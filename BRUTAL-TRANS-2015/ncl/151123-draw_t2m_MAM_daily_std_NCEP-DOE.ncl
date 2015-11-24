;*************************************************************
;Aim: Cal MAM detrended standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;     2.1 Calculate Q1
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
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;======================================================
;Variables List:
;	t--------------Air Temperature (K, TLLL)
;	u--------------U Wind (m/s, TLLL)
;	v--------------V Wind (m/s, TLLL)
;	w--------------Vertical Velocity (Pa/s, TLLL)
;	z--------------Geopotential Height (m^2/s^2, TLLL)
;	slp------------Mean Surface Pressure (Pa, TLLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_strt_yr=1979
    g_lst_yr=1984

    g_data_path = "../data/obv/NCEP-DOE-T2M"



    g_latS=0.
    g_latN=60.
    g_lonW=90.
    g_lonE=160.
    ; create an array of desired pressure levels:

        

    ;g_fig_title   =   "1979-2014 "+(/"Mar","Apr","May","Jun","Jul","Aug"/)+" Q1 Trend"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================
    do nyr = g_strt_yr, g_lst_yr
        ctrl_in1     = addfile (g_data_path(0)+"."+nyr+".nc", "r")   ; note the "s" of addfile
        t  =short2flt( ctrl_in1->air)
            ;************************************************
    ; High Efficiency to Write the file
    ;************************************************

    ;Get dimsize
    ;    dims=dimsizes(q1(0,0,:,:))
    ;    nlat=dims(0)
    ;    nlon=dims(1)
        
    ;Set fileoption    
        system("rm "+g_data_out_path+"q1."+nyr+".nc")
        fout = addfile( g_data_out_path+"q1."+nyr+".nc","c")  ; open output netCDF file
        setfileoption(fout,"DefineMode",True)

    ;Set All field attribution
        fileAtt     = True
        fileAtt@creation_date=systemfunc("date")
        fileattdef(fout,fileAtt)

    ;Define Coordinate
        dimNames    =(/"time","lev","lat","lon"/)
        dimSizes    =(/-1,g_nlvl,g_nlat,g_nlon/)
        dimUnlim    =(/True,False,False,False/)
        filedimdef(fout,dimNames,dimSizes,dimUnlim)

    ;Define var, type and dim
        filevardef(fout,"time",typeof(q1&time),getvardims(q1&time))
        filevardef(fout,"lev",typeof(q1&lev),getvardims(q1&lev))
        filevardef(fout,"lat",typeof(q1&lat),getvardims(q1&lat))
        filevardef(fout,"lon",typeof(q1&lon),getvardims(q1&lon))
        filevardef(fout,"q1",typeof(q1),getvardims(q1))

    ;Define Attribute
        filevarattdef(fout,"q1",q1)
        filevarattdef(fout,"time",q1&time)
        filevarattdef(fout,"lev",q1&lev)
        filevarattdef(fout,"lat",q1&lat)
        filevarattdef(fout,"lon",q1&lon)
        
        fout->time=(/q1&time/)
        fout->lev=(/q1&lev/)
        fout->lat=(/q1&lat/)
        fout->lon=(/q1&lon/)
        fout->q1=(/q1/)

        print(nyr+" Write done!")
        delete([/q1, dsdp, dsdt, adv_s, adv_s_x, adv_s_y, s, s0/])
        delete([/t, u, v, w, z/])
        print("Variable Deleted!")
    end do
end

