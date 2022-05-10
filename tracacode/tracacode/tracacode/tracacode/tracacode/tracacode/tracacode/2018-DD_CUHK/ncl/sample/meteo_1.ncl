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
begin
  cdf = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/meteo_data.nc","r")
  tempisobar = cdf->tempisobar
  levels     = cdf->levels     
  taus       = cdf->taus       
  rh         = cdf->rh
  ugrid      = cdf->ugrid
  vgrid      = cdf->vgrid
  rain03     = cdf->rain03
  tempht     = cdf->tempht
;***********************************************
;  smooth temperature and humidity.
;***********************************************
  smothtemp = smth9(tempisobar, 0.50, -0.25, False)
  smothrh   = smth9(rh, 0.50, -0.25, False)
;***********************************************
;  open a workstation and define colormap using rgb triplets
;***********************************************
  wks = gsn_open_wks("png","meteo") ; send graphics to PNG file
  colors = (/                                                        \
             (/255,255,255/),  \
             (/255,255,255/),   (/255,255,255/),   (/240,255,240/),  \
             (/220,255,220/),   (/190,255,190/),   (/120,255,120/),  \
             (/ 80,255, 80/),   (/ 50,200, 50/),   (/ 20,150, 20/) /) / 255.
;***********************************************
; Create a different resource list for each of the 5 plots
;***********************************************
  rh_res      = True
  temp_res    = True
  uv_res      = True
  rain_res    = True
  tempsfc_res = True
;***********************************************
; Here are the resources that rh_res, temp_res, and uv_res share.
;***********************************************
  rh_res@trYReverse   = True     ; Reverse the Y values.
  rh_res@gsnDraw      = False    ; Don't draw individual plot.
  rh_res@gsnFrame     = False    ; Don't advance frame.
  rh_res@vpXF         = 0.15     ; x location
  rh_res@vpYF         = 0.90     ; y location
  rh_res@vpWidthF     = 0.7      ; width
  rh_res@vpHeightF    = 0.40     ; height

  temp_res            = rh_res   ; copy shared resources to other lists
  uv_res              = rh_res
;***********************************************
; Relative humidity only resources
;***********************************************
  rh_res@cnFillOn          = True               ; turns on color fill
  rh_res@cnFillPalette     = colors             ; set color map
  rh_res@cnLineLabelsOn    = True               ; no contour labels
  rh_res@tiMainString      = "Meteogram for LGSA, 28/12Z" ; title

  rh_res@cnFillOn          = True               ; turns on the color
  rh_res@sfXArray          = taus               ; Define X/Y axes values that
  rh_res@sfYArray          = levels             ; all three data fields are on
  rh_res@tiYAxisString     = "Pressure (mb)"    ; Y axes label.

; y-left axis changes
  rh_res@tmYLMode       = "Explicit" ; Define own tick mark labels.
  rh_res@tmYLValues     = levels     ; location of explicit labels
  rh_res@tmYLLabels     = levels
  rh_res@tmYLMinorOn    = False            ; No Y-left minor tick marks.

; x-bottom axis changes
  rh_res@tmXBMode       = "Explicit" ; Define own tick mark labels.
  rh_res@tmXBValues     = taus       ; location of explicit labels
  rh_res@tmXBLabels     = (/"12z", "15z", "18z",  "21z", "Apr29", \
                            "03z", "06z", "09z",  "12z", "15z",   \
                            "18z", "21z", "Apr30","03z", "06z",   \
                            "09z", "12z", "15z",  "18z", "21z",   \
                            "May01", "03z", "06z",  "09z", "12z"/)

  rh_res@tmXBLabelAngleF      = 90.            ; change label angle
  rh_res@tmXBMinorOn          = False          ; No minor tick marks.
  rh_res@tmXBLabelJust        = "CenterCenter" ; label justification
  rh_res@tmXBLabelFontHeightF = .016           ; Font size
  rh_res@tiXAxisString        = ""             ; turn off x-axis string
;***********************************************
; Temperature only resources
;***********************************************
  temp_res@sfXArray        = taus    ; Define X/Y axes values that
  temp_res@sfYArray        = levels  ; all three data fields are on

  temp_res@cnLineLabelsOn  = True    ; no contour labels
  temp_res@cnLineThicknessF= 3.0     ; line thickness
  temp_res@cnLineColor     = "Red"   ; color of contour lines
;***********************************************
; wind barb only resources
;***********************************************
  uv_res@vfXArray            = taus       ; Define X/Y axes values that
  uv_res@vfYArray            = levels     ; all three data fields are on
  uv_res@vcRefAnnoOn         = False      ; turns off the ref vector
  uv_res@vcRefLengthF        = 0.040      ; set length of ref vector
  uv_res@vcGlyphStyle        = "WindBarb" ; turn on windbarbs
  uv_res@vcMonoWindBarbColor = True       ; to color the windbarbs with
                                          ; respect to speed use False
  uv_res@vcMapDirection = False			      ; needed to disassociate the coordinate plane from the wind barbs
                                     
;***********************************************
; rain histogram only resources
;***********************************************
  rain_res@vpXF            = 0.15   ; The left side of the box location
  rain_res@vpYF            = 0.34   ; The top side of the plot box location
  rain_res@vpWidthF        = 0.70   ; The Width of the plot box 
  rain_res@vpHeightF       = 0.10   ; The height of the plot box
  rain_res@trYMinF         = 0.0    ; min value on y-axis
  rain_res@trYMaxF         = 0.5    ; max value on y-axis
  rain_res@trXMinF         = 0.0    ; min value on x-axis
  rain_res@trXMaxF         = 72.0   ; max value on x-axis

  rain_res@tiXAxisString  = ""                ; X axis label.
  rain_res@tiYAxisString  = "3hr rain total"  ; Y axis label.
  rain_res@tmXBMode       = "Explicit" ; Define own tick mark labels.
  rain_res@tmXBValues     = taus       ; location of explicit labels
  rain_res@tmXBLabels     = (/"12z", "", "18z",  "", "Apr29", \
                            "", "06z", "",  "12z", "",   \
                            "18z", "", "Apr30","", "06z",   \
                            "", "12z", "",  "18z", "",   \
                            "May01", "", "06z",  "", "12z"/)
  rain_res@tmXTOn         = False             ; turn off the top tickmarks
  rain_res@tmXBMinorOn    = False             ; No minor tick marks.

  rain_res@gsnDraw         = False            ; Don't draw individual plot.
  rain_res@gsnFrame        = False            ; Don't advance frame.
  rain_res@gsnYRefLine     = 0.0              ; create a reference line
  rain_res@gsnAboveYRefLineColor = "green"    ; above ref line fill green
  rain_res@gsnXYBarChart   = True             ; turn on bar chart


;***********************************************
; temperature at surface only resources
;***********************************************
  tempsfc_res@vpXF            = 0.15   ; The left side of the box location
  tempsfc_res@vpYF            = 0.18   ; The top side of the plot box loc
  tempsfc_res@vpWidthF        = 0.70   ; The Width of the plot box
  tempsfc_res@vpHeightF       = 0.10   ; The height of the plot box
  tempsfc_res@trXMaxF         = 72.0   ; max value on x-axis
  tempsfc_res@trYMaxF         = max(tempht)+.5   ; max value on y-axis
  tempsfc_res@trYMinF         = min(tempht)-.5   ; min value on y-axis
  
  tempsfc_res@tiXAxisString  = ""            ; turn off x-axis string
  tempsfc_res@tiYAxisString  = "Temp at 2m"  ; set y-axis string
  tempsfc_res@tmXBMode       = "Explicit" ; Define own tick mark labels.
  tempsfc_res@tmXBValues     = taus       ; location of explicit labels
  tempsfc_res@tmXBLabels     = (/"12z", "", "18z",  "", "Apr29", \
                            "", "06z", "",  "12z", "",   \
                            "18z", "", "Apr30","", "06z",   \
                            "", "12z", "",  "18z", "",   \
                            "May01", "", "06z",  "", "12z"/)
  tempsfc_res@tmXTOn         = False         ; turn off the top tickmarks
  tempsfc_res@xyLineThicknesses = 2          ; increase line thickness
  tempsfc_res@xyLineColor    =  "red"        ; set line color

  tempsfc_res@gsnDraw         = False        ; Don't draw individual plot.
  tempsfc_res@gsnFrame        = False        ; Don't advance frame.

;********************************************************
; Create the five plots (they won't get drawn here, because gsnDraw
; was set to False for all of them.
;********************************************************
  rhfill    = gsn_contour(wks,smothrh,rh_res)
  templine  = gsn_contour(wks,smothtemp,temp_res)
  windlayer = gsn_vector(wks,ugrid,vgrid,uv_res)
  rainhist  = gsn_csm_xy(wks,taus,rain03,rain_res)
  temptmsz  = gsn_csm_xy(wks,taus,tempht,tempsfc_res)
;********************************************************
; three of the above plots become one overlay plot
;********************************************************
  overlay(rhfill,templine)   ; result is templine over rhfill
  overlay(rhfill,windlayer)  ; result is windlayer over the other two
  draw(rhfill)               ; draw this overlay result
  draw(rainhist)             ; draw the rain histogram
  draw(temptmsz)             ; draw the temperature time series
  frame(wks)                 ; finally advance the frame once all on page
end
