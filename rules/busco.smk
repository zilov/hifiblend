rule busco:
    input:
        anno_faa = rules.braker.output.braker_out_aa
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
             -i {input.anno_faa} \
             -o busco \
             -m prot \
             -f \
             -c {threads}
             
        cp {params.specific_busco} {output}
             """  
