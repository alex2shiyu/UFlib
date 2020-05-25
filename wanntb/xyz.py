#!/usr/bin/env python

import sys
import numpy as np
from numpy.linalg import inv
z=[-1,1,1]
x=[1,-1,1]
a=[[4.1026463509,         0.0000000000,         0.0000000000],
   [2.0513231754,         3.5529959626,         0.0000000000], 
   [2.0513231754,         1.1843319875,         3.3497967182]]
z1=np.dot(z,a)
x1=np.dot(x,a)

print('z1',z1)
print('x1',x1)
