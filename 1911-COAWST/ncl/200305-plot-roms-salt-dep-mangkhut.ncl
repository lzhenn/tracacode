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
  
    
    g_font=0.02
   
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
   
    casename="mangkhut" 
    
    wrfout_path="../data/1911-COAWST/"+casename+"/wrfout_d01"
    ocean_path="../data/1911-COAWST/"+casename+"/gba_ocean_his.nc"
    obv_tck_file="../data/1911-COAWST/"+casename+"/trck.cma.simple"
    cpl_tck_file="../data/1911-COAWST/"+casename+"/trck.cpl"
    wrf_tck_file="../data/1911-COAWST/"+casename+"-wrfonly/trck.wrf"
    
    
    
    ; --------Ocean grid file
    ocn_in     = addfile(ocean_path, "r")
    lon2d=ocn_in->lon_rho
    lat2d=ocn_in->lat_rho
    
    ; get temp first layer
  	ctrl_var1  = ocn_in->salt(0:145,15,:,:)
    printVarSummary(ctrl_var1)
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    
    ctrl_var1=dim_rmvmean_n_Wrap(ctrl_var1,0)

    dims:=dimsizes(ctrl_var1)
    dim_t=dims(0)
    dim_y=dims(1)
    dim_x=dims(2)
    ; --------Ocean grid file
    
    ; ---------parser time from wrf
    grid_in = addfile(wrfout_path,"r")
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

    date_str = month_abbr(month)+sprinti(" %0.2i ", day) + sprinti("%0.2iZ", hour) +sprinti("%0.2i:00", minute)
    ;date_str:=date_str(::2) ; consisitent with the ocn output
    lentime_wrf=dimsizes(xtime)
    ; ---------parser time from wrf


    ; get in ibtrck data
    tc_loc  =   asciiread(obv_tck_file,(/22,2/),"float") ; (n,0)--lat (n,1)--lon
    dims:=dimsizes(tc_loc) 
    dim_tc=dims(0)

    ; cpl simulation track 
    rec_tc = asciiread(cpl_tck_file,(/lentime_wrf,3/),"float"); (0)--lat, (1)--lon, (2)--slp
    ;rec_tc := rec_tc(::2,:)
    ; wrf simulation track 
    wrf_tc = asciiread(wrf_tck_file,(/lentime_wrf,3/),"float"); (0)--lat, (1)--lon, (2)--slp
    
    ;wrf_tc := wrf_tc(::2,:)
    
  res                   = True              ; plot mods desired
;---Resources for filled contour plot
  res@gsnMaximize          = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@cnFillOn             = True  
  res@cnLinesOn            = False
  res@cnLevelSpacingF      = 2.           ; NCL chose 4.0

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
;  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  ;res@lbLabelStride = 1  
  
  
  
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font

  res@mpMinLatF=min(lat2d)
  res@mpMaxLatF=max(lat2d)
  res@mpMaxLonF=max(lon2d)
  res@mpMinLonF=min(lon2d)

  
  
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines
  res@mpGridSpacingF         = 5.0 
  res@mpGridLineThicknessF   = 2.0
  res@mpGridLineColor        = "Gray30"

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
  tlat=13.0
  tlon=-33.0
  obv_polyres=polyres
  obv_polyres@gsMarkerIndex     = 16          ; polymarker style
  obv_polyres@gsMarkerSizeF     = 9.          ; polymarker size




time_frame = 0
ampf=1
do while(time_frame .lt. dim_t)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    
    wks_type="png"
    wks_type@wkWidth=800
    wks_type@wkHeight=800
    wks = gsn_open_wks(wks_type,"../fig/"+casename+"/droms_dsst_"+sprinti("%0.3iFrm", ampf*time_frame))      ; send graphics to PNG file

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = -1.5          ; set min contour level
    res@cnMaxLevelValF        = 1.5          ; set max contour level
    res@cnLevelSpacingF       = 0.1          ; set contour interval
  


    gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
    ;gsn_reverse_colormap(wks)
    res@gsnLeftString="SST Departure @ "+date_str(time_frame*ampf)
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,ctrl_var1(time_frame,:,:),res)
  
    ; center
    dum1    = gsn_add_polymarker(wks,plot,rec_tc(time_frame*ampf,1),rec_tc(time_frame*ampf,0),polyres)
    ;dum_text    = gsn_add_text(wks,plot,sprintf("Center SLP: %3.1f hPa", rec_tc(2, time_frame)),tlon,tlat,tres)
    if (time_frame .gt. 0) then
        dum_track=gsn_add_polyline(wks,plot, rec_tc(0:time_frame*ampf,1) , rec_tc(0:time_frame*ampf,0),pres)
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
    print(""+time_frame)
    time_frame=time_frame+1
    ;delete(wks)
end do
end
