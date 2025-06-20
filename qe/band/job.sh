#!/bin/bash
#SBATCH -N 4                 # Number of nodes
#SBATCH -p regular           # queue type (regular | debug | large | long)
#SBATCH -J scf               # job name
#SBATCH -t 48:00:00          # time limit

#-------------------------------------------------------------
echo Job starts at `date`
#-------------------------------------------------------------

module load qe/7.2-intel

srun -n 256 pw.x -npools 8 -nband 8 < bands.in > band_dft.out
srun -n 64 bands.x -npools 8 < bands.in > band_plot.out
srun -n 1 projwfc.x < kpdos.in > kpdos.out
plotband.x < plotband.in > plotband.out

#-------------------------------------------------------------
echo Job ends at `date`
#-------------------------------------------------------------
