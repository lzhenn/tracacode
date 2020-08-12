;*******************************************************
; lcnative_2.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
begin
;************************************************
; open file and read in data
;************************************************
    wrfout_path="/disk/v092.yhuangci/lzhenn/1911-COAWST/ERA5_WRFROMS_add"
    g_font=0.02
    figname="domain_terrain"
    
    d01_out=wrfout_path+"/wrfout_d01"
    d02_out=wrfout_path+"/wrfout_d02"
    d01_hdl=addfile(d01_out,"r")
    d02_hdl=addfile(d02_out,"r")
    d01_hgt = wrf_user_getvar(d01_hdl,"HGT", 0)  
    
    droms_out=wrfout_path+"/gba_ocean_his.nc"
    ; --------Ocean grid file
    ocn_in     = addfile(droms_out, "r")
    roms_lon2d=ocn_in->lon_rho
    roms_lat2d=ocn_in->lat_rho
     
    roms_nx        = dimsizes(roms_lat2d(:,0))
    roms_ny        = dimsizes(roms_lat2d(0,:))

    ; parser lake/ocean
    d01_lake = wrf_user_getvar(d01_hdl,"LAKEMASK", 0)  
    d01_land = wrf_user_getvar(d01_hdl,"LANDMASK", 0)  
    d01_hgt = where(d01_land .eq.0, -2, d01_hgt)
    d01_hgt = where(d01_lake .eq.1, -1, d01_hgt)
    
        
    ; parser lat lon
    d01_lat2d = wrf_user_getvar(d01_hdl,"XLAT",  0)
    d01_lon2d = wrf_user_getvar(d01_hdl,"XLONG", 0)
    d01_hgt@lat2d = d01_lat2d
    d01_hgt@lon2d = d01_lon2d
    
    d02_lat2d = wrf_user_getvar(d02_hdl,"XLAT",  0)
    d02_lon2d = wrf_user_getvar(d02_hdl,"XLONG", 0)
   
    nx        = dimsizes(d02_lat2d(:,0))
    ny        = dimsizes(d02_lat2d(0,:))


    res                   = True              ; plot mods desired
    ;---Resources for filled contour plot
    res@cnLevelSelectionMode  = "ExplicitLevels" ; set manual contour levels
    res@cnLevels = (/0, 20, 50, 100, 150, 200, 250, 300, 350, 400, 150, 500, 550, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1700, 2000, 2500, 3000, 3500, 4000, 4500/) ; fake values to erease shading colors
;    res@cnLevels := ispan(0,4500,50) ; fake values to erease shading colors
;    res@lbLabelStrings      =(/"Ocn","Lake","100","2000"/)
     ;change the water color lighter
    color_table="OceanLakeLandSnow"
    cmap = read_colormap_file(color_table)    ; returns 254 x 4 array
    cmap:=span_color_rgba(cmap,dimsizes(res@cnLevels)+1)
    cmap(0,:)=(/0.5,0.8,1.0,1.0/)
    
    res_tmp=True
    res_tmp@gsnFrame = False
    res_tmp@gsnDraw = False

    res=res_tmp
    res@cnFillOn             = True  
    res@cnLinesOn            = False
    res@cnFillColors=cmap
    res@lbOrientation        = "Vertical"
    res@cnFillMode           = "CellFill" ; Raster Mode
    
    res@gsnSpreadColors      = True               ; use full color map
    res@gsnLeftString="Domain Configuration for the GBA"
    res@gsnRightString = "m"
    res@gsnStringFontHeightF = g_font 
    res@gsnPaperOrientation = "portrait"

    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    
    mpres=res_tmp
    mpres@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
    mpres@mpGridLineDashPattern  = 2                ; Dashed lines
    mpres@mpGridSpacingF         = 5.0 
    mpres@mpGridLineThicknessF   = 2.0
    mpres@mpGridLineColor        = "Gray60"
    mpres@mpOutlineOn             = True  ; Use outlines from shapefile
    mpres@mpGeophysicalLineColor      = "Black"
    mpres@mpGeophysicalLineThicknessF=3.0

  
  ;mpres@cnFillDrawOrder         = "PreDraw"
  ;  mpres@mpDataBaseVersion       = "MediumRes"
  ;  mpres@mpDataSetName           = "Earth..4"

    mpres = wrf_map_resources(d01_hdl,mpres)
    
    ;---Resources for the polyline
    pres                  = True           ; polyline mods desired
    pres@gsLineThicknessF = 5.0            ; line thickness   
    pres@gsLineColor      = "red"         ; color of lines
   

    wks_type="png"
    wks_type@wkWidth=1600
    wks_type@wkHeight=1600
    wks = gsn_open_wks(wks_type,"../fig/"+figname)      ; send graphics to PNG file
    ;---Call plotting routine which draws contours over a map
    pmap=gsn_csm_map(wks,mpres) 
    plot = gsn_csm_contour(wks,d01_hgt,res)
      
      




    overlay(pmap, plot)
    ;-- draw edges for wrf d02
    lower = gsn_add_polyline(wks, plot, d02_lon2d(0,:), d02_lat2d(0,:), pres)
    upper = gsn_add_polyline(wks, plot, d02_lon2d(nx-1,:), d02_lat2d(nx-1,:), pres)
    left = gsn_add_polyline(wks, plot, d02_lon2d(:,0), d02_lat2d(:,0), pres)
    right = gsn_add_polyline(wks, plot, d02_lon2d(:,ny-1), d02_lat2d(:,ny-1), pres)
    
    
    ;-- draw edges for roms domain
    roms_pres=pres
    roms_pres@gsLineColor="blue"
    roms_pres@gsLineDashPattern=1
    
    roms_lower = gsn_add_polyline(wks, plot, roms_lon2d(0,:), roms_lat2d(0,:), roms_pres)
    roms_upper = gsn_add_polyline(wks, plot, roms_lon2d(roms_nx-1,:), roms_lat2d(roms_nx-1,:), roms_pres)
    roms_left = gsn_add_polyline(wks, plot, roms_lon2d(:,0), roms_lat2d(:,0), roms_pres)
    roms_right = gsn_add_polyline(wks, plot, roms_lon2d(:,roms_ny-1), roms_lat2d(:,roms_ny-1), roms_pres)

;    overlay(pmap, plot_d02)
    draw(pmap)
    frame(wks)
    ;delete(wks)
    ;break
end
