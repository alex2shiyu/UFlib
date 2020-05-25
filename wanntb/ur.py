#!/usr/bin/env python

import sys
import numpy as np
# get rotation matrix
#AA = np.array([[2.859327,0,4.667933],[-1.4296636,2.47625,4.667933],[-1.4296636,-2.47625,4.667933]],dtype=np.float64)
AA=np.array([[5.3842239380, 0.0000000000, 0.0000000000],[2.6370573554, 4.6942300667, 0.0000000000],[2.6370573554, 1.5432639091, 4.4332981431]])
#aa=np.linalg.inv(AA)
AA = np.transpose(AA)
AA_INV=np.linalg.inv(AA)
R1to2=np.array([[-1,0,0],[0,0,-1],[0,-1,0]],dtype=np.float64)
#R1to3=np.array([[1,0,0],[0,0,1],[0,1,0]],dtype=np.float64)
#R1to3=np.array([[0,0,1],[0,1,0],[1,0,0]],dtype=np.float64)
R1to3=np.array([[0,0,-1],[0,-1,0],[0,0,-1]],dtype=np.float64)
R1to4=np.array([[0,-1,0],[-1,0,0],[0,0,-1]],dtype=np.float64)
rot1to2=np.dot(AA,np.dot(R1to2,AA_INV))
rot1to3=np.dot(AA,np.dot(R1to3,AA_INV))
rot1to4=np.dot(AA,np.dot(R1to4,AA_INV))

#Z1=np.array([[-0.075438,-1.397510,-0.989602]])
Z1=np.array([[0.0,0.0,-1.0]])
X1=np.array([[-0.70710678,0.70710678,0.0]])
#X1=np.array([[-1.172553, 0.764032,-0.989602]])

Z1=np.transpose(Z1)
X1=np.transpose(X1)

Z2=np.dot(rot1to2,Z1)
X2=np.dot(rot1to2,X1)

Z3=np.dot(rot1to3,Z1)
X3=np.dot(rot1to3,X1)

Z4=np.dot(rot1to4,Z1)
X4=np.dot(rot1to4,X1)

print("Z1", np.transpose(Z1))
print("X1", np.transpose(X1))
print("Z2", np.transpose(Z2))
print("X2", np.transpose(X2))
print("Z3", np.transpose(Z3))
print("X3", np.transpose(X3))

print("Z4", np.transpose(Z4))
print("X4", np.transpose(X4))
