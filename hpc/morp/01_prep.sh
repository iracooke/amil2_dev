# Copy in coral raw sequencing reads
#
echo 'sample,fastq_1,fastq_2' > samples.csv
for f in ../fastq/*R1.fastq.gz;do bn=$(basename $f);echo ${bn%_C[78]*},$f,${f/R1/R2};done >> samples.csv

# Copy in reference transcriptomes
cp ../genomes/ncbi_dataset/data/GCF_013753865.1/cds_from_genomic.fna .
cp ../genomes/102_symbd_transcriptome_nucl.fa .

# Make maps
grep '>'  cds_from_genomic.fna | sed 's/>//' | awk '{printf("%s\t%s\n",$2,$1)}' | sed 's/\[gene=//' | sed 's/\]//' > amil.g2t.map
grep '>' 102_symbd_transcriptome_nucl.fa | sed 's/>//' | awk '{printf("%s\t%s\n",$1,$1)}' | sed -E 's/_i[0-9]//' > symbd.g2t.map

