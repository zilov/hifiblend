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
import yaml

def config_maker(settings, config_file):
    
    if not os.path.exists(os.path.dirname(config_file)):
        os.mkdir(os.path.dirname(config_file))

    with open(config_file, "w") as f:
        yaml.dump(settings, f)
        print(f"CONFIG IS CREATED! {config_file}")


def main(settings):
        
    if settings["debug"]:
        snake_debug = "-n"
    else:
        snake_debug = ""

    #Snakemake
    command = f"""
    snakemake --snakefile {settings["execution_folder"]}/workflow/snakefile \
              --configfile {settings["config_file"]} \
              --cores {settings["threads"]} \
              --use-conda --conda-frontend mamba {snake_debug}"""
    print(command)
    os.system(command)


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='hifiblender: snakemake pipeline for genome assembly with HiFi reads and its QC')
    parser.add_argument('-a','--assembler', help="assembler to use [default == hifiasm]", 
                        choices=["hifiasm", "hifiasm_hic", "flye", "canu", "lja", "verkko", "verkko_hic", "nextdenovo"], default="hifiasm")
    parser.add_argument('-f','--fastq', help="path to HiFi reads in fastq-format", default="")
    parser.add_argument('-1','--forward_hic_read', help="path to forward hic read", default="")
    parser.add_argument('-2','--reverse_hic_read', help="path to reverse hic read", default="")
    parser.add_argument('--bam', help="path to HiFi reads in BAM format", default="")
    parser.add_argument('-m','--merge_haplotips', help='Merge haplotips of resulting assembly', action='store_true')
    parser.add_argument('--merge_haplotips_tool', help='Tool to merge haplotips [default == purgedups]', choices=['purgedups'], default='purgedups')
    parser.add_argument('-b','--busco_lineage', help="path to busco lineage database folder", default="")
    parser.add_argument('-o','--outdir', help='output directory', required=True)
    parser.add_argument('-t','--threads', help='number of threads [default == 8]', default = "8")
    parser.add_argument('-g','--genome_size', help='genome size, e.g. 3.7m or 2.8g (required for canu and nextdenovo run)', default = "")
    parser.add_argument('--coverage', help="additionally perform read alignment and coverage counting for assembly", default=False, action='store_true')
    parser.add_argument('--assembly', help="run qc/coverage only on completed assembly", default=False)
    parser.add_argument('--scaffold', help="scaffold with RagTag (reference is required)", default=False, action='store_true')
    parser.add_argument('-r', '--reference', help="reference genome for scaffolding of draft assembly", default=False)
    parser.add_argument('-p', '--prefix', help='Run prefix [default == reads prefix]', default='')
    parser.add_argument('-d','--debug', help='debug mode', action='store_true')
    args = vars(parser.parse_args())

    threads = args["threads"]
    debug = args["debug"]
    assembler = args["assembler"]
    fastq = args["fastq"]
    bam = args["bam"]
    haplomerge = args['merge_haplotips']
    merge_tool = args['merge_haplotips_tool']
    busco_lineage = args["busco_lineage"]
    outdir = os.path.abspath(args["outdir"])
    forward_hic_read = args["forward_hic_read"]
    reverse_hic_read = args["reverse_hic_read"]
    genome_size = args["genome_size"]
    coverage = args["coverage"]
    assembly = args['assembly']
    reference = args['reference']
    scaffold = args['scaffold']
    
    if not assembly:
        assert(fastq or bam), "Reads in FASTA of BAM format are required"
    else:
        if coverage:
            assert(fastq or bam), "Reads in FASTA of BAM format are required for building coverage"
    
    
    if fastq:
        fastq = os.path.abspath(fastq)
    elif bam:
        bam = os.path.abspath(bam)
    if assembly:
        assembly = os.path.abspath(assembly)
    if reference:
        reference = os.path.abspath(reference)
        
    
    if assembler in ["hifiasm_hic", "verkko_hic"]:
        if not (forward_hic_read or reverse_hic_read):
            parser.error("\nhifiasm_hic and verkko_hic mode requires -1 {path_to_forward_read} and -2 {path_to_reverse_read}!")
        else:
            forward_hic_read = os.path.abspath(forward_hic_read)
            reverse_hic_read = os.path.abspath(reverse_hic_read)
    elif assembler in  ["canu", "nextdenovo"] and not genome_size:
            parser.error("\ncanu and nextdenovo mode requires genome size! E.g. -g 2.8m or -g 3.5g :)")
    if (forward_hic_read or reverse_hic_read) and assembler not in ["hifiasm_hic", "verkko_hic"]:
         parser.error("\nONLY hifiasm_hic and verkko modes requires -1 {path_to_forward_read} and -2 {path_to_reverse_read}! Please change run mode!")
    
    if busco_lineage:
        busco_lineage = os.path.abspath(busco_lineage)
    
    if scaffold and not reference:
        assert(reference), 'Reference fasta required to scaffold draft genome'    
        
    execution_folder = os.path.dirname(os.path.abspath(getsourcefile(lambda: 0)))
    execution_time = datetime.now().strftime("%d_%m_%Y_%H_%M_%S")
    config_file = os.path.join(execution_folder, f"config/config_{execution_time}.yaml")
    lja_bin = os.path.join(execution_folder, "./scripts/LJA/bin/lja")
    os.chdir(execution_folder)
            
    settings = {
        "outdir" : outdir,
        "threads" : threads,
        "assembler" : assembler,
        "fr" : forward_hic_read, 
        "rr" : reverse_hic_read,
        "fastq": fastq,
        "bam" : bam,
        "execution_folder" : execution_folder,
        "lja": lja_bin,
        "debug" : debug,            
        "config_file" : config_file,
        "busco_lineage" : busco_lineage,
        "genome_size": genome_size,
        "coverage": coverage,
        "assembly": assembly,
        "reference": reference,
        "scaffold": scaffold
    }
    
    config_maker(settings, config_file)
    main(settings)
