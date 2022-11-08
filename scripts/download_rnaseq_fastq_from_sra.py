#from inspect import ArgSpec
#import json
import os
import argparse
import pandas as pd
import subprocess

from multiprocessing import Pool

def get_srr_list(sraruntable):
    metadf = pd.read_csv(sraruntable).Run
    return [srr for srr in metadf]

def output_folder(sraruntable):
    metadf = pd.read_csv(sraruntable).BioProject
    return [srr for srr in metadf][0]

# def get_srr_json(srr):
#     cmd = ['ffq','--ftp',srr,'-o',srr+".json"]
#     print(' '.join(cmd))
#     subprocess.run(cmd)
    
# def get_srr_url(input_json):
#     df = json.load(open(input_json))
#     return [df[0]['url'],df[1]['url']]


# def download_srr(srr):
#     get_srr_json(srr)
#     for url in get_srr_json(srr+".json"):
#         cmd = ['wget',url]
#         print(' '.join(cmd))
#         subprocess.run(cmd)

kingfisher = '/mnt/shared/scratch/myan/apps/mingyan/Biotools/kingfisher-download/bin/kingfisher'

def download_srr(srr):
    cmd = [kingfisher,'get','-r',srr,'-m','ena-ftp','--quiet','--download-threads','4']
    print(' '.join(cmd))
    subprocess.run(cmd)

def final_run():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='a',
        epilog='''
        @author: Mingyan
        '''
    )
    
    parser.add_argument('-i',"--input",required=True)
    #parser.add_argument('-o','--output-folder',required=True)
    parser.add_argument('-nt','--number-threads',required=True,type=int,default=1)
    
    args = parser.parse_args()
    
    in_file = os.path.realpath(args.input)
    #output_folder = args.output_folder
    num_threads = args.number_threads
    op = os.path.join(os.getcwd(),output_folder(in_file))
    os.makedirs(op,exist_ok=True)
    os.chdir(os.path.realpath(op))
    
    
    srr_list = get_srr_list(in_file)
    
    with Pool(num_threads) as p:
        p.map(download_srr,srr_list)
        p.close()
        p.join()
        
        
if __name__ == '__main__':
    final_run()
    
    