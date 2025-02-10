#! /usr/bin/env python3
#
#
#conda activate pyprocar
import pyprocar
#pyprocar.bandsplot(cmap='OrRd',mode = 'parametric', code = 'vasp', elimit=[-10,10], fermi=10.6690, show=False, atoms=[0,3,6], orbitals=[0,1,2,3,4,5,6,7,8],savefig='./NbO_fatband_nosoc_U0_p10m10_vasp_Nb147.pdf',dirname='./')
#pyprocar.dosplot(code='vasp',dirname="./",savefig="./NbO-nosoc-relax2-dos.pdf",mode='plain',elimit=[-10, 10],fermi=0.2922,orientation='horizontal')
pyprocar.bandsplot(mode = 'plain', code = 'qe', elimit=[-2,2], fermi=9.0174, show=False, savefig='./NbO_band.pdf',dirname='./')

#pyprocar.bandsplot(cmap='OrRd',mode = 'parametric', code = 'vasp', elimit=[-10,10], fermi=10.6690, show=False, atoms=[0,3,6], orbitals=[0,1,2,3,4,5,6,7,8],savefig='/home/sypeng/work/NbO/uc-111/pic/NbO_fatband_nosoc_U0_p10m10_vasp_Nb147.pdf',dirname='/home/sypeng/work/NbO/uc-111/vasp/nosoc/band')
#pyprocar.dosplot(code='vasp',dirname="/home/sypeng/work/NbO/monolayer-111-substrateMgO/vasp/nosoc/wk2-relax/dos",savefig="/home/sypeng/work/NbO/monolayer-111-substrateMgO/vasp/pic/NbO-nosoc-relax2-dos.pdf",mode='plain',elimit=[-10, 10],fermi=0.2922,orientation='horizontal')
#pyprocar.bandsplot(mode = 'plain', code = 'vasp', elimit=[-2,2], fermi=-0.5641, show=False, savefig='/home/sypeng/work/NbO/monolayer-111/vasp/pic/NbO_band_nosoc_U0_p2m2_vasp.pdf',dirname='/home/sypeng/work/NbO/monolayer-111/vasp/nosoc/wk1/band')
