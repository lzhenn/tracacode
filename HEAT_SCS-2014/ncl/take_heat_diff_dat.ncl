
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
   pver = 26
   ;Define parameters
   filename="../data/model_post/CAM4_PTENDT_DIFF_mon.bin"
   fig_name="CAM4_HEATDIFF_PTENDT_takeout_lv20"
   fig_name2="CAM4_HEATDIFF_PTENDT_takeout_profile"
   fig_title="CAM4 Heat Diff at about 600hPa"

    latS=0.
    latN=30.
    lonW=110.
    lonE=150.
   ; ==============================================================
   ; Open the file: Read only the user specified period
   ; ==============================================================
   all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-9]*.nc ../HEATCTRL/ctrl_mon/*cam.h0.00[1-3]*.nc")
   ;all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-7]*.nc")
   setfileoption("nc","SuppressClose",False) ; close too many files

   ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile

   ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)



   all_files2 = systemfunc ("ls ../HEATSEN/sen_mon/*cam.h0.000[6-9]*.nc ../HEATSEN/sen_mon/*cam.h0.00[1-3]*.nc")
   ;all_files2 = systemfunc ("ls ../HEATSEN/sen_mon/*cam.h0.000[6-7]*.nc")
   setfileoption("nc","SuppressClose",False)

   exp_in      = addfiles (all_files2, "r")   ; note the "s" of addfile

   ListSetType (exp_in, "cat")             ; concatenate or "merge" (default)


   ;------------------Below to change the variable---------------------    
   ctrl_var  = ctrl_in[:]->PTENDT
   exp_var   = exp_in[:]->PTENDT

   avg_ctrl = clmMonTLLL(ctrl_var)
   avg_exp  = clmMonTLLL(exp_var)
   diff_avg_o = avg_ctrl(:,:,{0:30},{110:150})
   diff_avg_o = (avg_exp(:,:,{0:30},{110:150}) - avg_ctrl(:,:,{0:30},{110:150}))
   printVarSummary(diff_avg_o)
   diff_avg = diff_avg_o(month|:,lon|:,lat|:,lev|:) 
   diff_avg=where(diff_avg < 0,0,diff_avg)


; Write Binary File
   system("rm -f "+filename)
   setfileoption("bin","WriteByteOrder","BigEndian")
   fbinrecwrite(filename,-1,diff_avg&lat)
   fbinrecwrite(filename,-1,diff_avg&lon)
   fbinrecwrite(filename,-1,diff_avg)


;printVarSummary(avg_exp(:,{0:30},{110:150}))
	ctrl_var_season = month_to_season (ctrl_var, "JJA")
	exp_var_season = month_to_season (exp_var, "JJA")
    diff_avg=where(diff_avg < 0,0,diff_avg)

	avg_ctrl0 = dim_avg_n_Wrap(ctrl_var_season,0)
    avg_exp0  = dim_avg_n_Wrap(exp_var_season,0)

	avg_ctrl_area=wgt_areaave_Wrap(avg_ctrl0(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)
	avg_exp_area=wgt_areaave_Wrap(avg_exp0(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)

    avg_ctrl_area=where(avg_ctrl_area < 0,0,avg_ctrl_area)
    avg_exp_area=where(avg_exp_area < 0,0,avg_exp_area)

;************************************************
; plot parameters that do not change during loop
;************************************************
	wks = gsn_open_wks("eps","../fig/"+fig_name)
	gsn_define_colormap(wks,"NCV_blu_red")            ; choose colormap
	;gsn_reverse_colormap(wks)           ; Reverse the color map.
	gsnSpreadColors = True	
	plot = new ( 1 , graphic)

	hres =True
	hres@gsnDraw                  = True
	hres@gsnFrame                 = True
	
	hres@gsnAddCyclic         = False        ; plotted data are not cyclic
	hres@mpFillOn             = False        ; turn off map fill
	hres@mpMinLatF            = latS         ; zoom in on map
	hres@mpMaxLatF            = latN
	hres@mpMinLonF            = lonW
	hres@mpCenterLonF         = 180.
	hres@mpMaxLonF            = lonE
	hres@cnFillOn             = True         ; turn on color fill
	hres@cnLinesOn            = False              ; turn off contour lines
	hres@cnLineLabelsOn       = False              ; turn off line labels
	;hres@gsnRightString   = "m/s & Pa/s" 

	hres@cnLevelSelectionMode     = "ManualLevels"   ; manual contour levels
	hres@cnMinLevelValF           =  -0.05             ; minimum level
	hres@cnMaxLevelValF           =  0.05            ; maximum level
	hres@cnLevelSpacingF          =  0.0025            ; contour spacing
	;hres@lbLabelBarOn        = False           ; turn off individual cb's
	

	;hres@tmXBLabelStride = 2		; For global, = 2

	
	hres@tmXBLabelFontHeightF = 0.025
	hres@tmYLLabelFontHeightF = 0.025
	hres@gsnStringFontHeightF = 0.02
	hres@tiMainFontHeightF= 0.02
  	hres@tmXBMajorThicknessF = 5.0
	hres@tmYLMajorThicknessF = 5.0
	hres@tmXBMinorThicknessF = 4.0
	hres@tmYLMinorThicknessF = 4.0
	hres@tmBorderThicknessF = 4.0
	hres@mpGeophysicalLineThicknessF = 3.5	;costal line thick 4.0 fine for png
	

	hres@gsnLeftString    = "JJA Heating Rate"
	hres@gsnRightString   = "K/kg/s" 


	hres@tiMainString    = fig_title
    diff_back = diff_avg(month|:,lev|:,lat|:,lon|:)
    diff_back_JJA = month_to_season(diff_back,"JJA")
    printVarSummary(diff_back_JJA)
    plot = gsn_csm_contour_map(wks,diff_back_JJA(0,19,:,:),hres)	

;--------------------------------figure----------------------------------
        wks1 = gsn_open_wks("eps","../fig/"+fig_name2)           
	

        resxy                   = True                      ; plot mods desired
        resxy@gsnXRefLine       = 0.0                       ; draw ref line
        resxy@trYReverse        = True                      ; reverse Y-axis
        resxy@xyLineThicknesses = (/4.0,4.0/)           
        resxy@xyLineColors      = (/"blue","red"/)          ; change line colors
        resxy@trYMinF           = 0.0
        resxy@trYMaxF           = 1000.0

        resxy@pmLegendDisplayMode    = "Always"             ; turn on legend
        resxy@xyExplicitLegendLabels = (/"CON","SEN"/)
        resxy@pmLegendSide           = "Top"                ; Change location of 
        resxy@pmLegendParallelPosF   = .65                  ; move units right
        resxy@pmLegendOrthogonalPosF = -0.35                ; move units down
        resxy@lgPerimOn = False
        resxy@pmLegendWidthF         = 0.12                   ; Change width and
        resxy@pmLegendHeightF        = 0.12                   ; height of legend.
        resxy@lgLabelFontHeightF     = .020                    ; change font height

	    resxy@tiMainString	     = "Vertical Heating Rate Profile (K/kg/s)"

        y = ctrl_var_season(:1,:,0,0)			   ;take out the dimision style
        y(0,:) = (/ avg_ctrl_area /);*86400
        y(1,:) = (/ avg_exp_area /);*86400
        y@long_name = ""
        plt  = gsn_csm_xy (wks1,y,avg_ctrl_area&lev,resxy) 

end








