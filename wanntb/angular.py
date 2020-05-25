#!/usr/bin/env python

import numpy as np

def get_ladd(l,ispin=False):
    """
    Get the matrix form of l+ in the complex shperical harmonics basis
    l+|l,m> = sqrt((j-m)(j+m+1)) |j,m+1>

    Parameters
    ----------
    l:         orbital angular momentum number
    ispin:     including spin (default: False)

    Returns
    ----------
    matrix of ladd
    """

    norbs = 2 * l + 1
    ladd = np.zeros((norbs,norbs), dtype=np.complex128) 
    cone = np.complex128(1.0+0.0j)
    for m in range(-l,l):
        ladd[l+m+1,l+m] = np.sqrt((l - m) * (l + m + 1.0) * cone)
    if ispin:
        ladd_spin = np.zeros((2*norbs,2*norbs), dtype=np.complex128)
        ladd_spin[0:2*norbs:2, 0:2*norbs:2] = ladd
        ladd_spin[1:2*norbs:2, 1:2*norbs:2] = ladd
        return ladd_spin
    else:
        return ladd

def get_lminus(l,ispin=False):
    """
    Get the matrix form of l- in the complex shperical harmonics basis
    l+|l,m> = sqrt((j+m)(j-m+1)) |j,m+1>

    Parameters
    ----------
    l:         orbital angular momentum number
    ispin:     including spin (default: False)

    Returns
    ----------
    matrix of lminus
    """

    norbs = 2 * l + 1
    lminus = np.zeros((norbs,norbs), dtype=np.complex128) 
    cone = np.complex128(1.0+0.0j)
    for m in range(-l+1,l+1):
        lminus[l+m-1,l+m] = np.sqrt((l + m) * (l - m + 1.0) * cone)
    if ispin:
        lminus_spin = np.zeros((2*norbs,2*norbs), dtype=np.complex128)
        lminus_spin[0:2*norbs:2, 0:2*norbs:2] = lminus
        lminus_spin[1:2*norbs:2, 1:2*norbs:2] = lminus
        return lminus_spin
    else:
        return lminus

def get_lx(l,ispin=False):
    """
    Get the matrix form of lx in the complex shperical harmonics basis
    lx = (l+ + l-)/2 

    Parameters
    ----------
    l:         orbital angular momentum number
    ispin:     including spin (default: False)

    Returns
    ----------
    matrix of lx
    """

    if ispin:
        return (get_ladd(l,True) + get_lminus(l,True)) / 2.0
    else:
        return (get_ladd(l) + get_lminus(l)) / 2.0

def get_ly(l,ispin=False):
    """
    Get the matrix form of lx in the complex shperical harmonics basis
    ly = -i/2 * (l+ - l-) 

    Parameters
    ----------
    l:         orbital angular momentum number
    ispin:     including spin (default: False)

    Returns
    ----------
    matrix of ly
    """

    if ispin:
        return (get_ladd(l,True) - get_lminus(l,True)) / 2.0 * -1j
    else:
        return (get_ladd(l) - get_lminus(l)) / 2.0 * -1j
  
def get_lz(l,ispin=False):
    """
    Get the matrix form of lz in the complex shperical harmonics basis

    Parameters
    ----------
    l:         orbital angular momentum number
    ispin:     including spin (default: False)

    Returns
    ----------
    matrix of lz
    """

    norbs = 2 * l + 1
    lz = np.zeros((norbs,norbs),dtype=np.complex128)
    for m in range(-l,l+1):
        lz[l+m,l+m] = m

    if ispin:
        lz_spin = np.zeros((2*norbs,2*norbs),dtype=np.complex128)
        lz_spin[0:2*norbs:2,0:2*norbs:2] = lz
        lz_spin[1:2*norbs:2,1:2*norbs:2] = lz
        return lz_spin
    else:
        return lz 

def get_pauli():
    """
    Return the pauli matrix
    """
    sigma = np.zeros((4,2,2),dtype=np.complex128)
    sigma[0,0,1] =  1.0
    sigma[0,1,0] =  1.0
    sigma[1,0,1] = -1.0j
    sigma[1,1,0] =  1.0j
    sigma[2,0,0] =  1.0
    sigma[2,1,1] = -1.0
    sigma[3,0,0] =  1.0
    sigma[3,1,1] =  1.0

    return sigma

def get_sx(l):
    """
    Get the matrix form of sx in the complex shperical harmonics basis

    Parameters
    ----------
    l:         orbital angular momentum number

    Returns
    ----------
    matrix of sx
    """
   
    norbs = 2 * (2 * l + 1)
    sx = np.zeros((norbs, norbs),dtype=np.complex128) 
    sigma = get_pauli()
    for i in range(2*l+1):
        sx[2*i:2*i+2,2*i:2*i+2] = sigma[0,:,:]/2.0

    return sx

def get_sy(l):
    """
    Get the matrix form of sy in the complex shperical harmonics basis

    Parameters
    ----------
    l:         orbital angular momentum number

    Returns
    ----------
    matrix of sy
    """
   
    norbs = 2 * (2 * l + 1)
    sy = np.zeros((norbs, norbs),dtype=np.complex128) 
    sigma = get_pauli()
    for i in range(2*l+1):
        sy[2*i:2*i+2,2*i:2*i+2] = sigma[1,:,:]/2.0

    return sy

def get_sz(l):
    """
    Get the matrix form of sz in the complex shperical harmonics basis

    Parameters
    ----------
    l:         orbital angular momentum number

    Returns
    ----------
    matrix of sz
    """
   
    norbs = 2 * (2 * l + 1)
    sz = np.zeros((norbs, norbs),dtype=np.complex128) 
    sigma = get_pauli()
    for i in range(2*l+1):
        sz[2*i:2*i+2,2*i:2*i+2] = sigma[2,:,:]/2.0

    return sz
