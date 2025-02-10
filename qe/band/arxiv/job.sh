#!/bin/bash
#SBATCH -N 1                 # Number of nodes
#SBATCH -p debug             # queue type (regular | debug | large | long)
#SBATCH -J scf               # job name
#SBATCH -t 01:00:00          # time limit

#-------------------------------------------------------------
echo Job starts at `date`
#-------------------------------------------------------------

module load qe/7.2-intel

srun -n 64 pw.x -npools 8 -i bands.in > nscf_band.out
srun -n 1 bands.x -i bands.in > bands.out

#-------------------------------------------------------------
echo Job ends at `date`
#-------------------------------------------------------------
