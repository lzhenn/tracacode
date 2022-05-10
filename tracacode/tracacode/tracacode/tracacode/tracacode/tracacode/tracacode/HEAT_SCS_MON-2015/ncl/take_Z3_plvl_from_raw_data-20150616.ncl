;*************************************************************
;Aim: Take out UV from raw data
;
;Mission:
;   1. Read data from raw model output
;   2. Post process to deserved results
;   3. Output the processed data to ncdf file
;                       Zhenning Li
;                       2015-04-05
;Last Edited:
;   2014-11-07  Create
;   2015-02-05  Modefied to fit heat-rcp45
;   2015-03-01  Modefied to fit heat-rcp45 UV
;   2015-04-05  Modefied to fit Team_Server
;   2015-06-16  Modified to fit Z3
;*************************************************************



load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
   g_lvl         =   26
   g_plev        =   (/925.0, 850.0, 700.0, 600.0, 500.0, 400.0, 300.0, 200.0, 100.0, 50.0/)

   g_res  = "f19"
   g_var  = "Z3"
   g_case_name = "B2000_F19G16_CAM4_CTRL"
   ;g_case_name =  "HEAT_SCS_MAM-2015"
   g_period="0250-0299"
   g_fn=g_case_name+"."+g_var+".plvl.mon."+g_period+".nc"   
   g_data_path = "../data/model/pre/"
   g_pdata_fn="../data/model/pro/"+g_fn

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls "+g_data_path+g_case_name+"/*cam.h0.02[5-9]*"); +g_data_path+g_case_name+"/*cam.h0.03*"); ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")
	setfileoption("nc","SuppressClose",False) ; close too many files
	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
    ctrl_var1 = ctrl_in[:]->$g_var$


	hbcofa	    =   ctrl_in[:]->hyam(0:g_lvl-1)
	hbcofb	    =   ctrl_in[:]->hybm(0:g_lvl-1)
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
	ctrl_var1p = vinth2p(ctrl_var1,hbcofa,hbcofb,g_plev,ctrl_psfc,interp,p0,1,extrap)

    printVarSummary(ctrl_var1p)
;************************************************
; Write the file
;************************************************
	system("rm "+g_pdata_fn)
	ncdf = addfile(g_pdata_fn ,"c")  ; open output netCDF file
	; output variables directly
	ncdf->$g_var$=ctrl_var1p
end
