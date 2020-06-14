#!/usr/bin/env python
import os
import matplotlib.pyplot as plt

#
# fermi energy
#
fo = open('OUTCAR.scf','r')
Efermi = 0.0
for cnt, lines in enumerate(fo):
    if lines[1:8]=="E-fermi" :
        Efermi = float(lines[10:19])
print Efermi

#
# read data
#
f = open('DOSCAR','r')
line = f.readline()
natoms = int(line[0:4])            # n-atoms
line = f.readline()
line = f.readline()
line = f.readline()
line = f.readline()
line = f.readline()
nx = int(line[32:38])              # n-energy 
energy = [0.0]*nx
dos = [0.0]*nx                       # total dos
dos_atoms = [ [0.0]*nx for ii in range(natoms)]        # dos of each atoms
dos_atoms2 = [ [0.0]*nx for ii in range(natoms)]        # dos of each atoms
pdos =  [ [ [0.0]*nx for jj in range(9)] for ii in range(natoms)]         # 9 orbits: s py pz px dxy dyz dz2 dxz dx2
pdos2 =  [ [ [0.0]*nx for jj in range(9)] for ii in range(natoms)]         # 9 orbits: s py pz px dxy dyz dz2 dxz dx2
for i in range(nx):
    line = f.readline()
    energy[i] = float(line[3:12])-Efermi
    dos[i] = float(line[12:24])
for ii in range(natoms):
    line = f.readline()
    for jj in range(nx):
        line = f.readline()
        for kk in range(9):
            pdos[ii][kk][jj] =float(line[12+24*kk-1:24+24*kk-1]) 
            pdos2[ii][kk][jj] =float(line[24+24*kk-1:36+24*kk-1]) 
            dos_atoms[ii][jj] = dos_atoms[ii][jj] + pdos[ii][kk][jj] 
            dos_atoms2[ii][jj] = dos_atoms2[ii][jj] + pdos2[ii][kk][jj] 
fo.close() 
f.close() 

dos_Nbtotal = [0.0]*nx
dos_Nbtotal = [0.0]*nx
dos_Setotal = [0.0]*nx
dos_3total = [0.0]*nx
dos_3s = [0.0]*nx
dos_Nbd = [0.0]*nx
dos_Nbd2 = [0.0]*nx
dos_Nbd3 = [0.0]*nx
dos_Nbd4 = [0.0]*nx
dos_Nbdxy = [0.0]*nx
dos_Nbdyz = [0.0]*nx
dos_Nbdz2 = [0.0]*nx
dos_Nbdxz = [0.0]*nx
dos_Nbdx2 = [0.0]*nx
dos_Sep = [0.0]*nx
dos_Sepx = [0.0]*nx
dos_Sepy = [0.0]*nx
dos_Sepz = [0.0]*nx
dos_total = [0.0]*nx
dos_total2 = [0.0]*nx
for jj in range(nx):
#    dos_Nbtotal[jj] = dos_atoms[0][jj] + dos_atoms[1][jj]
#    dos_Setotal[jj] = dos_atoms[2][jj] + dos_atoms[3][jj] 
    dos_Nbd[jj] = pdos[1][4][jj] + pdos[1][5][jj] + pdos[1][6][jj] + pdos[1][7][jj] + pdos[1][8][jj]
    dos_Nbd2[jj] =-( pdos2[1][4][jj] + pdos2[1][5][jj] + pdos2[1][6][jj] + pdos2[1][7][jj] + pdos2[1][8][jj])


#   dos_Nbd3[jj] = pdos[11][1][jj] + pdos[11][2][jj] + pdos[19][3][jj] \
#                 +pdos[12][1][jj] + pdos[12][2][jj] + pdos[19][3][jj] \
#                 +pdos[13][1][jj] + pdos[13][2][jj] + pdos[19][3][jj] \
#                 +pdos[14][1][jj] + pdos[14][2][jj] + pdos[19][3][jj] \
#                 +pdos[15][1][jj] + pdos[15][2][jj] + pdos[19][3][jj] \
#                 +pdos[16][1][jj] + pdos[16][2][jj] + pdos[19][3][jj] \
#                 +pdos[17][1][jj] + pdos[17][2][jj] + pdos[19][3][jj] \
#                 +pdos[18][1][jj] + pdos[18][2][jj] + pdos[19][3][jj] 
#   dos_Nbd4[jj] =-(pdos[11][1][jj] + pdos[11][2][jj] + pdos[19][3][jj] \
#                 +pdos2[12][1][jj] + pdos2[12][2][jj] + pdos2[19][3][jj] \
#                 +pdos2[13][1][jj] + pdos2[13][2][jj] + pdos2[19][3][jj] \
#                 +pdos2[14][1][jj] + pdos2[14][2][jj] + pdos2[19][3][jj] \
#                 +pdos2[15][1][jj] + pdos2[15][2][jj] + pdos2[19][3][jj] \
#                 +pdos2[16][1][jj] + pdos2[16][2][jj] + pdos2[19][3][jj] \
#                 +pdos2[17][1][jj] + pdos2[17][2][jj] + pdos2[19][3][jj] \
#                 +pdos2[18][1][jj] + pdos2[18][2][jj] + pdos2[19][3][jj]) 

#    dos_Nbd[jj] = pdos[0][4][jj] + pdos[0][5][jj] + pdos[0][6][jj] + pdos[0][7][jj] + pdos[0][8][jj] \
#                + pdos[1][4][jj] + pdos[1][5][jj] + pdos[1][6][jj] + pdos[1][7][jj] + pdos[1][8][jj] 
#    dos_Sep[jj] = pdos[2][1][jj] + pdos[2][2][jj] + pdos[2][3][jj] \
#               + pdos[3][1][jj] + pdos[3][2][jj] + pdos[3][3][jj] 
#    dos_3s[jj] = pdos[4][0][jj] \
#                + pdos[5][0][jj]  


    dos_total[jj] = dos_atoms[0][jj] + dos_atoms[1][jj]+dos_atoms[2][jj] 

    dos_total2[jj] =-( dos_atoms2[0][jj] + dos_atoms2[1][jj]+dos_atoms2[2][jj] )

#   dos_Nbdxy[jj] = pdos[0][4][jj] + pdos[1][4][jj]
#   dos_Nbdyz[jj] = pdos[0][5][jj] + pdos[1][5][jj]
#   dos_Nbdz2[jj] = pdos[0][6][jj] + pdos[1][6][jj]
#   dos_Nbdxz[jj] = pdos[0][7][jj] + pdos[1][7][jj]
#   dos_Nbdx2[jj] = pdos[0][8][jj] + pdos[1][8][jj]
#   dos_Sepy[jj] = pdos[2][1][jj] + pdos[3][1][jj] + pdos[4][1][jj] + pdos[5][1][jj] 
#   dos_Sepz[jj] = pdos[2][2][jj] + pdos[3][2][jj] + pdos[4][2][jj] + pdos[5][2][jj] 
#   dos_Sepx[jj] = pdos[2][3][jj] + pdos[3][3][jj] + pdos[4][3][jj] + pdos[5][3][jj] 

#
# plot
#
plt.figure(figsize=(8,5))                                                                    # figure size 4:8 modify
#plt.plot( [0, 0], [-10, 10],color='black',linestyle='--')             #       The line of high-symmetry-point
plt.plot( [-6, 2], [0, 0],color='black')             #       The line of high-symmetry-point
#plt.plot( energy, dos_Nbtotal,label='Ba total',color='brown')
#plt.plot( energy, dos_Setotal,label='Sn total',color='yellow')
#plt.plot( energy, dos_3total,label='Hg total',color='magenta')


#plt.plot( energy, dos_Nbdxy,label='Ta dxy',color='red')
#plt.plot( energy, dos_Nbdyz,label='Ta dyz',color='blue')
#plt.plot( energy, dos_Nbdz2,label='Ta dz2',color='green')

plt.plot( energy, dos_Nbd,label='Ni d',color='red')
plt.plot( energy, dos_Nbd2,color='red')
#plt.plot( energy, dos_Nbd3,label='As p',color='blue')
#plt.plot( energy, dos_Nbd4,color='blue')

#plt.plot( energy, dos_Sep,label='Sn p',color='blue')
#plt.plot( energy, dos_3s,label='Hg s',color='green')
#plt.plot( energy, dos_Sepx,label='Se px',color='red')
#plt.plot( energy, dos_Sepy,label='Se py',color='blue')
#plt.plot( energy, dos_Sepz,label='Se pz',color='green')
plt.plot( energy, dos_total,label='total',color='black')
plt.plot( energy, dos_total2,color='black')
#plt.plot( energy, dos,color='green',label='total-a' )
#plt.plot( energy, dos,color='black' )


plt.xlabel('Energy(eV)')
plt.ylabel('DOS')

#plt.xlim(energy[0], energy[nx-1])
#plt.ylim(0, max(dos_total))                                                                              #   The range of y, modify  
plt.xlim(-6, 2)
plt.ylim(-10, 10 )                                                                            #   The range of y, modify  

plt.legend()
plt.savefig('dos.pdf', dpi=300)

#
# print
#
fw = open('dos0','w')
for k in range(nx):
    if dos[k] == 0 :
        fw.write('%3d   %8.4f  %8.4f\n' %(k, energy[k], dos[k]))
fw.close()
