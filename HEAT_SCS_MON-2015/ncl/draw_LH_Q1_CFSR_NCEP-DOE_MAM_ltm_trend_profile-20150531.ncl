;*************************************************************
;Aim: draw latent Heat trend from CFSR Datasets (processed),
;   Q1 from NCEP-DOE
;Mission:
;   1. Read data from CFSR data
;   2. Post-post process
;     2.1 Climatology 
;   3. Draw the climatology profile and climatology+trend*yr 
;      profile
;                       Zhenning Li
;                       2015-05-06
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-05-03  Change to fit CFSR LATENTE Trend
;   2015-05-04  Change to fit CFSR Profile
;   2015-05-06  Change to fit Processed Profile
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List: (All in final form)
;
;	dpcv_q--------------Deep Convection Heating
;                       from CFSR Datasets
;
;
;   q1------------------Q1 from NCEP-DOE Datasets
;
;================================================
;global variables
    ;Define parameters
    g_data_path="../data/obv/"
    g_in_files_cfsr="../data/obv/CFSR_HEAT/*grb2" ;cam5   
    g_in_files=g_data_path+"NCEP_DOE/q1_monthly/q1.*.nc" ;monthly q1
    g_latS=0.
    g_latN=15.
    g_lonW=105.
    g_lonE=155.
; create an array of desired pressure levels:

        
    g_font = 0.035
    g_season = "MAM"
    g_strt_mon = 197901 
    g_lst_mon = 200812
    g_fig_name    =   "../fig/obv/"+g_strt_mon+"-"+g_lst_mon+"_LH_MAM_ltm_trend_Profile_ALL"
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)"/)
   ; g_fig_title   =   "1979-2014 "+(/"Mar","Apr","May","Jun","Jul","Aug"/)+" Latent Engery"
    g_fig_title   = "ANN Mean LH & LH+trend Profile"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

    all_files = systemfunc ("ls "+g_in_files_cfsr)
	ctrl_in1     = addfiles (all_files, "r")   ; note the "s" of addfile
    
    ListSetType (ctrl_in1, "join")             ; concatenate or "merge" (default)
    ;var1  = ctrl_in1[0:35]->CNVHR_P8_L100_GLL0
    var1  = ctrl_in1[:]->CNVHR_P8_L100_GLL0
    var1!0="time"
    var1!1="lev"
    var1!2="lat"
    var1!3="lon"

    ; Read in NCEP-DOE Heating map
    all_files2 = systemfunc ("ls "+g_in_files)
	ctrl_in2     = addfiles (all_files2, "r")   ; note the "s" of addfile
    
    ListSetType (ctrl_in2, "cat")             ; concatenate or "merge" (default)
    var2  = ctrl_in2[:]->q1
    printVarSummary(var2)
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================

;-----------Follow is the vertical integral-----------
;    pver=var1&lev
;    dp=dpres_plevel(pver,100000,100,0)              ; caculate dp
;    dp_cfm=conform_dims(dimsizes(var1),dp,1)        ; confirm dp to caculate sum(var*dp)
;    wgt_var1=var1(:,0,:,:)
;    wgt_var1=dim_sum_n(dp_cfm*var1,1)               ; sum(var*dp)
;    wgt_var1=86400*wgt_var1/sum(dp)                 ; Integral=sum(var*dp)/sum(dp)
;    printVarSummary(wgt_var1)
;-----------Follow to caculate the trend--------------
    dvar1bar_dt      = var1(0,:,:,:) ; dvar1'dt of every indivadual month  
    var1bar = month_to_season(var1,g_season)
    var1bar!0="time" 
    dimz = dimsizes(var1bar)
    yr_length = dimz(0)

    dvar1bar_dt = (/regCoef(ispan(0,yr_length-1,1), var1bar(lev|:,lat|:,lon|:,time|:))/)
    dvar1bar_dt = yr_length*dvar1bar_dt

    var1bar_clim = dim_avg_n_Wrap(var1bar,0)
	var1bar_clim_area=wgt_areaave_Wrap(var1bar_clim(:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
   
    dvar1bar_dt_clim_area=wgt_areaave_Wrap(dvar1bar_dt(:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)

    dpcv_q=var1bar(:1,:,0,0)
    dpcv_q(0,:)= (/var1bar_clim_area/)
    dpcv_q(1,:)= dpcv_q(0,:)+(/dvar1bar_dt_clim_area/)
    dpcv_q = where(dpcv_q .eq. 0, 0.000000000000001,dpcv_q)
    print(dpcv_q(1,:)/dpcv_q(0,:))
    print(dpcv_q&lev)


    dvar2bar_dt      = var2(0,:,:,:) ; dvar1'dt of every indivadual month  
    var2bar = month_to_season(var2,g_season)
    var2bar!0="time"
    dimz = dimsizes(var2bar)
    yr_length = dimz(0)
    
    dvar2bar_dt = (/regCoef(ispan(0,yr_length-1,1), var2bar(lev|:,lat|:,lon|:,time|:))/)
    dvar2bar_dt = yr_length*dvar2bar_dt

    var2bar_clim = dim_avg_n_Wrap(var2bar,0)
	var2bar_clim_area=wgt_areaave_Wrap(var2bar_clim(:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
   
    dvar2bar_dt_clim_area=wgt_areaave_Wrap(dvar2bar_dt(:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)


    ;Now Prepare for plot Form data
    q1=var2bar(:1,:,0,0)
    q1(0,:)= (/var2bar_clim_area/)
    q1(1,:)= q1(0,:)+(/dvar2bar_dt_clim_area/)
    ; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================
    wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
    
    resxy                   = True                      ; plot mods desired
    resxy@gsnDraw           = False
    resxy@gsnFrame          = False


   ; resxy@gsnXRefLine       = 0.0                       ; draw ref line
    resxy@trYReverse        = True                      ; reverse Y-axis
    resxy@xyLineThicknesses = (/2.0,2.0/)           
    resxy@xyLineColors      = (/"black","black"/)          ; change line colors
    resxy@xyMonoDashPattern = False
    resxy@xyDashPatterns    = (/0,1/)
    resxy@trYMinF           = 0.0
    resxy@trYMaxF           = 1000.0


    ;resxy@pmLegendDisplayMode    = "Always"             ; turn on legend
    ;resxy@xyExplicitLegendLabels = (/"CON","SEN","CP_CON","CP_HEAT","HEAT"/)
    ;resxy@pmLegendSide           = "Top"                ; Change location of 
    ;resxy@pmLegendParallelPosF   = .65                  ; move units right
    ;resxy@pmLegendOrthogonalPosF = -0.35                ; move units down
    ;resxy@lgPerimOn = False
    ;resxy@pmLegendWidthF         = 0.12                   ; Change width and
    ;resxy@pmLegendHeightF        = 0.12                   ; height of legend.
    ;resxy@lgLabelFontHeightF     = .020                    ; change font height

    resxy@gsnStringFontHeightF = g_font 
    ;resxy@gsnLeftString = "(c)"


    resxy@trXMinF =  -1.  ; axis min
    resxy@trXMaxF =  5.  ; axis min

    ;resxy@xyMarkLineMode       = "MarkLines"  ; markers and lines
    ;resxy@xyMarkers            = (/16,16/)           ; filled dot
    ;resxy@xyMarkerSizeF        = (/0.01,0.01/)
    ;resxy@xyMarkerThicknessF   = (/0.6,0.6/)
    ;resxy@xyMarkerColors       = (/"blue","red"/)   


    ; Plot Q1
    plot  = gsn_csm_xy (wks,q1*86400,q1&lev,resxy) ; create plot

    ; Plot CFSR Deep Convection Heating
    resxy@xyMarkLineMode       = "MarkLines"  ; markers and lines
    resxy@xyMarkers            = (/16,16/)           ; filled dot
    resxy@xyMarkerSizeF        = (/0.0135,0.0135/)
    resxy@xyMarkerThicknessF   = (/0.6,0.6/)
    resxy@xyMarkerColors       = (/"blue","blue"/)   

    ;delete(resxy@xyLineColors)
    delete(resxy@xyLineThicknesses)
    ;delete(resxy@xyDashPatterns)
    ;resxy@xyDashPatterns = (/2,2/)
    resxy@xyLineColors      = (/"blue","blue"/) 
    ;resxy@xyLineThicknesses = (/4.,4./)  

    plot_deep  = gsn_csm_xy (wks,dpcv_q*86400,dpcv_q&lev/100,resxy) ; create plot


    ; Plot CFSR Diabatic Heating
    delete(resxy@xyMarkLineMode) 
    delete(resxy@xyMarkers)      
    delete(resxy@xyMarkerSizeF)  
    delete(resxy@xyMarkerThicknessF)
    delete(resxy@xyMarkerColor)

    delete(resxy@xyLineThicknesses)
    resxy@xyLineColors      = (/"red","red"/) 

;    plot_diab  = gsn_csm_xy (wks,diab_q*86400,diab_q&lev/100,resxy) ; create plot



    overlay(plot,plot_deep)
;    overlay(plot,plot_diab)

    ;--------------------------------------------------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 2.                    ; line thicker

    res_lines@gsMarkerColor     = "blue"
    res_lines@gsMarkerIndex     = 16
    res_lines@gsMarkerSizeF     = 0.01
    
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.02                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    res_lines@gsLineColor       = "blue"
    yy = (/100.,100./)
    xx = (/1.5,2.0/)
    text_pos = 2.1
    dum5 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum6 = gsn_add_text(wks,plot,"Clim",text_pos,yy(0),res_text); add text
    dum55 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)   


    res_lines@gsLineColor       = "red"
    res_lines@gsLineDashPattern = 1.
    res_lines@gsMarkerColor     = "red"
    yy = (/150.,150./)
    dum7 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum8 = gsn_add_text(wks,plot,"Clim+Change",text_pos,yy(0),res_text); add text
    dum77 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)   
    
    draw(plot)
    frame(wks)

end

