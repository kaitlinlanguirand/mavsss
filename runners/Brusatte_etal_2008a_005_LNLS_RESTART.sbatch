#!/bin/bash

#SBATCH --job-name=Brusatte_etal_2008a_005_LNLS_RESTART
#SBATCH --output=Brusatte_etal_2008a_005_LNLS_RESTART_%a.out
#SBATCH --error=Brusatte_etal_2008a_005_LNLS_RESTART_%a.err
#SBATCH --array=0-20
#SBATCH --partition=lemmium
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=27-23:59:59   # maximum for normal-priority jobs

module load gnu/12
module load openmpi/4.1.6
module load boost/1.82.0

cd /home/dcerny/mavsss

array0=(96 100 92 52 44 46 38 26 40 32 36 20 28 24 34 18 12 14 22 6 2)
array1=(98500 95000 94000 93000 91000 87000 79000 77500 77000 76000 72000 71500 71000 70500 70500 68500 67500 66000 63500 58500 49000)

mpirun -np 1 ../revbayes-4166bad/projects/cmake/build-mpi/rb-mpi ./scripts/large_number_large_stones_restart.Rev "2" "Brusatte_etal_2008a" 0.05 ${array0[$SLURM_ARRAY_TASK_ID]} ${array1[$SLURM_ARRAY_TASK_ID]}
