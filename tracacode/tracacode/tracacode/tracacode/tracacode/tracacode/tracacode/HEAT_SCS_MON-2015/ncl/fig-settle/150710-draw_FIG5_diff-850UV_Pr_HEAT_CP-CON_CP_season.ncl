;*************************************************************
;Aim: draw HEAT_CP - CON_CP Pr and 850UV, do the significance test 
;
;Mission:
;   1. Read data from post model datasets
;   2. Post-post process
;     2.1 Climatology 
;     2.2 Difference
;     2.3 Sig test
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-04-06
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-06  Change to fit Season jun
;   2015-06-23  Change to fit 973Report
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
    g_plev        =   (/925.0, 850.0, 700.0, 600.0, 500.0, 400.0, 300.0, 200.0, 100.0, 50.0/)
    g_res  = "f19"
    ;Define parameters
    g_data_path = "../data/model/pro/"
    g_ctrl_case = "B2000_F19G16_CAM4_CTRL"
    g_sen_cases = (/"/HEAT_SCS_MAM-2015"/)

    g_season      =   "MAM"
    g_latS=-5.
    g_latN=45.
    g_lonW=90.
    g_lonE=160.
; create an array of desired pressure levels:

    g_year_start   =   0 ;Rank from 0
    g_year_end     =   49;Rank from 0 
    g_nsmp        =   g_year_end - g_year_start + 1;number of samples for significance test
    g_idx_start = g_year_start*12
    g_idx_end = (g_year_end+1)*12-1

    g_run_period  =   "0250-0299"
        
    g_font = 0.035
    g_var         = (/"UV","Pr"/)

    g_fig_name    =   "../fig/model/diff_"+g_run_period+"_"+g_year_start+"-"+g_year_end+"_850UV_Pr_HEAT-CON_"+g_season
    ;g_fig_rank    =   "B2000_F19G16_CAM4_CTRL"
    g_fig_rank    =   ""
    ;g_fig_title   =   g_season+" HEAT_CP-CON_CP"
    g_fig_title   =    g_season+" 850UV & Pr Diff"


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path+g_ctrl_case+"."+g_var(0)+".plvl.mon."+g_run_period+".nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	ctrl_var1  = ctrl_in1->U(g_idx_start:g_idx_end,1,:,:)			; p for unify the var name
    ctrl_var2  = ctrl_in1->V(g_idx_start:g_idx_end,1,:,:)			; p for unify the var name
	
    ctrl_file1   = g_data_path+g_ctrl_case+"."+g_var(1)+".mon."+g_run_period+".nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	ctrl_var3  = ctrl_in1->PRECT(g_idx_start:g_idx_end,:,:)			; p for unify the var name
    ctrl_var3  = ctrl_var3*86400*1000
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
	ctrl_var1_season = month_to_season (ctrl_var1, g_season)
	ctrl_var1_season_clim = dim_avg_n_Wrap(ctrl_var1_season,0)
	ctrl_var1_var = dim_variance_n(ctrl_var1_season,0)

    ctrl_var2_season = month_to_season (ctrl_var2, g_season)
	ctrl_var2_season_clim = dim_avg_n_Wrap(ctrl_var2_season,0)
	ctrl_var2_var = dim_variance_n(ctrl_var2_season,0)

	ctrl_var3_season = month_to_season (ctrl_var3, g_season)
	ctrl_var3_season_clim = dim_avg_n_Wrap(ctrl_var3_season,0)
	ctrl_var3_var = dim_variance_n(ctrl_var3_season,0)



	do i = 0,dimsizes(g_sen_cases)-1
;*************************For F_Compset Heat***********************************

    ; ==============================================================
    ; Mission 1. Open the file: Read only the user specified period
    ; ==============================================================

        exp_file1   = g_data_path+g_sen_cases(i)+"."+g_var(0)+".plvl.mon."+g_run_period+".nc"
        exp_in1     = addfile (exp_file1, "r")   ; note the "s" of addfile
        
        exp_var1  = exp_in1->U(g_idx_start:g_idx_end,1,:,:)			; p for unify the var name
        exp_var2  = exp_in1->V(g_idx_start:g_idx_end,1,:,:)			; p for unify the var name
        
        exp_file1   = g_data_path+g_sen_cases(i)+"."+g_var(1)+".mon."+g_run_period+".nc"
        exp_in1     = addfile (exp_file1, "r")   ; note the "s" of addfile
        exp_var3  = exp_in1->PRECT(g_idx_start:g_idx_end,:,:)			; p for unify the var name
        exp_var3  = exp_var3*86400*1000
    ; ==============================================================
    ; Mission 2. post-post process data to deserved results
    ; ==============================================================
        exp_var1_season = month_to_season (exp_var1, g_season)
        exp_var1_season_clim = dim_avg_n_Wrap(exp_var1_season,0)
        exp_var1_var = dim_variance_n(exp_var1_season,0)

        exp_var2_season = month_to_season (exp_var2, g_season)
        exp_var2_season_clim = dim_avg_n_Wrap(exp_var2_season,0)
        exp_var2_var = dim_variance_n(exp_var2_season,0)

        exp_var3_season = month_to_season (exp_var3, g_season)
        exp_var3_season_clim = dim_avg_n_Wrap(exp_var3_season,0)
        exp_var3_var = dim_variance_n(exp_var3_season,0)

        diff_var1 = exp_var1_season_clim
        diff_var2 = exp_var2_season_clim
        diff_var3 = exp_var3_season_clim	

        diff_var1 = (exp_var1_season_clim-ctrl_var1_season_clim)
        diff_var2 = (exp_var2_season_clim-ctrl_var2_season_clim)
        diff_var3 = (exp_var3_season_clim-ctrl_var3_season_clim)		
        diff_var3_sig = diff_var3

		;============================================================
		;Sig test
		;============================================================

		sigr = 0.1                        ; critical sig lvl for r

		iflag= False                        ; population variance similar
		prob1 = ttest(ctrl_var1_season_clim,ctrl_var1_var,g_nsmp, exp_var1_season_clim,exp_var1_var,g_nsmp, iflag, False) 
		prob2 = ttest(ctrl_var2_season_clim,ctrl_var2_var,g_nsmp, exp_var2_season_clim,exp_var2_var,g_nsmp, iflag, False)
		prob3 = ttest(ctrl_var3_season_clim,ctrl_var3_var,g_nsmp, exp_var3_season_clim,exp_var3_var,g_nsmp, iflag, False)
		
		diff_var1=mask(diff_var1, (prob1 .lt. sigr) .or. (prob2 .lt. sigr), True)
		diff_var3_sig=mask(diff_var3, prob3 .lt. sigr, True)

	end do

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/1/),graphic)
  plot_sig = new((/1/),graphic)
;  plot_sh = new((/2/),graphic)
  plot_V = new((/1/),graphic)

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
  res@lbLabelStride = 4 

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
     
  res@gsnLeftString = ""
  res@gsnCenterString = g_fig_title
  res@gsnRightString = ""
  plot_sh(0) = gsn_csm_contour_map_ce(wks,diff_var3,res) ; create a default plot
;do i = 0,3
;    res@gsnLeftString = g_fig_rank(i)
;    res@gsnCenterString = g_fig_title(i)
;    res@gsnRightString = ""
;    plot(i) = gsn_csm_contour_map_ce(wks,dvar1_dt(i,:,:),res) ; create a default plot
;end do


;************************************************
; create points for box in SCS and WNP
;************************************************
ypts = (/ 15.0,  15.0, -0.0,  -0.0, 15.0/)
xpts = (/110.0, 155.0,155.0, 110.0,110.0/)
;************************************************
; add the box
;************************************************
resp                  = True                      ; polyline mods desired
resp@gsLineColor      = "Black"                     ; color of lines
resp@gsLineThicknessF = 6.0                       ; thickness of lines
;resp@gsLineLabelString= "test"                    ; adds a line label string

; create array of dummy graphic variables. This is required, b/c each line
; must be associated with a unique dummy variable.

dum = new(4,graphic)  

; draw each line separately. Each line must contain two points.
do i = 0 , 3
    dum(i)=gsn_add_polyline(wks,plot_sh,xpts(i:i+1),ypts(i:i+1),resp)      
end do 
;************************************************
; create points for box in southern China
;************************************************

resp@gsLineDashPattern      = 1                     ; color of lines
ypts = (/ 35.0,  35.0, 20.0,  20.0, 35.0/)
xpts = (/110.0, 135.0,135.0, 110.0,110.0/)

dum2 = new(4,graphic)  

; draw each line separately. Each line must contain two points.
do i = 0 , 3
    dum2(i)=gsn_add_polyline(wks,plot_sh,xpts(i:i+1),ypts(i:i+1),resp)      
end do 

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
  res4@cnFillScaleF = 2.
  res4@cnMonoFillColor = True
  res4@cnFillColor  =  "red"
  res4@cnFillDotSizeF = 0.005
 
  res4@lbLabelBarOn = False;True   ; turn off the label bar
 
;  res4@cnLevelSelectionMode="ExplicitLevels"
;  res4@cnLevels = (/3000,1000/)
  res4@gsnLeftString      = " "
  res4@gsnRightString      = " "

;-----------------------------------------------------------------------------
   ;-------Set for the vector plot------
    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    vcres@vcRefAnnoOrthogonalPosF = -1             ; move ref vector up
    vcres@vcRefMagnitudeF         = 2.0             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.025
    vcres@vcRefAnnoString1  = "2 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.018
    vcres@vcLineArrowThicknessF     = 3.0    ;thickness of vector

   vcres@vcLineArrowHeadMinSizeF   = 0.010
   vcres@vcLineArrowHeadMaxSizeF   = 0.010
;--------------------------------------

  plot_sig(0) = gsn_csm_contour_map_ce(wks,diff_var3_sig,res4) ; create a default plot
  plot_V(0) = gsn_csm_vector(wks,diff_var1,diff_var2,vcres)

  ;plot_V(1) = gsn_csm_vector(wks,cp_diff_var1,cp_diff_var2,vcres)

;  plot_sh(0) = gsn_csm_contour(wks,diff_var3_sig,res4)

  ;plot_sh(1) = gsn_csm_contour(wks,cp_diff_var3_sig,res4)

   overlay(plot_sh(0),plot_sig(0))
   overlay(plot_sh(0),plot_V(0))
  ;overlay(plot(1),plot_sh(1))

  ;overlay(plot(0),plot_V(0))
  ;overlay(plot(1),plot_V(1))

 
  gsn_panel(wks,plot_sh,(/1,1/),False)

  draw(plot_sh)
  frame(wks)
end 
