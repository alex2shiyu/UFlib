#!/usr/bin/env python

import numpy as np
import progressbar as pbar
#from mpi4py import MPI
def tran_unitary(op, tmat,transpose=False):

    """
    transform unitary transform operator from representation A to 
    another representation B
    
    Args:
        op:   the matrix form of unitary operator in representation A
        tmat: the unitary transform matrix
        tranpose : if op already transform in columns, set it False which is the default
                   if transfrom in rows, set it True. see <note>
        
        <note> : should all transform in columns
    """
    if transpose :
        if isinstance(op,np.ndarray) : 
            op_list = np.transpose(op)
        elif isinstance(op,list):
            op_list = []
            for iop in op:
                op_list.append(np.transpose(iop))
    else :
        op_list = copy.deepcopy(op)

    if isinstance(op_list,np.ndarray) and isinstance(tmat,np.ndarray):
        return np.dot(op_list,tmat)
    elif isinstance(op_list,list) and isinstance(tmat,np.ndarray):
        aim = []
        for ik in range(len(op_list)):
            if isinstance(op_list[ik],np.ndarray):
                mat = np.dot(op_list[ik],tmat)
                aim.append(mat)
            else:
                raise IOError('ERROR: the element in list should be numpy.ndarray!')
        return aim
    elif isinstance(op_list,list) and isinstance(tmat,list):
        aim = []
        if len(op_list) == len(tmat):
            for ik in range(len(op_list)):
                if isinstance(op_list[ik],np.ndarray) and isinstance(tmat[ik],np.ndarray):
                    mat = np.dot(op_list[ik],tmat[ik])
                    aim.append(mat)
                else:
                    raise IOError('ERROR: the element in list should be numpy.ndarray!')
            return aim
        else:
            raise IOError('ERROR: op and tmat are both list but they have different length!')
    elif isinstance(op_list,np.ndarray) and isinstance(tmat,list):
        aim = []
        for ik in range(len(tmat)):
            if isinstance(tmat[ik],np.ndarray):
                mat = np.dot(op_list,tmat[ik])
                aim.append(mat)
            else:
                raise IOError('ERROR: the element in list should be numpy.ndarray!')
        return aim
    else:
        raise IOError('ERROR: the type of <op> and <tmat> can only be numpy.ndarray or list of numpy.ndarray!')



#from mpi4py import MPI
def tran_op(op, tmat):

    """
    transform quantum operator from representation A to 
    another representation B
    
    Args:
        op:   the matrix form of operator in representation A
        tmat: the unitary transform matrix
    """
    if isinstance(op,np.ndarray) and isinstance(tmat,np.ndarray):
        return np.dot(np.dot(np.conj(np.transpose(tmat)), op), tmat)
    elif isinstance(op,list) and isinstance(tmat,np.ndarray):
        aim = []
        for ik in range(len(op)):
            if isinstance(op[ik],np.ndarray):
                mat = np.dot(np.dot(np.conj(np.transpose(tmat)), op[ik]),tmat)
                aim.append(mat)
            else:
                raise IOError('ERROR: the element in list should be numpy.ndarray!')
        return aim
    elif isinstance(op,list) and isinstance(tmat,list):
        aim = []
        if len(op) == len(tmat):
            for ik in range(len(op)):
                if isinstance(op[ik],np.ndarray) and isinstance(tmat[ik],np.ndarray):
                    mat = np.dot(np.dot(np.conj(np.transpose(tmat[ik])), op[ik]),tmat[ik])
                    aim.append(mat)
                else:
                    raise IOError('ERROR: the element in list should be numpy.ndarray!')
            return aim
        else:
            raise IOError('ERROR: op and tmat are both list but they have different length!')
    elif isinstance(op,np.ndarray) and isinstance(tmat,list):
        aim = []
        for ik in range(len(tmat)):
            if isinstance(tmat[ik],np.ndarray):
                mat = np.dot(np.dot(np.conj(np.transpose(tmat[ik])), op),tmat[ik])
                aim.append(mat)
            else:
                raise IOError('ERROR: the element in list should be numpy.ndarray!')
        return aim
    else:
        raise IOError('ERROR: the type of <op> and <tmat> can only be numpy.ndarray or list of numpy.ndarray!')
def tran_op2(op, tmat):

    """
    transform quantum operator from representation A to 
    another representation B
    
    Args:
        op:   the matrix form of operator in representation A
        tmat: the unitary transform matrix
    """

    return np.dot(np.dot(np.conj(np.transpose(tmat)), op), tmat)


def tranorder(mat,ispin=None,orb=np.array(None)):
    '''
    return hr with assigned spin order
    ispin = 1, up dn up dn up dn : be sure the input is "up up up dn dn dn"
    ispin = 2, up up up dn dn dn : be sure the input is "up dn up dn up dn"
    orb = np.array([1,3,5,2,4,6]) means atom 1 -> atom 1; 2->3;3->5;..., which is the equivlent way for "ispin=1 orb=None"
    '''
    m,n = mat.shape
    umat = np.zeros((m,n),dtype=np.float64)
#   mat_new = np.zeros((m,n),dtype=np.complex128)
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
    mat_new = tran_op(mat,umat)
    return mat_new

def tmat_c2r(case, ispin=False):

    """
    the transform matrix from complex shperical harmonics to 
    real spherical harmonics
    
    Args:
        case: label for different systems 
        ispin: whether to include spin or not 
    """
    sqrt2 = np.sqrt(2.0)
    ci    = np.complex128(0.0+1.0j)
    cone  = np.complex128(1.0+0.0j)

    if case.strip() == 'p':
        nband = 3
        t_c2r = np.zeros((nband, nband), dtype=np.complex128)
        # px=1/sqrt(2)( |1,-1> - |1,1> )
        t_c2r[0,0] =  cone/sqrt2
        t_c2r[2,0] = -cone/sqrt2
        # py=i/sqrt(2)( |1,-1> + |1,1> )
        t_c2r[0,1] =  ci/sqrt2
        t_c2r[2,1] =  ci/sqrt2
        # pz=|1,0>
        t_c2r[1,2] =  cone
    elif case.strip() == 't2g':
        nband = 3
        t_c2r = np.zeros((nband, nband), dtype=np.complex128)
        # dzx --> py=i/sqrt(2)( |1,-1> + |1,1> )
        t_c2r[0,0] =  ci/sqrt2
        t_c2r[2,0] =  ci/sqrt2
        # dzy --> px=1/sqrt(2)( |1,-1> - |1,1> )
        t_c2r[0,1] =  cone/sqrt2
        t_c2r[2,1] = -cone/sqrt2
        # dxy --> pz=|1,0>
        t_c2r[1,2] =  cone
    elif case.strip() == 'd':
        nband = 5
        t_c2r = np.zeros((nband, nband), dtype=np.complex128)
        # dz2=|2,0>
        t_c2r[2,0] =  cone
        # dzx=1/sqrt(2)( |2,-1> - |2,1> )
        t_c2r[1,1] =  cone/sqrt2 
        t_c2r[3,1] = -cone/sqrt2
        # dzy=i/sqrt(2)( |2,-1> + |2,1> )
        t_c2r[1,2] =  ci/sqrt2
        t_c2r[3,2] =  ci/sqrt2
        # dx2-y2=1/sqrt(2)( |2,-2> + |2,2> )
        t_c2r[0,3] =  cone/sqrt2
        t_c2r[4,3] =  cone/sqrt2
        # dxy=i/sqrt(2)( |2,-2> - |2,2> )
        t_c2r[0,4] =  ci/sqrt2
        t_c2r[4,4] = -ci/sqrt2
    elif case.strip() == 'f':
        nband = 7
        t_c2r = np.zeros((nband, nband), dtype=np.complex128)
        # fz3 = |3,0>
        t_c2r[3, 0] =  cone 
        # fxz2 = 1/sqrt(2)( |3,-1> - |3,1> )
        t_c2r[2, 1] =  cone/sqrt2
        t_c2r[4, 1] = -cone/sqrt2
        # fyz2 = i/sqrt(2)( |3,-1> + |3,1> )
        t_c2r[2, 2] =  ci/sqrt2
        t_c2r[4, 2] =  ci/sqrt2
        # fz(x2-y2) = 1/sqrt(2)( |3,-2> + |3,2> )
        t_c2r[1, 3] =  cone/sqrt2
        t_c2r[5, 3] =  cone/sqrt2
        # fxyz = i/sqrt(2)( |3,-2> - |3,2> )
        t_c2r[1, 4] =  ci/sqrt2
        t_c2r[5, 4] = -ci/sqrt2
        # fx(x2-3y2) = 1/sqrt(2) ( |3,-3> - |3,3> )
        t_c2r[0, 5] =  cone/sqrt2
        t_c2r[6, 5] = -cone/sqrt2
        # fy(3x2-y2) = i/sqrt(2) ( |3,-3> + |3,3> )
        t_c2r[0, 6] =  ci/sqrt2
        t_c2r[6, 6] =  ci/sqrt2
    else:
        print("don't support t_c2r for this case: ", case)
        return

    if ispin:
        norbs=2*nband
        t_c2r_spin = np.zeros((norbs,norbs), dtype=np.complex128)
        t_c2r_spin[0:norbs:2,0:norbs:2] = t_c2r      
        t_c2r_spin[1:norbs:2,1:norbs:2] = t_c2r      
        return t_c2r_spin
    else:
        return t_c2r

def tmat_r2c(case, ispin=False):
    
    """
    the transform matrix from real spherical harmonics to
    complex shperical harmonics
    
    Args:
        case: label for different systems
        ispin: whether to include spin or not
    """

    return np.conj(np.transpose(tmat_c2r(case, ispin)))
###########added by yfxu 5.18/13:30
def tmat_c2j(case):

    """
    the transform matrix from complex spherical harmonics(with spin) to
    spin-orbital |J2,jz>
    
    Args:
        case: label for different systems
    """
    sqrt2 = np.sqrt(2.0)
    sqrt3 = np.sqrt(3.0)
    sqrt5 = np.sqrt(5.0)
    sqrt6 = np.sqrt(6.0)
    sqrt7 = np.sqrt(7.0)
    ci    = np.complex128(0.0+1.0j)
    cone  = np.complex128(1.0+0.0j)
#complex order: |-3,up>,|-3,dn>,...,|3,up>,|3,dn> 
#|J2,Jz>order: |5/2,1/2>,|5/2,-1/2>,|5/2,3/2>,|5/2,-3/2>,...,|7/2,1/2>,...,|7/2,-7/2>
    if case.strip() == 'f':
        nband = 14
        t_c2j = np.zeros((nband, nband), dtype=np.complex128)
        t_c2j[6,0] = -sqrt3/sqrt7
        t_c2j[9,0] =  2.0/sqrt7
        t_c2j[4,1] = -2.0/sqrt7
        t_c2j[7,1] =  sqrt3/sqrt7
        t_c2j[8,2] = -sqrt2/sqrt7
        t_c2j[11,2] = sqrt5/sqrt7
        t_c2j[2,3] = -sqrt5/sqrt7
        t_c2j[5,3] = sqrt2/sqrt7
        t_c2j[10,4] = -1.0/sqrt7
        t_c2j[13,4] = sqrt6/sqrt7
        t_c2j[0,5] = -sqrt6/sqrt7
        t_c2j[3,5] = 1.0/sqrt7
        t_c2j[6,6] = 2.0/sqrt7
        t_c2j[9,6] = sqrt3/sqrt7
        t_c2j[4,7] = sqrt3/sqrt7
        t_c2j[7,7] = 2.0/sqrt7
        t_c2j[8,8] = sqrt5/sqrt7
        t_c2j[11,8] = sqrt2/sqrt7
        t_c2j[2,9] = sqrt2/sqrt7
        t_c2j[5,9] = sqrt5/sqrt7
        t_c2j[10,10] = sqrt6/sqrt7
        t_c2j[13,10] = 1.0/sqrt7
        t_c2j[0,11] = 1.0/sqrt7  
        t_c2j[3,11] = sqrt6/sqrt7
        t_c2j[12,12] = 1.0
        t_c2j[1,13] = 1.0
    else:
        print("don't support t_c2j for this case: ", case)
        return
    return t_c2j
################END by yfxu
def tmat_r2cub(ispin=False):
    
    """
    the transform matrix from real spherical harmonics to the cubic
    spherical harmonics, just for f system

    Args:
        ispin: whether to include spin or not
    """

    a = np.sqrt(10.0) / 4.0 + 0.0j
    b = np.sqrt(6.0) / 4.0  + 0.0j
    c = 1.0 + 0.0j

    nband = 7
    t_r2cub = np.zeros((nband,nband), dtype=np.complex128)
    # fx3 = -sqrt(6)/4 fxz2 + sqrt(10)/4 fx(x2-3y2) 
    t_r2cub[1, 0] = -b
    t_r2cub[5, 0] =  a
    # fy3 = -sqrt(6)/4 fyz2 - sqrt(10)/4 fy(3x2-y2) 
    t_r2cub[2, 1] = -b
    t_r2cub[6, 1] = -a
    # fz3 = fz3
    t_r2cub[0, 2] =  c
    # fx(y2-z2) = -sqrt(10)/4 fxz2 - sqrt(6)/4 fx(x2-3y2)
    t_r2cub[1, 3] = -a
    t_r2cub[5, 3] = -b
    # fy(z2-x2) = sqrt(10)/4 fyz2 - sqrt(6)/4 fy(3x2-y2)
    t_r2cub[2, 4] =  a
    t_r2cub[6, 4] = -b
    # fz(x2-y2) = fz(x2-y2)
    t_r2cub[3, 5] =  c
    # fxyz = fxyz
    t_r2cub[4, 6] =  c

    if ispin:
        norbs = 2 * nband
        t_r2cub_spin = np.zeros((norbs, norbs), dtype=np.complex128)
        t_r2cub_spin[0:norbs:2,0:norbs:2] = t_r2cub
        t_r2cub_spin[1:norbs:2,1:norbs:2] = t_r2cub
        return t_r2cub_spin
    else:
        return t_r2cub

def tmat_cub2r(ispin=False):

    """
    the transform matrix from cubic spherical harmonics to
    real spherical harmonics, just for f system

    Args:
        ispin: whether to include spin or not
    """

    return np.conj( np.transpose( tmat_r2cub(ispin) ) )

def fourier_hr2hk(norbs, nkpt, kvec, nrpt, rvec, deg_rpt, hr):

    """
    Fourier transform from R-space to K-space

    Args:
        norbs:   number of orbitals
        nkpt:    number of K-points
        kvec:    fractional coordinate for K-points
        nrpt:    number of R-points
        rvec:    fractional coordinate for R-points
        deg_rpt: the degenerate for each R-point
        hr:      Hamiltonian in R-space

    Return:
        hk:      Hamiltonian in K-space 
    """

    hk = np.zeros((nkpt, norbs, norbs), dtype=np.complex128)
    #with pbar.ProgressBar(maxval=nkpt) as progress:
    for i in range(nkpt):
        for j in range(nrpt):
            coef = -2*np.pi*np.dot(kvec[i,:], rvec[j,:])
            ratio = (np.cos(coef) + np.sin(coef) * 1j) / float(deg_rpt[j])
            hk[i,:,:] = hk[i,:,:] + ratio * hr[j,:,:]
        #progress.update(i)
    return hk

#def fourier_hr2h1k(norbs, kvec, nrpt, rvec, deg_rpt, hr):

#    """
#    Fourier transform from R-space to K-space

 #   Args:
 #       norbs:   number of orbitals
 #       nkpt:    number of K-points
 #       kvec:    fractional coordinate for K-points
 #       nrpt:    number of R-points
 #       rvec:    fractional coordinate for R-points
 #       deg_rpt: the degenerate for each R-point
 #       hr:      Hamiltonian in R-space
#
#    Return:
#        hk:      Hamiltonian in K-space
#    #"""

#    hk = np.zeros((norbs, norbs), dtype=np.complex128)
#    for i in range(nrpt):
#        coef =  2*np.pi*np.dot(kvec, np.float64(rvec[i,:]))
#        ratio = (np.cos(coef) + np.sin(coef) * 1.0j) / np.float64(deg_rpt[i])
#        hk[:,:] = hk[:,:] + ratio * hr[i,:,:]
#    return hk




def fourier_hr2h1k(norbs, kvec, nrpt, rvec, deg_rpt, hr):

    """
    Fourier transform from R-space to K-space

    Args:
        norbs:   number of orbitals
#        nkpt:    number of K-points
        kvec:    fractional coordinate for a certain K-points
        nrpt:    number of R-points
        rvec:    fractional coordinate for R-points
        deg_rpt: the degenerate for each R-point
        hr:      Hamiltonian in R-space

    Return:
        hkk:      Hamiltonian in K-space
    """

    hkk = np.zeros((norbs, norbs), dtype=np.complex128)
    #with pbar.ProgressBar(maxval=nkpt) as progress:
 #   for i in range(nkpt):
    for j in range(nrpt):
        coef = 2*np.pi*np.dot(kvec[:], rvec[j,:])
        ratio = (np.cos(coef) + np.sin(coef) * 1j) / float(deg_rpt[j])
        hkk[:,:] = hkk[:,:] + ratio * hr[j,:,:]
        #progress.update(j)
    return hkk


def fourier_hk2hr(norbs, nkpt, kvec, nrpt, rvec, deg_rpt, hk):

    """
    Fourier transform from K-space to R-space

    Args:
        norbs:   number of orbitals
        nkpt:    number of K-points
        kvec:    fractional coordinate for K-points
        nrpt:    number of R-points
        rvec:    fractional coordinate for R-points
        deg_rpt: the degenerate for each R-point
        hk:      Hamiltonian in K-space

    Return:
        hr:      Hamiltonian in R-space 
    """
    # instance for invoking MPI relatedfunctions  
#   comm = MPI.COMM_WORLD  
#   # the node rank in the whole community  
#   rank = comm.Get_rank()  
#   # the size of the whole community, i.e.,the total number of working nodes in the MPI cluster  
#   size = comm.Get_size() 
    hr = np.zeros((nrpt, norbs, norbs), dtype=np.complex128)
    #with pbar.ProgressBar(maxval=nkpt) as progress:
    for i in range(nrpt):
        for j in range(nkpt):
            coef = 2*np.pi*np.dot(kvec[j,:], rvec[i,:])
            ratio = (np.cos(coef) + np.sin(coef) * 1j) * float(deg_rpt[i])
            hr[i,:,:] = hr[i,:,:] + ratio * hk[j,:,:]
#   hr = comm.allreduce(hr)
#   comm.barrier()
    hr = hr/nkpt
        #progress.update(i)
    return hr
