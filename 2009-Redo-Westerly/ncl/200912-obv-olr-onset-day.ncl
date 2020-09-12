;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"
load "./LIB_CAL_SCSSM-2016.ncl"

begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    g_latS=5
    g_latN=15
    g_lonW=87.5
    g_lonE=97.5
   
    ;Read NOAA OLR
    var_obv=read_noaa_olr_daily_2D(1979, 2018, 0,180,g_latS,g_latN,g_lonW,g_lonE,"/disk/v092.yhuangci/lzhenn/westerly/olr.day.mean.nc")
    dims=dimsizes(var_obv)
    dimlen=dims(0)
    do ii = 0, dimlen-1
        onsetday=get_onset_idx_from_olr(var_obv(ii,:,:,:), g_latS, g_latN, g_lonW, g_lonE)+1
        print(1979+ii+":"+onsetday)
    end do
end
