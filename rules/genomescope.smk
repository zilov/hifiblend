rule genomescope:
    input: 
        rules.meryl_histo.output.meryl_histo
    conda: envs.genomescope
    threads: workflow.cores
    output: 
        genomescope_plot = f"{OUTDIR}/genomescope/{PREFIX}_{K}_linear_plot.png",
        genomescope_model = f"{OUTDIR}/genomescope/{PREFIX}_{K}_model.txt",
        genomescope_lookup = f"{OUTDIR}/genomescope/lookup_table.txt",
    params: 
        k = K,
        prefix = f"{PREFIX}_{K}",
        genomescope_dir = directory(f"{OUTDIR}/genomescope"),
        genomescope_exe = f"{EXECUTION_FOLDER}/scripts/genomescope2.0/genomescope.R"
    shell: "{params.genomescope_exe} -i {input} -o {params.genomescope_dir} -k {params.k} -n {params.prefix} --fitted_hist"

rule extract_kmercov:
    input:
        genomescope_output = rules.genomescope.output.genomescope_model
    output:
        kmercov_value = f"{OUTDIR}/genomescope/{PREFIX}_{K}_kmercov.txt"
    run:
        with open(input.genomescope_output, 'r') as infile:
            estimate = False
            for line in infile:
                if "Estimate" in line:
                    estimate = True
                if "kmercov" in line and estimate:
                    kmercov_value = line.split()[1]
                    print(kmercov_value)
                    kmercov_int = int(float(kmercov_value))
                    with open(output.kmercov_value, 'w') as outfile:
                        outfile.write(f"{kmercov_int}\n")
                    break
