workdir: "/home/myan/scratch/private/pomeRTD"

SRR,FRR = glob_wildcards("00.fastp.filtered.fq/"+"{srr}_clean_{frr}.fastq.gz")

print(SRR)

#kallisto index 03.pomeRTD/pome_RTDmaker_output/pome.fa -i 05.kallisto.quant/pomeRTD

rule all:
    input:
        expand("05.kallisto.quant/" + "{srr}/abundance.tsv",srr=SRR)


rule runkallisto:
    input:
        read01 = "00.fastp.filtered.fq/"+"{srr}_clean_1.fastq.gz",
        read02 = "00.fastp.filtered.fq/"+"{srr}_clean_2.fastq.gz",
        index = "05.kallisto.quant/" + "pomeRTD"
    output:
        abund = "05.kallisto.quant/" + "{srr}/abundance.tsv"
    threads:
        4
    params:
        "05.kallisto.quant/" + "{srr}"
    shell:
        """
        kallisto quant -i {input.index} -o {params} -t {threads} {input.read01} {input.read02}
        """