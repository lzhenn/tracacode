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
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_day_rank=(/135,140,150,155,145,140,150,135,160,145,160,140,160,140,150,125,135,130,140,140,150,135,130,135,145,140,150,140,145,125,150,145,130,140/)
    g_strt_yr=1979
    g_lst_yr=2010
    g_day_shift=10

    g_var_name1 = "r"
    g_data1_path ="../data/daily/ERA-rain/"

    g_font = 0.035
    
    g_latS=0.
    g_latN=25.
    g_lonW=105.
    g_lonE=125.

    ; create an array of desired pressure levels:
        
    g_fig_rank    = (/"(a)","(b)","(c)"/)
    g_fig_title   = (/"Early","Late", "Clim"/)+" "+g_var_name1
    g_fig_name   = "../fig/hov_rainy_season_"+g_var_name1
    npos_year = 0
    nneg_year = 0


;Prepare the variables
    ctrl_in1     = addfile (g_data1_path+g_var_name1+"ain.daily.interim."+g_strt_yr+".nc", "r")   ; note the "s" of addfile
    var1_accu_pos  =short2flt( ctrl_in1->$g_var_name1$(:364,{-10:40},{110:120}))
    var1_accu_all = var1_accu_pos
    var1_accu_pos = 0
    var1_accu_neg = var1_accu_pos
    print(g_strt_yr+" done!")
    do nyr = g_strt_yr+1, g_lst_yr
        print(nyr+" done!")
        ctrl_in1     = addfile (g_data1_path+g_var_name1+"ain.daily.interim."+nyr+".nc", "r")   ; note the "s" of addfile
        var1  =short2flt( ctrl_in1->$g_var_name1$(:364,{-10:40},{110:120}))
        var1_accu_all = var1+var1_accu_all
        if (g_day_rank(nyr-1979) .gt. 149) then
            var1_accu_pos = var1 + var1_accu_pos       
            npos_year = npos_year+1
        else if (g_day_rank(nyr-1979) .lt. 131) then
            var1_accu_neg = var1 + var1_accu_neg
            nneg_year = nneg_year+1
        end if
        end if
    end do
    date0 = cd_calendar(var1_accu_pos&time,0)
    var1_accu_pos&time=ispan(0,364,1)
    var1_pt0 = var1_accu_pos(:,:,0)
    var1_pt1 = var1_accu_pos(:,:,0)
    var1_accu_all_avg = var1_accu_pos(:,:,0)
    var1_pt0 = dim_avg_n_Wrap(var1_accu_pos(:,:,:),2)/npos_year
    var1_pt1 = dim_avg_n_Wrap(var1_accu_neg(:,:,:),2)/nneg_year
    var1_accu_all_avg = dim_avg_n_Wrap(var1_accu_all(:,:,:),2)/(g_lst_yr-g_strt_yr+1)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/3/),graphic)
;  plot_jet = new((/3/),graphic)
;  plot_sh = new((/3/),graphic)
;  plot_V = new((/3/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
 gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------

    res                  = True                ; plot mods desired

    res@cnFillOn         = True                ; color on
    res@lbLabelStride    = 2                   ; every other label
    res@lbOrientation    = "Vertical"          ; vertical label bar
    res@cnLinesOn        = False               ; turn off contour lines
    res@cnLevelSpacingF  = 5                   ; contour spacing
    res@vpWidthF = 0.6
    res@vpHeightF = 0.9


 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = 0         ; set min contour level
 res@cnMaxLevelValF        = 14         ; set max contour level
 res@cnLevelSpacingF       = 2         ; set contour interval


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnStringFontHeightF = g_font
  res@tmYLMode = "Explicit"
  res@tmYLValues = (/ 0. , 30., 61., 89., 120., 150.,181, 211, 242, 273, 303, 334 /)
  res@tmYLLabels = (/"JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC" /)

;  res@gsnMaximize      = True       ; fill up the page
;  res@gsnAddCyclic   = True;False
;  res@gsnPaperOrientation = "portrait"
;  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
   
     ; now change the size of the tickmark labels


 res@tmXBLabelFontHeightF = g_font
 ; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
    res@gsnRightString=""
    do ii=0,2  
        res@gsnLeftString=g_fig_rank(ii)
        res@gsnCenterString=g_fig_title(ii)
        if (ii .eq. 0) then
            plot(ii) = gsn_csm_time_lat(wks, var1_pt1(89:273,:), res ) 
        else if (ii .eq. 1) then
            plot(ii) = gsn_csm_time_lat(wks, var1_pt0(89:273,:), res ) 
        else 
            plot(ii) = gsn_csm_time_lat(wks, var1_accu_all_avg(89:273,:), res ) 
        end if
        end if
  end do
  
  
 
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


;      plot_jet(0) = gsn_csm_contour(wks,var1_accu_all_avg,res3)
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



;  overlay(plot(0),plot_jet(0))  
;  overlay(plot(0),plot_V(0))  
  gsn_panel(wks,plot,(/1,3/),False)

  draw(plot)
  frame(wks)
 
end

