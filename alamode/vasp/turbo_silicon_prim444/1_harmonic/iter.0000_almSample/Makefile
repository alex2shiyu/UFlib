
default: all


all: suggest create-dis


suggest:
	alm si_alm.in > si_alm.log1

create-dis:
	python /home/sypeng/soft/alamode/alamode-20241218/tools/displace.py --QE=/home/sypeng/work/silicon/alamode-PBE-prim/prim-444/2_anharmonic_3rd/data/si444-prim.pw.in --mag=0.01 -pf si_prim444_cubic.pattern_HARMONIC > create-dis.log2
