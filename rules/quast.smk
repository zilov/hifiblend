rule quast:
    input:
        ASSEMBLY,
    conda:
        envs.quast,
    output:
        quast_output = "{OUTDIR}/quast/report.txt"
    params:
        directory("{OUTDIR}/quast")
    shell: "quast -o {params} {input}"