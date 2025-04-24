echo 'sample,fastq_1,fastq_2' > samples.csv
for f in ../../raw_data/*R1.fastq.gz;do bn=$(basename $f);echo ${bn%_C[78]*},$f,${f/R1/R2};done >> samples.csv


