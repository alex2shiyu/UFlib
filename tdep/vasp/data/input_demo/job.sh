#!/bin/bash
#SBATCH -N 2                 # Number of nodes
#SBATCH -p regular           # queue type (regular | debug | large | long)
#SBATCH -J vasp4tdep              # job name
#SBATCH -t 06:00:00          # time limit

#-------------------------------------------------------------
echo Job starts at `date`
#-------------------------------------------------------------

module load vasp/6.1.1_intel_2021.7.1_mvapich2_2.3.7_1

export OMP_NUM_THREADS=1

srun -n 128 vasp_ncl > vasp.out 2>err

#-------------------------------------------------------------
echo Job ends at `date`
#-------------------------------------------------------------
