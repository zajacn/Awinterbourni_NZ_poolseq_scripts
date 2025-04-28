#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --time=3-00:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --job-name=grenedalf

##########################################
echo "Natalia Zajac, GDC, 04/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
module load grendalf/0.5.1

FASTA=/cluster/work/gdc/people/zajacn/Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Sequence/WholeGenomeFasta/genome.fa
NEWDIR=/cluster/scratch/zajacn
BED=/cluster/work/gdc/people/zajacn/Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Annotation/Genes/scaffolds_with_genes_noMT.bed
sequence=$1

#Convert bam file to sync simultanenous all files
sed -n $sequence $BED | while read -r line;
do
	CHROM=$(echo $line | awk '{print $1}')
       	echo $CHROM
	grenedalf sync --sam-path ${NEWDIR}/Sorted_Bams/*.sorted.dedup.filtered.bam \
		--sam-min-map-qual 20 \
		--sam-min-base-qual 20 \
		--reference-genome-fasta-file $FASTA \
		--threads 1 \
		--filter-region $CHROM \
		--file-prefix all_samples.$CHROM \
		--out-dir ${NEWDIR}/SYNC/;
done

