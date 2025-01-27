import numpy as np
import matplotlib.pyplot as plt
from math import pi
import at
import at.plot


#this function can plot pretty xy  phase space with certain initial cond.
def lat_pas(SR,nturns, ref, save = False):

    #global SR
    plt.rcParams["figure.figsize"] = [2*3.75, 3.75]
    plt.rcParams['xtick.major.size'] = 5
    plt.rcParams['xtick.labelsize'] = 18
    plt.rcParams['ytick.labelsize'] = 18
    plt.rcParams['xtick.top'] = True
    plt.rcParams['ytick.right'] = True
    plt.rcParams['axes.titlesize'] = 20
    plt.rcParams['legend.loc'] ='upper right'
    font = {'family':'Times New Roman',
       'weight' : 'normal',
       'size' : 18 }
    plt.rc('font',**font)
    plt.rcParams['lines.linewidth'] = 2
    Z01 = np.array([10e-5, 0, 5e-6, 0, 0, 0])
    Z02 = np.array([5e-5, 0, 0, 0, 0, 0])
    Z03 = np.array([3e-5, 0, 10e-6, 0, 0, 0])
    
    Z1=at.lattice_pass(SR, Z01, nturns, refpts=ref)
    Z2=at.lattice_pass(SR, Z02, nturns, refpts=ref)
    Z3=at.lattice_pass(SR, Z03, nturns, refpts=ref)
    
    fig, ax1 = plt.subplots()
    ax1.plot(Z1[0, 0, 0, :]*1e6, Z1[1, 0, 0, :]*1e6,'b.')
    #ax1.plot(Z2[0, 0, 0, :]*1e6, Z2[1, 0, 0, :]*1e6,'b.')
    #ax1.plot(Z3[0, 0, 0, :]*1e6, Z3[1, 0, 0, :]*1e6,'g.')
    ax1.set_title("Phase space at index number %g" %ref)
    ax1.minorticks_on()
    ax1.tick_params(axis='both',which='minor',width=1, length=6, top='True', right='True', direction='in')
    ax1.tick_params(which='both', width=1)
    ax1.tick_params(which='major', length=7, top='True', right='True', direction='inout')
    ax1.tick_params(axis='both',which='minor',width=1, length=6, top='True', right='True', direction='in')
# Create the contour plot
    ax1.set_ylabel("X' [$\mu$rad]")
    ax1.set_xlabel("X [$\mu$m]")
    
    ax2 = ax1.twinx()  # instantiate a second axes that shares the same x-axis
    ax2.minorticks_on()
    ax2.plot(Z1[2, 0, 0, :]*1e6, Z1[3, 0, 0, :]*1e6,'r.',ls='none', markersize=2, alpha =0.25)
    #ax2.plot(Z2[2, 0, 0, :]*1e6, Z2[3, 0, 0, :]*1e6,'b.', alpha =0.25)
    #ax2.plot(Z3[2, 0, 0, :]*1e6, Z3[3, 0, 0, :]*1e6,'g.', alpha =0.25)
    ax2.set_ylabel("Y' [$\mu$rad]", color='r')
    ax2.set_ylim(-10,10)
    print(SR[ref])
    if save == True:
        ax1.savefig('PhaseSpace_%g'%ref+'.png', dpi = 600, bbox_inches=None, pad_inches=0.5)
        ax1.savefig('PhaseSpace_%g'%ref+'.eps', dpi = 300, bbox_inches=None, pad_inches=0.5)
    plt.show()
    
#plots horizontal x orbit vs spos
def plot_bpm_x(SR, nturns, ref_point , tune, save):
    #nturns=500
    ref = SR[ref_point]
    time = nturns*1.7e-6 #second
    damp = 0.01717785 #s at.radiation_parameters(StorageR).Tau[0]#
    tune = 0.22#tune#at.radiation_parameters(SR).tunes[0]
    tt = np.linspace(0,time, nturns)
    Z03 = np.array([3e-6, 0, 10e-6, 0, 0, 0])
    Z3=at.lattice_pass(SR,Z03,nturns, refpts=ref)
    plt.rcParams['axes.titlesize'] = 20
    plt.rcParams['ytick.right'] = True
    plt.rcParams["figure.figsize"] = [3*3.75, 3.75]
    plt.rcParams['xtick.major.size'] = 5
    plt.rcParams['xtick.labelsize'] = 18
    plt.rcParams['ytick.labelsize'] = 18
    plt.rcParams['xtick.top'] = True
    plt.rcParams['legend.loc'] ='upper right'
    plt.rcParams['lines.linewidth'] = 2
    font = {'family':'Times New Roman',
       'weight' : 'normal',
       'size' : 18 }
    plt.rc('font',**font)
    plt.minorticks_on()
    plt.tick_params(axis='both',which='minor',width=1, length=6, top='True', right='True', direction='in')
    plt.tick_params(which='both', width=1)
    plt.tick_params(which='major', length=7, top='True', right='True', direction='inout')
    plt.tick_params(axis='both',which='minor',width=1, length=6, top='True', right='True', direction='in')
# Create the contour plot
    #plt.title('Horizontal position for turns: %d at ref. point %d, damping %.4e s' %(nturns, ref_point, damp) )

    
    plt.plot( tt*1000, 1000*Z3[0, 0, 0, :]*np.exp(-2*tt/damp),'.',c='b', label='Tune: %0.3f' %tune)# %tune)
    #plt.plot( tt*1000, 1000*Z3[2, 0, 0, :]*np.exp(-2*tt/0.0400897),'.',c='b', label='Tune: %0.3f' %tune)# %tune)
    plt.ylabel("X [mm]")
    plt.xlabel("Time [ms]")
    plt.legend()
    print(ref, damp)
    if save == True:
        plt.savefig('bpm'+str(tune)+'_hor.png', dpi =600)
        plt.savefig('bpm'+str(tune)+'_hor.eps', dpi =300)
    return  damp, 1000*Z3[0, 0, 0, :]*np.exp(-2*tt/damp)
##time, xx = plot_bpm_x(5000, 101, 0.27, False)

#same as plot_bpm_x without plotting it
def orbit_x(SR, nturns, ref_point , tune, save):
    #nturns=500
    ref = SR[ref_point]
    time = nturns*1.7e-6 #second
    damp =  6.54e-06 #s 
    tune = tune#at.radiation_parameters(SR).tunes[0]
    tt = np.linspace(0,time, nturns)
    Z03 = np.array([10e-6, 0, 10e-6, 0, 0, 0])
    Z3=at.lattice_pass(SR,Z03,nturns, refpts=ref)
    return  damp, 1000*Z3[0, 0, 0, :]*np.exp(-2*tt/damp), 1000*Z3[1, 0, 0, :]*np.exp(-2*tt/damp)
