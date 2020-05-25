#!/usr/bin/env python

import numpy as np
from wanntb import rotate

alpha = -np.arcsin(np.sqrt(5.0)/5.0)
beta  =  np.arcsin(np.sqrt(5.0)/3.0)
gamma =  np.arcsin(2.0*np.sqrt(5.0)/5.0) 

print(alpha, beta, gamma)

rmat = rotate.euler_to_rmat(alpha,beta,gamma) 

alpha2, beta2, gamma2 = rotate.rmat_to_euler(rmat)

print(alpha2, beta2, gamma2)

a1=np.sqrt(3.0)/2.0
a2=np.sqrt(3.0)/6.0
dmat1 = [[a1-a2*1j, -a2-a2*1j],
         [a2-a2*1j, a1+a2*1j ]]
dmat1 = np.array(dmat1, dtype=np.complex128)

print(dmat1)

dmat2 = rotate.dmat_spinor(alpha2,beta2,gamma2)

print(dmat2)

dmat3 = rotate.dmat_spinor(alpha,beta,gamma)

print(dmat3)

#alpha =  np.arccos(-2.0*np.sqrt(5.0)/5.0)
#beta  =  np.arcsin(np.sqrt(5.0)/3.0)
#gamma =  np.arcsin(2.0*np.sqrt(5.0)/5.0) 
#
#print rotate.euler_to_rmat(alpha,beta,gamma)
#
#alpha =  np.arcsin(np.sqrt(5.0)/5.0)
#beta  =  np.arccos(-2.0/3.0)
#gamma =  np.pi - np.arcsin(-2.0*np.sqrt(5.0)/5.0) 
#
#print rotate.euler_to_rmat(alpha,beta,gamma)
