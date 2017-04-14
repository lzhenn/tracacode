;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================


begin
    data_file_name3="$DATAOBV/PRECT/gpcp.precip.mon.nc"
    g_data_path3 = "$DATAOBV/SST/HadISST_sst.nc"

    g_el_year=(/1979, 1982, 1986, 1991, 1994, 1997, 2004, 2006, 2009, 2015/)
    g_el_mon=(/5, 14, 17, 13, 6, 12, 10, 5, 10, 21/)

    g_fig_name="../fig/FIG4b_case_reg"
    g_fig_title="2015-2014 Pr, Surface UV & Wind Stress Curl"
    g_font =0.02
    g_fig_rank=(/"(b)(c)"/)
    ;one month rightward shift
    yrstrt0  = 197901
    yrlast0  = 201512
    g_season="MAM"
    g_season2="DJF"

;---------------Read data-------------------
    ctrl_in3 = addfile(data_file_name3,"r")
    time = ctrl_in3->time
    yyyymm =cd_calendar(time,-1)
    istrt = ind(yyyymm .eq. yrstrt0)
    ilast = ind(yyyymm .eq. yrlast0)
    var3 = ctrl_in3->precip(istrt:ilast,:,:)
    var3_ssn=month_to_season(var3,g_season)
   
    var3_idx=var3_ssn(:,0,0)
    var3_idx=(wgt_areaave_Wrap(var3_ssn(:,{5:15},{150:200}),1.0,1.0,0)+wgt_areaave_Wrap(var3_ssn(:,{-20:-5},{150:180}),1.0,1.0,0))/2-wgt_areaave_Wrap(var3_ssn(:,{-15:15},{120:150}),1.0,1.0,0)

    ctrl_file3   = g_data_path3
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile
	time_hist1    = ctrl_in3->time
    yyyymm1  = cd_calendar(time_hist1,-1)
    istrt   = ind(yyyymm1 .eq. yrstrt0)
    ilast   = ind(yyyymm1 .eq. yrlast0)
	var2  =short2flt(ctrl_in3->sst(istrt:ilast,:,:))		; p for unify the var name
    var2_ssn=month_to_season(var2,g_season2)    
    ctrl_nino34 = wgt_areaave_Wrap(var2_ssn(:,{-5:5},{-170:-120}), 1.0, 1.0, 0)
    ctrl_nino34 = dim_rmvmean(ctrl_nino34)
    nidx=dimsizes(var3_idx)
        
    rc    = regline(var3_idx(0:nidx-2),ctrl_nino34(1:))
    ;************************************************
    ; Create an array to hold both the original data
    ; and the calculated regression line.
    ;************************************************
     data      = new ( (/2,dimsizes(ctrl_nino34(1:))/), typeof(ctrl_nino34))
     data(0,:) = ctrl_nino34(1:) 
    ; y = mx+b 
    ; m is the slope:       rc      returned from regline
    ; b is the y intercept: rc@yave attribute of rc returned from regline
     data(1,:) = rc*(var3_idx(0:nidx-2)-rc@xave) + rc@yave
    ;************************************************
    ; plotting parameters
    ;************************************************
     wks  = gsn_open_wks("eps",g_fig_name)             ; send graphics to PNG file
     
     res                     = True                   ; plot mods desired
;     res@gsnMaximize         = True                   ; maximize plot in frame
     res@xyMarkLineModes     = (/"Markers","Lines"/)  ; choose which have markers
     res@xyMarkers           = 16                     ; choose type of marker 
     res@xyMarkerColor       = "red"                  ; Marker color
     res@xyMarkerSizeF       = 0.005                  ; Marker size (default 0.01)
     res@xyDashPatterns      = 1                      ; solid line 
     res@xyLineThicknesses   = (/2,2/)                ; set second line to 2

     res@gsnCenterString        = "Pr Index & NINO3.4 SST Anomaly"  ; title
     res@gsnLeftString="(d)"
     res@gsnRightString="R="+sprintf("%4.2f",escorc(ctrl_nino34(1:),var3_idx(0:nidx-2)))
     res@tiYAxisString="DJF SST Anomaly (K)"
     res@tiXAxisString="Pr Index (mm/day)"
     res@gsnStringFontHeightF=g_font
     res@tiXAxisFontHeightF=g_font
    plot  = gsn_csm_xy (wks,var3_idx(0:nidx-2),data,res)        ; create plot 

end




