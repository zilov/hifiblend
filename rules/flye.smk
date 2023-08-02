rule flye:
    input: 
        READS
    conda: envs.flye
    threads: workflow.cores
    output: 
        assembly = f"{OUTDIR}/flye/assembly.fasta"
    params: 
        outdir = directory(f"{OUTDIR}/flye"),
    shell: "flye --out-dir {params.outdir} -t {threads} --pacbio-hifi {input} --keep-haplotypes"