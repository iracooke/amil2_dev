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
  p_type <- "none"
  if ( num_genes < input$num_hm_genes ){
    p_type <- "line_scatter"
    if ( input$use_average){
      p <- fd %>% group_by(gene,time_label,time) %>% 
        summarise(vst=mean(vst,na.rm = TRUE)) %>% 
        ungroup() %>% 
        ggplot(aes(x=reorder(time_label,time),y=vst)) + 
        geom_point(size = 2.5) + 
        # Add dashed line as indicator for settlement induction
        geom_vline(xintercept="133hpf", colour ="grey44",linetype = "dashed")+
        # Add axis labels
        xlab("Developmental stages") +
        ylab("Normalised gene expression \n (Variance stabilising transformations)")+
        geom_line(aes(group=gene)) +
        theme(
          axis.text.x = element_text(angle=70,vjust = 0.5, hjust=0.5),
          panel.background = element_rect(fill = "white",
                                          colour = "grey88",
                                          size = 0.5, linetype = "solid"),
          panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                          colour = "grey88"), 
          panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                          colour = "grey88"),
          panel.border = element_rect(color = "black", fill = NA),
          #Font sizes
          axis.title.x = element_text(size = 20),
          axis.title.y = element_text(size = 20),
          axis.text = element_text(size = 15),
          strip.text.x = element_text(size = 15)
        
        ) +  
        facet_wrap(~gene)        
    } else {
      p <- ggplot(fd,aes(x=reorder(time_label,time),y=vst)) + 
        geom_point(aes(color=cross, shape=cross),size = 2.5) + 
        geom_vline(xintercept="133hpf", colour ="grey44",linetype = "dashed")+
        theme(
          axis.text.x = element_text(angle=70,vjust = 0.5, hjust=0.5),
          panel.background = element_rect(fill = "white",
                                          colour = "grey88",
                                          size = 0.5, linetype = "solid"),
          panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                          colour = "grey88"), 
          panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                          colour = "grey88"),
          panel.border = element_rect(color = "black", fill = NA),
          
          #Font sizes
          axis.title.x = element_text(size = 20),
          axis.title.y = element_text(size = 20),
          axis.text = element_text(size = 15),
          strip.text.x = element_text(size = 15),
          legend.title=element_text(size=15), 
          legend.text=element_text(size=15)
          
        ) +  
        # Add axis labels
        xlab("Developmental stages") +
        ylab("Normalised gene expression \n (Variance stabilising transformations)")+
        # Manually change colours
        scale_color_manual(values = c("B"="red3", "A"="green4"), name="Cross")+ 
        scale_shape_manual(values = c(16,17),name="Cross")+
        facet_wrap(~gene)
    }
    
  } else {
    p_type <- "heatmap"
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
    
    
    p <- Heatmap(hm_centered[,column_order],
                 cluster_columns = FALSE, 
                 col=rev(brewer.pal(n = 11, name = "RdBu"))
                 )
  }
  list(plot = p, type = p_type)
}