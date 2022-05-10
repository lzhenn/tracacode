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

begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_strt_yr=1979
    g_lst_yr=2010
    g_day_shift=5

    g_var_name3 = "r"
    g_data3_path ="/Users/zhenningli/data/obv/NOAA-OLR/olr.day.mean.f10.nc"

    g_font = 0.025
    
    ;Andaman Sea convection
    g_latS=5.
    g_latN=20.
    g_lonW=87.5
    g_lonE=100.
    
    ;SCS
    g_latS=5.
    g_latN=20.
    g_lonW=110.
    g_lonE=120.


    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/"+"AndamanConv-P24-25"
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)"/)
    g_fig_title   = "ASConv24-25"

    npos_year = 0
    nneg_year = 0

;Prepare the variables
    ctrl_in     = addfile (g_data3_path, "r")   ; note the "s" of addfile
    time_hist    = ctrl_in->time
    yyyymmdd  = cd_calendar(time_hist,-2)
    
    var3  =short2flt(ctrl_in->olr(:,{g_latS:g_latN},{g_lonW:g_lonE}))
    adm_mean_var3=wgt_areaave_Wrap(var3(:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    adm_mean_var3=where(adm_mean_var3 .lt. 235, 1, 0)
    print(yyyymmdd+": "+adm_mean_var3) 
   
end
