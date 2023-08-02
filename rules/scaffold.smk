rule correct:
    input: 
        reads = READS,
        assembly = ASSEMBLY,
        reference = REFERENCE
    conda: envs.ragtag
    threads: workflow.cores
    output: 
        corrected_assembly = f"{OUTDIR}/ragtag/ragtag.correct.fasta"
    params: 
        outdir = f"{OUTDIR}/ragtag",
    shell: "ragtag.py correct {input.reference} {input.assembly} -o {params.outdir} -t {threads} -b 50000"

rule scaffold:
    input: 
        corrected_assembly = rules.correct.output.corrected_assembly,
        reference = REFERENCE
    conda: envs.ragtag
    threads: workflow.cores
    output: 
        corrected_assembly = f"{OUTDIR}/ragtag/ragtag.scaffold.fasta"
    params: 
        outdir = f"{OUTDIR}/ragtag",
    shell: "ragtag.py scaffold {input.reference} {input.corrected_assembly} -o {params.outdir} -t {threads}"