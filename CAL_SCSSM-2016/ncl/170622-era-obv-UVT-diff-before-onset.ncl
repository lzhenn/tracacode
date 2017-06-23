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
    ;g_var_name = (/"U","V","T"/)
    g_var_name = (/"uwnd","vwnd","air"/)
    g_font = 0.02
  
    g_latN=50
    g_latS=-5
    g_lonE=120
    g_lonW=30
    

    g_level=500

     ;BOB All
    ;g_comp="all"
    ;g_special_year=ispan(g_strt_yr,g_lst_yr,1)
    g_day_rank=(/125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134/)-1
    n_years=dimsizes(g_day_rank) 
    ;BOB Early
    g_comp="early"
    g_special_year=(/1984, 1990, 1999, 2000, 2006, 2009/)-1979
    g_onset_ctrl=(/108, 105, 93, 100, 107, 99/)-1
    
    ;BOB Late
    ;g_comp2="late"
    ;g_special_year2=(/1980, 1981, 1982, 1983, 1985, 1992, 1993, 1997, 1998, 2010/)-1979
    ;g_day_rank2=(/136, 133, 134, 143, 136, 132, 134, 133, 132, 134/)-1-g_day_strt2


    g_ctrl_datapath="/Users/zhenningli/data/CAL_SCSSM-2016/ERA-clim/"
    ;n_years=dimsizes(g_special_year)

    n_vars=dimsizes(g_var_name)
    
    var_ctrl_list = NewList("fifo")       ; Create a new list.
    var_ctrl_onset_list = NewList("fifo")       ; Create a new list.
    do ii=0, n_vars-1
        ctrl_in1     = addfile(g_ctrl_datapath+g_var_name(ii)+".mean.nc", "r") 
        ListPush(var_ctrl_list,ctrl_in1->$g_var_name(ii)$(:,{g_level},:,:))  ; Push variable onto list.
       ; nudg_in1     = addfile(g_nudg_datapath+g_nudg_name+".cam.h1.ESM.clim."+g_var_name(ii)+".0101-0701.nc", "r") 
       ; ListPush(var_nudg_list,nudg_in1->$g_var_name(ii)$(:,{g_level},:,:))  ; Push variable onto list.
        ctrl_in2     = addfile(g_ctrl_datapath+"interim.41days."+g_var_name(ii)+".nc", "r") 
        ListPush(var_ctrl_onset_list,ctrl_in2->$g_var_name(ii)$(:,:,{g_level},:,:))  ; Push variable onto list.
       ; nudg_in2     = addfile(g_nudg_datapath+g_nudg_name+".cam.h1.ESM.41days."+g_var_name(ii)+".0101-0701.nc", "r") 
       ; ListPush(var_nudg_onset_list,nudg_in2->$g_var_name(ii)$(:,:,{g_level},:,:))  ; Push variable onto list.
    end do
    do ii=0, dimsizes(g_special_year)-1
        do jj=0, n_vars-1
            var_ctrl_onset_list[jj](g_special_year(ii),:,:,:)=var_ctrl_onset_list[jj](g_special_year(ii),:,:,:)-var_ctrl_list[jj](g_onset_ctrl(ii)-20:g_onset_ctrl(ii)+20,:,:)
         ;   var_ctrl_onset_list[jj](ii,:,:,:)=var_ctrl_onset_list[jj](ii,:,:,:)-var_ctrl_list[jj](g_day_rank(ii)-20:g_day_rank(ii)+20,:,:)
        end do
    end do
    var1=var_ctrl_onset_list[2](0:dimsizes(g_special_year)-1,:,:,:)
    var2=var_ctrl_onset_list[1](0:dimsizes(g_special_year)-1,:,:,:)
    var3=var_ctrl_onset_list[0](0:dimsizes(g_special_year)-1,:,:,:)
    do ii=0, dimsizes(g_special_year)-1
        var1(ii,:,:,:)=var_ctrl_onset_list[2](g_special_year(ii),:,:,:)
        var2(ii,:,:,:)=var_ctrl_onset_list[1](g_special_year(ii),:,:,:)
        var3(ii,:,:,:)=var_ctrl_onset_list[0](g_special_year(ii),:,:,:)
    end do
    diff_var1=dim_avg_n_Wrap(var1,0)
    diff_var2=dim_avg_n_Wrap(var2,0)
    diff_var3=dim_avg_n_Wrap(var3,0)
    diff_var1:=dim_avg_n_Wrap(diff_var1(7:20,:,:),0)
    diff_var2:=dim_avg_n_Wrap(diff_var2(7:20,:,:),0)
    diff_var3:=dim_avg_n_Wrap(diff_var3(7:20,:,:),0)
    
    
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file
    n_smp=1
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
  vcres@vcMinDistanceF          = 0.025
  vcres@vcRefAnnoString1  = "3 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.02
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.01
  vcres@vcLineArrowHeadMaxSizeF   = 0.01
 



  g_fig_name="../fig/obv/diff-UVT-era-obv-before-onset-"+g_level
  

  wks_type="png"
  wks_type@wkWidth = 1200
  wks_type@wkHeight = 1200 
  wks = gsn_open_wks(wks_type,g_fig_name)  ; open a ps file
  gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
  do ii = 0, 0
     jj=18-3*(ii+2)
     res@gsnLeftString="UVT Diff"+g_level+"hPa Day -"+jj
     plot_sh(ii)= gsn_csm_contour_map(wks,diff_var3,res) ; create a default plot
    ;plot_cn_max = gsn_csm_contour(wks,var1_diff_max({g_level},:,:),res3)
     plot_V(ii) = gsn_csm_vector(wks,diff_var1,diff_var2,vcres) 
     overlay(plot_sh(ii), plot_V(ii))
  end do
  gsn_panel(wks,plot_sh,(/1,1/),False)
end
