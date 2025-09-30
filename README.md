# Acropora millepora developmental transcriptome 

This repository contains two related projects. 

1. R Shiny code for [amil-deview](https://amil-deview.mmb.group/) a web application for visualising gene expression changes during development of the coral *Acropora millepora*
2. Scripts used to process raw sequencing data underlying this web application. 

### Web App

The web app includes standard shiny components for the UI and server backend. These are contained with `.R` files at the top level of this repository. 

If you would like to run the web app locally you will need to download its database of gene expression values as well as fasta files used to facilitate blast searches. This can be done as follows;

```bash


```

### Data Processing

Three nextflow pipelines were used to perform the bulk of data processing.  

**MOQC**

An initial assessment of raw data was performed with [moqc](https://github.com/marine-omics/moqc).  This pipeline performs calculates standard QC metrics on Illumina sequencing data using fastqc and multiqc.  It also performs taxonomic classification on a subset of reads using krakenuniq for the purposes of identifying commensal or symbiotic organisms that may be present within the host sample. 
Full details of the databases used are provided within the moqc repository.  For the purposes of this analysis it is important to note that the databases include representative genomes for all major Symbiodiniaceae genera as well as representative coral genomes including *Acropora*.

moqc