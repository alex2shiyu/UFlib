#!/usr/bin/env python

from wanntb.akw import get_akw
import numpy as np

if __name__ == '__main__':
    nkpt = 200
    nfreq = 4001
    nwann = 24
    norbs = 24
    mu =-4.21230616
   
    hk = np.zeros((nkpt,nwann,nwann),dtype=np.complex128)
    sgm = np.zeros((nfreq,norbs,norbs),dtype=np.complex128)
    udc = np.zeros((norbs,norbs),dtype=np.complex128)
    fmesh = np.zeros(nfreq,dtype=np.float64)

    print("Reading lda.hamk.dat...")
    with open('lda.hamk.sym.dat', 'r') as f:
        f.readline()
        for i in range(nkpt):
            for j in range(nwann):
                for k in range(nwann):
                    line=f.readline().strip().split() 
                    hk[i,j,k] = float(line[3]) + 1j * float(line[4])

    print("Done !")
    print("Reading dmft.smat.in...")
    with open('dmft.smat.in', 'r') as f:
        for i in range(norbs):
            for j in range(nfreq):
                line=f.readline().strip().split()
                fmesh[j], sgm[j,i,i] = float(line[1]), float(line[2]) + 1j * float(line[3])  
            # skip two lines
            f.readline()
            f.readline()

    akw,rhow = get_akw(hk,sgm,udc,fmesh,mu)

    print("Dump akw ...")
    with open('akw.dat', 'w') as f:
        for i in range(nkpt):
            for j in range(nfreq):
                line="{:10d}{:20.10f}{:20.10f}\n".format(i+1,fmesh[j],akw[i,j])  
                f.write(line)
