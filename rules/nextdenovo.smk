import sys
sys.path.append("scripts")  # Add your relative path

from nextdenovo_config import generate_nextdenovo_config  # Import the function

rule generate_config:
    input:
        reads = READS
    output:
        nextdenovo_config = f"{OUTDIR}/nextdenovo/{PREFIX}_config.cfg"
    params:
        reads_fofn = f"{OUTDIR}/nextdenovo/reads.fofn",
        threads = THREADS,
        genome_size = GENOME_SIZE,
        outdir = directory(f"{OUTDIR}/nextdenovo"),
        prefix = PREFIX
    run:
        with open(params.reads_fofn, 'w') as fw:
            fw.write(READS + "\n")
        generate_nextdenovo_config(params.reads_fofn, params.genome_size, params.threads, params.prefix, params.outdir, output.nextdenovo_config)

rule nextdenovo:
    input: 
        nextdenovo_config = rules.generate_config.output.nextdenovo_config
    conda: envs.nextdenovo
    threads: workflow.cores
    output: 
        assembly = f"{OUTDIR}/nextdenovo/03.ctg_graph/nd.asm.fasta"
    params: 
        outdir = directory(f"{OUTDIR}/nextdenovo")
    shell: "nextDenovo {input.nextdenovo_config}"