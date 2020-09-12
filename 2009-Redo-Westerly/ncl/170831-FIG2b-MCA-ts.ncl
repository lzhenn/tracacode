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

at=(/0.03228732,-0.5854005,-0.3189126,-0.4756549,-1.40374,0.672407,1.227705,-0.3949893,-0.764492,0.2948529,-0.443841,-0.4704959,0.1041491,-1.280664,-1.36502,0.6402611,-0.1767203,0.9950252,-1.364929,-1.494223,1.998805,1.105038,0.929267,-0.3316015,-0.5130765,0.4823737,-0.708145,0.8268099,1.438142,2.477953,1.503865,-1.021818,0.1954353,0.5981882,-0.3374167,-0.8471315,-1.22429/)
bt=-(/-0.1077477,-0.1547463,1.059095,0.3402986,0.5959153,-0.6909541,-0.2853744,0.6870129,0.4159035,0.4083785,-0.4535643,-0.09637183,-1.153469,1.648252,0.9074267,-0.6140218,0.617864,-0.7622402,2.128705,2.379346,-2.37599,-1.72639,-0.70748,-0.4116242,0.1685555,-0.1346763,1.623254,-0.5893829,-0.4145629,-1.148684,-1.40665,0.7642842,-0.2144959,-0.4886607,0.6820332,0.0149679,-0.5042045/)
years=ispan(1979,2015,1)

;*********************************
; create plot
;********************************
 wks   = gsn_open_wks ("png", "../../fig/FINAL/FIG2b_bar-mca-ts" )  ; send graphics to PNG file
 g_font = 0.02
 res   = True
; res@gsnScale = True               
 res@gsnFrame= False
 res@gsnDraw= False
; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

; res@vpXF      = 0.10        ; In page coordinates, where to start
; res@vpYF      = 0.75        ; the plot
 res@vpHeightF = 0.25        ; Changes the aspect ratio
 res@vpWidthF  = 0.9
 res@gsnMaximize = True

 res@trXMinF   = 0        ; min value on y-axis
 res@trXMaxF   =  38        ; max value on y-axis
 res@trYMinF   = -3.0        ; min value on y-axis
 res@trYMaxF   =  3.0        ; max value on y-axis

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
 res@tmXBValues            = ispan(2,37,10)
 res@tmXBLabels            = ispan(1980,2015,10)
 res@tmYLMode              = "Explicit"
 res@tmYLValues            = fspan(-3.0,3.0,5)
 res@tmYLLabels            = fspan(-3.0,3.0,5)
 
  res@tmYLLabelFontHeightF = g_font
  res@tmXBLabelFontHeightF = g_font
  res@gsnStringFontHeightF = g_font
 res@gsnLeftString = "(b)" 
 res@gsnRightString = "R=0.78" 
 res@gsnCenterString = "U200 & Pr Expansion Coefficients" 
 res@gsnXYBarChartBarWidth = 0.4
 res@gsnXYBarChartColors = (/"red"/)   
 plot = gsn_csm_xy (wks,fspan(0.8,36.8,37),at,res) 
 res@gsnXYBarChartColors = (/"blue"/)                  ; but tweaking where
 plot1 = gsn_csm_xy(wks,fspan(1.2,37.2,37),bt,res)        ; Western

overlay(plot,plot1)
  ;*****************************************************   
    ; Manually create and attach legend
    ;***************************************************** 
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.018                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 18.                    ; line thicker
    res_lines@gsLineColor       = "red"                 ; line color
    
    xx = (/2.0,3.0/) 
    yy = (/2.3,2.3/)
    dum1 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum2 = gsn_add_text(wks,plot,"Pr",xx(1)+0.5,yy(0),res_text); add text

    res_lines@gsLineColor       = "blue"                 ; line color
    yy = yy -0.8
    dum3 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum4 = gsn_add_text(wks,plot,"U200",xx(1)+0.5,yy(0),res_text); add text

   draw(plot)
   frame(wks)
end


