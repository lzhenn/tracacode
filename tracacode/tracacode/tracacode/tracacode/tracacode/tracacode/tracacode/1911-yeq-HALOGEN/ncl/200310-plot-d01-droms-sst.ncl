;*******************************************************
; lcnative_2.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin
;************************************************
; open file and read in data
;************************************************
    casename="cpl" 
    multi_in=True
    wrfout_path="/disk/v092.yhuangci/coawst/"+casename
    roms_path="/disk/v092.yhuangci/coawst/cpl/gba_ocean_avg.nc"
    g_font=0.02
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
 "Oct","Nov","Dec"/)
  
    ; Ocean grid file
    ocn_in     = addfile(roms_path, "r")
    lon2d_roms=ocn_in->lon_rho
    lat2d_roms=ocn_in->lat_rho

    dimz=dimsizes(lat2d_roms)
 
    if multi_in then
        all_files=systemfunc("ls "+wrfout_path+"/wrfout_d01*")
        ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
    else
        ctrl_in      = addfile (wrfout_path, "r")   ; note the "s" of addfile
    end if

    ; get sst
  	ctrl_var1  = wrf_user_getvar(ctrl_in,"SST", -1)  
    dims:=dimsizes(ctrl_var1)
    dim_t=dims(0)
    dim_y=dims(1)
    dim_x=dims(2)
    
    ;ctrl_var2  = wrf_user_getvar(ctrl_in,"U10", -1)  
	;ctrl_var3  = wrf_user_getvar(ctrl_in,"V10", -1)  
    

    ; parser time
    time0 = wrf_user_getvar(ctrl_in,"Times", -1)
    xtime = wrf_times_c( time0, 1 ) 
    ;xtime = xtime+8 
    lc_date=cd_calendar(xtime, 0)
    year   = tointeger(lc_date(:,0))    ; Convert to integer for
    month  = tointeger(lc_date(:,1))    ; use sprinti 
    day    = tointeger(lc_date(:,2))
    hour   = tointeger(lc_date(:,3))
    minute = tointeger(lc_date(:,4))
    second = lc_date(:,5)

    date_str = month_abbr(month)+sprinti(" %0.2i ", day) + sprinti("%0.2iZ", hour) +sprinti("%0.2i:00", minute)
    lentime=dimsizes(xtime)

    ; parser lat lon
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    ctrl_var1=(/ctrl_var1-273.15/)   
    ctrl_var1(0,0,:)=(/ctrl_var1(0,0,:)+1e-2/)
    ; lets find the TC center!

   
  

    res                   = True              ; plot mods desired
;---Resources for filled contour plot
  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF        = 22.          ; set min contour level
  res@cnMaxLevelValF        = 30.          ; set max contour level
  res@cnLevelSpacingF       = 0.25          ; set contour interval
  
  res@gsnMaximize          = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@cnFillOn             = True  
  res@cnLinesOn            = False
  res@cnLevelSpacingF      = 2.           ; NCL chose 4.0
  res@lbOrientation        = "Vertical"

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay       = True
  res@gsnAddCyclic         = False
  res@cnFillMode           = "CellFill" ; Raster Mode
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnRightString = "degC"
  res@gsnStringFontHeightF = g_font 
  res@gsnMaximize      = True       ; fill up the page
  res@gsnPaperOrientation = "portrait"

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  res@lbLabelStride = 2  
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines
  res@mpGridSpacingF         = 10.0 
  res@mpGridLineThicknessF   = 2.0
  res@mpGridLineColor        = "Gray20"

  res@mpGeophysicalLineColor = "gray10"
  res@mpDataBaseVersion       = "MediumRes"
  res@mpDataSetName           = "Earth..4"
  res@mpLandFillColor         = "gray70"

  res@cnFillDrawOrder         = "PreDraw"
  res@mpOutlineOn             = True  ; Use outlines from shapefile
  polyres                   = True
  polyres@gsMarkerIndex     = 14          ; polymarker style
  polyres@gsMarkerSizeF     = 12.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "Black"          ; polymarker size

  ;---Resources for the polyline
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 3.0            ; line thickness   
  pres@gsLineColor      = "red"         ; color of lines


  tres  = True
  tres@txFontHeightF = 0.015
  tres@txJust="TopLeft"
  tlat=13.0
  tlon=-33.0
 
  resv                         = True               ; plot mods desired
  resv@vcGlyphStyle            = "WindBarb"         ; choose wind barbs
;  resv@lbOrientation           = "vertical"         ; vertical label bar
  resv@gsnDraw = False
  resv@gsnFrame = False
  resv@vcRefMagnitudeF         = 5.                ; make vectors larger
  resv@vcRefLengthF            = 0.015              ; ref vec length
  resv@vcMinDistanceF          = 0.03              ; thin out windbarbs
  resv@vcWindBarbLineThicknessF = 3.
  resv@vcWindBarbColor = "grey50"
  resv@vcWindBarbTickLengthF   = 0.5                ; length of the barb tick
  resv@vcWindBarbTickSpacingF  = 0.3                ; distance between ticks
  resv@vcRefAnnoOn             = False              ; turn off ref wind barb
  resv@gsnLeftString = ""
  resv@gsnRightString= ""
  resv@gsnAddCyclic            = False              ; regional data

  if multi_in then
    res = wrf_map_resources(ctrl_in[0],res)
  else
    res = wrf_map_resources(ctrl_in,res)
  end if
  obv_polyres=polyres
  obv_polyres@gsMarkerIndex     = 16          ; polymarker style
  obv_polyres@gsMarkerSizeF     = 9.          ; polymarker size


x_max=dimz(0)-1
y_max=dimz(1)-1
yy_roms = (/lon2d_roms(0,0),lon2d_roms(0,y_max),lon2d_roms(x_max,y_max),lon2d_roms(x_max,0),lon2d_roms(0,0)/)
xx_roms = (/lat2d_roms(0,0),lat2d_roms(0,y_max),lat2d_roms(x_max,y_max),lat2d_roms(x_max,0),lat2d_roms(0,0)/)

;Outer Box
    res_roms=True
    res_roms@gsLineColor       = "black"
    res_roms@gsLineDashPattern = 1.
    res_roms@gsLineThicknessF  = 4.                    ; line thicker


time_frame = 0
do while(time_frame .lt. lentime)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    
    wks_type="png"
    wks_type@wkWidth=800
    wks_type@wkHeight=800

    wks = gsn_open_wks(wks_type,"../fig/"+casename+"_d01_sst_"+sprinti("%0.3iFrm", time_frame))      ; send graphics to PNG file

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = 24.          ; set min contour level
    res@cnMaxLevelValF        = 31.          ; set max contour level
    res@cnLevelSpacingF       = 0.1          ; set contour interval
  

;  gsn_define_colormap(wks,"BlAqGrYeOrRe")
;    gsn_reverse_colormap(wks)
    res@gsnLeftString="SST @ "+date_str(time_frame)
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,ctrl_var1(time_frame,:,:),res)
    dum_roms =gsn_add_polyline(wks,plot,yy_roms,xx_roms,res_roms)              ; N
 
    ;overlay(plot, plotv)
    draw(plot)
    frame(wks)
    time_frame=time_frame+1
    ;delete(wks)
end do
end
