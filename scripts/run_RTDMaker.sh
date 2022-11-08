python ~/scratch/apps/mingyan/Biotools/RTDmaker/RTDmaker.py ShortReads \
--assemblies 02.stringtie/ --SJ-data 01.star.mapping.02/ \
--SJ-reads 2 1 --genome reference/genome/pg_genomic.fa \
--fastq 00.fastp.filtered.fq/ --tpm 0.1  1 \
--fragment-len 0.7 --antisense-len 0.5 --add intronic \
--keep intermediary --ram 8 --outpath 03_pomeRTD --outname pome --prefix pome
