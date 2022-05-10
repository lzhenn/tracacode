;*************************************************************
;Aim: take out multimember TS mean from r(1-5)i1p1 CMIP5 data  
;     and output to one individual ncdf file
;     
;Mission:
;   1. Read data from CMIP5 5 memeber mean
;   2. caculate ensemble mean 
;   3. output to an individual file 
;                       Zhenning Li
;                       2015-01-21
;Last Edited:
;   2015-01-21  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

;================================================
;Variables List:
;	var1--------------ts
;================================================
    
    fcase            =  "rcp45"
    fpath            =  "../data/"+fcase+"/"  
    ncdf_name        =  "ts_Amon_CCSM4_"+fcase+"_esm_mean_200601-210012.nc"

    ymstrt  =   200601
 
; ==============================================================
; Mission1. Open the file: Read only the user specified period
; ==============================================================
    
    ; for the 2006 start files

    all_files = systemfunc ("ls "+fpath+"ts_Amon_CCSM4_"+fcase+"_r[1-6]i1p1_2006*")

    setfileoption("nc","SuppressClose",False) ; close too many files

    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile

    ListSetType (ctrl_in, "join")             ; concatenate or "merge" (default)

    var1   = ctrl_in[:]->ts
    var1_time = ctrl_in[:]->time
    var1_lat = ctrl_in[:]->lat
    var1_lon = ctrl_in[:]->lon


    ;for the 2005 start files

    all_files2 = systemfunc ("ls "+fpath+"ts_Amon_CCSM4_"+fcase+"_r[2-5]i1p1_2005*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in2      = addfiles (all_files2, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in2, "join")             ; concatenate or "merge" (default)

    time    = ctrl_in2[:]->time
    yyyymm  = cd_calendar(time(0,:),-1)
    istrt   = ind(yyyymm .eq. ymstrt)
 
    var2   = ctrl_in2[:]->ts(:,istrt:,:,:) ;start from 2006


; ==============================================================
; Mission2. Post process the data
; ==============================================================
    esm_mean_var1 = dim_avg_n_Wrap(var1,0)   
    esm_mean_var2 = dim_avg_n_Wrap(var2,0)   
    esm_mean_var1 = (/ esm_mean_var1*(2.0/6.0)+esm_mean_var2*(4.0/6.0) /)  
    print(esm_mean_var1(5,{0},{110:120}))
;************************************************
; Mission3. High Efficiency to Write the file
;************************************************

;Get dimsize
    dims=dimsizes(esm_mean_var1(0,:,:))
    nlat=dims(0)
    nlon=dims(1)
	
;Set fileoption    
    system("rm "+fpath+ncdf_name)
	fout = addfile(fpath+ncdf_name ,"c")  ; open output netCDF file
	setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =(/"time","lat","lon"/)
    dimSizes    =(/-1,nlat,nlon/)
    dimUnlim    =(/True,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    filevardef(fout,"time",typeof(esm_mean_var1&time),getvardims(esm_mean_var1&time))
    filevardef(fout,"lat",typeof(esm_mean_var1&time),getvardims(esm_mean_var1&lat))
    filevardef(fout,"lon",typeof(esm_mean_var1&time),getvardims(esm_mean_var1&lon))
    filevardef(fout,"ts",typeof(esm_mean_var1),getvardims(esm_mean_var1))

;Define Attribute
    filevarattdef(fout,"time",var1_time)
    filevarattdef(fout,"lat",var1_lat)
    filevarattdef(fout,"lon",var1_lon)
    filevarattdef(fout,"ts",esm_mean_var1)
    
    fout->time=(/esm_mean_var1&time/)
    fout->lat=(/esm_mean_var1&lat/)
    fout->lon=(/esm_mean_var1&lon/)
    fout->ts=(/esm_mean_var1/)

end  
