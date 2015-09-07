;*************************************************************
;Aim: draw IO basin sst annual cycle with std range by using 3 
;     different datasets
;
;Mission:
;   1. Read data from 3 datasets
;   2. Post-post process to deserved results (IO basin ltmmean) 
;   3. Draw timeseries and overlap shading area
;                       Zhenning Li
;                       2014-11-21
;Last Edited:
;   2014-11-21  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin


;================================================
;Variables List:
;	var1--------------Had sst
;   var2--------------OI  sst
;   var3--------------ER  sst
;   var4--------------CAM used sst
;================================================

;IO region
	latS    =   -30.
	latN    =   30.
    lonL    =   50.
    lonR    =   110.

    data_path   =   "../../../data/sst/monthly/"
    fig_name    =   "../../../fig/IO_paper/fig1_sst_ann_cyc"
    fig_title   =   "SST annual cycle (30~S~o~N~S-30~S~o~N~N, 50~S~o~N~E-110~S~o~N~E )"
    
	mon_name =(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
	mon_x = ispan(1,12,1)
    
    need_start  =   1982
    need_end    =   2010 ; ERSST only extended to 2010-12

    var1_start  =   12*(need_start-1870) 
    var2_start  =   12*(need_start-1982)+1 ; OISST start from 1981-12 
    var3_start  =   12*(need_start-1854) 
    var4_start  =   12*(need_start-1850) 


    var1_end  =   12*(need_end-1870)+11 
    var2_end  =   12*(need_end-1982)+12 ; OISST start from 1981-12 
    var3_end  =   12*(need_end-1854)+11 
    var4_end  =   12*(need_end-1850)+11



; ==============================================================
; Mission 1. Open the file: Read sst 
; ==============================================================

;HadISST
	ctrl_file1   = data_path+"HadISST_sst.nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	
	var1  = ctrl_in1->sst(var1_start:var1_end,:,:)			; p for unify the var name
    printVarSummary(var1)

;OISST
	ctrl_file2   = data_path+"noaa_oi_sst.mnmean.nc"
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile

    temp    =   ctrl_in2->sst(var2_start:var2_end,:,:)			; p for unify the var name
    var2  	=   short2flt(temp)


; for land sea mask

    a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
    lsdata = a->LSMASK
    lsm  = landsea_mask(lsdata,var2&lat,var2&lon)
    var2 = mask(var2,lsm.eq.1,False)

    delete(temp)
    printVarSummary(var2)
;ERSST
    ctrl_file3   = data_path+"noaa_er_sst.mnmean.nc"
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile
	
	temp    =   ctrl_in3->sst(var3_start:var3_end,:,:)			; p for unify the var name
    var3    =   short2flt(temp)   
    printVarSummary(var3)
;CAMSST
    ctrl_file4   = data_path+"sst_HadOIBl_bc_0.9x1.25_1850_2012_c130411.nc"
	ctrl_in4     = addfile (ctrl_file4, "r")   ; note the "s" of addfile
	
	var4s1  = ctrl_in4->SST_cpl(var4_start:var4_end,:,:)			; p for unify the var name
    var4    = f2fsh_Wrap(var4s1,(/180,360/)) 
    lsm  = landsea_mask(lsdata,var4&lat,var4&lon)
    var4 = mask(var4,lsm.eq.1,False)
    printVarSummary(var4)
; ==============================================================
; Mission 2. process the ssts, generate anncyc 
; ==============================================================
	var1_aavg = wgt_areaave_Wrap(var1(:,{latS:latN},{lonL:lonR}),1.0,1.0,0)
	var2_aavg = wgt_areaave_Wrap(var2(:,{latS:latN},{lonL:lonR}),1.0,1.0,0)
	var3_aavg = wgt_areaave_Wrap(var3(:,{latS:latN},{lonL:lonR}),1.0,1.0,0)
	var4_aavg = wgt_areaave_Wrap(var4(:,{latS:latN},{lonL:lonR}),1.0,1.0,0)
    
    all_var_ltm=new((/4,12/),"float")
    all_var_max=new((/4,12/),"float")
    all_var_min=new((/4,12/),"float")

    all_var_std=new((/4,12/),"float")

    do i =0,11
        all_var_ltm(0,i)   =   dim_avg_Wrap(var1_aavg(i::12))
        all_var_ltm(1,i)   =   dim_avg_Wrap(var2_aavg(i::12))
        all_var_ltm(2,i)   =   dim_avg_Wrap(var3_aavg(i::12))
        all_var_ltm(3,i)   =   dim_avg_Wrap(var4_aavg(i::12))
        
        all_var_std(0,i)   =   stddev(var1_aavg(i::12))
        all_var_std(1,i)   =   stddev(var2_aavg(i::12))
        all_var_std(2,i)   =   stddev(var3_aavg(i::12))
        all_var_std(3,i)   =   stddev(var4_aavg(i::12))
    end do
    
    all_var_range=new((/4,2,12/),"float")

    all_var_max=all_var_ltm+all_var_std
    all_var_min=all_var_ltm-all_var_std

    all_var_range(:,0,:)=all_var_max
    all_var_range(:,1,:)=all_var_min
;**********************************************************************************************
;Mission.3		Display timeseries 
;**********************************************************************************************



	;************************************************ 
	; plotting parameters
	;************************************************
	wks1   = gsn_open_wks ("eps",fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

	res@gsnDraw            = False                   ; don't draw	
	res@gsnFrame           = False                   ; don't advance frame
             
    res@vpXF     = 0.15

    res@vpWidthF = 0.7
    res@vpHeightF= 0.4


	res@trYMinF            = min(all_var_range)-0.1                 ; Y axis limits
	res@trYMaxF            = max(all_var_range)+0.1

	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = 12                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.

	
	res@tmXBValues = mon_x
	res@tmXBLabels = mon_name
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue","red","green4","black"/) ; colors chosen
	res@xyLineThicknesses	 = (/4.,4.,4.,6/)      ; line thicknesses
	res@xyDashPatterns	 = (/0.,0.,0.,0./)      ; make all lines solid
	res@tmXBMajorThicknessF = 5.0
	res@tmYLMajorThicknessF = 5.0
	res@tmXBMinorThicknessF = 4.0
	res@tmYLMinorThicknessF = 4.0
	res@tmBorderThicknessF = 4.0
	res@tmXBLabelFontHeightF = 0.022
	res@tmYLLabelFontHeightF = 0.022
	res@gsnStringFontHeightF = 0.022
    res@gsnCenterString = fig_title
	top_plot  = gsn_csm_xy (wks1,mon_x,all_var_ltm,res)   ; create plot
	
    ; Create a plot with the area between both curves filled in blue.
	  delete(res@xyLineColors)
      ;res@gsnXYFillOpacities = 0.5
	  res@gsnXYFillColors = "LightBlue"
	  res@xyLineColor     = -1                           ; We don't want the line, so make it transparent.
	  bot_plot  = gsn_csm_xy (wks1,mon_x,all_var_range(0,:,:),res)  ; Create filled XY plot.

	  res@gsnXYFillColors = "LightPink"
	  bot_plot1  = gsn_csm_xy (wks1,mon_x,all_var_range(1,:,:),res)  ; Create filled XY plot.
	  overlay(bot_plot,bot_plot1)

	  res@gsnXYFillColors = "DarkOliveGreen1"
	  bot_plot2  = gsn_csm_xy (wks1,mon_x,all_var_range(2,:,:),res)  ; Create filled XY plot.
	  overlay(bot_plot,bot_plot2)

	  res@gsnXYFillColors = "LightGray"
	  bot_plot3  = gsn_csm_xy (wks1,mon_x,all_var_range(3,:,:),res)  ; Create filled XY plot.
	  overlay(bot_plot,bot_plot3)
	  
      overlay(bot_plot,top_plot)

    ;*****************************************************   
	; Manually create and attach legend
	;***************************************************** 
	res_text                    = True                  ; text mods desired
	res_text@txFontHeightF      = 0.02                 ; change text size
	res_text@txJust             = "CenterLeft"          ; text justification

	res_lines                   = True                  ; polyline mods desired
	res_lines@gsLineDashPattern = 0.                    ; solid line
	res_lines@gsLineThicknessF  = 6.                    ; line thicker
	res_lines@gsLineColor       = "black"                 ; line color
	xx = (/8,9/)

    unidiff = 0.3
	max_pos = res@trYMaxF-unidiff
	
	yy = (/max_pos,max_pos/)
	dum1 = gsn_add_polyline(wks1,bot_plot,xx,yy,res_lines)              ; add polyline
	dum2 = gsn_add_text(wks1,bot_plot,"HadOIBl",9.5,max_pos,res_text); add text


	res_lines@gsLineThicknessF  = 4.                    ; line thicker

	max_pos=max_pos-unidiff
	yy = (/max_pos,max_pos/)
	res_lines@gsLineColor       = "blue"                                 ; change to blue
	dum3 = gsn_add_polyline(wks1,bot_plot,xx,yy,res_lines)                ; add polyline
	dum4 = gsn_add_text(wks1,bot_plot,"HadISST",9.5,max_pos,res_text)       ; add text

	max_pos=max_pos-unidiff
	yy = (/max_pos,max_pos/)
	res_lines@gsLineColor       = "red"                                 ; change to blue
	dum5 = gsn_add_polyline(wks1,bot_plot,xx,yy,res_lines)                ; add polyline
	dum6 = gsn_add_text(wks1,bot_plot,"OISST",9.5,max_pos,res_text)       ; add text
	
	max_pos=max_pos-unidiff
	yy = (/max_pos,max_pos/)
	res_lines@gsLineColor       = "green4"                                 ; change to blue
	dum7 = gsn_add_polyline(wks1,bot_plot,xx,yy,res_lines)                ; add polyline
	dum8 = gsn_add_text(wks1,bot_plot,"ERSST",9.5,max_pos,res_text)       ; add text


    draw(bot_plot)
    frame(wks1)

end
