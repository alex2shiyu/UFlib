#!/usr/bin/env python

import numpy as np
import wanntb.rotate as rot

z1 = [0.746333691, 0.063953786, 1.795031188]
x1 = [1.410110410, 1.233568200, -0.630242020]

z2 = [0.746333681, -0.063953786, 1.795031188]
x2 = [1.410110410, -1.233568200, -0.630242020]

rmat1 = rot.zx_to_rmat(z1,x1)
rmat2 = rot.zx_to_rmat(z2,x2)
print(rmat1)
print(rmat2)
print('')

alpha1,beta1,gamma1 = rot.rmat_to_euler(rmat1)
alpha2,beta2,gamma2 = rot.rmat_to_euler(rmat2)
print(alpha1, beta1, gamma1)
print(alpha2, beta2, gamma2)
print('')

rmat11 = rot.euler_to_rmat(alpha1,beta1,gamma1)
rmat22 = rot.euler_to_rmat(alpha2,beta2,gamma2)
print(rmat11)
print(rmat22)
print('')

dmat1 = rot.dmat_spinor(alpha1,beta1,gamma1)
dmat2 = rot.dmat_spinor(alpha2,beta2,gamma2)
print(dmat1)
print(dmat2)
print('')

