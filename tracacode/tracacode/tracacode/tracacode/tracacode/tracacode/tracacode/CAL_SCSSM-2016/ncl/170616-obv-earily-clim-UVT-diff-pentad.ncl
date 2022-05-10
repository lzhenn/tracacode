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
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = (/"uwnd","vwnd","air"/)
    g_font = 0.02
  
    g_latN=50
    g_latS=-5
    g_lonE=120
    g_lonW=30
    
    g_day_strt=76-1
    g_day_end=120-1

    g_level=850

    ;BOB Early
    g_special_year=(/1984, 1990, 1999, 2000, 2006, 2009/)
    g_day_rank=(/108, 105, 93, 100, 107, 99/)-1
  
    g_clim_datapath="/home/yangsong3/data/observation/ERA-interim/pressure/daily-clim/"
    g_datapath="/home/yangsong3/data/observation/ERA-interim/pressure/"
    
    n_vars=dimsizes(g_var_name)
    
    var_clim_list = NewList("fifo")       ; Create a new list.
    do ii=0, n_vars-1
        ctrl_in1     = addfile(g_clim_datapath+g_var_name(ii)+".mean.nc", "r") 
        ListPush(var_clim_list,ctrl_in1->$g_var_name(ii)$(g_day_strt:g_day_end,:,:,:))  ; Push variable onto list.
    end do
    lcount = ListCount(var_clim_list)   ; Get total list count

    n_early=dimsizes(g_special_year)
    
    ctrl_in1     = addfile(g_datapath+"u/"+g_var_name(0)+".interim."+g_special_year(0)+".nc", "r") 
    var1=ctrl_in1->$g_var_name(0)$(g_day_strt:g_day_end,:,:,:)
    ctrl_in1     = addfile(g_datapath+"v/"+g_var_name(1)+".interim."+g_special_year(0)+".nc", "r") 
    var2=ctrl_in1->$g_var_name(1)$(g_day_strt:g_day_end,:,:,:)
    ctrl_in1     = addfile(g_datapath+g_var_name(2)+"/"+g_var_name(2)+".interim."+g_special_year(0)+".nc", "r") 
    var3=ctrl_in1->$g_var_name(2)$(g_day_strt:g_day_end,:,:,:)

    do ii=1, n_early-1
        ctrl_in1     = addfile(g_datapath+"u/"+g_var_name(0)+".interim."+g_special_year(ii)+".nc", "r") 
        var1=var1+ctrl_in1->$g_var_name(0)$(g_day_strt:g_day_end,:,:,:)
        ctrl_in1     = addfile(g_datapath+"v/"+g_var_name(1)+".interim."+g_special_year(ii)+".nc", "r") 
        var2=var2+ctrl_in1->$g_var_name(1)$(g_day_strt:g_day_end,:,:,:)
        ctrl_in1     = addfile(g_datapath+g_var_name(2)+"/"+g_var_name(2)+".interim."+g_special_year(ii)+".nc", "r") 
        var3=var3+ctrl_in1->$g_var_name(2)$(g_day_strt:g_day_end,:,:,:)
    end do
    var1=var1/n_early
    var2=var2/n_early
    var3=var3/n_early

    diff_var1=var1
    diff_var2=var2
    diff_var3=var3
    
    diff_var1=var1-var_clim_list[2]
    diff_var2=var2-var_clim_list[1]
    diff_var3=var3-var_clim_list[0]
    
    n_smp = ((g_day_end-g_day_strt)+1)/5
    
    
    diff_var1=runave_n_Wrap(diff_var1,5,0,0)
    diff_var2=runave_n_Wrap(diff_var2,5,0,0)
    diff_var3=runave_n_Wrap(diff_var3,5,0,0)

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/n_smp/),graphic)
  plot_V = new((/n_smp/),graphic)
  plot_xy = new((/n_smp/),graphic)
  plot_xynew = new((/n_smp/),graphic)
  newplot = new((/n_smp/),graphic)
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
 res@cnMinLevelValF        = -1.0         ; set min contour level
 res@cnMaxLevelValF        = 1.0         ; set max contour level
 res@cnLevelSpacingF       = 0.2          ; set contour interval

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


  res@lbLabelBarOn = True   ; turn off the label bar
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
  vcres@vcRefMagnitudeF         = 3.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.03
  vcres@vcRefAnnoString1  = "3 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.02
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.01
  vcres@vcLineArrowHeadMaxSizeF   = 0.01
 



  g_fig_name="../fig/obv/diff-UVT-obv-early-pentad-"+g_level
  

  wks_type="png"
  wks_type@wkWidth = 1200
  wks_type@wkHeight = 1200 
  wks = gsn_open_wks(wks_type,g_fig_name)  ; open a ps file
  gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
  do ii = 0, n_smp-1
     res@gsnLeftString="UVT Diff"+g_level+"hPa Day"+(g_day_strt+5*ii+1)+"-"+(g_day_strt+5*(ii+1))
     plot_sh(ii)= gsn_csm_contour_map(wks,diff_var3(5*ii+2,{g_level},:,:),res) ; create a default plot
    ;plot_cn_max = gsn_csm_contour(wks,var1_clim_max({g_level},:,:),res3)
     plot_V(ii) = gsn_csm_vector(wks,diff_var1(5*ii+2,{g_level},:,:),diff_var2(5*ii+2,{g_level},:,:),vcres) 
     overlay(plot_sh(ii), plot_V(ii))
  end do
  gsn_panel(wks,plot_sh,(/3,3/),False)
end
