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
    g_data_path="/users/yangsong3/L_Zealot/F/Ideal_phy/ctrl/Ideal_phy.cam.h0.0001-01-01-00000.nc"
        
    g_font = 0.03

    g_date =systemfunc("date '+%Y%m%d'")
    g_fig_name    =   "../../fig/paper/FigS1b-heating-profile"
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)"/)
   ; g_fig_title   =   "1979-2014 "+(/"Mar","Apr","May","Jun","Jul","Aug"/)+" Latent Engery"
    g_fig_title   = "Idealized Heating Profile"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_in1     = addfile (g_data_path, "r")   ; note the "s" of addfile
    
    var1  = ctrl_in1->Z3(0,:,0,0)

    printVarSummary(var1)
    var1 = (/ 0.00000000 , 0.00000000 , 0.00000000, 0.00000000 , 0.00000000 , 0.00000000 , 0.00000000 , 0.00000000 ,0.00000004 , 0.00000029 , 0.00000113 , 0.00000244 , 0.00000369 , 0.00000454, 0.00000674 , 0.00000929 , 0.00000970 , 0.00000970 , 0.00001157 ,0.00000656 ,0.00000461 , 0.00000470 , 0.00000443 , 0.00000517 , 0.00000480, 0.00000599 , 0.00000604 , 0.00000012 , 0.00000000 , 0.00000000 /)
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
    
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================
    wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
    
    resxy                   = True                      ; plot mods desired
    resxy@gsnDraw           = False
    resxy@gsnFrame          = False
    ;resxy@vpHeightF  = 0.9
    ;resxy@vpWidthF = 0.4

   ; resxy@gsnXRefLine       = 0.0                       ; draw ref line
    resxy@trYReverse        = True                      ; reverse Y-axis
    resxy@xyLineThicknesses = (/2.0/)           
    resxy@xyMonoDashPattern = False
    resxy@xyDashPatterns    = (/0/)
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
    resxy@tmYLLabelFontHeightF = g_font
    resxy@tmXBLabelFontHeightF = g_font
    resxy@tiYAxisFontHeightF = g_font
    resxy@gsnLeftString = "(b) Heating Profile"
    resxy@gsnCenterString = g_fig_title
    resxy@gsnRightString="K/day"

    resxy@trXMinF =  -0.2  ; axis min
    resxy@trXMaxF =  1.2  ; axis min
    resxy@tiYAxisString = "hPa"
    ; Plot CFSR Deep Convection Heating
    resxy@gsnCenterString = ""
    resxy@xyMarkLineMode       = "MarkLines"  ; markers and lines
    resxy@xyMarkers            = (/16/)           ; filled dot
    resxy@xyMarkerSizeF        = (/0.01/)
    resxy@xyMarkerThicknessF   = (/0.4/)
    resxy@xyMarkerColors       = (/"blue","blue"/)   

    ;delete(resxy@xyLineColors)
    ;delete(resxy@xyLineThicknesses)
    ;delete(resxy@xyDashPatterns)
    ;resxy@xyDashPatterns = (/2,2/)
    resxy@xyLineColors      = (/"blue"/) 
    ;resxy@xyLineThicknesses = (/4.,4./)  

    plot_deep  = gsn_csm_xy (wks,var1*86400,var1&lev,resxy) ; create plot
   
    draw(plot_deep)
    frame(wks)

end

