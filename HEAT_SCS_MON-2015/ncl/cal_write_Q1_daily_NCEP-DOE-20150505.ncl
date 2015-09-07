;*************************************************************
;Aim: cal daily Q1 from NCEP-DOE Datasets, Output 
; daily Q1, file by year
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
;global constants
    G_CPD   =   1004.07     ;Cpd=1004.07 J*kg^-1*K^-1
    G_RD    =   287.05      ;Rd=287.05 J*kg^-1*K^-1
    G_G     =   9.8         ;g=9.8 m*s^-2
;global variables
    ;Define parameters

    ;for directory 
    g_strt_yr=2002
    g_lst_yr=2013
    g_data_dir   =(/"air","uwnd","vwnd","omega","hgt","mslp"/)
    g_data_path = "../data/obv/NCEP_DOE/"+g_data_dir+"/"+g_data_dir

    g_data_out_path = "/home/yangsong3/data/observation/NCEP_DOE/daily/q1_1979-2013/"



    g_latS=0.
    g_latN=20.
    g_lonW=110.
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
        ctrl_in2     = addfile (g_data_path(1)+"."+nyr+".nc", "r")   ; note the "s" of addfile
        u  =short2flt( ctrl_in2->uwnd)
        ctrl_in3     = addfile (g_data_path(2)+"."+nyr+".nc", "r")   ; note the "s" of addfile
        v  =short2flt( ctrl_in3->vwnd)
        ctrl_in4     = addfile (g_data_path(3)+"."+nyr+".nc", "r")   ; note the "s" of addfile
        w  =short2flt( ctrl_in4->omega)
        ctrl_in5     = addfile (g_data_path(4)+"."+nyr+".nc", "r")   ; note the "s" of addfile
        z  =short2flt( ctrl_in5->hgt)
        z  =z*G_G ; change unit from pgm to m^2/s^2
        z@units="m^2/s^2"
        ;ctrl_in6     = addfile (g_data_path(5), "r")   ; note the "s" of addfile
        ;slp  =short2flt( ctrl_in6->mslp)

        print(nyr+" Read done!")
    ;   Prepare some global variables

        g_lvl   =   t&level*100 
        g_lat   =   t&lat
        g_lon   =   t&lon
        g_nlat  =   dimsizes(g_lat)
        g_nlon  =   dimsizes(g_lon)
        g_nlvl =   dimsizes(g_lvl)
    ; ==============================================================
    ; Mission 2. post-post process data to deserved results
    ; ==============================================================

    ;-----------------------------------------------------------
    ;Q1 Caculation: (partial diff replaced by complete diff)
    ;
    ;   s   =   Cp*T + Z        
    ;
    ;   q1  =   d(Cp*T)/dt + V*grad(Cp*T) + w*ds/dp
    ;               [1]         [2]         [3]
    ;
    ;   [1]     dsdt
    ;   [2]     adv_s
    ;   [3]     dsdp
    ;-----------------------------------------------------------
        
        ;CALCULATE Q1
        
        ;preparation
        s   =   z                   ;copy metadata
        s   =   G_CPD*t + z         ;Dry static energy
        s0  =   z
        s0  =   G_CPD*t             ;Cp*T


        ;*****************TERM [1], easy********************
        dsdt    =   z
        dsdt    =   center_finite_diff_n(s0,86400,False,0,0)
        ;***************************************************


        ;***********TERM [2], this is a little tricky*******
        adv_s_x =  z    ;u*ds0dx
        adv_s_y =  z    ;v*ds0dy

        ;u*ds0dx
        dlon = (g_lon(2)-g_lon(1))*0.0174533 ; convert to radians
        
        do i=0,g_nlat-1                      ; loop over each latitude
            dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
            adv_s_x(:,:,i,:) = center_finite_diff_n (s0(:,:,i,:), dx , True,0,2) ; be careful with the dimison downscale
        end do
        adv_s_x =   u*adv_s_x

        ;v*ds0dy
        dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
        dy   = 6378388.*dlat   
        adv_s_y = center_finite_diff_n (s0, dy , False,0,2)
        adv_s_y = v*adv_s_y
        
        adv_s   =   adv_s_x ; copy metadata
        adv_s   =   adv_s + adv_s_y
        ;***************************************************


        ;*****************TERM [3], easy********************
        dsdp    =   z
        dsdp    =   center_finite_diff_n(s,g_lvl,False,0,1)
        dsdp    =   w*dsdp
        ;***************************************************

        q1      =   dsdp ;copy metadata
        q1      =   dsdt + adv_s + dsdp
        q1      =   q1/G_CPD

        q1@long_name    =   "Daily Q1 on Pressure Levels"
        q1@units    =   "K/s"
        q1@var_desc    =   "Q1"
        q1!1        =   "lev"
        print(nyr+" Calculate done!")
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

