#!/bin/bash
#SBATCH -N 1                 	    # Number of nodes, MUST be 1
#SBATCH --ntasks-per-node=64 	    # MPI tasks per node
#SBATCH -p regular              	    # queue type (regular | debug | large | long)
#SBATCH -J vaspNVT               	    # job name
#SBATCH -t 48:00:00          	    # time limit
#SBATCH --no-requeue
#SBATCH --array=1-96%6              # Number of job array tasks
#SBATCH --output=slurm-%A_%a.log # Output file for each array TASK


#There are three things you need to change
#1. SBATCH --array=1-96%6
#2. sourceDIR and destDIR
#3. module load and parallelism parameters

# change this every time
sourceDIR="iter.0005"
destDIR="iter.0006"

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
ND=$SLURM_ARRAY_TASK_ID

if [ "$ND" -lt 10 ]; then
    NQ="000${ND}"
elif [ "$ND" -lt 100 ]; then
    NQ="00${ND}"
elif [ "$ND" -lt 1000 ]; then
    NQ="0${ND}"
fi
echo $NQ

DIR1="sample.$NQ"
if [ -d "$DIR1" ]; then
    mv $DIR1 "$DIR1"_backup
fi
cp -r ../../../data/input_demo ./"$DIR1"
cd $DIR1

cp "../../../$sourceDIR/contcar_conf${NQ}" ./POSCAR

#-------------------------------------------------------------
#change the phonon script
#######cp ../../${SUBJOB} ./
#sed -i  "s|.*test-ph.*|#SBATCH -J \"${PREFIX}-ph-q${NQ}\"|g" ${SUBJOB}
#sed -i  "s|.*test-ph.*|#PBS -N ${PREFIX}-ph-q${NQ}|g" ${SUBJOB}
#sed -i  "s|.*NQ=.*|NQ=${NQ}|g" ${SUBJOB}
#sed -i  "s|.*PREFIX=.*|PREFIX=${PREFIX}|g" ${SUBJOB}

# different dir in q=0 calculation.
#if [ "$NQ" == "1" ]; then
#   sed -i "s|.*DPATH=.*| DPATH='.' |g" ${SUBJOB}
#fi

#-------------------------------------------------------------
# run the phonon script
##bash ${SUBJOB}
##echo Done $DIR

echo Job starts at `date`
#-------------------------------------------------------------

module load vasp/6.1.1/intel_2021.7.1_mvapich2_2.3.7_1

export OMP_NUM_THREADS=1

#srun -n 64 vasp_std > vasp.out 2>err
srun -n 64 vasp_gam > vasp.out 2>err

#-------------------------------------------------------------
echo Job ends at `date`

# done, return to upper directory.

# go outside sample.000N
cd ..

# go ourside samples
cd ..

# go outside iter.0001
cd ..
