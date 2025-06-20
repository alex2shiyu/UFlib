#!/bin/bash

sw='restart-u'
end=''
cluster='nersc'

#-------------------------------------------------------------
# define the executable file

SCRDIR="/pscratch/sd/s/${USER}/work/phonon/tmp_${SLURM_JOB_ID}"
echo "$SCRDIR"

# see whether SCRDIR exists, if yes, delete it
if [ -d "$SCRDIR" ]; then
    echo "ERROR: $SCRDIR exists, we will delete it first!"
    rm -rf $SCRDIR
fi

#create scratch dir
mkdir -p $SCRDIR

if [ -d "$SLURM_SUBMIT_DIR/tmp" ]; then
  cp -r $SLURM_SUBMIT_DIR/tmp/*.save $SCRDIR/
else
  echo "ERROR: No tmp directory!"
  exit
fi

#-------------------------------------------------------------
echo Job starts at `date`
#-------------------------------------------------------------

NQ=
# Get the PREFIX from ph-ref.in
PREFIX=`awk -F= '{if($0~"prefix") print $NF}' ph-ref.in | sed "s/'//g" | sed 's/"//g' | sed 's/,//g' | sed 's/ //g'`
CASE=ph
sed -i  "s|.*outdir.*| outdir='${SCRDIR}'|g"  ${CASE}.in
#export OMP_NUM_THREADS=4

#module load qe/7.2-intel21.7
# modify npools if needed
#srun -n $SLURM_NTASKS ph.x -npools 4 < ${CASE}.in > ${CASE}.out
#module load qe/7.2-intel
module unload cudatoolkit/12.2
module load cudatoolkit/12.0 PrgEnv-nvidia nvidia/23.1
module load cray-hdf5-parallel/1.12.2.3 cray-libsci/23.02.1.1 cray-fftw
module load conda python/3.11

EXEFILE=/global/cfs/cdirs/m2626/sypeng/soft/qe-7.2-U_GPU-nvdia23.1-toolkit/bin/ph.x
INPUTFILE=ph.in
OUTPUTFILE=ph.out

#-------------------------------------------------------------
# Hybrid MPI/OpenMP settings

#mpi_tasks_per_node=4
#
#cpus_per_node=$SLURM_CPUS_ON_NODE
#total_nodes=$SLURM_NNODES
mpi_tasks_per_node=4
cpus_per_node=64
total_nodes=10
#
total_mpi_tasks=`expr $mpi_tasks_per_node \* $total_nodes`
cpus_per_task=`expr $cpus_per_node / $mpi_tasks_per_node`

#-------------------------------------------------------------
# Set up the environment

#OpenMP settings:  16 for GPU nodes, 32 for CPU nodes
export OMP_NUM_THREADS=$cpus_per_task
export OMP_PLACES=threads
export OMP_PROC_BIND=true

# Print our environment, for debugging
# env

# Run Perturbo
srun -N $total_nodes -n $total_mpi_tasks -c $cpus_per_task \
	--cpu_bind=cores --gpus-per-task=1 --gpu-bind=single:1 \
	$EXEFILE -npools $total_mpi_tasks -i $INPUTFILE > $OUTPUTFILE


#-------------------------------------------------------------
echo Job ends at `date`
#-------------------------------------------------------------

#-------------------------------------------------------------
#transfer data to login nodes if needed, and clear scratch dir

if [ "$sw" == "restart" ]; then
     mkdir -p ./tmp
     mkdir -p ./tmp/_ph0
     mkdir -p ./tmp/_ph0/${PREFIX}.q_${NQ}
     cp -r $SCRDIR/_ph0/*.phsave  $SLURM_SUBMIT_DIR/ph-${NQ}/tmp/_ph0/
     DPATH=${PREFIX}.q_${NQ}
     cp -r $SCRDIR/_ph0/${DPATH}/*.dvscf1  $SLURM_SUBMIT_DIR/ph-${NQ}/tmp/_ph0/${PREFIX}.q_${NQ}/
elif [ "$sw" == "restart-u" ]; then
     mkdir -p ./tmp
     mkdir -p ./tmp/_ph0
     mkdir -p ./tmp/_ph0/${PREFIX}.q_${NQ}
     cp -r $SCRDIR/_ph0/*.phsave  $SLURM_SUBMIT_DIR/ph-${NQ}/tmp/_ph0/
     DPATH=${PREFIX}.q_${NQ}
     cp -r $SCRDIR/_ph0/${DPATH}/*.dvscf1  $SLURM_SUBMIT_DIR/ph-${NQ}/tmp/_ph0/${PREFIX}.q_${NQ}/
     cp -r $SCRDIR/_ph0/${DPATH}/*.dns*  $SLURM_SUBMIT_DIR/ph-${NQ}/tmp/_ph0/${PREFIX}.q_${NQ}/
     cp -r $SCRDIR/_ph0/${DPATH}/*.d2n*  $SLURM_SUBMIT_DIR/ph-${NQ}/tmp/_ph0/${PREFIX}.q_${NQ}/
fi

if [ "$end" == 'clear' ]; then
      rm -rf $SCRDIR
      if [ "$cluster" == 'turbo' ]; then
          # Clean up the scratch directory (older than 30 days)
          SCRHOME="/scratch/${USER}"
          find $SCRHOME/* -mtime +30 -exec rm -rf {} \;
      fi
elif [ "$end" == 'collect_all' ]; then

      cp -r $SCRDIR/*  $SLURM_SUBMIT_DIR/ph-${NQ}/tmp/
      rm -rf $SCRDIR
fi
