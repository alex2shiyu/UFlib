#!/bin/bash
#SBATCH -q premium
#SBATCH -A jcap_g
##SBATCH -A m4289_g
##SBATCH -A m2626_g
#SBATCH --mail-type=begin,end,fail
#SBATCH --mail-user=sypeng23@caltech.edu
#SBATCH -C gpu,hbm40g
#SBATCH -N 10                 # Number of nodes
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=16
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=single:1
#SBATCH -J phonon               # job name
#SBATCH -t 7:00:00          # time limit

# In the following, "comment" means put more then one hash, uncomment means leave only one hash

# ===FIRST===, run the gamma point, find the number of q-points nq
##SBATCH --array=1-1%1             # Number of job array tasks

# ===SECOND===, comment the SBATCH line above and uncomment below,
# modify NQ to the number of q points
#SBATCH --array=7-7%1            # Number of job array tasks
##SBATCH --array=26-27%5            # Number of job array tasks


#SBATCH --output=slurm-%A_%a.log # Output file for each array TASK

# Get the PREFIX from ph-ref.in
PREFIX=`awk -F= '{if($0~"prefix") print $NF}' ph-ref.in | sed "s/'//g" | sed 's/"//g' | sed 's/,//g' | sed 's/ //g'`

SUBJOB='qe-ph-v70.sh'

# First, we need to test the convergence of dielectric tensor
# which is computed when q=0 w.r.t k-grid.
# the converged k-grid is then used in othe q points.

mode="gamma"

# Iterate over q points using the job array task ID
NQ=$SLURM_ARRAY_TASK_ID

# get the maximum value of $SLURM_ARRAY_TASK_ID from here #SBATCH --array=1-18%18 using slurm variables
NQmax=8

#define the start and end q points: start=2*NQ-1, end=2*NQ, the end value should not be larger than NQmax

#if NQ==1, then qstart=1, end=2
#if [ $NQ -eq 1 ]; then
#    Qstart=1
#    Qend=3
#elif [ $NQ -eq 2 ]; then
#    Qstart=7
#    Qend=8
#elif [ $NQ -eq 3 ]; then
#    Qstart=13
#    Qend=15
#elif [ $NQ -eq 4 ]; then
#    Qstart=16
#    Qend=21
#elif [ $NQ -eq 5 ]; then
#    Qstart=22
#    Qend=27
#fi

Qstart=$NQ
Qend=$NQ


#Qstart=$((1*NQ-0))
#Qend=$((1*NQ))
#Qstart=$SLURM_ARRAY_TASK_ID
#Qend=$SLURM_ARRAY_TASK_ID
if [ $Qend -gt $NQmax ]; then
    Qend=$NQmax
fi


# loop over q points
for ((iQ=$Qstart; iQ<=$Qend; iQ++)); do
    DIR=ph-$iQ
    echo $DIR
    mkdir -p $DIR
    
    cd $DIR


   #cp ../ph-ref.in  ./ph.in
    cp /global/cfs/cdirs/m2626/sypeng/work/fesb2/PBE-PM-QE-Finalone/pw-ph-wann-alm-U3.0/5-phonon-222/ph-$NQ/ph.in ./
    sed -i   "s|.*prefix.*|  prefix='${PREFIX}'|g"      ph.in
    sed -i   "s|.*fildyn.*|  fildyn='${PREFIX}.dyn.xml'|g"  ph.in
    sed -i   "s|.*start_q.*|  start_q= ${iQ}|g"  ph.in
    sed -i   "s|.*last_q.*|  last_q = ${iQ}|g"  ph.in
    
    #-------------------------------------------------------------
    #change the phonon script
    cp ../${SUBJOB} ./
    #sed -i  "s|.*test-ph.*|#SBATCH -J \"${PREFIX}-ph-q${NQ}\"|g" ${SUBJOB}
    #sed -i  "s|.*test-ph.*|#PBS -N ${PREFIX}-ph-q${NQ}|g" ${SUBJOB}
    sed -i  "s|.*NQ=.*|NQ=${iQ}|g" ${SUBJOB}
    sed -i  "s|.*PREFIX=.*|PREFIX=${PREFIX}|g" ${SUBJOB}
    
    # different dir in q=0 calculation.
    if [ "$iQ" == "1" ]; then
       sed -i "s|.*DPATH=.*| DPATH='.' |g" ${SUBJOB}
    fi
    
    #-------------------------------------------------------------
    # run the phonon script
    bash ${SUBJOB}
    echo Done $DIR
    
    # done, return to upper directory.
    cd ..
done
