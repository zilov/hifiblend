rule verkko_hic:
    input: 
        reads = READS,
        hic_forward = HIC_FR,
        hic_reverse = HIC_RR
    conda: envs.verkko
    threads: workflow.cores
    output: 
        assembly = f"{OUTDIR}/verkko/assembly.fasta"
    params: 
        outdir = directory(f"{OUTDIR}/verkko"),
        tmp_files = f"{OUTDIR}/verkko/tmp",
        prefix = PREFIX
    shell: """
    verkko -d {params.outdir} --hifi {input.reads} --hic1 {input.hic_forward} --hic2 {input.hic_reverse} --snakeopts "--cores {threads}" 
    """