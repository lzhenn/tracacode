;*****************************************************
;Missions:
;   1. Read AERO of RCP and F2000 forcing field
;   2. Test if AERO in 2000 is the same 
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;================================================
;Variables List:
;	var1--------------CB1 Aerosol in F2000
;	var1--------------CB1 Aerosol in RCP4.5
;================================================



begin

    data1_file_name="~/data/forcing/aero/aero_1.9x2.5_L26_2000clim_c091112.nc"
    data2_file_name="~/data/forcing/aero/aero_rcp45_v1_1.9x2.5_L26_1995-2105_c100316.nc"
    
    test_ym=200010
;---------------Read data-------------------
    ctrl_in1 = addfile(data1_file_name,"r")
    
    time1 = ctrl_in1->time
    
    yyyy =cd_calendar(time1,1)
    idx = ind(yyyy .eq. test_ym)
   
    delete(yyyy)
    var1 = ctrl_in1->CB1(idx,:,:,:)
    print(var1(0,{30},{110:120}))
;--------------Calculate RCP4.5 2026-35 period mean-----------
    ctrl_in2 = addfile(data2_file_name,"r")
    
    time2 = ctrl_in2->time
    
    yyyy =cd_calendar(time2,1)
    idx = ind(yyyy .eq. test_ym)
    var2 = ctrl_in2->CB1(idx,:,:,:)
    print(var2(0,{30},{110:120}))
  
exit
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
    res@vpHeightF= 0.15


	res@trYMinF            = min(ctrl_var_gmean)-0.1                ; Y axis limits
	res@trYMaxF            = max(ctrl_var_gmean)+0.1

	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = dimsizes(ctrl_var_gmean)                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.


    res@tiYAxisString = "TS departure"
    res@tiXAxisString = "Year"
	res@tmXBValues = ispan(0,2400,240) ;interval
	res@tmXBLabels = ispan(0,200,20)         ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue"/) ; colors chosen
	res@xyLineThicknesses	 = (/1/)      ; line thicknesses
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
	 res@tiMainString = fig_title 
	 top_plot  = gsn_csm_xy (wks,ispan(1,2400,1),ctrl_var_gmean,res)   ; create plot
end




