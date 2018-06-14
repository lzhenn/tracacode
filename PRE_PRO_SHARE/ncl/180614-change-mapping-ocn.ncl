;************************************************************
;Aim: Regression SST anomaly from TCP_index, and insert these 
;     anomalies to clim SST
;     
;
;Mission:
;   1. Read index data from ascii file, read sst data
;   2. Post process
;       2.1 Regression NINO3
;       2.2 Departure NINO3 signal from Anomaly pattern
;       2.3 Detrend
;       2.4 Regression TCP
;
;   3. Draw patterns 
;   4. Output SST forcing field
;                       Zhenning Li
;                       2015-01-18
;Last Edited:
;   2015-01-18  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin


;================================================
;Variables List:
;   var1--------------CAM used sst
;   index1------------TCP index
;   index2------------NINO3 index
;================================================

;SCS-PhS region
    

	latS    =   -90.0
	latN    =   90.0
    lonL    =   0
    lonR    =   360.
   
    data_file_in   =   "/users/yangsong3/CESM/input/share/scripgrids/gx1v6_090205.nc"
    data_file_out   =   "/users/yangsong3/CESM/input/share/scripgrids/gx1v6_aqua_polar_180614.nc"
    latlon_in="/users/yangsong3/L_Zealot/B/B20f19-realworld/exe/B20f19-realworld.pop.h.0021-04.nc"
    latlonf=addfile(latlon_in,"r") 
    lat2d     = latlonf->TLAT
    lon2d     = latlonf->TLONG
   

;------------------Read clim sst-------------------------------
    ctrl_in1     = addfile (data_file_in, "r")   ; note the "s" of addfile
    idx  = ctrl_in1->grid_imask			; p for unify the var name
    idx:=reshape(idx, (/384,320/))
    ;idx@lat2d=lat2d
    ;idx@lon2d=lon2d
    idx=1
    idx(0:1,:)=0 
    idx(382:383,:)=0 
    wks  = gsn_open_wks("x11","../fig/pop-tracer")            ; send graphics to PNG file
    cmap = read_colormap_file("BlAqGrYeOrRe")       ; read color data
    res                      = True                 ; plot mods desired
    res@gsnDraw              = False                ; don't draw yet
    res@gsnFrame             = False                ; don't advance frame yet
    res@cnFillOn             = True                 ; turn on color fill
    res@cnLinesOn            = False                ; turn off contour lines
    res@cnLineLabelsOn       = False                ; turn off contour line labels
    res@cnFillMode           = "CellFill"
    res@gsnLeftString = "PURE_AQUA SURF T"
    res@gsnRightString = "degC"
    plot = gsn_csm_contour_map(wks,idx,res)  
    draw(plot)
    frame(wks)

    printVarSummary(idx)
    idx:=reshape(idx, (/122880/))
    ncdf     = addfile(data_file_out ,"w")  ; open output netCDF file
    ncdf->grid_imask=idx
end
