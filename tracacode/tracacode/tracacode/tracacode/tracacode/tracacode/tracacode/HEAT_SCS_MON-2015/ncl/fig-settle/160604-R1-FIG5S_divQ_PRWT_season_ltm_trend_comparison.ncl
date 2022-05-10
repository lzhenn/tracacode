;*************************************************************
;Aim: draw PRECC annually ltm trend 
;Mission:
;   1. Read data
;   2. Post-post process
;     2.1 take the trend 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-05-03
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN
;   2015-05-03  Change to caculate season trend 
;   2015-06-22  Change to fit 973 Report Fig1
;   2015-11-09  Change to fit GRL Fig.3c
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------PRECC
;================================================
;global variables
    ;Define parameters
    g_data_path = "../../data/obv/ERA/U-197901-201408.nc"
    g_data_path2 = "../../data/obv/ERA/V-197901-201408.nc"
    g_data_path3 = "../../data/obv/ERA/SH-197901-201408.nc"
    g_data_path4 = "../../data/obv/ERA/PRWT_197901-201602.nc"
    
    ;g_latS=-30.
    ;g_latN=60.
    ;g_lonW=30.
    ;g_lonE=180.

    ;SCS+PhSea
    sea_latS=0.
    sea_latN=15.
    sea_lonW=105.
    sea_lonE=155.
 
    g_season="MAM"
    g_season_rank=(/"DJF","MAM","JJA","SON"/)
; create an array of desired pressure levels:

    yr_end = 2013        
    g_font = 0.03

    g_strt_mon = 197901 
    g_lst_mon = 201312
 
    g_date =systemfunc("date '+%Y%m%d'")
    g_fig_name    =   "../../fig/scientific_reports/FIG5S_divQ_Pr_ratio-"+g_date
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
  
    g_fig_title     = (/"MAM CVIMF and TPW Timeseries"/)
   ;g_fig_title1   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr trend"  ;for dsstdt
   ;g_fig_title2   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr' trend" ;for dsst'dt


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	var1  =short2flt(ctrl_in1->u(istrt:ilast,:,:,:))			; p for unify the var name

    ctrl_file2   = g_data_path2
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	time_hist2    = ctrl_in2->time
    yyyymm2  = cd_calendar(time_hist2,-1)
    istrt   = ind(yyyymm2 .eq. g_strt_mon)
    ilast   = ind(yyyymm2 .eq. g_lst_mon)
	var2  =short2flt(ctrl_in2->v(istrt:ilast,:,:,:))			; p for unify the var name

    ctrl_file3   = g_data_path3
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile
	time_hist3    = ctrl_in3->time
    yyyymm3  = cd_calendar(time_hist3,-1)
    istrt   = ind(yyyymm3 .eq. g_strt_mon)
    ilast   = ind(yyyymm3 .eq. g_lst_mon)
	var3  =short2flt(ctrl_in3->q(istrt:ilast,:,:,:))			; p for unify the var name

    ctrl_file4   = g_data_path4
	ctrl_in4     = addfile (ctrl_file4, "r")   ; note the "s" of addfile
	time_hist4    = ctrl_in4->time
    yyyymm4  = cd_calendar(time_hist4,-1)
    istrt   = ind(yyyymm4 .eq. g_strt_mon)
    ilast   = ind(yyyymm4 .eq. g_lst_mon)
	var4  =short2flt(ctrl_in4->tcwv(istrt:ilast,:,:))			; p for unify the var name


    print("Var Read Done!")
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    qu  = var3
    qv  = var3
    qu  = var1*var3
    qv  = var2*var3
    wgt_qu = qu(:,0,:,:)
    wgt_qv = qv(:,0,:,:)
    
    
    ;------Cal DivQ-------
    ;-----------Follow is the vertical integral-----------
    pver=qu&level
    pver=pver*100
    pver@units="Pa"
    dp=dpres_plevel(pver,100000,1,0)              ; caculate dp
    dp_cfm=conform_dims(dimsizes(qu),dp,1)        ; confirm dp to caculate sum(var*dp)
    wgt_qu=dim_sum_n(dp_cfm*qu,1)               ; sum(var*dp)

    wgt_qv=dim_sum_n(dp_cfm*qv,1)               ; sum(var*dp)
    
    wgt_qu = wgt_qu/9.8
    wgt_qv = wgt_qv/9.8
    delete([/qu,qv/])


    dQdx  = wgt_qu
    dQdy  = wgt_qv
    g_lon   =   wgt_qu&longitude
    g_lat   =   wgt_qu&latitude
    g_nlat  =   dimsizes(g_lat)
    ;dQdx
    dlon = (g_lon(2)-g_lon(1))*0.0174533 ; convert to radians
    
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        dQdx(:,i,:) = center_finite_diff_n (wgt_qu(:,i,:), dx , True,0,1) ; be careful with the dimison downscale
    end do

    ;dQdy
    dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    dQdy = center_finite_diff_n (wgt_qv, dy , False,0,1)
    
    divQ   =   dQdx ; copy metadata
    divQ   =   dQdx + dQdy
    divQ   =   -divQ*86400
    print("Total divQ Done!")
    
    var1_season = month_to_season(divQ,g_season)
    var4_season = month_to_season(var4,g_season)
    
    var1_season_seamean = wgt_areaave_Wrap(var1_season(:,{sea_latS:sea_latN},{sea_lonW:sea_lonE}),1.0,1.0,0)
    var4_season_seamean = wgt_areaave_Wrap(var4_season(:,{sea_latS:sea_latN},{sea_lonW:sea_lonE}),1.0,1.0,0)
    var1_season_seamean =100 * dim_rmvmean(var1_season_seamean)/dim_avg(var1_season_seamean)
    var4_season_seamean =100 * dim_rmvmean(var4_season_seamean)/dim_avg(var4_season_seamean)
    
    var1_sn_rm_searunmean=runave_Wrap(var1_season_seamean,3,0)
    var4_sn_rm_searunmean=runave_Wrap(var4_season_seamean,3,0)

    var1_sn_rm_sealine=regline(ispan(1979,yr_end,1),var1_sn_rm_searunmean)
    var4_sn_rm_sealine=regline(ispan(1979,yr_end,1),var4_sn_rm_searunmean)
    

    printVarSummary(var1_sn_rm_sealine)    
    df   = var1_sn_rm_sealine@nptxy-2
    prob = (1 - betainc(df/(df+var1_sn_rm_sealine@tval^2), df/2.0, 0.5) ) ;  also: prob = cdft_p(rc@tval,df)
    yReg = var1_season_seamean
    yReg = var1_sn_rm_sealine*ispan(1979,yr_end,1) + var1_sn_rm_sealine@yintercept   ; NCL array notation 

    df2   = var4_sn_rm_sealine@nptxy-2
    prob2 = (1 - betainc(df/(df+var4_sn_rm_sealine@tval^2), df/2.0, 0.5) ) ;  also: prob = cdft_p(rc@tval,df)
    yReg2 = var4_season_seamean
    yReg2 = var4_sn_rm_sealine*ispan(1979,yr_end,1) + var4_sn_rm_sealine@yintercept   ; NCL array notation 

    data      = new((/4,dimsizes(var1_season_seamean)/),float)
    data(0,:) = var1_sn_rm_searunmean
    data(1,:) = yReg
    data(2,:) = var4_season_seamean
    data(3,:) = yReg2

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("eps",g_fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

    plot = new((/1/),graphic)
    res@gsnFrame         = False
    res@gsnDraw  = False
             
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.3


	;res@trYMinF            = 0.9*min(var1_season_scmean)                ; Y axis limits
	;res@trYMaxF            = 1.1*max(var1_season_scmean)

	res@trYMinF            = 100               ; Y axis limits
	res@trYMaxF            = -100
    res@gsnCenterString = g_fig_title(0)
    res@gsnLeftString = "";g_fig_rank(0)
	res@trXMinF  = 0                   ; min value on x-axis
	res@trXMaxF  = dimsizes(var1_season_seamean)-1                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiYAxisString = "CVIMF and TPW Anomaly (%)"
	res@tmXBValues = ispan(0,dimsizes(var1_season_seamean)-1,5) ;interval
	res@tmXBLabels = ispan(1979,2013,5)         ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue","blue","red","red"/) ; colors chosen
	res@xyLineThicknesses	 = (/4.0,2.0,4.0,2.0/)      ; line thicknesses
	res@xyDashPatterns	 = (/0.,1.,0.,1./)      ; make all lines solid
	res@tmXBMajorThicknessF = 5.0
	res@tmYLMajorThicknessF = 5.0
	res@tmXBMinorThicknessF = 4.0
	res@tmYLMinorThicknessF = 4.0
	res@tmBorderThicknessF = 4.0
	res@tmXBLabelFontHeightF =0.022
	res@tmYLLabelFontHeightF = 0.022
	; Note that a colon is the default function code. We recommend
	; setting default code to be a tilde (~) in your .hluresfile.
	; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml


    plot(0)  = gsn_csm_xy (wks,ispan(0,dimsizes(var1_season_seamean)-1,1),data,res)   ; create plot
 
 ;---------------------------Add plot legend-----------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 4.                    ; line thicker

    ;res_lines@gsMarkerColor     = "blue"
    ;res_lines@gsMarkerIndex     = 16
    ;res_lines@gsMarkerSizeF     = 0.01
    
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    res_lines@gsLineColor       = "blue"
    yy = (/80,80/)
    xx = (/1,4/)
    text_pos = 4.5
    dum11 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum12 = gsn_add_text(wks,plot(0),"CVIMF 3yrm",text_pos,yy(0),res_text); add text
    ;dum55 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)   


    res_lines@gsLineColor       = "red"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineThicknessF  = 4.                    ; line thicker
    yy = yy - 20
    dum21 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum22 = gsn_add_text(wks,plot(0),"TPW 3yrm",text_pos,yy(0),res_text); add text
    ;dum77 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)   

   
    draw(plot)
    frame(wks)


end 
