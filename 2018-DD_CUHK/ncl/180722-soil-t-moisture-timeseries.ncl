;***********************************************
; Draw T2m i& RH2M at home
;
; jobs:
;   1.Read wrfout03 T2 var
;   2.Display the Result
;                       L_Zealot
;                       2018-01-16
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin
; ==============================================================
; Mission1.    Read Var
;
;   var1        T2
;   var2        Q2
;   var3        Surface Presure
;   var4        RH2
;
;   var5        SNOWH
;   var6        RAINC
;   var7        RAINNC
; ==============================================================

    ; home
    lat0=23.20
    lon0=113.25
    wrfout_path1="/users/yangsong3/L_Zealot/wrf/WRFV3/run/precon/clim/wrfout_d03*"
    wrfout_path2="/users/yangsong3/L_Zealot/wrf/WRFV3/run/precon/2018/wrfout_d03*"

    g_fig_name="../fig/soil-temp-humid-clim"
    g_font=0.012
   
    latSn=15
    latNn=74
    lonWn=54
    lonEn=125
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)

	all_files = systemfunc ("ls "+wrfout_path1)
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	setfileoption("nc","SuppressClose",False) ; close too many files
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
    
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)

	all_files = systemfunc ("ls "+wrfout_path2)
    sen_in      = addfiles (all_files, "r")   ; note the "s" of addfile

	ctrl_var1_0  = wrf_user_getvar(ctrl_in,"TSK", -1)  
	ctrl_var2  = wrf_user_getvar(ctrl_in,"TSLB", -1)  
    
    sen_var1_0  = wrf_user_getvar(sen_in,"TSK", -1)  
	sen_var2  = wrf_user_getvar(sen_in,"TSLB", -1)  
    

    ctrl_var1 =(/ctrl_var1_0 - 273.15/)
    ctrl_var2 =ctrl_var2 - 273.15
    data_var2_series= wgt_areaave_Wrap(ctrl_var2(:,:,latSn:latNn,lonWn:lonEn),1.0,1.0,0)
 
    sen_var1 =(/sen_var1_0 - 273.15/)
    sen_var2 =sen_var2 - 273.15
    sen_var2_series= wgt_areaave_Wrap(sen_var2(:,:,latSn:latNn,lonWn:lonEn),1.0,1.0,0)

    ctrl_var1_series=wgt_areaave_Wrap(ctrl_var1(:,latSn:latNn,lonWn:lonEn),1.0,1.0,0)
    printVarSummary(ctrl_var1_series)
    printVarSummary(data_var2_series)
    sen_var1_series=wgt_areaave_Wrap(sen_var1(:,latSn:latNn,lonWn:lonEn),1.0,1.0,0)
   
   
   
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

   date_str = month_abbr(month(4::72))+sprinti(" %0.2i~C~", day(4::72)) + sprinti("%0.2iH", hour(4::72)) 
              


    lentime=dimsizes(xtime)
        ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    point=getind_latlon2d(lat2d,lon2d,lat0,lon0)
    cor_x=point(0,0)
    cor_y=point(0,1)
;**********************************************************************************************
;MISSION.3      Display timeseries 
;**********************************************************************************************

  
	
	wks = gsn_open_wks("pdf",g_fig_name)       ; open file to plot 


    ;************************************************ 
    ; plotting parameters
    ;************************************************

    res               = True                    ; plot mods desired

    plot = new((/2/),graphic)
    res@gsnFrame         = False
    res@gsnDraw  = False
    res@gsnMaximize           = True 
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.25


    res@trYMinF            = 18; min(data_var2_series)-2                ; Y axis limits
    res@trYMaxF            = max(ctrl_var1_series)+2
    res@tmXBOn = True 
    res@tmXBMinorOn = False
    res@tmXTOn = False
    ;res@trYMinF            = 3.5                ; Y axis limits
    ;res@trYMaxF            = 6.5
    res@trXMaxF  = lentime-1                   ; max value on x-axis
    res@tiYAxisFontHeightF=g_font
    res@tiYAxisString = "Soil Temp (degC)"
    res@xyMonoLineColor    = False             ; want colored lines
    res@xyLineColors       = (/"blue","darkgreen","red","blue","darkgreen","red"/) ; colors chosen
    res@xyLineThicknesses    = (/2.0,2.0,2.0,2.0,2.0,2.0/)      ; line thicknesses
    res@xyDashPatterns   = (/0.,0.,0.,2.,2.,2./)      ; make all lines solid
    res@tmYLMinorOn = False
    res@tmYLMajorLengthF = 0.0
    res@tmYRMinorOn = False
    res@tmXBMajorThicknessF = 3.0
    res@tmYLMajorThicknessF = 3.0
    res@tmXBMinorThicknessF = 2.0
    res@tmYLMinorThicknessF = 2.0
    res@tmBorderThicknessF = 2.0
    
    res@tmXBMode = "Explicit"
    res@tmXBValues=ispan(4, lentime-1,72)
    res@tmXBLabels=date_str

    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    
    resR=res
    delete([/resR@trYMinF, resR@trYMaxF, resR@tiYAxisString/])
    resR@xyLineColors:="darkgreen"
    resR@tiYAxisString="SOIL-TEMP (degC)"
    data_var2_trans=data_var2_series(soil_layers_stag|:,Time|:)
    sen_var2_trans=sen_var2_series(soil_layers_stag|:,Time|:)
    data_var2_trans(2,:)=(/ctrl_var1_series/)
    data_var2_trans:=data_var2_trans(0:2,:)

    sen_var2_trans(2,:)=(/sen_var1_series/)
    data_var2_trans:=array_append_record(data_var2_trans,sen_var2_trans(0:2,:),0)
    plot(0)  = gsn_csm_xy (wks, ispan(0,lentime-1,1), data_var2_trans,res)   ; create plot
    
    res_line=True
    res_line@gsLineDashPattern=1.
    do ii=0, lentime-1
        if mod(ii-4, 24) .eq. 0 then 
            str=unique_string("")
            plot@$str$=gsn_add_polyline(wks,plot(0),(/ii,ii/),(/res@trYMinF, res@trYMaxF/),res_line)
        end if
    end do

    str=unique_string("")
    plot@$str$=gsn_add_polyline(wks,plot(0),(/ii,ii/),(/res@trYMinF, res@trYMaxF/),res_line)


    ctrl_var5  = wrf_user_getvar(ctrl_in,"SNOWH", -1)  
    ctrl_var6  = wrf_user_getvar(ctrl_in,"RAINC", -1)  
	ctrl_var7  = wrf_user_getvar(ctrl_in,"RAINNC", -1)  
	
    ctrl_var8  = wrf_user_getvar(ctrl_in,"SNOWNC", -1)  
    ctrl_var9  = wrf_user_getvar(ctrl_in,"HAILNC", -1)  
    ctrl_var10  = wrf_user_getvar(ctrl_in,"GRAUPELNC", -1)  
   
    ctrl_var11 = wrf_user_getvar(ctrl_in,"CLDFRA", -1)
    ctrl_var11 := ctrl_var11(:,:,cor_x,cor_y)
    z   = wrf_user_getvar(ctrl_in,"height",-1)  ; On half (mass) levels
    zin = z(:,:,cor_x, cor_y)

    ctrl_var5  = ctrl_var5*100
    ctrl_var6  = (ctrl_var6+ctrl_var7) ; Accumulate convective rainfall and non-convective rainfall
    ctrl_var6(1:lentime-1,:,:)=ctrl_var6(1:lentime-1,:,:)-ctrl_var6(0:lentime-2,:,:)
    ctrl_var8(1:lentime-1,:,:)=ctrl_var8(1:lentime-1,:,:)-ctrl_var8(0:lentime-2,:,:)
    ctrl_var9(1:lentime-1,:,:)=ctrl_var9(1:lentime-1,:,:)-ctrl_var9(0:lentime-2,:,:)
    ctrl_var10(1:lentime-1,:,:)=ctrl_var10(1:lentime-1,:,:)-ctrl_var10(0:lentime-2,:,:)

    var6_series=wgt_areaave_Wrap(ctrl_var6,1.0,1.0,0)
;    ctrl_var5(1:lentime-1,:,:)=ctrl_var5(1:lentime-1,:,:)-ctrl_var5(0:lentime-2,:,:)
    res_snow = res
    delete(res_snow@trXMaxF)
    res_snow@tiYAxisString = ""
   
    res_snow@vpHeightF= 0.1
    res_snow@vpWidthF = 0.8
    res_snow@xyLineColors := (/"black"/)
    res_snow@trYMinF            = 0                ; Y axis limits
    res_snow@trYMaxF            = max(var6_series)+1.0
    res_snow@gsnXYBarChart=True
    res_snow@gsnXYBarChartBarWidth = 1.0                 ; change bar widths
    res_snow@gsnXYBarChartColors := (/"grey"/)             ; below ref line fill blue
    res_pr=res_snow
    res_pr@tiYAxisString= "Pr (mm/hr)"
    ;res_pr@trYMaxF=max(ctrl_var6(:,cor_x,cor_y))+0.1
    res_pr@gsnXYBarChartColors := (/"skyblue"/)             ; below ref line fill blue
    plot(1)  = gsn_csm_xy (wks, ispan(0,lentime-1,1),var6_series, res_pr)   ; create plot

  ; Rainfall Mark Res
  rfmkres                   = True
  rfmkres@gsMarkerIndex     = 1          ; polymarker style
  rfmkres@gsMarkerSizeF     = 11.          ; polymarker size
  rfmkres@gsMarkerThicknessF     = 4.          ; polymarker size
  rfmkres@gsMarkerColor     = "Blue"          ; polymarker size

  ; Snow Mark Res
  snmkres                   = rfmkres
  snmkres@gsMarkerIndex     = 0         ; polymarker style
  snmkres@gsMarkerColor     = "gray50"          ; polymarker size

  ; Hail Mark Res
  hlmkres                   = rfmkres 
  hlmkres@gsMarkerIndex     = 7          ; polymarker style
  hlmkres@gsMarkerColor     = "Red"          ; polymarker size
  hlmkres@gsMarkerThicknessF     = 5.          ; polymarker size

  ; Graupel Mark Res
  gpmkres                   = rfmkres 
  gpmkres@gsMarkerIndex     = 9         ; polymarker style
  gpmkres@gsMarkerColor     = "deepskyblue"          ; polymarker size

 ; Graupel Mark Res
  fgmkres                   = rfmkres 
  fgmkres@gsMarkerIndex     = 2         ; polymarker style
  fgmkres@gsMarkerColor     = "darkseagreen"          ; polymarker size




  hratio = 0.9
  do ii=0, lentime-1
      if (ctrl_var8(ii,cor_x, cor_y) .gt. 0.01) then 
          str=unique_string("")
  ;        plot@$str$=gsn_add_polymarker(wks,plot(1), ii, res_snow@trYMaxF*hratio, snmkres)
      end if
      if (ctrl_var9(ii,cor_x, cor_y) .gt. 0.01) then 
          str=unique_string("")
   ;       plot@$str$=gsn_add_polymarker(wks,plot(1), ii, res_snow@trYMaxF*hratio, hlmkres)
      end if
      if (ctrl_var10(ii,cor_x, cor_y) .gt. 0.01) then 
          str=unique_string("")
    ;      plot@$str$=gsn_add_polymarker(wks,plot(1), ii, res_snow@trYMaxF*hratio, gpmkres)
      end if
 
      if ((ctrl_var6(ii,cor_x, cor_y)-ctrl_var8(ii, cor_x, cor_y)-ctrl_var9(ii,cor_x, cor_y)-ctrl_var10(ii, cor_x, cor_y)) .gt. 0.01) then 
          str=unique_string("")
   ;       plot@$str$=gsn_add_polymarker(wks,plot(1), ii, res_snow@trYMaxF*hratio, rfmkres)
      end if
      do jj = 0, 5
        if (zin(ii,jj) .lt. 100.0 .and. ctrl_var11(ii,jj) .gt. 0.1) then
            str=unique_string("")
    ;        plot@$str$=gsn_add_polymarker(wks,plot(1), ii, res_snow@trYMaxF*hratio, fgmkres)
            break
        end if
      end do
      ; Specific time marker
      if mod(ii-4, 24) .eq. 0 then 
          str=unique_string("")
          plot@$str$=gsn_add_polyline(wks,plot(1),(/ii,ii/),(/res_snow@trYMinF, res_snow@trYMaxF/),res_line)
      end if
  end do
  txres               =  True
  txres@txFontHeightF =  g_font         ;-- default size is HUGE!

  xndc = 0.55
  yndc = 0.5
  txres@txJust        = "CenterLeft"

  gsn_panel(wks, plot, (/2,1/), False)

end
