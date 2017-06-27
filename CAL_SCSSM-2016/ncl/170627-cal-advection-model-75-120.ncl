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
    g_var_name = (/"U","V","T"/)
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
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile            
    ListSetType (ctrl_in, "join")             ; concatenate or "merge" (default)
    var1 = ctrl_in[0]->$g_var_name(0)$(g_day_strt:g_day_end,:,:,:)
 
    all_files=systemfunc("ls "+g_data_path+"/*."+g_var_name(1)+".*")
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile            
    var2 = ctrl_in[0]->$g_var_name(1)$(g_day_strt:g_day_end,:,:,:)
    
    all_files=systemfunc("ls "+g_data_path+"/*."+g_var_name(2)+".*")
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile            
    var3 = ctrl_in[0]->$g_var_name(2)$(g_day_strt:g_day_end,:,:,:)
    
    ;Build ctrl_adv_var
    dim_adv_var=dimsizes(var1)
    ctrl_adv_var:=conform_dims((/n_esm,dim_adv_var(0),dim_adv_var(1),dim_adv_var(2),dim_adv_var(3)/),var1,(/1,2,3,4/))
    ctrl_adv_var!0="esm"
    ctrl_adv_var&esm=ispan(1,n_esm,1)
    ctrl_adv_var&esm@units="ensemble member"
    ctrl_adv_var!1="day"
    ctrl_adv_var&day=ispan(g_day_strt+1,g_day_end+1,1)
    ctrl_adv_var&day@long_name="day since D75"
    ctrl_adv_var!2=adv_var!1
    ctrl_adv_var&level=adv_var&level
    ctrl_adv_var!3=adv_var!2
    ctrl_adv_var&lat=adv_var&lat
    ctrl_adv_var!4=adv_var!3
    ctrl_adv_var&lon=adv_var&lon
    ctrl_adv_var(0,:,:,:,:)=advect_variable(var1,var2,var3,1,"advection of temperature","K/s",0)
    printVarSummary(ctrl_adv_var)
    exit
    do ii=1,n_esm-1
        print("  ESM "+(ii+1)+"/"+n_esm+" Reading...")
        var1 := ctrl_in[ii]->$g_var$
        ctrl_var1(ii,:,:,:,:)=(/var1(onset_nudg(ii)-g_day_comp_len:onset_nudg(ii)+g_day_comp_len,:,:,:)/)
    end do
    ndays=g_day_comp_len*2+1
    
    out_name_ele:=str_split(all_files(0),".")
    out_name=out_name_ele(0)+".cam.h1.ESM."+ndays+"days."+out_name_ele(4)+"."+out_name_ele(5)+"."+out_name_ele(6)
    out_name_ele:=str_split(out_name,"/")
    len=dimsizes(out_name_ele)
    out_name=pro_dir+out_name_ele(len-1)

    print("Write...")
    write_YDLLL_to_nc(g_var,ctrl_var1,out_name)
end

