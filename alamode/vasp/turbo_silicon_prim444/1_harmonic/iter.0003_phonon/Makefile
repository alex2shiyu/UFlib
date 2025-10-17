
default: all


all: phonon


phonon:
	anphon si_phband.in > si_phband.log

plot:
	python /home/sypeng/soft/alamode/alamode-20241218/tools/plotband.py si_prim444_cubic.bands > plotphonon.log
