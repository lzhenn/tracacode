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
;   2015-06-22  Change to fit multi-data 2 region timeseries
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
    g_data_path1 ="/home/yangsong3/data/observation/ICOADS2/Enhanced/cldc.mean.nc"

    ;SCS+PhSea
    sea_latS=0.
    sea_latN=15.
    sea_lonW=105.
    sea_lonE=155.
    
    ;South China
    sc_latS=20.
    sc_latN=35.
    sc_lonW=110.
    sc_lonE=135.

    g_season = "MAM"
    ;g_season_rank=(/"DJF","MAM","JJA","SON"/)
; create an array of desired pressure levels:

    g_strt_year=1900        
    g_end_year=2010
    g_strt_yyyymm=190001       
    g_end_yyyymm=201012

    g_font = 0.035

    g_fig_name    =   "../fig/Pr_cldc-timeseries_20R"
    g_fig_rank    =   (/"","","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    
    g_fig_title     = (/"Southern China ","SCS+PhS "/)+g_season +" Cloud Cover Timeseries"
   ;g_fig_title1   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr trend"  ;for dsstdt
   ;g_fig_title2   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr' trend" ;for dsst'dt


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path1
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    time = ctrl_in1->time
    yyyymm =floor( cd_calendar(time,-1))
    istrt = ind(yyyymm .eq. g_strt_yyyymm)
    ilast = ind(yyyymm .eq. g_end_yyyymm)
    var1 = short2flt(ctrl_in1->cldc(istrt:ilast,:,:))

   

    printVarSummary(var1)
    var1_season=month_to_season(var1,g_season)
    var1_season_seamean = wgt_areaave_Wrap(var1_season(:,{sea_latS:sea_latN},{sea_lonW:sea_lonE}),1.0,1.0,0)
    var1_season_seamean=runave_Wrap(var1_season_seamean,3,1)
    var1_sn_rm_searunmean=runave_Wrap(var1_season_seamean,11,0)
    var1_sn_rm_sealine=regline(ispan(g_strt_year,g_end_year,1),var1_season_seamean)
    
	
    df2   = var1_sn_rm_sealine@nptxy-2
    yReg2 = var1_season_seamean
    yReg2 = var1_sn_rm_sealine*ispan(g_strt_year,g_end_year,1) + var1_sn_rm_sealine@yintercept   ; NCL array notation 
    data2      = new((/3,dimsizes(var1_season_seamean)/),float)
    data2(0,:) = var1_season_seamean
    data2(1,:) = var1_sn_rm_searunmean
    data2(2,:) = yReg2

;**********************************************************************************************
;MISSION.3		Display timeseries 
;**********************************************************************************************



	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("png",g_fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

    plot = new((/2/),graphic)
    res@gsnFrame         = False
    res@gsnDraw  = False
             
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.3


	;res@trYMinF            = 0.9*min(var1_season_scmean)                ; Y axis limits
	;res@trYMaxF            = 1.1*max(var1_season_scmean)

	;res@trYMinF            = 3.5                ; Y axis limits
	;res@trYMaxF            = 6.5
    res@gsnCenterString = g_fig_title(0)
    res@gsnLeftString = g_fig_rank(0)
	res@trXMinF  = 0                   ; min value on x-axis
	res@trXMaxF  = dimsizes(var1_season_seamean)-1                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiYAxisString = "Cloud Cover"
	res@tmXBValues = ispan(0,dimsizes(var1_season_seamean)-1,10) ;interval
	res@tmXBLabels = ispan(g_strt_year,g_end_year,10)         ;tick label
	res@xyMonoLineColor    = False             ; want colored lines
	res@xyLineColors       = (/"blue","brown","darkgreen","red","black"/) ; colors chosen
	res@xyLineThicknesses	 = (/2.0,2.0,2.0,2.0,2.0/)      ; line thicknesses
	res@xyDashPatterns	 = (/1.,1.,0.,0.,1./)      ; make all lines solid
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


    ;plot(0)  = gsn_csm_xy (wks,ispan(0,dimsizes(var1_season_scmean)-1,1),data,res)   ; create plot
    
    res@tiXAxisString = "Year"
    res@gsnCenterString = g_fig_title(1)
    res@gsnLeftString = g_fig_rank(1)
    delete(res@xyLineColors)
    delete(res@xyLineThicknesses)
    delete(res@xyDashPatterns)
    res@xyDashPatterns=(/1.,0.,1./)
    res@xyLineThicknesses=(/2.0,3.0,3.0/)
    res@xyLineColors = (/"blue","blue","black"/)
	;res@trYMinF            = 9*min(var1_season_seamean)                ; Y axis limits
	;res@trYMaxF            = 1.1*max(var1_season_seamean)
    plot(0)  = gsn_csm_xy (wks,ispan(0,dimsizes(var1_season_seamean)-1,1),data2,res)   ; create plot
 

;---------------------------Add plot legend-----------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 1.                    ; solid line
    res_lines@gsLineThicknessF  = 2.                    ; line thicker

    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    res_lines@gsLineColor       = "blue"
    yy = (/4.8, 4.8/)
    xx = (/10,15/)
    text_pos = 18
    dum11 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum12 = gsn_add_text(wks,plot(0),"ICOADS2 CLDC",text_pos,yy(0),res_text); add text
    ;dum55 = gsn_add_polymarker(wks,plot,xx,yy,res_lines)   


    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    yy = yy - 0.4
    dum21 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum22 = gsn_add_text(wks,plot(0),"11-yr RM",text_pos,yy(0),res_text); add text

    gsn_panel(wks,plot(0),(/1,1/),False)

end


