rule meryl_build_db:
    input: 
        READS
    conda: envs.merfin
    threads: workflow.cores
    output: 
        meryl_db_index = f"{OUTDIR}/meryl/{PREFIX}_{K}_meryl/merylIndex",
        meryl_db_folder = directory(f"{OUTDIR}/meryl/{PREFIX}_{K}_meryl")
    params: 
        k = K
    shell: "meryl count k={params.k} {input} output {output.meryl_db_folder}"