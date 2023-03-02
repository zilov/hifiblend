rule busco:
    input:
        ASSEMBLY
    conda:
        envs.busco
    threads: workflow.cores
    output:
        f"{OUTDIR}/busco/{PREFIX}_specific.txt"
    params:
        lineage = BUSCO_LINEAGE,
        outdir = OUTDIR,
        specific_busco = f"{OUTDIR}/busco/short_summary.specific*.txt"
    shell:
       """
       cd {params.outdir}
       
       busco \
             --offline \
             -l {params.lineage} \
             -i {input} \
             -o busco \
             -m genome \
             -f \
             -c {threads}
             
        cp {params.specific_busco} {output}
             """  
