#!/usr/bin/env python

import numpy as np
import sys
from   wanntb.ham   import HR
from   wanntb.tran  import tran_op, fourier_hr2hk
from   wanntb.io    import write_gw_input
from   wanntb.kvec  import SymKVec, UniKVec
from   numpy.linalg import eigh
from   wanntb.io    import write_cmplx_matrix1

fname1 = 'dft.cemat.in'
fname2 = 'dft.amat.in'
# 1   prepare
# 1.1 hamiltonian
# the number of every type of atoms; Fe, impurity Fe, Se/Te. 
num_atom = np.array([1,  1],dtype = np.int)

# the orbital of every type of atoms; d orbital, d orbital, p orbital(all with spin).
orb      = np.array([4,  10],dtype = np.int)

# the total number of orbitals of all atoms
num_orb  = 0

for i in range(num_atom.size):
    num_orb = num_orb + num_atom[i] * orb[i]

print("the total number of orbitals is :", num_orb)

# read wannier hamiltonian from wannier90_hr.dat
hr       = HR.from_file()

# double size by spin
hr_mat   = hr.get_hr(1)

# read the onsite hamiltonian and its coordinate
hr0_mat, irpt0 = hr.get_hr0()
# the onsite term of hamiltonian(with spin)
hr_mat0  = hr_mat[irpt0,num_atom[0]*orb[0]:num_orb,num_atom[0]*orb[0]:num_orb] 

hr_tmp   = np.zeros((num_orb,num_orb),dtype=np.complex128)

#test
# 2.4 dumping the modified hamiltonian 
f1='wannier90_hr_Ni.dat'
with open(f1,'w') as f:
    f.write('wannier90_hr.dat format hamiltonian in real space  only d orbitals of Ni\n')
    line = "{:10d}\n".format(num_orb)
    f.write(line)
    line = "{:10d}\n".format(hr.nrpt)
    f.write(line)
    nline = hr.nrpt//15
    nleft = hr.nrpt - nline * 15
#   for i in range(hr.nrpt):
#       line="{:5d}".format(hr.deg_rpt[i])
    for i in range(nline):
        ibase = (i-1)*15
        for j in range(15):
            line="{:5d}".format(hr.deg_rpt[ibase + j])
            f.write(line)
        f.write("\n")
    if nleft > 0 :
        for j in range(nleft):
            line="{:5d}".format(hr.deg_rpt[nline*15 + j])
            f.write(line)
        f.write("\n")
    for i in range(hr.nrpt):
        for j in range(orb[1]):
            for k in range(orb[1]):
                line="{:5d}{:5d}{:5d}{:5d}{:5d}{:20.10f}{:20.10f}\n".format(hr.rpts[i,0],hr.rpts[i,1],hr.rpts[i,2],k+1,j+1,hr_mat[i,k+4,j+4].real,hr_mat[i,k+4,j+4].imag)
                f.write(line)



s,l,m = hr_mat.shape
for j in range(1):
    hr01_mat=hr_mat0
    Eim, evec = eigh(hr01_mat)
    print(Eim)
#   for i in range(s):
#       hr_tmp = np.dot(hr_mat[i,:,:], evec)
#       hr_mat[i,:,:] = np.dot(np.conj(np.transpose(evec)), hr_tmp)
hr_mat0  = np.diag(Eim) 
#        hr_mat[i,:,j*6:j*6+6]=np.dot(hr_mat[i,:,j*6:j*6+6],evec)
#        hr_mat[i,j*6:j*6+6,:]=np.dot(np.conj(np.transpose(evec)),hr_mat[i,j*6:j*6+6,:])
#1.2  crystals
# the basis of k space(which is just n/r, not 2*pi*n/r)
print("testing for the onsite term", hr_mat[irpt0,:,:])
kbase    = [[0.258335852, 0.000000000, 0.000000000],
            [0.000000000, 0.258335852, 0.000000000],
            [0.000000000, 0.000000000, 0.296340199]]

# high-symm line
hsymkpt  = [[0.00,  0.00,  0.00],  #G
            [0.50,  0.00,  0.00],  #X
            [0.50,  0.50,  0.00],  #M
            [0.00,  0.00,  0.00],  #G
            [0.00,  0.00,  0.50],  #Z
            [0.50,  0.00,  0.50],  #R
            [0.50,  0.50,  0.50],  #A
            [0.00,  0.00,  0.50]]  #Z





# 2.4 dumping the modified hamiltonian 
f1='wannier90_hr_new.dat'
with open(f1,'w') as f:
    f.write('wannier90_hr.dat format hamiltonian in real space of impurity\n')
    line = "{:10d}\n".format(num_orb)
    f.write(line)
    line = "{:10d}\n".format(hr.nrpt)
    f.write(line)
    nline = hr.nrpt//15
    nleft = hr.nrpt - nline * 15
#   for i in range(hr.nrpt):
#       line="{:5d}".format(hr.deg_rpt[i])
    for i in range(nline):
        ibase = (i-1)*15
        for j in range(15):
            line="{:5d}".format(hr.deg_rpt[ibase + j])
            f.write(line)
        f.write("\n")
    if nleft > 0 :
        for j in range(nleft):
            line="{:5d}".format(hr.deg_rpt[nline*15 + j])
            f.write(line)
        f.write("\n")
    for i in range(hr.nrpt):
        for j in range(num_orb):
            for k in range(num_orb):
                line="{:5d}{:5d}{:5d}{:5d}{:5d}{:20.10f}{:20.10f}\n".format(hr.rpts[i,0],hr.rpts[i,1],hr.rpts[i,2],k+1,j+1,hr_mat[i,k,j].real,hr_mat[i,k,j].imag)
                f.write(line)

# 3   prepare output.ovlp and output.enk as well as band structure
# 3.1 band structure
# 3.1.1 high-symm line in k-space
print(">>> build hk for high-symmetry path")
symk = SymKVec(kbase, hsymkpt)
symk.from_hsymkpt(20)
symk.get_klen()
print(symk.nkpt)
hk_sym = fourier_hr2hk(num_orb, symk.nkpt, symk.kvec, hr.nrpt, hr.rpts, hr.deg_rpt, hr_mat)

# 3.1.2 diagonalize 
print(">>> get band structure")
eigval = np.zeros((symk.nkpt, num_orb),dtype=np.float64)
eigvec = np.zeros((symk.nkpt, num_orb, num_orb),dtype=np.complex128)
for i in range(symk.nkpt):
    eigval[i,:], eigvec[i,:,:] = eigh(hk_sym[i,:,:])

# 3.1.3 dump band structure 
print(">>> dump wann.band.dat")
with open('wann.band.dat', 'w') as f:
    for i in range(num_orb):
        for j in range(symk.nkpt):
            line = "{:20.10f}{:20.10f}\n".format(symk.klen[j], eigval[j,i])
            f.write(line)
        f.write("\n\n")

# 3.2 output.ovlp and output.enk
# 3.2.1 define a uniform k-grid
print(">>> build hk for uniform grid")
unik = UniKVec([11,11,11])
unik.from_grid()
hk_uni = fourier_hr2hk(num_orb, unik.nkpt, unik.kvec, hr.nrpt, hr.rpts, hr.deg_rpt, hr_mat)

# 3.2.2 diagonalize
print("diagonalize ...")
eigval2    = np.zeros((unik.nkpt, num_orb),dtype=np.float64)
eigvec2    = np.zeros((unik.nkpt, num_orb, num_orb),dtype=np.complex128)
eigvec_imp = np.zeros((unik.nkpt, num_atom[1]*orb[1], num_orb),dtype=np.complex128)
for i in range(unik.nkpt):
    eigval2[i,:], eigvec2[i,:,:] = eigh(hk_uni[i,:,:])

# 3.2.3 prepare output.ovlp for impurity
print("dumping into output.ovlp&output.enk ...")
for k in range(unik.nkpt):
    for j in range(num_orb):
        for i in range(num_atom[0]*orb[0],num_atom[0]*orb[0]+num_atom[1]*orb[1]):
            eigvec_imp[k,i-num_atom[0]*orb[0],j] = eigvec2[k,i,j] 

write_gw_input(1, 10, 8.462, eigval2, eigvec_imp)   # correlated atoms per sites, correlated orbitals per site, tot. electrons
write_cmplx_matrix1(hr_mat0,fname1)
write_cmplx_matrix1(evec,fname2)
print("congratulations!")
#'''
