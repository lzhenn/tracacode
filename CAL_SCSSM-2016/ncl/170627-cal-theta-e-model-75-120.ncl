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
    g_var_name = (/"T","Q"/)
;    g_data_ctrl_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl"
    
    g_day_strt=74
    g_day_end=119
        
    g_latS=-90
    g_latN=90
    g_lonW=0
    g_lonE=360
  
    g_data_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/nudg/"
    pro_dir=g_data_path+"/clim/"
        

    all_files=systemfunc("ls "+g_data_path+"/*."+g_var_name(0)+".*")
    n_esm=dimsizes(all_files)
    print("  ESM 1/"+n_esm+" Reading...")
    print("T Reading...")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in1      = addfiles (all_files, "r")   ; note the "s" of addfile            
    var1 = ctrl_in1[0]->$g_var_name(0)$(g_day_strt:g_day_end,:,:,:)
 
    print("Q Reading...")
    all_files=systemfunc("ls "+g_data_path+"/*."+g_var_name(1)+".*")
    ctrl_in2      = addfiles (all_files, "r")   ; note the "s" of addfile            
    var2 = ctrl_in2[0]->$g_var_name(1)$(g_day_strt:g_day_end,:,:,:)
    

    print("theta_e Building...")
    ;Build ctrl_theta_e_var
    dim_theta_e_var=dimsizes(var1)
    ctrl_theta_e_var:=conform_dims((/n_esm,dim_theta_e_var(0),dim_theta_e_var(1),dim_theta_e_var(2),dim_theta_e_var(3)/),var1,(/1,2,3,4/))
    ctrl_theta_e_var!0="esm"
    ctrl_theta_e_var&esm=ispan(1,n_esm,1)
    ctrl_theta_e_var&esm@units="ensemble member"
    ctrl_theta_e_var!1="day"
    ctrl_theta_e_var&day=ispan(g_day_strt+1,g_day_end+1,1)
    ctrl_theta_e_var&day@long_name="day since D75"
    ctrl_theta_e_var!2=var1!1
    ctrl_theta_e_var&level=var1&level
    ctrl_theta_e_var!3=var1!2
    ctrl_theta_e_var&lat=var1&lat
    ctrl_theta_e_var!4=var1!3
    ctrl_theta_e_var&lon=var1&lon
    print("theta_e calculating...")
    
    level=conform(var2, var2&level, 1)
    ;ctrl_theta_e_var(0,:,:,:,:)=pot_temp_equiv(level, var1, var2, -1, "q")
    
    ;var2=100
    ctrl_theta_e_var(0,:,:,:,:)=pot_temp_equiv(level, var1, var2, -1, "rh")
    
    printVarSummary(ctrl_theta_e_var)
    do ii=1,n_esm-1
        print("  ESM "+(ii+1)+"/"+n_esm+" Reading...")
    
        print("T Reading...")
        var1 = ctrl_in1[ii]->$g_var_name(0)$(g_day_strt:g_day_end,:,:,:)
     
        print("Q Reading...")
        var2 = ctrl_in2[ii]->$g_var_name(1)$(g_day_strt:g_day_end,:,:,:)
        
        
        ctrl_theta_e_var(ii,:,:,:,:)=pot_temp_equiv(level, var1, var2, -1, "q")
    end do
    

    pro_dir=g_data_path+"/clim/"+"Nudging.cam.h1.ESM.75-120.theta_e.nc"
    print("Write...")
    write_YDLLL_to_nc("theta_e",ctrl_theta_e_var,pro_dir)
end

