load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
;load "$NCL_SELFLIB/cnmap-zhenning/cnmap.ncl"
begin
    g_font=0.018
    figname="domain_terrain_droms_bouy"


    bouy_loc_fn="/disk/v092.yhuangci/lzhenn/1911-COAWST/obv/bouy/location.csv"
 
    ; bouy
    nbouy=5
    bouy_loc = asciiread(bouy_loc_fn,(/nbouy,3/),"float"); (0)--bouy name, (1)--lon, (2)--lat



    roms_grid_in=addfile("/disk/v092.yhuangci/lzhenn/1911-COAWST/ERA5_WAOFF/gba_ocean_his.nc","w")
    lat_rho=roms_grid_in->lat_rho
    lon_rho=roms_grid_in->lon_rho
    h=roms_grid_in->h
    
    
    
    d02_out="/disk/v092.yhuangci/lzhenn/1911-COAWST/ERA5_WAOFF//wrfout_d02"
    d02_hdl=addfile(d02_out,"r")
    d02_lat2d = wrf_user_getvar(d02_hdl,"XLAT",  0)
    d02_lon2d = wrf_user_getvar(d02_hdl,"XLONG", 0)
    nx        = dimsizes(d02_lat2d(:,0))
    ny        = dimsizes(d02_lat2d(0,:))


    ;land mask
    lsmask=roms_grid_in->mask_rho
    

    dims=dimsizes(h)
    dim_x=dims(0)
    dim_y=dims(1)

    h@lat2d=lat_rho
    h@lon2d=lon_rho
    h=(/-h/)   
    
    h = where(((lsmask .eq. 0) .and.(h .lt. 1)), 1.0, h)

    res                   = True              ; plot mods desired
    ;---Resources for filled contour plot
    res@cnLevelSelectionMode  = "ExplicitLevels" ; set manual contour levels
    res@cnLevels = (/-6000, -5500, -5000, -4500, -4000, -3500, -3100, -2800, -2600, -2400, -2200, -2000, -1900, \
                    -1800, -1700, -1600, -1500, -1400, -1300, -1200, -1100, -1000, -950 -900, -850, -800\
                    -750, -700, -650, -600, -550, -500, -450, -400, -350, -300, -250, -200,\
                    -150, -100, -50, -20,\
                    0, 50, 100,  200,  300,  400,  500, \
                    600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1700, \
                    2000, 2500, 3000, 3500, 4000, 4500/) ; fake values to erease shading colors
;    res@cnLevels := ispan(0,4500,50) ; fake values to erease shading colors
;    res@lbLabelStrings      =(/"Ocn","Lake","100","2000"/)
     ;change the water color lighter
    color_table="GMT_globe"
    cmap = read_colormap_file(color_table)    ; returns 254 x 4 array
    cmap:=cmap(0:200,:)
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
  res@mpLandFillColor         = "black"
  res@mpGeophysicalLineThicknessF = 4.0
  res@mpOutlineOn             = True  ; Use outlines from shapefile   
    
    wks_type="png"
    wks_type@wkWidth=1600
    wks_type@wkHeight=1600
    wks = gsn_open_wks(wks_type,"../fig/"+figname)      ; send graphics to PNG file
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,h,res)

    ;---Resources for the polyline
    pres                  = True           ; polyline mods desired
    pres@gsLineThicknessF = 6.0            ; line thickness   
    pres@gsLineColor      = "red"         ; color of lines
   

    
    ;-- draw edges for wrf d02
    lower = gsn_add_polyline(wks, plot, d02_lon2d(0,:), d02_lat2d(0,:), pres)
    upper = gsn_add_polyline(wks, plot, d02_lon2d(nx-1,:), d02_lat2d(nx-1,:), pres)
    left = gsn_add_polyline(wks, plot, d02_lon2d(:,0), d02_lat2d(:,0), pres)
    right = gsn_add_polyline(wks, plot, d02_lon2d(:,ny-1), d02_lat2d(:,ny-1), pres)
    
    

    
    
    draw(plot) 
    pmres = True
    
    pmres@gsMarkerIndex = 16

    ; outer border
    pmres@gsMarkerColor = "Black"
    pmres@gsMarkerSizeF = 0.018
    do ii = 0, nbouy-1
        gsn_polymarker(wks,plot,bouy_loc(ii,1),bouy_loc(ii,2),pmres)
        ;break
    end do

    ; inner border
    pmres@gsMarkerColor = "red3"
    pmres@gsMarkerSizeF = 0.014
    do ii = 0, nbouy-1
        gsn_polymarker(wks,plot,bouy_loc(ii,1),bouy_loc(ii,2),pmres)
        ;break
    end do
   
      tres  = True
      tres@txFontHeightF = 0.016
      tres@txFontThicknessF=8.
      tres@txFontColor="Black"
      tres@txJust="TopLeft"
      
      do ii = 0, nbouy-1
           tlat=bouy_loc(ii,2)-0.3
           tlon=bouy_loc(ii,1)-1.0
           gsn_text(wks,plot,bouy_loc(ii,0)+"",tlon,tlat,tres)
        ;break
      end do
      frame(wks)           ; lets frame the plot - do not delete
    
end
