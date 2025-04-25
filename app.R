library(shiny)
library(bslib)

ui <- fluidPage(
  tags$head(includeHTML(("google-analytics.html"))),
  verticalLayout(

    titlePanel("Acropora millepora Development RNASeq. Version 2"),

    conditionalPanel(
      condition = ("(input.search_anno == 0) & (input.search_blast == 0)"),
      h3("Search for Genes based on their functional annotations"),
      wellPanel(
        p("Define genes using the following criteria. Note that criteria are additive so adding more criteria will produce a longer gene list"),

        textInput("gene_list_text", "Genes. A list of gene identifiers", value = "XP_029185411.2,XP_029192681.2", width = '100%', placeholder = "eg. XP_029192681.2,XP_029192681.2"),

        textInput("domain_list_text", "Domains. A list of PFam domains", value = NULL, width = '100%', placeholder = "eg. PF00046"),

        textInput("go_list_text", "GO Terms. A list of GO ids", value = NULL, width = '100%', placeholder = "eg. GO:0006355"),

        textInput("name_list_text", "Text to search in the protein name", value = NULL, width = '100%', placeholder = "eg. Peroxidasin"),
        actionButton("search_anno", "Find Genes")
      ),
      h3("Or Search for homologs using blast"),
      wellPanel(
        numericInput("evalue","E Value",value = 10,min=0),
        numericInput("max_hits", "Maximum number of hits. Set to 0 for no limit", 100, min = 0, max = Inf),
        textAreaInput("text_sequences", "Paste sequences for searching. Sequence type (nucleotide or protein) will be automatically detected",
                      value = "MRVISFLFTIYLIVSTSEARGDMSTEDATGQAMRPFIRRRRCSWITRLVCLRSPYRTFDG
RCNNLCDPTLGMANTPMVRLPGLRPPTAYEGNKFAPRQLSATSTSGRKVPLPNARRVSVR
VFVSGEGDVRFRRPPGTPQGTHLVMIWGQFLDHDLALTALTERVSCGTNAQPCPNKPDDC
IGIDVDRSVRLARDPSAQCIPLRRATRDRQGEQRNILTHFIDASQVYGSSTKTANELRDR
SANLGLMDVRQFLIPGTRSRPILPRQRQGFCRSNNPVREPCFRAGDDRPNENQGLTAMHT
VWVREHNRIARILHTLNPTWNDERLFQEARKIVIAEIQHITYNEWLPVFFSSTTRRAEGI
LLEQQGFFRGYSRNVSPAIINSFATAALRFGHSLVRGDFRLVVVGVPPRRQPRLDVSDFF
NPSPLYQPIRRQNPYGLIMKGLRSDRMRIVDHIFSPAVRERLIFDDGLSGDLTAINVQRG
RDHGLPPYVEFLKACGKRVRTFGQLRQVMSFVSHLRLRRVYRSVLDIDLFAGAMNEFPLR
GSAVGFTFGCILTQQFRNLRRGDRFWYERNDQRVGFTLPQLTQIRKVTMARVLCDNVDGY
RISQLSAFVVPSTRNIFRRCSGIPAMDFSPFKSFLGDESNAVEDAAVVEADSALTNDKPE
MEPILNEPEVALTPDETEAALFDDAVDYLST
PLPLSSDITPEPSSSSAPLP", width = "100%",height=200, placeholder = "Enter a single protein or nucleotide sequence to use as your query"),
        actionButton("search_blast", "Find Genes with BLAST")
      )
    ),

    conditionalPanel(
      condition = ("(input.search_anno != 0) | (input.search_blast != 0)"),
      h5("Match Summary"),
      wellPanel(
        layout_columns(
          card(textOutput("match_summary"),
          "You can narrow the selection by clicking individual rows in the table, or by dragging an area in the heatmap (if shown)"
          ),
          card(
            downloadButton("downloadCounts", "Download Expression Matrix"),
            downloadButton("downloadAnnotations", "Download Annotations"),            
          ),col_widths = c(8,4),
        )
      ),
      h5("Display Options"),
      wellPanel(
        page_fillable(
          layout_columns(
            numericInput("min_count", "Minimum read count for displayed genes", 10, min = 0, max = Inf),
            numericInput("num_hm_genes", "Number of genes required to display heatmap", 10, min = 2, max = 100)
          ),
        checkboxInput("use_average", "Average replicates ", TRUE),
      )),
      plotOutput("genesPlot",
                 height = "600px", 
                 brush = brushOpts(id = "heatmap_brush", 
                                   fill="auto", 
                                   delayType = "debounce", 
                                   delay = 600, resetOnNew = TRUE)),
      
      conditionalPanel(
        condition = ("input.genetable_rows_selected.length > 0"),
        h5(textOutput("gene_selection_summary")),
      
        actionButton("reset_selection","Undo selections and show all matching genes")
      ),
      
      DT::DTOutput('genetable')
      
    )
  )
)


source('myserver.R')

# Run the application 
shinyApp(ui = ui, server = server)
