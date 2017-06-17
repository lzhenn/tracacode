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
;    g_var_name = (/"T","U","V","Q","OMEGA","Z3"/)
;    g_var_name = (/"TS","TMQ","PRECC","PRECL","PS","PSL","FLUT"/)
    g_var_name = (/"uwnd","vwnd"/)
    g_dir_name = (/"u","v"/)
;    g_data_ctrl_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl"
    g_day_comp_len=20
    
    
    g_font = 0.02
    
        
    g_latS=-90
    g_latN=90
    g_lonW=0
    g_lonE=360
  
    g_data_path ="/home/yangsong3/data/observation/ERA-interim/pressure/"
    pro_dir="/home/yangsong3/L_Zealot/data-mirror/obv/L_Zealot/ERAI/CAL_SCSSM-2016/"
    
   ;BOB All
   g_day_rank=(/125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134/);,113,119,123/)-1
    do jj = 0, dimsizes(g_var_name)-1
        
        g_var= g_var_name(jj)   

        print("get "+g_var+"...")
        all_files:=systemfunc("ls "+g_data_path+"/"+g_dir_name(jj)+"/"+g_var+".*")
        
        n_esm=dimsizes(g_day_rank)
        setfileoption("nc","SuppressClose",False) ; close too many files
        ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile            
        ListSetType (ctrl_in, "join")             ; concatenate or "merge" (default)
        print("3D EXTRACT: "+g_var+" Reading...")
        print("  ESM 1/"+n_esm+" Reading...")
        var1 = ctrl_in[0]->$g_var$
        
        ;Build ctrl_var1
        dim_var1=dimsizes(var1)
        ctrl_var1:=conform_dims((/n_esm,2*g_day_comp_len+1,dim_var1(1),dim_var1(2),dim_var1(3)/),var1(0:g_day_comp_len*2,:,:,:),(/1,2,3,4/))
        ctrl_var1!0="esm"
        ctrl_var1&esm=ispan(1,n_esm,1)
        ctrl_var1&esm@units="ensemble member"
        ctrl_var1!1="day"
        ctrl_var1&day=ispan(-g_day_comp_len,g_day_comp_len,1)
        ctrl_var1&day@long_name="day offset relative to the first day in onset pentad"
        ctrl_var1!2=var1!1
        ctrl_var1&level=var1&level
        ctrl_var1!3=var1!2
        ctrl_var1&lat=var1&lat
        ctrl_var1!4=var1!3
        ctrl_var1&lon=var1&lon
        copy_VarAtts(var1,ctrl_var1) 
        ctrl_var1(0,:,:,:,:)=(/var1(g_day_rank(0)-g_day_comp_len:g_day_rank(0)+g_day_comp_len,:,:,:)/)
        do ii=1,n_esm-1
            print("  ESM "+(ii+1)+"/"+n_esm+" Reading...")
            var1 := ctrl_in[ii]->$g_var$
            ctrl_var1(ii,:,:,:,:)=(/var1(g_day_rank(ii)-g_day_comp_len:g_day_rank(ii)+g_day_comp_len,:,:,:)/)
        end do

        ndays=g_day_comp_len*2+1
        
        out_name=pro_dir+"interim."+ndays+"days."+g_var+".nc"

        print("Write...")
        write_YDLLL_to_nc(g_var,ctrl_var1,out_name)
    end do
end

