#!/bin/bash
#SBATCH --account=m2626
#SBATCH -C gpu
#SBATCH -q regular
#SBATCH -t 5:00:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH -J 1sscha-30
#SBATCH -c 32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=none

export SLURM_CPU_BIND="cores"
module purge
module load craype-x86-milan
module load cray-fftw/3.3.10.2
module load espresso/7.0-libxc-5.2.2-gpu

#-----------------------
echo Job starts ar `date`
#-----------------------

pop_number=1
for i in {71..100}
do

cd /pscratch/sd/s/sypeng/work/sto/test-sscha/data_sscha 

mkdir ensemble_${i}
cp scf.in ensemble_${i}
cd ensemble_${i}
cat ../data_ensemble_manual/scf_population${pop_number}_${i}.dat >> scf.in

srun pw.x < scf.in > scf.out

rm -rf tmp

done

#-----------------------
echo Job ends ar `date`
#-----------------------


