rule hifiasm:
    input: 
        READS
    conda: envs.hifiasm
    threads: workflow.cores
    output: 
        assembly = "{OUTDIR}/hifiasm/{PREFIX}.bp.p_ctg.fa"
    shell: 'hifiasm -o {output.assembly} -t 32 {input}'