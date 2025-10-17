#!/bin/bash
#SBATCH -N 1                 	    # Number of nodes, MUST be 1
#SBATCH --ntasks-per-node=64 	    # MPI tasks per node
#SBATCH -p regular              	    # queue type (regular | debug | large | long)
#SBATCH -J alm             	    # job name
#SBATCH -t 48:00:00          	    # time limit
#SBATCH --no-requeue
#SBATCH --array=1-16%4              # Number of job array tasks
#SBATCH --output=slurm-%A_%a.log # Output file for each array TASK



# First, we need to test the convergence of dielectric tensor
# which is computed when q=0 w.r.t k-grid.
# the converged k-grid is then used in othe q points.

sourceDIR="iter.0000_almSample"
destDIR="iter.0001_runQE"
numtot_conf=16

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

NQ2=${ND}

if [ "$ND" -lt 10 ]; then
    NQ="000${ND}"
    #note that the serial number of disp01.pw.in in ../iter.0000_alm is twp digits for 1 <= that <= 99
    #
    #if the number is less than 10, we need to add a zero in front of it.
    #
    if [ "$numtot_conf" -lt 10 ]; then
        NQ2="${ND}"
    elif [ "$numtot_conf" -lt 100 ]; then
        NQ2="0${ND}"
    elif [ "$numtot_conf" -lt 1000 ]; then
        NQ2="00${ND}"
    else
        NQ2="000${ND}"
    fi
elif [ "$ND" -lt 100 ]; then
    NQ="00${ND}"
    if [ "$numtot_conf" -lt 100 ]; then
        NQ2="${ND}"
    elif [ "$numtot_conf" -lt 1000 ]; then
        NQ2="0${ND}"
    else
        NQ2="00${ND}"
    fi
elif [ "$ND" -lt 1000 ]; then
    NQ="0${ND}"
    if [ "$numtot_conf" -lt 1000 ]; then
        NQ2="${ND}"
    else
        NQ2="0${ND}"
    fi
fi
echo $NQ

DIR1="sample.$NQ"
if [ -d "$DIR1" ]; then
    mv $DIR1 "$DIR1"_backup
fi
mkdir $DIR1
cp -r "../../iter.0000_almSample/disp${NQ2}.pw.in" ./"$DIR1"/scf.in
cd $DIR1

echo Job starts at `date`
#-------------------------------------------------------------

module load qe/7.2-intel21.7

export OMP_NUM_THREADS=1

srun -n 64 pw.x -i scf.in > scf.out

#-------------------------------------------------------------
echo Job ends at `date`

# done, return to upper directory.

# go outside sample.000N
cd ..

# go ourside samples
cd ..

# go outside iter.0001
cd ..
