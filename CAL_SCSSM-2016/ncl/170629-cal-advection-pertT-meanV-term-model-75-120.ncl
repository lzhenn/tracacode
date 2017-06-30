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
    

    print("Clim Reading...")
    clim_file=addfile(pro_dir+"Nudging.cam.h1.ESM.clim.U.0101-0701.nc","r")
    clim_var1=clim_file->$g_var_name(0)$(g_day_strt:g_day_end,:,:,:)

    clim_file=addfile(pro_dir+"Nudging.cam.h1.ESM.clim.V.0101-0701.nc","r")
    clim_var2=clim_file->$g_var_name(1)$(g_day_strt:g_day_end,:,:,:)

    clim_file=addfile(pro_dir+"Nudging.cam.h1.ESM.clim.T.0101-0701.nc","r")
    clim_var3=clim_file->$g_var_name(2)$(g_day_strt:g_day_end,:,:,:)

    all_files=systemfunc("ls "+g_data_path+"/*."+g_var_name(0)+".*")
    n_esm=dimsizes(all_files)
    print("  ESM 1/"+n_esm+" Reading...")
    print("U Reading...")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in1      = addfiles (all_files, "r")   ; note the "s" of addfile            
    var1 = ctrl_in1[0]->$g_var_name(0)$(g_day_strt:g_day_end,:,:,:)
 
    print("V Reading...")
    ;all_files=systemfunc("ls "+g_data_path+"/*."+g_var_name(1)+".*")
    ;ctrl_in2      = addfiles (all_files, "r")   ; note the "s" of addfile            
    ;var2 = ctrl_in2[0]->$g_var_name(1)$(g_day_strt:g_day_end,:,:,:)
    ;var2=var1
    print("T Reading...")
    all_files=systemfunc("ls "+g_data_path+"/*."+g_var_name(2)+".*")
    ctrl_in3      = addfiles (all_files, "r")   ; note the "s" of addfile            
    var3 = ctrl_in3[0]->$g_var_name(2)$(g_day_strt:g_day_end,:,:,:)
    
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
    
    ; pert T
    var3=var3-clim_var3

    ctrl_adv_var(0,:,:,:,:)=advect_variable(clim_var1,clim_var2,var3,1,"advection of temperature","K/s",0)
    printVarSummary(ctrl_adv_var)
    do ii=1,n_esm-1
        print("  ESM "+(ii+1)+"/"+n_esm+" Reading...")
    
        print("U Reading...")
        ;var1 = ctrl_in1[ii]->$g_var_name(0)$(g_day_strt:g_day_end,:,:,:)
     
        print("V Reading...")
        ;var2 = ctrl_in2[ii]->$g_var_name(1)$(g_day_strt:g_day_end,:,:,:)
        
        print("T Reading...")
        var3 = ctrl_in3[ii]->$g_var_name(2)$(g_day_strt:g_day_end,:,:,:)

        ;var1=var1-clim_var1
        var3=var3-clim_var3
        
        ctrl_adv_var(ii,:,:,:,:)=advect_variable(clim_var1,clim_var2,var3,1,"advection of temperature","K/s",0)
    end do
    

    pro_dir=g_data_path+"/clim/"+"Nudging.cam.h1.ESM.75-120.meanVpertT.advT.nc"
    print("Write...")
    write_YDLLL_to_nc("advT",ctrl_adv_var,pro_dir)
end

