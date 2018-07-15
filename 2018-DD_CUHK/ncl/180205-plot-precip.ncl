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
    lat0=23.20
    lon0=113.25
 
    wrfout_path="/users/yangsong3/L_Zealot/wrf/WRFV3/run/wrfout_d03*"
    g_font=0.015
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
   
	all_files = systemfunc ("ls "+wrfout_path)
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
    
    time0 = wrf_user_getvar(ctrl_in,"Times", -1)
    xtime = wrf_times_c( time0, 1 ) 
    xtime = xtime+8 

    lc_date=cd_calendar(xtime, 0)
    year   = tointeger(lc_date(:,0))    ; Convert to integer for
    month  = tointeger(lc_date(:,1))    ; use sprinti 
    day    = tointeger(lc_date(:,2))
    hour   = tointeger(lc_date(:,3))
    minute = tointeger(lc_date(:,4))
    second = lc_date(:,5)

    date_str = month_abbr(month)+sprinti(" %0.2i ", day) + sprinti("%0.2iH", hour) 
              

    lentime=dimsizes(xtime)
    
    ctrl_var1  = wrf_user_getvar(ctrl_in,"RAINC", -1)  
    ctrl_var2  = wrf_user_getvar(ctrl_in,"RAINNC", -1)  
    ctrl_var1  = (ctrl_var1+ctrl_var2)
    ctrl_var1(1:lentime-1,:,:)=ctrl_var1(1:lentime-1,:,:)-ctrl_var1(0:lentime-2,:,:)
   
 
    
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    point=getind_latlon2d(lat2d,lon2d,lat0,lon0)
    cor_x=point(0,0)
    cor_y=point(0,1)

   
   
   
   res                   = True              ; plot mods desired
;---Resources for filled contour plot
  
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
  res@cnLevels =    (/0.1, 0.5, 1, 2, 3, 5, 8, 12, 16, 20, 25, 30, 40, 50, 70, 100, 150/)
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
  res@gsnRightString = "mm/hr"
  res@gsnStringFontHeightF = g_font 
  res@gsnMaximize      = True       ; fill up the page
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
  res@mpGridSpacingF         = 0.5
  res@mpGridLineThicknessF   = 2.0
;  res@mpGridLineColor        = "Gray30"


res@mpOutlineOn             = False  ; Use outlines from shapefile
res@cnFillDrawOrder         = "PreDraw"
res@mpDataBaseVersion       = "MediumRes"
res@mpDataSetName           = "Earth..4"
res@mpAreaMaskingOn         = True
res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
res@mpLandFillColor         = "white"
res@mpInlandWaterFillColor  = "white"
res@gsnRightString = "mm/3hr"
;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = True       ; draw diqujie or not

  polyres                   = True
  polyres@gsMarkerIndex     = 14          ; polymarker style
  polyres@gsMarkerSizeF     = 11.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "Red"          ; polymarker size

  tres  = True
  tres@txFontHeightF = 0.012 
  tres@txJust="TopLeft"
  tlat=36.0
  tlon=121.0

  polymaxres=polyres
  polymaxres@gsMarkerIndex     = 5          ; polymarker style
  polymaxres@gsMarkerColor     = "red"          ; polymarker size
  polymaxres@gsMarkerThicknessF     = 5.          ; polymarker size

res = wrf_map_resources(ctrl_in[0],res)

time_frame = 3 
do while(time_frame .lt. lentime-1)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    wks_type="png"
    wks_type@wkWidth=800
    wks_type@wkHeight=800
    wks = gsn_open_wks(wks_type,"../fig/precip_"+sprinti("%0.3iH", time_frame))      ; send graphics to PNG file
    gsn_define_colormap(wks,"precip2_17lev")
    res@gsnLeftString="3hr Precipitation @ "+date_str(time_frame)
    ;---Call plotting routine which draws contours over a map
    sum_var1=dim_sum_n_Wrap(ctrl_var1(time_frame-2:time_frame,:,:), 0)
    plot = gsn_csm_contour_map(wks,sum_var1,res)
    chinamap = add_china_map(wks,plot,cnres)
    dum1    = gsn_add_polymarker(wks,plot,lon0,lat0,polyres)

    dims=dimsizes(sum_var1)
    var1D=ndtooned(sum_var1)
    max_value=max(var1D)
    inds = ind_resolve(maxind (var1D), dims)    ; convert 1D array back to 2D 
    ilat = inds(0,0)        ; select the latitude index where the X array is at its' maximum  
    ilon = inds(0,1)        ; select the longitude index where the X array is at its' maximum

    dum2    = gsn_add_text(wks,plot,sprintf("Precip Rate@Home: %3.1fmm/3hr~C~", sum_var1(cor_x, cor_y))+sprintf("Max Pricip Rate: %3.1fmm/3hr@(",sum_var1(ilat, ilon))+sprintf("%5.2fE, ", lon2d(ilat, ilon))+sprintf("%5.2fN)", lat2d(ilat, ilon)),tlon,tlat,tres)
    dummax    = gsn_add_polymarker(wks,plot,lon2d(ilat, ilon),lat2d(ilat, ilon),polymaxres)
    draw(plot)
    frame(wks)
    time_frame=time_frame+3
end do
end
