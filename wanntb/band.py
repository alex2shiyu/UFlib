#!/usr/bin/env python

import numpy as np
from numpy.linalg import eigh 
from wanntb.kvec import SymKVec
from wanntb.tran import fourier_hr2hk
from wanntb.ham import HR

class band():
    '''
    draw band for HR instance
    '''
    
    def __init__(self,nband,nkpt_pline,hsympkt,Rbase,efermi,hr,hr_mat):
        self.nband = nband
        self.nkpt_pline = nkpt_pline
        self.hsympkt = hsympkt
        self.Rbase = Rbase
        self.efermi = efermi
        self.hr = hr
        self.hr_mat = hr_mat
        self.symk = None
        self.hk_sym = None
        self.nhsympkt = 0
#       self.kbase = None
        self.kbase = np.zeros((3,3),np.float64)
        self.band_vec = None
        self.band_eig = None
    
    def make_kbase(self,phase=True):
        '''
        phase == True, the kbase is as same as the one defined in solid physics
        phase == False, which will lack a phase of <2*pi>
        '''
        print(">>> make k-base ...")
        v = np.dot(np.cross(self.Rbase[0,:],self.Rbase[1,:]),self.Rbase[2,:])
        if phase :
            self.kbase[0,:] = np.cross(self.Rbase[1,:],self.Rbase[2,:]) *2* np.pi /v
            self.kbase[1,:] = np.cross(self.Rbase[2,:],self.Rbase[0,:]) *2* np.pi /v
            self.kbase[2,:] = np.cross(self.Rbase[0,:],self.Rbase[1,:]) *2* np.pi /v
        else:
            self.kbase[0,:] = np.cross(self.Rbase[1,:],self.Rbase[2,:])  /v
            self.kbase[1,:] = np.cross(self.Rbase[2,:],self.Rbase[0,:])  /v
            self.kbase[2,:] = np.cross(self.Rbase[0,:],self.Rbase[1,:])  /v

    def make_symk(self):
        '''
        make quantity of high symmetry line
        '''
        print(">>> make high symmetry line ...")
        self.symk = SymKVec(self.kbase,self.hsympkt)
        self.symk.from_hsymkpt(self.nkpt_pline)
        self.symk.get_klen()
        self.nhsympkt = len(self.hsympkt)

    def make_Hk_band(self):
        '''
        make Hk of band path
        '''
        print(">>> transform H from real to k space ...")
        self.hk_sym = fourier_hr2hk(self.nband,self.symk.nkpt,\
                self.symk.kvec,self.hr.nrpt, self.hr.rpts, \
                self.hr.deg_rpt, self.hr_mat)

    def calculate_band(self):
        print(">>> calculate band structure ...")
        eigval = np.zeros((self.symk.nkpt,self.nband),dtype=np.float64)
        eigvec = np.zeros((self.symk.nkpt,self.nband,self.nband),dtype=np.complex128)
        for i in range(self.symk.nkpt):
            eigval[i,:], eigvec[i,:,:] = eigh(self.hk_sym[i,:,:])
        self.band_vec = eigvec
        self.band_eig = eigval

    def dump_band(self,bandfile='wann.band.dat'):
        print(">>> dump ",bandfile," ...")
        with open(bandfile,'w') as f:
            line = "{:20.10f}{:20.10f}\n".format(self.symk.klen[0],0.0)
            f.write(line)
            line = "{:20.10f}{:20.10f}\n".format(self.symk.klen[-1],0.0)
            f.write(line)
            f.write("\n\n")
            for i in range(self.nband):
                for j in range(self.symk.nkpt):
                    line = "{:20.10f}{:20.10f}\n".format(self.symk.klen[j],self.band_eig[j,i]- self.efermi)
                    f.write(line)
                f.write("\n\n")

    def band_plot(self,bandfile='wann.band.dat'):
        self.make_kbase(False)
        self.make_symk()
        self.make_Hk_band()
        self.calculate_band()
        self.dump_band(bandfile)

