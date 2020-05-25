#/usr/bin/env python

import numpy as np

def atom_hsoc(case, soc):

    """
    build atomic spin-orbit coupling matrix on complex orbitals

    Args:
        case: the different case
        soc:  the strength of SOC
    """

    sqrt2  = np.sqrt(2.0)
    sqrt6  = np.sqrt(6.0)
    sqrt10 = np.sqrt(10.0)
    sqrt12 = np.sqrt(12.0)
    

    if case.strip() == 'pr':
        hsoc = np.zeros((6, 6), dtype=np.complex128)
        hsoc[3,0] = -1.0
        hsoc[5,0] = -1.0j
        hsoc[2,1] = 1.0
        hsoc[4,1] = -1.0j
        hsoc[1,2] = 1.0
        hsoc[4,2] = 1.0j
        hsoc[0,3] = -1.0
        hsoc[5,3] = -1.0j
        hsoc[1,4] = 1.0j
        hsoc[2,4] = -1.0j
        hsoc[0,5] = 1.0j
        hsoc[3,5] = 1.0j
        return 0.5 * soc * hsoc
    elif case.strip() == 'p':
        hsoc = np.zeros((6, 6), dtype=np.complex128) 
        hsoc[0,0] = -1.0
        hsoc[3,0] = sqrt2
        hsoc[1,1] = 1.0
        hsoc[5,2] = sqrt2 
        hsoc[0,3] = sqrt2 
        hsoc[4,4] = 1.0
        hsoc[2,5] = sqrt2
        hsoc[5,5] = -1.0
        return 0.5 * soc * hsoc

#the order of basis of 't2g'is |1,1,d>,|1,1,u>,|1,0,d>,|1,0,u>...   
    elif case.strip() == 't2g':
        hsoc = np.zeros((6, 6), dtype=np.complex128) 
        hsoc[0,0] = -1.0
        hsoc[3,0] = sqrt2
        hsoc[1,1] = 1.0
        hsoc[5,2] = sqrt2 
        hsoc[0,3] = sqrt2 
        hsoc[4,4] = 1.0
        hsoc[2,5] = sqrt2
        hsoc[5,5] = -1.0
        return 0.5 * -soc * hsoc

#the order of basis of 't2gud'is |1,1,u>,|1,1,d>,|1,0,u>,|1,0,d>...
    elif case.strip() == 't2g2':
        hsoc = np.zeros((6, 6), dtype=np.complex128)
        hsoc[0,0] = 1.0
        hsoc[1,1] = -1
        hsoc[2,1] = sqrt2
        hsoc[1,2] = sqrt2
        hsoc[4,3] = sqrt2
        hsoc[3,4] = sqrt2
        hsoc[4,4] = -1
        hsoc[5,5] = 1
        return 0.5 * -soc * hsoc

    elif case.strip() == 'd':
        hsoc = np.zeros((10, 10), dtype=np.complex128) 
        hsoc[0,0] = -2.0     
        hsoc[3,0] =  2.0     
        hsoc[1,1] =  2.0     
        hsoc[2,2] = -1.0    
        hsoc[5,2] = sqrt6
        hsoc[0,3] =  2.0
        hsoc[3,3] =  1.0
        hsoc[7,4] = sqrt6
        hsoc[2,5] = sqrt6
        hsoc[6,6] =  1.0
        hsoc[9,6] =  2.0
        hsoc[4,7] = sqrt6
        hsoc[7,7] = -1.0
        hsoc[8,8] =  2.0
        hsoc[6,9] =  2.0
        hsoc[9,9] = -2.0
        return 0.5 * soc * hsoc

    elif case.strip() == 'f':
# |3,-3>,|3,-2>,|3,-1>,... added by sypeng
        hsoc = np.zeros((14, 14), dtype=np.complex128) 
        hsoc[0,0  ] = -3.0
        hsoc[3,0  ] = sqrt6
        hsoc[1,1  ] = 3.0
        hsoc[2,2  ] = -2.0
        hsoc[5,2  ] = sqrt10 
        hsoc[0,3  ] = sqrt6
        hsoc[3,3  ] = 2.0
        hsoc[4,4  ] = -1.0
        hsoc[7,4  ] = sqrt12
        hsoc[2,5  ] = sqrt10 
        hsoc[5,5  ] = 1.0
        hsoc[9,6  ] = sqrt12
        hsoc[4,7  ] = sqrt12
        hsoc[8,8  ] = 1.0
        hsoc[11,8 ] = sqrt10
        hsoc[6,9  ] = sqrt12
        hsoc[9,9  ] = -1.0
        hsoc[10,10] = 2.0
        hsoc[13,10] = sqrt6
        hsoc[8,11 ] = sqrt10
        hsoc[11,11] = -2.0
        hsoc[12,12] = 3.0
        hsoc[10,13] = sqrt6
        hsoc[13,13] = -3.0
        return 0.5 * soc * hsoc

    else:
        print("don't support SOC for this case: ", case)
        return
