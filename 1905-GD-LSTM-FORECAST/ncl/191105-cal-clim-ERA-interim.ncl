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
    
    yrstrt=19810101
    yrend=20101201
    ;File IO
    pdata_fn     = "/disk/hq247/yhuangci/lzhenn/data/1905-GD-LSTM-FORECAST/T2m.mon.mean.interim.nc"  ; open output netCDF file
    ctrl_in = addfile(pdata_fn ,"r")  ; open output netCDF file
    time=ctrl_in->time
    time_list=cd_calendar(time,-2)
    istrt = ind(time_list .eq. yrstrt)
    iend = ind(time_list .eq. yrend)
    var1    = short2flt(ctrl_in->t2m)
    var1:=var1(istrt:iend,:,:)
    printVarSummary(var1)
    var1:=clmMonTLL(var1)    
    out_file=addfile("/disk/hq247/yhuangci/lzhenn/data/1905-GD-LSTM-FORECAST/T2m.clim.interim.1981-2010.nc","c")
    out_file->T2_CLIM=var1

end




