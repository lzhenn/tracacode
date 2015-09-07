;*************************************************************
;Aim: draw PRECC annually ltm trend 
;Mission:
;   1. Read data
;   2. Post-post process
;     2.1 take the trend 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-05-03
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN
;   2015-05-03  Change to caculate season trend 
;   2015-06-20  Change to caculate timeseries
;   2015-06-22  Change to fit multi-data 2 region timeseries
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------PRECC
;================================================
;global variables
    ;Define parameters
    g_data_path = "../data/obv/GPCP_precip.mon.mean.nc"
    g_data_path2 = "../data/obv/CMAP_precip.mon.mean.nc"
    g_data_path3 = "../data/obv/precip.mon.mean.1x1.nc"

    ;SCS+PhSea
    sea_latS=0.
    sea_latN=15.
    sea_lonW=105.
    sea_lonE=155.
    
    ;South China
    sc_latS=20.
    sc_latN=35.
    sc_lonW=110.
    sc_lonE=135.

    g_season = "MAM"
    ;g_season_rank=(/"DJF","MAM","JJA","SON"/)
; create an array of desired pressure levels:

        
    g_font = 0.035

    g_strt_mon = 197901 
    g_lst_mon = 201312
    yr_end = 2013
    g_fig_name    =   "../fig/selected_973Report/Fig2_"+g_strt_mon+"-"+g_lst_mon+"_Pr_timeseries_2Region"+g_season
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    
    g_fig_title     = (/"Southern China ","SCS+PhS "/)+g_season +" Pr Timeseries"
   ;g_fig_title1   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr trend"  ;for dsstdt
   ;g_fig_title2   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr' trend" ;for dsst'dt


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	var1  =ctrl_in1->precip(istrt:ilast,:,:)			; p for unify the var name

    ctrl_file2   = g_data_path2
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	time_hist2    = ctrl_in2->time
    yyyymm2  = cd_calendar(time_hist2,-1)
    istrt   = ind(yyyymm2 .eq. g_strt_mon)
    ilast   = ind(yyyymm2 .eq. g_lst_mon)
	var2  =ctrl_in2->precip(istrt:ilast,:,:)			; p for unify the var name

    ctrl_file3   = g_data_path3
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile
	time_hist3    = ctrl_in3->time
    yyyymm3  = cd_calendar(time_hist3,-1)
    istrt   = ind(yyyymm3 .eq. g_strt_mon)
    ilast   = ind(yyyymm3 .eq. g_lst_mon)
	var3  =ctrl_in3->precip(istrt:ilast,:,:)			; p for unify the var name

; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    var1_season = month_to_season(var1,g_season)
    var2_season = month_to_season(var2,g_season)
    var3_season = month_to_season(var3,g_season)
    
    var1_season_scmean = wgt_areaave_Wrap(var1_season(:,{sc_latS:sc_latN},{sc_lonW:sc_lonE}),1.0,1.0,0)
    var1_season_seamean = wgt_areaave_Wrap(var1_season(:,{sea_latS:sea_latN},{sea_lonW:sea_lonE}),1.0,1.0,0)
    
    var2_season_scmean = wgt_areaave_Wrap(var2_season(:,{sc_latS:sc_latN},{sc_lonW:sc_lonE}),1.0,1.0,0)
    var2_season_seamean = wgt_areaave_Wrap(var2_season(:,{sea_latS:sea_latN},{sea_lonW:sea_lonE}),1.0,1.0,0)
    
    var3_season_scmean = wgt_areaave_Wrap(var3_season(:,{sc_latS:sc_latN},{sc_lonW:sc_lonE}),1.0,1.0,0)
    var3_season_seamean = wgt_areaave_Wrap(var3_season(:,{sea_latS:sea_latN},{sea_lonW:sea_lonE}),1.0,1.0,0)

    var1_sn_rm_scrunmean=runave_Wrap(var1_season_scmean,3,0)
    var1_sn_rm_searunmean=runave_Wrap(var1_season_seamean,3,0)
    var2_sn_rm_scrunmean=runave_Wrap(var2_season_scmean,3,0)
    var2_sn_rm_searunmean=runave_Wrap(var2_season_seamean,3,0)
    var3_sn_rm_scrunmean=runave_Wrap(var3_season_scmean,3,0)
    var3_sn_rm_searunmean=runave_Wrap(var3_season_seamean,3,0)



    var1_sn_rm_scline=regline(ispan(1979,yr_end,1),var1_season_scmean)
    var1_sn_rm_sealine=regline(ispan(1979,yr_end,1),var1_season_seamean)
    

    printVarSummary(var1_sn_rm_scline)    
    df   = var1_sn_rm_scline@nptxy-2
    prob = (1 - betainc(df/(df+var1_sn_rm_scline@tval^2), df/2.0, 0.5) ) ;  also: prob = cdft_p(rc@tval,df)
    yReg = var1_season_scmean
    yReg = var1_sn_rm_scline*ispan(1979,yr_end,1) + var1_sn_rm_scline@yintercept   ; NCL array notation 
    data      = new((/5,dimsizes(var1_season_scmean)/),float)
    data(0,:) = var1_season_scmean
    data(1,:) = var2_sn_rm_scrunmean
    data(2,:) = var3_sn_rm_scrunmean
    data(3,:) = var1_sn_rm_scrunmean
    data(4,:) = yReg

    df2   = var1_sn_rm_sealine@nptxy-2
    prob2 = (1 - betainc(df/(df+var1_sn_rm_sealine@tval^2), df/2.0, 0.5) ) ;  also: prob = cdft_p(rc@tval,df)
    yReg2 = var1_season_seamean
    yReg2 = var1_sn_rm_sealine*ispan(1979,yr_end,1) + var1_sn_rm_sealine@yintercept   ; NCL array notation 
    data2      = new((/4,dimsizes(var1_season_seamean)/),float)
    data2(0,:) = var1_season_seamean
    data2(1,:) = var2_sn_rm_searunmean
    data2(2,:) = var1_sn_rm_searunmean
    data2(3,:) = yReg2

;**********************************************************************************************
;MISSION.3		Display timeseries 
;**********************************************************************************************



	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("eps",g_fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

    plot = new((/2/),graphic)
    res@gsnFrame         = False
    res@gsnDraw  = False
             
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.3


	;res@trYMinF            = 0.9*min(var1_season_scmean)                ; Y axis limits
	;res@trYMaxF            = 1.1*max(var1_season_scmean)

	res@trYMinF            = 3.5                ; Y axis limits
	res@trYMaxF            = 6.5
    res@gsnCenterString = g_fig_title(0)
    res@gsnLeftString = g_fig_rank(0)
	res@trXMinF  = 0                   ; min value on x-axis
	res@trXMaxF  = dimsizes(var1_season_scmean)-1                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiYAxisString = "Pr Rate (mm/day)"
	res@tmXBValues = ispan(0,dimsizes(var1_season_scmean)-1,5) ;interval
	res@tmXBLabels = ispan(1979,2013,5)         ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue","brown","darkgreen","red","black"/) ; colors chosen
	res@xyLineThicknesses	 = (/2.0,2.0,2.0,4.0,5.0/)      ; line thicknesses
	res@xyDashPatterns	 = (/1.,0.,0.,0.,1./)      ; make all lines solid
	res@tmXBMajorThicknessF = 5.0
	res@tmYLMajorThicknessF = 5.0
	res@tmXBMinorThicknessF = 4.0
	res@tmYLMinorThicknessF = 4.0
	res@tmBorderThicknessF = 4.0
	res@tmXBLabelFontHeightF =0.022
	res@tmYLLabelFontHeightF = 0.022
	; Note that a colon is the default function code. We recommend
	; setting default code to be a tilde (~) in your .hluresfile.
	; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml


    plot(0)  = gsn_csm_xy (wks,ispan(0,dimsizes(var1_season_scmean)-1,1),data,res)   ; create plot
    
    res@tiXAxisString = "Year"
	res@trYMinF            = 9.0                ; Y axis limits
	res@trYMaxF            = 1.0
    res@gsnCenterString = g_fig_title(1)
    res@gsnLeftString = g_fig_rank(1)
    delete(res@xyLineColors)
    delete(res@xyLineThicknesses)
    delete(res@xyDashPatterns)
    res@xyDashPatterns=(/1.,0.,0.,1./)
    res@xyLineThicknesses=(/2.0,2.0,4.0,5.0/)
    res@xyLineColors = (/"blue","brown","red","black"/)
	res@trYMinF            = 0.9*min(var1_season_seamean)                ; Y axis limits
	res@trYMaxF            = 1.1*max(var2_season_seamean)
    r_timeseries = escorc(data(3,:),data2(2,:))
    res@gsnRightString="R="+sprintf("%4.2f",r_timeseries)
    plot(1)  = gsn_csm_xy (wks,ispan(0,dimsizes(var1_season_seamean)-1,1),data2,res)   ; create plot
 

;---------------------------Add plot legend-----------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 1.                    ; solid line
    res_lines@gsLineThicknessF  = 2.                    ; line thicker

    ;res_lines@gsMarkerColor     = "blue"
    ;res_lines@gsMarkerIndex     = 16
    ;res_lines@gsMarkerSizeF     = 0.01
    
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    res_lines@gsLineColor       = "blue"
    yy = (/6.2,6.2/)
    xx = (/21,23/)
    text_pos = 23.5
    dum11 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum12 = gsn_add_text(wks,plot(0),"GPCP",text_pos,yy(0),res_text); add text
    ;dum55 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)   


    res_lines@gsLineColor       = "red"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 4.                    ; line thicker
    yy = yy - 0.25
    dum21 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum22 = gsn_add_text(wks,plot(0),"GPCP 3yrm",text_pos,yy(0),res_text); add text
    ;dum77 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)   

    res_lines@gsLineColor       = "brown"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 2.                    ; line thicker
    yy = yy - 0.25
    dum31 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum32 = gsn_add_text(wks,plot(0),"CMAP 3yrm",text_pos,yy(0),res_text); add text

    res_lines@gsLineColor       = "darkgreen"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 2.                    ; line thicker
    yy = yy - 0.25
    dum41 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum42 = gsn_add_text(wks,plot(0),"PREC/L 3yrm",text_pos,yy(0),res_text); add text

    res_lines@gsLineColor       = "black"
    res_lines@gsLineDashPattern = 1.
    res_lines@gsLineThicknessF  = 5.                    ; line thicker
    yy = yy - 0.25
    dum51 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum52 = gsn_add_text(wks,plot(0),"GPCP regline",text_pos,yy(0),res_text); add text


    ;Plot2
    res_lines@gsLineColor       = "blue"
    res_lines@gsLineDashPattern = 1.
    res_lines@gsLineThicknessF  = 2.                    ; line thicker
    yy = (/3.9,3.9/)
    dum61 = gsn_add_polyline(wks,plot(1),xx,yy,res_lines)              ; add polyline
    dum62 = gsn_add_text(wks,plot(1),"GPCP",text_pos,yy(0),res_text); add text

    res_lines@gsLineColor       = "red"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 4.                    ; line thicker
    yy = yy - 0.6
    dum71 = gsn_add_polyline(wks,plot(1),xx,yy,res_lines)              ; add polyline
    dum72 = gsn_add_text(wks,plot(1),"GPCP 3yrm",text_pos,yy(0),res_text); add text

    res_lines@gsLineColor       = "brown"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 2.                    ; line thicker
    yy = yy - 0.6
    dum81 = gsn_add_polyline(wks,plot(1),xx,yy,res_lines)              ; add polyline
    dum82 = gsn_add_text(wks,plot(1),"CMAP 3yrm",text_pos,yy(0),res_text); add text

    res_lines@gsLineColor       = "black"
    res_lines@gsLineDashPattern = 1.
    res_lines@gsLineThicknessF  = 5.                    ; line thicker
    yy = yy - 0.6
    dum91 = gsn_add_polyline(wks,plot(1),xx,yy,res_lines)              ; add polyline
    dum92 = gsn_add_text(wks,plot(1),"GPCP regline",text_pos,yy(0),res_text); add text




    gsn_panel(wks,plot,(/2,1/),False)

    draw(plot)
    frame(wks)

exit




















; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/4/),graphic)
;  plot_tp = new((/2/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -2.0         ; set min contour level
 res@cnMaxLevelValF        = 2.0          ; set max contour level
 res@cnLevelSpacingF       = 0.25          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnSpreadColorStart  = 2               ; start at color 17
  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1

  res@mpFillOn   = False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  ;res@mpFillDrawOrder="PostDraw"
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
  res@tmYLTickSpacingF = 15
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     

do i = 0,3
    res@gsnLeftString = g_fig_rank(i)
    res@gsnCenterString = g_fig_title(i)
    res@gsnRightString = ""
    plot(i) = gsn_csm_contour_map_ce(wks,dvar1_dt(i,:,:),res) ; create a default plot
end do


;-------------------------------------------------------------------
  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 2
  res3@cnLineColor      = "black"
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/3000,1000/)
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "


  ;plot_tp = gsn_csm_contour(wks,phis,res3)

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
  res4@cnFillPattern = 17
  res4@cnMonoFillScale = True
  res4@cnFillScaleF = 1.
  res4@cnMonoFillColor = True
  res4@cnFillColor  =  "red"
  res4@cnFillDotSizeF = 0.003
 
  res4@lbLabelBarOn = False;True   ; turn off the label bar
 
;  res4@cnLevelSelectionMode="ExplicitLevels"
;  res4@cnLevels = (/3000,1000/)
  res4@gsnLeftString      = " "
  res4@gsnRightString      = " "
;-----------------------------------------------------------------------------
          
  vcres = True
  vcres@gsnDraw          = False           ; don't draw
  vcres@gsnFrame         = False           ; don't advance frame
  vcres@gsnRightString   = " "             ; turn off right string
  vcres@gsnLeftString    = " "             ; turn off left string
  vcres@gsnCenterString    = " "
 
  vcres@vcRefAnnoOn      = True
  vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  vcres@vcRefMagnitudeF         = 5.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017
  vcres@vcRefAnnoString1  = "5 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.01
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
;  vcres@vcLineArrowHeadMinSizeF   = 0.010
;  vcres@vcLineArrowHeadMaxSizeF   = 0.130
;--------------------------------------

  ;plot_V(0) = gsn_csm_vector(wks,diff_var1,diff_var2,vcres)

  ;plot_V(1) = gsn_csm_vector(wks,cp_diff_var1,cp_diff_var2,vcres)

;  plot_sh(0) = gsn_csm_contour(wks,diff_var3_sig,res4)

  ;plot_sh(1) = gsn_csm_contour(wks,cp_diff_var3_sig,res4)

 ; overlay(plot(0),plot_sh(0))
  ;overlay(plot(1),plot_sh(1))

  ;overlay(plot(0),plot_V(0))
  ;overlay(plot(1),plot_V(1))

 
  gsn_panel(wks,plot,(/2,2/),False)

  draw(plot)
  frame(wks)
end 
