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
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    g_comp="all"
    g_special_year=ispan(1979,2012,1)
    g_day_rank=(/125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119/)
    onset_yyyyddd=g_special_year*1000+g_day_rank
    ;for directory 
    g_var_name = (/"shum"/)
    ;g_var_name = (/"uwnd","vwnd","air"/)
    g_font = 0.02
   
    record_len=650
     
    nudg_in1     = addfile("/home/yangsong3/L_Zealot/data-mirror/obv/L_Zealot/ERAI/CAL_SCSSM-2016/interim.41days.theta_e.nc", "r") 
    var1=nudg_in1->theta_s(:,:,{1000:200},:,:)

    all_files=systemfunc ("ls /home/yangsong3/L_Zealot/data-mirror/obv/L_Zealot/CAL_2016_traj/post_process/*")
    n_files=dimsizes(all_files)
    var_point=new((/5000,5,3/),"float")
    tp_pos=new((/5,3/),"integer")
    tp_pos=0
    do ii =0, n_files-3
        fcontent = asciiread(all_files(ii),(/record_len,6/),"double")
        ;[0]--pt_id; [1]--yyyymmddHH; [2]--lat; [3]--lon; [4]--plvl; [5]--type
        yyyyddd=yyyymmdd_to_yyyyddd(doubletoint(fcontent(:,1))/100)
        lat=fcontent(:,2)
        lon=fcontent(:,3)
        plvl=fcontent(:,4)
        type=doubletoint(fcontent(:,5))-1
        year_idx=yyyyddd(0)/1000-1979
        day_shift=yyyyddd-onset_yyyyddd(year_idx)
        do jj=0,record_len-1
            ;print("year:"+year_idx+"day:"+20+day_shift(jj)+"plvl:"+plvl(jj)+"lat"+lat(jj)+"lon"+lon(jj))
            ;print(var1(year_idx,20+day_shift(jj),{plvl(jj)},{lat(jj)},{lon(jj)})) 
            var_point(tp_pos(4+day_shift(jj),type(jj)),4+day_shift(jj),type(jj))=var1(year_idx,20+day_shift(jj),{plvl(jj)},{lat(jj)},{lon(jj)})
            tp_pos(4+day_shift(jj),type(jj))=tp_pos(4+day_shift(jj),type(jj))+1
        end do
        print((year_idx+1979)+" done!")
    end do
    var1_daily_type=dim_avg_n_Wrap(var_point,0)
    std_var1_daily_type=dim_stddev_n_Wrap(var_point,0)

    var1_daily_type:=transpose(var1_daily_type)
    std_var1_daily_type:=transpose(std_var1_daily_type)

    all_var_range=new((/3,2,5/),"float") ;[0]--type [1]--+std/-std
    all_var_range(:,0,:)=var1_daily_type+std_var1_daily_type
    all_var_range(:,1,:)=var1_daily_type-std_var1_daily_type

;====================================================================================== 
     wks = gsn_open_wks("png","../fig/traj_theta_s")          ; send graphics to PNG file

     sres = True
     sres@vpWidthF = 0.7
     sres@vpHeightF = 0.5
     sres@vpXF = .15
     sres@trXMinF = 0
     sres@trXMaxF = 6
     sres@trYMinF = 327
     sres@trYMaxF = 334
     sres@gsnDraw = True
     sres@gsnFrame = False
     sres@gsnXYBarChart = True
     sres@gsnXYBarChartBarWidth = 0.25           ; change bar widths
     sres@tmXBMode          = "Explicit"         ; explicit labels
     sres@tmXBValues        = (/1,2,3,4,5/)
     sres@tmXBLabels = (/"-4 Day","-3 Day","-2 Day","-1 Day","0 Day"/)
     sres@tmXBLabelFontHeightF = 0.0205
     sres@tmXTLabelFontHeightF = 0.0205
     sres@tmYLLabelFontHeightF = 0.0225
     sres@tiMainFontHeightF = 0.025
;     sres@tiMainFont = "helvetica"
     sres@tiMainString = "Specific Humidity along the Trajectories"
     sres@gsnRightString = ""
     sres@tiYAxisString = "theta_e"
        
     sres@gsnXYBarChartColors = (/"red"/)   
     plot1 = gsn_csm_xy(wks,fspan(0.75,4.75,5),var1_daily_type(2,:),sres)     ; Eastern
     sres@gsnXYBarChartColors = (/"darkgreen"/)                 ; seperately, not
     plot2 = gsn_csm_xy(wks,fspan(1,5,5),var1_daily_type(1,:),sres)     ; Reside
     sres@gsnXYBarChartColors = (/"blue"/)                  ; but tweaking where
     plot3 = gsn_csm_xy(wks,fspan(1.25,5.25,5),var1_daily_type(0,:),sres)        ; Western

   
     frame(wks)      




    ;*****************************************************   
    ; Manually create and attach legend
    ;***************************************************** 
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.02                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    res_lines@gsLineColor       = "red"                 ; line color
    
    xx = (/0.5,0.8/) 
    yy = (/4,4/)
;    dum1 = gsn_add_polyline(wks1,bot_plot,xx,yy,res_lines)              ; add polyline
;    dum2 = gsn_add_text(wks1,bot_plot,"Type III",xx(1)+0.5,yy(0),res_text); add text


end
