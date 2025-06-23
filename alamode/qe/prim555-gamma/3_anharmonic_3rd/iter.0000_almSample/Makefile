
default: all


all: suggest create-dis

suggest:
	@echo "Source CPU_GNU environment, Loading module conda and alamode, activating Conda environment, and running the script..."
	@source /global/homes/s/sypeng/soft/Modules/env_sh/activate_cpu_gnu.sh && \
	module load conda alamode/250501-cpu-gnu  && conda activate alamode && \
	/global/cfs/cdirs/m2626/sypeng/soft/alamode/250501/alamode/_build/alm/alm diamond_alm.in > diamond_alm.out

create-dis:
	@echo "Source CPU_GNU environment, Loading module conda and alamode, activating Conda environment, and running the script..."
	@source /global/homes/s/sypeng/soft/Modules/env_sh/activate_cpu_gnu.sh && \
	module load conda alamode/250501-cpu-gnu  && conda activate alamode && \
	python /global/cfs/cdirs/m2626/sypeng/soft/alamode/250501/alamode/tools/displace.py --QE=/global/cfs/cdirs/m2626/sypeng/work/diamond/USPP-PBE-PM-QE/pw-ph-wann-alm/7-alm/prim555-gamma/0_data/diamond-prim555.pw.in --mag=0.01 -pf diamond_prim555_cubic.pattern_ANHARM3 > create-dis.out
