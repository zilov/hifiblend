rule sniffles:
    input: 
        bam = rules.minimap2_align.output.bam_sorted,
        bam_index = rules.index_bam.output.bam_index,
    conda: envs.sniffles
    threads: workflow.cores
    output: 
        sniffles_vcf = f"{OUTDIR}/sniffles/{PREFIX}_sv.vcf" 
    shell: "sniffles -i {input.bam} -v {output.sniffles_vcf} --minsvlen 5000 -t {threads}"

rule parse_sniffles:
    input:
        sniffles_vcf = rules.sniffles.output.sniffles_vcf
    output: 
        sniffles_summary = f"{OUTDIR}/sniffles/{PREFIX}_sv_summaary.tsv" 
    run:
        with open(output.sniffles_summary, "w") as fw:
            # Initialize counters
            inversions = 0
            deletions = 0
            duplications = 0
            insertions = 0
            translocations = 0
            total_sv = 0

            # Read VCF file
            with open(input.sniffles_vcf) as vcf:
                for line in vcf:
                    if line.startswith('#'):
                        continue  # Skip header lines
                    fields = line.split('\t')
                    info_field = fields[7]
                    
                    # Check for variant types
                    if 'SVTYPE=INV' in info_field:
                        inversions += 1
                    elif 'SVTYPE=DEL' in info_field:
                        deletions += 1
                    elif 'SVTYPE=DUP' in info_field:
                        duplications += 1
                    elif 'SVTYPE=INS' in info_field:
                        insertions += 1
                    elif 'SVTYPE=BND' in info_field:
                        translocations += 1
            
            total_sv = inversions + insertions + duplications + translocations + deletions

            fw.write(f"Total SVs\t{total_sv}\n")
            fw.write(f"Inversions\t{inversions}\n")
            fw.write(f"Deletions\t{deletions}\n")
            fw.write(f"Duplications\t{duplications}\n")
            fw.write(f"Insertions\t{insertions}\n")
            fw.write(f"Translocations\t{translocations}\n")