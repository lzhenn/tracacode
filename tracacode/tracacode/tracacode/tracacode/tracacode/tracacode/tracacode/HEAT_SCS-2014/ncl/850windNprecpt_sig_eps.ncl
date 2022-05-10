; ==============================================================
; eof_1.ncl
;
; Concepts illustrated:
;   - Calculating EOFs
;   - Using coordinate subscripting to read a specified geographical region
;   - Rearranging longitude data to span -180 to 180
;   - Calculating symmetric contour intervals
;   - Drawing filled bars above and below a given reference line
;   - Drawing subtitles at the top of a plot
;   - Drawing different sized plots on one page
;   - using do... end do
;
; ==============================================================
; Calculate EOFs of the Sea Level Pressure over the North Atlantic.
; ==============================================================
; The SST.mon.mean file can be downloaded from:
; http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.surface.html
; ==============================================================

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
;	var3--------------PRECC
;================================================

;ESAT ASIA
;	latS   =  -20.
;	latN   =  60. 
;	lonL   =  20.
;	lonR   =  220.
;GLOBAL
	latS   =  -20.
	latN   =  60. 
	lonL   =  0.
	lonR   =  360.



; create an array of desired pressure levels:
	pnew = (/ 850.0 /)     
	season = "JJA"
    
	lvl   = 26 ;CAM5=30, CAM4=26
    nsmp  = 25 ;Sample numbers

    ctrl_name = "HEATCTRL"
    ctrl_rundir = "ctrl_mon"    
 
	exp_names = (/"HEATING"/)
    exp_rundir = "exe"

    file_name = "HEAT_CAM4_p_g_wind850Np_JJA"
    fig_title = "HEAT-CON (CAM4)"
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.000[6-9]*.nc ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.00[1-3]*.nc")
	;all_files = systemfunc ("ls ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.000[6-9]*.nc ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.001*.nc")
	setfileoption("nc","SuppressClose",False) ; close too many files

	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

;------------------Below to change the variable---------------------	
	ctrl_var1  = ctrl_in[:]->U 
	ctrl_var2  = ctrl_in[:]->V
	ctrl_var3  = ctrl_in[:]->PRECL			; p for unify the var name
	ctrl_var4  = ctrl_in[:]->PRECC
	ctrl_var3 = (ctrl_var3+ctrl_var4)*86400*1000 		;precipt rate mm/day


;--------Below is for coordinate alternation-------------
	hbcofa	   = ctrl_in[:]->hyam(0:lvl-1)
	hbcofb	   = ctrl_in[:]->hybm(0:lvl-1)
	ctrl_psfc	   = ctrl_in[:]->PS
	p0	   = 1000


	

	ctrl_var1_season = month_to_season (ctrl_var1, season)
	ctrl_var2_season = month_to_season (ctrl_var2, season)
	ctrl_var3_season = month_to_season (ctrl_var3, season)
	ctrl_psfc_season = month_to_season (ctrl_psfc, season)	


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
	ctrl_var1p_season = vinth2p(ctrl_var1_season,hbcofa,hbcofb,pnew,ctrl_psfc_season,interp,p0,1,extrap)
	ctrl_var2p_season = vinth2p(ctrl_var2_season,hbcofa,hbcofb,pnew,ctrl_psfc_season,interp,p0,1,extrap)
	;ctrl_var3p_season = vinth2p(ctrl_var3_season,hbcofa,hbcofb,pnew2,ctrl_psfc_season,interp,p0,1,extrap)

	ctrl_var1p = dim_avg_n_Wrap(ctrl_var1p_season,0)
	ctrl_var2p = dim_avg_n_Wrap(ctrl_var2p_season,0)
	ctrl_var3p = dim_avg_n_Wrap(ctrl_var3_season,0)

	ctrl_var1p_var = dim_variance_n(ctrl_var1p_season,0)
	ctrl_var2p_var = dim_variance_n(ctrl_var2p_season,0)
	ctrl_var3p_var = dim_variance_n(ctrl_var3_season,0)


;************************************************
; plot parameters that do not change during loop
;************************************************
	wks = gsn_open_wks("eps","../fig/"+file_name)
	gsn_define_colormap(wks,"NCV_blu_red")            ; choose colormap
	gsn_reverse_colormap(wks)           ; Reverse the color map.
	gsnSpreadColors = True	
	plot = new ( 1 , graphic)
	plotV = new (1,graphic)
	plot_shade = new (1,graphic)

	pres                 = True
	;pres@tiMainString = "test"
	pres@gsnPanelLabelBar   = True		;Universial colorbar
	;pres@pmLabelBarWidthF   = 0.8	
	pres@lbBoxLineThicknessF = 0.0
	pres@lbBoxLinesOn	= False	        ;no line box in color bar
	pres@lbLabelAutoStride    = False
	pres@lbLabelStride       = 10
	pres@lbTitleString       = "precipitation rate (mm/day)"
	pres@lbLabelFontHeightF = 0.02
	pres@lbTitleFontHeightF = 0.02
	pres@pmLabelBarOrthogonalPosF = -0.03           ; move label bar down


	hres =True
	hres@gsnDraw                  = False
	hres@gsnFrame                 = False
	
	hres@gsnAddCyclic         = False        ; plotted data are not cyclic
	hres@mpFillOn             = False        ; turn off map fill
	hres@mpMinLatF            = latS         ; zoom in on map
	hres@mpMaxLatF            = latN
	hres@mpMinLonF            = lonL
	hres@mpCenterLonF         = 180.
	hres@mpMaxLonF            = lonR
	hres@cnFillOn             = True         ; turn on color fill
	hres@cnLinesOn            = False              ; turn off contour lines
	hres@cnLineLabelsOn       = False              ; turn off line labels
	;hres@gsnRightString   = "m/s & Pa/s" 

	hres@cnLevelSelectionMode     = "ManualLevels"   ; manual contour levels
	hres@cnMinLevelValF           =  -5.             ; minimum level
	hres@cnMaxLevelValF           =  5.             ; maximum level
	hres@cnLevelSpacingF          =  0.1            ; contour spacing
	hres@lbLabelBarOn        = False           ; turn off individual cb's
	

	hres@tmXBLabelStride = 2		; For global, = 2

	
	hres@tmXBLabelFontHeightF = 0.025
	hres@tmYLLabelFontHeightF = 0.025
	hres@gsnStringFontHeightF = 0.03
	hres@tiMainFontHeightF= 0.05
  	hres@tmXBMajorThicknessF = 5.0
	hres@tmYLMajorThicknessF = 5.0
	hres@tmXBMinorThicknessF = 4.0
	hres@tmYLMinorThicknessF = 4.0
	hres@tmBorderThicknessF = 4.0
	hres@mpGeophysicalLineThicknessF = 2.0	;costal line thick 4.0 fine for png
	

	hvcres                          = True

	hvcres@gsnDraw                  = False		 ; not draw yet
	hvcres@gsnFrame                = False            ; so we can draw time stamp


	hvcres@vcRefAnnoSide            = "Left"
	hvcres@vcRefAnnoOrthogonalPosF = -0.13             ; move ref vector up
	hvcres@vcRefAnnoString2On	= False		  ; no 'ref vector' string
	hvcres@vcRefMagnitudeF         = 2.0             ; define vector ref mag
	hvcres@vcRefAnnoFontHeightF    = 0.015		 ; define ref vector string font size
	hvcres@vcRefAnnoFontHeightF    = 0.02		 ; define ref vector string font size



	hvcres@vcRefLengthF            = 0.06            ; define length of vec ref
	hvcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
	hvcres@vcLineArrowThicknessF   = 2.5		  ; arrow thickness	4.5 fine for png		
	hvcres@vcMinDistanceF          = 0.02		  ; arrow distance between each other
	hvcres@vcRefAnnoString1        = "2 m/s"
	;hvcres@vcLevelSelectionMode    = "ManualLevels"
	;hvcres@vcMinMagnitudeF	       = -6e-5		 ; speed less than 0.5 will not be ploted
	;hvcres@vcLevelSpacingF	       = 6e-5
	;hvcres@vcMinMagnitudeF	       = 1e-6		 ; speed less than 0.5 will not be ploted


	;hvcres@tiMainString             = season+" WIND850 & PRECIPT "+exp_names(i)+"-CTRL"
	hvcres@gsnAddCyclic         = False        ; plotted data are not cyclic
	;hvcres@mpFillOn             = False        ; turn off map fill
	hvcres@gsnLeftString    = ""
	hvcres@gsnRightString   = "" 
	hres@gsnLeftString    = ""
	hres@gsnRightString   = "" 

	hres                          = True
	hres@gsnDraw                  = False
	hres@gsnFrame                 = False

	do i = 0,dimsizes(exp_names)-1
		all_files2 = systemfunc ("ls ../"+exp_names(i)+"/"+exp_rundir+"/*cam.h0.000[6-9]*.nc ../"+exp_names(i)+"/"+exp_rundir+"/*cam.h0.00[1-3]*.nc")
		;all_files2 = systemfunc ("ls ../"+exp_names(i)+"/"+exp_rundir+"/*cam.h0.000[6-9]*.nc ../"+exp_names(i)+"/"+exp_rundir+"/*cam.h0.001*.nc")
		setfileoption("nc","SuppressClose",False)

		exp_in      = addfiles (all_files2, "r")   ; note the "s" of addfile

		ListSetType (exp_in, "cat")             ; concatenate or "merge" (default)

;------------------Below to change the variable---------------------
		exp_var1  = exp_in[:]->U
		exp_var2  = exp_in[:]->V
		exp_var3  = exp_in[:]->PRECL 
		exp_var4  = exp_in[:]->PRECC
		exp_var3 = (exp_var3+exp_var4)*86400*1000 		;precipt rate mm/day

		exp_psfc  = exp_in[:]->PS

		exp_var1_season = month_to_season (exp_var1, season)
		exp_var2_season = month_to_season (exp_var2, season)
		exp_var3_season = month_to_season (exp_var3, season)
		exp_psfc_season = month_to_season (exp_psfc, season)
		


		exp_var1p_season = vinth2p(exp_var1_season,hbcofa,hbcofb,pnew,exp_psfc_season,interp,p0,1,extrap)
		exp_var2p_season = vinth2p(exp_var2_season,hbcofa,hbcofb,pnew,exp_psfc_season,interp,p0,1,extrap)
		;exp_var3p_season = vinth2p(exp_var3_season,hbcofa,hbcofb,pnew2,exp_psfc_season,interp,p0,1,extrap)
		
		exp_var1p=dim_avg_n_Wrap(exp_var1p_season,0)	;averages, will be 3 dims ([1]x[lat]x[lon]) for lev_p be the first 
		exp_var2p=dim_avg_n_Wrap(exp_var2p_season,0)
		exp_var3p=dim_avg_n_Wrap(exp_var3_season,0)

		exp_var1p_var = dim_variance_n(exp_var1p_season,0)	;variances
		exp_var2p_var = dim_variance_n(exp_var2p_season,0)
		exp_var3p_var = dim_variance_n(exp_var3_season,0)

		diff_var1 = exp_var1p
		diff_var2 = exp_var2p
		diff_var3 = exp_var3p	

		diff_var1 = (exp_var1p-ctrl_var1p)
		diff_var2 = (exp_var2p-ctrl_var2p)
		diff_var3 = (exp_var3p-ctrl_var3p)		
		diff_var3_sig = diff_var3

		;============================================================
		;Sig test
		;============================================================

		sigr = 0.05                        ; critical sig lvl for r

		iflag= False                        ; population variance similar
		prob1 = ttest(ctrl_var1p,ctrl_var1p_var,nsmp, exp_var1p,exp_var1p_var,nsmp, iflag, False) 
		prob2 = ttest(ctrl_var2p,ctrl_var2p_var,nsmp, exp_var2p,exp_var2p_var,nsmp, iflag, False)
		prob3 = ttest(ctrl_var3p,ctrl_var3p_var,nsmp, exp_var3p,exp_var3p_var,nsmp, iflag, False)
		
		diff_var1(0,:,:)=mask(diff_var1(0,:,:),(prob1(0,:,:) .lt. sigr) .or. (prob2(0,:,:) .lt. sigr),True)
		diff_var3_sig(:,:)=mask(diff_var3(:,:),prob3(:,:) .lt. sigr,True)
		;============================================================
		; PLOTS
		;============================================================
		

		

		;hres@tiMainString = ""
		;if i .eq. 0
		;	hres@tiMainString = "test"
		;end if
		hres@gsnCenterString    = fig_title
		;hres@gsnLeftString    = "("+fig_ranks(i)+")"

		plotV(i) = gsn_csm_vector(wks,diff_var1(0,:,:),diff_var2(0,:,:),hvcres) ; dim1 = 0 for lvl = 0


		plot(i) = gsn_csm_contour_map(wks,diff_var3(:,:),hres)	

		;---Set up resources for color-filled plot
		res			= True

		res@gsnMaximize       = True          ; maximize size in frame

		res@gsnDraw		= False		; Don't draw plots
		res@gsnFrame		= False		; Don't advance frame

		res@cnFillOn		= True		; Turn on contour fill
		res@cnLinesOn		= False		; Turn off contour lines

		;---Resources for shaded plot
		res@cnMonoFillPattern = True        ; Use multiple fill patterns
		res@cnFillPattern      = 4 
		res@cnMonoFillColor   = True         ; Use same color for shading
		res@lbLabelBarOn        = False           ; turn off individual cb's
		res@cnMonoFillScale     = True
		res@cnFillScaleF        = 0.5
		res@cnInfoLabelOn       = False
		res@cnLineLabelsOn       = False              ; turn off line labels
		;res@cnFillDotSizeF  = 0.003
		res@gsnLeftString    = ""
		res@gsnRightString    = ""
		plot_shade(i) = gsn_csm_contour(wks,diff_var3_sig(:,:),res)  ; Create shaded contours

		;---Overlay will transform plot_shade into data space of plot_fill

		overlay(plot(i),plot_shade(i))
		overlay(plot(i),plotV(i))
	end do
;==============================================
; create panel
;=============================================

	pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
  	
	gsn_panel(wks,plot,1,pres)  	
;	gsn_panel(wks,plot,(/1,2,2/),pres)

end




