from Bio import SeqIO
import re

def fasta_to_oneliner(fasta_file, oneliner_fasta_file):
    with open(fasta_file, "r") as fasta_handle, open(oneliner_fasta_file, "w") as oneliner_handle:
        for record in SeqIO.parse(fasta_handle, "fasta"):
            oneliner_handle.write(f">{record.id}\n{str(record.seq)}\n")

def soft_masked_regions_to_bed(oneliner_fasta_file, bed_file):
    with open(oneliner_fasta_file, "r") as fasta_handle, open(bed_file, "w") as bed_handle:
        for record in SeqIO.parse(fasta_handle, "fasta"):
            sequence = str(record.seq)
            chrom = record.id
            for match in re.finditer(r'[a-z]+', sequence):
                start = match.start()
                end = match.end()
                bed_handle.write(f"{chrom}\t{start}\t{end}\n")

# Paths to your files
fasta_file = "/cluster/work/gdc/people/zajacn/Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Sequence/WholeGenomeFasta/genome.fa"
oneliner_fasta_file = "/cluster/scratch/zajacn/reference_genome_oneliner.fasta"
bed_file = "/cluster/work/gdc/people/zajacn/Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Sequence/WholeGenomeFasta/soft_masked_regions.bed"

# Convert FASTA to one-liner format
fasta_to_oneliner(fasta_file, oneliner_fasta_file)

# Extract soft-masked regions to BED file
soft_masked_regions_to_bed(oneliner_fasta_file, bed_file)
