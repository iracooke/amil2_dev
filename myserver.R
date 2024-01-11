# Define server logic
library(shiny)
library(DT)
library(tidyverse)
library(dbplyr)
library(ComplexHeatmap)
library(RColorBrewer)


source('blast.R')
source('plot_genes.R')

cat(file=stderr(),"Opening db connection")
dbconn <- DBI::dbConnect(RSQLite::SQLite(), "shiny_data/amil2.sqlite")
onStop(function() {
  DBI::dbDisconnect(dbconn)
})
cat(file=stderr(),"Done opening db connection")

server <- function(input, output) {

  table_genes <- function(fd){
    gene_ids <- fd$gene %>% unique()

    tbg <- annotations() %>% 
      filter(gene %in% gene_ids) %>% 
      select(gene,protein_name=protein,
             uniprot_id,
             genename) %>% 
      distinct() %>% 
      as.data.frame()

    tbg
  }
  
  parse_csv_input <- function(raw_text){
    str_trim(str_split(raw_text,",",simplify = TRUE))
  }
  
  annotations <- reactive({
    dbconn %>% tbl("annotations")
  })
  
  uniprot_goterms <- reactive({
    dbconn %>% tbl("uniprot_goterms")
  })
  
  filtered_genes <- eventReactive(input$go_anno,{

    cat(file=stderr(),"Searching for genes based on annotations\n")
    gene_list <- parse_csv_input(input$gene_list_text)
    
    go_list <- parse_csv_input(input$go_list_text)
    if(length(go_list)>0){
      go_gene_list <- uniprot_goterms() %>% 
        filter(go %in% go_list) %>% 
        pull(gene)
      gene_list <- c(gene_list,go_gene_list)
    }
    
    anno <- annotations()
    
    if ( str_length(input$name_list_text) > 0 ){
      protein_pattern = paste("%",input$name_list_text,"%",sep = "")
      name_gene_list <- anno %>% 
        filter(protein %like% protein_pattern) %>% 
        pull(gene)
      gene_list <- c(gene_list,name_gene_list)
    }
    
    anno %>% 
      filter(gene %in% gene_list) %>% 
      pull(gene)

  })
  
  blast_genes <- eventReactive(input$go_blast,{
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    
    run_blast(input,progress)
    
  })
  
  filtered_data <- reactive({
      cat(file=stderr(),"Loading count-filtered data \n")
      progress <- shiny::Progress$new()
      on.exit(progress$close())

      progress$set(message = paste("Loading gene count data ..."),value=0.5)      
      
      if ( input$go_blast == 0 ){
        fg <- filtered_genes()
      } else {
        fg <- blast_genes()
      }
  
      cat(file=stderr(),"After filtering got ",length(fg)," geneids\n")

      vst_counts <- dbconn %>% 
        tbl("vst_counts")
      raw_counts <- dbconn %>% 
        tbl("raw_counts")
      sample_table <- dbconn %>% 
        tbl("samples") %>% 
        collect()

#      browser()
      
      genes_passing_count_filter <- raw_counts %>% 
        filter(gene %in% fg) %>% 
        collect() %>% 
        rowwise %>% 
        mutate(sum=sum(c_across(-gene))) %>% 
        filter(sum >= input$min_count) %>% 
        pull(gene)

      cat(file=stderr(),"After count filtering got ",length(genes_passing_count_filter)," geneids\n")      
            
      filtered_counts_long <- vst_counts %>% 
        filter(gene %in% genes_passing_count_filter) %>% 
        collect() %>% 
        pivot_longer(names_to = "sample",-gene,values_to = "vst") %>% 
        left_join(sample_table,by=c("sample")) 

      cat(file=stderr(),"Count data has ",nrow(filtered_counts_long)," rows\n")      
            
      filtered_counts_long

  })
  
     
   output$genesPlot <- renderPlot({
     fd <- filtered_data()
     rs <- input$genetable_rows_selected
     if ( is.null(rs) || length(rs)==0){
       plot_genes(fd,input) 
     } else {
       genes_selected <- table_genes(fd)[rs,]$gene
       fd %>% filter(gene %in% genes_selected) %>% plot_genes(input)
     }
   })
   
   output$genetable <- renderDataTable(table_genes(filtered_data()))
}


