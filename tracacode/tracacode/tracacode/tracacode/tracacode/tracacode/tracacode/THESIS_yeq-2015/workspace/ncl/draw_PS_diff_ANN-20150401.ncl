;*************************************************************
;Aim: draw difference of PS from two epoch
;
;Mission:
;   1. Read data from ECMWF datasets
;   2. Post-post process
;     2.1 DJF Mean
;     2.2 Difference
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-04-01
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-03-31  Change to fit ECMWF datasets and yeq use
;   2015-04-01  Change to fit PS 
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------TS
;================================================
;global variables
    ;Define parameters
    g_data_path = "../data/PS_SLP_T2m-200001-201412.nc" 

    g_latS=15.
    g_latN=55.
    g_lonW=105.
    g_lonE=135.
; create an array of desired pressure levels:

    g_frst  = "2004_07"
    g_lst   = "2011_14"
    g_epoch          = 4
    g_p1_strt  = 200401 
    g_p1_lst  = 200712
    g_p2_strt  = 201101
    g_p2_lst  = 201412
    g_season         = "DJF"

    g_font = 0.025

    g_fig_name    =   "../fig/diff_PS_ANN_"+g_lst+"-"+g_frst
    ;g_fig_rank    =   "(b)"
    ;g_fig_title   =   "HEAT_TP-CON"


; ==============================================================
; mission 1. open the file: read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	ctrl_time  = ctrl_in1->time
    yyyymm     = cd_calendar(ctrl_time,-1)
    i_p1_strt = ind (yyyymm .eq. g_p1_strt)
    i_p1_lst = ind (yyyymm .eq. g_p1_lst)
    i_p2_strt = ind (yyyymm .eq. g_p2_strt)
    i_p2_lst = ind (yyyymm .eq. g_p2_lst)
    ctrl_var1  = short2flt(ctrl_in1->msl(i_p1_strt:i_p1_lst,:,:))
	ctrl_var2  = short2flt(ctrl_in1->msl(i_p2_strt:i_p2_lst,:,:))
    printVarSummary(ctrl_var2)	
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
	ctrl_var1_season = month_to_annual (ctrl_var1, 1)
	ctrl_var2_season = month_to_annual (ctrl_var2, 1)
    printVarSummary(ctrl_var1_season)

    diff_var_season = ctrl_var1_season(0,:,:)
    diff_var_season = dim_avg_n_Wrap(ctrl_var2_season,0)-dim_avg_n_Wrap(ctrl_var1_season,0)
    diff_var_season = diff_var_season
;-----------------------------------------------------------------------------
  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/1/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
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
 res@cnMinLevelValF        = -100          ; set min contour level
 res@cnMaxLevelValF        =  100          ; set max contour level
 res@cnLevelSpacingF       =  10          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnLeftString = "(c)"
  res@gsnCenterString = "Upper-level temperature"
  res@gsnRightString = ""
  res@gsnStringFontHeightF = g_font
  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1



  res@mpDataSetName         = "Earth..4"   ; This new database contains
  res@mpOutlineSpecifiers   = (/"China:states","Taiwan"/) 
  res@mpDataBaseVersion     = "MediumRes"  ; Medium resolution database
  res@mpProvincialLineColor       = "Brown"
  res@mpProvincialLineThicknessF  = 2
  res@mpFillOn   = True;False     ; turn off gray continents
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
  res@tmXBTickSpacingF = 5
  res@tmYLTickSpacingF = 5
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     



 res@gsnLeftString = ""
 res@gsnCenterString = "ANN PS ("+g_lst+"-"+g_frst+")"
 plot(0) = gsn_csm_contour_map_ce(wks,diff_var_season,res) ; create a default plot
 

;-------------------------------------------------------------------
  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = True     ; turn off contour line labels
  res3@cnLineThicknessF = 3
  res3@cnLineColor      = "black"
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/0/)
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "


;  plot_cn0 = gsn_csm_contour(wks,diff_var_meg,res3)
  
  res_ws                  = True       ; use plot options
  res_ws@cnFillOn         = False;True       ; Fill contours
  res_ws@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res_ws@gsnFrame         = False
  res_ws@gsnDraw  = False
  res_ws@cnLineLabelsOn   = True     ; turn off contour line labels
  res_ws@cnLineThicknessF = 2
  res_ws@cnLineColor      = "black"
  res_ws@cnInfoLabelOn = False
 
 
  res_ws@cnLevelSelectionMode="ExplicitLevels"
  res_ws@cnLevels = (/0.2,0.1/)
  res_ws@gsnLeftString      = " "
  res_ws@gsnRightString      = " "

;  plot_cn = gsn_csm_contour(wks,diff_var_meg,res_ws)
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
  vcres@vcRefMagnitudeF         = 1.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017
  vcres@vcRefAnnoString1  = "1 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.01
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
;  vcres@vcLineArrowHeadMinSizeF   = 0.010
;  vcres@vcLineArrowHeadMaxSizeF   = 0.130
;--------------------------------------

 ; plot_V(0) = gsn_csm_vector(wks,diff_var1_season,diff_var2_season,vcres)


 ; overlay(plot(0),plot_V(0))
 ; overlay(plot(0),plot_cn0(0))
;  overlay(plot(0),plot_cn(0))
 
  gsn_panel(wks,plot(0),(/1,1/),False)

  draw(plot)
  frame(wks)
end 
