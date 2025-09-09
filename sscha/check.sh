#!/bin/bash
#SBATCH --account=m2626
#SBATCH -C gpu
#SBATCH -q regular
#SBATCH -t 10:00:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH -c 32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=none
#-----------------------
echo Job starts ar `date`
#-----------------------

pop_number=2
for i in {1..40}
do

cd /pscratch/sd/y/yluo7/sscha-STO/sscha-444-200K

cd ensemble_${i}

tail -n 3 scf.out

done 

#-----------------------
echo Job ends ar `date`
#-----------------------


