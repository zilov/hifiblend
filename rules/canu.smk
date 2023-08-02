rule canu:
    input: 
        reads = READS
    conda: envs.canu
    threads: workflow.cores
    output: 
        assembly = f"{OUTDIR}/canu/{PREFIX}.contigs.fasta"
    params: 
        outdir = directory(f"{OUTDIR}/canu"),
        tmp_files = f"{OUTDIR}/canu/tmp",
        prefix = PREFIX,
        genome_size = GENOME_SIZE,
    shell: """
    canu -p {params.prefix} -d {params.outdir} genomeSize={params.genome_size} useGrid=false -pacbio-hifi {input.reads} correctedErrorRate=0.005 minOverlapLength=2500 minReadLength=2500
    """