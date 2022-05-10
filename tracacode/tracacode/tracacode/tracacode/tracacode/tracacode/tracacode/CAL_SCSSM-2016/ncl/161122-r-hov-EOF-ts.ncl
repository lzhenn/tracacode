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
    g_data3_path ="../data/obv/NCEP-DOE/daily/ERA-rain/"

    g_font = 0.025
    
    g_latS=10.
    g_latN=20.
    g_lonW=80.
    g_lonE=120.

    ; create an array of desired pressure levels:
        
    g_fig_rank    = (/"(a)","(b)","(c)"/)
    g_fig_title   = (/"Early","Late", "Clim"/)+" "+g_var_name1
    g_fig_name   = "../fig/obv/hov_lon_time_EOF_ts_"+g_var_name1
    npos_year = 0
    nneg_year = 0


;Prepare the variables
    ctrl_in3_files = systemfunc("ls "+g_data3_path)
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in3     = addfiles (g_data3_path+ctrl_in3_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in3, "join")
    var3  =ctrl_in3[:]->r(:,89:151,{g_latS:g_latN},{g_lonW:g_lonE})
    var3_366  =ctrl_in3[1::4]->r(:,89:151,{g_latS:g_latN},{g_lonW:g_lonE})
    var3_hov =dim_avg_n_Wrap(var3(:,:,:,:),2) 
    var3_366_hov =dim_avg_n_Wrap(var3_366(:,:,:,:),2) 
    var3_hov_dim = dimsizes(var3_hov)
    var3_hov_data = new((/32,var3_hov_dim(1),var3_hov_dim(2)/),"float")
    copy_VarMeta(var3_hov, var3_hov_data)
    sp = 0
    do ii=0,31
        if (mod((ii-1),4) .eq. 0) then
            var3_hov_data(ii,:,:) = var3_366_hov((ii-1)/4,:,:)
            sp = sp+1
        else
            var3_hov_data(ii,:,:) = var3_hov(ii-sp,:,:)
        end if
    end do
    printVarSummary(var3_hov_data)

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
    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot = new((/3/),graphic)
    rts           = True
    rts@gsnDraw   = False       ; don't draw yet
    rts@gsnFrame  = False       ; don't advance frame yet
    rts@gsnScale  = True        ; force text scaling               

    ; these four rtsources allow the user to stretch the plot size, and
    ; decide exactly where on the page to draw it.

    rts@vpHeightF = 0.30        ; Changes the aspect ratio
    rts@vpWidthF  = 0.80
    rts@vpXF      = 0.10        ; change start locations
    rts@vpYF      = 0.75        ; the plot


    rts@tiYAxisString = "Standardized"          ; y-axis label      

    rts@gsnYRefLine           = 0.              ; reference line   
    rts@gsnXYBarChart         = True            ; create bar chart 
    rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
    rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

    rts@trYMinF            = -3.0                 ; Y axis limits
    rts@trYMaxF            = 3.5


    ;rts@tmXBLabelStride     = 1
    rts@tmYLLabelStride     = 2

    rts@tmYLMajorThicknessF = 3.0
    rts@tmXBMinorThicknessF = 3.0
    rts@tmYLMinorThicknessF = 3.0
    rts@tmBorderThicknessF = 3.0

    rts@tmXBLabelFontHeightF = g_font
    rts@tmYLLabelFontHeightF = g_font
    rts@gsnStringFontHeightF = g_font
    rts@tiYAxisFontHeightF   = g_font
    
    do ne=0,neof-1
        YYYY=ispan(1979,2010,1)
        plot(ne) = gsn_csm_xy(wks,YYYY,eof_ts(ne,:),rts)
    end do


    gsn_panel(wks,plot,(/4,1/),False)

    draw(plot)
frame(wks)
    
;  overlay(plot(0),plot_jet(0))  
;  overlay(plot(0),plot_V(0))  
  gsn_panel(wks,plot,(/3,1/),False)

  draw(plot)
  frame(wks)
 
end

