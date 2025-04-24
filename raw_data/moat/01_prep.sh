cat cds_from_genomic.fna| bioawk -c fastx '{printf(">%s\n%s\n",$name,$seq)}' | sed -E 's/.*(XP.*)_[0-9]+$/>\1/' > transcripts.fasta
