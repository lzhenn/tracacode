;*************************************************************
;Aim: draw PRECC annually ltm trend 
;Mission:
;   1. Read data
;   2. Post-post process
;     2.1 take the trend 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-05-03
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN
;   2015-05-03  Change to caculate season trend 
;   2015-06-20  Change to caculate timeseries
;   2015-06-22  Change to fit multi-data 2 region timeseries
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------PRECC
;================================================
;global variables
    ;Define parameters

g_data1_path ="../../data/obv/PRECT/precip.pentad.mean.nc"
g_latS2=5
g_latN2=15
g_lonW2=87.5
g_lonE2=97.5
ctrl_in1 = addfile(g_data1_path, "r")
time_hist    = ctrl_in1->time
yyyymm  = cd_calendar(time_hist,-1)
var1  = ctrl_in1->precip(:38*73-1,{g_latS2:g_latN2},{g_lonW2:g_lonE2})

var1_dim = dimsizes(var1) 
var1_4d  = reshape(var1,(/38,73,var1_dim(1),var1_dim(2)/))
var1_4d2 = var1_4d
;printVarSummary(var1_pt_data_reshape)

var1_4d2!0="year" 
var1_4d2!1="pentad"
var1_4d2!2="lat"
var1_4d2!3="lon"
var1_4d2&pentad=ispan(1,73,1)
var1_4d2&lat=var1&lat
var1_4d2&lon=var1&lon

var1_ts_1998=wgt_areaave_Wrap(var1_4d2(1998-1979,19:27,:,:),1.0,1.0,0)
var1_ts_1999=wgt_areaave_Wrap(var1_4d2(1999-1979,19:27,:,:),1.0,1.0,0)
var1_clim_ts=wgt_areaave_Wrap(dim_avg_n_Wrap(var1_4d2(:,19:27,:,:),0),1.0,1.0,0)



;*********************************
; create plot
;********************************
 wks   = gsn_open_wks ("eps", "../../fig/FINAL/FIG2c_bar-case-ts" )  ; send graphics to PNG file
 g_font = 0.025
 res   = True
; res@gsnScale = True               
 res@gsnFrame= False
 res@gsnDraw= False
; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

; res@vpXF      = 0.10        ; In page coordinates, where to start
; res@vpYF      = 0.75        ; the plot
 res@vpHeightF = 0.5        ; Changes the aspect ratio
 res@vpWidthF  = 0.8
 res@gsnMaximize = True

 res@trXMinF   = 0        ; min value on y-axis
 res@trXMaxF   =  10        ; max value on y-axis
 res@trYMinF   = 0        ; min value on y-axis
 res@trYMaxF   = 22.0        ; max value on y-axis

 res@tiYAxisString = "" ; y-axis label      
 res@tiXAxisString = ""
; res@tiMainString  = "Std U200 & Pr Expansion Coefficient" ; title

 res@tmXBMajorOutwardLengthF=0
 res@tmXBMajorLengthF=0.01
 res@tmYLMinorOn=False
 res@tmYLMajorOutwardLengthF=0
 res@tmYLMajorLengthF=0.01
 res@gsnYRefLine           = 0.              ; reference line   
 res@gsnXYBarChart         = True            ; create bar chart 
 ;res@gsnAboveYRefLineColor = "red"           ; above ref line fill red
; res@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue
 res@tmXBMode              = "Explicit"         ; explicit labels
 res@tmXBValues            = ispan(1,9,1)
 res@tmXBLabels            = ispan(20,28,1)
; res@tmYLMode              = "Explicit"
; res@tmYLValues            = fspan(-3.0,3.0,5)
; res@tmYLLabels            = fspan(-3.0,3.0,5)
 
  res@tmYLLabelFontHeightF = g_font
  res@tmXBLabelFontHeightF = g_font
  res@gsnStringFontHeightF = g_font
 res@gsnLeftString = "(c)" 
; res@gsnRightString = "R=0.78" 
 res@gsnCenterString = "1998/1999/Clim Pr around the Onsets" 
 res@gsnXYBarChartBarWidth = 0.25
 res@gsnXYBarChartColors = (/"red"/)   
 plot = gsn_csm_xy (wks,fspan(0.75,8.75,9),var1_ts_1998,res) 
 
 res@gsnXYBarChartColors = (/"darkgreen"/)                  ; but tweaking where
 plot1 = gsn_csm_xy(wks,fspan(1,9,9),var1_clim_ts,res)        ; Western


 res@gsnXYBarChartColors = (/"blue"/)                  ; but tweaking where
 plot2 = gsn_csm_xy(wks,fspan(1.25,9.25,9),var1_ts_1999,res)        ; Western

overlay(plot,plot1)
overlay(plot,plot2)
  ;*****************************************************   
    ; Manually create and attach legend
    ;***************************************************** 
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.025                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 30.                    ; line thicker
    res_lines@gsLineColor       = "red"                 ; line color
    
    xx = (/1.0,1.2/) 
    yy = (/18,18/)
    dum1 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum2 = gsn_add_text(wks,plot,"1998",xx(1)+0.25,yy(0),res_text); add text

    res_lines@gsLineColor       = "darkgreen"                 ; line color
    yy = yy -2
    dum3 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum4 = gsn_add_text(wks,plot,"Clim",xx(1)+0.25,yy(0),res_text); add text


    res_lines@gsLineColor       = "blue"                 ; line color
    yy = yy -2
    dum43 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum44 = gsn_add_text(wks,plot,"1999",xx(1)+0.25,yy(0),res_text); add text

   draw(plot)
   frame(wks)
end


