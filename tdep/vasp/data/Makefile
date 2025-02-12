rc2 = 7.2
nsample = 5
temp = 300

default: all

input:
	 cp ../../data/crystal/infile.ucposcar ../../data/crystal/infile.ssposcar ./
	 tdep_parse_output --temperature $(temp) samples/*/vasprun.xml > out_1.dat
	 cp ../../data/loto/outfile.lotosplitting ./infile.lotosplitting

input-debye:
	 cp ../../data/crystal/infile.ucposcar ../../data/crystal/infile.ssposcar ./

fc:
	extract_forceconstants -rc2 $(rc2) --polar  2>&1 | tee extract_forceconstants.log
	cp outfile.forceconstant infile.forceconstant
	canonical_configuration --quantum --temperature $(temp) -n $(nsample) > out_2.dat
	phonon_dispersion_relations --unit mev -p > out_3.dat
	gnuplot -p outfile.dispersion_relations.gnuplot_pdf
	tdep_plot_fc_norms > out_4.dat

fc-debye:
	canonical_configuration --quantum --temperature $(temp) -n $(nsample) -td $(td) > out_4.dat
	cp outfile.fakeforceconstant infile.forceconstant
	phonon_dispersion_relations --unit mev> out_5.dat
	sed -i.bak '1c\set terminal pdf size 8cm,7cm enhanced font "CMU Serif,10"\nset output "outfile.dispersion_relations.pdf"' outfile.dispersion_relations.gnuplot
	gnuplot -p outfile.dispersion_relations.gnuplot
	gnuplot -p outfile.dispersion_relations.gnuplot.bak

all: input fc
	
debye: input-debye fc-debye
	 
clean:
	rm -rf infile.*
	rm -rf outfile.*
	rm -rf *.dat
	rm -rf *.out
	rm -rf contcar*
