#!/bin/bash

#SBATCH --job-name="pomertd"
#SBATCH --mail-user=mingyan24@126.com
#SBATCH --mail-type=FAIL
#SBATCH --partition=long

source activate rnaseq
snakemake --cluster "sbatch --output=/mnt/shared/scratch/myan/private/pomeRTD/00.slurm.out/%j.out \
--error=/mnt/shared/scratch/myan/private/pomeRTD/00.slurm.out/%j.out --cpus-per-task={threads} \
--mail-type=FAIL --mail-user=mingyan24@126.com --mem={resources.mem}" \
--jobs 24 -s /mnt/shared/scratch/myan/private/pomeRTD/pomeRTD_v01.smk
