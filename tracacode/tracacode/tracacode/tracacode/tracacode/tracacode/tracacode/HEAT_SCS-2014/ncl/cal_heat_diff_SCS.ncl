
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


    ctrl_name = "HEATCTRL"
    ctrl_rundir = "ctrl_mon"    
 
	exp_names = (/"HEATING"/)
    exp_rundir = "exe"
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	;all_files = systemfunc ("ls ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.000[6-9]*.nc ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.00[1-3]*.nc")
	all_files = systemfunc ("ls ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.000[6-9]*.nc")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)



	;all_files2 = systemfunc ("ls ../"+exp_names(0)+"/"+exp_rundir+"/*cam.h0.000[6-9]*.nc ../"+exp_names(0)+"/"+exp_rundir+"/*cam.h0.00[1-3]*.nc")
	all_files2 = systemfunc ("ls ../"+exp_names(0)+"/"+exp_rundir+"/*cam.h0.000[6-9]*.nc")
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
end




