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
;   2015-07-11  Change to fit SST
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
    g_sen_cases = (/"HEAT_SCS_MAM-2015"/)

    g_season      =   "MAM"
    g_latS=-5.
    g_latN=35.
    g_lonW=100.
    g_lonE=200.
; create an array of desired pressure levels:

    g_year_start   =   0 ;Rank from 0
    g_year_end     =   49;Rank from 0 
    g_nsmp        =   g_year_end - g_year_start + 1;number of samples for significance test
    g_idx_start = g_year_start*12
    g_idx_end = (g_year_end+1)*12-1

    g_run_period  =   "0250-0299"
        
    g_font = 0.035
    g_var         = (/"UV","TS"/)

    g_fig_name    =   "../fig/model/diff_"+g_run_period+"_"+g_year_start+"-"+g_year_end+"_850UV_TS_HEAT-CON_"+g_season
    ;g_fig_rank    =   "B2000_F19G16_CAM4_CTRL"
    g_fig_rank    =   ""
    ;g_fig_title   =   g_season+" HEAT_CP-CON_CP"
    g_fig_title   =    g_season+" 850UV & SST Diff"


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
	ctrl_var3  = ctrl_in1->TS(g_idx_start:g_idx_end,:,:)			; p for unify the var name
   ;ctrl_var3  = ctrl_var3*86400*1000
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
        exp_var3  = exp_in1->TS(g_idx_start:g_idx_end,:,:)			; p for unify the var name
;        exp_var3  = exp_var3*86400*1000
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



;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    ;plot_C = new((/4/),graphic)     ;contour
    plot_V = new((/1/),graphic)     ;vector
    plot_S = new((/1/),graphic)     ;shading
    plot_sig = new((/1/),graphic)   ;sig in shading

    ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;gsn_define_colormap(wks,"precip4_diff_19lev")
    ;gsn_define_colormap(wks,"precip_diff_12lev")
    ; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


    ;-----------------------------------------------------------------------------
    res                  = True       ; use plot options

    res@cnFillOn             = True               ; turn on color for contours
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off contour line labels



    ;i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
    ;j = NhlNewColor(wks,1,0.,0.)
    ;  res@mpLandFillColor       = "gray"            ; set land to be gray

    ;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
    ;   res@cnLevels = ispan(0,60,10)
    ;  res@cnFillColors =(/-1,20,47,57,94,127,152/)

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        =  -0.5          ; set min contour level
    res@cnMaxLevelValF        =  0.5          ; set max contour level
    res@cnLevelSpacingF       =  0.1          ; set contour interval

    ;res@cnMinLevelValF        =  100000          ; set min contour level
    ;res@cnMaxLevelValF        =  102000          ; set max contour level
    ;res@cnLevelSpacingF       =  50          ; set contour interval
    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

    res@gsnSpreadColors      = True               ; use full color map
    ;res@gsnSpreadColorStart  = 2                ; start at color 17
    ;res@gsnSpreadColorEnd    = 14                ; end at color 200

    ;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
    res@gsnRightString = ""
    res@gsnCenterString = g_fig_title
    res@gsnLeftString = ""

   ; res@gsnMaximize      = True       ; fill up the page
   ; res@gsnAddCyclic   = False
   ; res@gsnPaperOrientation = "portrait"
   ; res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


    res@lbLabelBarOn = True   ; turn off the label bar
    ;res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller
    res@lbLabelStride = 3 
    res@lbBottomMarginF = -0.3
    res@pmLabelBarOrthogonalPosF = 0.5    ; move labelbar closer to plot
    ;res@lbLabelOffsetF = -1.0
    ;res@lbTitlelOffsetF = -1.0
    res@mpFillOn   = True;False     ; turn off gray continents
    res@mpGeophysicalLineThicknessF = 3 
    res@mpGeophysicalLineColor      = "black";"white" 
    ;res@mpFillDrawOrder="PostDraw"

    res@mpCenterLonF = 180.
    res@mpMaxLonF  = g_lonE
    res@mpMinLonF  = g_lonW

    res@mpMaxLatF  = g_latN
    res@mpMinLatF  = g_latS
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
    ; res@tmXBLabelFontAspectF = 1.6
    res@tmXBLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontAspectF = 1.3
    res@tmYLLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontQuality =
   	res@tmXBMajorThicknessF = 3.0
	res@tmYLMajorThicknessF = 3.0
	res@tmXBMinorThicknessF = 3.0
	res@tmYLMinorThicknessF = 3.0
	res@tmBorderThicknessF = 3.0
   ;-----------------------------------------------------------------------------
     
    
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    res@gsnStringFontHeightF = g_font
;-------Set for contour plot--------

    resC                  = True       ; use plot options
    resC@cnLinesOn            = True              ; turn off contour lines
    resC@cnLineLabelsOn       = True              ; turn off contour line labels
    resC@cnInfoLabelOn        = False             ; turn off info label
    resC@gsnFrame         = False
    resC@gsnDraw  = False
    ;resC@gsnMaximize      = True       ; fill up the page
;    resC@gsnAddCyclic   = True
    resC@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
   ; resC@cnLevelSelectionMode = "ExplicitLevels"  ; use explicit levels
   ; resC@cnLevels             = fspan(-1.5,2.0,8 )   ; set the contour levels
;-------Set for the vector plot------
    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    vcres@vcRefAnnoOrthogonalPosF = -1.8             ; move ref vector up
    vcres@vcRefMagnitudeF         = 3.0             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.025
    vcres@vcRefAnnoString1  = "3 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.015
    vcres@vcLineArrowThicknessF     = 4.0    ;thickness of vector

    ;----------Set res sig-----------
    res_sig                  = True       ; use plot options
    res_sig@cnFillOn         = True       ; Fill contours
    res_sig@cnLinesOn        = False;True      ; turn off contour lines
    res_sig@gsnFrame         = False
    res_sig@gsnDraw  = False
    ;res_sig@gsnAddCyclic   = False 
    res_sig@cnLineLabelsOn   = False      ; turn off contour line labels
    res_sig@cnLineThicknessF = 2
    ;res_sig@cnLineColor      = "black"
    res_sig@cnInfoLabelOn = False
    res_sig@cnMonoFillPattern    = True;False
    res_sig@cnFillPattern = 17
    res_sig@cnMonoFillScale = True
    res_sig@cnFillScaleF = 2.
    res_sig@cnMonoFillColor = True
    res_sig@cnFillColor  =  "red"
    res_sig@cnFillDotSizeF = 0.005

    res_sig@lbLabelBarOn = False;True   ; turn off the label bar

    ;  res_sig@cnLevelSelectionMode="ExplicitLevels"
    ;  res_sig@cnLevels = (/3000,1000/)
    res_sig@gsnLeftString      = " "
    res_sig@gsnRightString      = " "


  plot_V(0) = gsn_csm_vector(wks,diff_var1(:,:),diff_var2(:,:),vcres)

  plot_S(0) = gsn_csm_contour_map_ce(wks,diff_var3(:,:),res)
  
  plot_sig(0) = gsn_csm_contour(wks,diff_var3_sig,res_sig)

  overlay(plot_S(0),plot_sig(0))
  overlay(plot_S(0),plot_V(0))

 
  gsn_panel(wks,plot_S(0),(/1,1/),False)

  draw(plot_S)
  frame(wks)

	end do

end 
