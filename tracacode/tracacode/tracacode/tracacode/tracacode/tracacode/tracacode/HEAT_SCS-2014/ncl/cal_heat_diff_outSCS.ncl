
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


	casename  = "AHR_JJA"
	season    = "JJA"
	latS      = 0
	latN      = 30
	lonE      = 150
	lonW      = 120
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-9]*.nc ../HEATCTRL/ctrl_mon/*cam.h0.00[1-3]*.nc")
	;all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-9]*.nc")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)



	all_files2 = systemfunc ("ls ../HEATSEN/sen_mon/*cam.h0.000[6-9]*.nc ../HEATCTRL/ctrl_mon/*cam.h0.00[1-3]*.nc")
	;all_files2 = systemfunc ("ls ../HEATSEN/sen_mon/*cam.h0.000[6-9]*.nc")
	setfileoption("nc","SuppressClose",False)

	exp_in      = addfiles (all_files2, "r")   ; note the "s" of addfile

	ListSetType (exp_in, "cat")             ; concatenate or "merge" (default)


;------------------Below to change the variable---------------------	
	ctrl_var  = ctrl_in[:]->PTENDT
        exp_var   = exp_in[:]->PTENDT

	ctrl_var_season = month_to_season (ctrl_var, season)
	exp_var_season = month_to_season (exp_var, season)
	printVarSummary(ctrl_var_season)
        avg_ctrl = dim_avg_n_Wrap(ctrl_var,0)
        avg_exp  = dim_avg_n_Wrap(exp_var,0)
        diff_avg = avg_ctrl
        diff_avg = (avg_exp - avg_ctrl)
	diff_avg_area=wgt_areaave(diff_avg(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)
	print(diff_avg_area)
	exit
        wks = gsn_open_wks("pdf","../fig/"+casename)           

	gsn_define_colormap(wks,"BlueWhiteOrangeRed")            ; choose colormap
	;gsn_reverse_colormap(wks)           ; Reverse the color map.
	gsnSpreadColors = True
	res                      = True               ; plot options desired
	
	res@cnFillOn             = True               ; turn on color fill
        res@cnInfoLabelOn        = False              ; no contour info label
	res@cnLinesOn            = False              ; turn off contour lines
	res@cnLineLabelsOn       = False              ; turn off line labels
	res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels

	res@cnMinLevelValF    =   -0.0015               ; set min contour level
	res@cnMaxLevelValF    =    0.0015              ; set max contour level
	res@cnLevelSpacingF   =    0.0001               ; set contour spacing

	res@lbBoxLineThicknessF = 0.1
	res@lbBoxLinesOn	= True	        ;no line box in color bar
	res@mpFillOn             = False        ; turn off map fill
	res@mpCenterLonF         = 180.

	res@gsnLeftString    = "Air Heating Rate (AHR)"
	res@gsnRightString   = "K/kg/s"
	res@tiMainString     = "JJA Deep_Conv AHR Diff at lev19 (about 500hPa)"	

        ;do i = 0,24
        ;  plot = gsn_csm_contour_map_ce(wks,diff_avg((24-i),:,:),res)        ; create plot
	;end do

          plot = gsn_csm_contour_map_ce(wks,diff_avg(19,:,:),res)        ; create plot

end




