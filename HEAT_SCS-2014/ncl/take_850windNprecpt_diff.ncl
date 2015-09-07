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
;	var3--------------Omega
;================================================

	latS   =  -60.
	latN   =  60. 
	;lonL   =  30.
	;lonR   =  180.
	case_len = 25
	case_x = 144
	case_y = 96
	pver = 26

; create an array of desired pressure levels:
	pnew = (/ 850.0 /)     
	fig_ranks    = (/"a","b","c","d","e"/)
	mon_name =(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
	exp_names = (/"HEATING"/)
	title_names=(/"HEAT (SCS_in) - CTRL"/)
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-9]*.nc ../HEATCTRL/ctrl_mon/*cam.h0.00[1-3]*.nc")
	
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
	hbcofa	   = ctrl_in[:]->hyam(0:pver-1)
	hbcofb	   = ctrl_in[:]->hybm(0:pver-1)
	ctrl_psfc	   = ctrl_in[:]->PS
	p0	   = 1000
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
	ctrl_var1p = vinth2p(ctrl_var1,hbcofa,hbcofb,pnew,ctrl_psfc,interp,p0,1,extrap)
	ctrl_var2p = vinth2p(ctrl_var2,hbcofa,hbcofb,pnew,ctrl_psfc,interp,p0,1,extrap)
	;ctrl_var3p = vinth2p(ctrl_var3,hbcofa,hbcofb,pnew2,ctrl_psfc,interp,p0,1,extrap)

	ctrl_var1p_mon = clmMonTLLL (ctrl_var1p)
	ctrl_var2p_mon = clmMonTLLL (ctrl_var2p)
	ctrl_var3p_mon = clmMonTLL (ctrl_var3)

	;ctrl_var1p = dim_avg_n_Wrap(ctrl_var1p_mon,0)
	;ctrl_var2p = dim_avg_n_Wrap(ctrl_var2p_mon,0)
	;ctrl_var3p = dim_avg_n_Wrap(ctrl_var3p_mon,0)

	
	ctrl_var1p_var = stdMonTLLL(ctrl_var1p)
	ctrl_var2p_var = stdMonTLLL(ctrl_var2p)
	ctrl_var3p_var = stdMonTLL(ctrl_var3)

	ctrl_var1p_var = ctrl_var1p_var*ctrl_var1p_var
	ctrl_var2p_var = ctrl_var2p_var*ctrl_var2p_var
	ctrl_var3p_var = ctrl_var3p_var*ctrl_var3p_var

;************************************************
; plot parameters that do not change during loop
;************************************************
	wks = gsn_open_wks("png","../fig/wind850Np_HEATincSCS")
	gsn_define_colormap(wks,"BlWhRe")            ; choose colormap
	gsn_reverse_colormap(wks)           ; Reverse the color map.
	gsnSpreadColors = True	
	plot = new ( 1 , graphic)
	plotV = new (1,graphic)
	plot_shade = new (1,graphic)

	pres                 = True
	;pres@tiMainString = "test"
	pres@gsnPanelLabelBar   = True		;Universial colorbar
	pres@pmLabelBarWidthF   = 0.8	
	pres@lbBoxLineThicknessF = 0.0
	pres@lbBoxLinesOn	= False	        ;no line box in color bar
	pres@lbLabelAutoStride    = False
	pres@lbLabelStride       = 10
	pres@lbTitleString       = "precipitation rate (mm/day)"
	pres@lbLabelFontHeightF = 0.025
	pres@lbTitleFontHeightF = 0.025
	pres@pmLabelBarOrthogonalPosF = -0.03           ; move label bar down


	hres =True
	hres@gsnDraw                  = False
	hres@gsnFrame                 = False
	
	hres@gsnAddCyclic         = False        ; plotted data are not cyclic
	hres@mpFillOn             = False        ; turn off map fill
	hres@mpMinLatF            = latS         ; zoom in on map
	hres@mpMaxLatF            = latN
	;hres@mpMinLonF            = lonL
	hres@mpCenterLonF         = 180.
	;hres@mpMaxLonF            = lonR
	hres@cnFillOn             = True         ; turn on color fill
	hres@cnLinesOn            = False              ; turn off contour lines
	hres@cnLineLabelsOn       = False              ; turn off line labels
	;hres@gsnRightString   = "m/s & Pa/s" 

	hres@cnLevelSelectionMode     = "ManualLevels"   ; manual contour levels
	hres@cnMinLevelValF           = -8.             ; minimum level
	hres@cnMaxLevelValF           =  8.             ; maximum level
	hres@cnLevelSpacingF          =  0.2             ; contour spacing
	hres@lbLabelBarOn        = False           ; turn off individual cb's


	
	hres@tmXBLabelFontHeightF = 0.025
	hres@tmYLLabelFontHeightF = 0.025
	hres@gsnStringFontHeightF = 0.025
	hres@tiMainFontHeightF= 0.03
  	hres@tmXBMajorThicknessF = 5.0
	hres@tmYLMajorThicknessF = 5.0
	hres@tmXBMinorThicknessF = 4.0
	hres@tmYLMinorThicknessF = 4.0
	hres@tmBorderThicknessF = 4.0
	hres@mpGeophysicalLineThicknessF = 4.0	;costal line thick
	hres@tmXBLabelStride = 2
	
	hvcres                          = True

	hvcres@gsnDraw                  = False		 ; not draw yet
	hvcres@gsnFrame                = False            ; so we can draw time stamp

	hvcres@vcRefAnnoSide            = "Left"
	hvcres@vcRefAnnoOrthogonalPosF = -0.13             ; move ref vector up
	hvcres@vcRefAnnoString2On	= False		  ; no 'ref vector' string
	hvcres@vcRefMagnitudeF         = 3.0             ; define vector ref mag
	hvcres@vcRefAnnoFontHeightF    = 0.015		 ; define ref vector string font size
	hvcres@vcRefAnnoFontHeightF    = 0.02		 ; define ref vector string font size



	hvcres@vcRefLengthF            = 0.06            ; define length of vec ref
	hvcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
	hvcres@vcLineArrowThicknessF   = 5.0		  ; arrow thickness		
	hvcres@vcMinDistanceF          = 0.02		  ; arrow distance between each other
	hvcres@vcRefAnnoString1        = "2 m/s"
	;hvcres@vcLevelSelectionMode    = "ManualLevels"
	;hvcres@vcMinMagnitudeF	       = -6e-5		 ; speed less than 0.5 will not be ploted
	;hvcres@vcLevelSpacingF	       = 6e-5
	;hvcres@vcMinMagnitudeF	       = 1e-6		 ; speed less than 0.5 will not be ploted


	;hvcres@tiMainString             = mon+" WIND850 & PRECIPT "+exp_names(i)+"-CTRL"
	hvcres@gsnAddCyclic         = False        ; plotted data are not cyclic
	;hvcres@mpFillOn             = False        ; turn off map fill
	hvcres@gsnLeftString    = ""
	hvcres@gsnRightString   = "" 


	hres                          = True
	hres@gsnDraw                  = False
	hres@gsnFrame                 = False

	
	diff_var1_case=new((/1,12,1,case_y,case_x/),"float")
	diff_var2_case=new((/1,12,1,case_y,case_x/),"float")
	diff_var3_case=new((/1,12,case_y,case_x/),"float")
	diff_var3_sig_case=new((/1,12,case_y,case_x/),"float")
	diff_var1_case(0,:,:,:,:)=ctrl_var1p_mon
	diff_var2_case(0,:,:,:,:)=ctrl_var2p_mon
	diff_var3_case(0,:,:,:)=ctrl_var3p_mon
	diff_var3_sig_case(0,:,:,:)=ctrl_var3p_mon
	do i = 0,dimsizes(exp_names)-1
		all_files2 = systemfunc ("ls ../"+exp_names(i)+"/incSCS_mon/*cam.h0.000[6-9]*.nc ../"+exp_names(i)+"/incSCS_mon/*cam.h0.00[1-3]*.nc")

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


		


		exp_var1p = vinth2p(exp_var1,hbcofa,hbcofb,pnew,exp_psfc,interp,p0,1,extrap)
		exp_var2p = vinth2p(exp_var2,hbcofa,hbcofb,pnew,exp_psfc,interp,p0,1,extrap)
		;exp_var3p = vinth2p(exp_var3,hbcofa,hbcofb,pnew2,exp_psfc,interp,p0,1,extrap)


		exp_var1p_mon = clmMonTLLL (exp_var1p)
		exp_var2p_mon = clmMonTLLL (exp_var2p)
		exp_var3p_mon = clmMonTLL (exp_var3)
				

		exp_var1p_var =  stdMonTLLL (exp_var1p)
		exp_var2p_var =  stdMonTLLL (exp_var2p)
		exp_var3p_var =  stdMonTLL (exp_var3)


		exp_var1p_var =  exp_var1p_var*exp_var1p_var
		exp_var2p_var =  exp_var2p_var*exp_var2p_var
		exp_var3p_var =  exp_var3p_var*exp_var3p_var		

		diff_var1 = exp_var1p_mon
		diff_var2 = exp_var2p_mon
		diff_var3 = exp_var3p_mon	

		diff_var1 = (exp_var1p_mon-ctrl_var1p_mon)
		diff_var2 = (exp_var2p_mon-ctrl_var2p_mon)
		diff_var3 = (exp_var3p_mon-ctrl_var3p_mon)		
		diff_var3_sig = diff_var3

		;============================================================
		;Sig test
		;============================================================

		sigr = 0.05                        ; critical sig lvl for r

		iflag= False                        ; population variance similar
		
		prob1 = new((/1,case_y,case_x/),"float")
		prob2 = new((/1,case_y,case_x/),"float")
		prob3 = new((/case_y,case_x/),"float")
		do j =0,11
			prob1 = ttest(ctrl_var1p_mon(j,:,:,:),ctrl_var1p_var(j,:,:,:),case_len, exp_var1p_mon(j,:,:,:),exp_var1p_var(j,:,:,:),case_len, iflag, False) 
			prob2 = ttest(ctrl_var2p_mon(j,:,:,:),ctrl_var2p_var(j,:,:,:),case_len, exp_var2p_mon(j,:,:,:),exp_var2p_var(j,:,:,:),case_len, iflag, False)
			prob3 = ttest(ctrl_var3p_mon(j,:,:),ctrl_var3p_var(j,:,:),case_len, exp_var3p_mon(j,:,:),exp_var3p_var(j,:,:),case_len, iflag, False)
			


			diff_var1_case(i,j,0,:,:)= (/mask(diff_var1(j,0,:,:),(prob1(0,:,:) .lt. sigr) .or. (prob2(0,:,:) .lt. sigr),True)/)
			
			diff_var2_case(i,j,0,:,:)= diff_var2(j,0,:,:)	
			diff_var3_case(i,j,:,:)= diff_var3(j,:,:)
			diff_var3_sig_case(i,j,:,:)= (/mask(diff_var3(j,:,:),prob3 .lt. sigr,True)/)
			;diff_var1_case(i,j,0,:,:)= diff_var1(j,0,:,:)
			;printVarSummary(diff_var1_case)
			
			;diff_var2_case(i,j,0,:,:)= diff_var2(j,0,:,:)		
			;diff_var3_case(i,j,0,:,:)= diff_var3(j,0,:,:)
			;diff_var3_sig_case(i,j,0,:,:)=diff_var3(j,0,:,:)
		end do
	end do
;==============================================
; create panel
;=============================================
	do j = 0,11
		;============================================================
		; PLOTS
		;============================================================
		
		do i = 0,dimsizes(exp_names)-1
		

			;hres@tiMainString = ""
			;if i .eq. 0
			;	hres@tiMainString = "test"
			;end if
			hres@gsnCenterString    = mon_name(j) + " 850UV & Prcpt Diff (sig0.05 Shaded)"
			hres@gsnLeftString    = ""			
			;hres@gsnLeftString    = "("+fig_ranks(i)+")"

			plotV(i) = gsn_csm_vector(wks,diff_var1_case(i,j,0,:,:),diff_var2_case(i,j,0,:,:),hvcres) 


			plot(i) = gsn_csm_contour_map(wks,diff_var3_case(i,j,:,:),hres)	

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

			plot_shade(i) = gsn_csm_contour(wks,diff_var3_sig_case(i,j,:,:),res)  ; Create shaded contours

			;---Overlay will transform plot_shade into data space of plot_fill

			overlay(plot(i),plot_shade(i))
			overlay(plot(i),plotV(i))

		end do

		pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
  	
  		gsn_panel(wks,plot,1,pres)
	end do

end




