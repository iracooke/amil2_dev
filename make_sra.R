library(tidyverse)


samples <- read_csv("raw_data/sra/samples.csv",show_col_types = FALSE) %>% 
  mutate(fastq_1 = basename(fastq_1), fastq_2 = basename(fastq_2)) %>% 
  group_by(sample) %>% 
  summarise(fastq_1 = paste(fastq_1,collapse=","),fastq_2 = paste(fastq_2,collapse=","))

biosample <- readxl::read_excel("raw_data/sra/Invertebrate.1.0_biosample.xlsx",skip=12)

sra <- samples %>% 
  left_join(biosample,by=c("sample"="*sample_name")) %>% 
  mutate(library_ID = sample) %>% 
  mutate(title = paste("RNAseq of Acropora millepora development: ",dev_stage)) %>% 
  select(sample_name=sample,library_ID,title,fastq_1,fastq_2) %>% 
  separate(fastq_1,into = c("filename","filename2"),sep=",") %>% 
  separate(fastq_2,into = c("filename3","filename4"),sep=",") 
  