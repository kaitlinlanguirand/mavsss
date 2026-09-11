#!/bin/bash

# arg1: subdirectory with Nexus files
subdir=$1

module load gnu/12
module load R/4.4.2

export R_LIBS_USER=/home/dcerny/R_libs

cd /home/dcerny/mavsss/datasets/$subdir

find . -name "*.clean" -print0 | while IFS= read -r -d '' file
do
    Rscript ../../runners/generate_palmuc_sbatch.R -s "$subdir" -d "$file"
done