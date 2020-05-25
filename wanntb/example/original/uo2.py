#!/usr/bin/env python

import numpy as np
from numpy.linalg import eigh 
from wanntb.ham import HR
from wanntb.kvec import SymKVec, UniKVec
from wanntb.tran import fourier_hr2hk

# the original wannier90_hr.dat
print(">>> build hr")
hr = HR.from_file()

hr_mat = hr.get_hr(2)
nband = hr.nwann
norbs = 2 * nband

# the K-points base (fractional coordinate)
kbase=[[-0.183016105,0.183016105,0.183016105],
       [0.183016105,-0.183016105,0.183016105],
       [0.183016105,0.183016105,-0.183016105]]

hsymkpt=[[0.000,0.000,0.000], # G
         [0.500,0.000,0.500], # X
         [0.500,0.250,0.750], # W
         [0.375,0.375,0.750], # K
         [0.000,0.000,0.000], # G
         [0.500,0.500,0.500], # L
         [0.625,0.250,0.625], # U
         [0.500,0.250,0.750], # W
         [0.500,0.500,0.500], # L
         [0.375,0.375,0.750]] # K

print(">>> build hk for high-symmetry path")
# define a symmetry k-path
symk = SymKVec(kbase, hsymkpt)
symk.from_hsymkpt(20)
symk.get_klen()
hk_sym = fourier_hr2hk(norbs, symk.nkpt, symk.kvec, hr.nrpt, hr.rpts, hr.deg_rpt, hr_mat)

print(">>> build hk for uniform grid")
# define a uniform k-grid
unik = UniKVec([11,11,11])
unik.from_grid()
hk_uni = fourier_hr2hk(norbs, unik.nkpt, unik.kvec, hr.nrpt, hr.rpts, hr.deg_rpt, hr_mat)

print(">>> get band structure")
eigval = np.zeros((symk.nkpt, norbs),dtype=np.float64)
eigvec = np.zeros((symk.nkpt, norbs, norbs),dtype=np.complex128)
for i in range(symk.nkpt):
    eigval[i,:], eigvec[i,:,:] = eigh(hk_sym[i,:,:])

with open('wann.band.dat', 'w') as f:
    for i in range(norbs):
        for j in range(symk.nkpt):
            line = "{:20.10f}{:20.10f}\n".format(symk.klen[j], eigval[j,i])
            f.write(line)
        f.write("\n\n")

print(">>> dump lda.hamk.dat for sunset")
with open("lda.hamk.dat", 'w') as f:
    line="{:10d}{:10d}\n".format(unik.nkpt, norbs)
    f.write(line)
    for i in range(unik.nkpt):
        for j in range(nband):
            for k in range(nband):
                line = "{:10d}{:10d}{:10d}{:20.10f}{:20.10f}{:20.10f}{:20.10f} \n".format(
                        j+1, k+1, i+1, hk_uni[i,j,k].real, hk_uni[i,j,k].imag,
                        hk_uni[i,j+nband,k+nband].real, hk_uni[i,j+nband,k+nband].imag )
                f.write(line)

