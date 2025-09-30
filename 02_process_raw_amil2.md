Prepare Count Tables for Visualisation
================

First we read the metadata associated with the experiment and tidy up
the sample names

We then used tximport to read isoform level expression values calculated
by RSEM and then aggregate these to gene-level counts. This count matrix
was then used as input for DESeq2 where the `vst` function was used to
calculate variance-stabilised and normalised expression values for
visualisation purposes.

Gene annotations obtained via the `01_annotation` script were then read
and used to create a series of tables to facilitate fast lookup of GO
and PFam accessions. These were then saved to sqlite format for use with
the DEview application.
