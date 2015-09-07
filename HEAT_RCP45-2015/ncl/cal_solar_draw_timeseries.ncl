;*****************************************************
;Missions:
;   1. Read solar data of RCP forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Annual Timeseries of solar
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;================================================
;Variables List:
;	var1--------------tsi solar radiation
;================================================



begin

    data_file_name="~/data/forcing/solar/SOLAR_TSI_Lean_1610-2140_annual_c100301.nc"
    fig_name="~/L_Zealot/fig/RCP45_Heat/RCP45_solar_timeseries"
    fig_title="RCP4.5 Solar Radiation (W/m^2)"
    
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
    var1 = ctrl_in->tsi(istrt:ilast)

;--------------Calculate RCP4.5 2026-35 period mean-----------
   
    ircp_strt = ind(yyyy .eq. slice_yrstrt)
    ircp_last = ind(yyyy .eq. slice_yrlast)
    force_var1 = avg(var1(ircp_strt:ircp_last))

    print("Solar radiation: "+force_var1+"W/m^2")
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


	res@trYMinF            = min(var1)-0.5               ; Y axis limits
	res@trYMaxF            = max(var1)+0.5

    res@gsnCenterString = fig_title
	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = dimsizes(var1)                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiXAxisString = "Year"
    res@tiYAxisString = "Solar"
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





