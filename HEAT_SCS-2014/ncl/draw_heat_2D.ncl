
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

	season    = "JJA"
	latS      = 0
	latN      = 30
	lonE      = 150
	lonW      = 110
	lev       = 26

    ctrl_name = "HEATCTRL"
    ctrl_rundir = "ctrl_mon"    
 
	exp_names = (/"HEATING"/)
    exp_rundir = "exe"
    file_name = "heatdiff_CAM4_HEAT_20lvl"
    fig_title = "HEAT-CON (CAM4)"
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.000[6-9]*.nc ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.001[1-8]*.nc")
	;all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-9]*.nc")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

	all_files2 = systemfunc ("ls ../"+exp_names(0)+"/"+exp_rundir+"/*cam.h0.000[6-9]*.nc ../"+exp_names(0)+"/"+exp_rundir+"/*cam.h0.001[1-8]*.nc")
	;all_files2 = systemfunc ("ls ../HEATSEN/sen_mon/*cam.h0.000[6-9]*.nc")
	setfileoption("nc","SuppressClose",False)

	exp_in      = addfiles (all_files2, "r")   ; note the "s" of addfile

	ListSetType (exp_in, "cat")             ; concatenate or "merge" (default)


;------------------Below to change the variable---------------------	
	ctrl_var  = ctrl_in[:]->PTENDT
    exp_var   = exp_in[:]->PTENDT

	ctrl_var_season = month_to_season (ctrl_var, season)
	exp_var_season = month_to_season (exp_var, season)


	avg_ctrl = dim_avg_n_Wrap(ctrl_var_season,0)
    avg_exp  = dim_avg_n_Wrap(exp_var_season,0)


    diff_avg = avg_ctrl
    diff_avg = (avg_exp - avg_ctrl)
    printVarSummary(diff_avg)

    avg_ctrl_area=wgt_areaave_Wrap(avg_ctrl(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)
	avg_exp_area=wgt_areaave_Wrap(avg_exp(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)

	printVarSummary(avg_ctrl_area)




;************************************************
; plot parameters that do not change during loop
;************************************************
	wks = gsn_open_wks("eps","../fig/"+file_name)
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
	hres@lbLabelBarOn        = False           ; turn off individual cb's
	

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
	

	hres@gsnLeftString    = "lvl 20 "
	hres@gsnRightString   = "Heat diff" 


	hres@tiMainString    = fig_title

	plot = gsn_csm_contour_map(wks,diff_avg(19,:,:),hres)	


end




