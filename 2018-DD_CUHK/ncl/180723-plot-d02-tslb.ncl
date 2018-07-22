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
    lat0=37.40
    lon0=121.56
 
    wrfout_path="/home/lzhenn/array/lzhenn/data/18-DD_CUHK/spinup/wrfout_d03_2018-06-06_00:00:00"
    ;wrfout_path="/home/lzhenn/array/lzhenn/data/18-DD_CUHK/process/wrfout_d03_2018-06-06_00:00:00"
    g_font=0.015
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
   
	all_files = systemfunc ("ls "+wrfout_path)
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	setfileoption("nc","SuppressClose",False) ; close too many files
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
    
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
    print(date_str)

    lentime=dimsizes(xtime)
  	ctrl_var1_0  = wrf_user_getvar(ctrl_in,"TSLB", -1)  
	ctrl_land  = wrf_user_getvar(ctrl_in,"XLAND", 0)  

    ctrl_var1 =(/ctrl_var1_0(:,1,:,:) - 273.15/)

 
    
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  0)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 0)
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    point=getind_latlon2d(lat2d,lon2d,lat0,lon0)
    cor_x=point(0,0)
    cor_y=point(0,1)

   
   
   
   res                   = True              ; plot mods desired
;---Resources for filled contour plot
  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF        = 22.          ; set min contour level
  res@cnMaxLevelValF        = 35.          ; set max contour level
  res@cnLevelSpacingF       = 0.25          ; set contour interval
  
  
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
  res@gsnRightString = "degC"
  res@gsnStringFontHeightF = g_font 
  res@gsnMaximize      = True       ; fill up the page
  res@gsnPaperOrientation = "portrait"
  res@cnFillMode           = "CellFill" ; Raster Mode

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  res@lbLabelStride = 4  
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

  polyminres = polymaxres
  polyminres@gsMarkerColor="blue"
res = wrf_map_resources(ctrl_in[0],res)

time_frame = 0
ctrl_var1@_FillValue=-999.
do while(time_frame .lt. lentime)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    
    ctrl_var1(time_frame,:,:)=where(ctrl_land .eq. 2, ctrl_var1@_FillValue, ctrl_var1(time_frame,:,:))
    wks_type="png"
    wks_type@wkWidth=800
    wks_type@wkHeight=800
    wks = gsn_open_wks(wks_type,"../fig/T25cm_"+sprinti("%0.3iH", time_frame))      ; send graphics to PNG file
    gsn_define_colormap(wks,"nice_gfdl")
    res@gsnLeftString="Skin Temp  @ "+date_str(time_frame)
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,ctrl_var1(time_frame,:,:),res)
    chinamap = add_china_map(wks,plot,cnres)
    dum1    = gsn_add_polymarker(wks,plot,lon0,lat0,polyres)

    dims=dimsizes(ctrl_var1(time_frame,:,:))
    var1D=ndtooned(ctrl_var1(time_frame,:,:))
    max_value=max(var1D)
    min_value=min(var1D)
    inds = ind_resolve(maxind (var1D), dims)    ; convert 1D array back to 2D 
    inds_min = ind_resolve(minind (var1D), dims)    ; convert 1D array back to 2D 
    ilat = inds(0,0)        ; select the latitude index where the X array is at its' maximum  
    ilon = inds(0,1)        ; select the longitude index where the X array is at its' maximum
    ilat_min = inds_min(0,0)        ; select the latitude index where the X array is at its' maximum  
    ilon_min = inds_min(0,1)        ; select the longitude index where the X array is at its' maximum

    dum2    = gsn_add_text(wks,plot,sprintf("T2m@Home: %3.1fdegC~C~", ctrl_var1(time_frame, cor_x, cor_y))+\
              sprintf("Max T2m: %3.1fdegC@(",ctrl_var1(time_frame, ilat, ilon))+\
              sprintf("%5.2fE, ", lon2d(ilat, ilon))+sprintf("%5.2fN)~C~", lat2d(ilat, ilon))+\
              sprintf("Min T2m: %3.1fdegC@(",ctrl_var1(time_frame, ilat_min, ilon_min))+\
              sprintf("%5.2fE, ", lon2d(ilat_min, ilon_min))+sprintf("%5.2fN)~C~", lat2d(ilat_min, ilon_min))\
              ,tlon,tlat,tres)
    dummax    = gsn_add_polymarker(wks,plot,lon2d(ilat, ilon),lat2d(ilat, ilon),polymaxres)
    dummin    = gsn_add_polymarker(wks,plot,lon2d(ilat, ilon),lat2d(ilat, ilon),polyminres)
    
    draw(plot)
    frame(wks)
    time_frame=time_frame+3
end do
end
