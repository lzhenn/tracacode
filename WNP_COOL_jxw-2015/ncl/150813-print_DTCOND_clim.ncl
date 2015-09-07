
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

	season    = "JJA"
	latS      = 7.5 
	latN      = 17.5
    lonE      = 140
	lonW      = 120
	lev       = 30

    ctrl_dir = "../data/model/pre/F2000_CAM5_CTRL_cdh"    
 

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls "+ctrl_dir+"/*cam.h0.00[1-3]*.nc")
	;all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-7]*.nc")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

;------------------Below to change the variable---------------------	
	ctrl_var  = ctrl_in[:]->DTCOND
	
    ctrl_var_season = month_to_season (ctrl_var, season)
	avg_ctrl = dim_avg_n_Wrap(ctrl_var_season,0)
	avg_ctrl_area=wgt_areaave_Wrap(avg_ctrl(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)
    print(avg_ctrl_area)

end




