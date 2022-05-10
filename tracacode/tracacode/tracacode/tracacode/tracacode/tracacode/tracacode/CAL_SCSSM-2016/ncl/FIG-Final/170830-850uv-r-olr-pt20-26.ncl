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
load "$NCL_SELFLIB/data_parser.ncl"
begin


;======================================================
;Variables List:
;	var1--------------U (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_strt_yr=1979
    g_lst_yr=2013
    g_yr_len = g_lst_yr - g_strt_yr +1
    g_strt_mon=197901
    g_lst_mon=201312
    g_var_name1 = "r"
    g_data1_path ="../../data/obv/PRECT/precip.pentad.mean.nc"
    g_data2_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ERA-clim/uwnd.mean.nc"
    g_data3_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ERA-clim/vwnd.mean.nc"
    g_plvl =850
    g_font = 0.025
    
    g_latS=-10.
    g_latN=30.
    g_lonW=40.
    g_lonE=130.


    ; create an array of desired pressure levels:
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)"/)
    g_fig_title   = "Pentad:"+ispan(20,26,2)+" Pr, OLR, and UV"+g_plvl
    g_fig_name   = "../../fig/FINAL/FIG1_pt20-26_Pr_OLR_UV850_Clim"


;Prepare the variables
    var_olr=read_noaa_olr_daily_2D(0,364,g_latS,g_latN,g_lonW,g_lonE,"/Users/zhenningli/data/obv/NOAA-OLR/olr.day.mean.f25.nc")
    var_olr:=dim_avg_n_Wrap(var_olr, 0)
    var0_pt=daily_to_pentad_DLL(var_olr)

    ctrl_in1 = addfile(g_data1_path, "r")
    time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    var1  = ctrl_in1->precip(:g_yr_len*73-1,{g_latS:g_latN},{g_lonW:g_lonE})
    var1_pt=var1(0:72,:,:)
    do ii = 0, 72
        var1_pt(ii,:,:)=dim_avg_n_Wrap(var1(ii::73,:,:), 0)
    end do
    ctrl_in2 = addfile(g_data2_path, "r")
    var2  = ctrl_in2->uwnd(:,{g_plvl},{g_latS:g_latN},{g_lonW:g_lonE})
    var2_pt:=daily_to_pentad_DLL(var2)
 
    ctrl_in3 = addfile(g_data3_path, "r")
    var3  = ctrl_in3->vwnd(:,{g_plvl},{g_latS:g_latN},{g_lonW:g_lonE})
    var3_pt:=daily_to_pentad_DLL(var3)

    printVarSummary(var1_pt)


; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/4/),graphic)
  plot_cn = new((/4/),graphic)
  plot_V = new((/4/),graphic)
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
 gsn_define_colormap(wks,"precip2_17lev")


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
 res@cnMinLevelValF        = 4.0         ; set min contour level
 res@cnMaxLevelValF        = 14.0          ; set max contour level
 res@cnLevelSpacingF       = 2.0          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
;  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  res@gsnMaximize      = True       ; fill up the page
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
  res@tmXBTickSpacingF = 20
  res@tmYLTickSpacingF = 10
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =

  resC                  = True       ; use plot options
  resC@cnFillOn         = False;True       ; Fill contours
  resC@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  resC@gsnFrame         = False
  resC@gsnDraw  = False 
  resC@cnLineLabelsOn   = False      ; turn off contour line labels

  resC@cnLineThicknessF = 3.0
  resC@cnLineColor      = "red"
  resC@cnInfoLabelOn = False
  resC@cnMonoLineDashPattern  = False 
  resC@cnLineDashPatterns = (/0/)

  resC@cnLevelSelectionMode="ExplicitLevels"
  resC@cnLevels = (/235/)
  resC@gsnLeftString      = " "
  resC@gsnRightString      = " "


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
  vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.025
  vcres@vcRefAnnoString1  = "5 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.02
 
  vcres@vcLineArrowThicknessF     = 1.5    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.008
  vcres@vcLineArrowHeadMaxSizeF   = 0.008
  
;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
; resP@gsnPanelMainString = "A plot with a common label bar"
                                                 ; use this for NCL V6.3.0 and earlier
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.015               ; make labels smaller 
  
  do ii=0,3
    jj=19+2*ii
    res@gsnLeftString = g_fig_rank(ii)
    res@gsnCenterString = g_fig_title(ii)
    plot_sh(ii) = gsn_csm_contour_map(wks,var1_pt(jj,:,:),res) ; create a default plot
    plot_cn(ii) = gsn_csm_contour(wks,var0_pt(jj,:,:),resC) ; create a default plot
    plot_V(ii) = gsn_csm_vector(wks,var2_pt(jj,:,:),var3_pt(jj,:,:),vcres) 
    overlay(plot_sh(ii),plot_cn(ii))
    overlay(plot_sh(ii),plot_V(ii))
  end do
  gsn_panel(wks,plot_sh,(/2,2/),resP)

end


