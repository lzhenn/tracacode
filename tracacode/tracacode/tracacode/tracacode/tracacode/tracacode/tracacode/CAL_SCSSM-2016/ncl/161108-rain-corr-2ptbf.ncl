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
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_day_rank=(/135,140,150,155,145,140,150,135,160,145,160,140,160,140,150,125,135,130,140,140,150,135,130,135,145,140,150,140,145,125,150,145,130,140/)
    g_day_rankp=g_day_rank/5
    g_strt_yr=1979
    g_lst_yr=2010
    g_day_shift=5

    g_var_name3 = "r"
    g_data3_path ="../data/daily/ERA-rain/"

    g_font = 0.025
    
    g_lats=0.
    g_latn=30.
    g_lonw=85.
    g_lone=125.

    ;Andaman Sea convection
    g_latS=10.
    g_latN=20.
    g_lonW=90.
    g_lonE=100.

    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/"+"OnsetPentad-AndamanConv-Corr"
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)"/)
    g_fig_title   = "-2pAmSeaConv-SCS Onset"

    npos_year = 0
    nneg_year = 0

;Prepare the variables
    ctrl_in3_files = systemfunc("ls "+g_data3_path)
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in3     = addfiles (g_data3_path+ctrl_in3_files, "r")   ; note the "s" of addfile
    ;time_hist    = ctrl_in1->time
    ;yyyymmdd  = cd_calendar(time_hist,-2)
    ;istrt   = ind(yyyymmdd .eq. g_strt_day)
    ;ilast   = ind(yyyymmdd .eq. g_lst_day) 
    ListSetType (ctrl_in3, "join")
    var3  =ctrl_in3[:]->r(:,:,:,:)
    var3_366  =ctrl_in3[1::4]->r(:,:,:,:)
    adm_mean_var3=wgt_areaave_Wrap(var3(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    
    adm_mean_var3_366=wgt_areaave_Wrap(var3_366(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    
    var3_data = new((/32/),"float")
    copy_VarMeta(adm_mean_var3, var3_data)
    sp = 0
    adm_mean_var3_p2425_366=adm_mean_var3(0,0:9)
    
    clim_var3=adm_mean_var3(0,0:364)
    clim_var3=dim_avg_n_Wrap(adm_mean_var3,0)*0.75+dim_avg_n_Wrap(adm_mean_var3_366(:,0:364),0)*0.25
    do ii=0,31
        period_0=g_day_rank(ii)-g_day_shift
        period_1=g_day_rank(ii)+g_day_shift-1
        if (mod((ii-1),4) .eq. 0) then
            adm_mean_var3_p2425=100*(adm_mean_var3_366((ii-1)/4,period_0:period_1)-clim_var3(period_0:period_1))/clim_var3(period_0:period_1)
            var3_data(ii) = dim_avg_Wrap(adm_mean_var3_p2425)
            sp = sp+1
        else
            adm_mean_var3_p2425=100*(adm_mean_var3(ii-sp,period_0:period_1)-clim_var3(period_0:period_1))/clim_var3(period_0:period_1)
            var3_data(ii) = dim_avg_Wrap(adm_mean_var3_p2425)
        end if
    end do
    print(var3_data)

    
    ; ==============================================================
    ; Mission 3. Set plot parameters and plot
    ; ==============================================================
    ;************************************************
    ; Create an array to hold both the original data
    ; and the calculated regression line.
    ;************************************************
    var_reg=regline(g_day_rankp(0:31), var3_data)
    r = escorc(g_day_rankp(0:31), var3_data)
    sig = rtest(r,32,0) 
    print(r)
    print(sig)
    yreg = var_reg*ispan(min(g_day_rankp),max(g_day_rankp),1) + var_reg@yintercept   ; ncl array notation 



    ;************************************************
    ; plotting parameters
    ;************************************************
    
    wks = gsn_open_wks ("eps",g_fig_name) ; open workstation
    plot = new((/2/),graphic)
    
    res               = True                    ; plot mods desired
    res@gsnDraw                = False
    res@gsnFrame                = False
    
    res@vpXF     = 0.2
    res@vpYF     = 0.85

    res@vpWidthF = 0.7
    res@vpHeightF= 0.5

;    res@trYMinF            =  0.0               ; min value on y-axis
;    res@trYMaxF            =  9.0               ; max value on y-axis
;    res@trXMinF            =  27.5                  ; min value on x-axis
;    res@trXMaxF            =  30.0                  ; max value on x-axis


    ;---Set some marker resources
    res@xyMarkLineMode     = "Markers"
    res@xyMarkerSizeF      = 0.015
    res@xyMarkerThicknessF = 2.0
    res@xyMarkerColor     = "Red"  ; It's okay to list more than you need here
    res@xyMarkers          = (/4,6,7/)  ; Again, you can list more than you need.

 
    res@tmYLLabelFontHeightF = g_font
    res@tmXBLabelFontHeightF = g_font
    res@gsnStringFontHeightF = g_font
    res@tiXAxisFontHeightF   = g_font
    res@tiYAxisFontHeightF   = g_font
    res@gsnLeftString     = g_fig_title
    res@tiYAxisString     = "Pr Anomaly (%)"
    res@tiXAxisString = "Onset Pentad"
    plot(0)  = gsn_csm_xy (wks,g_day_rankp(0:31),var3_data,res)

    delete([/res@xyMarkerSizeF,res@xyMarkerColor,res@xyMarkers,res@xyMarkerThicknessF/])
    
    res@xyMarkLineMode     = "Lines"
    res@xyLineColors       = "Black" ; colors chosen
    res@xyLineThicknesses    = 4.0      ; line thicknesses
    res@xyDashPattern=0.

        
    plot(1) = gsn_csm_xy (wks,ispan(min(g_day_rankp),max(g_day_rankp),1),yreg,res) ; create plot
    overlay(plot(0),plot(1))
    draw(plot(0))
    frame(wks)
end
