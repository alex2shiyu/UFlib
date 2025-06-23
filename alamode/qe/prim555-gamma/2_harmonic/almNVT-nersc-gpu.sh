#!/bin/bash
#SBATCH -q premium
#SBATCH -A jcap_g
#SBATCH --mail-type=begin,end,fail
#SBATCH --mail-user=sypeng23@caltech.edu
#SBATCH -C gpu,hbm40g
#SBATCH -N 4                 # Number of nodes
#SBATCH --ntasks-per-node=4
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=single:1
#SBATCH -J 333-gam               # job name
#SBATCH -t 8:00:00          # time limit
#SBATCH --array=1-1%5              # Number of job array tasks
#SBATCH --output=slurm-%A_%a.log # Output file for each array TASK

module unload cudatoolkit/12.2
module load cudatoolkit/12.0 PrgEnv-nvidia nvidia/23.1
module load cray-hdf5-parallel/1.12.2.3 cray-libsci/23.02.1.1
module load conda python/3.11

cpus_per_node=$SLURM_CPUS_ON_NODE
total_nodes=$SLURM_NNODES
mpi_tasks_per_node=$SLURM_NTASKS_PER_NODE
#cpus_per_node=64
#total_nodes=8
#
total_mpi_tasks=`expr $mpi_tasks_per_node \* $total_nodes`
cpus_per_task=`expr $cpus_per_node / $mpi_tasks_per_node`
#OpenMP settings:  16 for GPU nodes, 32 for CPU nodes
export OMP_NUM_THREADS=1
#$cpus_per_task
export OMP_PLACES=threads
export OMP_PROC_BIND=true

npools_cpu=1
nbands_cpu=4

echo "cpus_per_task: $cpus_per_task"
echo "total_mpi_tasks: $total_mpi_tasks"
echo "total_nodes: $total_nodes"
echo "mpi_tasks_per_node: $mpi_tasks_per_node"
echo "cpus_per_node: $cpus_per_node"


#-------------------------------------------------------------
# Set up the environment

EXEFILE=/global/cfs/cdirs/m2626/sypeng/soft/qe-7.2-U_GPU-nvdia23.1-toolkit/bin/pw.x
INPUTFILE=scf.in
OUTPUTFILE=scf.out

sourceDIR="iter.0000_almSample"
destDIR="iter.0001_runQE"
numtot_conf=1
num_conf_per_task=1
#$SLURM_ARRAY_TASK_MAX

if [ ! -d "$destDIR" ]; then
    mkdir -p $destDIR
    echo "$destDIR created!"
else
    echo "$destDIR exist!"
fi
cd $destDIR

if [ ! -d "samples" ]; then
    mkdir -p "samples"
    echo "samples created"
else
    echo "samples exist!"
fi
cd "samples"

# Iterate over q points using the job array task ID
Cstart=$(($num_conf_per_task*$SLURM_ARRAY_TASK_ID-$num_conf_per_task+1))
Cend=$(($num_conf_per_task*$SLURM_ARRAY_TASK_ID))
if [ $Cend -gt $numtot_conf ]; then
    Cend=$numtot_conf
fi
#echo Computing configuration $Cstart to $Cend
echo "Computing configuration $Cstart -> $Cend ..."

for ((iC=$Cstart; iC<=$Cend; iC++)); do

    echo "Computing $iC ..."
    NQ_source=$iC
    if [ "$iC" -lt 10 ]; then
        NQ_target="000${iC}"
        #note that the serial number of disp01.pw.in in ../iter.0000_alm is twp digits for 1 <= that <= 99
        #
        #if the number is less than 10, we need to add a zero in front of it.
        #
        if [ "$numtot_conf" -lt 10 ]; then
            NQ_source="${iC}"
        elif [ "$numtot_conf" -lt 100 ]; then
            NQ_source="0${iC}"
        elif [ "$numtot_conf" -lt 1000 ]; then
            NQ_source="00${iC}"
        else
            NQ_source="000${iC}"
        fi
    elif [ "$iC" -lt 100 ]; then
        NQ_target="00${iC}"
        if [ "$numtot_conf" -lt 100 ]; then
            NQ_source="${iC}"
        elif [ "$numtot_conf" -lt 1000 ]; then
            NQ_source="0${iC}"
        else
            NQ_source="00${iC}"
        fi
    elif [ "$iC" -lt 1000 ]; then
        NQ_target="0${iC}"
        if [ "$numtot_conf" -lt 1000 ]; then
            NQ_source="${iC}"
        else
            NQ_source="0${iC}"
        fi
    fi

    DIR1="sample.$NQ_target"
    if [ -d "$DIR1" ]; then
        echo "$NQ_target exist and renamed."
        mv $DIR1 "$DIR1"_backup
    fi
    mkdir $DIR1
    echo "Creating $NQ_target ..."
    cp -r "../../iter.0000_almSample/disp${NQ_source}.pw.in" ./"$DIR1"/scf.in
    cd $DIR1

    echo Job starts at `date`
    #-------------------------------------------------------------

    #module load qe/7.2-intel21.7

    #export OMP_NUM_THREADS=4

    #srun -n 16 pw.x -npools 4 -i scf.in > scf.out
    # Run Perturbo
    srun -N $total_nodes -n $total_mpi_tasks -c $cpus_per_task -G $total_mpi_tasks \
        --cpu_bind=cores --gpus-per-task=1 --gpu-bind=single:1 \
        $EXEFILE -npools $npools_cpu -nband $nbands_cpu -i $INPUTFILE > $OUTPUTFILE

    #-------------------------------------------------------------
    echo Job ends at `date`

    # done, return to upper directory.

    # go outside sample.000N
    cd ..
done

# go ourside samples
cd ..

# go outside iter.0001
cd ..
