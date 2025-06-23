
default: all


all: extract 


extract:
	@echo "Source CPU_GNU environment, Loading module conda and alamode, activating Conda environment, and running the script..."
	@source /global/homes/s/sypeng/soft/Modules/env_sh/activate_cpu_gnu.sh && \
	module load conda alamode/250501-cpu-gnu  && conda activate alamode && \
	python /global/cfs/cdirs/m2626/sypeng/soft/alamode/250501/alamode/tools/extract.py --QE=/global/cfs/cdirs/m2626/sypeng/work/diamond/USPP-PBE-PM-QE/pw-ph-wann-alm/7-alm/prim555-gamma/0_data/diamond-prim555.pw.in samples/*/scf.out > DFSET_cubic
