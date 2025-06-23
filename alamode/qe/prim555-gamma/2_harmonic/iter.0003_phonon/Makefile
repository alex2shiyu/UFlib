
default: all


all: phonon


phonon:
	@echo "Source CPU_GNU environment, Loading module conda and alamode, activating Conda environment, and running the script..."
	@source /global/homes/s/sypeng/soft/Modules/env_sh/activate_cpu_gnu.sh && \
	module load conda alamode/250501-cpu-gnu  && conda activate alamode && \
	/global/cfs/cdirs/m2626/sypeng/soft/alamode/250501/alamode/_build/anphon/anphon diamond_phband.in > diamond_phband.log

plot:
	@echo "Source CPU_GNU environment, Loading module conda and alamode, activating Conda environment, and running the script..."
	@source /global/homes/s/sypeng/soft/Modules/env_sh/activate_cpu_gnu.sh && \
	module load conda alamode/250501-cpu-gnu  && conda activate alamode && \
	python /global/cfs/cdirs/m2626/sypeng/soft/alamode/250501/alamode/tools/plotband.py diamond_prim555.bands > plotphonon.log
