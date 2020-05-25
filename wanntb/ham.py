#!/usr/bin/env python
#read on 04/15/2018

import numpy as np
from numpy.linalg import eigh
from wanntb.tran import fourier_hr2hk, tran_op

class HR():
    """ 
    The Wannier tight-binding (TB) Hamiltonian in real space.

    """

   # def __init__(self, nwann, nrpt, irpt0, rpts, deg_rpt, hr):
    def __init__(self, nwann, nrpt, irpt0, rpts, deg_rpt, rpts_d, hr):
        self.nwann=nwann
        self.nrpt = nrpt
        self.irpt0 = irpt0 
        self.deg_rpt = deg_rpt
        self.rpts = rpts
        self.rpts_d = rpts_d
        self.hr = hr
        
    @staticmethod
    def from_file(fname='wannier90_hr.dat'):

        """
        Generate a TB Hamiltonian from Wannier90 output file "case_hr.dat".

        Args:
            fname (string): the file that contains the Wannier90 output file 
            "case_hr.dat"
        """

        try: 
            with open(fname, 'r') as f:
                # skip the header (1 line)
                f.readline()
                nwann = int(f.readline().strip()) 
                nrpt = int(f.readline().strip())
                rpts_d = np.zeros((50,50,50),dtype=np.int)
                # the degeneracy of R points
                if int(nrpt/15)*15 == nrpt:
                    nline = int(nrpt/15)
                else:
                    nline = int(nrpt/15)+1 #nline = nrpt/15 + 1
                tmp = []
                for i in range(nline):
                    tmp.extend(f.readline().strip().split())   
                tmp = [np.int(item) for item in tmp]
                deg_rpt = np.array(tmp, dtype=np.int)
                # read hr for each r-point
                rpts = np.zeros((nrpt,3), dtype=np.int) 
                hr = np.zeros((nrpt, nwann, nwann), dtype=np.complex128)
                for i in range(nrpt):
                    for j in range(nwann):
                        for k in range(nwann):
                            rx, ry, rz, hr_i, hr_j, hr_real, hr_imag = f.readline().strip().split() 
                            rpts[i,:] = int(rx), int(ry), int(rz)
                            rpts_d[int(rx)+25,int(ry)+25,int(rz)+25]=deg_rpt[i] 
                            if int(rx) == 0 and int(ry) == 0 and int(rz) == 0:
                                irpt0 = i
                            tmpx=int(hr_i)-1
                            tmpy=int(hr_j)-1
                            hr[i,tmpx,tmpy] = np.float64(hr_real) + np.float64(hr_imag) * 1j
                # construct the HR instance
                return HR(nwann, nrpt, irpt0, rpts, deg_rpt, rpts_d, hr)

        except IOError:
            print("File:" + "\"" + fname + "\"" +  " doesn't exist!")

    @staticmethod
    def copy_hr(other):

        """
        copy instance of HR
        """

        return HR( other.nwann, 
                   other.nrpt, 
                   other.irpt0, 
                   np.copy(other.rpts), 
                   np.copy(other.deg_rpt), 
                   np.copy(other.hr) )

    def get_hr0(self, ispin=False):
    
        """
        return the on-site term 
        """

        if ispin:
            norbs = 2 * self.nwann
            hr0_spin = np.zeros((norbs, norbs), dtype=np.complex128) 
            hr0_spin[0:norbs:2, 0:norbs:2] = self.hr[self.irpt0,:,:]
            hr0_spin[1:norbs:2, 1:norbs:2] = self.hr[self.irpt0,:,:]
            return hr0_spin
        else:
            return self.hr[self.irpt0,:,:],self.irpt0
 
    def get_hr(self, ispin):
        
        """
        return hr
        """

        # with spin, spin order: up dn up dn up dn
        if ispin==1:
            norbs = 2 * self.nwann 
            hr_spin = np.zeros((self.nrpt, norbs, norbs), dtype=np.complex128)
            hr_spin[:, 0:norbs:2, 0:norbs:2] = self.hr
            hr_spin[:, 1:norbs:2, 1:norbs:2] = self.hr
            return hr_spin
        # with spin, spin order: up up up dn dn dn
        elif ispin==2:
            norbs = 2 * self.nwann 
            hr_spin = np.zeros((self.nrpt, norbs, norbs), dtype=np.complex128)
            hr_spin[:, 0:self.nwann, 0:self.nwann] = self.hr
            hr_spin[:, self.nwann:norbs, self.nwann:norbs] = self.hr
            return hr_spin
        # without spin
        else:
            return self.hr[:,:,:]

    def transpin_hr(self,ispin=None,orb=np.array(None)):
        '''
        return hr with assigned spin order
        ispin = 1, up dn up dn up dn : be sure the input is "up up up dn dn dn"
        ispin = 2, up up up dn dn dn : be sure the input is "up dn up dn up dn"
        orb = np.array([1,3,5,2,4,6]) means atom 1 -> atom 1; 2->3;3->5;..., which is the equivlent way for "ispin=1 orb=None"
        '''
        l,m,n = self.hr.shape
        umat = np.zeros((m,n),dtype=np.float64)
        hr_new = np.zeros((l,m,n),dtype=np.complex128)
        if orb.all()==None:
            if ispin==1:
                for i in range(int(m/2)):
                    umat[i,2*i] = 1
                    umat[i+int(m/2),2*i+1] = 1
            elif ispin==2:
                for i in range(int(m/2)):
                    umat[2*i,i] = 1
                    umat[2*i+1,i+int(m/2)] = 1
            else :
                for i in range(m):
                    umat[i,i] = 1
        else:
            for i in range(m):
                umat[i,int(orb[i])-1] = 1
        for i in range(l):
            hr_new[i,:,:] = tran_op(self.hr[i,:,:],umat)
        return hr_new

    def dump_hr(self,hr_mat=np.array(None),ispin = None,file_hr="wannier_hr_new.dat",comment='new wannier'):
        '''
        aim : dump modified hr_mat to wannier format output with the property of HR
        if hr_mat is absent, the ispin will be used to get hr_mat of instance of HR
        comment : is the first line of output file same as wannier90_hr.dat file
        file_hr : the name of output file
        '''
        if hr_mat.all() == None :
            hr_mat = self.get_hr(ispin)
        num_orb = hr_mat.shape[1] 
        with open(file_hr,'w') as f:
            f.write(comment + '\n')
            line = "{:10d}\n".format(num_orb)
            f.write(line)
            line = "{:10d}\n".format(self.nrpt)
            f.write(line)
            nline = self.nrpt//15
            nleft = self.nrpt - nline * 15
            for i in range(nline):
                ibase = (i-1)*15
                for j in range(15):
                    line="{:5d}".format(self.deg_rpt[ibase + j])
                    f.write(line)
                f.write("\n")
            if nleft > 0 :
                for j in range(nleft):
                    line="{:5d}".format(self.deg_rpt[nline*15 + j])
                    f.write(line)
                f.write("\n")
            for i in range(self.nrpt):
                for j in range(num_orb):
                    for k in range(num_orb):
                        line="{:5d}{:5d}{:5d}{:5d}{:5d}{:20.10f}{:20.10f}\n".format(self.rpts[i,0],self.rpts[i,1],self.rpts[i,2],k+1,j+1,hr_mat[i,k,j].real,hr_mat[i,k,j].imag)
                        f.write(line)








