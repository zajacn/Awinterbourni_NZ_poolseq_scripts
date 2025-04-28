#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --array=6-174%30
#SBATCH --time=3-00:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --job-name=grenedalf_loop

k=$SLURM_ARRAY_TASK_ID
name=`sed -n ${k}p < /cluster/scratch/zajacn/all_jobs.txt`

echo $name
bash ${name}
