
default: all


all: fitting


fitting:
	@echo "Source CPU_GNU environment, Loading module conda and alamode, activating Conda environment, and running the script..."
	@source /global/homes/s/sypeng/soft/Modules/env_sh/activate_cpu_gnu.sh && \
	module load conda alamode/250501-cpu-gnu && conda activate alamode && \
	/global/cfs/cdirs/m2626/sypeng/soft/alamode/250501/alamode/_build/alm/alm diamond_alm.in > diamond_alm.log2
