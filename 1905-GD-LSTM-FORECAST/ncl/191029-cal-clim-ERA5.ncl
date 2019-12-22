;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"

begin
    

    ;File IO
    pdata_fn     = "/home/lzhenn/array2/data/ERA5/monthly/surface/"  ; open output netCDF file
    all_files = systemfunc("ls "+pdata_fn+"sfc*1999*.nc "+ pdata_fn+"sfc*200*.nc "+pdata_fn+"sfc201*.nc ")
    print(all_files)
    ctrl_in = addfiles(all_files ,"r")  ; open output netCDF file
    ListSetType(ctrl_in, "join")
    var1    = ctrl_in[:]->2T_GDS0_SFC
    var1:=clmMonTLL(var1)    
    out_file=addfile("/home/lzhenn/array2/data/ERA5/monthly/clim/T2m.clim.1999-2018.nc","c")
    out_file->T2_CLIM=var1

end




