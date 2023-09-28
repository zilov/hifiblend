rule hifiasm:
    input: 
        READS
    conda: envs.hifiasm
    threads: workflow.cores
    output: 
        assembly_gfa = f"{OUTDIR}/hifiasm/{PREFIX}.bp.p_ctg.gfa"
    params: 
        prefix = f"{OUTDIR}/hifiasm/{PREFIX}",
    shell: "hifiasm -o {params.prefix} -t 32 {input}"

rule gfa_to_fa:
    input: 
        gfa = rules.hifiasm.output.assembly_gfa
    conda: envs.gfatools
    output:
        assembly_fa = f"{OUTDIR}/hifiasm/{PREFIX}.bp.p_ctg.fa"
    shell: 'gfatools gfa2fa {input.gfa} > {output.assembly_fa}'