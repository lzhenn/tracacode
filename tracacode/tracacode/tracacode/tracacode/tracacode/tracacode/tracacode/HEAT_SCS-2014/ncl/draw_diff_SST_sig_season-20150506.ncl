;*************************************************************
;Aim: For draw TS (total prec water) diff with sig test
;
;Mission:
;   1. Read data from post model datasets
;   2. Post-post process to deserved results 
;   3. Significance test
;   4. Draw the TS and overlap them
;                       Zhenning Li
;                       2015-05-06
;Last Edited:
;   2014-11-07  Create
;   2015-05-06  Change to fit team server
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------TS
;================================================

;ESAT ASIA
;	latS   =  -20.
;	latN   =  60. 
;	lonL   =  20.
;	lonR   =  220.
;GLOBAL
	g_latS   =  -60.
	g_latN   =  60. 
	g_lonW   =  0.
	g_lonE   =  360.



; create an array of desired pressure levels:
	g_season      =   "SON"
        
    g_cp_ctrl_name    =   "CON_CP"
    g_cp_exp_names    =   (/"HEAT_CP"/)
    g_strt_mon = 017002 ; in fact, you need to write 015002 Mean, for cam.h0.0150-01, CAM bug 
    g_lst_mon = 020001 ; So as g_strt_mon
    g_cp_process_period   =   g_strt_mon+"-"+g_lst_mon
    g_cp_run_period = "0150-0199"
    g_font = 0.025
    g_var         = "TS"

    g_pdata_fn="../data/model/pro/"
    g_fig_name    =   "../fig/"+g_var+"-DIFF-"+g_cp_exp_names+"-"+g_cp_ctrl_name+g_cp_process_period+"_CAM4_"+g_season
    g_fig_title   =   g_season+" "+g_var+" DIFF "+g_cp_exp_names+"-"+g_cp_ctrl_name


;*************************For B_Compset Ctrl***********************************

;; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	cp_ctrl_file1   = g_pdata_fn+g_cp_ctrl_name+"."+g_var+".mon."+g_cp_run_period+".nc"
	cp_ctrl_in1     = addfile (cp_ctrl_file1, "r")   ; note the "s" of addfile
	
    time_hist    = cp_ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	cp_ctrl_var  = cp_ctrl_in1->$g_var$(istrt:ilast,:,:)			; p for unify the var name
    printVarSummary(cp_ctrl_var)
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================

	cp_ctrl_var_season = month_to_season(cp_ctrl_var, g_season)

	cp_ctrl_var_season_clim = dim_avg_n_Wrap(cp_ctrl_var_season,0)

	cp_ctrl_var_var = dim_variance_n(cp_ctrl_var_season,0)

	do i = 0,dimsizes(g_cp_exp_names)-1

;*************************For B_Compset Heat***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	cp_exp_file1   = g_pdata_fn+g_cp_exp_names(0)+"."+g_var+".mon."+g_cp_run_period+".nc"
	cp_exp_in1     = addfile (cp_exp_file1, "r")   ; note the "s" of addfile
	
	cp_exp_var  = cp_exp_in1->TS(istrt:ilast,:,:)			; p for unify the var name
    
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
	cp_exp_var_season = month_to_season (cp_exp_var, g_season)
    
    
    dimz = dimsizes(cp_exp_var_season)
    yr_length = dimz(0)


	cp_exp_var_season_clim = dim_avg_n_Wrap(cp_exp_var_season,0)

	cp_exp_var_var = dim_variance_n(cp_exp_var_season,0)

	cp_diff_var = cp_exp_var_season_clim	

	cp_diff_var = (cp_exp_var_season_clim-cp_ctrl_var_season_clim)		
	cp_diff_var_sig = cp_diff_var

		;============================================================
		;Sig test
		;============================================================

		sigr = 0.05                        ; critical sig lvl for r

		iflag= False                        ; population variance similar
		prob = ttest(cp_ctrl_var_season_clim,cp_ctrl_var_var,yr_length, cp_exp_var_season_clim,cp_exp_var_var,yr_length, iflag, False)
		
		cp_diff_var_sig=mask(cp_diff_var, prob .lt. sigr, True)
	end do




;-----------------------------------------------------------------------------
  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/1/),graphic)
 ; plot_tp = new((/2/),graphic)
  plot_sh = new((/1/),graphic)
 ; plot_V = new((/2/),graphic)

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks1,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


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

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -1.5          ; set min contour level
 res@cnMaxLevelValF        =  1.5          ; set max contour level
 res@cnLevelSpacingF       =  0.25          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
  ;res@gsnSpreadColorStart  = 2                ; start at color 17
  ;res@gsnSpreadColorEnd    = 14                ; end at color 200

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
  res@tmXBTickSpacingF = 60
  res@tmYLTickSpacingF = 20
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     


 res@gsnLeftString = "(a)"
 res@gsnCenterString = " HEAT - CON (CAM4)"

 ;plot(0) = gsn_csm_contour_map_ce(wks,diff_var3,res) ; create a default plot
 
; res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
; res@cnMinLevelValF        = -3.          ; set min contour level
; res@cnMaxLevelValF        =  3.          ; set max contour level
; res@cnLevelSpacingF       =  0.5          ; set contour interval
 

 res@gsnLeftString = "(a)"
 res@gsnCenterString = g_fig_title
 plot(0) = gsn_csm_contour_map_ce(wks,cp_diff_var,res) ; create a default plot


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
 
  vcres@vcLineArrowThicknessF     = 1.5    ;thickness of vector
;  vcres@vcLineArrowHeadMinSizeF   = 0.010
;  vcres@vcLineArrowHeadMaxSizeF   = 0.130
;--------------------------------------

  ;plot_V(0) = gsn_csm_vector(wks,diff_var1,diff_var2,vcres)

  ;plot_V(1) = gsn_csm_vector(wks,cp_diff_var1,cp_diff_var2,vcres)


  plot_sh(0) = gsn_csm_contour(wks,cp_diff_var_sig,res4)

  overlay(plot(0),plot_sh(0))
  ;overlay(plot(1),plot_sh(1))

  ;overlay(plot(0),plot_V(0))
  ;overlay(plot(1),plot_V(1))

 
  ;gsn_panel(wks,plot,(/2,1/),False)

  draw(plot)
  frame(wks)
end 
