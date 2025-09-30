Annotation Table
================

Annotation of the Amil 2.0 genome was first done using `moat`. We then
create a list of all unique Swissprot IDs included in the `moat`
annotation and submit them to the uniprot mapping tool to retrieve
additional annotation fields. To obtain these fields we add two
additional columns to the Swissprot default;

- Gene Ontology IDs: Uniprot GO terms
- Gene Ontology (GO): Names of Uniprot GO terms

``` bash
cat hpc/moat/moat_out/final_table/annotation.tsv | awk '{print $3}' | sort -u > hpc/moat/uniprot_ids.txt
```

Prepare joined annotation table

``` r
raw_annotations <- read_tsv("hpc/moat/moat_out/final_table/annotation.tsv",show_col_types = FALSE)
uniprot_annotations <- readxl::read_excel("hpc/moat/uniprot-compressed_true_download_true_fields_accession_2Creviewed_2C-2022.12.22-23.51.02.69.xlsx")

merged_annotations <- raw_annotations %>% 
  left_join(uniprot_annotations,by=c("Swissprot_acc"="Entry"))

merged_annotations %>% write_tsv("hpc/amil2_annotations.tsv")
```
