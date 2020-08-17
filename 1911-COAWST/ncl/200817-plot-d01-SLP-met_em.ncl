;*******************************************************
; lcnative_2.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCL_SELFLIB/cnmap/cnmap.ncl"
begin
;************************************************
; open file and read in data
;************************************************
    casename="mangkhut" 
    met_em_path="/users/b145872/project-dir/app/WPS/era5-met_em/met_em.d01.2018-09-13_12:00:00.nc"
    fig_prefix="met_em_SLP_"
    g_font=0.03
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
    
    
    ; get wrf fully coupled nc data
    ctrl_in      = addfile (met_em_path, "r")   ; note the "s" of addfile
    
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
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  0)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 0)
  
    rec_tc=new((/3,lentime/), "float") ; (0)--lat, (1)--lon, (2)--slp
    
       
  res                   = True              ; plot mods desired
;---Resources for filled contour plot
  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF        = 920.          ; set min contour level
  res@cnMaxLevelValF        = 1000.          ; set max contour level
  res@cnLevelSpacingF      = 4.        
  
  res@gsnMaximize          = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@cnFillOn             = True  
  res@cnLinesOn            = False
  res@lbOrientation        = "Vertical"

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay       = True
  res@gsnAddCyclic         = False
  res@cnFillMode           = "CellFill" ; Raster Mode
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnRightString = "hPa"
  res@gsnStringFontHeightF = g_font 
  res@gsnMaximize      = True       ; fill up the page
  res@gsnPaperOrientation = "portrait"

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
  res@mpGridSpacingF         = 5.0 
  res@mpGridLineThicknessF   = 2.0
  res@mpGridLineColor        = "Gray60"


    res@mpOutlineOn             = True  ; Use outlines from shapefile
    res@mpGeophysicalLineColor = "gray"
    res@cnFillDrawOrder         = "PreDraw"
    res@mpDataBaseVersion       = "MediumRes"
    res@mpDataSetName           = "Earth..4"
    res@mpGeophysicalLineThicknessF = 2.0
    res@mpLandFillColor         = "gray80"
    res@mpInlandWaterFillColor  = "white"
;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = False       ; draw diqujie or not


  
  polyres                   = True
  polyres@gsMarkerIndex     = 14          ; polymarker style
  polyres@gsMarkerSizeF     = 12.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "Black"          ; polymarker size

  obv_polyres=polyres
  obv_polyres@gsMarkerIndex     = 16          ; polymarker style
  obv_polyres@gsMarkerSizeF     = 9.          ; polymarker size


  ;---Resources for the polyline
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 3.0            ; line thickness   
  pres@gsLineColor      = "red"         ; color of lines
  pres_wrf=pres
  pres_wrf@gsLineColor="blue"

  tres  = True
  tres@txFontHeightF = 0.035
  tres@txJust="TopLeft"
  tlat=10.0
  tlon=100.0
 
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


    res = wrf_map_resources(ctrl_in,res)


    time_frame = 0
    wks_type="png"
    wks_type@wkWidth=800
    wks_type@wkHeight=800



do while(time_frame .lt. lentime)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
   ; get slp
  	ctrl_var1  = wrf_user_getvar(ctrl_in,"PMSL", time_frame)  
    ctrl_var1=(/ctrl_var1/100.0/)
    dims:=dimsizes(ctrl_var1)
    dim_y=dims(0)
    dim_x=dims(1)
    
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
 
    tmp1D      = ndtooned(ctrl_var1)
    indices  = ind_resolve(minind(tmp1D),(/dim_y,dim_x/))
    id_y=indices(0,0)
    id_x=indices(0,1)
    rec_tc(0,time_frame)=lat2d(id_y,id_x)
    rec_tc(1,time_frame)=lon2d(id_y,id_x)
    rec_tc(2,time_frame)=min(tmp1D)
    print("lat: "+rec_tc(0,time_frame)+" lon: "+rec_tc(1,time_frame)+" minSLP= "+min(tmp1D))

   
    wks = gsn_open_wks(wks_type,"../fig/mangkhut/"+fig_prefix+sprinti("%0.3iFrm", time_frame))      ; send graphics to PNG file
    gsn_define_colormap(wks,"wind_17lev")
    gsn_reverse_colormap(wks)
    res@gsnLeftString="ERA5 SLP @ "+date_str(time_frame)
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,ctrl_var1,res)
    chinamap = add_china_map(wks,plot,cnres)
  
    ; center
    ;dum1    = gsn_add_polymarker(wks,plot,tc_loc(3,1),tc_loc(3,0),polyres)
    dum1    = gsn_add_polymarker(wks,plot,rec_tc(1,time_frame),rec_tc(0,time_frame),polyres)
    dum_text    = gsn_add_text(wks,plot,sprintf("Center SLP: %3.1f hPa", rec_tc(2, time_frame)),tlon,tlat,tres)
    if (time_frame .gt. 0) then
        dum_track=gsn_add_polyline(wks,plot, rec_tc(1, 0:time_frame) , rec_tc(0,0:time_frame),pres)
    end if

    ;Obv Track
    res_lines=True
    res_lines@gsLineColor       = "black"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    

    ;overlay(plot, plotv)
    draw(plot)
    frame(wks)
    time_frame=time_frame+1
    ;delete(wks)
    ;break
end do
end
