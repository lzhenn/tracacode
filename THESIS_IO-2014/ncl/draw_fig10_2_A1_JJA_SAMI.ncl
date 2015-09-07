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
load "~/L_Zealot/LIB/ncl/shea_util2.ncl"
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================


;================================================
;Variables List:
;	var1--------------U
;	var2--------------V
;================================================

;global variables
   g_data_path    = "../data/"
   g_fig_name    = "../fig/fig10_A1_JJA_SAMI"

; create an array of desired pressure levels:
	g_pnew = (/ 200.0, 850.0 /)     
	g_p0	   = 1000   ;for sigma-p to p lvl
	
   g_season       = "JJA"  
   
   g_fig_titles   = (/"BIO","NIO","SIO","TIO"/)
   g_exp_group    = "a1"
   g_exp_names    = (/"bio","nio","sio","tio"/)
	g_fig_ranks    = (/"a","b","c","d"/)

   g_font         = 0.03
   
   g_nsmp         = 28   

   g_nexps        = dimsizes(g_exp_names)	
	
   
; ==============================================================
; Mission 1. Open the file: Read data and merge metadata 
; ==============================================================
   
   all_files = systemfunc ("ls "+g_data_path+"ctrl/*h0.000[5-9]*.nc  "+g_data_path+"ctrl/*h0.00[1-3]*.nc")
	
	setfileoption("nc","SuppressClose",False) ; close too many files

	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

;------------------Below to change the variable---------------------	
	ctrl_var1  = ctrl_in[:]->U 
	ctrl_var2  = ctrl_in[:]->V


; ==============================================================
; Mission 2. Post process CTRL datasets
; ==============================================================

;--------Below is for coordinate alternation-------------
	hbcofa	   = ctrl_in[:]->hyam(0:25)
	hbcofb	   = ctrl_in[:]->hybm(0:25)
	ctrl_psfc	   = ctrl_in[:]->PS

	wyi = new((/g_nexps+1,g_nsmp/),"float")
	sami = new((/g_nexps+1,g_nsmp/),"float")
	seami = new((/g_nexps+1,g_nsmp/),"float")
	eami = new((/g_nexps+1,g_nsmp/),"float")
	y1_box = new((/g_nexps+1,5/),"float")
	y2_box = new((/g_nexps+1,5/),"float")
	y3_box = new((/g_nexps+1,5/),"float")
	y4_box = new((/g_nexps+1,5/),"float")

	ctrl_var1_season = month_to_season (ctrl_var1,g_season)
	ctrl_var2_season = month_to_season (ctrl_var2,g_season)
	ctrl_psfc_season = month_to_season (ctrl_psfc, g_season)	
;************************************************
; define other arguments required by vinth2p
;************************************************
; type of interpolation: 1 = linear, 2 = log, 3 = loglog
	interp = 2 

; is extrapolation desired if data is outside the range of PS
	extrap = False
      
	ctrl_var1p = vinth2p(ctrl_var1_season,hbcofa,hbcofb,g_pnew,ctrl_psfc_season,interp,g_p0,1,extrap)
	ctrl_var2p = vinth2p(ctrl_var2_season,hbcofa,hbcofb,g_pnew,ctrl_psfc_season,interp,g_p0,1,extrap)
	;printVarSummary(ctrl_var1p)

;Caculate WY Index
	wy_umean = wgt_areaave_Wrap(ctrl_var1p(:,:,{5:20},{40:110}),1.0,1.0,0)
	wyi(0,:)=wy_umean(:,1)-wy_umean(:,0) ;wyi(0) for ctrl; wy_umean[time]x[lvl]
;Caculate SAM Index
	sam_vmean = wgt_areaave_Wrap(ctrl_var2p(:,:,{10:30},{70:110}),1.0,1.0,0)
	sami(0,:)=sam_vmean(:,1)-sam_vmean(:,0)
;Caculate SEAM Index
	seam_umean1 = wgt_areaave_Wrap(ctrl_var1p(:,:,{5:15},{90:130}),1.0,1.0,0)
	seam_umean2 = wgt_areaave_Wrap(ctrl_var1p(:,:,{22.5:32.5},{110:140}),1.0,1.0,0)
	seami(0,:)=seam_umean1(:,1)-seam_umean2(:,1)
;Caculate EAM Index
	eam_umean1 = wgt_areaave_Wrap(ctrl_var1p(:,:,{25:35},{110:150}),1.0,1.0,0)
	eam_umean2 = wgt_areaave_Wrap(ctrl_var1p(:,:,{40:50},{110:150}),1.0,1.0,0)
	eami(0,:)=-(eam_umean1(:,0)-eam_umean2(:,0))
   print("CTRL done!")
	
; ==============================================================
; Now for the exps
; ==============================================================
   
  
   
   do i = 0,g_nexps-1
	   all_files2 = systemfunc ("ls "+g_data_path+g_exp_group+"_"+g_exp_names(i)+"/*h0.000[5-9]*.nc  "+g_data_path+g_exp_group+"_"+g_exp_names(i)+"/*h0.00[1-3]*.nc")

		setfileoption("nc","SuppressClose",False)

		exp_in      = addfiles (all_files2, "r")   ; note the "s" of addfile

		ListSetType (exp_in, "cat")             ; concatenate or "merge" (default)

		;------------------Below to change the variable---------------------	
		exp_var1  = exp_in[:]->U 
		exp_var2  = exp_in[:]->V


	;--------Below is for coordinate alternation-------------
		hbcofa	   = exp_in[:]->hyam(0:25)
		hbcofb	   = exp_in[:]->hybm(0:25)
		exp_psfc  = exp_in[:]->PS


	

		exp_var1_season = month_to_season (exp_var1, g_season)
		exp_var2_season = month_to_season (exp_var2, g_season)
		exp_psfc_season = month_to_season (exp_psfc, g_season)	
	;************************************************
	; define other arguments required by vinth2p
	;************************************************
	; type of interpolation: 1 = linear, 2 = log, 3 = loglog
		interp = 2 

	; is extrapolation desired if data is outside the range of PS
		extrap = False

	      
	;************************************************
	; calculate T on pressure levels
	;************************************************
	; note, the 7th argument is not used, and so is set to 1.
	;************************************************
		exp_var1p = vinth2p(exp_var1_season,hbcofa,hbcofb,g_pnew,exp_psfc_season,interp,g_p0,1,extrap)
		exp_var2p = vinth2p(exp_var2_season,hbcofa,hbcofb,g_pnew,exp_psfc_season,interp,g_p0,1,extrap)
		;printVarSummary(exp_var1p)

	;Caculate WY Index
		wy_umean = wgt_areaave_Wrap(exp_var1p(:,:,{5:20},{40:110}),1.0,1.0,0)
		wyi(i+1,:)=wy_umean(:,1)-wy_umean(:,0)
	;Caculate SAM Index
		sam_vmean = wgt_areaave_Wrap(exp_var2p(:,:,{10:30},{70:110}),1.0,1.0,0)
		sami(i+1,:)=sam_vmean(:,1)-sam_vmean(:,0)
	;Caculate SEAM Index
		seam_umean1 = wgt_areaave_Wrap(exp_var1p(:,:,{5:15},{90:130}),1.0,1.0,0)
		seam_umean2 = wgt_areaave_Wrap(exp_var1p(:,:,{22.5:32.5},{110:140}),1.0,1.0,0)
		seami(i+1,:)=seam_umean1(:,1)-seam_umean2(:,1)
	;Caculate EAM Index
		eam_umean1 = wgt_areaave_Wrap(exp_var1p(:,:,{25:35},{110:150}),1.0,1.0,0)
		eam_umean2 = wgt_areaave_Wrap(exp_var1p(:,:,{40:50},{110:150}),1.0,1.0,0)
		eami(i+1,:)=-(eam_umean1(:,0)-eam_umean2(:,0))
	end do

; ==============================================================
; Mission 3. Prepare the figure data
; ==============================================================

	labels    = (/"CTRL","BIO","NIO","SIO","TIO"/)	
	x = (/-2., -1., 0., 1., 2./)
	wyi_avg = dim_avg_n_Wrap(wyi,1) ;each exp avg
	wyi = wyi - wyi_avg(0)	; wyi rm CTRL avg
	wyi_avg = wyi_avg - wyi_avg(0) ;each exp avg rm CTRL avg	
	do i = 0,dimsizes(labels)-1
		qsort(wyi(i,:))
	end do
	y1_box(:,0) = wyi(:,0)
	y1_box(:,1) = wyi(:,7)
	y1_box(:,2) = (wyi(:,13)+wyi(:,14))/2
	y1_box(:,3) = wyi(:,21)
	y1_box(:,4) = wyi(:,27)


	sami_avg = dim_avg_n_Wrap(sami,1)
	sami = sami - sami_avg(0)	
	sami_avg = sami_avg - sami_avg(0)	
	do i = 0,dimsizes(labels)-1
		qsort(sami(i,:))
	end do
	y2_box(:,0) = sami(:,0)
	y2_box(:,1) = sami(:,7)
	y2_box(:,2) = (sami(:,13)+sami(:,14))/2
	y2_box(:,3) = sami(:,21)
	y2_box(:,4) = sami(:,27)
	

	seami_avg = dim_avg_n_Wrap(seami,1)
	seami = seami - seami_avg(0)	
	seami_avg = seami_avg - seami_avg(0)	
	do i = 0,dimsizes(labels)-1
		qsort(seami(i,:))
	end do
	y3_box(:,0) = seami(:,0)
	y3_box(:,1) = seami(:,7)
	y3_box(:,2) = (seami(:,13)+seami(:,14))/2
	y3_box(:,3) = seami(:,21)
	y3_box(:,4) = seami(:,27)

	eami_avg = dim_avg_n_Wrap(eami,1)
	eami = eami - eami_avg(0)	
	eami_avg = eami_avg - eami_avg(0)	
	do i = 0,dimsizes(labels)-1
		qsort(eami(i,:))
	end do
	y4_box(:,0) = eami(:,0)
	y4_box(:,1) = eami(:,7)
	y4_box(:,2) = (eami(:,13)+eami(:,14))/2
	y4_box(:,3) = eami(:,21)
	y4_box(:,4) = eami(:,27)
	;********************************************************
	; create the plot
	;********************************************************   
   wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
   ;plot_box = new((/4/),graphic)


	res            = True                         ; plot mods desired
	res@tmXBLabels = labels ; labels for each box
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
	opti@boxWidth = .5				; Width of box (x units)
	opti@boxColors = (/"black","blue","red","orange","purple"/)  	; Color of box(es)
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
	
	
	res@tiMainString = "(b) JJA SAM Index"
	plot_box = boxplot(wks,x,y2_box,opti,res,llres)	; All 3 options used...
	dum1 = gsn_add_polyline(wks,plot_box,(/-3.,3./),(/0,0/),lnres)	
   dum2 = gsn_add_polymarker(wks,plot_box,x,sami_avg,mres) 

  	gsn_panel(wks,plot_box,(/1,1/),False)
exit
	re@tiMainString = "(b) JJA SAM Index"
	plot_box(1) = boxplot(wks,x,y2_box,opti,res,llres)	; All 3 options used...
	gsn_polyline(wks,plot_box(1),(/ -5.,7. /),(/0,0/),lnres)	
   gsn_polymarker(wks,plot_box(1),x,sami_avg,mres) 
	
	res@tiMainString = "(c) JJA SEAM Index"
	plot_box(2) = boxplot(wks,x,y3_box,opti,res,llres)	; All 3 options used...
	gsn_polyline(wks,plot_box(2),(/ -5.,7. /),(/0,0/),lnres)	
   gsn_polymarker(wks,plot_box(2),x,seami_avg,mres) 
	
	res@tiMainString = "(d) JJA EAM Index"
	plot_box(3) = boxplot(wks,x,y4_box,opti,res,llres)	; All 3 options used...
	gsn_polyline(wks,plot_box(3),(/ -5.,7. /),(/0,0/),lnres)	
   gsn_polymarker(wks,plot_box(3),x,eami_avg,mres) 
	
  	gsn_panel(wks,plot_box,(/2,2/),False)
   draw(wks)                                     ; box plot does not call
	frame(wks)                                    ; these for you

end




