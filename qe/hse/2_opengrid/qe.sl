#!/bin/bash

#SBATCH  -J ge-scf
#SBATCH  -p regular
#SBATCH  -N 1
#SBATCH  --ntasks-per-node=64
#SBATCH  --time=10:00:00

export OMP_NUM_THREADS=1
PH=/home/latan/software/qe-7.2/bin/open_grid.x

mpirun -np 1 $PH -npools 1 -i open_grid.in > open_grid.out
