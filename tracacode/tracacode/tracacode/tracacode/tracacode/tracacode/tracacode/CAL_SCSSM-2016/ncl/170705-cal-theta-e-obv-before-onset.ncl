;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"
load "./LIB_CAL_SCSSM-2016.ncl"

begin


;======================================================
;Variables List:
;	2m--------------Air Temperature (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = (/"air","shum"/)
;    g_data_ctrl_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl"
    
    g_day_strt=74
    g_day_end=119
        
    g_latS=-90
    g_latN=90
    g_lonW=0
    g_lonE=360
  
    g_data_path ="/home/yangsong3/L_Zealot/data-mirror/obv/L_Zealot/ERAI/CAL_SCSSM-2016/"
    pro_dir=g_data_path
        

    print("T Reading...")
    ctrl_in1      = addfile (g_data_path+"interim.51days.air.nc", "r")   ; note the "s" of addfile            
    var1 = ctrl_in1->$g_var_name(0)$
    print("Q Reading...")
    ctrl_in2      = addfile (g_data_path+"interim.51days.shum.nc", "r")   ; note the "s" of addfile            
;    var2 = ctrl_in2->$g_var_name(1)$

    

    print("theta_es Building...")
    ;Build ctrl_theta_e_var
    ctrl_theta_e_var=var1
    print("theta_es calculating...")
    
    level=conform(var1, var1&level, 2)
    ;ctrl_theta_e_var=pot_temp_equiv(level, var1, var2, -1, "q")
    var2=var1 
    var2=100
    ctrl_theta_e_var=pot_temp_equiv(level, var1, var2, -1, "rh")
   
    pro_dir=g_data_path+"interim.51days.theta_es.nc"
    print("Write...")
    write_YDLLL_to_nc("theta_es",ctrl_theta_e_var,pro_dir)
end

