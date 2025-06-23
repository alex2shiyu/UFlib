#!/bin/bash
#SBATCH -N 4                 	    # Number of nodes, MUST be 1
#SBATCH --ntasks-per-node=16 	    # MPI tasks per node
#SBATCH -p regular              	    # queue type (regular | debug | large | long)
#SBATCH -J alm             	    # job name
#SBATCH -t 48:00:00          	    # time limit
#SBATCH --output=slurm-%A_%a.log # Output file for each array TASK



# First, we need to test the convergence of dielectric tensor
# which is computed when q=0 w.r.t k-grid.
# the converged k-grid is then used in othe q points.


echo Job starts at `date`
#-------------------------------------------------------------

module load qe/7.2-intel21.7

export OMP_NUM_THREADS=4

srun -n 64 pw.x -i scf.in > scf.out

#-------------------------------------------------------------
echo Job ends at `date`

