;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
    data_file_name1="$DATAOBV/NCEP_DOE/monthly/uwnd.10m.mon.mean.nc"
    data_file_name2="$DATAOBV/NCEP_DOE/monthly/vwnd.10m.mon.mean.nc"
    data_file_name3="$DATAOBV/PRECPT/GPCP_precip.mon.mean.nc"
    
    g_fig_name="../fig/FIG4b_case"
    g_fig_title="2015-2014 Pr, Surface UV & Wind Stress Curl"
    g_font =0.013
    g_font2=0.015
    g_fig_rank=(/"(b)(c)"/)
    ;one month rightward shift
    yrstrt0  = 198101
    yrlast0  = 201512
    
    yrstrt1  = 201401
    yrlast1  = 201512

    ;Smaller Region
    g_latS=-20.
    g_latN=20.
    g_lonW=100.
    g_lonE=200.
    g_season="MAM"
;---------------Read data-------------------
    ctrl_in1 = addfile(data_file_name1,"r")
    time = ctrl_in1->time
    yyyymm =cd_calendar(time,-1)
    istrt = ind(yyyymm .eq. yrstrt0)
    ilast = ind(yyyymm .eq. yrlast0)
    var1 = short2flt(ctrl_in1->uwnd(istrt:ilast,0,:,:))


    ctrl_in2 = addfile(data_file_name2,"r")
    time = ctrl_in2->time
    yyyymm =cd_calendar(time,-1)
    istrt = ind(yyyymm .eq. yrstrt0)
    ilast = ind(yyyymm .eq. yrlast0)
    var2 = short2flt(ctrl_in2->vwnd(istrt:ilast,0,:,:))

    delete([/time, yyyymm/])
    ctrl_in3 = addfile(data_file_name3,"r")
    time = ctrl_in3->time
    yyyymm =cd_calendar(time,-1)
    istrt = ind(yyyymm .eq. yrstrt0)
    ilast = ind(yyyymm .eq. yrlast0)
    var3 = ctrl_in3->precip(istrt:ilast,:,:)

    


;--------------Proprocessing-----------
    
    var1_ssn=month_to_season(var1,g_season)
    var2_ssn=month_to_season(var2,g_season)
    var3_ssn=month_to_season(var3,g_season)
    
    var1_clim=dim_avg_n_Wrap(var1_ssn,0)
    var2_clim=dim_avg_n_Wrap(var2_ssn,0)
    var3_clim=dim_avg_n_Wrap(var3_ssn,0)

    diff_var1 = var1_ssn(0,:,:)
    diff_var2 = var2_ssn(0,:,:)
    diff_var3 = var3_ssn(0,:,:)
    


    diff_var1 =var1_ssn(34,:,:) -var1_clim
    diff_var2 =var2_ssn(34,:,:) -var2_clim
    diff_var3 =var3_ssn(34,:,:) -var3_clim
    
    
  
    ; Calculate the Sverdrup Transport
    ; Vs=(1/beta)*curl(tao)
    ;   tao=ruo*Cd*U*U
    ;   ruo*Cd=2kg/m3
    ;   beta=partial(f)/(a*partial(fai))
    ;   f=2*om*sin(fai)

    ruo=1.22 ;kg/m3
    Cd=0.0013  
    a=6378388 ; R of the earth
    om=7.29e-5
    d2r=0.0174533 ; convert to radians

    tao_x_exp=var1_ssn(1,:,:)
    tao_y_exp=var2_ssn(1,:,:)

    tao_x_ctrl=var1_ssn(0,:,:)
    tao_y_ctrl=var2_ssn(0,:,:)
   
    tao_x_exp=ruo*Cd*tao_x_exp*tao_x_exp
    tao_y_exp=ruo*Cd*tao_y_exp*tao_y_exp

    tao_x_ctrl=ruo*Cd*tao_x_ctrl*tao_x_ctrl
    tao_y_ctrl=ruo*Cd*tao_y_ctrl*tao_y_ctrl    

    tao_x_diff=diff_var1
    tao_y_diff=diff_var2
    
    tao_x_diff=ruo*Cd*diff_var1*diff_var1
    tao_y_diff=ruo*Cd*diff_var2*diff_var2

  

    curl_exp=tao_x_ctrl
    curl_ctrl=tao_x_ctrl
    curl_diff0=tao_x_ctrl
    curl_ctrl=uv2vrF_Wrap(tao_x_ctrl,tao_y_ctrl)
    curl_exp=uv2vrF_Wrap(tao_x_exp,tao_y_exp)
    curl_diff0=uv2vrF_Wrap(tao_x_diff,tao_y_diff)
    curl_diff=curl_exp-curl_ctrl

    wks = gsn_open_wks("png",g_fig_name)  ; open a ps file

    plot = new((/2/),graphic)
  plot_sig = new((/2/),graphic)
  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
; gsn_define_colormap(wks,"BlueRed")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



;  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
;  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)
    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        =  -4e-8          ; set min contour level
    res@cnMaxLevelValF        =  4e-8          ; set max contour level
    res@cnLevelSpacingF       =  5e-9          ; set contour interval
    res@vpHeightF=0.2
    res@vpWidthF=0.6
;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map

  res@gsnSpreadColorStart  = 15               ; start at color 17
  res@gsnSpreadColorEnd    = 101-13                ; end at color 200
;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True   ; turn off the label bar
;  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1

  res@mpFillOn   = True     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
  res@mpCenterLonF = 180.
  res@mpMaxLatF  = g_latN
  res@mpMinLatF  = g_latS
  res@mpMaxLonF  = g_lonE
  res@mpMinLonF  = g_lonW

;  res@mpShapeMode = "FreeAspect" 

;  res@vpWidthF = 0.8
;  res@vpHeightF = 0.6

;  res@tmXBMajorOutwardLengthF = -0.
;  res@tmYLMajorOutwardLengthF = -0.
;  res@tmYRMajorOutwardLengthF = -0.
  
;  res@tmXBMinorOutwardLengthF = -0.
;  res@tmYLMinorOutwardLengthF = -0.
;  res@tmYRMinorOutwardLengthF = -0.
    
     ; now change the size of the tickmark labels
  res@tmXBTickSpacingF = 30
  res@tmYLTickSpacingF = 10
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =


;-----------------------------------------------------------------------------
    res3                  = True       ; use plot options
    res3@cnFillOn         = False;True       ; Fill contours
    res3@cnLinesOn        = True      ; turn off contour lines
    ;for tp masking
    res3@gsnFrame         = False
    res3@gsnDraw  = False
    res3@cnLineLabelsOn   = False      ; turn off contour line labels
    res3@cnLineThicknessF = 2 
    res3@cnInfoLabelOn = False


    res3@cnLevelSelectionMode="ExplicitLevels"
    res3@cnLevels = (/1.0, 2.0, 3.0/)
    ;    res3@cnLevels = (/4.0, 6.0, 8.0, 10.0/)
    res3@cnLineColor      = "Blue"
    res3@gsnLeftString      = " "
    res3@gsnRightString      = " "
    res3@cnLineDashPattern      = 0
    cmpvarsmoth=smth9_Wrap(diff_var3,0.5,0.25, True)
    plot_cn_pos = gsn_csm_contour(wks, diff_var3, res3) ; create a default plot
    
    res3@cnLevels = -res3@cnLevels
    res3@cnLineColor      = "red"
    res3@cnLineDashPattern      = 1
    
    plot_cn_neg = gsn_csm_contour(wks, diff_var3,res3) ; create a default plot
  
  ;plot_cn_neg(1) = gsn_csm_contour(wks,cmp_var4_su(2,:,:),res3) ; create a default plot
 

;-------------------------------------------------
;-----------------------------------------------------
  res4                  = True       ; use plot options
  res4@cnFillOn         = True       ; Fill contours
  res4@cnLinesOn        = False;True      ; turn off contour lines
  res4@gsnFrame         = False
  res4@gsnDraw  = False
  res4@cnLineLabelsOn   = False      ; turn off contour line labels
  res4@cnLineThicknessF = 2
  res4@cnLineColor      = "black"
  res4@cnInfoLabelOn = False
  res4@cnMonoFillPattern    = True;False
  res4@cnFillPattern = 3 
  res4@cnMonoFillScale = True
  res4@cnFillScaleF = 0.6 
  res4@cnMonoFillColor = True
  res4@cnFillColor  =  "black"
  res4@cnFillDotSizeF = 0.0025
 
  res4@lbLabelBarOn = False;True   ; turn off the label bar
 
;  res4@cnLevelSelectionMode="ExplicitLevels"
;  res4@cnLevels = (/3000,1000/)
  res4@gsnLeftString      = " "
  res4@gsnRightString      = " "
 
;-----------------------------------------------------------------------------
     ;-----------------------------------------------------------------------------
       ;-------Set for the vector plot------
    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    ;vcres@vcRefAnnoOrthogonalPosF = -1             ; move ref vector up
    vcres@vcRefMagnitudeF         = 2.0             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.035
    vcres@vcRefAnnoString1  = "2 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.015
    vcres@vcLineArrowThicknessF     = 2    ;thickness of vector

    vcres@vcLineArrowHeadMinSizeF   = 0.015
    vcres@vcLineArrowHeadMaxSizeF   = 0.015       
    




do i = 0,0
    res@gsnLeftString = g_fig_rank(i)
    res@gsnCenterString = g_fig_title
    res@gsnRightString = ""

    cmpvrsmoth=smth9_Wrap(curl_diff,0.5,0.25, True)
    plot(i) = gsn_csm_contour_map_ce(wks,cmpvrsmoth,res)

    plot_V(i) = gsn_csm_vector(wks,diff_var1,diff_var2,vcres)
    overlay(plot(i),plot_V(i))
    overlay(plot(i),plot_cn_pos)
    overlay(plot(i),plot_cn_neg)
    ;overlay(plot(i),plot_cn_sen(i))
end do
    diff_var1_lat=dim_avg_n_Wrap(diff_var1({-20:20},{140:170}),1)
    diff_var3_lat=dim_avg_n_Wrap(diff_var3({-20:20},{140:170}),1)
    print(diff_var1_lat&lat)
    print(diff_var3_lat&lat)
    xyres                 = True         ; xy plot mods desired
    xyres@vpHeightF        = .20          ; set width of second plot
    xyres@vpWidthF        = .15          ; set width of second plot
    xyres@tmXBMinorOn     = False        ; no minor tickmarks

    xyres@gsnDraw         = False        ; don't draw yet
    xyres@gsnFrame        = False        ; don't advance frame yet

    xyres@tmXBLabelFontHeightF=g_font2        ; change font height
    xyres@gsnCenterString=""
    xyres@trYMinF         = -20 
    xyres@trYMaxF         = 20
    xyres@trXMinF         = -3. 
    xyres@trXMaxF         = 3.
    xyres@xyLineThicknesses    = 2.0      ; line thicknesses
   
    xyres@tmYRTickSpacingF = 5.
    xyres@tmYRMinorOn=False
    xyres@tmYROn              = True 
    xyres@tmXBMode="Explicit"
    ;xyres@tmYRLabelsOn=True
    xyres@tmXBValues=fspan(-2.0,4.0,4)
    xyres@tmXBLabels=fspan(-2.0,4.0,4)
    xyres@tiXAxisString="Wind Speed (m/s)"
    xyres@tiXAxisFontHeightF=g_font2
    

    xy2res=xyres
    xyres@tiYAxisString       = "Easterly Speed (m/s)"
    xy2res@tiXAxisSide="Bottom"
    xy2res@xyLineThicknesses    = 2.0      ; line thicknesses
    xy2res@gsnXRefLine=0.0
    xy2res@gsnXYBarChart=True
    xy2res@gsnXYBarChartBarWidth = 1.5                 ; change bar widths
    xy2res@gsnXYBarChartColors = (/"skyblue2"/)             ; below ref line fill blue
    xyres@xyDashPattern=1
    plotxy = gsn_csm_xy(wks,diff_var1_lat,diff_var1_lat&lat,xyres)
    plotxy2 = gsn_csm_xy(wks,diff_var3_lat,diff_var3_lat&lat,xy2res)
    overlay(plotxy,plotxy2)

    diff_var3_lat=where(diff_var3_lat .lt. 0, diff_var3_lat,0)
    xy2res@gsnXYBarChartColors = (/"orangered"/)             ; below ref line fill blue
    plotxy3 = gsn_csm_xy(wks,diff_var3_lat,diff_var3_lat&lat,xy2res)
    overlay(plotxy,plotxy3)

   
    newplot = gsn_attach_plots(plot(0),(/plotxy/),res,xy2res)



    draw(plot(0))
    frame(wks)





end




