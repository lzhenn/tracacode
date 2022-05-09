import matplotlib  
matplotlib.use('Agg') 
import matplotlib.pylab as plt
from matplotlib.pyplot import savefig
# import sompy as sompy
import pandas as pd
import numpy as np
from time import time
import sompy
from netCDF4 import Dataset


def read_ncdf(pfname):
    ncdf= Dataset(pfname)
    lat=ncdf.variables['lat'][:]
    lon=ncdf.variables['lon'][:]
    var=ncdf.variables['precip']
    return lat, lon, var


pfname='/home/yangsong3/L_Zealot/data-mirror/obv/GPCP-precip/precip.pentad.clim.mean.nc'
lat, lon, var = read_ncdf(pfname)

var_array2=var[:,np.logical_and(lat>0, lat<45) ,np.logical_and(lon>60, lon<180)]

#var_array=np.array(var)
#var_array2=var_array[:,15:60,45:90]
lenlat=len(lat)
lenlon=len(lon)
var_size=var_array2.shape
var_1d_array=var_array2.reshape(var_size[0],var_size[1]*var_size[2])

#fig = plt.figure()
#plt.plot(Data1[:,0],Data1[:,1],'ob',alpha=0.2, markersize=4)

#fig.set_size_inches(7,7)
mapsize = [1,8]
som = sompy.SOMFactory.build(var_1d_array, mapsize, mask=None, mapshape='planar', lattice='rect', normalization='var', initialization='pca', neighborhood='gaussian', training='batch', name='sompy')  # this will use the default parameters, but i can change the initialization and neighborhood methods
som.train(n_job=1, verbose='info')  # verbose='debug' will print more, and verbose=None wont print anything
exit()
v = sompy.mapview.View2DPacked(50, 50, 'test',text_size=8)  
# could be done in a one-liner: sompy.mapview.View2DPacked(300, 300, 'test').show(som)
v.show(som, what='codebook', which_dim=[0,1], cmap=None, col_sz=6) #which_dim='all' default
# v.save('2d_packed_test')


savefig('test.png')
