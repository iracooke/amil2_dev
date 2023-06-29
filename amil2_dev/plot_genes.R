plot_genes <- function(fd,input){
  
  num_genes <- fd$gene %>% n_distinct()
  
#  browser()
  
  validate(
    need(num_genes<1000 , "Too many genes selected. Try a more specific set")
  )
  
  validate(
    need(num_genes>0 , "No genes selected.")
  )
  
  
  
  p <- NULL
  if ( num_genes < input$num_hm_genes ){
    if ( input$use_average){
      p <- fd %>% group_by(gene,time_label,time) %>% 
        summarise(vst=mean(vst,na.rm = TRUE)) %>% 
        ungroup() %>% 
        ggplot(aes(x=reorder(time_label,time),y=vst)) + 
        geom_point() + 
        geom_line(aes(group=gene)) +
        theme(axis.text.x = element_text(angle=90)) + xlab("Stage") +
        facet_wrap(~gene)        
    } else {
      p <- ggplot(fd,aes(x=reorder(time_label,time),y=vst)) + geom_point(aes(color=cross)) + 
        theme(axis.text.x = element_text(angle=90)) + xlab("Stage") +
        facet_wrap(~gene)
    }
    
  } else {
    if ( input$use_average){
      hmd <- fd %>% 
        select(gene,vst,time_code,cross,sample) %>% 
        filter(!is.na(gene)) %>% 
        group_by(gene,time_code) %>% 
        summarise(vst=mean(vst,na.rm = TRUE)) %>% 
        distinct() %>% 
        pivot_wider(names_from = time_code,values_from = vst,id_cols = gene)
      
      hm_matrix <- hmd %>% column_to_rownames(var="gene") %>% as.matrix()
      
      hm_centered <- hm_matrix %>% t() %>% scale(scale=FALSE) %>% t()
      
      condition_info <- fd %>% select(time_code,time) %>% unique()
      
      column_order <- match(condition_info %>% arrange(time) %>% pull(time_code),colnames(hm_centered))
      
    } else {
      hmd <- fd %>% 
        select(gene,vst,time_code,cross,sample) %>% 
        filter(!is.na(gene)) %>% 
        distinct() %>% 
        pivot_wider(names_from = sample,values_from = vst,id_cols = gene)
      
      hm_matrix <- hmd %>% column_to_rownames(var="gene") %>% as.matrix()
      
      hm_centered <- hm_matrix %>% t() %>% scale(scale=FALSE) %>% t()
      
      condition_info <- fd %>% select(sample,time,cross) %>% unique()
      
      column_order <- match(condition_info %>% arrange(time,cross) %>% pull(sample),colnames(hm_centered))
      
    }
    
    
    p <- Heatmap(hm_centered[,column_order],cluster_columns = FALSE)
  }
  p
}