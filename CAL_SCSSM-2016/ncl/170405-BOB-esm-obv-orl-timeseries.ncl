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

begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = "FLUT"
    g_data3_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl"

    g_font = 0.025
    
    ;Andaman Sea convection
    g_latS=5.
    g_latN=20.
    g_lonW=87.5
    g_lonE=100.

    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/model-esm-olr"
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)"/)
    g_fig_title   = "Obv: 1979-2012 vs Sim: 50 esm members"

    npos_year = 0
    nneg_year = 0

;Prepare the variables
    ctrl_in_files = systemfunc("ls "+g_data3_path+"/*"+g_var_name+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in     = addfiles (ctrl_in_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "join")
    var  =ctrl_in[:]->$g_var_name$
    var_areamean=wgt_areaave_Wrap(var(:,1:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    
    ;Read NOAA OLR
    var_obv=read_noaa_olr_daily_2D(0,180,g_latS,g_latN,g_lonW,g_lonE,"/Users/zhenningli/data/obv/NOAA-OLR/olr.day.mean.f10.nc")
    var_obv_areamean=wgt_areaave_Wrap(var_obv(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)

    var_mean=dim_avg_n_Wrap(var_areamean,0)  
    var_obv_mean=dim_avg_n_Wrap(var_obv_areamean,0)  
 

    var_areamean=runave_n_Wrap(var_areamean,5,0,1)  
    var_obv_areamean=runave_n_Wrap(var_obv_areamean,5,0,1)  
 
    ;************************************************
    ; plotting parameters
    ;************************************************
    
    wks = gsn_open_wks ("png",g_fig_name) ; open workstation
    plot = new((/2/),graphic)
    plot_obv = new((/2/),graphic)
    
    res               = True                    ; plot mods desired
    res@gsnDraw                = False
    res@gsnFrame                = False
    
    res@vpXF     = 0.2
    res@vpYF     = 0.85

    res@vpWidthF = 0.7
    res@vpHeightF= 0.5

    res@trYMinF            =  160.0               ; min value on y-axis
    res@trYMaxF            =  310.0               ; max value on y-axis
;    res@trXMinF            =  27.5                  ; min value on x-axis
;    res@trXMaxF            =  30.0                  ; max value on x-axis


    ;---Set some marker resources
 
    res@tmYLLabelFontHeightF = g_font
    res@tmXBLabelFontHeightF = g_font
    res@gsnStringFontHeightF = g_font
    res@tiXAxisFontHeightF   = g_font
    res@tiYAxisFontHeightF   = g_font
    res@gsnLeftString     = g_fig_title    
    res@tiYAxisString     = "OLR"
    res@tiXAxisString = "Day"

    res@xyMarkLineMode     = "Lines"
    res@xyLineColor       = "lightpink" ; colors chosen
    res@xyLineThicknesses    = 1.0      ; line thicknesses
    res@xyDashPattern=0.
;    res@tmXBValues = ispan(0,180,1) ;interval
;    res@tmXBLabels = ispan(0,180,30) ;tick label
        
;    res@trXMinF            = 1           ; X axis limits
    res@trXMaxF            = 180           ; X axis limits

    plot(0) = gsn_csm_xy (wks,ispan(60,180,1),var_areamean(:,59:),res) ; create plot
    res@xyLineColor       = "lightskyblue" ; colors chosen
    plot_obv(0)=gsn_csm_xy (wks,ispan(60,180,1),var_obv_areamean(:,59:),res) ; create plot

    res@xyLineColor       = "red" ; colors chosen
    res@xyLineThicknesses    = 4.0      ; line thicknesses

  
    plot(1) = gsn_csm_xy (wks,ispan(60,180,1),var_mean(59:),res) ; create plot
    res@xyLineColor       = "blue" ; colors chosen
    plot_obv(1) = gsn_csm_xy (wks,ispan(60,180,1),var_obv_mean(59:),res) ; create plot
  
      res_lines=True
      res_lines@gsLineColor       = "black"
      res_lines@gsLineDashPattern = 2.
      xx = (/60,180/)
      yy = (/235.,235./)
      dum7 = gsn_add_polyline(wks,plot(1),xx,yy,res_lines)              ; add polyline

     
    overlay(plot(0),plot_obv(0))
    overlay(plot(0),plot_obv(1))
    overlay(plot(0),plot(1))
    
    draw(plot(0))
    frame(wks)
end
