## 1 download pomegranate-related rna-seq dataset using kingfihser
`python run_download_rnaseq_fastq_from_sra.py`

## 2 fastp+star+stringtie

pomegranate cv. ' Tunisia' reference genome was downloaded from NCBI

`sbatch run_pomeRTD.sh`

## 3 run RTDMaker

```
python ~/scratch/apps/mingyan/Biotools/RTDmaker/RTDmaker.py ShortReads \
--assemblies 02.stringtie/ --SJ-data 01.star.mapping.02/ \
--SJ-reads 2 1 --genome reference/genome/pg_genomic.fa \
--fastq 00.fastp.filtered.fq/ --tpm 0.1  1 \
--fragment-len 0.7 --antisense-len 0.5 --add intronic \
--keep intermediary --ram 8 --outpath 03_pomeRTD --outname pome --prefix pome
````

## 4 run kallisto
`snakemake -s kallisto.smk --cores 16 -p`'

## 5 get gene and transcript abundances using R package tximport

```
library(readr);library(tidyverse);library(tidyverse);library(tximport);library(rhdf5)
tx2gene<-read_delim("../03.pomeRTD/pome_RTDmaker_output/pomeRTD_tx2gene.csv",delim = ";")
files<-list.files(".",full.names = TRUE,recursive = TRUE,pattern = "*.h5")
names(files)<- str_extract(files,pattern = "PRJ[A-z0-9]+/SRR[0-9]+") %>%  str_replace("/","_")
ka.genes<-tximport(files,type="kallisto",tx2gene = tx2gene)
ka.tx<-tximport(files,type = "kallisto",txOut = TRUE)

save(ka.genes,file = "kallisto_pomeRTD_gene_abund.Rdata")
save(ka.tx,file = "kallisto_pomeRTD_transcripts_abund.Rdata")

ka.genes$counts%>%as.data.frame()%>%rownames_to_column("gene_id")%>%write_tsv(file = "pomeRTD_genes_counts.tsv") 
ka.genes$abundance%>%as.data.frame()%>%rownames_to_column("gene_id")%>%write_tsv(file = "pomeRTD_genes_tpm.tsv") 
ka.genes$length%>%as.data.frame()%>%rownames_to_column("gene_id")%>%write_tsv(file = "pomeRTD_genes_length.tsv") 

ka.tx$abundance%>%as.data.frame()%>%rownames_to_column("gene_id")%>%write_tsv(file = "pomeRTD_transcripts_tpm.tsv")
ka.tx$length%>%as.data.frame()%>%rownames_to_column("gene_id")%>%write_tsv(file = "pomeRTD_transcripts_length.tsv") 
ka.tx$counts%>%as.data.frame()%>%rownames_to_column("gene_id")%>%write_tsv(file = "pomeRTD_transcripts_counts.tsv")


genes.tpm<-read_tsv("D:/Bioinformatics_Intro/pomeRTD/pomeRTD_genes_tpm.tsv")

for (bioject in readLines("D:/Bioinformatics_Intro/pomeRTD/bioproject.txt")){
  genes.tpm %>% 
    select("gene_id",starts_with(bioject)) %>% 
    write_csv(paste0(bioject,"_","pomeRTD_genes_tpm"))
}
```