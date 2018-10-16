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
    pre_dir="/home/yangsong3/zwx/SST.mean.nc"
    out_dir="/home/yangsong3/zwx/nudging_TEMP.nc"
    
    ctrl_in = addfile (pre_dir, "r")
    output_in= addfile (out_dir, "w")

    var1=ctrl_in->SST
    var2=output_in->WGT_365
    
    
    
    guess     = 1                ; use zonal means
    is_cyclic = True             ; cyclic [global]
    nscan     = 1500             ; usually much less than this
    eps       = 1.e-2            ; variable dependent
    relc      = 0.6              ; relaxation coefficient
    opt       = 0                ; not used
    ;poisson_grid_fill( var1, is_cyclic, guess, nscan, eps, relc, opt) 

    lat2d=output_in->TLAT
    lon2d=output_in->TLONG
    var1@lat2d=lat2d
    var1@lon2d=lon2d
;    delete([/var1@_FillValue, var2@_FillValue/])
    var2=1.0
;    do itime=0,364
;        var2(itime,:,:)=where((lat .lt. 50.0) .and. (lat .gt. -50.0), 1.0, 0.0)
;        var2(itime,:,:)=where((lat .gt. 50.0) .and. (lat .lt. 52.0), 0.8, var2(itime,:,:))
;        var2(itime,:,:)=where((lat .gt. 52.0) .and. (lat .lt. 54.0), 0.6, var2(itime,:,:))
;        var2(itime,:,:)=where((lat .gt. 54.0) .and. (lat .lt. 56.0), 0.4, var2(itime,:,:))
;        var2(itime,:,:)=where((lat .gt. 56.0) .and. (lat .lt. 58.0), 0.2, var2(itime,:,:))
;        
;        var2(itime,:,:)=where((lat .lt. -50.0) .and. (lat .gt. -52.0), 0.8, var2(itime,:,:))
;        var2(itime,:,:)=where((lat .lt. -52.0) .and. (lat .gt. -54.0), 0.6, var2(itime,:,:))
;        var2(itime,:,:)=where((lat .lt. -54.0) .and. (lat .gt. -56.0), 0.4, var2(itime,:,:))
;        var2(itime,:,:)=where((lat .lt. -56.0) .and. (lat .gt. -58.0), 0.2, var2(itime,:,:))
;    end do
;    var2 = where(var1(0:364,:,:) .lt.-999.9,0.0,var2)
;    var1 = where(var1 .lt.-999.9,-250.0,var1)

;    output_in->WGT_365=(/var2/)
;    output_in->TEMP_365=(/var1(0:364,:,:)/)
    
    wks  = gsn_open_wks("x11","../fig/pop-tracer")            ; send graphics to PNG file
    cmap = read_colormap_file("BlAqGrYeOrRe")       ; read color data
    res                      = True                 ; plot mods desired
    res@gsnDraw              = False                ; don't draw yet
    res@gsnFrame             = False                ; don't advance frame yet
    res@cnFillOn             = True                 ; turn on color fill
    res@cnLinesOn            = False                ; turn off contour lines
    res@cnLineLabelsOn       = False                ; turn off contour line labels
    res@cnFillMode           = "CellFill"
    plot = gsn_csm_contour_map(wks,var1(3,:,:),res)  
    draw(plot)
    frame(wks)
end
