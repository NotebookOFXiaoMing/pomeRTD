workdir: "/home/myan/scratch/private/pomeRTD"

genome_fasta = "/mnt/shared/scratch/myan/private/pomeRTD/reference/genome/pg_genomic.fa"
genome_gtf = "/mnt/shared/scratch/myan/private/pomeRTD/reference/gtf/pg_genomic.gtf"
genome_index_folder = "/mnt/shared/scratch/myan/private/pomeRTD/reference/genome_index/"

SRR,FRR = glob_wildcards("00.raw.fq/" + "{srr}_{frr}.fastq.gz")

#print(SRR,FRR)

rule all:
    input:
        expand("00.fastp.report/" + "{srr}.html",srr=SRR),
        directory(genome_index_folder + "star_index_pass1"),
        expand("01.star.mapping.01/{srr}_SJ.out.tab",srr=SRR),
        "01.star.mapping.01/SJ.filtered.tab",
        expand("01.star.mapping.02/{srr}_SJ.out.tab",srr=SRR),
        expand("02.stringtie/{srr}_stringtie.gtf",srr=SRR)

rule a_runfastp:
    input:
        read01 = "00.raw.fq/" + "{srr}_1.fastq.gz",
        read02 = "00.raw.fq/" + "{srr}_2.fastq.gz"

    output:
        read01 = "00.fastp.filtered.fq/" + "{srr}_clean_1.fastq.gz",
        read02 = "00.fastp.filtered.fq/" + "{srr}_clean_2.fastq.gz",
        html = "00.fastp.report/" + "{srr}.html",
        json = "00.fastp.report/" + "{srr}.json"

    threads:
        8
    resources:
        mem = 8000
    params:
        "-q 20 --cut_front --cut_tail -l 30"
    shell:
        """
        fastp -i {input.read01} -I {input.read02} -o {output.read01} \
        -O {output.read02} -w {threads} -h {output.html} -j {output.json} \
        {params}
        """

rule b_genomeindex01:
    input:
        genome_fasta = genome_fasta,
    output:
        genome_index_folder = directory(genome_index_folder + "star_index_pass1")
        #outputfileprefix = "star_index_pass1"
    threads:
        8
    resources:
        mem = 24000
    shell:
        """
        STAR --runMode genomeGenerate --runThreadN {threads} --genomeDir {output.genome_index_folder} \
        --genomeFastaFiles {input.genome_fasta}
        """

rule c_starmapping01:
    input:
        genome_fasta = genome_fasta,
        genome_index = directory(genome_index_folder + "star_index_pass1"),
        read01 = rules.a_runfastp.output.read01,
        read02 = rules.a_runfastp.output.read02,
    output:
        #output_bam_dir = directory(output_folder + "02.star.mapping.01/{exper}/{srr}/"),
        #output_tmp_dir = directory(output_folder + "tmp_folder/"),
        output_sjtab = "01.star.mapping.01/{srr}_SJ.out.tab"
    threads:
        8
    resources:
        mem = 24000
    params:
        output_bam_dir = "01.star.mapping.01/{srr}_"
    shell:
        """
        STAR --genomeDir {input.genome_index} --readFilesIn {input.read01} {input.read02} \
        --runThreadN {threads} --outBAMsortingThreadN {threads} \
        --alignIntronMin 60 --alignIntronMax 15000 --alignMatesGapMax 2000 \
        --alignEndsType Local --alignSoftClipAtReferenceEnds No \
        --outSAMprimaryFlag AllBestScore --outFilterMismatchNmax 1 --outFilterMismatchNoverLmax 1 \
        --outFilterMismatchNoverReadLmax 1 --outFilterMatchNmin 0 --outFilterMatchNminOverLread 0 \
        --outFilterMultimapNmax 15 --outSAMstrandField intronMotif --outSAMtype BAM SortedByCoordinate \
        --outBAMcompression 10 --alignTranscriptsPerReadNmax 30000 --readFilesCommand zcat \
        --outReadsUnmapped Fastx --outFileNamePrefix {params.output_bam_dir} \
        --alignSJoverhangMin 7 --alignSJDBoverhangMin 7 --alignSJstitchMismatchNmax 0 1 0 0
        """

rule d_mergefilterSJSfrompass1:
    input:
        sjsfolder = "01.star.mapping.01"
    output:
        sjsfilter = "01.star.mapping.01/SJ.filtered.tab"
    threads:
        8
    resources:
        mem = 24000
    script:
        "scripts/r/sjsfilter.R"

rule e_genomeindex02:
    input:
        genome_fasta = genome_fasta,
        sjsfiltertab = "01.star.mapping.01/SJ.filtered.tab"
    output:
        genome_index_folder = directory(genome_index_folder + "star_index_pass2")
    threads:
        8
    resources:
        mem = 24000
    params:
        genome_index_folder + "star_index_pass2"
    shell:
        """
        STAR --runMode genomeGenerate --runThreadN {threads} \
        --genomeDir {output.genome_index_folder} \
        --genomeFastaFiles {input.genome_fasta} \
        --outFileNamePrefix {params} \
        --sjdbFileChrStartEnd {input.sjsfiltertab}
        """

rule f_starmapping02:
    input:
        genome_fasta = genome_fasta,
        genome_index = directory(genome_index_folder + "star_index_pass2"),
        read01 = rules.a_runfastp.output.read01,
        read02 = rules.a_runfastp.output.read02,
    output:
        #output_bam_dir = directory(output_folder + "02.star.mapping.01/{exper}/{srr}/"),
        #output_tmp_dir = directory(output_folder + "tmp_folder/"),
        output_sjtab = "01.star.mapping.02/{srr}_SJ.out.tab"
    threads:
        8
    resources:
        mem = 24000
    params:
        output_bam_dir = "01.star.mapping.02/{srr}_"
    shell:
        """
        STAR --genomeDir {input.genome_index} --readFilesIn {input.read01} {input.read02} \
        --runThreadN {threads} --outBAMsortingThreadN {threads} \
        --alignIntronMin 60 --alignIntronMax 15000 --alignMatesGapMax 2000 \
        --alignEndsType Local --alignSoftClipAtReferenceEnds No \
        --outSAMprimaryFlag AllBestScore --outFilterMismatchNmax 1 --outFilterMismatchNoverLmax 1 \
        --outFilterMismatchNoverReadLmax 1 --outFilterMatchNmin 0 --outFilterMatchNminOverLread 0 \
        --outFilterMultimapNmax 15 --outSAMstrandField intronMotif --outSAMtype BAM SortedByCoordinate \
        --outBAMcompression 10 --alignTranscriptsPerReadNmax 30000 --readFilesCommand zcat \
        --outReadsUnmapped Fastx --outFileNamePrefix {params.output_bam_dir} \
        --alignSJoverhangMin 7 --alignSJDBoverhangMin 7 --alignSJstitchMismatchNmax 0 1 0 0
        """
rule g_stringtie:
    input:
        bamfile = "01.star.mapping.02/{srr}_Aligned.sortedByCoord.out.bam",
    output:
        outputgtf = "02.stringtie/{srr}_stringtie.gtf",
        abund_tab = "02.stringtie/{srr}_gene_abund.tab",
    params:
        "-a 10 -c 2.5 -f 0 -g 50 -j 0.1 -M 1"
    threads:
        8
    resources:
        mem = 8000
    shell:
        """
        stringtie {input.bamfile} -o {output.outputgtf} -p {threads} -A {output.abund_tab} {params}
        """

# '''
# python ~/scratch/apps/mingyan/Biotools/RTDmaker/RTDmaker.py ShortReads \
# --assemblies 02.stringtie/ --SJ-data 01.star.mapping.02/ \
# --SJ-reads 2 1 --genome reference/genome/pg_genomic.fa \
# --fastq 00.fastp.filtered.fq/ --tpm 0.1  1 \
# --fragment-len 0.7 --antisense-len 0.5 --add intronic \
# --keep intermediary --ram 8 --outpath 03_pomeRTD --outname pome --prefix pome
# '''