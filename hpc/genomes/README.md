## Genomic Resources

##### Coral Host

The *Acropora millepora* genome was obtained from the NCBI genomes repository using the datasets command

```bash
datasets download genome accession GCF_013753865.1 --include gff3,rna,cds,protein --filename GCF_013753865.1.zip
unzip GCF_013753865.1.zip
```

For our purposes the important files here are the predicted transcripts, `cds_from_genomic.fna` and predicted proteins `protein.faa`


##### Algal Symbionts

A representative durusdinium transcript set was obtained from the OIST marine genomics resources page

wget 'https://marinegenomics.oist.jp/symbd/download/102_symbd_transcriptome_nucl.fa.gz'
gunzip 102_symbd_transcriptome_nucl.fa.gz


