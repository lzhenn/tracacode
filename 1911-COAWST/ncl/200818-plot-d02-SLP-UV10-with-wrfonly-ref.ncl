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
    casename="ERA5_TY2001_add2" 
    base_path="/disk/v092.yhuangci/lzhenn/1911-COAWST/"
    wrfout_path=base_path+casename+"/wrfout_d02"
    g_font=0.02
    fig_prefix="d02_SLP_UV10_"
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)
    ; get in ibtrck data
    tck_file=base_path+"cma.trck.mangkhut"
    ncol=6
    tc_loc = readAsciiTable(tck_file,ncol,"float", 1) ; tc_loc(nrec, ncol) 
    dims=dimsizes(tc_loc) 
    dim_tc=dims(0)
    
    
    ; get wrf fully coupled nc data
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

    ; get in SEN tc track data
    ;0-timestamp 1-lat 2-lon 3-minSLP 4-maxWS 5-uRadius 6-vRadius
    sen_tc =asciiread(base_path+casename+"/trck."+casename+".d02",(/lentime,7/),"float")
    sen_tc:=transpose(sen_tc)
 
    ; get in CTRL tc track data 
    ;0-timestamp 1-lat 2-lon 3-minSLP 4-maxWS 5-uRadius 6-vRadius
    ctrl_tc = asciiread(base_path+"ERA5_WRF_add/trck.ERA5_WRF_add.d02",(/lentime,7/),"float")
    ctrl_tc:=transpose(ctrl_tc)
    
    count_tc=0
    ctrl_istrt=0 ; count no tc frames
    do ii=0, lentime-1
        if (ctrl_tc(4, ii) .gt. 0) then
            if (count_tc .eq. 0) then ;first time
                ctrl_istrt=ii
            end if
            count_tc=count_tc+1
        end if
    end do
    ctrl_iend=ctrl_istrt+count_tc-1

    ; parser lat lon
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  0)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 0)
  
    rec_tc=new((/3,lentime/), "float") ; (0)--lat, (1)--lon, (2)--slp
    
       
  res                   = True              ; plot mods desired
;---Resources for filled contour plot
  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF        = 960.          ; set min contour level
  res@cnMaxLevelValF        = 1000.          ; set max contour level
  res@cnLevelSpacingF      = 2.        
  
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
  tres@txFontHeightF = 0.018
  tres@txJust="CenterLeft"
  tlat=18.0
  tlon=110.0
 
  resv                         = True               ; plot mods desired
  resv@vcGlyphStyle            = "WindBarb"         ; choose wind barbs
;  resv@lbOrientation           = "vertical"         ; vertical label bar
  resv@gsnDraw = False
  resv@gsnFrame = False
  resv@vcRefMagnitudeF         = 5.                ; make vectors larger
  resv@vcRefLengthF            = 0.015              ; ref vec length
  resv@vcMinDistanceF          = 0.03              ; thin out windbarbs
  resv@vcWindBarbLineThicknessF = 3.
  resv@vcWindBarbColor = "grey70"
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
    
    res_lines=True
    res_lines@gsLineColor       = "black"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    



do while(time_frame .lt. lentime)
    ;---Set map resources based on projection on WRF output file

    ;************************************************
    ; create plot
    ;************************************************
    ; whether tc in domain
    if (sen_tc(4, time_frame) .eq. 0) then
        time_frame=time_frame+1
        continue
    end if
    ; get slp
  	ctrl_var1  = wrf_user_getvar(ctrl_in,"slp", time_frame)  
    dims:=dimsizes(ctrl_var1)
    dim_y=dims(0)
    dim_x=dims(1)
    
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    
    ctrl_var2  = wrf_user_getvar(ctrl_in,"U10", time_frame)  
  	ctrl_var3  = wrf_user_getvar(ctrl_in,"V10", time_frame)  
    ctrl_var2@lat2d = lat2d
    ctrl_var2@lon2d = lon2d
    ctrl_var3@lat2d = lat2d
    ctrl_var3@lon2d = lon2d

    print(date_str(time_frame)+"--> lat: "+sen_tc(1,time_frame)+" lon: "+sen_tc(2,time_frame)+" minSLP= "+sen_tc(3, time_frame))
   
    wks = gsn_open_wks(wks_type,"../fig/"+casename+"/"+fig_prefix+sprinti("%0.3iFrm", time_frame))      ; send graphics to PNG file
    gsn_define_colormap(wks,"wind_17lev")
    gsn_reverse_colormap(wks)
    res@gsnLeftString="SLP UV10 @ "+date_str(time_frame)
    ;---Call plotting routine which draws contours over a map
    plot = gsn_csm_contour_map(wks,ctrl_var1,res)
    plotv = gsn_csm_vector(wks, ctrl_var2,ctrl_var3, resv)
    chinamap = add_china_map(wks,plot,cnres)
  
   

    ; Obv Track
    yy := tc_loc(:,3)/10 
    xx := tc_loc(:,2)/10 
    obv_track=gsn_add_polyline(wks,plot,yy,xx,res_lines)              ; N

    do ii =0, dim_tc-1
        obv_track@$unique_string("xx")$    = gsn_add_polymarker(wks,plot,yy(ii),xx(ii),obv_polyres)
    end do

    ; Ctrl Track
    ctrl_track=gsn_add_polyline(wks,plot,ctrl_tc(2,ctrl_istrt:ctrl_iend), ctrl_tc(1, ctrl_istrt:ctrl_iend),pres_wrf)  

    ; SEN Track
    center_sen  = gsn_add_polymarker(wks,plot,sen_tc(2,time_frame),sen_tc(1, time_frame),polyres)
    center_info = gsn_add_text(wks,plot,sprintf("Center SLP: %3.1f hPa", sen_tc(3, time_frame)),tlon,tlat,tres)
    sen_track   = gsn_add_polyline(wks, plot, sen_tc(2, 0:time_frame) , sen_tc(1,0:time_frame),pres)
    
    ; legends
    yy := (/115.0, 116.0/)
    xx := (/27.0, 27.0/)
    obv_lg = gsn_add_polyline(wks, plot, yy, xx, res_lines)
    obv_lg@leftDot=gsn_add_polymarker(wks, plot, yy(0), xx(0), obv_polyres)
    obv_lg@rightDot=gsn_add_polymarker(wks, plot, yy(1), xx(1), obv_polyres)
    obv_lg@txt=gsn_add_text(wks, plot, "CMA bTrack", yy(1)+0.5, xx(1), tres)
    
    xx = xx - 0.5
    ctrl_lg = gsn_add_polyline(wks, plot, yy, xx, pres_wrf)
    ctrl_lg@txt=gsn_add_text(wks, plot, "WRF_ONLY", yy(1)+0.5, xx(1), tres)


    xx = xx - 0.5
    sen_lg = gsn_add_polyline(wks, plot, yy, xx, pres)
    sen_lg@txt=gsn_add_text(wks, plot, "TY2001", yy(1)+0.5, xx(1), tres)

    overlay(plot, plotv)
    draw(plot)
    frame(wks)
    time_frame=time_frame+1
    ;delete(wks)
    ;break
end do
end
