## Overview 

This folder archives all source code modifications to CESM1.2 (or other models in the future) that I have conducted during research.


Another repo, called [CESM CAM FORCING MODULE (CCFM)](https://github.com/Novarizark/cesm-cam-forcing-mod), archives source modification for CESM users using external forcing files to conduct sensitive experiments in the CAM workflow. This flexible architecture enables you to deploy the module to a series of different versions of CESM (with careful check), although the source code was developed based on CESM1.2.2. That module was general enough to be applicable in a wide variety of questions by modifying the model prognostic physical tendencies. The common module embedded into the CESM architecture is still in development. You could make your choice to use the following specific files (including applications requesting source mods in CLM or POP), or use the CCFM for the CAM-only source mod applications.

## Usage

Please check [the slide from Cecile Hannay](http://www.cesm.ucar.edu/events/tutorials/2016/practical4-hannay.pdf) about how to modify the source code in the CESM (from p30). Basically, you may `create_newcase` and then execute `./cesm_setup`, copy the following modified source code tree which fits your needs to the `${CASENAME}/SourceMods` directory. Then execute `./${CASENAME}.build` to compile the modified source.

Some following targeted modifications may need external input or namelist changes. Please follow the specific introductions for these operations.

**Please use keyword "MOD" or "LZN" to lock the modification parts in the source.**

Any question, please contact Zhenning LI: novarizark@gmail.com

## Catagory
    
* [SourceMods-CAM4-MAM-heat](#SourceMods-CAM4-MAM-heat)
* [SourceMods-Nudging](#SourceMods-Nudging)
* [SourceMods-ideal-folding-heat](#SourceMods-ideal-folding-heat)
* [SourceMods-mod_canopyNgrd_albd](#SourceMods-mod_canopyNgrd_albd)
* [SourceMods-shf](#SourceMods-shf)
* [SourceMods-SST-decoupling](#SourceMods-SST-decoupling)
* [SourceMods-heatflux-correction](#SourceMods-heatflux-correction)
* [SourceMods-snow_rate](#SourceMods-snow_rate)
* [SourceMods-phys_audit](#SourceMods-phys_audit)

### SourceMods-CAM4-MAM-heat
Intensify/Suppress convective heating rate (J/kg/s) over a certain region/time, a detailed introduction can be found in the Methods section in https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4962042/ 

### SourceMods-Nudging    
Nudge a user-specified field (3-D structure evolves in time) in the model runtime.

### SourceMods-ideal-folding-heat
Impose a 3-D heating anomaly over a certain region/time in the idealized simulation (F_IDEAL).
 
### SourceMods-mod_canopyNgrd_albd
Dynamically modify the albedo calculation before the radiation allocation and update in the land surface model (CLM4).
 
### SourceMods-shf
Remove the vertical diffusion (turbulance) caused heating to the atmosphere over the Tibetan Platau. This process can be treated as, instead of redistributing the surface heating, the turbulance eats up all surface heating like a black hole. Therefore, this is nearly shutdown the surface heating by the TP.

### SourceMods-SST-decoupling
Partially decoupling the Air-sea interaction by fixing the SST values to the prescribed SST datasets. **Prof. Chao He provided the initial code based on CCSM4. His contribution greatly assisted me to build the current version for CESM1.2.2.**

* Please use 'LZN' (no apostrophe) to lock the code modification segmentation.

* Need to register new namelist group in  `$CCSMROOT/models/ocn/pop2/bld/build-namelist`, just add `ptempf_file_nml` in **L1776**, the @group name writing section.

* Need to register new namelist variables in `$CCSMROOT/models/ocn/pop2/bld/namelist_files/namelist_definition_pop2.xml`, just copy the following code to the end of the xml file.

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

### SourceMods-heatflux-correction
Using prescribed heat flux correction method to correct the model state. Heat flux includes sensible heat from coupler to atm, shortwave, and longwave flux from atm to coupler.
Please refer the [tech blog](https://novarizark.github.io/2018/10/29/cesm-fully-coupled-correction/) for more info. 

### SourceMods-snow_rate
Change the large-scale snowfall rate over a certain region and period. This is aiming to accumulate snow cover over the targeted land surface, while the user need to be very careful in interpreting the results as mass conservation is violated by this operation. 
Please use keyword "MOD" to lock the modification parts.

### SourceMods-phys_audit
PHYS_AUDIT is an online, process-based audit module in CAM physics package. The idea is sourced from [Lu and Cai (2010)](https://link.springer.com/content/pdf/10.1007/s00382-009-0673-x.pdf) in an idealized CGCM to quantify contributions to polar warming amplification.
Please use keyword "LZN" to lock the modification parts.

LZN

Last Updated: Mar 19, 2021
