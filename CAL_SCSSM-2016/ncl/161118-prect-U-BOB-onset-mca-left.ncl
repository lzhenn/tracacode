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
;	t2m--------------Air Temperature (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_day_rank=(/135,140,150,155,145,140,150,135,160,145,160,140,160,140,150,125,135,130,140,140,150,135,130,135,145,140,150,140,145,125,150,145,130,140/)
    g_strt_yr=1979
    g_lst_yr=2010
    g_day_shift=10

    g_var_name = "r"
    g_data_path ="../data/obv/NCEP-DOE/monthly/uwnd.mon.mean.nc"
    g_data2_path ="../data/obv/PRECT/precip.mon.mean.nc"

    g_font = 0.035
    
    g_latS1=0.
    g_latN1=45.
    g_lonW1=30.
    g_lonE1=130.
    
    g_latS2=6
    g_latN2=22
    g_lonW2=88.
    g_lonE2=122.
    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/mca_pr_u_left_may"
        
    g_fig_rank    = (/"(a)","(b)","(c)"/)
    g_fig_title   = (/" -2Pts ","+2Pts ", "Diff "/)+g_var_name



;Prepare the variables
    ctrl_in1     = addfile (g_data_path, "r")   ; note the "s" of addfile
    var1  = short2flt(ctrl_in1->uwnd(4::12,{200},:,:))
    
    ctrl_in2     = addfile (g_data2_path, "r")   ; note the "s" of addfile
    var2  = ctrl_in2->precip(4::12,:,:)


; ==============================================================
; Mission 3. post process the data
; ==============================================================

    nmca = 1 ; how many MCA we need



    var1_region = var1(:,{g_latS1:g_latN1},{g_lonW1:g_lonE1})
    var1_region_LLT = var1_region(lat|:,lon|:,time|:)
    var1_ano = dim_rmvmean_n_Wrap(var1_region,0)
    
    var1_size = dimsizes(var1_ano)
    n_var1_size = var1_size(1)*var1_size(2)
    homlft = new((/nmca,n_var1_size/),float)
    hetlft = new((/nmca,n_var1_size/),float)
    var1_ano_line = reshape(var1_ano,(/var1_size(0),n_var1_size/))
    var1_ano_line!0 = "time" 
    var1_ano_line!1 = "pts"

 
    var2_region = var2(:,{g_latS2:g_latN2},{g_lonW2:g_lonE2})
    var2_region_LLT = var2_region(lat|:,lon|:,time|:)
    var2_ano = dim_rmvmean_n_Wrap(var2_region,0)
    
    var2_size = dimsizes(var2_ano)
    n_var2_size = var2_size(1)*var2_size(2)
    homrgt = new((/nmca,n_var2_size/),float)
    hetrgt = new((/nmca,n_var2_size/),float)
    var2_ano_line = reshape(var2_ano,(/var2_size(0),n_var2_size/))
    var2_ano_line!0 = "time" 
    var2_ano_line!1 = "pts" 



               
        mca_var2 = svdcov(var1_ano_line(pts|:,time|:),var2_ano_line(pts|:,time|:),nmca,homlft,hetlft,homrgt,hetrgt) 
        var2_ak   = onedtond(mca_var2@ak,(/nmca,var1_size(0)/)) ;timeseries
        var2_bk   = onedtond(mca_var2@bk,(/nmca,var1_size(0)/)) ;timeseries
        var2_ak!0 = "sv"
        var2_ak!1 = "time"
        var2_bk!0 = "sv"
        var2_bk!1 = "time"
       
        var2_ak_std=dim_standardize_Wrap(var2_ak,1)
        reg_var2 = var2_region(0,:,:)

        reg_var2 = (/regCoef(var2_ak_std(0,:), var2_region_LLT)/) 
        
        
        var1_bk_std=dim_standardize_Wrap(var2_bk,1)
        reg_var1 = var1_region(0,:,:)
        printVarSummary(reg_var1)
        printVarSummary(var1_bk_std)
        printVarSummary(var1_region_LLT)
        reg_var1 = (/regCoef(var2_ak_std(0,:), var1_region_LLT)/) 
        reg_var1 = - reg_var1 

        print("var2 MCA done!") 
      
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_S = new((/1/),graphic)
;  plot_tp = new((/2/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


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
 res@cnMinLevelValF        = -5         ; set min contour level
 res@cnMaxLevelValF        = 5         ; set max contour level
 res@cnLevelSpacingF       = 1         ; set contour interval
 res@mpDataBaseVersion    = "MediumRes"
;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1

  res@mpFillOn   = False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
  res@mpCenterLonF = 180.
  res@mpMaxLatF  = g_latN1
  res@mpMinLatF  = g_latS1
  res@mpMaxLonF  = g_lonE1
  res@mpMinLonF  = g_lonW1

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
  res@tmXBTickSpacingF = 15
  res@tmYLTickSpacingF = 15
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
    res@gsnRightString=""
    plot_S   =    gsn_csm_contour_map_ce(wks,reg_var1,res) ; create a default plot

    draw(plot_S)
    frame(wks)
end 


