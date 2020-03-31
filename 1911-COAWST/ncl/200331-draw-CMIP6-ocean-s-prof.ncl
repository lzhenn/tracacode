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
    data_path="/users/b145872/project-dir/data/CMIP6/"
    g_hist_path=data_path+"so_Omon_CESM2_historical_r1i1p1f1_gr_185001-201412.nc"

    g_exps=data_path+(/"so_Omon_CESM2_1pctCO2_r1i1p1f1_gr_010101-015012.nc",\
            "so_Omon_CESM2_piControl_r1i1p1f1_gr_110001-120012.nc",\
            "so_Omon_CESM2_ssp126_r1i1p1f1_gr_206501-210012.nc",\
            "so_Omon_CESM2_ssp245_r1i1p1f1_gr_206501-210012.nc",\
            "so_Omon_CESM2_ssp370_r1i1p1f1_gr_206501-210012.nc",\
            "so_Omon_CESM2_ssp585_r1i1p1f1_gr_206501-210012.nc"/)
    
    g_expnames=(/"1pctCO2", "PICTRL", "SSP126", "SSP245", "SSP370", "SSP585"/)
    g_archv_lbnames=(/"Hist", "1pctCO2", "PICtrl", "SSP126", "SSP245", "SSP370", "SSP585"/)
    
    g_latS=10.
    g_latN=20.
    g_lonW=110.
    g_lonE=130.
        
    g_dep0=0
    g_dep1=300

; create an array of desired pressure levels:
        
    g_font = 0.025
    g_season = "JAS"
    g_strt_mon = 198101
    g_lst_mon = 201012
    g_fig_name    =   "../fig/ocean_temp_profile_CMIP6"
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)"/)
   ; g_fig_title   =   "1979-2014 "+(/"Mar","Apr","May","Jun","Jul","Aug"/)+" Latent Engery"
    g_fig_title   = "Upper Ocean S Profile"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_in1     = addfile (g_hist_path, "r")   ; note the "s" of addfile
   
    time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
    
    lvls = ctrl_in1->lev({g_dep0:g_dep1})
    
    var1  =ctrl_in1->so(istrt:ilast,{g_dep0:g_dep1},{g_latS:g_latN},{g_lonW:g_lonE})            ; p for unify the var name
    clim_var1=dim_avg_n_Wrap(month_to_season(var1,g_season),0)
    areamean_var1=wgt_areaave_Wrap(clim_var1,1.0,1.0,0)
    
    nExp=dimsizes(g_expnames)
    arch_var1=var1(0:nExp,:,0,0)
    arch_var1=0
    arch_var1(0,:)=areamean_var1
    
    ;do iExp = 0, 0
    do iExp = 0, nExp-1
        fileIn  := addfile (g_exps(iExp), "r")   ; note the "s" of addfile
        var1:=fileIn->so(:,{g_dep0:g_dep1},{g_latS:g_latN},{g_lonW:g_lonE})
        clim_var1:=dim_avg_n_Wrap(month_to_season(var1,g_season),0)
        areamean_var1:=wgt_areaave_Wrap(clim_var1,1.0,1.0,0)
        arch_var1(iExp+1,:)=areamean_var1
    end do
    
    print(arch_var1)

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================
    wks = gsn_open_wks("x11",g_fig_name)  ; open a ps file
    
    resxy                   = True                      ; plot mods desired
    resxy@gsnDraw           = False
    resxy@gsnFrame          = False


   ; resxy@gsnXRefLine       = 0.0                       ; draw ref line
    resxy@trYReverse        = True                      ; reverse Y-axis
    resxy@xyLineThicknesses = (/4.0,4.0,4.0,4.0,4.0,4.0,4.0/)
    resxy@xyLineColors      = (/"black","green","gray50","blue","yellow","orange","red"/)          ; change line colors
    resxy@xyMonoDashPattern = False
    resxy@xyDashPatterns    = 0
    resxy@trYMinF           = 0.0
;    resxy@trYMaxF           = 1000.0


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


;    resxy@trXMinF =  10.  ; axis min
;    resxy@trXMaxF =  35.  ; axis min

    ;resxy@xyMarkLineMode       = "MarkLines"  ; markers and lines
    ;resxy@xyMarkers            = (/16,16/)           ; filled dot
    ;resxy@xyMarkerSizeF        = (/0.01,0.01/)
    ;resxy@xyMarkerThicknessF   = (/0.6,0.6/)
    ;resxy@xyMarkerColors       = (/"blue","red"/)   


    ; Plot Q1
    plot  = gsn_csm_xy (wks,arch_var1,lvls,resxy) ; create plot


    ;--------------------------------------------------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 4.                    ; line thicker
    
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    xx = (/32.4,32.6/)
    yy = (/150.,150./)
    text_pos = 32.7

    
    do iExp = 0, dimsizes(g_archv_lbnames)-1
        res_lines@gsLineColor       = resxy@xyLineColors(iExp)
        yy=yy+15
        yy@$unique_string("fxxk ncl")$ = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
        yy@$unique_string("fxxk ncl")$ = gsn_add_text(wks,plot,g_archv_lbnames(iExp),text_pos,yy(0),res_text); add text
    end do

    draw(plot)
    frame(wks)

end

