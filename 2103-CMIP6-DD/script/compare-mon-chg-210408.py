import xarray as xr

CMIP_ARC='/home/metctm1/array/data/cmip6/cmip6-mpi-esm-hr/'
ds_ref=xr.load_dataset(CMIP_ARC+'ts_Amon_MPI-ESM1-2-HR_ssp245_r1i1p1f1_gn_202001-202412.nc')

ds_sen=xr.load_dataset(CMIP_ARC+'ts_Amon_MPI-ESM1-2-HR_ssp585_r1i1p1f1_gn_204501-204912.nc')

