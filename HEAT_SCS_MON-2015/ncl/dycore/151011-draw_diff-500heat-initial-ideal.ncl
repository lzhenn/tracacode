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
;   2015-10-05  Change to fit dycore test
;   2015-10-05  Change to fit dycore test CONHEAT
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
    g_data_path = "../../data/model/pre/Ideal_phy/"
    g_ctrl_case = "ideal_data"
    g_sen_cases = (/"heat_data_0.25folding"/)

    g_season      =   "MAM"
    g_latS=-5.
    g_latN=45.
    g_lonW=90.
    g_lonE=160.
    ;g_latS=-90.
    ;g_latN=90.
    ;g_lonE=360.
    ;g_lonW=0.
; create an array of desired pressure levels:

    g_year_start   =   0 ;Rank from 0
    g_year_end     =   49;Rank from 0 
    g_nsmp        =   g_year_end - g_year_start + 1;number of samples for significance test
    g_idx_start = g_year_start*12
    g_idx_end = (g_year_end+1)*12-1

    g_run_period  =   "0250-0299"
        
    g_font = 0.035

    g_var         = "Z3"
    g_lev         = 12 

    g_fig_name    =   "../../fig/model/diff_CONHEAT_ideal_0.25folding_day0"
    ;g_fig_rank    =   "B2000_F19G16_CAM4_CTRL"
    g_fig_rank    =   ""
    ;g_fig_title   =   g_season+" HEAT_CP-CON_CP"
    g_fig_title   =    "Idealized Simulation"


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls "+g_data_path+g_ctrl_case+"/*")
	setfileoption("nc","suppressclose",False) ; close too many files
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile


	ctrl_var4  = ctrl_in[:]->CONHEAT(:,18,:,:)			; p for unify the var name

	do i = 0,dimsizes(g_sen_cases)-1
;*************************For F_Compset Heat***********************************

    ; ==============================================================
    ; Mission 1. Open the file: Read only the user specified period
    ; ==============================================================
	    all_files = systemfunc ("ls "+g_data_path+g_sen_cases(i)+"/*")
	    setfileoption("nc","suppressclose",False) ; close too many files
	    exp_in      = addfiles (all_files, "r")   ; note the "s" of addfile


        exp_var4  = exp_in[:]->CONHEAT(:,18,:,:)			; p for unify the var name

        diff_var4 = exp_var4

        diff_var4 = (exp_var4-ctrl_var4)
        
        diff_var4 = diff_var4*86400
   	end do

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file
  plot_cn = new((/1/),graphic)
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")

 do n = 0,0
    ;-----------------------------------------------------------------------------
      res                  = True       ; use plot options

      res@cnLinesOn            = True              ; turn off contour lines
      res@cnLineLabelsOn       = False              ; turn off contour line labels



      res@gsnFrame         = False
      res@gsnDraw  = False
      
      res@gsnStringFontHeightF = g_font

      res@gsnMaximize      = True       ; fill up the page
      res@gsnAddCyclic   = True;False
      res@gsnPaperOrientation = "portrait"
      res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero

      res@mpFillOn   = True     ; turn off gray continents
      res@mpGeophysicalLineThicknessF = 2
      res@mpGeophysicalLineColor      = "black";"white" 
      ;res@mpFillDrawOrder="PostDraw"
      res@mpCenterLonF = 180.
      res@mpMaxLatF  = g_latN
      res@mpMinLatF  = g_latS
      res@mpMaxLonF  = g_lonE
      res@mpMinLonF  = g_lonW

    ;  res@mpShapeMode = "FreeAspect" 
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
         
      res@gsnLeftString = "Day: 0"
      res@gsnRightString = g_fig_title
      res@gsnCenterString = ""
      
    ;for tp masking
      res@cnLineThicknessF = 2 
      res@cnInfoLabelOn = False
     
     
      res@cnLevelSelectionMode="ExplicitLevels"
      ;res3@cnLevels = (/0.002,0.006,0.008,0.01/)
      res@cnLineColor      = "Red"



      ;res3@cnLevels = (/-0.004,-0.008,-0.012,-0.016,-0.02/)
      res@cnLevels = (/0.5,1.0,1.5,2.0,2.5,3.0/)
      ;res3@cnLineColor      = "Blue"
      res@cnLineDashPattern      = 0 
      
      plot_cn = gsn_csm_contour_map_ce(wks,diff_var4(0,:,:),res) ; create a default plot

  end do

  gsn_panel(wks,plot_cn(0),(/1,1/),False)
  
  draw(plot_cn)
  frame(wks)
end 
