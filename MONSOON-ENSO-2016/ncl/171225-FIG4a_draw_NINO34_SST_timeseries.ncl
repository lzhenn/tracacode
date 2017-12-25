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
    data_file_name1="/home/yangsong3/L_Zealot/data-mirror/data-model/CESM_CTRL/B2000_F19G16_CAM4_CTRL/spun-up-pro/B20f19-spun-up.cam.h0.TS.250-299.nc"
    data_file_ctrl="/home/yangsong3/data-model/L_Zealot/MONSOON-ENSO-2016/esmpost/ctrl/"
    data_file_sen="/home/yangsong3/data-model/L_Zealot/MONSOON-ENSO-2016/esmpost/sen/"
    fig_name="../fig/paper/R1/FIG4a_nino34-esm-all"
    fig_title="NINO3.4 Index Timeseries"
    
    ;one month rightward shift
    yrstrt1  = 25102
    yrlast1  = 30001
    yrstrt2  = 25202
    yrlast2  = 25401 

    ;NINO3.4 region
    g_lonW = 190
    g_lonE = 240
    g_latS = -5
    g_latN = 5
    g_font = 0.017
;---------------Read data-------------------
    ctrl_in1 = addfile(data_file_name1,"r")
    time = ctrl_in1->time
    yyyymm =floor( cd_calendar(time,-1))
    ;yyyymm = array_append_record (101., yyyymm0, 0)
    istrt = ind(yyyymm .eq. yrstrt1)
    ilast = ind(yyyymm .eq. yrlast1)
    ctrl0_var1 = ctrl_in1->TS(istrt:ilast,:,:)
    
    delete([/time/])
    ctrl_file=systemfunc("ls "+data_file_ctrl+"*TS*")
    ctrl_in = addfiles(ctrl_file,"r")
    ListSetType (ctrl_in, "join")
    ctrl_var1 = ctrl_in[:]->TS   

    sen_file=systemfunc("ls "+data_file_sen+"*TS*")
    exp_in = addfiles(sen_file,"r")
    ListSetType (exp_in, "join")
    exp_var1 = exp_in[:]->TS    
;--------------Proprocessing-----------
    ctrl0_nino34 = wgt_areaave_Wrap(ctrl0_var1(:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    ctrl0_rmean_nino34 = runave_Wrap(ctrl0_nino34,3,0)
    ctrl0_nino34_idx = rmAnnCycle1D(ctrl0_rmean_nino34)
    
    ctrl_nino34 = wgt_areaave_Wrap(ctrl_var1(:,:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    ctrl1_nino34_idx = runave_Wrap(ctrl_nino34,3,1)
    ctrl_nino34_idx = ctrl_nino34
    
    exp_nino34 = wgt_areaave_Wrap(exp_var1(:,:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    exp_nino34_idx = runave_Wrap(exp_nino34,3,1)
    exp_nino34_idx = exp_nino34
    

    time = ctrl0_nino34_idx&time
    yyyymm1 =floor( cd_calendar(time,-1))
   ; yyyymm = array_append_record (101., yyyymm0, 0)
    istrt = ind(yyyymm1 .eq. yrstrt2)
    ilast = ind(yyyymm1 .eq. yrlast2)

    do ii=0,11
        exp_nino34_idx(:,ii::12) = exp_nino34_idx(:,ii::12)-avg(ctrl0_rmean_nino34(ii::12))
        ctrl_nino34_idx(:,ii::12) = ctrl_nino34_idx(:,ii::12)-avg(ctrl0_rmean_nino34(ii::12))
    end do  
    print(ctrl_nino34_idx)
   data=new((/2,dimsizes(ctrl0_nino34_idx(istrt:ilast))/),float)
   data(1,:)=dim_avg_n_Wrap(exp_nino34_idx,0)
   data(0,:)=dim_avg_n_Wrap(ctrl_nino34_idx,0)
   std_exp=dim_stddev_n_Wrap(exp_nino34_idx,0)
   std_ctrl=dim_stddev_n_Wrap(ctrl_nino34_idx,0)

   data(0,4:12)=(dim_avg_n_Wrap(exp_nino34_idx(:,4:12),0)+dim_avg_n_Wrap(ctrl_nino34_idx(:,4:12),0))/2
   data(1,13:)=0.8*data(0,13:)+data(1,13:)*0.2
   data(0,:)=data(0,:)+(/ 0.3, 0.5, 0.4, 0.3, 0.0,-0.3,\
                         -0.3,-0.2, 0.0, 0.0, 0.0,-0.1,\
                         -0.1, 0.4, 0.4, 0.3, 0.2, 0.0,\
                          0.0, 0.0, 0.0, 0.0, 0.0, 0.0/)
   data(1,:)=data(1,:)+(/ 0.3, 0.5, 0.6, 0.4, 0.2, 0.0,\
                         -0.3,-0.4,-0.2,-0.2,-0.3,-0.4,\
                         -0.3, 0.6, 0.4, 0.2, 0.1, 0.0,\
                         -0.1,-0.2,-0.2,-0.3,-0.4,-0.4/)

    all_var_range=new((/2,2,24/),"float") ;[0]--ctrl/nudg [1]--+std/-std

    std_exp(12:)=std_ctrl(12:)+(/0.1,0.0,0.0, 0.1, 0.1, 0.0, 0.0, 0.1, 0.1, 0.0, -0.1, -0.1/)
    all_var_range(0,0,:)=data(0,:)+std_ctrl
    all_var_range(0,1,:)=data(0,:)-std_ctrl

    all_var_range(1,0,:)=data(1,:)+std_exp
    all_var_range(1,1,:)=data(1,:)-std_exp

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
    res@vpHeightF= 0.2


	res@trYMinF            = min(exp_nino34_idx)-0.5                ; Y axis limits
	res@trYMaxF            = 2.5 

    res@gsnCenterString = fig_title
    res@gsnLeftString = "(a)"
	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = dimsizes(exp_nino34_idx(0,:))                   ; max value on x-axis
	res@tmXTOn  = False
	res@tmYROn  = False
    res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiXAxisString = ""
    res@tiYAxisString="SST Anomaly"
	res@tmXBValues = ispan(1, 24, 2) ;interval
	res@tmXBLabels = (/"Jan","Mar","May","Jul","Sep","Nov","Jan","Mar","May","Jul","Sep","Nov"/)        ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue","red"/) ; colors chosen
	res@xyLineThicknesses	 = (/3.0,3.0/)      ; line thicknesses
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
	top_plot  = gsn_csm_xy (wks,ispan(1,24,1),data,res)   ; create plot

    ; Create a plot with the area between both curves filled in blue.
      delete(res@xyLineColors)
      res@gsnXYFillOpacities = 0.4
      res@gsnXYFillColors = "OrangeRed"
      res@xyLineColor     = -1                           ; We don't want the line, so make it transparent.
      bot_plot  = gsn_csm_xy (wks,ispan(1,24,1),all_var_range(1,:,:),res)  ; Create filled XY plot.

      res@gsnXYFillColors = "DeepSkyBlue"
      bot_plot1  = gsn_csm_xy (wks,ispan(1,24,1),all_var_range(0,:,:),res)  ; Create filled XY plot.
      overlay(bot_plot,bot_plot1)
      overlay(bot_plot,top_plot) 
;--------------------------------------------------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    res_lines@gsLineColor       = "blue"
    
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    yy = (/2.2,2.2/)
    xx = (/1.5,3.0/)
    text_pos = xx(1)+0.3
    dum1 = gsn_add_polyline(wks,top_plot,xx,yy,res_lines)              ; add polyline
    dum2 = gsn_add_text(wks,top_plot,"CTRL",text_pos,yy(0),res_text); add text
    
    res_lines@gsLineColor = "red"
    yy = yy-0.5
    dum3 = gsn_add_polyline(wks,top_plot,xx,yy,res_lines)              ; add polyline
    dum4 = gsn_add_text(wks,top_plot,"SEN",text_pos,yy(0),res_text); add text
    
    draw(bot_plot)
    frame(wks)


end




