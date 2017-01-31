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
    data_file_name1="/home/yangsong3/data-model/CESM_CTRL/B2000_F09G16_CAM5PM_CTRL/pro/B2000_f09_CAM5PM_spin-up.cam.h0.TS.1-300.nc"
    data_file_name2="/home/yangsong3/data-model/L_Zealot/MONSOON-ENSO-2016/esmpost/"
    fig_name="../fig/nino34-esm-ctrl"
    fig_title="NINO3.4 INDEX Timeseries"
    
    ;one month rightward shift
    yrstrt1  = 20102
    yrlast1  = 30101
    yrstrt2  = 26102
    yrlast2  = 26301 

    ;NINO3.4 region
    g_lonW = 190
    g_lonE = 240
    g_latS = -5
    g_latN = 5
    g_font = 0.02
;---------------Read data-------------------
    ctrl_in1 = addfile(data_file_name1,"r")
    time = ctrl_in1->time
    yyyymm =floor( cd_calendar(time,-1))
    ;yyyymm = array_append_record (101., yyyymm0, 0)
    istrt = ind(yyyymm .eq. yrstrt1)
    ilast = ind(yyyymm .eq. yrlast1)
    ctrl_var1 = ctrl_in1->TS(istrt:ilast,:,:)
    
    delete([/time/])
    all_file=systemfunc("ls "+data_file_name2+"*ESMc*TS*")
    exp_in = addfiles(all_file,"r")
    ListSetType (exp_in, "join")
    exp_var1 = exp_in[:]->TS    
;--------------Proprocessing-----------
    ctrl_nino34 = wgt_areaave_Wrap(ctrl_var1(:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    ctrl_rmean_nino34 = runave_Wrap(ctrl_nino34,3,0)
    ctrl_nino34_idx = rmAnnCycle1D(ctrl_rmean_nino34)
    print(yyyymm(istrt:ilast)+": "+ctrl_nino34_idx(:))
    exp_nino34 = wgt_areaave_Wrap(exp_var1(:,:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    ;exp_nino34_idx = runave_Wrap(exp_nino34,3,1)
    exp_nino34_idx = exp_nino34
    
    time = ctrl_nino34_idx&time
    yyyymm1 =floor( cd_calendar(time,-1))
   ; yyyymm = array_append_record (101., yyyymm0, 0)
    istrt = ind(yyyymm1 .eq. yrstrt2)
    ilast = ind(yyyymm1 .eq. yrlast2)


    do ii=0,11
        exp_nino34_idx(:,ii::12) = exp_nino34_idx(:,ii::12)-avg(ctrl_rmean_nino34(ii::12))
    end do   

    
    data=new((/2,dimsizes(ctrl_nino34_idx(istrt:ilast))/),float)
   data(0,:)=ctrl_nino34_idx(istrt:ilast)
   data(1,:)=dim_avg_n_Wrap(exp_nino34_idx,0)
   print (yyyymm1(istrt:ilast)+" CTRL:"+data(0,:)+" EXP:"+data(1,:))
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

    res@vpWidthF = 0.8
    res@vpHeightF= 0.3


	res@trYMinF            = min(exp_nino34_idx)-0.5                ; Y axis limits
	res@trYMaxF            = max(exp_nino34_idx)+0.5

    res@gsnCenterString = fig_title
	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = dimsizes(exp_nino34_idx(0,:))                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiXAxisString = "Month"
    res@tiYAxisString="SST Anomaly"
	res@tmXBValues = ispan(1, 24, 2) ;interval
	res@tmXBLabels = (/"Jan","Mar","May","Jul","Sep","Nov","Jan","Mar","May","Jul","Sep","Nov"/)        ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue","red"/) ; colors chosen
	res@xyLineThicknesses	 = (/4.0,4.0/)      ; line thicknesses
	res@xyDashPatterns	 = (/0.,0./)      ; make all lines solid
    res@tmXBMajorThicknessF = 4.0
	res@tmYLMajorThicknessF = 4.0
	res@tmXBMinorThicknessF = 3.0
	res@tmYLMinorThicknessF = 3.0
	res@tmBorderThicknessF = 3.0
	res@tmXBLabelFontHeightF =g_font
	res@tmYLLabelFontHeightF =g_font
	; Note that a colon is the default function code. We recommend
	; setting default code to be a tilde (~) in your .hluresfile.
	; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml
	;
	 top_plot  = gsn_csm_xy (wks,ispan(1,24,1),data,res)   ; create plot
    
    
    res2               = res                    ; plot mods desired
 	delete([/res2@xyLineColors,res2@xyLineThicknesses,res2@xyDashPatterns/])
    res2@xyLineColor       = "grey" ; colors chosen
	res2@xyLineThicknessF	 = 2.0      ; line thicknesses
	res2@xyDashPattern	 = 0      ; make all lines solid
    plot  = gsn_csm_xy (wks,ispan(1,24,1),exp_nino34_idx,res2)   ; create plot
    overlay(plot,top_plot)
;--------------------------------------------------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 4.                    ; line thicker
    res_lines@gsLineColor       = "blue"
    
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    yy = (/3.0,3.0/)
    xx = (/1.5,3.0/)
    text_pos = xx(1)+0.3
    dum1 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum2 = gsn_add_text(wks,plot,"CTRL",text_pos,yy(0),res_text); add text
    
    res_lines@gsLineColor = "red"
    yy = yy-0.5
    dum3 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum4 = gsn_add_text(wks,plot,"ESM_MEAN",text_pos,yy(0),res_text); add text
    
    res_lines@gsLineColor = "grey"
    res_lines@gsLineThicknessF = 2.0
    yy = yy-0.5
     dum5 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum6 = gsn_add_text(wks,plot,"ESM_MEMBER",text_pos,yy(0),res_text); add text
    


    draw(plot)
    frame(wks)

end




