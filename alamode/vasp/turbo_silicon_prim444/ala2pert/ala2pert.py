import sys
sys.path.append('./')
from alm2pert import alm2pert
import numpy as np

pc_lat = np.zeros([3,3])
#set primitive lattice vectors mannully, iunit to angstram ? bohr ?
#syp: primitive lettice vectors in bohr.
pc_lat[0] = np.array([-1, 0, 1]) * 5.16840095
pc_lat[1] = np.array([ 0, 1, 1]) * 5.16840095
pc_lat[2] = np.array([-1, 1, 0]) * 5.16840095
#mass of every atom not every element type in the primitive cell
mass = np.array([28.085,28.085])
prefix = 'si_prim444_cubic'
alm2pert(prefix, pc_lat, mass)

#pc_lat[0] = np.array([1,0,0]) * 5.47000039
#pc_lat[1] = np.array([0,1,0]) * 5.47000039
#pc_lat[2] = np.array([0,0,1]) * 5.47000039
#mass = np.array([28.085,28.085,28.085,28.085,28.085,28.085,28.085,28.085])
