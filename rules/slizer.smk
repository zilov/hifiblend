rule slizer:
    input: 
        bam = rules.minimap2_align.output.bam_sorted,
        assembly = ASSEMBLY
    conda: envs.slizer
    threads: workflow.cores
    output: 
        slizer_summary = f"{OUTDIR}/slizer/{PREFIX}_final_statistics_report.tsv"
    params:
        prefix = PREFIX,
        outdir = directory(f"{OUTDIR}/slizer")
    shell: "./scripts/slizer/slizer.py -m bam --bam {input.bam} -a {input.assembly} -p {params.prefix} -o {params.outdir}"