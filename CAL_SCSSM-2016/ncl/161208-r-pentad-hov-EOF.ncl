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
    g_strt_yr=1979
    g_lst_yr=2014
    g_yr_len=g_lst_yr-g_strt_yr+1
    g_var_name1 = "r"

    g_data3_path ="../data/obv/PRECT/precip.pentad.mean.nc"
    g_font = 0.025
    
    g_latS=5.
    g_latN=20.
    g_lonW=80.
    g_lonE=120.

    ; create an array of desired pressure levels:
        
    g_fig_rank    = (/"(a)","(b)","(c)"/)
    g_fig_name   = "../fig/obv/hov_lon_time_EOF_"+g_var_name1


;Prepare the variables
    ctrl_in3 = addfile(g_data3_path, "r")
    time_hist    = ctrl_in3->time
    yyyymm  = cd_calendar(time_hist,-1)
    var3  = ctrl_in3->precip(:g_yr_len*73-1,{g_latS:g_latN},{g_lonW:g_lonE})
    dimvar3=dimsizes(var3)
    var3_pt  = reshape(var3,(/g_yr_len,73,dimvar3(1),dimvar3(2)/))
    copy_VarAtts(var3,var3_pt)
    var3_pt!2=var3!1
    var3_pt!3=var3!2
    var3_pt&lon=var3&lon
    var3_pt&lat=var3&lat
    printVarSummary(var3_pt)
    printVarSummary(var3)
    exit
    neof=3
    optEOF=True
    optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
    optETS = False
     
    var3_hov_anom = dim_rmvmean_n_Wrap(var3_hov_data, 0)
    var3_rg    = var3_hov_anom(time|:,lon|:,ncl_join|:)
    eof    = eofunc_Wrap(var3_rg, neof, optEOF)      
    eof_ts = eofunc_ts_Wrap (var3_rg, eof, optETS)
    ;eof_ts = dtrend(eof_ts,False)
    eof_ts = dim_standardize_n(eof_ts, 0, 1)      ; normalize
    ; regress the field
    eof_regres = eof                               ; create an array w meta data

   
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
  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------

    res                  = True                ; plot mods desired

    res@cnFillOn         = True                ; color on
    res@lbLabelStride    = 2                   ; every other label
    res@lbOrientation    = "Vertical"          ; vertical label bar
    res@lbLabelFontHeightF    = g_font          ; vertical label bar
    res@cnLinesOn        = False               ; turn off contour lines
    res@cnLevelSpacingF  = 5                   ; contour spacing
    res@vpWidthF = 0.4
    res@vpHeightF = 0.4


 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -4         ; set min contour level
 res@cnMaxLevelValF        = 4         ; set max contour level
 res@cnLevelSpacingF       = 1         ; set contour interval


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnStringFontHeightF = g_font
  res@tmYLMode = "Explicit"
  res@tmYLValues = (/ 0. , 31., 59., 90., 120., 151.,181, 212, 243, 273, 301, 331 /)
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

  
  
  ;--------------------------------------

    do ne=0,neof-1
        eof_regres(ne,:,:) = (/ regCoef(eof_ts(ne,:), var3_rg(time|:,lon|:,ncl_join|:)) /)
        res@gsnLeftString=g_fig_rank(ne)
        res@gsnCenterString=sprintf("%5.1f", eof@pcvar(ne)) +"%"
        plot(ne) = gsn_csm_hov(wks, eof_regres(ne,:,:), res) 
    end do


;  overlay(plot(0),plot_jet(0))  
;  overlay(plot(0),plot_V(0))  
  gsn_panel(wks,plot,(/3,1/),False)

  draw(plot)
  frame(wks)
 
end

