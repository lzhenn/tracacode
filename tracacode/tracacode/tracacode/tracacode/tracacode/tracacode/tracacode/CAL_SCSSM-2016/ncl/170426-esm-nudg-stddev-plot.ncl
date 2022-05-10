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
    g_var_name="U"
    g_data_ctrl_path ="/users/yangsong3/L_Zealot/F/DATA_CLIM-Trans-2015/pro"
    g_data_nudg_path ="/users/yangsong3/L_Zealot/F/DATA_Nudging/pro"
    g_font = 0.02
    g_level=200
  
    g_latN=40
    g_latS=0
    g_lonE=120
    g_lonW=45
    
    g_day_strt=75
    g_day_end=120
    ;Prepare the variables
    ctrl_in_files1 = systemfunc("ls "+g_data_ctrl_path+"/CLIM-Trans-2015.cam.h1.ESMc_add_00*."+g_var_name+".*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in1     = addfiles (ctrl_in_files1, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in1, "join")
    var1  =ctrl_in1[:]->$g_var_name(0)$(:,g_day_strt:g_day_end,{g_level},:,:)
    std_var1=dim_stddev_n_Wrap(var1,1)
    std_var1:=dim_avg_n_Wrap(std_var1,0)


    ;Prepare the variables
    nudg_in_files1 = systemfunc("ls "+g_data_nudg_path+"/*ESMn2*."+g_var_name+".*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    nudg_in1     = addfiles (nudg_in_files1, "r")   ; note the "s" of addfile
    ListSetType (nudg_in1, "join")
    nudg_var1  =nudg_in1[:]->$g_var_name(0)$(:,g_day_strt:g_day_end,{g_level},:,:)
    std_nudg_var1=dim_stddev_n_Wrap(nudg_var1,1)
    std_nudg_var1:=dim_avg_n_Wrap(std_nudg_var1,0)

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/2/),graphic)
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
 res@cnMinLevelValF        = -10         ; set min contour level
 res@cnMaxLevelValF        = 10        ; set max contour level
 res@cnLevelSpacingF       = 1         ; set contour interval

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


  res@lbLabelBarOn = False   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  res@lbLabelStride = 2 


  res@mpFillOn   = False     ; turn off gray continents
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
     
  res@gsnLeftString = ""
  res@gsnRightString = ""
       
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
  vcres@vcMinDistanceF          = 0.03
  vcres@vcRefAnnoString1  = "5 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.02
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.01
  vcres@vcLineArrowHeadMaxSizeF   = 0.01
 

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
  res3@cnLevels = (/900./)
  res3@cnLineColor      = "Black"
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "


  res4=res3
  res4@cnLineColor="Grey"

;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
; resP@gsnPanelMainString = "A plot with a common label bar"
                                                 ; use this for NCL 6.3.0 and earlier
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.015               ; make labels smaller 

  g_fig_name="../fig/nudging/esm-nudg-std-diff-200U"
  wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
  gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
  res@gsnLeftString="U stddev "+g_level+"hPa Day75-120"

  plot_sh(0)= gsn_csm_contour_map(wks,std_var1,res) ; create a default plot
  plot_sh(1)= gsn_csm_contour_map(wks,std_nudg_var1,res) ; create a default plot
  ;plot_cn_max = gsn_csm_contour(wks,var1_clim_max({g_level},:,:),res3)
  ;plot_V = gsn_csm_vector(wks,diff_var1_clim({g_level},:,:),diff_var2_clim({g_level},:,:),vcres) 
  xyres                 = True         ; xy plot mods desired
  xyres@vpHeightF        = .20          ; set width of second plot
  xyres@vpWidthF        = .15          ; set width of second plot
  xyres@tmXBMinorOn     = False        ; no minor tickmarks

  xyres@gsnDraw         = False        ; don't draw yet
  xyres@gsnFrame        = False        ; don't advance frame yet

  xyres@tmXBLabelFontHeightF=g_font        ; change font height
  xyres@gsnCenterString=""
  xyres@trYMinF         = g_latS 
  xyres@trYMaxF         = g_latN
  xyres@trXMinF         = -20
  xyres@trXMaxF         = 40
  xyres@xyLineThicknesses    = 3.0      ; line thicknesses
 
  xyres@tmXBOn              = True
  xyres@tmXBLabelsOn=True
  xyres@tmXBMode="Explicit"
  xyres@tmYRLabelsOn=True
  xyres@tmXBValues=ispan(-20,40,20)
  xyres@tmXBLabels=ispan(-20,40,20)
  
  xyres@tiXAxisString="U wind (m/s)"
  xyres@tiXAxisFontHeightF=g_font
  ;var1_clim_lat(2,:)=0
  ;plotxy = gsn_csm_xy(wks, var1_clim_lat(1:2,:), var1_clim_lat&lat, xyres)
  ;overlay(plot_sh,plot_cn_max)
  ;newplot = gsn_attach_plots(plot_sh,(/plotxy/),res,xyres)
 ;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
; resP@gsnPanelMainString = "A plot with a common label bar"
                                                 ; use this for NCL V6.3.0 and earlier
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.015               ; make labels smaller 
 gsn_panel(wks,plot_sh,(/1,2/),resP) 
end
