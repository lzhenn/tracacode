

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    case_name="HEATCTRL"
    exedir="ctrl_mon"
    period="0001-0030"
    pdata_fn="../post_data/"+case_name+".Pr.mon."+period+".nc"

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls ../"+case_name+"/"+exedir+"/*cam.h0.00[0-2]* ../"+case_name+"/"+exedir+"/*cam.h0.0030*")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
    ctrl_var1 = ctrl_in[:]->PRECC
    ctrl_var2 = ctrl_in[:]->PRECL
    ctrl_var = ctrl_var1
    ctrl_var = ctrl_var1 + ctrl_var2
    printVarSummary(ctrl_var)

	system("rm "+pdata_fn)
	ncdf = addfile(pdata_fn ,"c")  ; open output netCDF file
	; output variables directly
	ncdf->PRECT=ctrl_var
end
