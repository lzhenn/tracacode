;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = (/"U","V"/)
    
    
    ctrl_dir="/users/yangsong3/L_Zealot/F/Ideal_phy/ctrl"    
   
    sen_dir="/users/yangsong3/L_Zealot/F/Ideal_phy/exe"    


    g_font = 0.02
  
    g_latN=30
    g_latS=-30
    g_lonE=270
    g_lonW=60
    g_season="MAM"
    g_skip_year=3


    g_start=31
    g_end=179
    ;Prepare the variables
    all_files = systemfunc ("ls "+ctrl_dir+"/*");
    ctrl_in     = addfiles (all_files, "r")   ; note the "s" of addfile
    var1  =ctrl_in[:]->U(g_start:g_end,27,:,:)
    var2  =ctrl_in[:]->V(g_start:g_end,27,:,:)
    var3  =ctrl_in[:]->OMEGA(g_start:g_end,18,:,:)
    var4  =ctrl_in[:]->PSL(g_start:g_end,:,:)
    printVarSummary(var1)

    all_files := systemfunc ("ls "+sen_dir+"/*cam.h*");
    sen_in     = addfiles (all_files, "r")   ; note the "s" of addfile
    sen_var1  =sen_in[:]->U(g_start:g_end,27,:,:)
    sen_var2  =sen_in[:]->V(g_start:g_end,27,:,:)
    sen_var3  =sen_in[:]->OMEGA(g_start:g_end,18,:,:)
    sen_var4  =sen_in[:]->PSL(g_start:g_end,:,:)
    
    var1_clim=dim_avg_n_Wrap(var1,0)
    var2_clim=dim_avg_n_Wrap(var2,0)
    var3_clim=dim_avg_n_Wrap(var3,0)
    var4_clim=dim_avg_n_Wrap(var4,0)

    sen_var1_clim=dim_avg_n_Wrap(sen_var1,0)
    sen_var2_clim=dim_avg_n_Wrap(sen_var2,0)
    sen_var3_clim=dim_avg_n_Wrap(sen_var3,0)
    sen_var4_clim=dim_avg_n_Wrap(sen_var4,0)




    diff_var1=var1_clim
    diff_var2=var2_clim
    diff_var3=var3_clim
    diff_var4=var4_clim
    
    diff_var1=sen_var1_clim-var1_clim
    diff_var2=sen_var2_clim-var2_clim
    diff_var3=sen_var3_clim-var3_clim
    diff_var4=sen_var4_clim-var4_clim

    ws = wind_speed(diff_var1, diff_var2)
    diff_var1=where(ws .gt. 0.5, diff_var1, diff_var1@_FillValue)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps","../../../fig/paper/R1/Fig4x-label")  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

;  plot_sh = new((/g_day_comp_len/),graphic)
;  plot_V = new((/g_day_comp_len/),graphic)
;  plot_cn_max = new((/g_day_comp_len/),graphic)
;  plot_cn_max_pre = new((/g_day_comp_len/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)
  gsn_define_colormap(wks,"ViBlGrWhYeOrRe") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -180       ; set min contour level
 res@cnMaxLevelValF        = 180         ; set max contour level
 res@cnLevelSpacingF       = 15          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
;  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font
  res@mpCenterLonF=180
  ;res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = False
  res@gsnPaperOrientation = "portrait"
  ;res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True  ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  res@lbLabelStride = 2 


  res@mpFillOn   = False    ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
  res@mpMaxLatF  =g_latN
  res@mpMinLatF  =g_latS
  res@mpMaxLonF  =g_lonE
  res@mpMinLonF  =g_lonW

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
;  res@tmXBMode="Explicit"
;  res@tmXBValues=ispan(g_lonW,g_lonE,20)
;  res@tmXBLabels=ispan(g_lonW,g_lonE,20)+"E"
  res@tmYLTickSpacingF =  10
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     
  res@gsnLeftString = ""
  res@gsnRightString = ""
      
      res3                  = True       ; use plot options
      res3@cnFillOn         = False;True       ; Fill contours
      res3@cnLinesOn        = True      ; turn off contour lines
    ;for tp masking
      res3@gsnFrame         = False
      res3@gsnDraw  = False
      res3@cnLineLabelsOn   = False      ; turn off contour line labels
      res3@cnLineThicknessF = 3 
      res3@cnInfoLabelOn = False
     
     
      res3@cnLevelSelectionMode="ExplicitLevels"
      res3@cnLevels = (/0.005, 0.01, 0.02,0.04,0.06/)
      res3@cnLineColor      = "Red"
      res3@gsnLeftString      = " "
      res3@gsnRightString      = " "


      plot_cn_pos = gsn_csm_contour(wks,diff_var3,res3)

      res3@cnLevels = - res3@cnLevels 
      res3@cnLineColor      = "Blue"
      res3@cnLineDashPattern      = 1
      
      plot_cn_neg = gsn_csm_contour(wks,diff_var3,res3)



  vcres = True
  vcres@gsnDraw          = False           ; don't draw
  vcres@gsnFrame         = False           ; don't advance frame
  vcres@gsnRightString   = " "             ; turn off right string
  vcres@gsnLeftString    = " "             ; turn off left string
  vcres@gsnCenterString    = " "
 
  vcres@vcRefAnnoOn      = True
  vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  vcres@vcRefMagnitudeF         = 2.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.025
  vcres@vcRefAnnoString1  = "2 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.012
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.008
  vcres@vcLineArrowHeadMaxSizeF   = 0.008
 

  g_fig_name="../../fig/paper/Fig3a-1000uv-pr-had-"+g_season
  res@gsnLeftString="(a) Day 31-180 SLP, Omega, and Surf Wind"
  print( wgt_areaave_Wrap(diff_var1({-5:5},{150:190}),1.0,1.0,0))
  plot_sh= gsn_csm_contour_map(wks,diff_var4,res) ; create a default plot
  ;plot_cn_max = gsn_csm_contour(wks,var1_clim_max({g_level},:,:),res3)
  plot_V = gsn_csm_vector(wks,diff_var1,diff_var2,vcres) 
  ;overlay(plot_sh,plot_cn)
  overlay(plot_sh,plot_cn_pos)
  overlay(plot_sh,plot_cn_neg)
  overlay(plot_sh,plot_V)
  draw(plot_sh)
  frame(wks)

end
