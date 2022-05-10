;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"

begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = (/"PRECC","PRECL"/)
    g_data_ctrl_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl"
    g_data_nudg_path ="/Users/zhenningli/data/CAL_SCSSM-2016/nudging_test"

    g_font = 0.025
    
    ;Andaman Sea convection
    g_latS=5.
    g_latN=20.
    g_lonW=85
    g_lonE=100.

    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/model-esm-nudg-prmax-std"
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)"/)
    g_fig_title   = "BOB Pr Daily Max Evolution"

    npos_year = 0
    nneg_year = 0

;Prepare the variables
    ctrl_in_files = systemfunc("ls "+g_data_ctrl_path+"/*ESMc_0*"+g_var_name(0)+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in     := addfiles (ctrl_in_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "join")
    var  =ctrl_in[:]->$g_var_name(0)$
    
    ctrl_in_files = systemfunc("ls "+g_data_ctrl_path+"/*ESMc_0*"+g_var_name(1)+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in     := addfiles (ctrl_in_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "join")
    var2  =ctrl_in[:]->$g_var_name(1)$ 

    var=1000*86400*(var+var2)
    printVarSummary(var)

    var_areamean=wgt_areaave_Wrap(var(:,1:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    var_mean=dim_max_n_Wrap(var_areamean,0)  
    ;var_areamean=runave_n_Wrap(var_areamean,5,1,1)  
    var_stddev=dim_stddev_n_Wrap(var_areamean,0)
 
    nudg_in_files = systemfunc("ls "+g_data_nudg_path+"/*n[3-4]*"+g_var_name(0)+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    nudg_in     := addfiles (nudg_in_files, "r")   ; note the "s" of addfile
    ListSetType (nudg_in, "join")
    var_nudg=nudg_in[:]->$g_var_name(0)$

    printVarSummary(var_nudg)

    nudg_in_files = systemfunc("ls "+g_data_nudg_path+"/*n[3-4]*"+g_var_name(1)+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    nudg_in     := addfiles (nudg_in_files, "r")   ; note the "s" of addfile
    ListSetType (nudg_in, "join")
    var2_nudg=nudg_in[:]->$g_var_name(1)$

    var_nudg=(var_nudg+var2_nudg)*86400*1000

    var_nudg_areamean=wgt_areaave_Wrap(var_nudg(:,1:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    var_nudg_mean=dim_max_n_Wrap(var_nudg_areamean,0)  
    ;var_nudg_areamean=runave_n_Wrap(var_nudg_areamean,5,1,1)  
    var_nudg_stddev=dim_stddev_n_Wrap(var_nudg_areamean,0)

    dim_var=dimsizes(var_mean)
    all_var_ltm=new((/2,dim_var(0)/),"float")
    all_var_ltm(0,:)=var_mean
    all_var_ltm(1,:)=var_nudg_mean
   
    printVarSummary(var_mean)
    all_var_range=new((/2,2,dim_var(0)/),"float") ;[0]--ctrl/nudg [1]--+std/-std

    all_var_range(0,0,:)=var_mean+var_stddev
    all_var_range(0,1,:)=var_mean-var_stddev

    all_var_range(1,0,:)=var_nudg_mean+var_nudg_stddev
    all_var_range(1,1,:)=var_nudg_mean-var_nudg_stddev

;**********************************************************************************************
;Mission.3		Display timeseries 
;**********************************************************************************************



    day_series=ispan(60,120,1)
	;************************************************ 
	; plotting parameters
	;************************************************
	wks1   = gsn_open_wks ("png",g_fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

	res@gsnDraw            = False                   ; don't draw	
	res@gsnFrame           = False                   ; don't advance frame
             
    res@vpXF     = 0.15

    res@vpWidthF = 0.7
    res@vpHeightF= 0.4


	res@trYMinF            = 0.0                 ; Y axis limits
	res@trYMaxF            = max(all_var_range)+2.0

	;res@trXMinF  = 1                   ; min value on x-axis
;	res@trXMaxF  = 12                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.

	
	res@tmXBValues = ispan(60,120,15)
	res@tmXBLabels = ispan(60,120,15)
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"red","blue","green4","black"/) ; colors chosen
	res@xyLineThicknesses	 = (/4.,4.,4.,6/)      ; line thicknesses
	res@xyDashPatterns	 = (/0.,0.,0.,0./)      ; make all lines solid
	res@tmXBMajorThicknessF = 5.0
	res@tmYLMajorThicknessF = 5.0
	res@tmXBMinorThicknessF = 4.0
	res@tmYLMinorThicknessF = 4.0
	res@tmBorderThicknessF = 4.0
	res@tmXBLabelFontHeightF = g_font
	res@tmYLLabelFontHeightF = g_font
	res@gsnStringFontHeightF = g_font
    res@gsnCenterString = g_fig_title
	top_plot  = gsn_csm_xy (wks1,day_series,all_var_ltm(:,60:120),res)   ; create plot
    print(all_var_ltm)	
    ; Create a plot with the area between both curves filled in blue.
	  delete(res@xyLineColors)
      res@gsnXYFillOpacities = 0.4
	  res@gsnXYFillColors = "OrangeRed"
	  res@xyLineColor     = -1                           ; We don't want the line, so make it transparent.
	  ;bot_plot  = gsn_csm_xy (wks1,day_series,all_var_range(0,:,60:120),res)  ; Create filled XY plot.

	  res@gsnXYFillColors = "DeepSkyBlue"
	 ; bot_plot1  = gsn_csm_xy (wks1,day_series,all_var_range(1,:,60:120),res)  ; Create filled XY plot.
	  ;overlay(bot_plot,bot_plot1)
	  
      ;overlay(bot_plot,top_plot)

    ;*****************************************************   
	; Manually create and attach legend
	;***************************************************** 
	res_text                    = True                  ; text mods desired
	res_text@txFontHeightF      = 0.02                 ; change text size
	res_text@txJust             = "CenterLeft"          ; text justification

	res_lines                   = True                  ; polyline mods desired
	res_lines@gsLineDashPattern = 0.                    ; solid line
	res_lines@gsLineThicknessF  = 4.                    ; line thicker
	res_lines@gsLineColor       = "red"                 ; line color
	
    xx = (/65,70/) 
	yy = (/30,30/)
	dum1 = gsn_add_polyline(wks1,top_plot,xx,yy,res_lines)              ; add polyline
	dum2 = gsn_add_text(wks1,top_plot,"Control",xx(1)+5,yy(0),res_text); add text



	res_lines@gsLineColor       = "blue"                                 ; change to blue
	yy = yy -3
    dum3 = gsn_add_polyline(wks1,top_plot,xx,yy,res_lines)                ; add polyline
	dum4 = gsn_add_text(wks1,top_plot,"Nudging",xx(1)+5,yy(0),res_text)       ; add text
    
    res_ref_lines=True
    res_ref_lines@gsLineColor       = "black"
    res_ref_lines@gsLineDashPattern = 4.
    xx = (/60,120/)
    yy = (/20,20/)
    dum7 = gsn_add_polyline(wks1,top_plot,xx,yy,res_ref_lines)              ; add polyline

 
    draw(top_plot)
    frame(wks1)

end
