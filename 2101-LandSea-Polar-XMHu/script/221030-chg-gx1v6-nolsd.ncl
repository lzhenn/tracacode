
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin


	latS    =   -90.0
	latN    =   90.0
    lonL    =   0
    lonR    =   360.
   
    data_file_in   =   "/home/lzhenn/temp/Drake_Closure/gx1v6_chg_210211.nc"
    data_file_out   =   "/home/lzhenn/temp/NO_LSD/gx1v6_chg_221030.nc"
    latlon_in="/home/lzhenn/temp/Drake_Closure/domain.ocn.gx1v6.210211.nc"
    latlonf=addfile(latlon_in,"r") 
    lat2d     = latlonf->yc
    lon2d     = latlonf->xc
   

;------------------Read clim sst-------------------------------
    ctrl_in1     = addfile (data_file_in, "r")   ; note the "s" of addfile
    idx  = ctrl_in1->grid_imask			; p for unify the var name
    idx:=reshape(idx, (/384,320/))
    ;idx@lat2d=lat2d
    ;idx@lon2d=lon2d
    idx=1
    idx(0:1,:)=0 
    idx(382:383,:)=0 
    wks  = gsn_open_wks("png","pop-tracer")            ; send graphics to PNG file
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
