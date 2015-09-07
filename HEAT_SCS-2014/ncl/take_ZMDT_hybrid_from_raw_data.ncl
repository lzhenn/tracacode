

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    case_name   =   "HEATSEN"
    exedir      =   "sen_mon"
    lvl         =   26
    period      =   "0001-0030"
    plev        =   (/925.0, 850.0, 700.0, 600.0, 500.0, 400.0, 300.0, 200.0, 100.0, 50.0/)
    pdata_fn    =   "../post_data/"+case_name+".ZMDT.hybrid.mon."+period+".nc"

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls ../"+case_name+"/"+exedir+"/*cam.h0.00[0-3]*")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
    ctrl_var1 = ctrl_in[:]->ZMDT


;************************************************
; High Efficiency to Write the file
;************************************************

;Get dimsize
    dims=dimsizes(ctrl_var1(0,0,:,:))
    nlat=dims(0)
    nlon=dims(1)
	
;Set fileoption    
    system("rm "+pdata_fn)
	fout = addfile(pdata_fn ,"c")  ; open output netCDF file
	setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =(/"time","lev","lat","lon"/)
    dimSizes    =(/-1,lvl,nlat,nlon/)
    dimUnlim    =(/True,False,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    filevardef(fout,"time",typeof(ctrl_var1&time),getvardims(ctrl_var1&time))
    filevardef(fout,"lev",typeof(ctrl_var1&lev),getvardims(ctrl_var1&lev))
    filevardef(fout,"lat",typeof(ctrl_var1&lat),getvardims(ctrl_var1&lat))
    filevardef(fout,"lon",typeof(ctrl_var1&lon),getvardims(ctrl_var1&lon))
    filevardef(fout,"ZMDT",typeof(ctrl_var1),getvardims(ctrl_var1))

;Define Attribute
    filevarattdef(fout,"ZMDT",ctrl_var1)
    
    fout->time=(/ctrl_var1&time/)
    fout->lev=(/ctrl_var1&lev/)
    fout->lat=(/ctrl_var1&lat/)
    fout->lon=(/ctrl_var1&lon/)
    fout->ZMDT=(/ctrl_var1/)

end
