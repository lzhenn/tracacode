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
    lat0=37.40
    lon0=121.56
    wrfout_path="/home/lzhenn/array/lzhenn/WRFV3/run/wrfout_d03*"

    g_fig_name="../fig/T2m-home"
    g_font=0.012
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)

	all_files = systemfunc ("ls "+wrfout_path)
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	setfileoption("nc","SuppressClose",False) ; close too many files
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

	ctrl_var1_0  = wrf_user_getvar(ctrl_in,"TSK", -1)  
	ctrl_var2  = wrf_user_getvar(ctrl_in,"Q2", -1)  
	ctrl_var3  = wrf_user_getvar(ctrl_in,"PSFC", -1)  
    
    ; get rh2m
    ctrl_var4  = wrf_rh(ctrl_var2, ctrl_var3, ctrl_var1_0)

    ctrl_var1 =(/ctrl_var1_0 - 273.15/)
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

   date_str = month_abbr(month(4::12))+sprinti(" %0.2i~C~", day(4::12)) + sprinti("%0.2iH", hour(4::12)) 
              


    lentime=dimsizes(xtime)
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    point=getind_latlon2d(lat2d,lon2d,lat0,lon0)
    cor_x=point(0,0)
    cor_y=point(0,1)
;**********************************************************************************************
;MISSION.3      Display timeseries 
;**********************************************************************************************

  
	
	wks = gsn_open_wks("png","../fig/T2m-home")       ; open file to plot 


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
    res@vpHeightF= 0.2


    res@trYMinF            = min(ctrl_var1(:,cor_x,cor_y))-2                ; Y axis limits
    res@trYMaxF            = max(ctrl_var1(:,cor_x,cor_y))+2
    res@tmXBOn = True 
    res@tmXBMinorOn = False
    res@tmXTOn = False
    ;res@trYMinF            = 3.5                ; Y axis limits
    ;res@trYMaxF            = 6.5
    res@trXMaxF  = lentime-1                   ; max value on x-axis
    res@tiYAxisFontHeightF=g_font
    res@tiYAxisString = "T2m (degC)"
    res@xyMonoLineColor    = False             ; want colored lines
    res@xyLineColors       = (/"red","black"/) ; colors chosen
    res@xyLineThicknesses    = (/3.0,2.0,2.0,2.0,2.0/)      ; line thicknesses
    res@xyDashPatterns   = (/0.,1.,0.,0.,1./)      ; make all lines solid
    res@tmYLMinorOn = False
    res@tmYLMajorLengthF = 0.0
    res@tmYRMinorOn = False
    res@tmXBMajorThicknessF = 3.0
    res@tmYLMajorThicknessF = 3.0
    res@tmXBMinorThicknessF = 2.0
    res@tmYLMinorThicknessF = 2.0
    res@tmBorderThicknessF = 2.0
    
    res@tmXBMode = "Explicit"
    res@tmXBValues=ispan(4, lentime-1,12)
    res@tmXBLabels=date_str

    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    
    resR=res
    delete([/resR@trYMinF, resR@trYMaxF, resR@tiYAxisString/])
    resR@xyLineColors:="darkgreen"
    resR@tiYAxisString="RH (%)"
    plot(0)  = gsn_csm_xy2 (wks, ispan(0,lentime-1,1),ctrl_var1(:,cor_x,cor_y),ctrl_var4(:,cor_x,cor_y),res, resR)   ; create plot
    
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

;    ctrl_var5(1:lentime-1,:,:)=ctrl_var5(1:lentime-1,:,:)-ctrl_var5(0:lentime-2,:,:)
    res_snow = res
    delete(res_snow@trXMaxF)
    res_snow@tiYAxisString = "Snow Depth (cm)"
   
    res_snow@vpHeightF= 0.1
    res_snow@vpWidthF = 0.8
    res_snow@xyLineColors := (/"black"/)
    res_snow@trYMinF            = 0                ; Y axis limits
    res_snow@trYMaxF            = max(ctrl_var5(:,cor_x,cor_y))+1.0
    res_snow@gsnXYBarChart=True
    res_snow@gsnXYBarChartBarWidth = 1.0                 ; change bar widths
    res_snow@gsnXYBarChartColors := (/"grey"/)             ; below ref line fill blue
    res_pr=res_snow
    res_pr@tiYAxisString= "Pr (mm/hr)"
    res_pr@trYMaxF=max(ctrl_var6(:,cor_x,cor_y))+0.1
    res_pr@gsnXYBarChartColors := (/"skyblue"/)             ; below ref line fill blue
    plot(1)  = gsn_csm_xy2 (wks, ispan(0,lentime-1,1),ctrl_var5(:,cor_x,cor_y),ctrl_var6(:,cor_x,cor_y),res_snow, res_pr)   ; create plot

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
          plot@$str$=gsn_add_polymarker(wks,plot(1), ii, res_snow@trYMaxF*hratio, snmkres)
      end if
      if (ctrl_var9(ii,cor_x, cor_y) .gt. 0.01) then 
          str=unique_string("")
          plot@$str$=gsn_add_polymarker(wks,plot(1), ii, res_snow@trYMaxF*hratio, hlmkres)
      end if
      if (ctrl_var10(ii,cor_x, cor_y) .gt. 0.01) then 
          str=unique_string("")
          plot@$str$=gsn_add_polymarker(wks,plot(1), ii, res_snow@trYMaxF*hratio, gpmkres)
      end if
 
      if ((ctrl_var6(ii,cor_x, cor_y)-ctrl_var8(ii, cor_x, cor_y)-ctrl_var9(ii,cor_x, cor_y)-ctrl_var10(ii, cor_x, cor_y)) .gt. 0.01) then 
          str=unique_string("")
          plot@$str$=gsn_add_polymarker(wks,plot(1), ii, res_snow@trYMaxF*hratio, rfmkres)
      end if
      do jj = 0, 5
        if (zin(ii,jj) .lt. 100.0 .and. ctrl_var11(ii,jj) .gt. 0.1) then
            str=unique_string("")
            plot@$str$=gsn_add_polymarker(wks,plot(1), ii, res_snow@trYMaxF*hratio, fgmkres)
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

  gsn_polymarker_ndc(wks,xndc,yndc,fgmkres)
  gsn_text_ndc(wks,"Fog", xndc+0.015, yndc, txres)
  
  xndc=xndc+0.06
  gsn_polymarker_ndc(wks,xndc,yndc,rfmkres)
  gsn_text_ndc(wks,"Rain", xndc+0.015, yndc, txres)
  
  xndc2 = xndc+0.075
  gsn_polymarker_ndc(wks,xndc2,yndc,snmkres)
  gsn_text_ndc(wks,"Snow", xndc2+0.015, yndc, txres)
 
  xndc3 = xndc2+0.08
  gsn_polymarker_ndc(wks,xndc3,yndc,gpmkres)
  gsn_text_ndc(wks,"Graupel", xndc3+0.015, yndc, txres)
 
  xndc4 = xndc3+0.1
  gsn_polymarker_ndc(wks,xndc4,yndc,hlmkres)
  gsn_text_ndc(wks,"Hail", xndc4+0.015, yndc, txres)

  gsn_panel(wks, plot, (/2,1/), False)

end
