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
    g_strt_yr=1979
    g_lst_yr=2014

    g_data_path = "../data/obv/NCEP-DOE-T2M/"

    g_font = 0.035

    g_latS=-90.
    g_latN=90.
    g_lonW=0.
    g_lonE=360.
    ; create an array of desired pressure levels:

        

    g_fig_title   =  "MAM T2M std"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================


;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

;  plot_sh = new((/1/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------
    res                  = True       ; use plot options

    res@cnFillOn             = True               ; turn on color for contours
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off contour line labels

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = 0.0         ; set min contour level
    res@cnMaxLevelValF        = 12.0          ; set max contour level
    res@cnLevelSpacingF       = 0.5          ; set contour interval

    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

    res@gsnSpreadColors      = True               ; use full color map

    ;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
    res@gsnStringFontHeightF = g_font

    res@gsnMaximize      = True       ; fill up the page
    res@gsnAddCyclic   = True;False
    res@gsnPaperOrientation = "portrait"
    res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller
    res@lbLabelStride = 4 

    res@mpFillOn   = False     ; turn off gray continents
    res@mpGeophysicalLineThicknessF = 2
    res@mpGeophysicalLineColor      = "black";"white" 
    ;res@mpFillDrawOrder="PostDraw"
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
    res@tmXBTickSpacingF = 60
    res@tmYLTickSpacingF = 30
    res@tmXBLabelFontHeightF = g_font
    ; res@tmXBLabelFontAspectF = 1.6
    res@tmXBLabelFontThicknessF = 2.0
    res@tmYLLabelFontHeightF = g_font
    ; res@tmYLLabelFontAspectF = 1.3
    res@tmYLLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontQuality =
    ;-----------------------------------------------------------------------------

    res@gsnRightString = ""
    res@gsnCenterString = g_fig_title

    do nyr = g_strt_yr, g_lst_yr
        g_fig_name = "../fig/MAM_dtr_t2m_std"+nyr
        g_strt_day = nyr*10000+3*100+1
        g_lst_day = nyr*10000+5*100+31
        
        ctrl_in1     = addfile (g_data_path+"air.2m.gauss."+nyr+".nc", "r")   ; note the "s" of addfile
        time_hist    = ctrl_in1->time
        yyyymmdd  = cd_calendar(time_hist,-2)
        istrt   = ind(yyyymmdd .eq. g_strt_day)
        ilast   = ind(yyyymmdd .eq. g_lst_day)
        t2m  =short2flt( ctrl_in1->air(istrt:ilast,0,:,:))
        ;t2m = g2fsh_Wrap(t2m_g,(/72,144/))
        ;printVarSummary(t2m)
        ;post process
        dtr_t2m = t2m
        dtr_t2m = dtrend_n(t2m, False, 0)
        dtr_t2m_std = dim_stddev_n_Wrap(dtr_t2m,0)
        
        ;plot
        wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
        gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
        
        res@gsnLeftString = nyr
        dtr_t2m_std = where(dtr_t2m_std .lt. 3.0, dtr_t2m_std@_FillValue,dtr_t2m_std)
        plot_sh = gsn_csm_contour_map_ce(wks,dtr_t2m_std,res) ; create a default plot
        print(nyr+" std:"+wgt_areaave(dtr_t2m_std({45:60},:),1.0,1.0,0))
        draw(plot_sh)
        frame(wks)

        ;clean up
        delete([/wks, plot_sh, time_hist, yyyymmdd/])
    end do
end

