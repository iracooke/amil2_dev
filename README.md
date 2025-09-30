# Acropora millepora developmental transcriptome 

[![DOI](https://zenodo.org/badge/741772001.svg)](https://doi.org/10.5281/zenodo.17230817)

This repository contains two related projects. 

1. R Shiny code for [amil-deview](https://amil-deview.mmb.group/) a web application for visualising gene expression changes during development of the coral *Acropora millepora*
2. Scripts used to process raw sequencing data underlying this web application. 

### Web App

The web app includes standard shiny components for the UI and server backend. These are contained with `.R` files at the top level of this repository. 

If you would like to run the web app locally you will need to download its database of gene expression values as well as fasta files used to facilitate blast searches. This can be done as follows;

```bash
git clone git@github.com:iracooke/amil2_dev.git
cd amil2_dev
wget http://data.qld.edu.au/public/Q5999/iracooke/amil2_dev/shiny_data.tgz
tar -zxvf
```

After checking out data in this way you should be able to open the project in RStudio.  Then open the `app.R` file and click run to start the shiny application.

### Data Processing

Three nextflow pipelines were used to perform the bulk of data processing.  

**MOQC** Marine Omics QC

An initial assessment of raw data was performed with [moqc](https://github.com/marine-omics/moqc).  This pipeline performs calculates standard QC metrics on Illumina sequencing data using fastqc and multiqc.  It also performs taxonomic classification on a subset of reads using krakenuniq for the purposes of identifying commensal or symbiotic organisms that may be present within the host sample. 

Full details of the databases used include URLs to download original files for each species are provided within the moqc repository under [databases](https://github.com/marine-omics/moqc/tree/main/databases).  
Databases include representative genomes for all major Symbiodiniaceae genera as well as representative coral genomes including *Acropora*.

We used `moqc` revision 255d880 which depends on the following software

- [krakenuniq](https://github.com/fbreitwieser/krakenuniq/) version 1.0.2
- [fastqc](https://github.com/s-andrews/FastQC) version 0.11.5
- [KronaTools](https://github.com/marbl/Krona) version 2.8.1

All these programs were run with default arguments (aside from arguments affecting output format and performance). Both krakenuniq and fastqc were run in paired-end read mode.

**MORP** Marine Omics RNASeq Pipeline

The [morp](https://github.com/marine-omics/morp) pipeline includes steps to trim reads (primarily to remove adapters), align to a reference transcript set using bowtie2 and calculate transcript-level counts using RSEM.

Since `morp` is designed for marine organism samples where symbionts, commensals or parasites are often present it performs mapping to a combined reference transcript set.  In our case we used the *Acropora millepora* transcripts as the host and *Durusdinium* transcripts downloaded from [OIST](https://marinegenomics.oist.jp/symbd/download/102_symbd_transcriptome_nucl.fa.gz) as the symbiont reference.  These are first marked so that host and symbiont transcripts can be easily separated after mapping and then concatenated to form a combined reference file. 

We used `morp` revision 310399f which depends on the following software

- [fastp](https://github.com/OpenGene/fastp) version 0.23.1
- [bowtie2](https://github.com/BenLangmead/bowtie2) version 2.5.0
- [RSEM](https://github.com/deweylab/RSEM) version 1.3.3

Read trimming was performed with fastp with default parameters in paired end read mode.  In this mode fastp operates as follows;
  
  - Removes reads if more than 40% of bases are below a quality threshold (Q<15)
  - Removed adapters after first autodetecting the adapter sequences taking advantage of PE overlaps where present

Bowtie2 alignment was performed internally by RSEM via the RSEM command `rsem-calculate-expression`

In principle this data includes information about both host and symbiont gene expression changes, however, as the amount of symbiont was less than 2% (as shown by MOQC) we did not include symbiont transcripts in the analyses for DEView.


**MOAT** Marine Omics AnnoTation

The [moat](https://github.com/marine-omics/moat) pipeline was used to perform functional annotation (via homology) for all *Acropora millepora* transcripts. 

`moat` includes signalp, tmhmm, blastp and interproscan searches based on protein sequences. It also performs `blastx` on transcript sequences.  

We ran `moat` revision 255d880 which depends on the following software

- [Interproscan]() version 5.59-91.0
- [NCBI Blast+]() version 2.13.0
- [signalp]() version 4.1c
- [tmhmm]() version 2.0c

BLAST (blastp and blastx) searches were performed against the Swissprot database downloaded December 13 2022.  Blast searches were performed with `-max_target_seqs 5` and where multiple hits were obtained for the same query we chose the hit with the minimum evalue. If no hit had an evalue < 1 x 10-5 then no blast hit was recorded.


**Database Preparation**

After running nextflow pipelines further processing with R was performed to [supplement annotation via uniprot](01_annotation.md) and [normalise read counts and save sqlite tables](02_process_raw_amil2.md)

