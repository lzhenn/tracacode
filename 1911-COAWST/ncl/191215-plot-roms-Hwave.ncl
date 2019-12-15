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
    casename="sen" 
    ocean_path="../data/1911-COAWST/joe_tc_"+casename+"/ocean_joe_tcs_his.nc"
    grid_path="../data/1911-COAWST/joe_tc_"+casename+"/wrfout_d01.nc"
    tc_track_path="../data/1911-COAWST/joe_tc_"+casename+"/tc_pos_slp.txt"
    g_font=0.02
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
   
    ctrl_in      = addfile (ocean_path, "r")   ; note the "s" of addfile
    
    ; get temp first layer
  	ctrl_var1  = ctrl_in->Hwave
    dims=dimsizes(ctrl_var1)
    dim_t=dims(0)
    dim_y=dims(1)
    dim_x=dims(2)
    

    ; parser time
    grid_in = addfile(grid_path,"r")
    time0 = wrf_user_getvar(grid_in,"Times", -1)
    xtime = wrf_times_c( time0, 1 ) 
    ;xtime = xtime+8 
    lc_date=cd_calendar(xtime, 0)
    year   = tointeger(lc_date(:,0))    ; Convert to integer for
    month  = tointeger(lc_date(:,1))    ; use sprinti 
    day    = tointeger(lc_date(:,2))
    hour   = tointeger(lc_date(:,3))
    minute = tointeger(lc_date(:,4))
    second = lc_date(:,5)

    date_str = month_abbr(month)+sprinti(" %0.2i ", day) + sprinti("%0.2iZ", hour) 
    lentime=dimsizes(xtime)

    ; parser lat lon
    lat2d = wrf_user_getvar(grid_in,"XLAT",  1)
    lon2d = wrf_user_getvar(grid_in,"XLONG", 1)
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    ctrl_var1(0,100,:)=(/ctrl_var1(0,100,:)+1e-3/)
    ; lets find the TC center!

    rec_tc = asciiread(tc_track_path,(/lentime,3/),"float"); (0)--lat, (1)--lon, (2)--slp
    
    res                   = True              ; plot mods desired
;---Resources for filled contour plot
 
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
  res@gsnRightString = "m"
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
;  res@mpGridLineColor        = "Gray30"


  res@mpOutlineOn             = True  ; Use outlines from shapefile
  polyres                   = True
  polyres@gsMarkerIndex     = 14          ; polymarker style
  polyres@gsMarkerSizeF     = 12.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "Black"          ; polymarker size

  ;---Resources for the polyline
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 3.0            ; line thickness   
  pres@gsLineColor      = "blue"         ; color of lines


  tres  = True
  tres@txFontHeightF = 0.015
  tres@txJust="TopLeft"
  tlat=13.0
  tlon=-33.0
 
res = wrf_map_resources(grid_in,res)


time_frame = 0
ampf=6
do while(time_frame .lt. dim_t)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    
    wks_type="png"
    wks_type@wkWidth=800
    wks_type@wkHeight=800
    wks = gsn_open_wks(wks_type,"../fig/"+casename+"_d01_HWave_"+sprinti("%0.3iH", 6*time_frame))      ; send graphics to PNG file

    gsn_define_colormap(wks,"wind_17lev")
    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = 0.          ; set min contour level
    res@cnMaxLevelValF        = 15.          ; set max contour level
    res@cnLevelSpacingF       = 1.          ; set contour interval
   

;  gsn_define_colormap(wks,"BlAqGrYeOrRe")
;    gsn_reverse_colormap(wks)
    res@gsnLeftString="HWave @ "+date_str(time_frame*ampf)
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,ctrl_var1(time_frame,:,:),res)
  
    ; center
    dum1    = gsn_add_polymarker(wks,plot,rec_tc(time_frame*ampf,1),rec_tc(time_frame*ampf,0),polyres)
    ;dum_text    = gsn_add_text(wks,plot,sprintf("Center SLP: %3.1f hPa", rec_tc(2, time_frame)),tlon,tlat,tres)
    if (time_frame .gt. 0) then
        dum_track=gsn_add_polyline(wks,plot, rec_tc(0:time_frame*ampf,1) , rec_tc(0:time_frame*ampf,0),pres)
    end if

    ;overlay(plot, plotv)
    draw(plot)
    frame(wks)
    print(""+time_frame)
    time_frame=time_frame+1
    ;delete(wks)
end do
end
