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
    g_data_path3 = "/Users/zhenningli/data/obv/SST/HadISST_sst.nc"
    fig_name="../fig/FIG0-nino34-composite"
    
    ;NINO3.4 region
    g_lonW = -170
    g_lonE = -120
    g_latS = -5
    g_latN = 5
    
    ; WEP
    g_lonW1 = 130
    g_lonE1 = 160
    g_latS1 = -5
    g_latN1 = 5
    
    g_font = 0.02
    yrstrt1=197812
    yrlast1=201611

    ; long events larger than 10 months, develop
    g_sp_events = (/198201,198601,199101,199701,201501/)
    ;g_sp_events = (/201501/)
    ; short events with 10 months, develop
    g_su_events = (/197901,199401,200201,200401,200601,200901/)
;---------------Read data-------------------
    ctrl_in1 = addfile(g_data_path3,"r")
    time = ctrl_in1->time
    yyyymm =floor( cd_calendar(time,-1))
    ;yyyymm = array_append_record (101., yyyymm0, 0)
    istrt = ind(yyyymm .eq. yrstrt1)
    ilast = ind(yyyymm .eq. yrlast1)
    ctrl_var1_temp = ctrl_in1->sst(istrt:ilast,:,:)
    
    dim_var1=dimsizes(ctrl_var1_temp)

    ctrl_var1 =ctrl_var1_temp
    ctrl_var1(0:dim_var1(0)-2,:,:) =ctrl_var1_temp(1:dim_var1(0)-1,:,:)
    ctrl_var1(dim_var1(0)-1,:,:) =ctrl_var1_temp(dim_var1(0)-1,:,:)

;--------------Proprocessing-----------
    ctrl_nino34 = wgt_areaave_Wrap(ctrl_var1(:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    ctrl_rmean_nino34 = runave_Wrap(ctrl_nino34,3,1)
    ctrl_nino34_idx = rmAnnCycle1D(ctrl_rmean_nino34)
    
    printVarSummary(ctrl_nino34_idx)
    ctrl_var1:= clmMonTLL(ctrl_var1)
    ctrl_wep = wgt_areaave_Wrap(ctrl_var1(:,{g_latS1:g_latN1},{g_lonW1:g_lonE1}), 1.0, 1.0, 0)
    ctrl_wep_anncyc = dim_rmvmean_n_Wrap(ctrl_wep,0)

    comp_le=ctrl_nino34_idx(1:24)
    comp_se=ctrl_nino34_idx(1:24)
    comp_le=0
    comp_se=0
    do ii=0, dimsizes(g_su_events)-1
        comp_strt = ind(yyyymm .eq. g_su_events(ii))-istrt-1
        comp_se=comp_se+ctrl_nino34_idx(comp_strt:comp_strt+23)
    end do
    do ii=0, dimsizes(g_sp_events)-1
        comp_strt = ind(yyyymm .eq. g_sp_events(ii))-istrt-1
        comp_le=comp_se+ctrl_nino34_idx(comp_strt:comp_strt+23)
    end do
    comp_se=comp_se/dimsizes(g_su_events)
    comp_le=comp_le/dimsizes(g_sp_events)

    data=new((/2,24/),"float")
    data(0,:)=comp_le
    data(1,:)=comp_se

    ctrl_wep0=comp_le
    ctrl_wep0(0:11)=ctrl_wep_anncyc
    ctrl_wep0(12:23)=ctrl_wep_anncyc
;**********************************************************************************************
;MISSION.4		Display timeseries 
;**********************************************************************************************
    plot=new((/2/),graphic)


	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("eps",fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

    res@gsnDraw = False             
    res@gsnFrame = False             
    res@vpXF     = 0.15

    res@vpWidthF = 0.7
    res@vpHeightF= 0.35


	res@trYMinF            = min(comp_le)-0.5                ; Y axis limits
	res@trYMaxF            = max(comp_le)+0.5

    res@gsnCenterString = "Composite SSTA" 
    res@gsnLeftString = "(a)"
	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = 24                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    ;res@tiXAxisString = "Month"
    ;res@tiYAxisString="Deg. C"
    res@tiXAxisFontHeightF=0.022
    res@tiYAxisFontHeightF=0.022
	res@tmXBValues = ispan(1, 24, 2) ;interval
	res@tmXBLabels = (/"Jan","Mar","May","Jul","Sep","Nov","Jan","Mar","May","Jul","Sep","Nov"/)        ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue","red"/) ; colors chosen
	res@xyLineThicknesses	 = (/3.0,3.0/)      ; line thicknesses
	res@xyDashPatterns	 = (/0.,0./)      ; make all lines solid
    res@tmXBMajorThicknessF = 2.0
	res@tmYLMajorThicknessF = 2.0
	res@tmXBMinorThicknessF = 2.0
	res@tmYLMinorThicknessF = 2.0
	res@tmBorderThicknessF = 2.0
	res@tmXBLabelFontHeightF =g_font
	res@tmYLLabelFontHeightF =g_font
    res@gsnStringFontHeightF =g_font
    ; Note that a colon is the default function code. We recommend
	; setting default code to be a tilde (~) in your .hluresfile.
	; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
	;
	plot(0)  = gsn_csm_xy (wks,ispan(1,24,1),data,res)   ; create plot
    
    
    
    
    res@trYMinF            = -0.6               ; Y axis limits
	res@trYMaxF            = 0.6


    res@gsnLeftString="(b)"
    res@gsnCenterString="SST Annual Cycle"
	plot(1)  = gsn_csm_xy (wks,ispan(1,24,1),ctrl_wep0,res)   ; create plot


;--------------------------------------------------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    res_lines@gsLineColor       = "blue"
    
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.018                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    yy = (/1.5,1.5/)
    xx = (/18,20/)
    text_pos = xx(1)+0.3
    dum1 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum2 = gsn_add_text(wks,plot(0),"LE",text_pos,yy(0),res_text); add text
    
    res_lines@gsLineColor = "red"
    yy = yy-0.5
    dum3 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum4 = gsn_add_text(wks,plot(0),"SE",text_pos,yy(0),res_text); add text
   

    res_lines@gsLineDashPattern = 2.                    ; solid line
    res_lines@gsLineThicknessF  = 2.                    ; line thicker
    res_lines@gsLineColor       = "grey"
    yy = (/0.5,0.5/)
    xx = (/1,24/)
    dum11 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    
    yy = (/0,0/)
    xx = (/1,24/)
    dum12 = gsn_add_polyline(wks,plot(1),xx,yy,res_lines)              ; add polyline
    

    gsn_panel(wks,plot,(/2,1/),False)
end




