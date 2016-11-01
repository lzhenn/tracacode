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
;	var1--------------U (K, TLL)
;	var2--------------V (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_day_rank=(/135,140,150,155,145,140,150,135,160,145,160,140,160,140,150,125,135,130,140,140,150,135,130,135,145,140,150,140,145,125,150,145,130,140/)
    g_strt_yr=1979
    g_lst_yr=2012
    g_day_shift=10

    g_var_name1 = "uwnd"
    g_var_name2 = "vwnd"
    g_data1_path ="../data/daily/"+g_var_name1+"1979-2013/"
    g_data2_path ="../data/daily/"+g_var_name2+"1979-2013/"

    g_font = 0.035
    
    g_latS=0.
    g_latN=25.
    g_lonW=105.
    g_lonE=125.

    g_latS=0.
    g_latN=60.
    g_lonW=60.
    g_lonE=145.

    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/"+g_var_name1+g_var_name2+"_sync_earliest_comp_P1-P0"
        
    g_fig_rank    = (/"(a)","(b)","(c)"/)
    g_fig_title   = (/" 23-25P Er-La ","+2Pts ", "Diff "/)+"UV"

    npos_year = 0
    nneg_year = 0


;Prepare the variables
    ctrl_in1     = addfile (g_data1_path+g_var_name1+".1979.nc", "r")   ; note the "s" of addfile
    ctrl_in2     = addfile (g_data2_path+g_var_name2+".1979.nc", "r")   ; note the "s" of addfile
    ref_day_rank =125-1
    var1_accu_pos  =short2flt( ctrl_in1->$g_var_name1$(ref_day_rank-g_day_shift:ref_day_rank+g_day_shift-1,{200},:,:))
    var2_accu_pos  =short2flt( ctrl_in2->$g_var_name2$(ref_day_rank-g_day_shift:ref_day_rank+g_day_shift-1,{200},:,:))
    var1_accu_all = var1_accu_pos
    var2_accu_all = var2_accu_pos
    var1_accu_pos = 0
    var2_accu_pos = 0
    var1_accu_neg = var1_accu_pos
    var2_accu_neg = var2_accu_pos
    print("1979 done!")
    do nyr = g_strt_yr+1, g_lst_yr
        print(nyr+" done!")
        ctrl_in1     = addfile (g_data1_path+g_var_name1+"."+nyr+".nc", "r")   ; note the "s" of addfile
        ctrl_in2     = addfile (g_data2_path+g_var_name2+"."+nyr+".nc", "r")   ; note the "s" of addfile
        ;time_hist    = ctrl_in1->time
        ;yyyymmdd  = cd_calendar(time_hist,-2)
        ;istrt   = ind(yyyymmdd .eq. g_strt_day)
        ;ilast   = ind(yyyymmdd .eq. g_lst_day)
        var1  =short2flt( ctrl_in1->$g_var_name1$(ref_day_rank-g_day_shift:ref_day_rank+g_day_shift-1,{200},:,:))
        var2  =short2flt( ctrl_in2->$g_var_name2$(ref_day_rank-g_day_shift:ref_day_rank+g_day_shift-1,{200},:,:))
        var1_accu_all = var1+var1_accu_all
        var2_accu_all = var2+var2_accu_all
        if (g_day_rank(nyr-1979) .gt. 149) then
            var1_accu_pos = var1 + var1_accu_pos       
            var2_accu_pos = var2 + var2_accu_pos       
            npos_year = npos_year+1
        else if (g_day_rank(nyr-1979) .lt. 131) then
            var1_accu_neg = var1 + var1_accu_neg
            var2_accu_neg = var2 + var2_accu_neg
            nneg_year = nneg_year+1
        end if
        end if
    end do
    
    var1_pt0 = var1_accu_pos(0,:,:)
    var2_pt0 = var2_accu_pos(0,:,:)
    var1_pt1 = var1_accu_pos(0,:,:)
    var2_pt1 = var2_accu_pos(0,:,:)
    var1_accu_all_avg = var1_accu_pos(0,:,:)
    var2_accu_all_avg = var2_accu_pos(0,:,:)
    var1_diff = var1_accu_pos(0,:,:)
    var2_diff = var2_accu_pos(0,:,:)
    var1_pt0 = dim_avg_n_Wrap(var1_accu_pos(0:g_day_shift-1,:,:),0)/npos_year
    var2_pt0 = dim_avg_n_Wrap(var2_accu_pos(0:g_day_shift-1,:,:),0)/npos_year
    var1_pt1 = dim_avg_n_Wrap(var1_accu_neg(0:g_day_shift-1,:,:),0)/nneg_year
    var2_pt1 = dim_avg_n_Wrap(var2_accu_neg(0:g_day_shift-1,:,:),0)/nneg_year
    var1_accu_all_avg = dim_avg_n_Wrap(var1_accu_all(0:g_day_shift-1,:,:),0)/dimsizes(g_day_rank)
    var2_accu_all_avg = dim_avg_n_Wrap(var2_accu_all(0:g_day_shift-1,:,:),0)/dimsizes(g_day_rank)
    var1_diff = var1_pt1 - var1_pt0
    var2_diff = var2_pt1 - var2_pt0
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/3/),graphic)
  plot_jet = new((/3/),graphic)
  plot_sh = new((/3/),graphic)
  plot_V = new((/3/),graphic)

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
 res@cnMinLevelValF        = -10         ; set min contour level
 res@cnMaxLevelValF        = 10         ; set max contour level
 res@cnLevelSpacingF       = 2         ; set contour interval
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
  res@mpFillDrawOrder="PostDraw"
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
    res@gsnLeftString=g_fig_rank(0)
    res@gsnCenterString=g_fig_title(0)
  
  
  
  plot(0) = gsn_csm_contour_map_ce(wks,var1_diff,res)
 
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
      res3@cnLevels = (/20/)
      res3@cnLineColor      = "Red"
      res3@gsnLeftString      = " "
      res3@gsnRightString      = " "


      plot_jet(0) = gsn_csm_contour(wks,var1_accu_all_avg,res3)
    ;-----------------------------------------------------------------------------
          
      vcres = True
      vcres@gsnDraw          = False           ; don't draw
      vcres@gsnFrame         = False           ; don't advance frame
      vcres@gsnRightString   = " "             ; turn off right string
      vcres@gsnLeftString    = " "             ; turn off left string
      vcres@gsnCenterString    = " "
     
      vcres@vcRefAnnoOn      = True
      vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
      vcres@vcRefMagnitudeF         = 25.0             ; define vector ref mag
      vcres@vcRefLengthF            = 0.045            ; define length of vec ref
      vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
      vcres@vcMinDistanceF          = 0.017
      vcres@vcRefAnnoString1  = "25 m/s"
      vcres@vcRefAnnoString2  = ""
      vcres@vcRefAnnoFontHeightF = 0.01
     
      vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
    ;  vcres@vcLineArrowHeadMinSizeF   = 0.010
    ;  vcres@vcLineArrowHeadMaxSizeF   = 0.130
    ;--------------------------------------

      var1_accu_all_avg = where(wind_speed(var1_accu_all_avg,var2_accu_all_avg) .lt. 25, var1_accu_all_avg@_FillValue, var1_accu_all_avg)
      plot_V(0) = gsn_csm_vector(wks,var1_accu_all_avg,var2_accu_all_avg,vcres)


  overlay(plot(0),plot_jet(0))  
  overlay(plot(0),plot_V(0))  
  gsn_panel(wks,plot(0),(/1,1/),False)

  draw(plot)
  frame(wks)
 
end

