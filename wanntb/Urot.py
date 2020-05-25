#!/usr/bin/env python

import sys
import numpy as np
from numpy.linalg import inv
#from wanntb.tran import tran_op
#this prog if for wannier projecting
a=[[4.1026463509,         0.0000000000,         0.0000000000],
   [2.0513231754,         3.5529959626,         0.0000000000],
   [2.0513231754,         1.1843319875,         3.3497967182]]
T=np.transpose(a)
T_inv=inv(T)
U=[[-1,0,0],[0,-1,0],[0,0,-1]]
U_tr=np.dot(np.dot(T,U),T_inv)
z=[0.0,
0.0,
1.0]
x=[1.0,
0.0,
0.0]
xd=np.dot(U_tr,x)
zd=np.dot(U_tr,z)
#print 'U',U_tr
print('xd',xd)
print('zd',zd)

