# Raw Sequencing Data

Sequencing data has been deposited on SRA and can be accessed from https://www.ncbi.nlm.nih.gov/sra/PRJNA1332262

Scripts in `moat`, `moqc` and `morp` directories assume that fastq files are available in this directory under their original filenames. 

If you wish to reproduce these analyses you can either

1. Adjust `moat`, `moqc` and `morp` scripts to use SRA generated filenames
2. Download SRA metadata which provides a list of original filenames associated with each SRA accession.  Then rename SRA fastq files to their original filenames

