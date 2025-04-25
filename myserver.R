# Define server logic
library(shiny)
library(DT)
library(tidyverse)
library(dbplyr)
library(ComplexHeatmap)
library(InteractiveComplexHeatmap)
library(RColorBrewer)

options(dplyr.summarise.inform = FALSE)

source('blast.R')
source('plot_genes.R')

cat(file=stderr(),"Opening db connection")
dbconn <- DBI::dbConnect(RSQLite::SQLite(), "shiny_data/amil2.sqlite")
onStop(function() {
  DBI::dbDisconnect(dbconn)
})
cat(file=stderr(),"Done opening db connection")

server <- function(input, output, session) {
  pdf(NULL)
  
  parse_csv_input <- function(raw_text){
    str_trim(str_split(raw_text,",",simplify = TRUE))
  }
  
  annotations <- reactive({
    dbconn %>% tbl("annotations")
  })
  
  uniprot_goterms <- reactive({
    dbconn %>% tbl("uniprot_goterms")
  })
  
  pfam_accessions <- reactive({
    dbconn %>% tbl("pfam_accessions")
  })
  
  filtered_genes <- eventReactive(input$search_anno,{

    cat(file=stderr(),"Searching for genes based on annotations\n")
    
    # Gene ids provided directly
    gene_list <- parse_csv_input(input$gene_list_text)
    
    # Gene ids corresponding to listed GO terms
    go_list <- parse_csv_input(input$go_list_text)
    if(length(go_list)>0){
      go_gene_list <- uniprot_goterms() %>% 
        filter(go %in% go_list) %>% 
        pull(gene)
      gene_list <- c(gene_list,go_gene_list)
    }
    
    pfam_list <- parse_csv_input(input$domain_list_text)
    if(length(pfam_list)>0){
      pfam_gene_list <- pfam_accessions() %>% 
        filter(pfam_acc %in% pfam_list) %>% 
        pull(gene)
      gene_list <- c(gene_list,pfam_gene_list)
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
  
  blast_genes <- eventReactive(input$search_blast,{
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    
    run_blast(input,progress)
    
  })
  
  filtered_data <- reactive({
      cat(file=stderr(),"Loading count-filtered data \n")
      progress <- shiny::Progress$new()
      on.exit(progress$close())

      progress$set(message = paste("Loading gene count data ..."),value=0.5)      
      
      if ( input$search_blast == 0 ){
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
  
  
  table_genes <- function(fd){
    gene_ids <- fd$gene %>% base::unique()
    
    tbg <- annotations() %>% 
      filter(gene %in% gene_ids) %>% 
      select(gene,protein_name=protein,
             uniprot_id,
             genename) %>% 
      distinct() %>% 
      as.data.frame()
    
    tbg
  }
  
  ht_obj = reactiveVal(NULL)
  ht_pos_obj = reactiveVal(NULL)
  
   output$genesPlot <- renderPlot({
     fd <- filtered_data()
     rs <- input$genetable_rows_selected
     if ( is.null(rs) || length(rs)==0){
       plot_list <- plot_genes(fd,input) 
     } else {
       genes_selected <- table_genes(fd)[rs,]$gene
       plot_list <- fd %>% filter(gene %in% genes_selected) %>% plot_genes(input)
     }
     
     if (plot_list$type == "heatmap"){
       ht = draw(plot_list$plot,heatmap_legend_side="bottom")
       ht_pos = htPositionsOnDevice(ht,calibrate = FALSE)
       ht_obj(ht)
       ht_pos_obj(ht_pos)
     } else {
       plot_list$plot
     }
     
   })
   
   proxy = dataTableProxy('genetable')
   
   observeEvent(input$heatmap_brush, {

     lt = getPositionFromBrush(input$heatmap_brush)
     selection = selectArea(ht_obj(), lt[[1]], lt[[2]], mark = FALSE, ht_pos = ht_pos_obj(),
                            verbose = FALSE, calibrate = FALSE)
     selectRows(proxy, selection$row_index[[1]])
     
   })
   
  observeEvent(input$reset_selection,{selectRows(proxy,NULL)})
   
   output$gene_selection_summary <- renderText({
     fd <- filtered_data()
     tg <- table_genes(fd)
     rs <- input$genetable_rows_selected
     if ( is.null(rs) || length(rs)==0){
       paste0("Showing all ", nrow(tg), " matching genes")
     } else {
       paste0("Showing ", length(input$genetable_rows_selected), " of ", nrow(tg)," matching genes")
    }
   })
   
   
   output$genetable <- renderDT(table_genes(filtered_data()))
}


