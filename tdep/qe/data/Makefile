rc2 = 7.2
rc3 = 6
nsample = 5
temp = 300
td = 600

default: all

input-debye:
	 cp ../../data/crystal/infile.ucposcar ../../data/crystal/infile.ssposcar ./

input:
	 cp ../../data/crystal/infile.ucposcar ../../data/crystal/infile.ssposcar ./
	 cp ../../data/loto/merge_pw_ph/infile.lotosplitting ./
	 tdep_parse_output --temperature $(temp) samples/*/vasprun.xml > out1.dat

new-fc-debye:
	canonical_configuration --quantum --temperature $(temp) -n $(nsample) -td $(td) -of 8 > out2.dat
	cp outfile.fakeforceconstant infile.forceconstant
	phonon_dispersion_relations --unit mev -p > out3.dat
	gnuplot -p outfile.dispersion_relations.gnuplot_pdf

new-fc2:
	extract_forceconstants -rc2 $(rc2) --polar  2>&1 | tee extract_forceconstants.log
	cp outfile.forceconstant infile.forceconstant
	canonical_configuration --quantum --temperature $(temp) -n $(nsample) -of 8 > out2.dat
	phonon_dispersion_relations --unit mev -p > out3.dat
	gnuplot -p outfile.dispersion_relations.gnuplot_pdf
	tdep_plot_fc_norms > out4.dat

new-fc2fc3:
	extract_forceconstants -rc2 $(rc2) -rc3 $(rc3) --polar  2>&1 | tee extract_forceconstants.log
	cp outfile.forceconstant infile.forceconstant
	canonical_configuration --quantum --temperature $(temp) -n $(nsample) -of 8 > out2.dat
	phonon_dispersion_relations --unit mev -p > out3.dat
	gnuplot -p outfile.dispersion_relations.gnuplot_pdf
	tdep_plot_fc_norms > out4.dat


old-fc-debye:
	canonical_configuration --quantum --temperature $(temp) -n $(nsample) -td $(td) -of 8 > out2.dat
	cp outfile.fakeforceconstant infile.forceconstant
	phonon_dispersion_relations --unit mev> out3.dat
	sed -i.bak '1c\set terminal pdf size 8cm,7cm enhanced font "CMU Serif,10"\nset output "outfile.dispersion_relations.pdf"' outfile.dispersion_relations.gnuplot
	gnuplot -p outfile.dispersion_relations.gnuplot
	gnuplot -p outfile.dispersion_relations.gnuplot.bak


old-fc2:
	extract_forceconstants -rc2 $(rc2) --polar -pc 3 --nosymmborn 2>&1 | tee extract_forceconstants.log
	cp outfile.forceconstant infile.forceconstant
	canonical_configuration --quantum --temperature $(temp) -n $(nsample) -of 8 > out2.dat
	phonon_dispersion_relations --unit mev > out3.dat
	sed -i.bak '1c\set terminal pdf size 8cm,7cm enhanced font "CMU Serif,10"\nset output "outfile.dispersion_relations.pdf"' outfile.dispersion_relations.gnuplot
	gnuplot -p outfile.dispersion_relations.gnuplot
	gnuplot -p outfile.dispersion_relations.gnuplot.bak


new-debye: input-debye new-fc-debye

new-iter: input new-fc2

new-last: input new-fc2fc3

old-debye: input-debye old-fc-debye

old-iter: input old-fc2
	
	 
clean:
	rm -rf infile.*
	rm -rf outfile.*
	rm -rf *.dat
	rm -rf *.out
	rm -rf contcar*
