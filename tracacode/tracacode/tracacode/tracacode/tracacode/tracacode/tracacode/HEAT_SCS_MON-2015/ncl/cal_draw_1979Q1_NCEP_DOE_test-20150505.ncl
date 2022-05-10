;*************************************************************
;   THIS IS A SCRIPT FOR Q1 CALCULATION TEST    
;Aim: cal daily Q1 from NCEP-DOE Datasets, draw 1979
; daily Q1, file by year
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;     2.1 Calculate Q1
;   3. Draw a profile in a specific region 
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;======================================================
;Variables List:
;	t--------------Air Temperature (K, TLLL)
;	u--------------U Wind (m/s, TLLL)
;	v--------------V Wind (m/s, TLLL)
;	w--------------Vertical Velocity (Pa/s, TLLL)
;	z--------------Geopotential Height (m^2/s^2, TLLL)
;	slp------------Mean Surface Pressure (Pa, TLLL)
;======================================================
;global constants
    G_CPD   =   1004.07     ;Cpd=1004.07 J*kg^-1*K^-1
    G_RD    =   287.05      ;Rd=287.05 J*kg^-1*K^-1
    G_G     =   9.8         ;g=9.8 m*s^-2
;global variables
    ;Define parameters

    ;for directory 
    g_strt_yr=1979
    g_lst_yr=1979
    g_data_dir   =(/"air","uwnd","vwnd","omega","hgt","mslp"/)
    g_data_varname = (/"",""/)
    g_data_path = "../data/obv/NCEP_DOE/"+g_data_dir+"/"+g_data_dir+"."+g_strt_yr+".nc"

    g_latS=0.
    g_latN=20.
    g_lonW=110.
    g_lonE=160.
    ; create an array of desired pressure levels:

        
    g_font = 0.035

    g_fig_name    =   "../fig/obv/1979_Q1"
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)"/)
    ;g_fig_title   =   "1979-2014 "+(/"Mar","Apr","May","Jun","Jul","Aug"/)+" Q1 Trend"
    g_fig_title = "19790101 Q1"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_in1     = addfile (g_data_path(0), "r")   ; note the "s" of addfile
    t  =short2flt( ctrl_in1->air)
	ctrl_in2     = addfile (g_data_path(1), "r")   ; note the "s" of addfile
    u  =short2flt( ctrl_in2->uwnd)
	ctrl_in3     = addfile (g_data_path(2), "r")   ; note the "s" of addfile
    v  =short2flt( ctrl_in3->vwnd)
	ctrl_in4     = addfile (g_data_path(3), "r")   ; note the "s" of addfile
    w  =short2flt( ctrl_in4->omega)
	ctrl_in5     = addfile (g_data_path(4), "r")   ; note the "s" of addfile
    z  =short2flt( ctrl_in5->hgt)
    z  =z*G_G ; change unit from pgm to m^2/s^2
    z@units="m^2/s^2"
    ;ctrl_in6     = addfile (g_data_path(5), "r")   ; note the "s" of addfile
    ;slp  =short2flt( ctrl_in6->mslp)


;   Prepare some global variables

    g_lvl   =   t&level*100 
    g_lat   =   t&lat
    g_lon   =   t&lon
    g_nlat  =   dimsizes(g_lat)
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================

;-----------------------------------------------------------
;Q1 Caculation: (partial diff replaced by complete diff)
;
;   s   =   Cp*T + Z        
;
;   q1  =   d(Cp*T)/dt + V*grad(Cp*T) + w*ds/dp
;               [1]         [2]         [3]
;
;   [1]     dsdt
;   [2]     adv_s
;   [3]     dsdp
;-----------------------------------------------------------
    
    ;CALCULATE Q1
    
    ;preparation
    s   =   z                   ;copy metadata
    s   =   G_CPD*t + z         ;Dry static energy
    s0  =   z
    s0  =   G_CPD*t             ;Cp*T


    ;*****************TERM [1], easy********************
    dsdt    =   z
    dsdt    =   center_finite_diff_n(s0,86400,False,0,0)
    printVarSummary(dsdt)
    ;***************************************************


    ;***********TERM [2], this is a little tricky*******
    adv_s_x =  z    ;u*ds0dx
    adv_s_y =  z    ;v*ds0dy

    ;u*ds0dx
    dlon = (g_lon(2)-g_lon(1))*0.0174533 ; convert to radians
    
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        adv_s_x(:,:,i,:) = center_finite_diff_n (s0(:,:,i,:), dx , True,0,2) ; be careful with the dimison downscale
    end do
    adv_s_x =   u*adv_s_x

    ;v*ds0dy
    dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    adv_s_y = center_finite_diff_n (s0, dy , False,0,2)
    adv_s_y = v*adv_s_y
    
    adv_s   =   adv_s_x ; copy metadata
    adv_s   =   adv_s + adv_s_y
    printVarSummary(adv_s)
    ;***************************************************


    ;*****************TERM [3], easy********************
    dsdp    =   z
    dsdp    =   center_finite_diff_n(s,g_lvl,False,0,1)
    dsdp    =   w*dsdp
    printVarSummary(dsdp)
    ;***************************************************

    q1      =   dsdp ;copy metadata
    q1      =   dsdt + adv_s + dsdp
    q1      =   86400*q1/G_CPD
    
    clim_q1 =   dim_avg_n_Wrap(q1,0)
	clim_q1_area=wgt_areaave_Wrap(clim_q1(:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
	sample_q1_area=wgt_areaave_Wrap(q1(200,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    
    y=q1(:1,:,0,0)
    y(0,:)= (/clim_q1_area/)
    y(1,:)= (/sample_q1_area/)

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
    resxy@xyLineColors      = (/"blue","red"/)          ; change line colors
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

    resxy@xyMarkLineMode       = "MarkLines"  ; markers and lines
    resxy@xyMarkers            = (/16,16/)           ; filled dot
    resxy@xyMarkerSizeF        = (/0.01,0.01/)
    resxy@xyMarkerThicknessF   = (/0.6,0.6/)
    resxy@xyMarkerColors       = (/"blue","red"/)   


    plot  = gsn_csm_xy (wks,y,g_lvl/100,resxy) ; create plot

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
    dum6 = gsn_add_text(wks,plot,"1997Clim",text_pos,yy(0),res_text); add text
    dum55 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)   


    res_lines@gsLineColor       = "red"
    res_lines@gsLineDashPattern = 1.
    res_lines@gsMarkerColor     = "red"
    yy = (/150.,150./)
    dum7 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum8 = gsn_add_text(wks,plot,"1979Day200",text_pos,yy(0),res_text); add text
    dum77 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)   
    
    draw(plot)
    frame(wks)

end

