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
   g_fig_name    = "../fig/pH"
    g_font=0.02
	box = new((/5,5/),"float")
    box=(/\
        (/243,280,324,366,379/),\ ;top
        (/32,34,47,45,51/),\ ;std+
        (/198,243,267,284,295/),\ ;mean
        (/32,34,47,45,51/),\ ;std+
        (/138,171,190,239,224/)\ ;bottom
        /) 
    box(1,:)=box(2,:)+box(1,:)    
    box(3,:)=box(2,:)-box(3,:)    
    box_trans=transpose(box)
    




   
    ;********************************************************
	; create the plot
	;********************************************************   
   wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
   ;plot_box = new((/4/),graphic)

    labels=(/"2.0","2.5","3.0","3.5","4.0"/)
	res            = True                         ; plot mods desired
	res@tmXBLabels = labels ; labels for each box
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
	opti@boxColors = (/"black","blue","yellow","green","red"/)  	; Color of box(es)
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
	lnres@gsLineDashPattern=1
	
	;siglnres@gsLineThicknessF = 3.0
	;siglnres@gsLineDashPattern = 2
	;siglnres@gsLineColor = "red"
	
    x = (/20,25,30,35,40/)	
	res@tiMainString = "Length & pH"
	plot_box = boxplot(wks,x,box_trans,opti,res,llres)	; All 3 options used...
	dum1 = gsn_add_polyline(wks,plot_box,x,box_trans(:,2),lnres)	

  	gsn_panel(wks,plot_box,(/1,1/),False)
end




