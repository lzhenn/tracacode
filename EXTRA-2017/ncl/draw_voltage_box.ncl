;*************************************************************
;Aim: draw SEN - CON (A1) Monsoon Index Box Plot
;     (BIO, NIO, SIO, TIO)
;Mission:
;   1. Read data from experiments data
;   2. Post-post process
;     2.1 Climatology 
;     2.2 Difference
;     2.3 Prepare for boxplot
;   3. Draw the boxplot 
;                       Zhenning Li
;                       2014-12-21
;Last Edited:
;   2014-12-21  Create
;*************************************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin


;================================================
;Variables List:
;	var1--------------U
;	var2--------------V
;================================================

;global variables
   g_fig_name    = "../fig/voltage"
    g_font=0.02
	box = new((/5,6/),"float")
    box=(/\
        (/22.3,38.9,55.1,70.2,105.8,138.5/),\ ;top
        (/1.1,2.2,3.0,3.1,3.3,3.3/),\ ;std+
        (/18.0,34.2,50.6,66.7,100.1,132.3/),\ ;mean
        (/1.1,2.2,3.0,3.1,3.3,3.3/),\ ;std-
        (/16.1,29.4,45.2,61.7,92.9,124.7/)\ ;bottom
        /) 
    box(1,:)=box(2,:)+box(1,:)    
    box(3,:)=box(2,:)-box(3,:)    
    box_trans=transpose(box)
	;********************************************************
	; create the plot
	;********************************************************   
   wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
   ;plot_box = new((/4/),graphic)


	res            = True                         ; plot mods desired
;	res@tmXBLabels = labels ; labels for each box
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
	opti@boxWidth = 2.				; Width of box (x units)
	opti@boxColors = (/"black","blue","red","orange","purple","green"/)  	; Color of box(es)
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
	
    x = (/5., 10., 15., 20., 30., 40./)	
	res@tiMainString = "Diameter & Voltage"
	plot_box = boxplot(wks,x,box_trans,opti,res,llres)	; All 3 options used...
	;dum1 = gsn_add_polyline(wks,plot_box,(/-3.,3./),(/0,0/),lnres)	
;    dum2 = gsn_add_polymarker(wks,plot_box,x,wyi_avg,mres) 

  	gsn_panel(wks,plot_box,(/1,1/),False)
end




