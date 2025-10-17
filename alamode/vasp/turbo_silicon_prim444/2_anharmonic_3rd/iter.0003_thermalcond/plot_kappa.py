#!/usr/bin/env python3


import numpy as np

import matplotlib.pyplot as plt


#real data from a txt file with the first line as header and the rest as data of ten columns
#draw the 2D plot using the first and second columns as x and y axis


#read the data from the file
data = np.loadtxt('si_prim444_cubic.kl', skiprows=1)
#extract the first and second columns
x = data[:, 0]
y = data[:, 1]

#plot the data using line dots
plt.plot(x, y, 'ro-', label='kappa 20*20*20')
#add labels to the axes
plt.xlabel('Temperature (K)')
plt.ylabel('kappa (W/mK)')

#using log scale for x and y axes
plt.xscale('log')
plt.yscale('log')

#add title to the plot
plt.title('Thermal conductivity vs Temperature of silicon crystal')
#add grid to the plot
plt.grid()
#add legend to the plot
plt.legend()
#save the plot to a file
plt.savefig('kappa.png')
