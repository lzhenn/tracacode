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
    g_data_path3 = "/home/yangsong3/data/observation/SST/HadISST/HadISST_sst.nc"
    fig_name="../fig/paper/R1/FIGS0-nino34-composite"
    
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
    
    g_font = 0.03
    yrstrt1=197812
    yrlast1=201611
    g_fig_rank = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    ; long events larger than 10 months, develop
    g_sp_events = (/198201,198601,199101,199701,201501/)
    g_sp_text = "LE SSTA "+(/"1982/83","1986/88","1991/92","1997/98","2015/16"/)
    ;g_sp_events = (/201501/)
    ; short events with 10 months, develop
    g_su_text = "SE SSTA "+(/"1979/80","1994/95","2002/03","2004/05","2006/07","2009/10"/)
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
    
    ctrl_var1:= clmMonTLL(ctrl_var1)
    ctrl_wep = wgt_areaave_Wrap(ctrl_var1(:,{g_latS1:g_latN1},{g_lonW1:g_lonE1}), 1.0, 1.0, 0)
    ctrl_wep_anncyc = dim_rmvmean_n_Wrap(ctrl_wep,0)

    
    comp_se=new((/dimsizes(g_su_events),24/),"float")
    do ii=0, dimsizes(g_su_events)-1
        comp_strt = ind(yyyymm .eq. g_su_events(ii))-istrt-1
        comp_se(ii,:)=ctrl_nino34_idx(comp_strt:comp_strt+23)
    end do
    comp_le=new((/5,24/),"float")
    do ii=0, dimsizes(g_sp_events)-1
        comp_strt = ind(yyyymm .eq. g_sp_events(ii))-istrt-1
        comp_le(ii,:)=ctrl_nino34_idx(comp_strt:comp_strt+23)
    end do


;**********************************************************************************************
;MISSION.4		Display timeseries 
;**********************************************************************************************
    plot=new((/11/),graphic)


	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("eps",fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

    res@gsnDraw = False             
    res@gsnFrame = False             

	res@trYMinF            = -1.5                ; Y axis limits
	res@trYMaxF            = 2.5 
    res@vpWidthF = 0.7
        res@vpHeightF= 0.35


	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = 24                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    ;res@tiXAxisString = "Month"
    ;res@tiYAxisString="Deg. C"
    res@tiXAxisFontHeightF=0.03
    res@tiYAxisFontHeightF=0.03
	res@tmXBValues = ispan(1, 24, 4) ;interval
	res@tmXBLabels = (/"Jan","May","Sep","Jan","May","Sep"/)        ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue"/) ; colors chosen
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
    do ii=0, dimsizes(g_sp_events)-1
    	
        res@gsnCenterString = g_sp_text(ii)
        res@gsnLeftString = g_fig_rank(ii)
        plot(ii)  = gsn_csm_xy (wks,ispan(1,24,1),comp_le(ii,:),res)   ; create plot
    end do
    do ii=0, dimsizes(g_su_events)-1
        res@gsnCenterString = g_su_text(ii)
        res@gsnLeftString = g_fig_rank(ii+5)
    	plot(ii+5)  = gsn_csm_xy (wks,ispan(1,24,1),comp_se(ii,:),res)   ; create plot
    end do  

    gsn_panel(wks,plot,(/4,3/),False)
end




