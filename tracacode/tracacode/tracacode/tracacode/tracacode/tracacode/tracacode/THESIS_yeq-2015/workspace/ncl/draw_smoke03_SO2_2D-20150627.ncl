;***********************************************
; Draw UV 10m from wrfout_01
;
; jobs:
;   1.Read wrfout03 U10 V10 var
;   2.Display the Result
;                       L_Zealot
;                       2015-06-15
; 2015-06-15    Created;
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"
begin
; ==============================================================
; Mission1.    Read UV10
; ==============================================================

	;all_files = systemfunc ("ls ../data/*h0.000[3-9]*.nc ../data/*h0.001*.nc")
	
	;setfileoption("nc","SuppressClose",False) ; close too many files

	g_font =0.035
	ctrl_in      = addfile("../data/smokeout_d03/egts.2012030100_3.ncf","r")
    var1     = ctrl_in->SO2                 ; znw(bottom_top_stag)
    
    ctrl_in2      = addfile("../data/smokeout_d03/egts.2012030100_3_06.ncf","r")
    var2     = ctrl_in2->SO2                 ; znw(bottom_top_stag)

;**********************************************************************************************
;MISSION.2		Plot Clim monthly mean to check the result
;**********************************************************************************************
    var1_ver_sum = dim_sum_n_Wrap(var1,1)
    var1_t_avg = dim_avg_n_Wrap(var1_ver_sum,0)
    var2_ver_sum = dim_sum_n_Wrap(var2,1)
    var2_t_avg = dim_avg_n_Wrap(var2_ver_sum,0)
    diff_var = var1_t_avg
    diff_var = diff_var - var2_t_avg 
;**********************************************************************************************
;MISSION.3		Plot Clim monthly mean to check the result
;**********************************************************************************************

	
	wks = gsn_open_wks("eps","../fig/smoke03_t01")       ; open file to plot 
;-----------------------------------------------------------------------------

plot = new((/1/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")




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
; res@cnMinLevelValF        = -1.0          ; set min contour level
; res@cnMaxLevelValF        = 1.0          ; set max contour level
; res@cnLevelSpacingF       = 0.02          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnLeftString = "(c)"
  res@gsnCenterString = "NO"
  res@gsnRightString = ""
  res@gsnStringFontHeightF = g_font
  ;res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  ;res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1



  plotV = gsn_csm_contour(wks,diff_var(:85,:),res) ; dim1 = 0 for lvl = 0
 
 draw(plotV)
  frame(wks)

end
