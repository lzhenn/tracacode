This folder archives all source code modifications to CESM1.2 (or other models in the future) that I have implemented during my research.

**Please use keyword "MOD" to lock the modification parts.**

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
Partially decoupling the Air-sea interaction by fixing the SST values to the prescribed SST datasets.

* Please use 'LZN' (no apostrophe) to lock the code modification segmentation.
* Need to register new namelist variables in `$CESM_ROOT/models/ocn/pop2/bld/namelist_files/namelist_definition_pop2.xml`, just copy the following code to the end of the xml file.
```xml
<entry 
id="ptempf_file_name"
type="char*256"
category="forcing"
group="forcing_pt_interior_nml" >
File containing forcing potential temperature data 

Default: ''
</entry>

<entry 
id="ptempf_file_fmt"
type="char*256"
category="forcing"
group="forcing_pt_interior_nml"
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

LZN

Last Updated: Nov 28, 2018
