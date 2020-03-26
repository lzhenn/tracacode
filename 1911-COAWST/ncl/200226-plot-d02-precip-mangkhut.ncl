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
    casename="mangkhut" 
    fig_prefix="d02_precip_"
    wrfout_path="../data/1911-COAWST/"+casename+"/wrfout_d02"
    g_font=0.02
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
    
    tck_file="../data/1911-COAWST/"+casename+"/trck.cma.simple"
    tc_track_path="../data/1911-COAWST/"+casename+"/trck.cpl"
    
    ; get in ibtrck data
    tc_loc  =   asciiread(tck_file,(/22,2/),"float") ; (n,0)--lat (n,1)--lon
    dims=dimsizes(tc_loc) 
    dim_tc=dims(0)
 

   
   
    ctrl_in      = addfile (wrfout_path, "r")   ; note the "s" of addfile
    
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
   
    ; get in wrf only tc data
    wrf_tc = asciiread("../data/1911-COAWST/"+casename+"-wrfonly/trck.wrf",(/lentime,3/),"float"); (0)--lat, (1)--lon, (2)--slp
    rec_tc = asciiread(tc_track_path,(/lentime,3/),"float"); (0)--lat, (1)--lon, (2)--slp

    ; get rain
    ;ctrl_var1  = wrf_user_getvar(ctrl_in,"RAINC", -1)  
    ctrl_var1  = wrf_user_getvar(ctrl_in,"RAINNC", -1)  
    ;ctrl_var1  = (ctrl_var1+ctrl_var2)
 
    dims:=dimsizes(ctrl_var1)
    dim_t=dims(0)
    dim_y=dims(1)
    dim_x=dims(2)
    
    ctrl_var1(1:lentime-1,:,:)=ctrl_var1(1:lentime-1,:,:)-ctrl_var1(0:lentime-2,:,:)

    ; parser lat lon
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    ;ctrl_var1=(/ctrl_var1-273.15/)   
    ctrl_var1(0,0,:)=(/ctrl_var1(0,0,:)+1e-2/)
    ; lets find the TC center!

   

res                   = True              ; plot mods desired
;---Resources for filled contour plot
  
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
  res@cnLevels =    (/0.1, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 20, 25, 30, 40, 50/)
   
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
  res@mpGridSpacingF         = 5.0 
  res@mpGridLineThicknessF   = 2.0
  res@mpGridLineColor        = "Gray80"

  res@mpOutlineOn             = True  ; Use outlines from shapefile
  res@mpGeophysicalLineColor = "gray10"
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
  cnres@diqu      = False       ; draw diqujie or not


 
    
  polyres                   = True
  polyres@gsMarkerIndex     = 14          ; polymarker style
  polyres@gsMarkerSizeF     = 12.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "Black"          ; polymarker size

  ;---Resources for the polyline
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 3.0            ; line thickness   
  pres@gsLineColor      = "red"         ; color of lines
  
  pres_wrf=pres
  pres_wrf@gsLineColor="blue"



  tres  = True
  tres@txFontHeightF = 0.015
  tres@txJust="TopLeft"
  tlat=18.0
  tlon=110.0
 
  obv_polyres=polyres
  obv_polyres@gsMarkerIndex     = 16          ; polymarker style
  obv_polyres@gsMarkerSizeF     = 9.          ; polymarker size



res = wrf_map_resources(ctrl_in,res)


time_frame = 18 
do while(time_frame .lt. lentime)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    
    wks_type="png"
    wks_type@wkWidth=800
    wks_type@wkHeight=800
    wks = gsn_open_wks(wks_type,"../fig/"+casename+"/"+fig_prefix+sprinti("%0.3iFrm", time_frame))      ; send graphics to PNG file
    
    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    res@cnLevels =    (/0.1, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 20, 25, 30, 40, 50/)
   
    gsn_define_colormap(wks,"precip2_17lev")
    res@gsnLeftString="half-hr precip @ "+date_str(time_frame)
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,ctrl_var1(time_frame,:,:),res)
  
    chinamap = add_china_map(wks,plot,cnres)
    ; center
    dum1    = gsn_add_polymarker(wks,plot,rec_tc(time_frame,1),rec_tc(time_frame,0),polyres)
    ;dum_text    = gsn_add_text(wks,plot,sprintf("Center SLP: %3.1f degC", rec_tc(2, time_frame)),tlon,tlat,tres)
    if (time_frame .gt. 0) then
        dum_track=gsn_add_polyline(wks,plot, rec_tc(0:time_frame,1) , rec_tc(0:time_frame,0),pres)
    end if
    
    ;Obv Track
    res_lines=True
    res_lines@gsLineColor       = "black"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    
    yy := tc_loc(:,1) 
    xx := tc_loc(:,0) 
    obv_track=gsn_add_polyline(wks,plot,yy,xx,res_lines)              ; N

    do ii =0, dim_tc-1
        dum1@$unique_string("xx")$    = gsn_add_polymarker(wks,plot,yy(ii),xx(ii),obv_polyres)
    end do

    ; wrf only track
    yy := wrf_tc(:,1) 
    xx := wrf_tc(:,0) 
    wrf_track=gsn_add_polyline(wks,plot,yy,xx,pres_wrf)              ; N



    ;overlay(plot, plotv)
    draw(plot)
    frame(wks)
    time_frame=time_frame+1
    ;delete(wks)
end do
end
