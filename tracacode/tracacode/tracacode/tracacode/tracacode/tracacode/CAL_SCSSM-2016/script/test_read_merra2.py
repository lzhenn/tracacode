from climlab.solar.insolation import daily_sza
import math
from numpy import *
from netCDF4 import Dataset
from pylab import *
import numpy as np
import test_for

#use f2py --fcompiler=intelem -c -m rrtmg_sw_io rrtmg_sw_io.f 


def find_cld_lay(atm_p, ctp):
    '''
    Find the cld layer; atm_p is from high to low; rrtmg need start from #1
    from alt low to high;
    '''
    for i in xrange(size(atm_p)-1):
        if ( (atm_p[i]-ctp)*(atm_p[i+1]-ctp) <= 0.0 ):
            nlay = i+1
    return nlay

def read_merra2_profile(pfname):
    merra2 = Dataset(pfname)
    #merra2 = Dataset("./MERRA2_400.instM_3d_ana_Np.201201.nc4")
    mlat = merra2.variables["lat"][:]
    mlon = merra2.variables["lon"][:]
    mp   = merra2.variables["lev"][:]
    mh   = merra2.variables["H"][0,:,:,:]
    mt   = merra2.variables["T"][0,:,:,:]
    mqv  = merra2.variables["QV"][0,:,:,:]
    mqv  = mqv/(1.0-mqv)*1000.0   ## convert to g/kg
    mo3  = merra2.variables["O3"][0,:,:,:]*1000.0 ## convert to g/kg
    return mlat,mlon,mp,mt,mqv,mo3

def read_elev(fname):
    '''
    data may be negative! but no missing!
    '''
    elev = Dataset(fname)
    #elev = Dataset("./elev.0.5-deg.nc")
    elat   = elev.variables["lat"][:]
    elon   = elev.variables["lon"][:]
    edata  = elev.variables["data"][0,:,:]
    elat2  = zeros(360)
    elon2  = zeros(720)
    edata2 = zeros((360,720))
    elat2[:]       = elat[::-1]
    elon2[0:360]   = elon[360:720]-360.0
    elon2[360:720] = elon[0:360]
    edata2[:,0:360]   = edata[::-1, 360:720]
    edata2[:,360:720] = edata[::-1, 0:360] 
    return elat2,elon2,edata2

fname = "./elev.0.5-deg.nc"
elat,elon,edata = read_elev(fname)
#print edata

pfname = "./MERRA2_400.instM_3d_ana_Np.201201.nc4"
mlat,mlon,mp,mt,mqv,mo3 = read_merra2_profile(pfname)

sza1 = daily_sza(mlat,80)
sza2 = daily_sza(mlat,172)
sza3 = daily_sza(mlat,266)
sza4 = daily_sza(mlat,356)

#jday = [15,46,75,106,136,167,197,228,259,289,320,350]
#
#for i in jday:
#    plot(mlat,daily_sza(mlat,i))

#plot(mlat,sza1,'b')
#plot(mlat,sza2,'r')
#plot(mlat,sza3,'g')
#plot(mlat,sza4,'k')

#for i in sza1:
#    if (math.isnan(i)):
#        print 90.0
#    else:
#        print i

#print sza2
#print sza3
#print sza4


# count the number of masked elements in the vertical direction
nmasked = np.ma.count_masked(mt[:,0,0])
print nmasked
print mt[:,0,0]

test_for.tesing(mt[:,0,0],nmasked)


pcld = 600.0
print find_cld_lay(mp,pcld), mp[find_cld_lay(mp,pcld)]

print find_cld_lay(mp,pcld) - nmasked

print mp


show()

