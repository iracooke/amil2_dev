infer_seq_type <- function(seqstr){
  seq_chars <- str_split(seqstr,"")[[1]] %>% unique()
  if ( all(seq_chars %in% c("G","C","T","A"))){
    return("Nucleotide")
  } else {
    return("Protein")
  }
}

run_blast <- function(input,progress){
  query_seq <- str_replace_all(input$text_sequences," ","") %>% str_replace_all("[\r\n]" , "")
  cat(file=stderr(),"Finding genes with blast using sequence:\n",query_seq,"\n")
  
  
  
  if ( infer_seq_type(query_seq)=="Protein" ){
    blast_db <- "shiny_data/protein.fa"
    blast_cmd <- "blastp"
  } else {
    blast_db <- "shiny_data/CDS.fa"
    blast_cmd <- "blastn"
  }
  evalue <- input$evalue
  
  query_file <- tempfile("query",fileext = ".fasta")
  con<-file(query_file)
  writeLines(c(">query",query_seq), con)
  close(con)
  
  colnames <- c("qseqid",
                "sseqid",
                "pident",
                "length",
                "mismatch",
                "gapopen",
                "qstart",
                "qend",
                "sstart",
                "send",
                "evalue",
                "bitscore")
  
  progress$set(message = paste("Running ",blast_cmd," ..."),value=0.5) 
  
  blast_args <- c("-db",blast_db,
                  "-query",query_file,
                  "-outfmt 6",
                  "-num_threads",8,
                  "-evalue",evalue)
  if ( input$max_hits > 0){
    blast_args <- c(blast_args,c("-max_target_seqs",input$max_hits))      
  }
  
  blast_out <- system2(blast_cmd,args = blast_args, stdout = TRUE, wait = TRUE)
  
  tidy_blast <- blast_out %>%
    as_tibble() %>% 
    separate(col = value, 
             into = colnames,
             sep = "\t",
             convert = TRUE) %>% 
    arrange(evalue)

#  tidy_blast$sseqid %>% str_extract(".*g[0-9]*") %>% unique()
  tidy_blast$sseqid %>% unique()  
}


