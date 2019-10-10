;*************************************************************
;Aim: take 3D clim field from post CAM output
;Mission:
;   1. Read post processed data
;   2. Calculate climatology
;   3. High effeciency output to nc file
;                       Zhenning Li
;         Last modified: 2017-04-01 
;Last Edited:
;   2015-09-21  Create
;   2017-04-03  Modify to fit clim output
;*************************************************************




load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"
begin
    pre_dir="/users/yangsong3/zwx/CESM/zwx_B20f19_heatf_2015F1/exe/zwx_B20f19_heatf_2015F1.pop.h.nday1.0250-07-01.nc"
    
    ctrl_in = addfile (pre_dir, "r")

    var1=ctrl_in->SST
    var1@lat2d=ctrl_in->ULAT
    var1@lon2d=ctrl_in->ULONG
    wks  = gsn_open_wks("x11","../fig/pop-tracer")            ; send graphics to PNG file
    cmap = read_colormap_file("BlAqGrYeOrRe")       ; read color data
    res                      = True                 ; plot mods desired
    res@gsnDraw              = False                ; don't draw yet
    res@gsnFrame             = False                ; don't advance frame yet
    res@cnFillOn             = True                 ; turn on color fill
    res@cnLinesOn            = False                ; turn off contour lines
    res@cnLineLabelsOn       = False                ; turn off contour line labels
    res@cnFillMode           = "CellFill"
    do ii=0,30
        res@gsnLeftString="Day:"+(ii)
        plot = gsn_csm_contour_map(wks,var1(ii,:,:),res)  
        draw(plot)
        frame(wks)
    end do
end
