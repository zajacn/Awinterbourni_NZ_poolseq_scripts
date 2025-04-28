#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
#SBATCH --job-name=grenedalf

#########################################
echo "Natalia Zajac, GDC, 31/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
module load grendalf/0.5.1

NEWDIR=/cluster/scratch/zajacn
FASTA=/cluster/work/gdc/people/zajacn/Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Sequence/WholeGenomeFasta/genome.fa

grenedalf fst --sync-path $NEWDIR/SYNC/combined.filtered.nomasked.sync \
	--window-type queue \
	--window-average-policy available-loci \
	--method unbiased-hudson \
	--write-pi-tables \
	--pool-sizes 24 \
	--reference-genome-fai-file $NEWDIR/SYNC/genome.fa.sync.sorted.fai \
	--window-queue-count 1 \
	--window-queue-stride 0 \
	--out-dir $NEWDIR/FST \
	--file-prefix Queue.1SNP.Hudson \
	--rename-samples-file $NEWDIR/SYNC/sample_names.lst \
	--threads 2

#       --filter-mask-bed $NEWDIR/SYNC/mask.for.fst.bed \
