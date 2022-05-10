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
    g_var_name = (/"uwnd","vwnd","air"/)
;    g_data_ctrl_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl"
    
    g_day_strt=74
    g_day_end=119
        
    g_latS=-10
    g_latN=60
    g_lonW=30
    g_lonE=180
  
    g_data_path ="/home/yangsong3/data/observation/ERA-interim/pressure/"
    pro_dir=g_data_path+"daily-clim/"
        

    all_files=systemfunc("ls "+g_data_path+"/u/*"+g_var_name(0)+"*")
    n_esm=dimsizes(all_files)
    print("  ESM 1/"+n_esm+" Reading...")
    print("U Reading...")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in1      = addfiles (all_files, "r")   ; note the "s" of addfile            
    var1 = ctrl_in1[0]->$g_var_name(0)$(g_day_strt:g_day_end,{100:1000},{g_latS:g_latN},{g_lonW:g_lonE})
 
    print("V Reading...")
    all_files=systemfunc("ls "+g_data_path+"/v/*"+g_var_name(1)+"*")
    ctrl_in2      = addfiles (all_files, "r")   ; note the "s" of addfile            
    var2 = ctrl_in2[0]->$g_var_name(1)$(g_day_strt:g_day_end,{100:1000},{g_latS:g_latN},{g_lonW:g_lonE})    
    ;var2=var1
    print("T Reading...")
    all_files=systemfunc("ls "+g_data_path+"/air/*"+g_var_name(2)+"*")
    ctrl_in3      = addfiles (all_files, "r")   ; note the "s" of addfile            
    var3 = ctrl_in3[0]->$g_var_name(2)$(g_day_strt:g_day_end,{100:1000},{g_latS:g_latN},{g_lonW:g_lonE})    
    print("adv Building...")
    ;Build ctrl_adv_var
    dim_adv_var=dimsizes(var1)
    ctrl_adv_var:=conform_dims((/n_esm,dim_adv_var(0),dim_adv_var(1),dim_adv_var(2),dim_adv_var(3)/),var1,(/1,2,3,4/))
    ctrl_adv_var!0="esm"
    ctrl_adv_var&esm=ispan(1,n_esm,1)
    ctrl_adv_var&esm@units="ensemble member"
    ctrl_adv_var!1="day"
    ctrl_adv_var&day=ispan(g_day_strt+1,g_day_end+1,1)
    ctrl_adv_var&day@long_name="day since D75"
    ctrl_adv_var!2=var1!1
    ctrl_adv_var&level=var1&level
    ctrl_adv_var!3=var1!2
    ctrl_adv_var&lat=var1&lat
    ctrl_adv_var!4=var1!3
    ctrl_adv_var&lon=var1&lon
    print("adv calculating...")
    ;var2=0
    ctrl_adv_var(0,:,:,:,:)=advect_variable(var1,var2,var3,1,"advection of temperature","K/s",0)
    printVarSummary(ctrl_adv_var)
    do ii=1,n_esm-1
        print("  ESM "+(ii+1)+"/"+n_esm+" Reading...")
    
        print("U Reading...")
        var1 = ctrl_in1[ii]->$g_var_name(0)$(g_day_strt:g_day_end,{100:1000},{g_latS:g_latN},{g_lonW:g_lonE})    
     
        print("V Reading...")
        var2 = ctrl_in2[ii]->$g_var_name(1)$(g_day_strt:g_day_end,{100:1000},{g_latS:g_latN},{g_lonW:g_lonE})    
        
        print("T Reading...")
        var3 = ctrl_in3[ii]->$g_var_name(2)$(g_day_strt:g_day_end,{100:1000},{g_latS:g_latN},{g_lonW:g_lonE})    

        ctrl_adv_var(ii,:,:,:,:)=advect_variable(var1,var2,var3,1,"advection of temperature","K/s",0)
    end do
    

    pro_dir=g_data_path+"/daily-clim/"+"interim.75-120.advT.nc"
    print("Write...")
    write_YDLLL_to_nc("advT",ctrl_adv_var,pro_dir)
end

