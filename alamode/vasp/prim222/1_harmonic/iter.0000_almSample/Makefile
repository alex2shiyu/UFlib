
default: all


all: suggest create-dis


suggest:
	/global/cfs/cdirs/m2626/sypeng/soft/alamode/250501/alamode/_build/alm/alm fesb2_alm.in > fesb2_alm.out

create-dis:
	python /global/cfs/cdirs/m2626/sypeng/soft/alamode/250501/alamode/tools/displace.py --VASP=/global/cfs/cdirs/m2626/sypeng/work/fesb2/PBE-PM-VASP/alamode/prim222/0_data/fesb2-prim222.POSCAR --mag=0.01 -pf fesb2_prim222.pattern_HARMONIC > create-dis.out
