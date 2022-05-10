

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    case_name   =   "CTRL"
    exedir      =   "exe"
    lvl         =   26
    period      =   "0006-0035"
    plev        =   (/925.0, 850.0, 700.0, 600.0, 500.0, 400.0, 300.0, 200.0, 100.0, 50.0/)
    pdata_fn    =   "../data/"+case_name+".ZMDT.mon."+period+".nc"

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls ../../"+case_name+"/"+exedir+"/*cam.h0.000[6-9]* ../../"+case_name+"/"+exedir+"/*cam.h0.00[1-3]*")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
    ctrl_var1 = ctrl_in[:]->Z3

	hbcofa	    =   ctrl_in[:]->hyam(0:lvl-1)
	hbcofb	    =   ctrl_in[:]->hybm(0:lvl-1)
	ctrl_psfc   =   ctrl_in[:]->PS
	p0	        =   1000

;************************************************
; define other arguments required by vinth2p
;************************************************
; type of interpolation: 1 = linear, 2 = log, 3 = loglog
	interp = 2 

; is extrapolation desired if data is outside the range of PS
	extrap = False

      
;************************************************
; calculate T on pressure levels
;************************************************
; note, the 7th argument is not used, and so is set to 1.
;************************************************
	ctrl_var1p = vinth2p(ctrl_var1,hbcofa,hbcofb,plev,ctrl_psfc,interp,p0,1,extrap)

;************************************************
; Write the file
;************************************************

;Get dimsize
    dims=dimsizes(ctrl_var1p(0,:,:,:))
    nlvl=dims(0)
    nlat=dims(1)
    nlon=dims(2)
	
;Set fileoption    
    system("rm "+pdata_fn)
	fout = addfile(pdata_fn ,"c")  ; open output netCDF file
	setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =(/"time","lev_p","lat","lon"/)
    dimSizes    =(/-1,nlvl,nlat,nlon/)
    dimUnlim    =(/True,False,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    filevardef(fout,"time",typeof(ctrl_var1p&time),getvardims(ctrl_var1p&time))
    filevardef(fout,"lev_p",typeof(ctrl_var1p&lev_p),getvardims(ctrl_var1p&lev_p))
    filevardef(fout,"lat",typeof(ctrl_var1p&lat),getvardims(ctrl_var1p&lat))
    filevardef(fout,"lon",typeof(ctrl_var1p&lon),getvardims(ctrl_var1p&lon))
    filevardef(fout,"ZMDT",typeof(ctrl_var1p),getvardims(ctrl_var1p))

;Define Attribute
    filevarattdef(fout,"ZMDT",ctrl_var1p)
    
    fout->time=(/ctrl_var1p&time/)
    fout->lev_p=(/ctrl_var1p&lev_p/)
    fout->lat=(/ctrl_var1p&lat/)
    fout->lon=(/ctrl_var1p&lon/)
    fout->Z3=(/ctrl_var1p/)

end
