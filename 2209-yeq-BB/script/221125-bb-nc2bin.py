#!/bin/env python3
import xarray as xr
import numpy as np
from scipy.io import FortranFile

strt_day=60
end_day=60

nc_path='/disk/r113/yhuangci/BrC_data/BrC_feedback/read_BB_test_netCDF/BB_BCOC/outputs/'
outpath='/home/lzhenn/temp/'

#varnames=["AECI"]
varnames=["AECI","AECJ","AOCI", "AOCJ"]

for i in range(strt_day, end_day+1):
    infn = 'BB-BCOC_2015%03d.nc' % i
    ds=xr.open_dataset(nc_path+infn)
    var_dic={}
    for varname in varnames:
        print(ds[varname])
        var_dic[varname]=ds[varname].values.astype('>f4')
        print(var_dic[varname][1,1,100,200])
    ds.close()

    for j in range(0, 24):
        outfn= 'BB-BCOC_2015%03d%02d.bin' % (i,j)
        f = FortranFile(outpath+outfn, 'w',header_dtype=np.dtype('>u4'))
        for varname in varnames:
            f.write_record(var_dic[varname][j,:,:,:])
        f.close()
