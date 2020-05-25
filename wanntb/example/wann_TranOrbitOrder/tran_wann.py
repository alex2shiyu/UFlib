#! /usr/bin/env python

import numpy as np
from wanntb.ham import HR
from wanntb.tran import tranorder

# comment
# UTe2's orbital type:
# U1:f,d
# U2:f,d
# Te1:p
# Te2:p
# Te3:p
# Te4:p
# order of quantum espresso : udududud
# this material : f(U1,udud),f(U2,udud),d(U1,udud),d(U2,udud),p(Te1,udud),p(Te2,udud),p(Te3,udud),p(Te4,udud)
# however, the Wannier_Hamiltonian_symmetrization need orbitals which belong to a same atom should be put togeter, also
# the spin order should be uuuddd,
hr = HR.from_file('UTe2_soc_qe_hr.dat')
hr_mat = hr.get_hr(0)
orb = []
for i in range(14):
    orb.append(i+1)
for i in range(14):
    orb.append(i+10+1+14)
for i in range(10):
    orb.append(i+14+1)
for i in range(10):
    orb.append(i+1+14+14+10)
for i in range(24):
    orb.append(48+i+1)
print('orb=\n',orb)
orb = np.array(orb)
hr.hr = hr.transpin_hr(orb=orb)
# if you use ispin=2 be sure the input hamiltonian whose spin order is ududud
hr_mat_uuuddd = hr.transpin_hr(ispin=2)
#hr_mat_fdfd = tranorder(hr_mat,orb)
#hr_mat_uuuddd=tranorder(hr_mat_fdfd,ispin=2)
#hr_mat_uuuddd = hr.transpin_hr(hr_mat_fdfd,ispin=2,file_hr = 'UTe2_uudd_fdfd_hr.dat',comment='qe(udud,ffdd) to (uudd,fdfd)')
hr.dump_hr(hr_mat_uuuddd,file_hr='UTe2_uudd_fdfd_hr.dat',comment='modified by wanntb library')

