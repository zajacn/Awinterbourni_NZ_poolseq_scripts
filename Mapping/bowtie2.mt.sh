#!/bin/bash
#SBATCH --array=7,8,10,11,12
#SBATCH --cpus-per-task=3
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=500M
#SBATCH --job-name=bowtie2
#SBATCH --output=bowtie2_%a.log

##########################################
echo "Natalia Zajac, GDC, 04/07/24"
echo "$(date) start ${SLURM_JOB_ID}"
##########################################

source /cluster/project/gdc/shared/stack/GDCstack.sh
module load stack/.2024-03-beta-silent  gcc/13.2.0-i6mrihr
module load bowtie2/2.5.1-3zsz7pi
module load samtools/1.20
module load sambamba/1.0.1
module load picard/3.1.1

k=$SLURM_ARRAY_TASK_ID
name=`sed -n ${k}p < /cluster/scratch/zajacn/list_of_samples`

NEWDIR=/cluster/scratch/zajacn
MITOREF=/cluster/work/gdc/people/zajacn/Mitochondrial/Mitos2/Bowtie2_Index/consensus_mic_mito

#bowtie2 --no-unal -p 3 --rg-id ${name} --rg SM:${name} --rg LB:RGLB_${name} --rg PL:illumina --rg PU:RGPU_3${name} -x $MITOREF -1 $NEWDIR/Fastq/${name}_filtered_R1.fastq.gz -2 $NEWDIR/Fastq/${name}_filtered_R2.fastq.gz 2> $NEWDIR/Mito_SYNC/${name}_bowtie2.mito.log | samtools view -S -b -  > $NEWDIR/Mito_SYNC/${name}.mito.bam
samtools sort -l 9 -m 8750M -@ 5 $NEWDIR/Mito_SYNC/${name}.mito.bam -o $NEWDIR/Mito_SYNC/${name}.mito.sorted.bam
samtools index $NEWDIR/Mito_SYNC/${name}.mito.sorted.bam
sambamba markdup -r -t 5  $NEWDIR/Mito_SYNC/${name}.mito.sorted.bam $NEWDIR/Mito_SYNC/${name}.mito.sorted.dedup.bam --overflow-list-size 600000
