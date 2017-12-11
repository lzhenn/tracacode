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

begin


;======================================================
;Variables List:
;	t2m--------------Air Temperature (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    
    ;SCS onset 1951-2014
    g_pt_rank=(/26,29,29,31,29,31,27,29,30,30,28,28,31,28,29,25,29,29,28,32,31,26,32,30,29,28,28,29,27,28,30,31,29,28,30,27,32,29,32,28,32,28,30,25,27,26,28,28,30,27,26,27,29,28,30,28,29,25,30,29,26,28,27,32/)
    g_day_rank=(g_pt_rank-1)*5+2 ; exact number
    
    g_strt_yr=1951
    g_lst_yr=2014
 
    ;g_data_strt_yr=1948
    ;g_data_lst_yr=1950
 
    g_yr_strtidx=0
    g_yr_lstidx=g_lst_yr-g_strt_yr  
    g_day_comp_len=22
    
    
    g_font = 0.02
    
        
    g_latS=-90
    g_latN=90
    g_lonW=0
    g_lonE=360
    g_var=(/"uwnd","vwnd","shum"/)
    g_data1_path ="$DATAOBV/NCEP_NCAR/daily/"+g_var+"/"

    g_data_mask_path ="$DATAOBV/NCEP_NCAR/ltmmean/pres.mon.ltm.nc"
    surf_in1     = addfile (g_data_mask_path, "r") 
    surf_pres    = surf_in1->pres
    mean_pres=surf_pres(4,:,:) ; May
    mean_pres:=mean_pres(::-1,:)
    print(mean_pres({30},{90}))
    var1_data=read_large_daily_batch_return_batch(g_var(0), g_data1_path(0),g_strt_yr, g_lst_yr, 300, 1000, g_latS, g_latN, g_lonW, g_lonE)
    var2_data=read_large_daily_batch_return_batch(g_var(1), g_data1_path(1),g_strt_yr, g_lst_yr,300, 1000, g_latS, g_latN, g_lonW, g_lonE)
    var3_data=read_large_daily_batch_return_batch(g_var(2), g_data1_path(2),g_strt_yr, g_lst_yr,300, 1000, g_latS, g_latN, g_lonW, g_lonE)
    ctrl_var1=var1_data(g_yr_strtidx:g_yr_lstidx,0:g_day_comp_len*2,:,:,:)
    ctrl_var1!0="year"
    ctrl_var1&year=ispan(g_strt_yr,g_lst_yr,1)
    ctrl_var1&year@units="years since 1951-01-01 00:00:0.0"
    ctrl_var1!1="day"
    ctrl_var1&day=ispan(-g_day_comp_len,g_day_comp_len,1)
    ctrl_var1&day@long_name="day offset relative to the third day in onset pentad"
    ctrl_var1@long_name="Vertical Integrated qu/g, kg*m-1*s-1"

    ctrl_var2=ctrl_var1
    ctrl_var2@long_name="Vertical Integrated qv/g, kg*m-1*s-1"
    ctrl_var3=ctrl_var1
    do ii=0,g_yr_lstidx-g_yr_strtidx
        ctrl_var1(ii,:,:,:,:)=(/var1_data(g_yr_strtidx+ii,g_day_rank(ii)-g_day_comp_len:g_day_rank(ii)+g_day_comp_len,:,:,:)/)
        ctrl_var2(ii,:,:,:,:)=(/var2_data(g_yr_strtidx+ii,g_day_rank(ii)-g_day_comp_len:g_day_rank(ii)+g_day_comp_len,:,:,:)/)
        ctrl_var3(ii,:,:,:,:)=(/var3_data(g_yr_strtidx+ii,g_day_rank(ii)-g_day_comp_len:g_day_rank(ii)+g_day_comp_len,:,:,:)/)
    end do
    dims=dimsizes(ctrl_var3)
    mean_pres:=conform_dims((/dims(0),dims(1),dims(2),dims(3),dims(4)/),mean_pres,(/3,4/))
    var_level:=conform_dims((/dims(0),dims(1),dims(2),dims(3),dims(4)/),ctrl_var3&level,(/2/))
    copy_VarMeta(ctrl_var3,var_level)
    copy_VarMeta(ctrl_var3,mean_pres)
    print(mean_pres(0,0,:,{30},{90}))
    print(var_level(0,0,:,{30},{90}))
    ctrl_var3=where(var_level .gt. mean_pres, ctrl_var3@_FillValue, ctrl_var3)
    print(ctrl_var3(0,0,:,{30},{90}))
    
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    qu  = ctrl_var1
    qv  = ctrl_var2
    qu  = ctrl_var1*ctrl_var3
    qv  = ctrl_var2*ctrl_var3
    wgt_qu = qu(:,:,0,:,:)
    wgt_qv = qv(:,:,0,:,:)
    
    printVarSummary(qu)
    
    ;------Cal DivQ-------
    ;-----------Follow is the vertical integral-----------
    pver=qu&level
    pver=pver*100
    pver@units="Pa"
    dp=dpres_plevel(pver,100000,1,0)              ; caculate dp
    dp_cfm=conform_dims(dimsizes(qu),dp,2)        ; confirm dp to caculate sum(var*dp)
    wgt_qu=(/dim_sum_n(dp_cfm*qu,2)/)               ; sum(var*dp)

    wgt_qv=(/dim_sum_n(dp_cfm*qv,2)/)               ; sum(var*dp)
    
    wgt_qu = wgt_qu/9.8
    wgt_qv = wgt_qv/9.8
    printVarSummary(wgt_qu) 
    ndays=g_day_comp_len*2+1
    pdata_fn = "$DATAOBV/NCEP_NCAR/daily/ncep_ncar.mask.wgt_qu.slice.45days.nc"
    write_YDLL_to_nc("wgt_qu", wgt_qu, pdata_fn)
    pdata_fn = "$DATAOBV/NCEP_NCAR/daily/ncep_ncar.mask.wgt_qv.slice.45days.nc"
    write_YDLL_to_nc("wgt_qv", wgt_qv, pdata_fn)
end

