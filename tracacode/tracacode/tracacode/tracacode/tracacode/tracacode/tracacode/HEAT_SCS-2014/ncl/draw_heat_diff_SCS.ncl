
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
    fig_name = "HEAT_CAM4_SCSpoint_PTENDT"
 
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.000[6-9]*.nc ../"+ctrl_name+"/"+ctrl_rundir+"/*cam.h0.00[1-3]*.nc")
	;all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-7]*.nc")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

	all_files2 = systemfunc ("ls ../"+exp_names(0)+"/"+exp_rundir+"/*cam.h0.000[6-9]*.nc ../"+exp_names(0)+"/"+exp_rundir+"/*cam.h0.00[1-3]*.nc")
	;all_files2 = systemfunc ("ls ../HEATSEN/sen_mon/*cam.h0.000[6-7]*.nc")
	setfileoption("nc","SuppressClose",False)

	exp_in      = addfiles (all_files2, "r")   ; note the "s" of addfile

	ListSetType (exp_in, "cat")             ; concatenate or "merge" (default)


;------------------Below to change the variable---------------------	
	ctrl_var  = ctrl_in[:]->PTENDT
    exp_var   = exp_in[:]->PTENDT

	ctrl_var_season = month_to_season (ctrl_var, season)
	exp_var_season = month_to_season (exp_var, season)

	printVarSummary(ctrl_var_season)

	avg_ctrl = dim_avg_n_Wrap(ctrl_var_season,0)
        avg_exp  = dim_avg_n_Wrap(exp_var_season,0)


        ;diff_avg = avg_ctrl
        ;diff_avg = (avg_exp - avg_ctrl)

	avg_ctrl_area=wgt_areaave_Wrap(avg_ctrl(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)
	avg_exp_area=wgt_areaave_Wrap(avg_exp(:,{latS:latN},{lonW:lonE}),1.0,1.0,0)

	printVarSummary(avg_ctrl_area)



;--------------------------------figure----------------------------------
        wks = gsn_open_wks("eps","../fig/"+fig_name)           
	

        resxy                   = True                      ; plot mods desired
        resxy@gsnXRefLine       = 0.0                       ; draw ref line
        resxy@trYReverse        = True                      ; reverse Y-axis
        resxy@xyLineThicknesses = (/4.0,4.0/)           
        resxy@xyLineColors      = (/"blue","red"/)          ; change line colors
        resxy@trYMinF           = 0.0
        resxy@trYMaxF           = 1000.0

        resxy@pmLegendDisplayMode    = "Always"             ; turn on legend
        resxy@xyExplicitLegendLabels = (/"CON","HEAT_CAM4"/)
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
	    y(:,lev-1) = 0
        y@long_name = ""
        plt  = gsn_csm_xy (wks,y,avg_ctrl_area&lev,resxy) 

end




