;*************************************************************
;Aim: Take out DTCOND from post data to clim data
;
;Mission:
;   1. Read data from post data
;   2. Post process to deserved results
;   3. Output the processed data to ncdf file
;                       Zhenning Li
;                       2015-09-24
;Last Edited:
;   2014-11-07  Create
;   2015-02-05  Modefied to fit heat-rcp45
;   2015-03-01  Modefied to fit heat-rcp45 UV
;   2015-04-05  Modefied to fit Team_Server
;   2015-06-16  Modified to fit Z3
;   2015-0924   Modified to fit clim cal
;*************************************************************



load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
   g_var  = "DTCOND"
   g_case_name = "B2000_f09_CAM5_spin-up"
   g_period="200-300"
   g_fn=g_case_name+".cam.h0."+g_var+".hybrid."+g_period+".nc"   
   g_data_path = "../data/model/pro/"
   g_pdata_fn="../data/model/pro/"+g_case_name+".cam.h0."+g_var+".hybrid."+g_period+"clim.nc"

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	
	ctrl_in      = addfile (g_data_path+g_fn, "r")   ; note the "s" of addfile
	
    ctrl_var1 = ctrl_in->$g_var$

    printVarSummary(ctrl_var1)

    ctrl_var1_clim = clmMonTLLL(ctrl_var1)

    printVarSummary(ctrl_var1_clim)

;************************************************
; Write the file
;************************************************
	system("rm "+g_pdata_fn)
	ncdf = addfile(g_pdata_fn ,"c")  ; open output netCDF file
	; output variables directly
	ncdf->$g_var$=ctrl_var1_clim
end
