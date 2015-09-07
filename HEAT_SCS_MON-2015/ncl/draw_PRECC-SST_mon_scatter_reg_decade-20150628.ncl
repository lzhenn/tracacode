;*************************************************************
;Aim: draw PRECC annually ltm trend 
;Mission:
;   1. Read data
;   2. Post-post process
;     2.1 take the trend 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-05-03
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN
;   2015-05-03  Change to caculate season trend 
;   2015-06-20  Change to caculate timeseries
;   2015-06-28  Change to draw sst-pr scatter plot
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------PRECC
;================================================
;global variables
    ;Define parameters
    ;g_data_path = "../data/obv/GPCP_precip.mon.mean.nc"
    g_data_path = "../data/obv/precip.mon.mean.1x1.nc"
    g_data_path2 = "../data/obv/HadISST_sst.nc"

    ;SCS+PhSea
    g_s_latS=0.
    g_s_latN=15.
    g_s_lonW=105.
    g_s_lonE=155.
    
    ;Southern China
    g_latS=20.
    g_latN=28.
    g_lonW=112.
    g_lonE=125.
    ;South China
    ;g_latS=20.
    ;g_latN=35.
    ;g_lonW=105.
    ;g_lonE=130.
    g_season = "MAM"
    ;g_season_rank=(/"DJF","MAM","JJA","SON"/)
; create an array of desired pressure levels:

        
    g_font = 0.025

    g_strt_mon = 197901 
    g_lst_mon = 201312
    g_fig_name    =   "../fig/obv/Pr-SST_-SC-scatter_regline_r2_"+g_strt_mon+"-"+g_lst_mon
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    
    g_fig_title     = g_season +" Pr~SST Scatter Plot"
   ;g_fig_title1   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr trend"  ;for dsstdt
   ;g_fig_title2   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr' trend" ;for dsst'dt


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	var1  =ctrl_in1->precip(istrt:ilast,:,:)			; p for unify the var name

	ctrl_file2   = g_data_path2
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	time_hist2    = ctrl_in2->time
    yyyymm2  = cd_calendar(time_hist2,-1)
    istrt   = ind(yyyymm2 .eq. g_strt_mon)
    ilast   = ind(yyyymm2 .eq. g_lst_mon)
	var2  =ctrl_in2->sst(istrt:ilast,:,:)			; p for unify the var name
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    var1_rgmean = wgt_areaave_Wrap(var1(:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    var2_rgmean = wgt_areaave_Wrap(var2(:,{g_s_latS:g_s_latN},{g_s_lonW:g_s_lonE}),1.0,1.0,0)
    var1_rm_mar = var1_rgmean(2::12)
    var1_rm_apr = var1_rgmean(3::12)
    var1_rm_may = var1_rgmean(4::12)
    var2_rm_mar = var2_rgmean(2::12)
    var2_rm_apr = var2_rgmean(3::12)
    var2_rm_may = var2_rgmean(4::12)

    ;1979-1988
    var1_decade0 = new(30,typeof(var1_rm_mar))
    var1_decade0(0:9)=var1_rm_mar(0:9)
    var1_decade0(10:19)=var1_rm_apr(0:9)
    var1_decade0(20:29)=var1_rm_may(0:9)
    
    var2_decade0 = new(30,typeof(var2_rm_mar))
    var2_decade0(0:9)=var2_rm_mar(0:9)
    var2_decade0(10:19)=var2_rm_apr(0:9)
    var2_decade0(20:29)=var2_rm_may(0:9)

    print("1979-1988:"+escorc(var1_decade0,var2_decade0))

    ;1989-1998
    var1_decade1 = new(30,typeof(var1_rm_mar))
    var1_decade1(0:9)=var1_rm_mar(10:19)
    var1_decade1(10:19)=var1_rm_apr(10:19)
    var1_decade1(20:29)=var1_rm_may(10:19)
    
    var2_decade1 = new(30,typeof(var2_rm_mar))
    var2_decade1(0:9)=var2_rm_mar(10:19)
    var2_decade1(10:19)=var2_rm_apr(10:19)
    var2_decade1(20:29)=var2_rm_may(10:19)


    print("1989-1998:"+escorc(var1_decade1,var2_decade1))

    ;1999-2013
    len_rst_yr =dimsizes(var1_rm_mar(20:))
    var1_decade2 = new(3*len_rst_yr,typeof(var1_rm_mar))
    var1_decade2(0:len_rst_yr-1)=var1_rm_mar(20:)
    var1_decade2(len_rst_yr:2*len_rst_yr-1)=var1_rm_apr(20:)
    var1_decade2(2*len_rst_yr:3*len_rst_yr-1)=var1_rm_may(20:)

    var2_decade2 = new(3*len_rst_yr,typeof(var2_rm_mar))
    var2_decade2(0:len_rst_yr-1)=var2_rm_mar(20:)
    var2_decade2(len_rst_yr:2*len_rst_yr-1)=var2_rm_apr(20:)
    var2_decade2(2*len_rst_yr:3*len_rst_yr-1)=var2_rm_may(20:)

    print("1999-2013:"+escorc(var1_decade2,var2_decade2))
;--------------- Caculate Regline------------------
    ;1979-1988
    var_d0_reg=regline(var2_decade0,var1_decade0)

    df   = var_d0_reg@nptxy-2
    prob = (1 - betainc(df/(df+var_d0_reg@tval^2), df/2.0, 0.5) ) ;  also: prob = cdft_p(rc@tval,df)
    yreg = var1_rm_mar(0:9)
    yreg = var_d0_reg*fspan(min(var2_decade0),max(var2_decade2),10) + var_d0_reg@yintercept   ; ncl array notation 
    
    ;1989-1998
    var_d1_reg=regline(var2_decade1,var1_decade1)

    df   = var_d1_reg@nptxy-2
    prob1 = (1 - betainc(df/(df+var_d1_reg@tval^2), df/2.0, 0.5) ) ;  also: prob = cdft_p(rc@tval,df)
    yreg1 = var1_rm_mar(0:9)
    yreg1 = var_d1_reg*fspan(min(var2_decade0),max(var2_decade2),10) + var_d1_reg@yintercept   ; ncl array notation 

    ;1999-2013
    var_d2_reg=regline(var2_decade2,var1_decade2)

    df   = var_d2_reg@nptxy-2
    prob2 = (1 - betainc(df/(df+var_d2_reg@tval^2), df/2.0, 0.5) ) ;  also: prob = cdft_p(rc@tval,df)
    yreg2 = var1_rm_mar(0:9)
    yreg2 = var_d2_reg*fspan(min(var2_decade0),max(var2_decade2),10) + var_d2_reg@yintercept   ; ncl array notation 


    data      = new((/3,dimsizes(yreg)/),float)
    data(0,:) = yreg
    data(1,:) = yreg1
    data(2,:) = yreg2
   
  
 
;**********************************************************************************************
;MISSION.3		Display timeseries 
;**********************************************************************************************



	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("eps",g_fig_name)                 ; open workstation

    labels = (/"Mar","Apr","May"/)
    colors = (/"darkgreen","blue","red"/) 

    ;gsn_define_colormap(wks,colors)
    
    plot = new((/4/),graphic)
	
    res               = True                    ; plot mods desired
    res@gsnDraw                = False
    res@gsnFrame                = False
    
    res@vpXF     = 0.2
    res@vpYF     = 0.85

    res@vpWidthF = 0.5
    res@vpHeightF= 0.5

    res@trYMinF            =  0.0               ; min value on y-axis
    res@trYMaxF            =  9.0               ; max value on y-axis
    res@trXMinF            =  27.5                  ; min value on x-axis
    res@trXMaxF            =  30.0                  ; max value on x-axis


    ;---Set some marker resources
    res@xyMarkLineMode     = "Markers"
    res@xyMarkerSizeF      = 0.015
    res@xyMarkerThicknessF = 2.0
    res@xyMarkerColor     = colors(0)  ; It's okay to list more than you need here
    res@xyMarkers          = (/4,6,7/)  ; Again, you can list more than you need.

 
    res@tmYLLabelFontHeightF = g_font
    res@tmXBLabelFontHeightF = g_font
    res@gsnStringFontHeightF = g_font
    res@tiXAxisFontHeightF   = g_font
    res@tiYAxisFontHeightF   = g_font
    plot(0)  = gsn_csm_xy (wks,(/var2_rm_mar(0:9),var2_rm_apr(0:9),var2_rm_may(0:9)/),\
                            (/var1_rm_mar(0:9),var1_rm_apr(0:9),var1_rm_may(0:9)/),res)
    
    res@xyMarkerColor     = colors(1)  ; It's okay to list more than you need here
    plot(1)  = gsn_csm_xy (wks,(/var2_rm_mar(10:19),var2_rm_apr(10:19),var2_rm_may(10:19)/),\
                            (/var1_rm_mar(10:19),var1_rm_apr(10:19),var1_rm_may(10:19)/),res)
    
    res@xyMarkerColor     = colors(2)  ; It's okay to list more than you need here
    res@gsnLeftString     = "MAM Pr-SST Scatter Plot"
    res@tiYAxisString     = "Pr Rate (mm/day)"
    res@tiXAxisString     = "SST (degC)"
    plot(2)  = gsn_csm_xy (wks,(/var2_rm_mar(20:),var2_rm_apr(20:),var2_rm_may(20:)/),\
                            (/var1_rm_mar(20:),var1_rm_apr(20:),var1_rm_may(20:)/),res)
    
  
    delete([/res@xyMarkerSizeF,res@xyMarkerColor,res@xyMarkers,res@xyMarkerThicknessF/])
    
    res@xyMarkLineMode     = "Lines"
    res@xyLineColors       = colors ; colors chosen
	res@xyLineThicknesses	 = (/6.0,6.0,6.0/)      ; line thicknesses
    res@xyDashPatterns=(/0.,0.,0./)

    
    plot(3)  = gsn_csm_xy (wks,fspan(min(var2_decade0),max(var2_decade2),10),data,res)   ; create plot



    ; add avg point
    res_avg = True 
    res_avg@gsMarkerIndex = 16
    res_avg@gsMarkerThicknessF = 8.0
    res_avg@gsMarkerSizeF = 0.02
   
    res_avg@gsMarkerColor = colors(0)
    dum = gsn_add_polymarker(wks,plot(3),var_d0_reg@xave,var_d0_reg@yave,res_avg)
    
    res_avg@gsMarkerColor = colors(1)
    dum1 = gsn_add_polymarker(wks,plot(3),var_d1_reg@xave,var_d1_reg@yave,res_avg)
    
    res_avg@gsMarkerColor = colors(2)
    dum2 = gsn_add_polymarker(wks,plot(3),var_d2_reg@xave,var_d2_reg@yave,res_avg)

    ; add R^2
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.02                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification
    res_text@txFontThicknessF   = 2.0
    text_x = 29.2
    text_y = (/2.0,1.4,0.8/)

    res_text@txFontColor        = colors(0)
    dumtext1 = gsn_add_text(wks,plot(3),"R~S~2~N~="+sprintf("%4.2f",escorc(var1_decade0,var2_decade0)),text_x,text_y(0),res_text); add text
   
    res_text@txFontColor        = colors(1)
    dumtext1 = gsn_add_text(wks,plot(3),"R~S~2~N~="+sprintf("%4.2f",escorc(var1_decade1,var2_decade1)),text_x,text_y(1),res_text); add text

    res_text@txFontColor        = colors(2)
    dumtext1 = gsn_add_text(wks,plot(3),"R~S~2~N~="+sprintf("%4.2f",escorc(var1_decade2,var2_decade2)),text_x,text_y(2),res_text); add text
    overlay(plot(0),plot(1))
    overlay(plot(0),plot(2))
    overlay(plot(0),plot(3))
    
        
    draw(plot(0))

    ;----------------------------------------------------------------------
    ; Draw Color Difference Labels ---> decades 
    ;----------------------------------------------------------------------
    labels1  = (/"1979-1988","1989-1998","1999-2013"/)
    lbres                    = True          ; labelbar only resources
    lbres@vpWidthF           = 0.1           ; labelbar width
    lbres@vpHeightF          = 0.1           ; labelbar height
    lbres@lbBoxMajorExtentF  = 0.15          ; puts space between color boxes
    lbres@lbMonoFillPattern  = True          ; Solid fill pattern
    lbres@lbLabelFontHeightF = 0.02        ; font height. default is small
    lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
    lbres@lbPerimOn          = False
    ;
    ; Each labelbar has just one label. This allows you to more
    ; easily control where the label goes.
    ; 
    xpos = (/0.17,   0.37,  0.57/)
    do i=0,dimsizes(labels1)-1
        lbres@lbFillColors     = colors(i)
        lbres@lbLabelFontColor = colors(i)
        gsn_labelbar_ndc(wks,1,labels1(i),xpos(i),0.23,lbres)
    end do
        
        
        
    
    ;----------------------------------------------------------------------
    ; Draw some markers and text.
    ;----------------------------------------------------------------------
    labels2  = (/"March","April","May"/)
    markers1 = (/     4,       6,    7/)
    xpos2    = (/  0.28,  0.43,    0.58/)
    xpos3    = (/  0.30,  0.45,    0.60/)

    mkres               = True         ; Marker resources
    
    txres               = True         ; Text resources
    txres@txFontHeightF = 0.02
    txres@txJust        = "CenterLeft"
    do i = 0,dimsizes(labels2)-1
        mkres@gsMarkerThicknessF = 3.5
        mkres@gsMarkerSizeF      = 0.015
        mkres@gsMarkerIndex      = markers1(i)
        gsn_polymarker_ndc(wks,           xpos2(i),0.21,mkres)
        gsn_text_ndc      (wks,labels2(i),xpos3(i),0.21,txres)
    end do

    frame(wks)
end 
