#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#@created: 16.02.2023
#@author: Danil Zilov
#@contact: zilov.d@gmail.com

import argparse
import os
import os.path
from inspect import getsourcefile
from datetime import datetime
import string
import random

def config_maker(settings, config_file):
    config = f"""
    "outdir" : "{settings["outdir"]}"
    "forward_read" : "{settings["fr"]}"
    "reverse_read" : "{settings["rr"]}"
    "assembler" : "{settings["mode"]}"
    "threads" : "{settings["threads"]}"
    "busco_lineage": "{settings["busco_lineage"]}"
    """

    if not os.path.exists(os.path.dirname(config_file)):
        os.mkdir(os.path.dirname(config_file))


    with open(config_file, "w") as fw:
        fw.write(config)
        print(f"CONFIG IS CREATED! {config_file}")
      

def main(settings):
    ''' Function description.
    '''
        
    if settings["debug"]:
        snake_debug = "-n"
    else:
        snake_debug = ""

    #Snakemake
    command = f"""
    snakemake --snakefile {settings["execution_folder"]}/workflow/snakefile \
              --configfile {settings["config_file"]} \
              --cores {settings["threads"]} \
              --use-conda {snake_debug}"""
    print(command)
    os.system(command)


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='hifiblender: snakemake pipeline for genome assembly with HiFi reads and its QC')
    parser.add_argument('-a','--assembler', help="assembler to use [default == hifiasm]", 
                        choices=["hifiasm", "flye", "canu", "lja", "verkko"], default="hifiasm")
    parser.add_argument('-f','--fasta', help="path to HiFi reads in fasta-format", default="")
    parser.add_argument('--bam', help="path to HiFi reads in BAM format", default="")
    parser.add_argument('-h', '--merge-haplotips', 'Merge haplotips of resulting assembly',  action='store_true')
    parser.add_argument('--merge-haplotips-tool', help='Tool to merge haplotips [default == purgedups]', choices=['purgedups'], default='purgedups')
    parser.add_argument('-b','--busco_lineage', help="path to busco lineage database folder", default="")
    parser.add_argument('-o','--outdir', help='output directory', required=True)
    parser.add_argument('-t','--threads', help='number of threads [default == 8]', default = "8")
    parser.add_argument('-p', '--prefix', help='Run prefix [default == reads prefix]', default='')
    parser.add_argument('-d','--debug', help='debug mode', action='store_true')
    args = vars(parser.parse_args())

    assembly_fasta = os.path.abspath(args["assembly"])
    threads = args["threads"]
    debug = args["debug"]
    assembler = args["assembler"]
    fasta = args["fasta"]
    bam = args["bam"]
    haplomerge = argparse['merge-haplotips']
    merge_tool = argparse['merge-haplotips-tool']
    busco_lineage = args["busco_lineage"]
    outdir = os.path.abspath(args["outdir"])
    
    assert(fasta or bam), "Reads in FASTA of BAM format are required"
    
    execution_folder = os.path.dirname(os.path.abspath(getsourcefile(lambda: 0)))
    execution_time = datetime.now().strftime("%d_%m_%Y_%H_%M_%S")
    random_letters = "".join([random.choice(string.ascii_letters) for n in range(3)])
    config_file = os.path.join(execution_folder, f"config/config_{random_letters}{execution_time}.yaml")
            
    settings = {
        "outdir" : outdir,
        "threads" : threads,
        "assembler" : assembler,
        "fasta": fasta,
        "bam" : bam,
        "execution_folder" : execution_folder,
        "debug" : debug,
        "config_file" : config_file,
        "busco_lineage" : busco_lineage,
    }
    
    config_maker(settings, config_file)
    main(settings)
