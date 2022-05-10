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
load "$NCL_SELFLIB/file_io.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = (/"U","V","T"/)
    ;g_var_name = (/"uwnd","vwnd","air"/)
    g_font = 0.02
  
    ;BOB Early
    ;g_comp="early"
    ;g_special_year=(/1984, 1990, 1999, 2000, 2006, 2009/)-1979
    ;g_nsp_years=dimsizes(g_special_year)
   
    ;BOB Late
    g_comp="late"
    g_special_year=(/1980, 1981, 1982, 1983, 1985, 1992, 1993, 1997, 1998, 2010/)-1979
    g_day_rank=(/136, 133, 134, 143, 136, 132, 134, 133, 132, 134/)
    g_nsp_years=dimsizes(g_special_year)

    ;West guys
    g_latN0=17.5
    g_latS0=10
    g_lonE0=95
    g_lonW0=85.5
 
    ;East guys
    g_latN1=7.5
    g_latS1=9.5
    g_lonE1=100
    g_lonW1=87.5
    
    ;5, 12 works
    ep_strt=18
    ep_end=19

    g_level=700
    g_level0=1000

 
    g_ctrl_datapath="/Users/zhenningli/data/CAL_SCSSM-2016/ERA-clim/"
    g_nudg_datapath="/Users/zhenningli/data/CAL_SCSSM-2016/ERA-clim/"


    nudg_in1     = addfile(g_nudg_datapath+"interim.41days.shum.nc", "r") 
    nudg_var1=nudg_in1->shum(:,ep_strt:ep_end,{1000:500},:,:)
 
    ;nudg_in1     = addfile(g_nudg_datapath+"interim.41days.theta_e.nc", "r") 
    ;nudg_var2=nudg_in1->theta_e(:,ep_strt:ep_end,{g_level0},:,:)   
    
    var1=nudg_var1(:,:,:,{g_latS0:g_latN0},{g_lonE0:g_lonW0})
    var2=nudg_var1(:,:,:,{g_latS1:g_latN1},{g_lonE1:g_lonW1})
    
     

    var1:=dim_avg_Wrap(var1)
    var1:=dim_avg_Wrap(var1)
  
 
    dim_var1=dimsizes(var1)
    var1_for_std=reshape(var1,(/dim_var1(0)*dim_var1(1),dim_var1(2)/))
    std_var1=dim_stddev_n_Wrap(var1_for_std,0)


    
    var1:=dim_avg_n_Wrap(var1,0)
    var1:=dim_avg_n_Wrap(var1,0)
 
    var2:=dim_avg_Wrap(var2)
    var2:=dim_avg_Wrap(var2)
   
    dim_var2=dimsizes(var2)
    printVarSummary(var2)
    var2_for_std=reshape(var2,(/dim_var2(0)*dim_var2(1),dim_var2(2)/))
    std_var2=dim_stddev_n_Wrap(var2_for_std,0)
    
    var2:=dim_avg_n_Wrap(var2,0)
    var2:=dim_avg_n_Wrap(var2,0) 
 
    var1=var1*1000 
    var2=var2*1000 

    std_var1=std_var1*1000 
    std_var2=std_var2*1000 
    
    print(std_var1)
    print(std_var2)

    print(var1)
    print(var2)
    
    ;********************************************************
    ; create the plot
    ;********************************************************  
    g_fig_name="../fig/Q-profile"

    wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
    
    resxy                   = True                      ; plot mods desired
    resxy@gsnDraw           = False
    resxy@gsnFrame          = False


   ; resxy@gsnXRefLine       = 0.0                       ; draw ref line
    resxy@trYReverse        = True                      ; reverse Y-axis
    resxy@xyLineThicknesses=  3.0          
    resxy@xyLineColor      = "red"          ; change line colors
    resxy@xyMonoDashPattern = False
    resxy@xyDashPattern    = 0
    resxy@trYMinF           = 500.0
    resxy@trYMaxF           = 1000.0
    resxy@tiXAxisString = "Specific Humidity (g/kg)"

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


    resxy@trXMinF =  0.  ; axis min
    resxy@trXMaxF =  20.  ; axis min

    ;resxy@xyMarkLineMode       = "MarkLines"  ; markers and lines
    ;resxy@xyMarkers            = (/16,16/)           ; filled dot
    ;resxy@xyMarkerSizeF        = (/0.01,0.01/)
    ;resxy@xyMarkerThicknessF   = (/0.6,0.6/)
    ;resxy@xyMarkerColors       = (/"blue","red"/)   


    ; Plot 
    plot  = gsn_csm_xy (wks,var1,var1&level,resxy) ; create plot
    resxy@xyLineColor      = "blue"          ; change line colors
 
    plot_deep  = gsn_csm_xy (wks,var2,var2&level,resxy) ; create plot






    overlay(plot,plot_deep)


    var1_range=new((/2,dimsizes(var1)/),"float")
    var1_range(0,:)=var1+std_var1
    var1_range(1,:)=var1-std_var1

    var2_range=new((/2,dimsizes(var2)/),"float")
    var2_range(0,:)=var2+std_var2
    var2_range(1,:)=var2-std_var2


    ; Create a plot with the area between both curves filled in blue.
      resxy@gsnXYFillOpacities = 0.4
      resxy@gsnXYFillColors = "OrangeRed"
      resxy@xyLineColor     = -1                           ; We don't want the line, so make it transparent.
      bot_plot  = gsn_csm_xy (wks,var1_range,var1&level,resxy)  ; Create filled XY plot.

      resxy@gsnXYFillColors = "DeepSkyBlue"
      bot_plot1  = gsn_csm_xy (wks,var2_range,var2&level,resxy)  ; Create filled XY plot.
      
      overlay(plot,bot_plot)
      overlay(plot,bot_plot1)









    ;--------------------------------------------------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 3.                    ; line thicker

        res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    res_lines@gsLineColor       = "blue"
    yy = (/600.,600./)
    xx = (/9.0,12.0/)
    text_pos = 12.5
    dum5 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum6 = gsn_add_text(wks,plot,"Eastern Parcels",text_pos,yy(0),res_text); add text

    res_lines@gsLineColor       = "red"
    res_lines@gsLineDashPattern = 0.
    yy = (/650.,650./)
    dum7 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum8 = gsn_add_text(wks,plot,"Western Parcels",text_pos,yy(0),res_text); add text
 
;    overlay(plot,plot_diab)
  draw(plot)
    frame(wks)
   
  end
