rule verkko:
    input: 
        reads = READS
    conda: envs.verkko
    threads: workflow.cores
    output: 
        assembly = f"{OUTDIR}/verkko/assembly.fasta"
    params: 
        outdir = directory(f"{OUTDIR}/verkko")
    shell: """
    verkko -d {params.outdir} --hifi {input.reads} --snakeopts "--cores {threads}" 
    """