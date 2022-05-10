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
load "$NCL_SELFLIB/file_io.ncl"

begin


;======================================================
;Variables List:
;	t2m--------------Air Temperature (K, TLL)
;======================================================

;global variables
    ;Define parameters
    g_var_name = "r"
    g_data_path1 ="/users/yangsong3/L_Zealot/F/aquac4/pro/clim/aquac4.cam.h1.ESM.clim.U.nc"
    g_data_path2 ="/users/yangsong3/L_Zealot/F/aquac4/pro/clim/aquac4.cam.h1.ESM.clim.V.nc"
    g_data_path3 ="/users/yangsong3/L_Zealot/F/aquac4/pro/clim/aquac4.cam.h1.ESM.clim.OMEGA.nc"
 ;    g_data_path ="/home/yangsong3/L_Zealot/data-mirror/obv/SST/HadISST/HadISST_sst.nc"

    g_font = 0.02
    g_latS=-90.
    g_latN=90.
    g_lonW=0.
    g_lonE=360.
    ; create an array of desired pressure levels:
    g_fig_name = "../fig/aqua-profile-uv-omega"

    ctrl_in1     = addfile (g_data_path1, "r")   ; note the "s" of addfile
    var1 = ctrl_in1->U(:,7:,:,:)
    ctrl_in2     = addfile (g_data_path2, "r")   ; note the "s" of addfile
    var2 = ctrl_in2->V(:,7:,:,:)
    clim_var1=dim_avg_n_Wrap(var1,0)
    clim_var2=dim_avg_n_Wrap(var2,0)
    
    ctrl_in3     = addfile (g_data_path3, "r")   ; note the "s" of addfile
    var3 = ctrl_in3->OMEGA(:,7:,:,:)
    clim_var3=dim_avg_n_Wrap(var3,0)

    pro_var1=dim_avg_n_Wrap(clim_var1,2)
    pro_var2=dim_avg_n_Wrap(clim_var2,2)
    pro_var3=dim_avg_n_Wrap(clim_var3,2)

    xlb_value=ispan(-90,90,15)
    xlb_str=sprinti(" %2i", xlb_value)

    print(xlb_str)

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

;  gsn_define_colormap(wks,"precip2_17lev")

;***********************************************
; Create a different resource list for each of the 5 plots
;***********************************************
  u_res      = True
  vw_res      = True
;***********************************************
; Here are the resources that u_res, temp_res, and vw_res share.
;***********************************************
  u_res@trYReverse   = True     ; Reverse the Y values.
  u_res@gsnDraw      = False    ; Don't draw individual plot.
  u_res@gsnFrame     = False    ; Don't advance frame.
  u_res@vpXF         = 0.15     ; x location
  u_res@vpWidthF     = 0.8      ; width
  u_res@vpHeightF    = 0.40     ; height

  u_res@gsnStringFontHeightF = g_font 
  vw_res              = u_res
  u_res@lbLabelFontHeightF  = g_font              ; make labels smaller
;***********************************************
; Relative humidity only resources
;***********************************************
  u_res@cnFillOn          = True               ; turns on color fill
  ;u_res@cnFillPalette     = read_colormap_file("")             ; set color map
  u_res@cnLinesOn   = False
  u_res@cnLineLabelsOn    = False               ; no contour labels
  u_res@cnLineLabelPerimOn = False
  u_res@cnFillMode           = "CellFill" ; Raster Mode
  u_res@tiYAxisString     = "Pressure (hPa)"    ; Y axes label.
  u_res@tiYAxisFontHeightF = g_font
  u_res@lbLabelBarOn = True   ; turn off the label bar
  u_res@lbOrientation          = "vertical"
  u_res@gsnRightString = "" 
  u_res@gsnMaximize          = True
  u_res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
  u_res@cnLevels = (/-5,-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4,5/) 
  u_res@gsnLeftString = "Aqua Planet Clim V, Omega Profile"
; y-left axis changes
  u_res@tmYLMode       = "Explicit" ; Define own tick mark labels.
  u_res@tmYLValues     = (/990, 900,  800, 700, 600, 500, 400, 300, 200, 100/)     ; location of explicit labels
  u_res@tmYLLabels     =(/1000,900,  800, 700, 600, 500, 400, 300, 200, 100/) 
  u_res@tmYLMajorLengthF = 0.0
  u_res@tmYLMinorOn    = False            ; No Y-left minor tick marks.

; x-bottom axis changes
  u_res@tmXBMode       = "Explicit" ; Define own tick mark labels.
  u_res@tmXBValues=xlb_value
  u_res@tmXBLabels=xlb_str
  u_res@tmXBMajorLengthF = 0.0
  u_res@tmXBLabelFontHeightF = g_font
  u_res@tmYLLabelFontHeightF = g_font

  u_res@tmXBMinorOn          = False          ; No minor tick marks.
;***********************************************
; wind barb only resources
;***********************************************
  vcres = True
  vcres@gsnDraw          = False           ; don't draw
  vcres@gsnFrame         = False           ; don't advance frame
  vcres@gsnRightString   = " "             ; turn off right string
  vcres@gsnLeftString    = " "             ; turn off left string
  vcres@gsnCenterString    = " "
 
  vcres@vcRefAnnoOn      = True
  vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  vcres@vcRefMagnitudeF         = 5.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.025
  vcres@vcRefAnnoString1  = "5 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.012
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.008
  vcres@vcLineArrowHeadMaxSizeF   = 0.008
 
      
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
      res3@cnLevels = (/0.001,0.005,0.01,0.05,0.1,0.2/)
      ;res3@cnLevels = (/0.1,0.5,1,2,3,4,5/)
      res3@cnLineColor      = "Red"
      res3@gsnLeftString      = " "
      res3@gsnRightString      = " "


      plot_cn_pos = gsn_csm_contour(wks,pro_var3,res3)
      res3@cnLevels = -res3@cnLevels
      res3@cnLineColor      = "Blue"
      res3@cnLineDashPattern      = 1
      
      plot_cn_neg = gsn_csm_contour(wks,pro_var3,res3)



  ufill    = gsn_csm_contour(wks,pro_var2,u_res)
  vwbarb = gsn_csm_vector(wks,  pro_var2, pro_var3, vcres)


  overlay(ufill,plot_cn_pos)
  overlay(ufill,plot_cn_neg)
;  overlay(ufill,vwbarb)
  draw(ufill)
  frame(wks)


end

