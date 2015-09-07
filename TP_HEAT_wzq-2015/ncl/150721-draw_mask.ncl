;*************************************************************
;Aim: draw PRECC annually ltm trend 
;Mission:
;   1. Read topo mask data
;   2. Draw the mask region
;                       Zhenning Li
;                       2015-07-21
;Last Edited:
;   2015-07-21  Create
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
    g_data_path = "../data/obv/TPmask.nc"

    ;g_latS=-30.
    ;g_latN=60.
    ;g_lonW=30.
    ;g_lonE=180.

    g_latS=-5.
    g_latN=45.
    g_lonW=90.
    g_lonE=160.
    g_season="MAM"
; create an array of desired pressure levels:

        
    g_font = 0.035

    g_fig_name    =   "../fig/TP_mask"
    
    g_fig_title     = " TP mask"
   ;g_fig_title1   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr trend"  ;for dsstdt
   ;g_fig_title2   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr' trend" ;for dsst'dt


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	var1  =ctrl_in1->tp			; p for unify the var name
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    printVarSummary(var1)

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_cn_pos = new((/1/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-------------------------------------------------------------------
  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 4 
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/0.9/)
  res3@cnLineColor      = "Red"
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "


  plot_cn_pos(0) = gsn_csm_contour_map_ce(wks,var1,res3)
  draw(plot_cn_pos)
  frame(wks)
end 
