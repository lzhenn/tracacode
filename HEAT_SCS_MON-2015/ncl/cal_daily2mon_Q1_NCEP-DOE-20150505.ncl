;*************************************************************
;Aim: cal monthly Q1 from daily Q1
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;     2.1 Calculate Q1
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-06
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-05-06  Change to Monthly Q1
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;global variables
    ;Define parameters

    ;for directory 
    g_strt_yr=1979
    g_lst_yr=2013
    g_data_path = "../data/obv/NCEP_DOE/q1/"
    g_data_out_path = "/home/yangsong3/data/observation/NCEP_DOE/monthly/q1/"



;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================
	do nyr = g_strt_yr,g_lst_yr
        print(nyr+"Started!")
        ctrl_in     = addfile (g_data_path+"q1."+nyr+".nc", "r")   ; note the "s" of addfile
        var1 = ctrl_in->q1
        mon_var1 = calculate_monthly_values(var1,"ave",0,False)
        mon_var1@long_name = "Monthly Q1 Calculated from daily on Pressure Levels"
        system("rm "+g_data_out_path+"q1."+nyr+".mon.mean.nc")
        ncdf = addfile(g_data_out_path+"q1."+nyr+".mon.mean.nc" ,"c")  ; open output netCDF file
        ; output variables directly
        ncdf->q1=mon_var1
        print(nyr+"Done!")
        delete([/var1, mon_var1/])
    end do
end

