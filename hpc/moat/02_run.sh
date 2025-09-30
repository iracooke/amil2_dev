nextflow run marine-omics/moat \
	-profile zodiac \
	-r 255d880 -c custom.config \
	--cds transcripts.fasta \
	--prot protein.faa \
	--outdir moat_out -resume -with-tower

