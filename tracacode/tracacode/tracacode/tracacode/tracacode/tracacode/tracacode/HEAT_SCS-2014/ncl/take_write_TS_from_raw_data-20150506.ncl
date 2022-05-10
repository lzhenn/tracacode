;*************************************************************
;Aim: Take TS from CAM raw Output
;Mission:
;   1. Read data from CAM raw Output
;   2. Output data to one individual file
;                       Zhenning Li
;                       2015-05-06
;Last Edited:
;   2015-05-05  Create; Modify from original file
;*************************************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    g_case_name="CON_CP"
    g_period="0150-0199"
    g_pdata_fn="/home/yangsong3/data/model/L_Zealot/HEAT_SCS-2014/pro/"+g_case_name+".TS.mon."+g_period+".nc"
    g_org_data="../data/model/pre/"+g_case_name
; ==============================================================
; Mission1: Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls "+g_org_data+"/*cam.h0.0*"); ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
    ctrl_var = ctrl_in[:]->TS
    printVarSummary(ctrl_var)

; ==============================================================
; Mission2: Write File
; ==============================================================



	system("rm "+g_pdata_fn)
	ncdf = addfile(g_pdata_fn ,"c")  ; open output netCDF file
	; output variables directly
	ncdf->TS=ctrl_var
end
