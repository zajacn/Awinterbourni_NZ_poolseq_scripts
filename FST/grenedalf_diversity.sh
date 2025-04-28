#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=3G
#SBATCH --job-name=grenedalf

#########################################
echo "Natalia Zajac, GDC, 31/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
module load grendalf/0.5.1

NEWDIR=/cluster/scratch/zajacn
FASTA=/cluster/work/gdc/people/zajacn/Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Sequence/WholeGenomeFasta/genome.fa

grenedalf diversity --sync-path $NEWDIR/SYNC/combined.filtered.nomasked.sync \
	--window-type queue \
	--window-average-policy available-loci \
	--tajima-d-denominator-policy empirical-min-read-depth \
	--pool-sizes 24 \
	--reference-genome-fai-file $NEWDIR/SYNC/genome.fa.sync.sorted.fai \
	--window-queue-count 50 \
	--window-queue-stride 0 \
	--filter-sample-min-count 2 \
	--filter-sample-min-read-depth 4 \
	--out-dir $NEWDIR/FST \
	--file-prefix Queue.50SNPs.Diversity \
	--rename-samples-file $NEWDIR/SYNC/sample_names.lst \
	--threads 2
#Genewise
grenedalf diversity --sync-path ../SYNC/combined.filtered.nomasked.sync --window-type regions --window-average-policy window-length --pool-sizes 24 --window-region-gff ../SYNC/grendalf_genes_noMT2.gtf --reference-genome-fai ../SYNC/genome.fa.sync.sorted.fai --tajima-d-denominator-policy empirical-min-read-depth --filter-sample-min-count 2 --filter-sample-min-read-depth 4 --out-dir ../FST/ --file-prefix Queue.Diversity.Genewise --rename-samples-list ../SYNC/sample_names.txt
