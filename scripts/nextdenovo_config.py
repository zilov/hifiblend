def generate_nextdenovo_config(reads_path, genome_size, threads, prefix, outdir, output_config):
    config_content = f"""
[General]
job_type = local
job_prefix = {prefix}
task = assemble
rewrite = yes
deltmp = yes
parallel_jobs = {threads}
input_type = corrected
read_type = hifi
input_fofn = {reads_path}
workdir = {outdir}

[correct_option]
read_cutoff = 1k
genome_size = {genome_size} # estimated genome size
sort_options = -m 20g -t 15
minimap2_options_raw = -t 8
pa_correction = 3
correction_options = -p 15

[assemble_option]
minimap2_options_cns = -t 8
nextgraph_options = -a 1
"""
    with open(output_config, "w") as f:
        f.write(config_content)
