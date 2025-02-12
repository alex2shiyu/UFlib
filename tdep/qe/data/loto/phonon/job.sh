#!/bin/bash
#SBATCH -N 6                 # Number of nodes
#SBATCH -p regular           # queue type (regular | debug | large | long)
#SBATCH -J dfpt-test           # job name
#SBATCH -t 48:00:00          # time limit

#-------------------------------------------------------------
echo Job starts at `date`
#-------------------------------------------------------------

module load qe/7.2-intel21.7

srun -n 384 ph.x -npools 32 < ph.in > ph.out

#-------------------------------------------------------------
echo Job ends at `date`
#-------------------------------------------------------------
