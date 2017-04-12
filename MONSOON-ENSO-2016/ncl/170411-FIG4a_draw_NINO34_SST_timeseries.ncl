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
    data_file="/Users/zhenningli/data/obv/SST/sst.mnmean.nc"
    fig_name="../fig/nino34-2016case"
    fig_title="NINO3.4 Index Timeseries"
    
    ;one month rightward shift
    yrstrt1  = 201401
    yrlast1  = 201512
    yrstrt2  = 201501
    yrlast2  = 201612

    ;NINO3.4 region
    g_lonW = 190
    g_lonE = 240
    g_latS = -5
    g_latN = 5
    g_font = 0.017
;---------------Read data-------------------
    ctrl_in1 = addfile(data_file,"r")
    time = ctrl_in1->time
    yyyymm =cd_calendar(time(1:),-1)
    var1 = short2flt(ctrl_in1->sst(1:,:,:))

;--------------Proprocessing-----------
    clim_var1 = clmMonTLL(var1)
    clim_nino34 = wgt_areaave_Wrap(clim_var1(:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    
    
    istrt = ind(yyyymm .eq. yrstrt1)
    ilast = ind(yyyymm .eq. yrlast1)
    var1_1415=var1(istrt:ilast,:,:)
    nino34_1415 = wgt_areaave_Wrap(var1_1415(:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    nino34_1415(0:11) = nino34_1415(0:11) - clim_nino34
    nino34_1415(12:) = nino34_1415(12:) - clim_nino34

    istrt = ind(yyyymm .eq. yrstrt2)
    ilast = ind(yyyymm .eq. yrlast2)
    var1_1516=var1(istrt:ilast,:,:)
    nino34_1516 = wgt_areaave_Wrap(var1_1516(:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    nino34_1516(0:11) = nino34_1516(0:11) - clim_nino34
    nino34_1516(12:) = nino34_1516(12:) - clim_nino34

   
    data=new((/2,24/),float)
    data(0,:)=nino34_1415
    data(1,:)=nino34_1516

;**********************************************************************************************
;MISSION.4		Display timeseries 
;**********************************************************************************************



	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("eps",fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

    res@gsnDraw = False             
    res@gsnFrame = False             
    res@vpXF     = 0.15

    res@vpWidthF = 0.55
    res@vpHeightF= 0.12


	res@trYMinF            = min(nino34_1415)-0.5                ; Y axis limits
	res@trYMaxF            = max(nino34_1516)+0.5

    res@gsnCenterString = fig_title
    res@gsnLeftString = "(a)"
	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = dimsizes(data(0,:))                   ; max value on x-axis
	res@tmXTOn  = False
	res@tmYROn  = False
    res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiXAxisString = ""
    res@tiYAxisString="SST Anomaly"
	res@tmXBValues = ispan(1, 24, 2) ;interval
	res@tmXBLabels = (/"Jan","Mar","May","Jul","Sep","Nov","Jan","Mar","May","Jul","Sep","Nov"/)        ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue","red"/) ; colors chosen
	res@xyLineThicknesses	 = (/2.0,2.0/)      ; line thicknesses
	res@xyDashPatterns	 = (/0.,0./)      ; make all lines solid
    res@tmXBMajorThicknessF = 2.0
	res@tmYLMajorThicknessF = 2.0
	res@tmXBMinorThicknessF = 1.0
	res@tmYLMinorThicknessF = 1.0
	res@tmBorderThicknessF = 2.0
    ;res@tmXBMajorLengthF= 0.005
	res@tmXBLabelFontHeightF =g_font
	res@tmYLLabelFontHeightF =g_font
	; Note that a colon is the default function code. We recommend
	; setting default code to be a tilde (~) in your .hluresfile.
	; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
	;
	 plot  = gsn_csm_xy (wks,ispan(1,24,1),data,res)   ; create plot
    
   ;--------------------------------------------------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    res_lines@gsLineColor       = "blue"
    
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    yy = (/3.0,3.0/)
    xx = (/1.5,3.0/)
    text_pos = xx(1)+0.3
    dum1 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum2 = gsn_add_text(wks,plot,"2014-15",text_pos,yy(0),res_text); add text
    
    res_lines@gsLineColor = "red"
    yy = yy-0.75
    dum3 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum4 = gsn_add_text(wks,plot,"2015-16",text_pos,yy(0),res_text); add text
    
   


    draw(plot)
    frame(wks)

end




