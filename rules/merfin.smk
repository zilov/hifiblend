rule merfin_hist_lookup:
    input: 
        assembly = ASSEMBLY,
        kmercov = rules.extract_kmercov.output.kmercov_value,
        lookup = rules.genomescope.output.genomescope_lookup,
        meryl_db = MERYL_DB
    conda: envs.merfin
    threads: workflow.cores
    output: 
        hist_file = f"{OUTDIR}/merfin/{PREFIX}_hist_lookup.txt",
        hist_log = f"{OUTDIR}/merfin/{PREFIX}_hist_lookup.log"
    shell: """
        peak_values=$(cat {input.kmercov})
        merfin -hist \
               -sequence {input.assembly} \
               -readmers {input.meryl_db} \
               -output {output.hist_file} \
               -prob {input.lookup} \
               -peak $peak_values 2> {output.hist_log}
    """

rule extract_merfin_hist_lookup_results:
    input:
        merfin_output = rules.merfin_hist_lookup.output.hist_log
    output:
        hist_results = f"{OUTDIR}/merfin/{PREFIX}_hist_lookup_results.tsv"
    run:
        # Define a dictionary to hold the values to extract
        results = {
            "K-mers not found in reads (missing)": None,
            "K-mers overly represented in assembly": None,
            "K-mers found in the assembly": None,
            "Missing QV": None,
            "Merfin QV*": None
        }

        # Open and read the Merfin output file
        with open(input.merfin_output, 'r') as infile:
            for line in infile:
                for key in results.keys():
                    if line.startswith(key):
                        # Extract the value after the colon and strip whitespace
                        results[key] = line.split(":")[1].strip()

        # Write the extracted values to the output TSV file
        with open(output.hist_results, 'w') as outfile:
            # Write the headers
            outfile.write("Metric\tValue\n")
            # Write the results
            for key, value in results.items():
                outfile.write(f"{key}\t{value}\n")


rule merfin_completeness_lookup:
    input: 
        assembly = ASSEMBLY,
        kmercov = rules.extract_kmercov.output.kmercov_value,
        lookup = rules.genomescope.output.genomescope_lookup,
        meryl_assembly_db = MERYL_DB
    conda: envs.merfin
    threads: workflow.cores
    output: 
        completeness_log = f"{OUTDIR}/merfin/{PREFIX}_completeness_lookup.log"
    shell: """
        peak_values=$(cat {input.kmercov})
        merfin -completeness \
               -sequence {input.assembly} \
               -readmers {input.meryl_assembly_db} \
               -prob {input.lookup} \
               -peak $peak_values 2> {output.completeness_log}
    """

rule extract_merfin_completeness_lookup:
    input:
        merfin_output = rules.merfin_completeness_lookup.output.completeness_log
    output:
        completeness_results = f"{OUTDIR}/merfin/{PREFIX}_completeness_lookup_results.tsv"
    run:
        # Define a dictionary to hold the values to extract
        results = {
            "TOTAL readK": None,
            "TOTAL undrcpy": None,
            "COMPLETENESS": None,
        }

        # Open and read the Merfin output file
        with open(input.merfin_output, 'r') as infile:
            for line in infile:
                for key in results.keys():
                    if line.startswith(key):
                        # Extract the value after the colon and strip whitespace
                        results[key] = line.split(":")[1].strip()

        # Write the extracted values to the output TSV file
        with open(output.completeness_results, 'w') as outfile:
            # Write the headers
            outfile.write("Metric\tValue\n")
            # Write the results
            for key, value in results.items():
                outfile.write(f"{key}\t{value}\n")


rule merfin_hist:
    input: 
        assembly = ASSEMBLY,
        kmercov = rules.extract_kmercov.output.kmercov_value,
        lookup = rules.genomescope.output.genomescope_lookup,
        meryl_db = MERYL_DB
    conda: envs.merfin
    threads: workflow.cores
    output: 
        hist_file = f"{OUTDIR}/merfin/{PREFIX}_hist.txt",
        hist_log = f"{OUTDIR}/merfin/{PREFIX}_hist.log"
    shell: """
        peak_values=$(cat {input.kmercov})
        merfin -hist \
               -sequence {input.assembly} \
               -readmers {input.meryl_db} \
               -output {output.hist_file} \
               -peak $peak_values 2> {output.hist_log}
    """

rule extract_merfin_hist_results:
    input:
        merfin_output = rules.merfin_hist.output.hist_log
    output:
        hist_results = f"{OUTDIR}/merfin/{PREFIX}_hist_results.tsv"
    run:
        # Define a dictionary to hold the values to extract
        results = {
            "K-mers not found in reads (missing)": None,
            "K-mers overly represented in assembly": None,
            "K-mers found in the assembly": None,
            "Missing QV": None,
            "Merfin QV*": None
        }

        # Open and read the Merfin output file
        with open(input.merfin_output, 'r') as infile:
            for line in infile:
                for key in results.keys():
                    if line.startswith(key):
                        # Extract the value after the colon and strip whitespace
                        results[key] = line.split(":")[1].strip()

        # Write the extracted values to the output TSV file
        with open(output.hist_results, 'w') as outfile:
            # Write the headers
            outfile.write("Metric\tValue\n")
            # Write the results
            for key, value in results.items():
                outfile.write(f"{key}\t{value}\n")


rule merfin_completeness:
    input: 
        assembly = ASSEMBLY,
        kmercov = rules.extract_kmercov.output.kmercov_value,
        lookup = rules.genomescope.output.genomescope_lookup,
        meryl_assembly_db = MERYL_DB
    conda: envs.merfin
    threads: workflow.cores
    output: 
        completeness_log = f"{OUTDIR}/merfin/{PREFIX}_completeness.log"
    shell: """
        peak_values=$(cat {input.kmercov})
        merfin -completeness \
               -sequence {input.assembly} \
               -readmers {input.meryl_assembly_db} \
               -peak $peak_values 2> {output.completeness_log}
    """

rule extract_merfin_completeness:
    input:
        merfin_output = rules.merfin_completeness.output.completeness_log
    output:
        completeness_results = f"{OUTDIR}/merfin/{PREFIX}_completeness_results.tsv"
    run:
        # Define a dictionary to hold the values to extract
        results = {
            "TOTAL readK": None,
            "TOTAL undrcpy": None,
            "COMPLETENESS": None,
        }

        # Open and read the Merfin output file
        with open(input.merfin_output, 'r') as infile:
            for line in infile:
                for key in results.keys():
                    if line.startswith(key):
                        # Extract the value after the colon and strip whitespace
                        results[key] = line.split(":")[1].strip()

        # Write the extracted values to the output TSV file
        with open(output.completeness_results, 'w') as outfile:
            # Write the headers
            outfile.write("Metric\tValue\n")
            # Write the results
            for key, value in results.items():
                outfile.write(f"{key}\t{value}\n")