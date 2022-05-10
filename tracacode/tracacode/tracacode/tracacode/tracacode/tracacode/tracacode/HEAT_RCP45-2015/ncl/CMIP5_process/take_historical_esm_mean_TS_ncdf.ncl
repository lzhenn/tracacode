;*************************************************************
;Aim: take out multimember TS mean from r(1-5)i1p1 CMIP5 data  
;     and output to one individual ncdf file
;     
;Mission:
;   1. Read data from CMIP5 5 memeber mean
;   2. caculate ensemble mean 
;   3. output to an individual file 
;                       Zhenning Li
;                       2015-01-20
;Last Edited:
;   2015-01-20  Create
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
    
    fcase            =  "historical"
    fpath            =  "../data/"+fcase+"/"  
    ncdf_name        =  "ts_Amon_CCSM4_"+fcase+"_esm_mean_185001-200512.nc"

; ==============================================================
; Mission1. Open the file: Read only the user specified period
; ==============================================================
    all_files = systemfunc ("ls "+fpath+"ts_Amon_CCSM4_"+fcase+"_r[1-6]i1p1*")

    setfileoption("nc","SuppressClose",False) ; close too many files

    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile

    ListSetType (ctrl_in, "join")             ; concatenate or "merge" (default)

    var1   = ctrl_in[:]->ts
    var1_time = ctrl_in[:]->time
    var1_lat = ctrl_in[:]->lat
    var1_lon = ctrl_in[:]->lon
; ==============================================================
; Mission2. Post process the data
; ==============================================================
    esm_mean_var1 = dim_avg_n_Wrap(var1,0)   


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
