import glob
import subprocess

for prj in glob.glob("metadata/*.txt"):
    cmd = ['download_rnaseq_fastq_from_sra.py','-i',prj,'-nt','4']
    print(' '.join(cmd))
    subprocess.run(cmd)