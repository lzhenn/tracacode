

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    case_name   =   "HEATING"
    exedir      =   "exe"
    lvl         =   26
    period      =   "0001-0030"
    plev        =   (/925.0, 850.0, 700.0, 600.0, 500.0, 400.0, 300.0, 200.0, 100.0, 50.0/)
    pdata_fn    =   "../post_data/"+case_name+".UV.mon."+period+".nc"

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls ../"+case_name+"/"+exedir+"/*cam.h0.00[0-2]* ../"+case_name+"/"+exedir+"/*cam.h0.0030*")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
    ctrl_var1 = ctrl_in[:]->U
    ctrl_var2 = ctrl_in[:]->V


	hbcofa	    =   ctrl_in[:]->hyam(0:lvl-1)
	hbcofb	    =   ctrl_in[:]->hybm(0:lvl-1)
	ctrl_psfc   =   ctrl_in[:]->PS
	p0	        =   1000

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
	ctrl_var1p = vinth2p(ctrl_var1,hbcofa,hbcofb,plev,ctrl_psfc,interp,p0,1,extrap)
	ctrl_var2p = vinth2p(ctrl_var2,hbcofa,hbcofb,plev,ctrl_psfc,interp,p0,1,extrap)

    printVarSummary(ctrl_var1p)
;************************************************
; Write the file
;************************************************
	system("rm "+pdata_fn)
	ncdf = addfile(pdata_fn ,"c")  ; open output netCDF file
	; output variables directly
	ncdf->U=ctrl_var1p
	ncdf->V=ctrl_var2p

end
