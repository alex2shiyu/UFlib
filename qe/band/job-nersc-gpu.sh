#!/bin/bash
#SBATCH -q premium
#SBATCH -A jcap_g
#SBATCH --mail-type=begin,end,fail
#SBATCH --mail-user=sypeng23@caltech.edu
#SBATCH -C gpu,hbm40g
#SBATCH -N 2                 # Number of nodes
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=single:1
#SBATCH -J scf               # job name
#SBATCH -t 06:00:00          # time limit

#-------------------------------------------------------------
echo Job starts at `date`
#-------------------------------------------------------------

#module load qe/7.2-intel
module unload cudatoolkit/12.2
module load cudatoolkit/12.0 PrgEnv-nvidia nvidia/23.1
module load cray-hdf5-parallel/1.12.2.3 cray-libsci/23.02.1.1 cray-fftw
module load conda python/3.11


#-------------------------------------------------------------
# Hybrid MPI/OpenMP settings

mpi_tasks_per_node=4

cpus_per_node=$SLURM_CPUS_ON_NODE
total_nodes=$SLURM_NNODES

total_mpi_tasks=`expr $mpi_tasks_per_node \* $total_nodes`
cpus_per_task=`expr $cpus_per_node / $mpi_tasks_per_node`

#-------------------------------------------------------------
# Set up the environment

#OpenMP settings:  32 for GPU nodes, 64 for CPU nodes
export OMP_NUM_THREADS=$cpus_per_task
export OMP_PLACES=threads
export OMP_PROC_BIND=true

# Print our environment, for debugging
# env

EXEFILE=/global/cfs/cdirs/m2626/sypeng/soft/qe-7.2-U_GPU-nvdia23.1-toolkit/bin/pw.x
INPUTFILE=bands.in
OUTPUTFILE=bands_dft.out
srun -N $total_nodes -n $total_mpi_tasks -c $cpus_per_task \
	--cpu_bind=cores --gpus-per-task=1 --gpu-bind=single:1 \
	$EXEFILE -npools $total_mpi_tasks -i $INPUTFILE > $OUTPUTFILE

EXEFILE=/global/cfs/cdirs/m2626/sypeng/soft/qe-7.2-U_GPU-nvdia23.1-toolkit/bin/bands.x
INPUTFILE=bands.in
OUTPUTFILE=bands_plot.out
srun -N $total_nodes -n $total_mpi_tasks -c $cpus_per_task \
	--cpu_bind=cores --gpus-per-task=1 --gpu-bind=single:1 \
	$EXEFILE -npools $total_mpi_tasks -i $INPUTFILE > $OUTPUTFILE

EXEFILE=/global/cfs/cdirs/m2626/sypeng/soft/qe-7.2-U_GPU-nvdia23.1-toolkit/bin/projwfc.x
INPUTFILE=kpdos.in
OUTPUTFILE=kpdos.out
srun -N $total_nodes -n $total_mpi_tasks -c $cpus_per_task \
	--cpu_bind=cores --gpus-per-task=1 --gpu-bind=single:1 \
	$EXEFILE -i $INPUTFILE > $OUTPUTFILE

#srun -n 256 pw.x -npools 16 -nband 4 < bands.in > band_dft.out
#srun -n 256 bands.x -npools 16 < bands.in > band_plot.out
#srun -n 32 projwfc.x < kpdos.in > kpdos.out

#-------------------------------------------------------------
echo Job ends at `date`
#-------------------------------------------------------------
