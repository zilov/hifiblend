rule minimap2_align:
    input: 
        reads = FASTQ,
        assembly = ASSEMBLY
    conda: envs.minimap2
    threads: workflow.cores
    output: 
        bam_sorted = f"{OUTDIR}/minimap2/{PREFIX}_sorted.bam",
    shell: "minimap2 -ax map-hifi -t {threads} {input.assembly} {input.reads} | samtools view -Sb | samtools sort - > {output.bam_sorted}"

rule index_bam:
    input: 
        bam = rules.minimap2_align.output.bam_sorted
    conda: envs.minimap2
    threads: workflow.cores
    output: 
        bam_index = f"{OUTDIR}/minimap2/{PREFIX}_sorted.bam.bai",
    shell: "samtools index {input.bam}"
