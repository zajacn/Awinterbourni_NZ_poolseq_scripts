#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=120M
#SBATCH --job-name=grenedalf

#########################################
echo "Natalia Zajac, GDC, 31/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
module load grendalf/0.6.2

NEWDIR=/cluster/scratch/zajacn
FASTA=/cluster/work/gdc/people/zajacn/Atriophallophorus_winterbourni/EBI/GCA_013407085.1/Sequence/WholeGenomeFasta/genome.fa

grenedalf fst --sync-path $NEWDIR/SYNC/combined.filtered.nomasked.sync \
	--window-type regions \
	--window-average-policy window-length \
	--method unbiased-hudson \
	--pool-sizes 24 \
	--window-region-gff $NEWDIR/SYNC/grendalf_genes_noMT2.gtf \
	--reference-genome-fai $NEWDIR/SYNC/genome.fa.sync.sorted.fai \
	--out-dir $NEWDIR/FST \
	--file-prefix GenewiseFst.Hudson \
	--rename-samples-list $NEWDIR/SYNC/sample_names.txt \
	--threads 5
#gtf that contains only genes
#For mt
#grenedalf fst --sync-path ../Mito_SYNC/all_samples.mit.sync.filtered.sync --window-type regions --window-average-policy window-length --method unbiased-hudson --pool-sizes 12 --window-region-bed ../Mito_SYNC/mt.bed --reference-genome-fasta /cluster/work/gdc/people/zajacn/Mitochondrial/Mitos2/consensus_mic_mito.fasta --out-dir ../Mito_SYNC/ --file-prefix GenewiseFst.Hudson.mt  --allow-file-overwriting
#grenedalf fst --sync-path ../Mito_SYNC/all_samples.mit.sync.filtered.sync --window-type single --window-average-policy available-loci --method unbiased-hudson --pool-sizes 12 --reference-genome-fasta /cluster/work/gdc/people/zajacn/Mitochondrial/Mitos2/consensus_mic_mito.fasta --out-dir ../Mito_SYNC/ --file-prefix 1SNPFst.mt --allow-file-overwriting
