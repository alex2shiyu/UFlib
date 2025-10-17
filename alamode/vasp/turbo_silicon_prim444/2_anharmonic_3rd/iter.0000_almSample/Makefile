
default: all


all: suggest create-dis


suggest:
	alm si_alm.in > si_alm.log1

create-dis:
	python /home/sypeng/soft/alamode/alamode-20241218/tools/displace.py --QE=/home/sypeng/work/silicon/alamode-PBE/alamode-prim-444/data/si444.pw.in --mag=0.01 -pf si_prim444_cubic.pattern_ANHARM3 > create-dis.log2
