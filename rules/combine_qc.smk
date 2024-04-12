import os

rule combine_qc:
    input: 
        busco_results_file = rules.busco.output.specific_txt if BUSCO_LINEAGE else [],
        quast_results = rules.quast.output.quast_output,
        merfin_hist = rules.extract_merfin_hist_results.output.hist_results,
        merfin_completeness = rules.extract_merfin_completeness.output.completeness_results,
        merfin_hist_lookup = rules.extract_merfin_hist_lookup_results.output.hist_results,
        merfin_completeness_lookup = rules.extract_merfin_completeness_lookup.output.completeness_results,
        slizer_summary = rules.slizer.output.slizer_summary if COVERAGE else [],
        sniffles_summary = rules.parse_sniffles.output.sniffles_summary if SV else [],
    output: 
        qc_results = f"{OUTDIR}/{PREFIX}_final_qc.tsv"
    run: 
        with open(output.qc_results, 'w') as fw:
            headers = ["QUAST", "MERFIN HIST", "MERFIN COMPLETENESS", "MERFIN HIST LOOKUP", "MERFIN COMPLETENESS LOOKUP", "SLIZER COVERAGE", "SNIFFLES SV"]
            for i, file in enumerate([input.quast_results, input.merfin_hist, input.merfin_completeness, input.merfin_hist_lookup, input.merfin_completeness_lookup, input.slizer_summary, input.sniffles_summary]):
                if isinstance(file, str):
                    with open(file) as fh:
                        fw.write(f"** {headers[i]} **\t\n")
                        for line in fh:
                            fw.write(line)
            if input.busco_results_file:
                with open(input.busco_results_file, 'r') as busco_file:
                    fw.write(f"** BUSCO **\t\n")
                    for line in busco_file:
                        if '***** Results: *****' in line:
                            busco_file.readline()
                            busco = busco_file.readline().strip()
                            fw.write(f"BUSCO results\t{busco}\n") 