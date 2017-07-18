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
    g_lonW0=87.5
 
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
    nudg_var1=nudg_in1->shum(:,ep_strt:ep_end,{g_level},:,:)
 
    ;nudg_in1     = addfile(g_nudg_datapath+"interim.41days.theta_e.nc", "r") 
    ;nudg_var2=nudg_in1->theta_e(:,ep_strt:ep_end,{g_level0},:,:)   
    
    var1=nudg_var1(:,:,{g_latS0:g_latN0},{g_lonE0:g_lonW0})
    var2=nudg_var1(:,:,{g_latS1:g_latN1},{g_lonE1:g_lonW1})
    
    ctrl_ip=ndtooned(var1)*1000 ;parcel from west
    nudg_ip=ndtooned(var2)*1000 ;parcel from east
    
    qsort(ctrl_ip)
    qsort(nudg_ip)
    y1_box = new((/2,5/),"float")
    y1_avg = new((/2/),"float")

    n_ctrl=dimsizes(ctrl_ip)
    n_nudg=dimsizes(nudg_ip)
    print(n_ctrl)
    print(n_nudg)
    y1_box(0,:) = (/ctrl_ip(floattoint(0.15*n_ctrl)),ctrl_ip(floattoint(n_ctrl/4)),ctrl_ip(floattoint(n_ctrl/2)),ctrl_ip(floattoint(3*n_ctrl/4)),ctrl_ip(floattoint(n_ctrl*0.85))/)
    y1_box(1,:) = (/nudg_ip(floattoint(0.1*n_ctrl)),nudg_ip(floattoint(n_nudg/4)),nudg_ip(floattoint(n_nudg/2)),nudg_ip(floattoint(3*n_nudg/4)),nudg_ip(floattoint(n_nudg*0.9))/)

    y1_avg(0) = avg(ctrl_ip)
    y1_avg(1) = avg(nudg_ip)
    
    ;y1_box(0,:)=y1_box(0,:)/y1_avg(0)
    ;y1_box(1,:)=y1_box(1,:)/y1_avg(0)

    x=(/-1,1/)
;********************************************************
    ; create the plot
    ;********************************************************  
    g_fig_name="../fig/obv/box-west-east-shum" 
   wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
   ;plot_box = new((/4/),graphic)


    res            = True                         ; plot mods desired
    res@tmXBLabels = (/"West Type", "East Type"/) ; labels for each box
   res@tmXBLabelFontHeightF = g_font
   res@tmYLLabelFontHeightF = g_font
   res@tiMainFontHeightF    = g_font

    ;**********************************************
    ; resources for polylines that draws the boxes
    ;**********************************************  
    llres                   = True          
    llres@gsLineThicknessF  = 5.0                 ; line thickness 
    ;**********************************************
    ; resources that control color and width of boxes
    ;**********************************************  
    opti          = True            
    opti@boxWidth = .5              ; Width of box (x units)
    opti@boxColors = (/"blue","red"/)     ; Color of box(es)
    ;***********************************************
    
    
   ;***********************************************
   ;add polymarker res
   ;***********************************************
   mres               = True                     ; marker mods desired
   mres@gsMarkerIndex = 3                        ; polymarker style
   mres@gsMarkerSizeF = 20.                      ; polymarker size
   mres@gsMarkerColor = "navy blue"                    ; polymarker color
   mres@gsMarkerThicknessF = 3.0

   ;***********************************************
   ;add refline res
   ;***********************************************

    lnres = True
    lnres@gsLineThicknessF = 3.0
    
    ;res@trYMaxF  = 285.0
    ;res@trYMinF  = 283.0
    ;siglnres@gsLineThicknessF = 3.0
    ;siglnres@gsLineDashPattern = 2
    ;siglnres@gsLineColor = "red"
    res@tiMainFontHeightF=g_font 
    res@tiMainString="SH700 Distribution (g/kg)"
   plot_box = boxplot(wks,x,y1_box,opti,res,llres) ; All 3 options used...
   dum2 = gsn_add_polymarker(wks,plot_box,x,y1_avg,mres) 

    gsn_panel(wks,plot_box,(/1,1/),False)
end
