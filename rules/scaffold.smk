rule correct:
    input: 
        reads = READS,
        assembly = ASSEMBLY,
        reference = REFERENCE
    conda: envs.ragtag
    threads: workflow.cores
    output: 
        corrected_assembly = f"{OUTDIR}/ragtag/{PREFIX}_corrected.fasta"
    params: 
        outdir = f"{OUTDIR}/ragtag",
    shell: "ragtag.py correct -R {input.reads} {input.reference} {input.assembly} -o"

rule scaffold:
    input: 
        reads = READS,
        assembly = ASSEMBLY,
        reference = REFERENCE
    conda: envs.ragtag
    threads: workflow.cores
    output: 
        corrected_assembly = f"{OUTDIR}/ragtag/{PREFIX}_corrected.fasta"
    params: 
        outdir = f"{OUTDIR}/ragtag",
    shell: "ragtag.py correct -R {input.reads} {input.reference} {input.assembly} -o"