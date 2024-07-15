rule meryl_histo:
    input: 
        MERYL_DB
    conda: envs.merfin
    threads: workflow.cores
    output: 
        meryl_histo = f"{OUTDIR}/meryl/{PREFIX}_{K}_meryl.histo"
    shell: "meryl histogram {input} > {output.meryl_histo}"

rule meryl_build_assembly_db:
    input: 
        ASSEMBLY
    conda: envs.merfin
    threads: workflow.cores
    output: 
        meryl_db_index = f"{OUTDIR}/meryl/{PREFIX}_assembly_meryl/merylIndex",
        meryl_db_folder = directory(f"{OUTDIR}/meryl/{PREFIX}_assembly_meryl")
    params: 
        k = K
    shell: "meryl count k={params.k} {input} output {output.meryl_db_folder}"
