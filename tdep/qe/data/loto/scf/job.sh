#!/bin/bash
#SBATCH -N 1                 # Number of nodes
#SBATCH -p regular           # queue type (regular | debug | large | long)
#SBATCH -J scf               # job name
#SBATCH -t 06:00:00          # time limit

#-------------------------------------------------------------
echo Job starts at `date`
#-------------------------------------------------------------

module load qe/7.2-intel

srun -n 64 pw.x -npools 8 < scf.in > scf.out

#-------------------------------------------------------------
echo Job ends at `date`
#-------------------------------------------------------------
