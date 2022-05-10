;*************************************************************
;Aim: draw CAPE ltm monthly mean from ECMWF Datasets, contains
; Mar Apr May Jun Jul Aug
;Mission:
;   1. Read data from ECMWF data
;   2. Post-post process
;     2.1 Monthly Climatology 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-04-08
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
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
    g_data_path = "/home/yangsong3/data/observation/NCEP_DOE/monthly/q1/"

    g_latS=-30.
    g_latN=30.
    g_lonW=90.
    g_lonE=210.
; create an array of desired pressure levels:

        
    g_font = 0.02

    g_fig_name    =   "../fig/obv/1979-2015_Q1_MAM_ltm_mon_mean"
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)"/)
    g_fig_title   =   "1979-2014 "+(/"Mar","Apr","May","Jun","Jul","Aug"/)+" CAPE"


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	fn   = systemfunc("ls "+g_data_path+"*")
    ctrl_in      = addfiles(fn,"r")
	ctrl_var1  =ctrl_in[:]->q1			; p for unify the var name
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    cp=1004.0
    g=9.8
    
    ctrl_var1=month_to_season12(ctrl_var1) 
    ctrl_var1_ltmmon = clmMonTLLL(ctrl_var1)
    pver=ctrl_var1&lev
    pver=pver*100
    pver@units="Pa"
    dp=dpres_plevel(pver,100000,1,0)
    dp_cfm=conform_dims(dimsizes(ctrl_var1_ltmmon),dp,1)
    int_q1=ctrl_var1_ltmmon(:,0,:,:)
    int_q1=cp*dim_sum_n(dp_cfm*ctrl_var1_ltmmon,1)/g
    
    


; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/6/),graphic)
;  plot_tp = new((/2/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
 gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



 ; i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
 ; j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = 0          ; set min contour level
 res@cnMaxLevelValF        = 300          ; set max contour level
 res@cnLevelSpacingF       = 25          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


;  res@gsnFrame         = False
 ; res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

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
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
  res@gsnLeftString="(b)"   
  res@gsnCenterString="MAM Clim Vert Int Q1"   
  res@gsnRightString="W/m~S~2"   
  plot = gsn_csm_contour_map_ce(wks,int_q1(3,:,:),res) ; create a default plot
 

  ;draw(plot)
  ;frame(wks)
end 
