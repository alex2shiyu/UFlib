#!/usr/bin/env python

from wanntb.band import band
from wanntb.ham import HR
import numpy as np

print(">>> start ...")
print(">>> build H(R)")
hr = HR.from_file('wannier90_hr.dat_nsymm8')
hr_mat = hr.get_hr(0)
nkpt_pline = 50
efermi = 12.5900 
#Rbase=[[  -1.7349141, 1.7349141,5.8687908],
#        [1.7349141,-1.7349141, 5.8687908],
#        [1.7349141, 1.7349141,-5.8687908]]
#Rbase = np.array(Rbase)
Rbase=[[-2.110421645, 3.09539272, 6.911791355],
        [2.110421645,-3.09539272, 6.911791355],
        [2.110421645, 3.09539272,-6.911791355]]
Rbase = np.array(Rbase)

kpoint =[[0.000,0.000,0.000], #G
    [0.000,0.500, 0.000],      #R
    [0.000,0.000, 0.500],      #T
    [0.500,0.000, 0.000],      #S
    [0.000,0.000, 0.000],      #G
    [0.500,0.500,-0.500]]      #X
kpoint = np.array(kpoint)
     

bands = band(hr.nwann,nkpt_pline,kpoint,Rbase,efermi,hr,hr_mat)
bands.band_plot(bandfile='UTe2_udud_ffdd_symm_band.dat')
#bands.make_kbase()
