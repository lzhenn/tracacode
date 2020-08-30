load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
;load "$NCL_SELFLIB/cnmap-zhenning/cnmap.ncl"
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
begin
    g_font=0.015
    figname="domain_terrain_droms02"
   
    roms_grid_in=addfile("/disk/v092.yhuangci/lzhenn/1911-COAWST/GBA_roms_grid.d02.nc","w")
    lat_rho=roms_grid_in->lat_rho
    lon_rho=roms_grid_in->lon_rho
    h=roms_grid_in->h

    ;land mask
    lsmask=roms_grid_in->mask_rho
    

    dims=dimsizes(h)
    dim_x=dims(0)
    dim_y=dims(1)

    h@lat2d=lat_rho
    h@lon2d=lon_rho
    
;    h = where(((lsmask .eq. 0) .and.(h .lt. 1)), 0.1, h)

    res                   = True              ; plot mods desired
    ;---Resources for filled contour plot
    res@cnLevelSelectionMode  = "ExplicitLevels" ; set manual contour levels
    res@cnLevels = (/-90, -85, -80, -75, -70, -65, -60, -55, -50, -45, -40, -36, -32, -28, -24, -22, -20, -18, -16, -14, -12, -10, -8, -6, -4, -2, 0,\
                    5, 10, 30, 60, 100, 150, 200, 300, 400, 500, 600/) ; fake values to erease shading colors
;    res@cnLevels := ispan(0,4500,50) ; fake values to erease shading colors
;    res@lbLabelStrings      =(/"Ocn","Lake","100","2000"/)
     ;change the water color lighter
    color_table="GMT_globe"
    cmap = read_colormap_file(color_table)    ; returns 254 x 4 array
    cmap:=cmap(0:180,:)
    cmap:=span_color_rgba(cmap,dimsizes(res@cnLevels)+1)
;    cmap(0,:)=(/0.5,0.8,1.0,1.0/)
    
    res_tmp=True
    res_tmp@gsnFrame = False
    res_tmp@gsnDraw = False

    res=res_tmp
    res@cnFillOn             = True  
    res@cnLinesOn            = False
    res@cnFillColors=cmap
    res@gsnMaximize          = True
    res@cnFillMode           = "CellFill" ; Raster Mode
    
    res@gsnSpreadColors      = True               ; use full color map
    res@gsnLeftString="Domain Configuration for the ROMS/SWAN"
    res@gsnRightString = "m"
    res@gsnStringFontHeightF = g_font 
;    res@gsnPaperOrientation = "portrait"

    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller

  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  res@tmXBMode = "Explicit"
  res@tmXBValues=fspan(112.5,115.0, 6)
  res@tmXBLabels=fspan(112.5,115.0, 6)+"E"

  res@tmYLMode = "Explicit"
  res@tmYLValues=fspan(21.5,23.0, 4)
  res@tmYLLabels=fspan(21.5,23.0, 4)+"N"

  ;res@lbLabelStride = 1  
  
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font

  res@mpMinLatF=min(lat_rho)
  res@mpMaxLatF=max(lat_rho)
  res@mpMaxLonF=max(lon_rho)
  res@mpMinLonF=min(lon_rho)

  
  
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines
  res@mpGridSpacingF         = 0.5 
  res@mpGridLineThicknessF   = 2.0
  res@mpGridLineColor        = "Gray20"

  res@mpGeophysicalLineColor = "gray10"
  res@mpDataBaseVersion       = "HighRes"
  res@mpLandFillColor         = "black"
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpOutlineOn             = True  ; Use outlines from shapefile   


;>============================================================<
 ;                      add China map
 ;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = True    ; draw diqujie or not
  cnres@county      = True       ; draw diqujie or not





    wks_type="png"
    wks_type@wkWidth=1200
    wks_type@wkHeight=1200
    wks = gsn_open_wks(wks_type,"../fig/"+figname)      ; send graphics to PNG file




;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,h,res)
    chinamap = add_china_map(wks,plot,cnres)

    
    draw(plot)
    frame(wks)
end
