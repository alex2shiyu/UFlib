#!/bin/bash
#SBATCH -N 1                 # Number of nodes
#SBATCH -p regular             # queue type (regular | debug | large | long)
#SBATCH -J pert_ph           # job name
#SBATCH -t 48:00:00          # time limit

#-------------------------------------------------------------
echo Job starts at `date`
#-------------------------------------------------------------

#module load perturbo-dev/sundials/intel-mvapich2.3.7-tdep
#module load perturbo-dev/dev-sypeng/intel-mvapich2.3.7
export OMP_NUM_THREADS=64

conda activate alamode
module load alamode

#srun -n 1 /home/sypeng/soft/qe-7.2/perturbo-dev-cbte/bin/perturbo.x -npools 1 -i pert.in > pert.out 2>err
srun -n 1 anphon si_kappa.in > out.dat 2>err

#srun -n 64 ph.x -npools 8 < ph.in > ph.out

#-------------------------------------------------------------
echo Job ends at `date`
#-------------------------------------------------------------
