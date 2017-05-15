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
    
    
    
    g_data_ctrl_path1 ="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/POST_SCRATCH-2017/ctrl/as-bob-test.cam.h0.U.1-15.nc"
    g_data_ctrl_path2 ="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/POST_SCRATCH-2017/ctrl/as-bob-test.cam.h0.V.1-15.nc"
    g_data_ctrl_path3 ="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/POST_SCRATCH-2017/ctrl/as-bob-test.cam.h0.PRECC.1-15.nc"
    g_data_ctrl_path4 ="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/POST_SCRATCH-2017/ctrl/as-bob-test.cam.h0.PRECL.1-15.nc"
   
    g_data_sen_path1 ="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/POST_SCRATCH-2017/sen/as-bob-test.cam.h0.U.1-15.nc"
    g_data_sen_path2 ="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/POST_SCRATCH-2017/sen/as-bob-test.cam.h0.V.1-15.nc"
    g_data_sen_path3 ="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/POST_SCRATCH-2017/sen/as-bob-test.cam.h0.PRECC.1-15.nc"
    g_data_sen_path4 ="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/POST_SCRATCH-2017/sen/as-bob-test.cam.h0.PRECL.1-15.nc"
 
    g_topo_path="../../PRE_PRO_SHARE/data/TOPO/USGS-gtopo30_1.9x2.5_remap_c050602.nc"

    g_font = 0.02
    g_level=850
  
    g_latN=50
    g_latS=-10
    g_lonE=150
    g_lonW=30
    g_season="JJA"
    g_skip_year=3

    ;Prepare the variables
    ctrl_in     = addfile (g_data_ctrl_path1, "r")   ; note the "s" of addfile
    var1  =ctrl_in->U
    ctrl_in     = addfile (g_data_ctrl_path2, "r")   ; note the "s" of addfile
    var2  =ctrl_in->V
    ctrl_in     = addfile (g_data_ctrl_path3, "r")   ; note the "s" of addfile
    var3  =ctrl_in->PRECC
    ctrl_in     = addfile (g_data_ctrl_path4, "r")   ; note the "s" of addfile
    var4 =ctrl_in->PRECL
    var3=(var3+var4)*1000*86400

    sen_in     = addfile (g_data_sen_path1, "r")   ; note the "s" of addfile
    sen_var1  =sen_in->U
    sen_in     = addfile (g_data_sen_path2, "r")   ; note the "s" of addfile
    sen_var2  =sen_in->V
    sen_in     = addfile (g_data_sen_path3, "r")   ; note the "s" of addfile
    sen_var3  =sen_in->PRECC
    sen_in     = addfile (g_data_sen_path4, "r")   ; note the "s" of addfile
    sen_var4 =sen_in->PRECL
    sen_var3=(sen_var3+sen_var4)*1000*86400

    topo_in= addfile(g_topo_path,"r")
    topo_var =topo_in->PHIS
    topo_var =topo_var/10

    
    var1_clim=dim_avg_n_Wrap(month_to_season(var1(g_skip_year*12:,:,:,:),g_season),0)
    var2_clim=dim_avg_n_Wrap(month_to_season(var2(g_skip_year*12:,:,:,:),g_season),0)
    var3_clim=dim_avg_n_Wrap(month_to_season(var3(g_skip_year*12:,:,:),g_season),0)

    sen_var1_clim=dim_avg_n_Wrap(month_to_season(sen_var1(g_skip_year*12:,:,:,:),g_season),0)
    sen_var2_clim=dim_avg_n_Wrap(month_to_season(sen_var2(g_skip_year*12:,:,:,:),g_season),0)
    sen_var3_clim=dim_avg_n_Wrap(month_to_season(sen_var3(g_skip_year*12:,:,:),g_season),0)

    diff_var1=var1_clim
    diff_var2=var2_clim
    diff_var3=var3_clim
    
    diff_var1=sen_var1_clim-var1_clim
    diff_var2=sen_var2_clim-var2_clim
    diff_var3=sen_var3_clim-var3_clim

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

;  plot_sh = new((/g_day_comp_len/),graphic)
;  plot_V = new((/g_day_comp_len/),graphic)
;  plot_cn_max = new((/g_day_comp_len/),graphic)
;  plot_cn_max_pre = new((/g_day_comp_len/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
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
 res@cnMinLevelValF        = -6.0        ; set min contour level
 res@cnMaxLevelValF        = 6.0         ; set max contour level
 res@cnLevelSpacingF       = 1.0          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
;  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

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
  res@tmXBMode="Explicit"
  res@tmXBValues=ispan(g_lonW,g_lonE,20)
  res@tmXBLabels=ispan(g_lonW,g_lonE,20)+"E"
  res@tmYLTickSpacingF = 10
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     
  res@gsnLeftString = "(b)"
  res@gsnRightString = ""

  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = False     ; turn off contour line labels
  res3@cnLineThicknessF = 3
  res3@cnLineColor      = "black"
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/1500/)
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " " 



  vcres = True
  vcres@gsnDraw          = False           ; don't draw
  vcres@gsnFrame         = False           ; don't advance frame
  vcres@gsnRightString   = " "             ; turn off right string
  vcres@gsnLeftString    = " "             ; turn off left string
  vcres@gsnCenterString    = " "
 
  vcres@vcRefAnnoOn      = True
  vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  vcres@vcRefMagnitudeF         = 3.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.03
  vcres@vcRefAnnoString1  = "3 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.02
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.01
  vcres@vcLineArrowHeadMaxSizeF   = 0.01
 

  g_fig_name="../fig/bob-as-850uv-pr"
  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
  gsn_define_colormap(wks,"precip_diff_12lev")
  res@gsnCenterString="UV850 & Pr Diff"

  plot_sh= gsn_csm_contour_map(wks,diff_var3,res) ; create a default plot
  plot_cn= gsn_csm_contour(wks,topo_var,res3) ; create a default plot
  ;plot_cn_max = gsn_csm_contour(wks,var1_clim_max({g_level},:,:),res3)
  plot_V = gsn_csm_vector(wks,diff_var1({g_level},:,:),diff_var2({g_level},:,:),vcres) 
  overlay(plot_sh,plot_cn)
  overlay(plot_sh,plot_V)
  draw(plot_sh)
  frame(wks)

end
