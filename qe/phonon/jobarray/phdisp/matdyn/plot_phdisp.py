import numpy as np                                                                                                                 
import matplotlib.pyplot as plt                                                                                                    
                                                                                                                                   
data = np.loadtxt("fesb2.freq.gp")                                                                                                 
# convert from cm^-1 to meV                                                                                                        
data[:, 1:] *= 0.123984                                                                                                            
                                                                                                                                   
                                                                                                                                   
nbands = data.shape[1]                                                                                                             
for band in range(1,nbands):                                                                                                       
    plt.plot(data[:, 0], data[:, band], linewidth=1, alpha=0.5, color='k')                                                         
# High symmetry k-points (check matdyn.GaAs.in)                                                                                    
plt.axvline(x=data[0, 0], linewidth=0.5, color='k', alpha=0.5)                                                                     
plt.axvline(x=data[30, 0], linewidth=0.5, color='k', alpha=0.5)                                                                    
plt.axvline(x=data[60, 0], linewidth=0.5, color='k', alpha=0.5)                                                                    
plt.axvline(x=data[90, 0], linewidth=0.5, color='k', alpha=0.5)                                                                    
plt.axvline(x=data[120, 0], linewidth=0.5, color='k', alpha=0.5)                                                                   
plt.axvline(x=data[150, 0], linewidth=0.5, color='k', alpha=0.5)                                                                   
plt.axvline(x=data[180, 0], linewidth=0.5, color='k', alpha=0.5)                                                                   
plt.axvline(x=data[210, 0], linewidth=0.5, color='k', alpha=0.5)                                                                   
plt.xticks(ticks= [0, data[30, 0], data[60, 0], data[90, 0], data[120,0], data[150,0], \                                           
        data[180,0], data[210,0], data[-1, 0]], \                                                                                  
        labels=['$\Gamma$', 'Z', 'T', 'Y', '$\Gamma$', 'X', 'S', 'R', 'U'])                                                        
#plt.ylabel("Frequency (cm$^{-1}$)")                                                                                               
plt.ylabel("Frequency (meV)")                                                                                                      
plt.xlim(data[0, 0], data[-1, 0])                                                                                                  
plt.ylim(0, )                                                                                                                      
plt.savefig('fesb2_phdisp.pdf')
