cp ../genomes/ncbi_dataset/data/GCF_013753865.1/cds_from_genomic.fna .
cat cds_from_genomic.fna| bioawk -c fastx '{printf(">%s\n%s\n",$name,$seq)}' | sed -E 's/.*(XP.*)_[0-9]+$/>\1/' > transcripts.fasta

cp ../genomes/ncbi_dataset/data/GCF_013753865.1/protein.faa .