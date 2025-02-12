rc2 = 6
nsample = 12
temp = 300

default: all

input:
	cp ../../data/crystal/infile.ucposcar ../../data/crystal/infile.ssposcar ./
	cp ../../data/loto/merge_pw_ph/infile.lotosplitting ./
	tdep_parse_output --temperature $(temp) samples/*/scf.out > out_1.dat

input-debye:
	cp ../../data/crystal/infile.ucposcar ../../data/crystal/infile.ssposcar ./

fc:
	extract_forceconstants -rc2 $(rc2) --polar -pc 3 --nosymmborn 2>&1 | tee extract_forceconstants.log
	cp outfile.forceconstant infile.forceconstant
	canonical_configuration --quantum --temperature $(temp) -n $(nsample) -of 8 > out_2.dat
	phonon_dispersion_relations --unit mev > out_3.dat
	sed -i.bak '1c\set terminal pdf size 8cm,7cm enhanced font "CMU Serif,10"\nset output "outfile.dispersion_relations.pdf"' outfile.dispersion_relations.gnuplot
	gnuplot -p outfile.dispersion_relations.gnuplot
	gnuplot -p outfile.dispersion_relations.gnuplot.bak

fc-debye:     
	canonical_configuration --quantum --temperature $(temp) -n $(nsample) -td $(td) -of 8 > out_4.dat
	cp outfile.fakeforceconstant infile.forceconstant
	phonon_dispersion_relations --unit mev> out_5.dat
	sed -i.bak '1c\set terminal pdf size 8cm,7cm enhanced font "CMU Serif,10"\nset output "outfile.dispersion_relations.pdf"' outfile.dispersion_relations.gnuplot 
	gnuplot -p outfile.dispersion_relations.gnuplot
	gnuplot -p outfile.dispersion_relations.gnuplot.bak

all: input fc

debye: input-debye fc-debye


clean:
	rm -rf infile.*
	rm -rf *.log
	rm -rf outfile.*
	rm -rf out*.dat
	rm -rf *.out
	rm -rf contcar*
	
