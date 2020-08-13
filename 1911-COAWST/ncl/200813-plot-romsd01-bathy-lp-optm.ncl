load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
;load "$NCL_SELFLIB/cnmap-zhenning/cnmap.ncl"
begin
    g_font=0.015
    figname="domain_terrain_droms_chg"
   
    roms_grid_in=addfile("/disk/v092.yhuangci/lzhenn/1911-COAWST/ERA5_WAOFF/gba_ocean_his.nc","w")
    roms_chg_in=addfile("/disk/v092.yhuangci/lzhenn/1911-COAWST/ERA5_WRFROMS_add/gba_ocean_his.nc","w")
    lat_rho=roms_grid_in->lat_rho
    lon_rho=roms_grid_in->lon_rho
    h_org=roms_grid_in->h
    h_chg=roms_chg_in->h

    ;land mask
    lsmask=roms_grid_in->mask_rho
    

    dims=dimsizes(h_org)
    dim_x=dims(0)
    dim_y=dims(1)

    h_org@lat2d=lat_rho
    h_org@lon2d=lon_rho
    h_chg@lat2d=lat_rho
    h_chg@lon2d=lon_rho
    h_org=(/-h_org/)   
    h_chg=(/-h_chg/)   
    
    h_org@_FillValue=-999
    h_org = where((lsmask .eq. 0) , h_org@_FillValue, h_org)
    h_diff=h_org
    h_diff=h_chg-h_org

    res                   = True              ; plot mods desired
    ;---Resources for filled contour plot
    res@cnLevelSelectionMode  = "ExplicitLevels" ; set manual contour levels
    res@cnLevels = (/-500, -400, -300, -200, -100, -50, -20,  20,50 ,100, 200, 300, 400, 500 /) ; fake values to erease shading colors
;    res@cnLevels := ispan(0,4500,50) ; fake values to erease shading colors
;    res@lbLabelStrings      =(/"Ocn","Lake","100","2000"/)
     ;change the water color lighter
   
    res_tmp=True
    res_tmp@gsnFrame = False
    res_tmp@gsnDraw = False

    res=res_tmp
    res@cnFillOn             = True  
    res@cnLinesOn            = False
    res@cnFillMode           = "CellFill" ; Raster Mode
    
    res@gsnSpreadColors      = True               ; use full color map
    res@gsnLeftString="LP Optimized Bathymetry"
    res@gsnRightString = "m"
    res@gsnStringFontHeightF = g_font 
;    res@gsnPaperOrientation = "portrait"

    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font

  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  ;res@lbLabelStride = 1  
  
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font

  res@mpMinLatF=min(lat_rho)
  res@mpMaxLatF=max(lat_rho)
  res@mpMaxLonF=max(lon_rho)
  res@mpMinLonF=min(lon_rho)

  
  
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines
  res@mpGridSpacingF         = 5.0 
  res@mpGridLineThicknessF   = 2.0
  res@mpGridLineColor        = "Gray30"

  res@mpGeophysicalLineColor = "gray10"
  res@mpDataBaseVersion       = "MediumRes"
  res@mpDataSetName           = "Earth..4"
  res@mpLandFillColor         = "gray"
  res@mpGeophysicalLineThicknessF = 4.0
  res@mpOutlineOn             = True  ; Use outlines from shapefile   
    
    wks_type="png"
    wks_type@wkWidth=1200
    wks_type@wkHeight=1200
    wks = gsn_open_wks(wks_type,"../fig/"+figname)      ; send graphics to PNG file
    gsn_define_colormap(wks,"BlWhRe")
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,h_diff,res)

    
    draw(plot)
    frame(wks)
end
