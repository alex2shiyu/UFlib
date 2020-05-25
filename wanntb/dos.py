import numpy as np

def get_dos(eigval, eigvec, emin=None, emax=None, nedos=200, sigma=0.01):
    nkpt, nband = eigval.shape
    if emin is None or emax is None or emax < emin:
        emin, emax = np.min(eigval), np.max(eigval) 

    # build energy grid
    emesh = np.linspace(emin, emax, nedos) 
    step = (emax-emin)/np.float64(nedos-1)

    # partial dos
    pdos = np.zeros((nband,nedos), dtype=np.float64)

    for ik in range(nkpt):
        for ib in range(nband):
            e1, e2 = eigval[ik,ib]-6.0*sigma, eigval[ik,ib]+6.0*sigma
            if e1 < emin:
                e1 = emin
            if e2 > emax:
                e2 = emax
            indx1, indx2 = int((e1-emin)/step), int((e2-emin)/step) 
            for ie in range(indx1,indx2):
                pdos[:,ie] = pdos[:,ie] + np.exp( -(eigval[ik,ib]-emesh[ie])**2 / (2.0*sigma**2) ) * np.abs(eigvec[ik,:,ib])**2 

    pdos = pdos / (step * nkpt * np.sqrt(2.0*np.pi) * sigma)
    # the total dos
    tdos = np.sum(pdos, axis=0)

    return emesh, pdos, tdos
