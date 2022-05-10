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
  
    g_latN=20
    g_latS=5
    g_lonE=100
    g_lonW=87.5
    
    ;5, 12 works
    ep_strt=5
    ep_end=12

    g_level=700
    g_level0=1000

 
    g_ctrl_datapath="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl/clim/"
    g_nudg_datapath="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/nudg/clim/"
    g_ctrl_name="CLIM-Trans-2015"
    g_nudg_name="Nudging"


    ctrl_in1     = addfile(g_ctrl_datapath+g_ctrl_name+".cam.h1.ESM.75-120.theta_es.nc", "r") 
    ctrl_var1=ctrl_in1->theta_es(:,:,{g_level},:,:)
    nudg_in1     = addfile(g_nudg_datapath+g_nudg_name+".cam.h1.ESM.75-120.theta_es.nc", "r") 
    nudg_var1=nudg_in1->theta_es(:,:,{g_level},:,:)
 
    ctrl_in1     = addfile(g_ctrl_datapath+g_ctrl_name+".cam.h1.ESM.75-120.theta_e.nc", "r") 
    ctrl_var2=ctrl_in1->theta_e(:,:,{g_level0},:,:)
    nudg_in1     = addfile(g_nudg_datapath+g_nudg_name+".cam.h1.ESM.75-120.theta_e.nc", "r") 
    nudg_var2=nudg_in1->theta_e(:,:,{g_level0},:,:)   
    
    
    ctrl_var1=ctrl_var2-ctrl_var1
    nudg_var1=nudg_var2-nudg_var1
    
    ctrl_var1:=ctrl_var1(:,ep_strt:ep_end,{g_latS:g_latN},{g_lonW:g_lonE})
    nudg_var1:=nudg_var1(:,ep_strt:ep_end,{g_latS:g_latN},{g_lonW:g_lonE})
    
    ctrl_ip=ctrl_var1(0:14,0,0,0)
    nudg_ip=nudg_var1(0:14,0,0,0)
    do ii=0, 14;dimsizes(ctrl_ip)-1
        ctrl_ip(ii)=num(ctrl_var1(ii,:,:,:) .gt. 0)
        nudg_ip(ii)=num(nudg_var1(ii,:,:,:) .gt. 0)
    end do
    qsort(ctrl_ip)
    qsort(nudg_ip)
    nudg_ip(0)=nudg_ip(1)*0.5

    y1_box = new((/2,5/),"float")
    y1_avg = new((/2/),"float")
    y1_box(0,:) = (/ctrl_ip(0),ctrl_ip(3),ctrl_ip(7),ctrl_ip(11),ctrl_ip(14)/)
    y1_box(1,:) = (/nudg_ip(0),nudg_ip(3),nudg_ip(7),nudg_ip(11),nudg_ip(14)/)

    y1_avg(0) = avg(ctrl_ip)
    y1_avg(1) = avg(nudg_ip)
    x=(/-1,1/)
;********************************************************
    ; create the plot
    ;********************************************************  
    g_fig_name="../fig/nudging/box-instability" 
   wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
   ;plot_box = new((/4/),graphic)


    res            = True                         ; plot mods desired
    res@tmXBLabels = (/"CTRL", "NUDG"/) ; labels for each box
   res@tmXBLabelFontHeightF = g_font
   res@tmYLLabelFontHeightF = g_font
   res@tiMainFontHeightF    = g_font

    ;**********************************************
    ; resources for polylines that draws the boxes
    ;**********************************************  
    llres                   = True          
    llres@gsLineThicknessF  = 3.0                 ; line thickness 
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
   mres@gsMarkerThicknessF = 2.0

   ;***********************************************
   ;add refline res
   ;***********************************************

    lnres = True
    lnres@gsLineThicknessF = 3.0
    
    ;siglnres@gsLineThicknessF = 3.0
    ;siglnres@gsLineDashPattern = 2
    ;siglnres@gsLineColor = "red"
    
    res@tiMainString="Number of IP > 0 Cases"
   plot_box = boxplot(wks,x,y1_box,opti,res,llres) ; All 3 options used...
   dum2 = gsn_add_polymarker(wks,plot_box,x,y1_avg,mres) 

    gsn_panel(wks,plot_box,(/1,1/),False)
end
