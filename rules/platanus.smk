rule platanus_assembly:
    input: 
        reads = READS,
    conda: envs.platanus
    threads: workflow.cores
    output: 
        assembly_draft = f"{OUTDIR}/platanus/out_contig.fa",
        kmers = f"{OUTDIR}/platanus/out_junctionKmer.fa"
    params: 
        outdir = directory(f"{OUTDIR}/platanus"),
        tmpdir = directory(f"{OUTDIR}/platanus/tmp"),
        platanus = local.platanus
    shell: "cd {params.outdir} && {params.platanus} assemble -f {input.reads} -m 100 -s 250 -K 0.1 -t {threads} 2>assembly.log"

rule platanus_phase:
    input: 
        assembly = rules.platanus_assembly.output.assembly_draft,
        kmers = rules.platanus_assembly.output.kmers,
        reads = READS
    conda: envs.platanus
    threads: workflow.cores
    output: 
        bubbles = f"{OUTDIR}/platanus/out_primaryBubble.fa",
        candidates = f"{OUTDIR}/platanus/out_nonBubbleHomoCandidate.fa"
    params: 
        outdir = directory(f"{OUTDIR}/platanus"),
        tmpdir = directory(f"{OUTDIR}/platanus/tmp"),
        platanus = local.platanus
    shell: "cd {params.outdir} && {params.platanus} phase -c {input.assembly} {input.kmers} -p {input.reads} -m 100 -t {threads} 2>phase.log"

rule platanus_consensus:
    input:
        bubbles = rules.platanus_phase.output.bubbles,
        candidates = rules.platanus_phase.output.candidates,
        reads = READS
    conda: envs.platanus
    threads: workflow.cores
    output: 
        assembly = f"{OUTDIR}/platanus/out_consensusScaffolds.fa"
    params: 
        outdir = directory(f"{OUTDIR}/platanus"),
        tmpdir = directory(f"{OUTDIR}/platanus/tmp"),
        platanus = local.platanus
    shell: "cd {params.outdir} && {params.platanus} consensus -c {input.bubbles} {input.candidates} -p {input.reads} -m 100 -t {threads} 2>consensus.log"