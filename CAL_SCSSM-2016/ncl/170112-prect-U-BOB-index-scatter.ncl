;*************************************************************
;Aim: EMCA method on pentad observational U and Pr
;
;                       Zhenning Li
;                       2017-01-10
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;   2017-01-10  Change to fit MCA analysis
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;======================================================
;Variables List:
;	var1--------------U (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_strt_yr=1979
    g_lst_yr=2013
    g_strt_mon=197901
    g_lst_mon=201312
    g_yr_len = g_lst_yr-g_strt_yr+1
    
    ; U200 P20-28
    g_day_strt2=95
    g_day_lst2=144
    
    ; Pr P21-29
    g_day_strt1=g_day_strt2
    g_day_lst1=g_day_lst2


    g_p_strt1=g_day_strt1/5 ;(Index)
    g_p_lst1=(g_day_lst1+1)/5-1 ;


    g_p_strt2=g_day_strt2/5 ;(Index)
    g_p_lst2=(g_day_lst2+1)/5-1 ;

    g_var_name1 = "r"
    g_data2_path ="../data/obv/NCEP-DOE/daily/uwnd1979-2013/uwnd*"
    g_data1_path ="../data/obv/PRECT/precip.pentad.mean.nc"
    g_plvl =200
    g_font = 0.035
    
    g_latS1=0.
    g_latN1=45.
    g_lonW1=60.
    g_lonE1=105.
    
    g_latS2=5
    g_latN2=20
    g_lonW2=85.
    g_lonE2=105.
    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/mca_pr_u_right_pentad_Ulag1"
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)"/)


;Prepare the variables

    ctrl_in1 = addfile(g_data1_path, "r")
    time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    var1  = ctrl_in1->precip(:g_yr_len*73-1,:,:)
    
    
    ctrl_in2_files = systemfunc("ls "+g_data2_path)
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in2     = addfiles (ctrl_in2_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in2, "join")
    var2  =short2flt(ctrl_in2[:]->uwnd(:,g_day_strt2:g_day_lst2,{g_plvl},:,:))
    var2_366  =short2flt(ctrl_in2[1::4]->uwnd(:,g_day_strt2:g_day_lst2,{g_plvl},:,:))
    var2_dim = dimsizes(var2)
    var2_data = new((/g_yr_len,var2_dim(1),var2_dim(2),var2_dim(3)/),"float")
    copy_VarMeta(var2,var2_data)
    
    ; Merge normal and leap years 
    sp = 0
    do ii=0,g_yr_len-1
        if (mod((ii-1),4) .eq. 0) then
            var2_data(ii,:,:,:) = var2_366((ii-1)/4,:,:,:)
            sp=sp+1
        else
            var2_data(ii,:,:,:) = var2(ii-sp,:,:,:)
        end if
    end do

    var2_pt_data = var2_data(:,0:g_p_lst2-g_p_strt2,:,:)    
    ; Calculate pentad data
    do ii=g_p_strt2-1,g_p_lst2-1
        jj = ii - g_p_strt2 +1
        var2_pt_data(:,jj,:,:)=dim_avg_n_Wrap(var2_data(:,jj*5:jj*5+4,:,:),1)
    end do
    var2_pt_data!1="pentad"
    
    
    var2_ind=  wgt_areaave_Wrap(var2_pt_data(:,:,{22.5:40},{60:90}),1.0,1.0,0)-wgt_areaave_Wrap(var2_pt_data(:,:,{5:20},{60:90}),1.0,1.0,0)
    do ii=g_strt_yr,g_lst_yr
        print(ii+"-"+var2_ind(ii-1979,:))
    end do
    exit
    ;var2_pt_data_reshape =  reshape(var2_pt_data,(/g_yr_len,(g_p_lst-g_p_strt+1)*var2_dim(2),var2_dim(3)/))
    
    var1_dim = dimsizes(var1) 
    var1_4d  = reshape(var1,(/g_yr_len,73,var1_dim(1),var1_dim(2)/))
    var1_4d2 = var1_4d(:,g_p_strt1:g_p_lst1,:,:)
    ;printVarSummary(var1_pt_data_reshape)
   
    var1_4d2!0="year" 
    var1_4d2!1="pentad"
    var1_4d2!2="lat"
    var1_4d2!3="lon"
    ;var1_4d2&pentad=var2_pt_data&pentad
    var1_4d2&lat=var1&lat
    var1_4d2&lon=var1&lon

    printVarSummary(var1_4d2)


end 


