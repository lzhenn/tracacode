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

    data_file_name1="/HOME/sysu_hjkx_ys/WORKSPACE/data/model/B2000_f09_CAM5PM_spin-up/B2000_f09_CAM5PM_spin-up.cam.h0.TS.201-250.nc"
    data_file_name2="/HOME/sysu_hjkx_ys/WORKSPACE/data/model/L_Zealot/SCS_ANNCYC-2015/pro/B2000_f09_CAM5PM_SCS_ANNCYC.cam.h0.TS.201-250.nc"
    fig_name="/HOME/sysu_hjkx_ys/WORKSPACE/L_Zealot/project/SCS_ANNCYC-2015/fig/auto-fig/PM_spin-up_nino34"
    fig_title="NINO3.4 INDEX Timeseries"
    
    yrstrt  = 20102
    yrlast  = 25101

;---------------Read data-------------------
    ctrl_in1 = addfile(data_file_name1,"r")
    exp_in1 = addfile(data_file_name2,"r")
    
    time = ctrl_in1->time
    
    yyyymm =floor( cd_calendar(time,-1))
    istrt = ind(yyyymm .eq. yrstrt)
    ilast = ind(yyyymm .eq. yrlast)
   
    delete(yyyymm)
    t    = time(istrt:ilast) 
    yyyy =floor( cd_calendar(t,4))
    ctrl_var1 = ctrl_in1->TS(istrt:ilast,:,:)
    exp_var1 = exp_in1->TS(istrt:ilast,:,:)
;--------------Proprocessing-----------
    ctrl_nino34 = wgt_areaave(ctrl_var1(:,{-5:5},{190:240}), 1.0, 1.0, 0)
    ctrl_rmean_nino34 = runave_Wrap(ctrl_nino34,3,0)
    ctrl_nino34_idx = rmAnnCycle1D(ctrl_rmean_nino34)

    exp_nino34 = wgt_areaave(exp_var1(:,{-5:5},{190:240}), 1.0, 1.0, 0)
    exp_rmean_nino34 = runave_Wrap(exp_nino34,3,0)
    exp_nino34_idx = rmAnnCycle1D(exp_rmean_nino34)

    data=new((/2,dimsizes(exp_nino34)/),float)
    data(0,:)=ctrl_nino34_idx
    data(1,:)=exp_nino34_idx
    print(data)
;--------count-----------
    ctrl_n_el=sum(where(ctrl_nino34_idx .gt. 0.5,1,ctrl_var1@_FillValue))
    ctrl_n_la=sum(where(ctrl_nino34_idx .lt. -0.5,1,ctrl_var1@_FillValue))
    exp_n_el=sum(where(exp_nino34_idx .gt. 0.5,1,exp_var1@_FillValue))
    exp_n_la=sum(where(exp_nino34_idx .lt. -0.5,1,exp_var1@_FillValue))
    print(ctrl_n_el)
    print(ctrl_n_la)
    print(exp_n_el)
    print(exp_n_la)

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


	res@trYMinF            = min(exp_nino34_idx)-0.5                ; Y axis limits
	res@trYMaxF            = max(exp_nino34_idx)+0.5

    res@gsnCenterString = fig_title
	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = dimsizes(exp_nino34_idx)                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiXAxisString = "Year"
	res@tmXBValues = ispan(1, 600, 60) ;interval
	res@tmXBLabels = ispan(201,250,5)         ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue","red"/) ; colors chosen
	res@xyLineThicknesses	 = (/4.0,4.0/)      ; line thicknesses
	res@xyDashPatterns	 = (/0.,0./)      ; make all lines solid
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
	 top_plot  = gsn_csm_xy (wks,ispan(1,600,1),data,res)   ; create plot
end




