
default: all


all: thermalcond


thermalcond:
	@echo "Source CPU_GNU environment, Loading module conda and alamode, activating Conda environment, and running the script..."
	@source /global/homes/s/sypeng/soft/Modules/env_sh/activate_cpu_gnu.sh && \
	module load conda alamode/250501-cpu-gnu && conda activate alamode && \
	export OMP_NUM_THREADS=128 && \
	/global/cfs/cdirs/m2626/sypeng/soft/alamode/250501/alamode/_build/anphon/anphon diamond_kappa.in > diamond_kappa.log2

plotkappa:
	@echo "Source CPU_GNU environment, Loading module conda and alamode, activating Conda environment, and running the script..."
	@source /global/homes/s/sypeng/soft/Modules/env_sh/activate_cpu_gnu.sh && \
	module load conda alamode/250501-cpu-gnu && conda activate alamode && \
	python plot_kappa.py > diamond_plotkappa.log
