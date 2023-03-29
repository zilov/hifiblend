rule align:
    input:
        assembly = ASSEMBLY,
        reads = READS
    conda: envs.coverage
    threads: workflow.cores
    output: 
        alignment = f"{OUTDIR}/alignment/{PREFIX}_sorted.bam",
        alignment_stats = f"{OUTDIR}/alignment/{PREFIX}_sorted.stats"
    params: 
        outdir = directory(f"{OUTDIR}/alignment"),
    shell: """
    minimap2 -ax map-hifi {input.assembly} {input.reads} -t {threads} \
    | samtools view -b -u - \
    | samtools sort -@ {threads} -T tmp > {output.alignment} \
    && samtools flagstat {output.alignment} > {output.alignment_stats}
    """

rule count_coverage:
    input:
        alignment = rules.align.output.alignment
    conda: envs.coverage
    threads: workflow.cores
    output: 
        coverage = f"{OUTDIR}/alignment/{PREFIX}_coverage.bed"
    shell: """
    bedtools genomecov -bga -split -ibam {input.alignment} > {output.coverage}
    """