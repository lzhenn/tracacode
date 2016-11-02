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
    g_lst_yr=2012
    g_day_shift=10

    g_var_name1 = "uwnd"
    g_data1_path ="../data/daily/"+g_var_name1+"1979-2013/"

    g_font = 0.035
    
    g_latS=0.
    g_latN=40.
    g_lonW=60.
    g_lonE=100.

    ref_day_rank =130-1
    ; create an array of desired pressure levels:
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)"/)
    g_fig_title   = (/"Clim", "Er", "La"/)+" P25-26"
    g_fig_name = "../fig/obv/u-cross-sec"
    npos_year = 0
    nneg_year = 0


;Prepare the variables
    ctrl_in1     = addfile (g_data1_path+g_var_name1+".1979.nc", "r")   ; note the "s" of addfile
    var1_accu_pos  =short2flt( ctrl_in1->$g_var_name1$(ref_day_rank-g_day_shift:ref_day_rank+g_day_shift-1,{:100},{g_latS:g_latN},{g_lonW:g_lonE}))
    var1_accu_all = var1_accu_pos
    var1_accu_pos = 0
    var1_accu_neg = var1_accu_pos
    print("1979 done!")
    do nyr = g_strt_yr+1, g_lst_yr
        print(nyr+" done!")
        ctrl_in1     = addfile (g_data1_path+g_var_name1+"."+nyr+".nc", "r")   ; note the "s" of addfile
        ;time_hist    = ctrl_in1->time
        ;yyyymmdd  = cd_calendar(time_hist,-2)
        ;istrt   = ind(yyyymmdd .eq. g_strt_day)
        ;ilast   = ind(yyyymmdd .eq. g_lst_day)
        var1  =short2flt( ctrl_in1->$g_var_name1$(ref_day_rank-g_day_shift:ref_day_rank+g_day_shift-1,{:100},{g_latS:g_latN},{g_lonW:g_lonE}))
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
    
    var1_pt0 = var1_accu_pos(0,:,:,:)
    var1_pt1 = var1_accu_pos(0,:,:,:)
    var1_accu_all_avg = var1_accu_pos(0,:,:,:)
    var1_diff = var1_accu_pos(0,:,:,:)
    var1_pt0 = dim_avg_n_Wrap(var1_accu_pos(0:g_day_shift-1,:,:,:),0)/npos_year
    var1_pt1 = dim_avg_n_Wrap(var1_accu_neg(0:g_day_shift-1,:,:,:),0)/nneg_year
    var1_accu_all_avg = dim_avg_n_Wrap(var1_accu_all(0:g_day_shift-1,:,:,:),0)/dimsizes(g_day_rank)
    var1_pt0_zmean = dim_avg_n_Wrap(var1_pt0,2)
    var1_pt1_zmean = dim_avg_n_Wrap(var1_pt1,2)
    var1_accu_avg_zmean = dim_avg_n_Wrap(var1_accu_all_avg,2)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/3/),graphic)

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
  res@gsnFrame         = False
  res@gsnDraw  = False
 
  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels


  res@tmYRMode = "Automatic"
 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -10         ; set min contour level
 res@cnMaxLevelValF        = 25         ; set max contour level
 res@cnLevelSpacingF       = 5         ; set contour interval
;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)
 res@vpWidthF = 0.7
 res@vpHeightF = 0.4



 
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

;  res@gsnMaximize      = True       ; fill up the page
;  res@gsnAddCyclic   = True;False
;  res@gsnPaperOrientation = "portrait"
;  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1
;  res@tmXBTickSpacingF = 15
;  res@tmYLTickSpacingF = 15
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = g_font
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = g_font
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
    
    
  do ii=0,2  
    res@gsnRightString=""
    res@gsnLeftString=g_fig_rank(ii)
    res@gsnCenterString=g_fig_title(ii)
    if (ii .eq. 0) then
         plot(ii) = gsn_csm_pres_hgt(wks, var1_accu_avg_zmean, res ) 
    else if (ii .eq. 1) then
         plot(ii) = gsn_csm_pres_hgt(wks, var1_pt1_zmean, res ) 
    else 
         plot(ii) = gsn_csm_pres_hgt(wks, var1_pt0_zmean, res ) 
    end if
    end if
  end do
  

  gsn_panel(wks,plot,(/3,1/),False)

  draw(plot)
  frame(wks)
 
end

