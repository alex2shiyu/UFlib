#!/usr/bin/env python

import numpy as np
import progressbar as pbar

def get_akw_mpi(hk, sgm, udc, fmesh, mu, is_mpi=False, comm=None):
    """
    Given a LDA TB Hamiltonian and the self-energy on real frequency, calculate the A(k,w).

    Parameters
    ----------
    hk : 3-dimensional (nkpt,nwann,nwann) array 
         the LDA TB Hamiltonian
    sgm : 3-dimensional (nfreq, norbs, norbs) array
         the self-energy on real frequency
    udc : 2-dimensional (norbs, norbs) array
         the double counting term
    fmesh : 1-dimensional (nfreq) array
         the real frequency mesh grid
    mu : scalar
         the chemical potential
    is_mpi : logical
         whether to use MPI
    comm : the MPI commuication world
    

    Returns
    -------
    akw : 2-dimensional (nkpt, nfreq) array
          the calculate k-resolved spectral function
    rhow: 2-dimensional (nwan, nfreq) array
          the k-interated spectral function
  
    """
    if is_mpi:
        rank, size = comm.Get_rank(), comm.Get_size()
    else:
        rank, size = 0, 1

    nkpt, nwann, _ = hk.shape
    nfreq, norbs, _ = sgm.shape 
    
    sgm2 = np.zeros((nfreq,nwann,nwann), dtype=np.complex128)
    for i in range(nfreq):
        sgm2[i,0:norbs,0:norbs] = sgm[i,:,:] - udc

    unity = np.eye(nwann,dtype=np.float64)
    akw = np.zeros((nkpt,nfreq), dtype=np.float64)
    rhow = np.zeros((nfreq,nwann), dtype=np.float64)

    # build lattice Green's function
    if  rank==0:
        print("Build lattice Green's function ...")
        progress = pbar.ProgressBar(widgets=[pbar.Percentage(), pbar.Bar()], maxval=nfreq).start()
    for ifreq in range(rank,nfreq,size):
        for ikpt in range(nkpt):
            green = (fmesh[ifreq] + mu) * unity - (hk[ikpt,:,:] + sgm2[ifreq,:,:])
            green = np.linalg.inv(green)
            akw[ikpt,ifreq] = np.trace(-green.imag/np.pi)
            rhow[ifreq,:] = rhow[ifreq,:] + np.diagonal(-green.imag/np.pi)
        if rank==0:
            progress.update(ifreq)
        rhow[ifreq,:] = rhow[ifreq,:]/np.float64(nkpt)

    if rank==0: 
        progress.finish()

    if is_mpi:
        akw, rhow = comm.allreduce(akw), comm.allreduce(rhow)

    return akw, rhow

def get_akw(hk, sgm, udc, fmesh, mu):
    """
    Given a LDA TB Hamiltonian and the self-energy on real frequency, calculate the A(k,w).

    Parameters
    ----------
    hk : 3-dimensional (nkpt,nwann,nwann) array 
         the LDA TB Hamiltonian
    sgm : 3-dimensional (nfreq, norbs, norbs) array
         the self-energy on real frequency
    udc : 2-dimensional (norbs, norbs) array
         the double counting term
    fmesh : 1-dimensional (nfreq) array
         the real frequency mesh grid
    mu : scalar
         the chemical potential
    

    Returns
    -------
    akw : 2-dimensional (nkpt, nfreq) array
          the calculate k-resolved spectral function
    rhow: 2-dimensional (nwan, nfreq) array
          the k-interated spectral function
  
    """
    nkpt, nwann, _ = hk.shape
    nfreq, norbs, _ = sgm.shape 
    
    sgm2 = np.zeros((nfreq,nwann,nwann), dtype=np.complex128)
    for i in range(nfreq):
        sgm2[i,0:norbs,0:norbs] = sgm[i,:,:] - udc

    unity = np.eye(nwann,dtype=np.float64)
    akw = np.zeros((nkpt,nfreq), dtype=np.float64)
    rhow = np.zeros((nfreq,nwann), dtype=np.float64)

    # build lattice Green's function
    print("Build lattice Green's function ...")
    progress = pbar.ProgressBar(widgets=[pbar.Percentage(), pbar.Bar()], maxval=nfreq).start()
    for ifreq in range(nfreq):
        for ikpt in range(nkpt):
            green = (fmesh[ifreq] + mu) * unity - (hk[ikpt,:,:] + sgm2[ifreq,:,:])
            green = np.linalg.inv(green)
            akw[ikpt,ifreq] = np.trace(-green.imag/np.pi)
            rhow[ifreq,:] = rhow[ifreq,:] + np.diagonal(-green.imag/np.pi)
        progress.update(ifreq)
        rhow[ifreq,:] = rhow[ifreq,:]/np.float64(nkpt)

    progress.finish()
    
    return akw, rhow
