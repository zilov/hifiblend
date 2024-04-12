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

def check_input(path_to_file):
    if not os.path.exists(path_to_file) or os.path.getsize(path_to_file) == 0:
        raise ValueError(f"The file '{path_to_file}' does not exist or empty. Check arguemnts list!")
    return os.path.abspath(path_to_file)

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
    
    ## assembly options
    parser.add_argument('-a','--assembler', help="assembler to use [default == hifiasm]", 
                        choices=["hifiasm", "hifiasm_hic", "flye", "canu", "lja", "verkko", "verkko_hic", "nextdenovo"], default="hifiasm")
    parser.add_argument('-f','--fastq', help="path to HiFi reads in fastq-format", default=None)
    parser.add_argument('-1','--forward_hic_read', help="path to forward hic read", default=None)
    parser.add_argument('-2','--reverse_hic_read', help="path to reverse hic read", default=None)
    parser.add_argument('-g','--genome_size', help='genome size, e.g. 3.7m or 2.8g (required for canu and nextdenovo run)', default=None)
    
    # qc options
    parser.add_argument('--assembly', help="run qc/coverage only on completed assembly", default=False)    
    parser.add_argument('-b','--busco_lineage', help="path to busco lineage database folder", default=None)
    parser.add_argument('-k', help='k value for k-mer analysis', default=23)
    parser.add_argument('-m', "--meryl_db", help='path to meryl reads db for QV* analysis (should be with same K value as -k!)', default=None)
    parser.add_argument('-c', '--coverage', help="additionally perform read alignment and coverage counting for assembly", default=False, action='store_true')
    parser.add_argument('-sv', '--sv_analysis', help="additionally perform read alignment and sv analyisis with sniffles", default=False, action='store_true')

    # scaffolding options
    parser.add_argument('--scaffold', help="scaffold with RagTag (reference is required)", default=False, action='store_true')
    parser.add_argument('-r', '--reference', help="reference genome for scaffolding of draft assembly", default=False)
    
    ## run parameters
    parser.add_argument('-o','--outdir', help='output directory', required=True)
    parser.add_argument('-t','--threads', help='number of threads [default == 8]', default = "8")
    parser.add_argument('-p', '--prefix', help='Run prefix [default == reads prefix]', default=None)
    parser.add_argument('-d','--debug', help='debug mode', action='store_true')
    
    ## TODO
    # SV search bam
    # polishing tool
    # polishing rounds
    # filter polishing vcf with merfin
    # parser.add_argument('--bam', help="path to HiFi reads in BAM format", default="")
    # parser.add_argument('-m','--merge_haplotips', help='Merge haplotips of resulting assembly', action='store_true')
    # parser.add_argument('--merge_haplotips_tool', help='Tool to merge haplotips [default == purgedups]', choices=['purgedups'], default='purgedups')


    args = vars(parser.parse_args())

    # run params
    threads = args["threads"]
    debug = args["debug"]
    outdir = os.path.abspath(args["outdir"])
    prefix = args["prefix"]     
    
    # assembly options
    assembler = args["assembler"]
    fastq = check_input(args["fastq"]) if args["fastq"] else None
    forward_hic_read = check_input(args["forward_hic_read"]) if args["forward_hic_read"] else None
    reverse_hic_read = check_input(args["reverse_hic_read"]) if args["reverse_hic_read"] else None
    genome_size = args["genome_size"]
    
    # qc options
    assembly = check_input(args["assembly"]) if args['assembly'] else None
    busco_lineage = check_input(args["busco_lineage"]) if args["busco_lineage"] else None
    coverage = args["coverage"]
    k = args['k']
    meryl_db = check_input(args["meryl_db"]) if args['meryl_db'] else None
    sv = args['sv_analysis']
    
    # scaffolding options
    reference = check_input[args["reference"]] if args['reference'] else None
    scaffold = args['scaffold']

        
    if not prefix:
        prefix_file = assembly or fastq
        prefix = os.path.splitext(os.path.split(prefix_file)[-1])[0]
    
    ## check if reads available for coverage check
    if not assembly:
        assert(fastq), "Reads in FASTQ format are required"
    else:
        if coverage:
            assert(fastq), "Reads in FASTQ format are required for building coverage"
        
    
    if assembler in ["hifiasm_hic", "verkko_hic"]:
        if not (forward_hic_read or reverse_hic_read):
            parser.error("\nhifiasm_hic and verkko_hic mode requires -1 {path_to_forward_read} and -2 {path_to_reverse_read}!")
    elif assembler in  ["canu", "nextdenovo"] and not genome_size:
            parser.error("\ncanu and nextdenovo mode requires genome size! E.g. -g 2.8m or -g 3.5g :)")
    if (forward_hic_read or reverse_hic_read) and assembler not in ["hifiasm_hic", "verkko_hic"]:
         parser.error("\nONLY hifiasm_hic and verkko modes requires -1 {path_to_forward_read} and -2 {path_to_reverse_read}! Please change run mode!")
    
    if scaffold and not reference:
        assert(reference), 'Reference fasta required to scaffold draft genome'    
        
    execution_folder = os.path.dirname(os.path.abspath(getsourcefile(lambda: 0)))
    execution_time = datetime.now().strftime("%d_%m_%Y_%H_%M_%S")
    config_file = os.path.join(execution_folder, f"config/config_{execution_time}.yaml")
    os.chdir(execution_folder)
            
    settings = {
        "outdir" : outdir,
        "threads" : threads,
        "execution_folder" : execution_folder,
        "debug" : debug,
        "config_file" : config_file,
        "prefix": prefix,
        
        "assembler" : assembler,
        "fr" : forward_hic_read, 
        "rr" : reverse_hic_read,
        "fastq": fastq,
        "genome_size": genome_size,
        
        "busco_lineage" : busco_lineage,
        "coverage": coverage,
        "assembly": assembly,
        "k" : k,
        "meryl_db": meryl_db,
        "sv" : sv,
        
        "reference": reference,
        "scaffold": scaffold,
    }
    
    config_maker(settings, config_file)
    main(settings)
