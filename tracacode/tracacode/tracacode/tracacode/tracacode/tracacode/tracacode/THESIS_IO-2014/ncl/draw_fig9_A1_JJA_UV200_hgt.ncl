;Aim: draw SEN - CON (A1) Z3 and 200UV, do the significant test
;     (BIO, NIO, SIO, TIO), hgt especially 12480 drawn 
;Mission:
;   1. Read data from experiments data
;   2. Post-post process
;     2.1 Climatology 
;     2.2 Difference
;     2.3 Sig test
;   3. Draw the response map of A1 (BIO, NIO, SIO, TIO) 
;                       Zhenning Li
;                       2014-12-19
;Last Edited:
;   2014-12-19  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================


;================================================
;Variables List:
;	var1--------------U
;	var2--------------V
;	var3--------------Pr
;================================================


;global variables

   g_data_path    = "../data/"
   g_fig_name    = "../fig/fig9_A1_JJA_UV200_hgt"

	g_latS        = -40.
	g_latN        = 60. 
	g_lonL        = 0.
	g_lonR        = 360.
	g_pnew         = (/ 200.0 /) ;for sigma-p to p lvl    
	g_p0	   = 1000   ;for sigma-p to p lvl
	
   g_season       = "JJA"  
   
   g_fig_titles   = (/"BIO","NIO","SIO","TIO"/)

   g_exp_group    = "a1"
   g_exp_names    = (/"bio","nio","sio","tio"/)
	g_fig_ranks    = (/"a","b","c","d"/)

   g_font         = 0.02

   g_nsmp         = 28   
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
	ctrl_var3  = ctrl_in[:]->Z3			; p for unify the var name


;--------Below is for coordinate alternation-------------
	hbcofa	   = ctrl_in[:]->hyam(0:25)
	hbcofb	   = ctrl_in[:]->hybm(0:25)
	ctrl_psfc	   = ctrl_in[:]->PS


	


	
; ==============================================================
; Mission 2. Set the figure parameters
; ==============================================================
  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
  plot_sig = new((/4/),graphic)
  plot_S = new((/4/),graphic)
  plot_V = new((/4/),graphic)
  plot_C_ctrl = new((/4/),graphic)
  plot_C_sen = new((/4/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks1,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -30.          ; set min contour level
 res@cnMaxLevelValF        =  30.          ; set max contour level
 res@cnLevelSpacingF       =  5.          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnSpreadColorStart  = 2                ; start at color 17
  res@gsnSpreadColorEnd    = 102                ; end at color 200

  res@gsnRightString = " "
  res@gsnStringFontHeightF = g_font 

  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font          ; make labels smaller
  res@lbLabelStride = 2

  res@mpFillOn   = True;False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 

   res@mpCenterLonF = 180.
  res@mpMaxLatF  = g_latN
  res@mpMinLatF  = g_latS
;  res@mpMaxLonF  = 220.
;  res@mpMinLonF  = 20.

;  res@mpShapeMode = "FreeAspect" 

;  res@vpWidthF = 0.8
;  res@vpHeightF = 0.6

;  res@tmXBMajorOutwardLengthF = -0.
;  res@tmYLMajorOutwardLengthF = -0.
;  res@tmYRMajorOutwardLengthF = -0.
  
;  res@tmXBMinorOutwardLengthF = -0.
;  res@tmYLMinorOutwardLengthF = -0.
;  res@tmYRMinorOutwardLengthF = -0.

; now change the size of the tickmark labels
; now change the size of the tickmark labels
   res@tmXBTickSpacingF = 60
   res@tmYLTickSpacingF = 30
   ; res@tmXBLabelFontAspectF = 1.6
   res@tmXBLabelFontThicknessF = 2.0
   ; res@tmYLLabelFontAspectF = 1.3
   res@tmYLLabelFontThicknessF = 2.0
   ; res@tmYLLabelFontQuality =
   res@tmXBMajorThicknessF = 3.0
   res@tmYLMajorThicknessF = 3.0
   res@tmXBMinorThicknessF = 3.0
   res@tmYLMinorThicknessF = 3.0
   res@tmBorderThicknessF = 3.0
   res@tmXBLabelFontHeightF = g_font
   res@tmYLLabelFontHeightF = g_font
   res@gsnStringFontHeightF = g_font

;-----------------------------------------------------------------------------
     



 
; res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
; res@cnMinLevelValF        = -3.          ; set min contour level
; res@cnMaxLevelValF        =  3.          ; set max contour level
; res@cnLevelSpacingF       =  0.5          ; set contour interval
 

;----------Set res sig-----------
   res_sig                  = True       ; use plot options
   res_sig@cnFillOn         = True       ; Fill contours
   res_sig@cnLinesOn        = False;True      ; turn off contour lines
   res_sig@gsnFrame         = False
   res_sig@gsnDraw  = False
   res_sig@cnLineLabelsOn   = False      ; turn off contour line labels
   res_sig@cnLineThicknessF = 2
   res_sig@cnLineColor      = "black"
   res_sig@cnInfoLabelOn = False
   res_sig@cnMonoFillPattern    = True;False
   res_sig@cnFillPattern = 17
   res_sig@cnMonoFillScale = True
   res_sig@cnFillScaleF = 1.
   res_sig@cnMonoFillColor = True
   res_sig@cnFillColor  =  "red"
   res_sig@cnFillDotSizeF = 0.0035

   res_sig@lbLabelBarOn = False;True   ; turn off the label bar

   ;  res_sig@cnLevelSelectionMode="ExplicitLevels"
   ;  res_sig@cnLevels = (/3000,1000/)
   res_sig@gsnLeftString      = " "
   res_sig@gsnRightString      = " "



         
  vcres = True
  vcres@gsnDraw          = False           ; don't draw
  vcres@gsnFrame         = False           ; don't advance frame
  vcres@gsnRightString   = " "             ; turn off right string
  vcres@gsnLeftString    = " "             ; turn off left string
  vcres@gsnCenterString    = " "
 
  vcres@vcRefAnnoOn      = True
  vcres@vcRefAnnoOrthogonalPosF = -1             ; move ref vector up
  vcres@vcRefMagnitudeF         = 5.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017
  vcres@vcRefAnnoString1  = "5 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.01
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.001
  vcres@vcLineArrowHeadMaxSizeF   = 0.015

;--------------------------------------
;-------------------------------------------------------------------
  resC                  = True       ; use plot options
  resC@cnFillOn         = False;True       ; Fill contours
  resC@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  resC@gsnFrame         = False
  resC@gsnDraw  = False 
  resC@cnLineLabelsOn   = False      ; turn off contour line labels

  resC@cnLineThicknessF = 3
  resC@cnLineColors      = (/"black"/)
  resC@cnInfoLabelOn = False
  resC@cnMonoLineDashPattern  = False 
  resC@cnLineDashPatterns = (/1/)

  resC@cnLevelSelectionMode="ExplicitLevels"
  resC@cnLevels = (/12480/)
  resC@gsnLeftString      = " "
  resC@gsnRightString      = " "
  
  

; ==============================================================
; Mission 3. post process the data
; ==============================================================

	ctrl_var1_season = month_to_season (ctrl_var1, g_season)
	ctrl_var2_season = month_to_season (ctrl_var2, g_season)
	ctrl_var3_season = month_to_season (ctrl_var3, g_season)
	ctrl_psfc_season = month_to_season (ctrl_psfc, g_season)	


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
	ctrl_var1p_season = vinth2p(ctrl_var1_season,hbcofa,hbcofb,g_pnew,ctrl_psfc_season,interp,g_p0,1,extrap)
	ctrl_var2p_season = vinth2p(ctrl_var2_season,hbcofa,hbcofb,g_pnew,ctrl_psfc_season,interp,g_p0,1,extrap)
	ctrl_var3p_season = vinth2p(ctrl_var3_season,hbcofa,hbcofb,g_pnew,ctrl_psfc_season,interp,g_p0,1,extrap)

	ctrl_var1p = dim_avg_n_Wrap(ctrl_var1p_season(:,0,:,:),0)
	ctrl_var2p = dim_avg_n_Wrap(ctrl_var2p_season(:,0,:,:),0)
	ctrl_var3p = dim_avg_n_Wrap(ctrl_var3p_season(:,0,:,:),0)

	ctrl_var1p_var = dim_variance_n(ctrl_var1p_season(:,0,:,:),0)
	ctrl_var2p_var = dim_variance_n(ctrl_var2p_season(:,0,:,:),0)
	ctrl_var3p_var = dim_variance_n(ctrl_var3p_season(:,0,:,:),0)


      
   print("CTRL processed done!")
   
   
   do i = 0,dimsizes(g_exp_names)-1
		all_files2 = systemfunc ("ls "+g_data_path+g_exp_group+"_"+g_exp_names(i)+"/*h0.000[5-9]*.nc  "+g_data_path+g_exp_group+"_"+g_exp_names(i)+"/*h0.00[1-3]*.nc")

		setfileoption("nc","SuppressClose",False)

		exp_in      = addfiles (all_files2, "r")   ; note the "s" of addfile

		ListSetType (exp_in, "cat")             ; concatenate or "merge" (default)

;------------------Below to post process the data---------------------
		exp_var1  = exp_in[:]->U
		exp_var2  = exp_in[:]->V
		exp_var3  = exp_in[:]->Z3 

		exp_psfc  = exp_in[:]->PS

		exp_var1_season = month_to_season (exp_var1, g_season)
		exp_var2_season = month_to_season (exp_var2, g_season)
		exp_var3_season = month_to_season (exp_var3, g_season)
		exp_psfc_season = month_to_season (exp_psfc, g_season)
		


		exp_var1p_season = vinth2p(exp_var1_season,hbcofa,hbcofb,g_pnew,exp_psfc_season,interp,g_p0,1,extrap)
		exp_var2p_season = vinth2p(exp_var2_season,hbcofa,hbcofb,g_pnew,exp_psfc_season,interp,g_p0,1,extrap)
		exp_var3p_season = vinth2p(exp_var3_season,hbcofa,hbcofb,g_pnew,exp_psfc_season,interp,g_p0,1,extrap)
		
		exp_var1p=dim_avg_n_Wrap(exp_var1p_season(:,0,:,:),0)	;averages, will be 3 dims ([1]x[lat]x[lon]) for lev_p be the first 
		exp_var2p=dim_avg_n_Wrap(exp_var2p_season(:,0,:,:),0)
		exp_var3p=dim_avg_n_Wrap(exp_var3p_season(:,0,:,:),0)

		exp_var1p_var = dim_variance_n(exp_var1p_season(:,0,:,:),0)	;variances
		exp_var2p_var = dim_variance_n(exp_var2p_season(:,0,:,:),0)
		exp_var3p_var = dim_variance_n(exp_var3p_season(:,0,:,:),0)

		diff_var1 = exp_var1p
		diff_var2 = exp_var2p
		diff_var3 = exp_var3p

		diff_var1 = (exp_var1p-ctrl_var1p)
		diff_var2 = (exp_var2p-ctrl_var2p)
		diff_var3 = (exp_var3p-ctrl_var3p)		
		diff_var3_sig = diff_var3

      res@gsnLeftString = "("+g_fig_ranks(i)+")"
      res@gsnCenterString = g_fig_titles(i)
           
		if (i .eq. 0) then
			bio_var3 = diff_var3
		else
         res@gsnRightString ="R="+sprintf("%4.2f",pattern_cor(bio_var3({g_latS:g_latN},{g_lonL:g_lonR}), diff_var3({g_latS:g_latN},{g_lonL:g_lonR}), 1.0, 0))
		end if 
		;============================================================
		;Sig test
		;============================================================

		sigr = 0.05                        ; critical sig lvl for r

		iflag= False                        ; population variance similar
		prob1 = ttest(ctrl_var1p,ctrl_var1p_var,g_nsmp, exp_var1p,exp_var1p_var,g_nsmp, iflag, False) 
		prob2 = ttest(ctrl_var2p,ctrl_var2p_var,g_nsmp, exp_var2p,exp_var2p_var,g_nsmp, iflag, False)
		prob3 = ttest(ctrl_var3p,ctrl_var3p_var,g_nsmp, exp_var3p,exp_var3p_var,g_nsmp, iflag, False)
		
		diff_var1=mask(diff_var1,(prob1 .lt. sigr) .or. (prob2 .lt. sigr),True)
		diff_var3_sig=mask(diff_var3,prob3 .lt. sigr,True)
		;============================================================
		; PLOTS
		;============================================================
	
      resC@cnLineDashPatterns = (/0/)
      plot_C_ctrl(i) = gsn_csm_contour(wks,ctrl_var3p,resC)

      resC@cnLineDashPatterns = (/1/)
      plot_C_sen(i) = gsn_csm_contour(wks,exp_var3p,resC)



		
      plot_S(i) = gsn_csm_contour_map_ce(wks,diff_var3,res) ; create a default plot

		plot_V(i) = gsn_csm_vector(wks,diff_var1,diff_var2,vcres) ; dim1 = 0 for lvl = 0

		plot_sig(i) = gsn_csm_contour(wks,diff_var3_sig,res_sig)  ; Create shaded contours

		;---Overlay will transform plot_shade into data space of plot_fill

		overlay(plot_S(i),plot_sig(i))
		overlay(plot_S(i),plot_V(i))
		;overlay(plot_S(i),plot_C_ctrl(i))
		;overlay(plot_S(i),plot_C_sen(i))
      print(g_exp_names(i)+" done!")
	end do
;==============================================
; create panel
;=============================================

  	gsn_panel(wks,plot_S,(/4,1/),False)

end




