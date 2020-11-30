### SourceMods-SST-decoupling
Partially decoupling the Air-sea interaction by fixing the SST values to the prescribed SST datasets. **Prof. Chao He provided the initial code based on CCSM4. His contribution greatly assisted me to build the current version for CESM1.2.2.**

* Please use 'LZN' (no apostrophe) to lock the code modification segmentation.

* Please register new namelist group in  `$CCSMROOT/models/ocn/pop2/bld/build-namelist`, just add `ptempf_file_nml` in **L1776**, the @group name writing section.

* Please register new namelist variables in `$CCSMROOT/models/ocn/pop2/bld/namelist_files/namelist_definition_pop2.xml`, just copy the following code to the end of the xml file.

* Please rename `ocn_comp_mct.mon12.F90` or `ocn_comp_mct.day365.F90` to `ocn_comp_mct.F90` according to your requirement.


```xml
<entry 
id="ptempf_file_name"
type="char*256"
category="forcing"
group="ptempf_file_nml" >
File containing forcing potential temperature data 

Default: ''
</entry>

<entry 
id="ptempf_file_fmt"
type="char*256"
category="forcing"
group="ptempf_file_nml"
valid_values="bin,nc" >
potential temperature forcing file format (binary or netCDF).

Valid Values: 'bin', 'nc'
Default: 'nc'
</entry>
```

* Set proper namelist variable in user_nl_pop2.

``` fortran
ptempf_file_name       = '$PATH_TO_YOUR_DATA/nudging_ptemp.nc'
ptempf_file_fmt        = 'nc'
```
* Sample of the nudging_ptemp.nc

```
netcdf nudging_ptemp {
dimensions:
    nlat = 384 ;
    nlon = 320 ;
    time = 365 ;
variables:
    double TLONG(nlat, nlon) ;
        TLONG:missing_value = 9.96920996838687e+36 ;
        TLONG:units = "degrees_east" ;
        TLONG:long_name = "array of t-grid longitudes" ;
        TLONG:_FillValue = 9.96920996838687e+36 ;
    double TLAT(nlat, nlon) ;
        TLAT:missing_value = 9.96920996838687e+36 ;
        TLAT:units = "degrees_north" ;
        TLAT:long_name = "array of t-grid latitudes" ;
        TLAT:_FillValue = 9.96920996838687e+36 ;
    float TEMP_365(time, nlat, nlon) ;
        TEMP_365:grid_loc = "3111" ;
        TEMP_365:coordinates = "TLONG TLAT" ;
        TEMP_365:units = "degC" ;
        TEMP_365:long_name = "Surface Potential Temperature" ;
        TEMP_365:_FillValue = 9.96921e+36f ;
    int time(time) ;
    float WGT_365(time, nlat, nlon) ;
        WGT_365:grid_loc = "3111" ;
        WGT_365:coordinates = "TLONG TLAT" ;
        WGT_365:units = "1" ;
        WGT_365:long_name = "Nudging Coefficients" ;
        WGT_365:_FillValue = 9.96921e+36f ;
}
```


