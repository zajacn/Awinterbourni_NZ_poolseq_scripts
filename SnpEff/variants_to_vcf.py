#!/usr/bin/env python3
"""
Convert tab-delimited variant file to VCF format
Input format: Chromosome Position RefAllele AltAllele
"""

import sys
import argparse

def variants_to_vcf(variants_file, output_vcf, reference_fasta=None):
    """Convert tab-delimited variants to VCF format"""
    
    # Read reference genome if provided (to get chromosome lengths)
    seq_lengths = {}
    if reference_fasta:
        print(f"Reading reference genome from {reference_fasta}...", file=sys.stderr)
        current_chr = None
        current_len = 0
        
        with open(reference_fasta, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith('>'):
                    if current_chr:
                        seq_lengths[current_chr] = current_len
                    current_chr = line[1:].split()[0]
                    current_len = 0
                else:
                    current_len += len(line)
            if current_chr:
                seq_lengths[current_chr] = current_len
        
        print(f"Found {len(seq_lengths)} sequence(s)", file=sys.stderr)
        for chr_name, length in seq_lengths.items():
            print(f"  {chr_name}: {length} bp", file=sys.stderr)
    
    # Read variants and collect chromosome info
    variants = []
    chromosomes = set()
    
    print(f"Reading variants from {variants_file}...", file=sys.stderr)
    with open(variants_file, 'r') as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            
            # Skip header line
            if line_num == 1 and ('Chromosome' in line or 'Position' in line):
                print(f"Skipping header line: {line}", file=sys.stderr)
                continue
            
            fields = line.split('\t')
            if len(fields) < 4:
                print(f"Warning: Line {line_num} has fewer than 4 columns, skipping", file=sys.stderr)
                continue
            
            chrom = fields[0]
            try:
                pos = int(fields[1])
            except ValueError:
                print(f"Warning: Line {line_num} has invalid position '{fields[1]}', skipping", file=sys.stderr)
                continue
            
            ref = fields[2].upper()
            alt = fields[3].upper()
            
            # Validate nucleotides
            valid_bases = set('ATGCN')
            if not all(b in valid_bases for b in ref):
                print(f"Warning: Line {line_num} has invalid reference allele '{ref}', skipping", file=sys.stderr)
                continue
            if not all(b in valid_bases for b in alt):
                print(f"Warning: Line {line_num} has invalid alternate allele '{alt}', skipping", file=sys.stderr)
                continue
            
            chromosomes.add(chrom)
            variants.append((chrom, pos, ref, alt, line_num))
    
    print(f"Read {len(variants)} variants from {len(chromosomes)} chromosome(s)", file=sys.stderr)
    
    # Write VCF
    print(f"Writing VCF to {output_vcf}...", file=sys.stderr)
    with open(output_vcf, 'w') as out:
        # Write header
        out.write("##fileformat=VCFv4.2\n")
        if reference_fasta:
            out.write(f"##reference=file://{reference_fasta}\n")
        
        # Write contig lines
        for chrom in sorted(chromosomes):
            if chrom in seq_lengths:
                out.write(f"##contig=<ID={chrom},length={seq_lengths[chrom]}>\n")
            else:
                out.write(f"##contig=<ID={chrom}>\n")
        
        # Write INFO and FORMAT headers
        out.write("##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Total Depth\">\n")
        out.write("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">\n")
        
        # Write column header
        out.write("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tSAMPLE\n")
        
        # Write variants
        for chrom, pos, ref, alt, line_num in variants:
            variant_id = f"var_{line_num}"
            out.write(f"{chrom}\t{pos}\t{variant_id}\t{ref}\t{alt}\t.\tPASS\t.\tGT\t1/1\n")
    
    print(f"\n✓ Successfully wrote {len(variants)} variants to {output_vcf}", file=sys.stderr)
    print(f"\nYou can now run SnpEff:", file=sys.stderr)
    print(f"  java -Xmx4g -jar snpEff.jar ann -v ASM1340708v1_Mito {output_vcf} > annotated.vcf", file=sys.stderr)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Convert tab-delimited variant file to VCF format',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Input file format (tab-delimited with header):
  Chromosome      Position        RefAllele       AltAllele
  Consensus_mic_mito      251     A       T
  Consensus_mic_mito      401     A       T

Example usage:
  python variants_to_vcf.py variants.txt output.vcf
  python variants_to_vcf.py variants.txt output.vcf -r reference.fasta
        '''
    )
    
    parser.add_argument('variants', help='Input tab-delimited variant file')
    parser.add_argument('output', help='Output VCF file')
    parser.add_argument('-r', '--reference', help='Optional reference FASTA file (for chromosome lengths)')
    
    args = parser.parse_args()
    
    variants_to_vcf(args.variants, args.output, args.reference)
