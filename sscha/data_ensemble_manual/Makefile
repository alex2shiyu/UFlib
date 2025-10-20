
default: all


all: create-dis


create-dis:
	@echo "Load module alamode, activating Conda environment, and running the script..."
	@echo "Converting VASP configuration files into QE format and checking the results."
	@module load alamode/20241218  && \
	source /home/sypeng/soft/Anaconda3-2023.09-install/etc/profile.d/conda.sh && conda activate alamode && \
	python convert_vasp2qe.py && python check.py && python get_displacement.py 
