;**************************************
;  meteo_1.ncl
;
; Concepts illustrated:
;   - Drawing a meteogram
;   - Creating a color map using RGB triplets
;   - Reversing the Y axis
;   - Explicitly setting tickmarks and labels on the bottom X axis
;   - Increasing the thickness of contour lines
;   - Drawing wind barbs
;   - Drawing a bar chart
;   - Changing the width and height of a plot
;   - Overlaying wind barbs and line contours on filled contours
;   - Changing the position of individual plots on a page
;
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin
    lat0=37.40
    lon0=121.56
    wrfout_path="/home/lzhenn/array/lzhenn/WRFV3/run/wrfout_d03*"

    g_fig_name="../fig/cloud-profile-home"
    g_font=0.015
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)

	all_files = systemfunc ("ls "+wrfout_path)
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	setfileoption("nc","SuppressClose",False) ; close too many files
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

	ctrl_var1  = wrf_user_getvar(ctrl_in,"CLDFRA", -1)  
    

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
    z   = wrf_user_getvar(ctrl_in,"pressure",1)  ; On half (mass) levels
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    point=getind_latlon2d(lat2d,lon2d,lat0,lon0)
    cor_x=point(0,0)
    cor_y=point(0,1)

    ctrl_var1 := ctrl_var1(:,:,cor_x,cor_y)
    zin = z(:,cor_x, cor_y)
    z_raob = fspan(200.0,1000.0,17)    ; height in radiosonde
    z_raob@_FillValue = -999. ; missing value
    linlog = 2  
    ctrl_var1 := transpose(int2p_Wrap(zin, ctrl_var1, z_raob, linlog))
    ctrl_var1@_FillValue = -999.0
;***********************************************
;  open a workstation and define colormap using rgb triplets
;***********************************************
  wks = gsn_open_wks("png",g_fig_name) ; send graphics to PNG file
;***********************************************
; Create a different resource list for each of the 5 plots
;***********************************************
  rh_res      = True
  uv_res      = True
;***********************************************
; Here are the resources that rh_res, temp_res, and uv_res share.
;***********************************************
  rh_res@trYReverse   = True     ; Reverse the Y values.
  rh_res@gsnDraw      = False    ; Don't draw individual plot.
  rh_res@gsnFrame     = False    ; Don't advance frame.
  rh_res@vpXF         = 0.15     ; x location
  rh_res@vpWidthF     = 0.8      ; width
  rh_res@vpHeightF    = 0.15     ; height

  rh_res@gsnStringFontHeightF = g_font 
  uv_res              = rh_res
  rh_res@lbLabelFontHeightF  = g_font              ; make labels smaller
;***********************************************
; Relative humidity only resources
;***********************************************
  rh_res@cnFillOn          = True               ; turns on color fill
  cmap=read_colormap_file("WhiteBlue")
  rh_res@cnFillPalette     = cmap(::-1,:)             ; set color map
  rh_res@cnLinesOn   = False
  rh_res@cnLineLabelsOn    = False               ; no contour labels
  rh_res@cnLineLabelPerimOn = False
  rh_res@cnFillMode           = "CellFill" ; Raster Mode
  rh_res@tiYAxisString     = "Pressure (hPa)"    ; Y axes label.
  rh_res@tiYAxisFontHeightF = g_font
  rh_res@lbLabelBarOn = True   ; turn off the label bar
  rh_res@lbOrientation          = "vertical"
  rh_res@gsnRightString = systemfunc("date")+ " ALL Updated" 
  rh_res@gsnMaximize          = True
  rh_res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
  rh_res@cnLevels = fspan(0,1,21) 
  rh_res@gsnLeftString = "Cloud Fraction"
; y-left axis changes
  rh_res@tmYLMode       = "Explicit" ; Define own tick mark labels.
  rh_res@tmYLValues     = (/1000,  500, 200/)     ; location of explicit labels
  rh_res@tmYLLabels     =(/1000,  500, 200/) 
  rh_res@tmYLMajorLengthF = 0.0
  rh_res@tmYLMinorOn    = False            ; No Y-left minor tick marks.

; x-bottom axis changes
  rh_res@tmXBMode       = "Explicit" ; Define own tick mark labels.
  rh_res@tmXBValues=ispan(4, lentime-1,12)
  rh_res@tmXBLabels=date_str
  rh_res@tmXBMajorLengthF = 0.0
  rh_res@tmXBLabelFontHeightF = g_font
  rh_res@tmYLLabelFontHeightF = g_font

  rh_res@tmXBMinorOn          = False          ; No minor tick marks.
  rhfill    = gsn_csm_contour(wks,ctrl_var1,rh_res)
  res_line=True
  res_line@gsLineDashPattern=1.
  res_line@gsLineColor = "gray50"
  res_line@gsLineThicknessF = 2.
  do ii=0, lentime-1
    if mod(ii-4, 24) .eq. 0 then 
      str=unique_string("")
      rhfill@$str$=gsn_add_polyline(wks,rhfill,(/ii,ii/),(/200, 1000/),res_line)
    end if
  end do




;  windlayer = gsn_vector(wks,ctrl_var1,ctrl_var2,uv_res)
;********************************************************
; three of the above plots become one overlay plot
;********************************************************
  draw(rhfill)               ; draw this overlay result
  frame(wks)                 ; finally advance the frame once all on page
end
