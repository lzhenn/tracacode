

PATHROOT=/home/metctm1/array/app/wrf43-wudapt

## Compiling

```
# Setup GPI 2020
source /usr/local/pgi-20cos7/setup
source  /usr/local/pgi-20cos7/setup_mpich


# set netcdf
export NETCDF=/usr/local/netcdf4-pgi/
export PATH=$NETCDF/bin:$PATH
export LD_LIBRARY_PATH=$NETCDF/lib:$LD_LIBRARY_PATH
export INCLUDE=$NETCDF/include/:$INCLUDE

# set hdf5
export HDF5=/usr/local/hdf5-1.10.7-pgi/
export PATH=$HDF5/bin:$PATH
export LD_LIBRARY_PATH=$HDF5/lib:$LD_LIBRARY_PATH 
export INCLUDE=$HDF5/include:$INCLUDE
```


## Modifications

$PATHROOT/wrf

### WPSv43_GEOG

```bash
mkdir WPSv43_GEOG
cd WPSv43_GEOG
ln ../WPS_GEOG/* ./ -s
```

Add additional landuse, albedo, and roughness data:
* WPSv43_GEOG/cuhk_2010_lu
* WPSv43_GEOG/wudapt_d3_4pt 
* WPSv43_GEOG/roughness_30s
* WPSv43_GEOG/albedo_30s 

### wrf_run.config
```
L57 export WPS_root=${work_root}/WPS-4.3
L58 export WRF_root=${work_root}/WRF-4.3/test/em_real
L62 export geog_data_root=${work_root}/WPSv43_GEOG
```
### wrf_run
```
L174 $ECHO Clenaup files in WRF-4.3/test/em_real directory
L175 /usr/bin/find WRF-4.3/test/em_real -mindepth 1 -maxdepth 1 -name 'wrfout_d0*' -exec /bin/rm -v {} \;
```

### ./WPS-4.3

Add `./WPS-4.3/geogrid/GEOGRID.TBL.ARW.wudapt`

In `GEOGRID.TBL`, add following lines:
```
490 ===============================
491 name = NOAH_Z0
492         priority=1
493         dest_type=continuous
494         interp_option = default:nearest_neighbor
495         interp_option = wudapt_d3_4pt:four_pt
496         fill_missing=0.
497         rel_path=default:roughness_30s/
498         rel_path=wudapt_d3_4pt:roughness_30s/
499 ===============================
500 name = NOAH_ALB
501         priority=1
502         dest_type=continuous
503         interp_option = default:nearest_neighbor
504         interp_option = wudapt_d3_4pt:four_pt
505         fill_missing=0.
506         rel_path=default:albedo_30s/
507         rel_path=wudapt_d3_4pt:albedo_30s/
508 ===============================
```

Move previous control scripts:

```bash
cp ../WPS/run_* ./
ln -s ../OBSGRID ./
ln -s ../OBSGRID/obsgrid.exe ./
```
Modify `run_sepSST.csh`:
```
L52  geog_data_res     = 'usgs_10m', 'usgs_5m', 'wudapt_d3_4pt+cuhk_2010_lu+usgs_2m','wudapt_d3_4pt+cuhk_2010_lu+usgs_30s'
L115  geog_data_res     = 'usgs_10m', 'usgs_5m', 'wudapt_d3_4pt+cuhk_2010_lu+usgs_2m','wudapt_d3_4pt+cuhk_2010_lu+usgs_30s' 
L171  geog_data_res     = 'usgs_10m', 'usgs_5m', 'wudapt_d3_4pt+cuhk_2010_lu+usgs_2m','wudapt_d3_4pt+cuhk_2010_lu+usgs_30s'
```

### ./WRF-4.3
```bash
cd test/em_real
cp -r ../../../met_WRFV3/test/em_real/run* ./
```
#### ./WRF-4.3/Registory/Registry.EM_COMMON
Add:
```
L842 state    real   NOAH_Z0          ij    misc        1         -     i10rhd=(interp_fcnm)u=(copy_fcnm)       "NOAH_Z0"  "Noah-LSM Gridwise Roughness Length"         "m" 
L843 state    real   NOAH_ALB         ij    misc        1         -     i10rhd=(interp_fcnm)u=(copy_fcnm)
```
#### ./WRF-4.3/dyn_em

`module_first_rk_step_part1.F` add:
```
L971      &        ,NOAH_Z0=grid%NOAH_Z0                                                  & !Added by Zhenning LI, Oct 14, 2021
L972      &        ,NOAH_ALB=grid%NOAH_ALB                                                & !Added by Zhenning LI, Oct 14, 2021 
```

#### ./WRF-4.3/phys

Sourcemods in 
* `module_sf_noahdrv.F`
* `module_sf_noahlsm.F`
* `module_surface_driver.F`

**please use "LZN" to search and lock the modification snippets.**

#### ./WRF-4.3/test/em_real/runWRF_EPD_nonudging.csh.6h
```
L115:  num_land_cat                        = 24,
```


Zhenning LI
Oct 14, 2021
