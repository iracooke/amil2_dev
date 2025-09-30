nextflow run marine-omics/morp -profile zodiac \
	-r 310399f --samples samples.csv \
	--outdir out_d \
	-c custom.config \
	--refa cds_from_genomic.fna \
	--refb 102_symbd_transcriptome_nucl.fa \
	--refa_map amil.g2t.map \
	--refb_map symbd.g2t.map -resume -with-tower

