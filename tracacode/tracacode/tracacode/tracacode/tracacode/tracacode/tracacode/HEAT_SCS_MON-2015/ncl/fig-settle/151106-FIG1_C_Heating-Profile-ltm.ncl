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
;   q1------------------Q1 from NCEP-DOE Datasets
;
;================================================
;global variables
    ;Define parameters
    g_data_path="../../data/obv/"
    g_in_files_cfsr="../../data/obv/CFSR_HEAT/*grb2" ;cfsr
    g_in_files=g_data_path+"NCEP_DOE/q1_monthly/q1.*.nc" ;monthly q1
    g_latS=0.
    g_latN=15.
    g_lonW=105.
    g_lonE=155.
; create an array of desired pressure levels:

        
    g_font = 0.02
    g_season = "MAM"
    g_strt_mon = 197901 
    g_lst_mon = 200812
    g_date =systemfunc("date '+%Y%m%d'")
    g_fig_name    =   "../../fig/scientific_reports/FIG1c_MAM_Profile-"+g_date
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)"/)
   ; g_fig_title   =   "1979-2014 "+(/"Mar","Apr","May","Jun","Jul","Aug"/)+" Latent Engery"
    g_fig_title   = "SCS+PhS DPLH DIABH Q1 Profile"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

    all_files = systemfunc ("ls "+g_in_files_cfsr)
	ctrl_in1     = addfiles (all_files, "r")   ; note the "s" of addfile
    
    ListSetType (ctrl_in1, "join")             ; concatenate or "merge" (default)
    var1  = ctrl_in1[:]->CNVHR_P8_L100_GLL0
    ;var1  = ctrl_in1[0:35]->CNVHR_P8_L100_GLL0
    print("READ CFSR DPCVHEAT DONE!")
    var3  = ctrl_in1[:]->TTDIA_P8_L100_GLL0
    ;var3  = ctrl_in1[0:35]->TTDIA_P8_L100_GLL0
    print("READ CFSR DIABHEAT DONE!")
    var1!0="time"
    var1!1="lev"
    var1!2="lat"
    var1!3="lon"

    var3!0="time"
    var3!1="lev"
    var3!2="lat"
    var3!3="lon"

    ; Read in NCEP-DOE Heating map
    all_files2 = systemfunc ("ls "+g_in_files)
	ctrl_in2     = addfiles (all_files2, "r")   ; note the "s" of addfile
    
    ListSetType (ctrl_in2, "cat")             ; concatenate or "merge" (default)
    var2  = ctrl_in2[:]->q1
    print("READ NECP-DOE Q1 DONE!")
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
    
    ;Deep convection heating rate
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

    ;All diabatic heating rate
    dvar3bar_dt      = var3(0,:,:,:) ; dvar1'dt of every indivadual month  
    var3bar = month_to_season(var3,g_season)
    var3bar!0="time" 
    dimz = dimsizes(var3bar)
    yr_length = dimz(0)

    dvar3bar_dt = (/regCoef(ispan(0,yr_length-1,1), var3bar(lev|:,lat|:,lon|:,time|:))/)
    dvar3bar_dt = yr_length*dvar3bar_dt

    var3bar_clim = dim_avg_n_Wrap(var3bar,0)
	var3bar_clim_area=wgt_areaave_Wrap(var3bar_clim(:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
   
    dvar3bar_dt_clim_area=wgt_areaave_Wrap(dvar3bar_dt(:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)

    diab_q=var3bar(:1,:,0,0)
    diab_q(0,:)= (/var3bar_clim_area/)
    diab_q(1,:)= diab_q(0,:)+(/dvar3bar_dt_clim_area/)
    diab_q = where(diab_q .eq. 0, 0.000000000000001,diab_q)

    ;Q1
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

    print("ALL VAR SETTLED...")
    print(q1)
    print(diab_q)
    print(dpcv_q)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================
    wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
    
    resxy                   = True                      ; plot mods desired
    resxy@gsnDraw           = False
    resxy@gsnFrame          = False


   ; resxy@gsnXRefLine       = 0.0                       ; draw ref line
    resxy@trYReverse        = True                      ; reverse Y-axis
    resxy@xyLineThicknesses = (/3.0,3.0/)           
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
    resxy@gsnLeftString = "(c)"
    resxy@gsnCenterString = g_fig_title


    resxy@trXMinF =  -1.  ; axis min
    resxy@trXMaxF =  5.  ; axis min

    ;resxy@xyMarkLineMode       = "MarkLines"  ; markers and lines
    ;resxy@xyMarkers            = (/16,16/)           ; filled dot
    ;resxy@xyMarkerSizeF        = (/0.01,0.01/)
    ;resxy@xyMarkerThicknessF   = (/0.6,0.6/)
    ;resxy@xyMarkerColors       = (/"blue","red"/)   


    ; Plot Q1
    plot_q1  = gsn_csm_xy (wks,q1*86400,q1&lev,resxy) ; create plot

    ; Plot CFSR Deep Convection Heating
    resxy@gsnLeftString = ""
    resxy@gsnCenterString = ""
    resxy@xyMarkLineMode       = "MarkLines"  ; markers and lines
    resxy@xyMarkers            = (/16,16/)           ; filled dot
    resxy@xyMarkerSizeF        = (/0.01,0.01/)
    resxy@xyMarkerThicknessF   = (/0.4,0.4/)
    resxy@xyMarkerColors       = (/"blue","blue"/)   

    ;delete(resxy@xyLineColors)
    ;delete(resxy@xyLineThicknesses)
    ;delete(resxy@xyDashPatterns)
    ;resxy@xyDashPatterns = (/2,2/)
    resxy@xyLineColors      = (/"blue","blue"/) 
    ;resxy@xyLineThicknesses = (/4.,4./)  

    plot_deep  = gsn_csm_xy (wks,dpcv_q*86400,dpcv_q&lev/100,resxy) ; create plot


    ; Plot CFSR Diabatic Heating

    resxy@xyMarkers            = (/7,7/)           ; filled dot
    resxy@xyMarkerColors       = (/"red","red"/)   
    resxy@xyLineColors      = (/"red","red"/) 
    
    resxy@xyMarkerThicknessF   = (/3.0,3.0/)

    plot_diab  = gsn_csm_xy (wks,diab_q*86400,diab_q&lev/100,resxy) ; create plot



    overlay(plot_deep,plot_diab)
    overlay(plot_deep,plot_q1)

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
    yy = (/50.,50./)
    xx = (/1.5,2.0/)
    text_pos = 2.1
    dum5 = gsn_add_polyline(wks,plot_deep,xx,yy,res_lines)              ; add polyline
    dum6 = gsn_add_text(wks,plot_deep,"DPLH Clim",text_pos,yy(0),res_text); add text
    dum55 = gsn_add_polymarker(wks,plot_deep,xx,yy,res_lines)   

    res_lines@gsLineDashPattern = 1.
   
    yy = yy+50
    dum51 = gsn_add_polyline(wks,plot_deep,xx,yy,res_lines)              ; add polyline
    dum61 = gsn_add_text(wks,plot_deep,"DPLH Clim+Change",text_pos,yy(0),res_text); add text
    dum551 = gsn_add_polymarker(wks,plot_deep,xx,yy,res_lines)   

   
    res_lines@gsMarkerIndex     = 7
    res_lines@gsLineColor       = "red"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsMarkerColor     = "red"
    res_lines@gsMarkerThicknessF   = 3.0
    yy = yy+50
    dum7 = gsn_add_polyline(wks,plot_deep,xx,yy,res_lines)              ; add polyline
    dum8 = gsn_add_text(wks,plot_deep,"DIABH Clim Q1",text_pos,yy(0),res_text); add text
    dum77 = gsn_add_polymarker(wks,plot_deep,xx,yy,res_lines)   
    
    res_lines@gsLineDashPattern = 1.
    yy = yy+50
    dum71 = gsn_add_polyline(wks,plot_deep,xx,yy,res_lines)              ; add polyline
    dum81 = gsn_add_text(wks,plot_deep,"DIABH Clim+Change",text_pos,yy(0),res_text); add text
    dum771 = gsn_add_polymarker(wks,plot_deep,xx,yy,res_lines)   
    
    draw(plot_deep)
    frame(wks)

end

