load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
;load "$NCL_SELFLIB/cnmap-zhenning/cnmap.ncl"
begin
    g_font=0.015
   
    roms_grid_in=addfile("/users/b145872/project-dir/app/COAWST-GBA/Projects/GBA/coawst_clm.nc","w")
    var=roms_grid_in->v(0,:,:,:)
    lat_rho=roms_grid_in->lat_rho
    lon_rho=roms_grid_in->lon_rho
    
    var@lat2d=lat_rho
    var@lon2d=lon_rho
    res=True
    ;---Resources for filled contour plot
    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = -10.          ; set min contour level
    res@cnMaxLevelValF        = 10.          ; set max contour level
    res@cnLevelSpacingF       = 1.          ; set contour interval


    res@gsnMaximize          = True
    res@gsnFrame = False
    res@gsnDraw = False
    res@cnFillOn             = True  
    res@cnLinesOn            = False
    ;res@cnLevelSpacingF      = 2.           ; NCL chose 4.0
    res@lbOrientation        = "Vertical"

    ;---Necessary for contours to be overlaid correctly on WRF projection
    res@tfDoNDCOverlay       = True
    res@gsnAddCyclic         = False
    res@cnFillMode           = "CellFill" ; Raster Mode
    res@gsnSpreadColors      = True               ; use full color map
    res@gsnRightString = "m"
    res@gsnStringFontHeightF = g_font 
    res@gsnPaperOrientation = "portrait"
    res@cnFillMode           = "CellFill" ; Raster Mode

    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = 0.02              ; make labels smaller
    res@tmYLMajorLengthF = 0.01
    res@tmXBMajorLengthF = 0.01
    ;res@lbLabelStride = 1  
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
    res@mpGridLineDashPattern  = 2                ; Dashed lines
    res@mpGridSpacingF         = 2.0 
    res@mpGridLineThicknessF   = 2.0
    res@mpMinLatF=min(lat_rho)
    res@mpMaxLatF=max(lat_rho)
    res@mpMinLonF=min(lon_rho)
    res@mpMaxLonF=max(lon_rho)
    ;  res@mpGridLineColor        = "Gray30"


    res@mpOutlineOn             = False  ; Use outlines from shapefile
    res@cnFillDrawOrder         = "PreDraw"
    res@mpDataBaseVersion       = "MediumRes"
    res@mpDataSetName           = "Earth..4"
    res@mpAreaMaskingOn         = True
;    res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
    res@mpLandFillColor         = "white"
    res@mpInlandWaterFillColor  = "white"

   
    wks_type="png"
    wks_type@wkWidth=800
    wks_type@wkHeight=800
    wks = gsn_open_wks(wks_type,"../../fig/roms_clm")      ; send graphics to PNG file
    gsn_define_colormap(wks,"wind_17lev")
    res@gsnLeftString="ETOPO Bathemetry"

    ;>============================================================<
    ;                      add China map
    ;>------------------------------------------------------------<
    cnres           = True
    cnres@china     = False       ;draw china map or not
    cnres@river     = False       ;draw changjiang&huanghe or not
    cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
    cnres@nanhai    = False       ;draw nanhai or not 
    cnres@diqu      = False       ; draw diqujie or not


    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,var(15,:,:),res)
    ;chinamap = add_china_map(wks,plot,cnres)
    
    draw(plot)
    frame(wks)
end
