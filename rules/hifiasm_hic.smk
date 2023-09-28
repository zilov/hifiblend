rule hifiasm_hic:
    input: 
        hifi_reads = READS,
        hic_forward = HIC_FR,
        hic_reverse = HIC_RR
    conda: envs.hifiasm
    threads: workflow.cores
    output: 
        assembly_gfa = f"{OUTDIR}/hifiasm/{PREFIX}.bp.p_ctg.gfa"
    params: 
        prefix = f"{OUTDIR}/hifiasm/{PREFIX}",
    shell: "hifiasm -o {params.prefix} --h1 {input.hic_forward} --h2 {input.hic_reverse} {input} -t {threads}"

rule gfa_to_fa:
    input: 
        gfa = rules.hifiasm_hic.output.assembly_gfa
    conda: envs.gfatools
    output:
        assembly_fa = f"{OUTDIR}/hifiasm/{PREFIX}.bp.p_ctg.fa"
    shell: 'gfatools gfa2fa {input.gfa} > {output.assembly_fa}'
