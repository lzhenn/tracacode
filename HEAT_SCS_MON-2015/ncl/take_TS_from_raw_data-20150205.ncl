;*************************************************************
;Aim: Take out TS from raw data
;
;Mission:
;   1. Read data from raw model output
;   2. Post process to deserved results
;   3. Output the processed data to ncdf file
;                       Zhenning Li
;                       2015-06-13
;Last Edited:
;   2014-11-07  Create
;   2015-02-05  Modefied to fit heat-rcp45
;   2015-06-13  Modified to fit HEAT_MON
;*************************************************************



load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;global variables
   g_res  = "f19"
   ;g_case_name = "HEAT_SCS_MAM-2015"
   g_case_name = "B2000_F19G16_CAM4_CTRL"
   g_data_path = "../data/model/pre/"
   g_period="0250-0319"
   g_pdata_fn="../data/model/pro/"+g_case_name+".TS.mon."+g_period+".nc"

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls "+g_data_path+g_case_name+"/*cam.h0.02[5-9]* "+g_data_path+g_case_name+"/*cam.h0.03[0-1]*")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
    ctrl_var = ctrl_in[:]->TS
    printVarSummary(ctrl_var)

	system("rm "+g_pdata_fn)
	ncdf = addfile(g_pdata_fn ,"c")  ; open output netCDF file
	; output variables directly
	ncdf->TS=ctrl_var
end
