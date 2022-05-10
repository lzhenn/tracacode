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

    data_file_name="~/data/forcing/ghg/ghg_rcp45_1765-2500_c100405.nc"
    fig_name="~/L_Zealot/fig/RCP45_Heat/RCP45_CO2_timeseries"
    fig_title="RCP4.5 CO2 Concentration (ppmv)"
    
    yrstrt  = 1850
    yrlast  = 2100

    slice_yrstrt = 2026
    slice_yrlast = 2035
;---------------Read data-------------------
    ctrl_in = addfile(data_file_name,"r")
    
    time = ctrl_in->time
    
    yyyy =floor( cd_calendar(time,4))
    istrt = ind(yyyy .eq. yrstrt)
    ilast = ind(yyyy .eq. yrlast)
   
    delete(yyyy)
    t    = time(istrt:ilast) 
    yyyy =floor( cd_calendar(t,4))
    var1 = ctrl_in->CO2(istrt:ilast)
    var2 = ctrl_in->CH4(istrt:ilast)
    var3 = ctrl_in->N2O(istrt:ilast)
    var4 = ctrl_in->f11(istrt:ilast)
    var5 = ctrl_in->f12(istrt:ilast)

;--------------Calculate RCP4.5 2026-35 period mean-----------
   
    ircp_strt = ind(yyyy .eq. slice_yrstrt)
    ircp_last = ind(yyyy .eq. slice_yrlast)
    force_var1 = avg(var1(ircp_strt:ircp_last))
    force_var2 = avg(var2(ircp_strt:ircp_last))
    force_var3 = avg(var3(ircp_strt:ircp_last))
    force_var4 = avg(var4(ircp_strt:ircp_last))
    force_var5 = avg(var5(ircp_strt:ircp_last))

    print("CO2: "+force_var1+"ppm")
    print("CH4: "+force_var2+"ppb")
    print("N2O: "+force_var3+"ppb")
    print("f11: "+force_var4+"ppt")
    print("f12: "+force_var5+"ppt")
;------------------Draw Time Series----------------

;**********************************************************************************************
;MISSION.4		Display timeseries 
;**********************************************************************************************



	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("eps",fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

             
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.3


	res@trYMinF            = min(var1)-20                ; Y axis limits
	res@trYMaxF            = max(var1)+20

    res@gsnCenterString = fig_title
	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = dimsizes(var1)                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiXAxisString = "Year"
	res@tmXBValues = ispan(0,250,25) ;interval
	res@tmXBLabels = ispan(1850,2100,25)         ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue"/) ; colors chosen
	res@xyLineThicknesses	 = (/4.0/)      ; line thicknesses
	res@xyDashPatterns	 = (/0./)      ; make all lines solid
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
	;
	 top_plot  = gsn_csm_xy (wks,ispan(0,250,1),var1,res)   ; create plot
end




