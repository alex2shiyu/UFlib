#!/usr/bin/env python

def write_cmplx_matrix(mat, fname):
    """
    write a complex matrix to file
    
    Parameters
    ----------
    mat:    the matrix to be wrote
    fname:  file name
    """
    m, n = mat.shape
    with open(str(fname), 'w') as f:
        for i in range(n):
            for j in range(m):
                line = "{:10d}{:10d}{:20.16f}{:20.16f}\n".format(j+1,i+1, mat[j,i].real, mat[j,i].imag)    
                f.write(line)


def write_cmplx_matrix1(mat, fname):
    """
    write a complex matrix to file
    
    Parameters
    ----------
    mat:    the matrix to be wrote
    fname:  file name
    """
    m, n = mat.shape
    with open(str(fname), 'w') as f:
        for i in range(n):
            for j in range(m):
                line = "{:5d}{:5d}{:20.16f}{:20.16f}\n".format(j+1,i+1, mat[j,i].real, mat[j,i].imag)    
                f.write(line)

def write_band(klen, eigval, fname):
    """
    write band structure to file
    
    Parameters
    ----------
    klen:      the length of each K-point 
    eigval:    eigenvalues for each K-point and each band
    fname:     file name
    """
    nkpt, norbs = eigval.shape

    with open(str(fname), 'w') as f:
        for i in range(norbs):
            for j in range(nkpt):
                line = "{:20.10f}{:20.10f}\n".format(klen[j], eigval[j,i])
                f.write(line)
            f.write("\n\n")

def write_oldgw_input(natom, ncorr, nelec, eigval, eigvec):
    """
    preapare input files 'output.enk' and 'output.ovlp' for rtgw program
    
    Parameters
    ----------
    natom:    number of correlated atoms
    ncorr:    number of correlated orbitals for each atom
    nelec:    number of total electrons
    """
    
    nkpt, nband = eigval.shape
    
    with open('output.enk', 'w') as f:
        # write headers
        f.write("{:10d}    :number of k-points\n".format(nkpt))
        f.write("{:10d}    :number of bands\n".format(nband))
        f.write("{:10d}    :number of correlated orbitals for each atom\n".format(ncorr))
        f.write("{:10d}    :number of correlated atoms in unit cell\n".format(natom))
        f.write("{:10.5f}    :number of total electrons\n".format(nelec))
        for i in range(nkpt):
            f.write("#ikpt  {:10d}\n".format(i+1))
            for j in range(nband):
                line = "{:10d}{:20.16f}\n".format(j+1, eigval[i,j])    
                f.write(line)
            f.write("\n")

    with open('output.ovlp', 'w') as f:
        #write headers
        f.write("{:10d}    :number of k-points\n".format(nkpt))
        f.write("{:10d}    :number of bands\n".format(nband))
        f.write("{:10d}    :number of correlated orbitals for each atom\n".format(ncorr))
        f.write("{:10d}    :number of correlated atoms in unit cell\n".format(natom))
        f.write("{:10.5f}    :number of total electrons\n".format(nelec))
        for i in range(nkpt):
            f.write("#ikpt  {:10d}\n".format(i+1))
            for j in range(nband):
                for k in range(natom*ncorr):
                    line = "{:10d}{:10d}{:20.16f}{:20.16f}\n".format(j+1, k+1, eigvec[i,k,j].real, eigvec[i,k,j].imag)    
                    f.write(line)
            f.write("\n")

def write_gw_input(natom, ncorr, nelec_band, nelec_ncorr, eigval, eigvec):
    """
    preapare input files 'output.enk' and 'output.ovlp' for rtgw program
    
    Parameters
    ----------
    natom:    number of correlated atoms
    ncorr:    number of correlated orbitals for each atom
    nelec:    number of total electrons
    """
    
    nkpt, nband = eigval.shape
    
    with open('output.enk', 'w') as f:
        #write headers
        f.write("{:10d}    :number of k-points\n".format(nkpt))
        f.write("{:10d}    :number of bands\n".format(nband))
        f.write("{:10d}    :number of correlated orbitals for each atom\n".format(ncorr))
        f.write("{:10d}    :number of correlated atoms in unit cell\n".format(natom))
        f.write("{:10.5f}    :number of total band electrons\n".format(nelec_band))
        f.write("{:10.5f}    :number of total correlated electrons\n".format(nelec_ncorr))
        for i in range(nkpt):
            f.write("#ikpt  {:10d}\n".format(i+1))
            for j in range(nband):
                line = "{:10d}{:20.16f}\n".format(j+1, eigval[i,j])    
                f.write(line)
            f.write("\n")

    with open('output.ovlp', 'w') as f:
        # write headers
        f.write("{:10d}    :number of k-points\n".format(nkpt))
        f.write("{:10d}    :number of bands\n".format(nband))
        f.write("{:10d}    :number of correlated orbitals for each atom\n".format(ncorr))
        f.write("{:10d}    :number of correlated atoms in unit cell\n".format(natom))
        f.write("{:10.5f}    :number of total band electrons\n".format(nelec_band))
        f.write("{:10.5f}    :number of total correlated electrons\n".format(nelec_ncorr))
        for i in range(nkpt):
            f.write("#ikpt  {:10d}\n".format(i+1))
            for j in range(nband):
                for k in range(natom*ncorr):
                    line = "{:10d}{:10d}{:20.16f}{:20.16f}\n".format(k+1,j+1, eigvec[i,k,j].real, eigvec[i,k,j].imag)    
                    f.write(line)
            f.write("\n")

def write_mag_gw_input(natom, ncorr, nelec, Ham):
    """
    preapare input files 'output.hk' instead of 'output.enk' and 'output.ovlp' for rtgw program
    
    Parameters
    ----------
    natom:    number of correlated atoms
    ncorr:    number of correlated orbitals for each atom
    nelec:    number of total electrons
    """
    
    nkpt, nband, n = Ham.shape

    with open('output.hk', 'w') as f:
        # write headers
        f.write("{:10d}    :number of k-points\n".format(nkpt))
        f.write("{:10d}    :number of bands\n".format(nband))
        f.write("{:10d}    :number of correlated orbitals for each atom\n".format(ncorr))
        f.write("{:10d}    :number of correlated atoms in unit cell\n".format(natom))
        f.write("{:10.5f}    :number of total electrons\n".format(nelec))
        for i in range(nkpt):
            f.write("#ikpt  {:10d}\n".format(i+1))
            for j in range(natom*ncorr):
                for k in range(natom*ncorr):
                    line = "{:10d}{:10d}{:20.16f}{:20.16f}\n".format(k+1,j+1, Ham[i,k,j].real, Ham[i,k,j].imag)    
                    f.write(line)
            f.write("\n")

