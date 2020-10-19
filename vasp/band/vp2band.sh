#!/bin/bash
outfile=OUTCAR.scf
infile=INCAR

if [ -e $outfile -a -e ./EIGENVAL ] 
then
    echo "The" $outfile "exists, we use it to get the Fermi level,"
    echo "the RWIGS tag and the number of spins."
    efermi=$(grep "E-fermi" $outfile | tail -1 | awk '{print $3}')
    echo "Fermi level:" $efermi 
    echo "$efermi : Fermi level "> EFERMI
    ISPIN=$(grep "ISPIN" $outfile | tail -1 | awk '{print $3}')
    echo "ISPIN: " $ISPIN
    echo "$ISPIN      : IPSIN" >> EFERMI
    #
    time vp_band
    #
else
    echo -e "\tPlease rename the scf OUTCAR as OUTCAR.scf"
    echo -e "\tThe program need EIGENVAL file"
fi

