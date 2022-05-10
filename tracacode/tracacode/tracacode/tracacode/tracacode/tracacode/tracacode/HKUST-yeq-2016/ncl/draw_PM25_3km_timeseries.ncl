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
    ;File day
    g_filetime=(/"316","317","318"/)
    
    ;Ctrl run
    data_file_name1="/disk/scratch/huangyeq/test_data/AE-test/ae6/cmaq/2015111112/3km/CCTM_V5g_Linux2_x86_64pg_mpich2.PM25.2015"+g_filetime+".nc"
    
    ;Sensitive run
    data_file_name2="/disk/scratch/huangyeq/test_data/AE-test/ae5/cmaq/2015111112/3km/CCTM_V5g_ebi_cb05cl_ae5_aq_mpich2.PM25.2015"+g_filetime+".nc"
    
    ;Fig name
    fig_name="../../pic/AE-test/PM25_3km_timeseries"
    
    ;Fig title
    fig_title="PM2.5"

    ;Point Lat&Lon Guangzhou
    p_lon=113.25
    p_lat=23.1

;---------------Read data-------------------
    varin1 = addfiles(data_file_name1,"r")
    varin2 = addfiles(data_file_name2,"r")
    
    var1 = varin1[:]->PM25
    var2 = varin2[:]->PM25
    var_time = varin1[:]->TSTEP 
    g_hours = dimsizes(var_time(:,0))
;---------------Read lat-lon config-------------------
    latlon_in   =  addfile("/disk/scratch/huangyeq/test_data/map_info/3km/GRIDCRO2D.3km.20151112","r")
    var1@lat2d = latlon_in->LAT(0,0,:,:)
    var1@lon2d = latlon_in->LON(0,0,:,:)
    var2@lat2d = latlon_in->LAT(0,0,:,:)
    var2@lon2d = latlon_in->LON(0,0,:,:)
    ; Get point coordinate
    point=getind_latlon2d(var1@lat2d,var1@lon2d,p_lat,p_lon)
    cor_x=point(0,0)
    cor_y=point(0,1)
    
    data=new((/2,g_hours/),float)
    data(0,:)=var1(:,0,cor_x,cor_y)
    data(1,:)=var2(:,0,cor_x,cor_y)
;**********************************************************************************************
;MISSION.4		Display timeseries 
;**********************************************************************************************



	;************************************************ 
	; plotting parameters
	;************************************************
	wks   = gsn_open_wks ("png",fig_name)                 ; open workstation

	res               = True                    ; plot mods desired

    res@gsnDraw           = False
    res@gsnFrame = False
    res@vpXF     = 0.15
    res@vpWidthF = 0.8
    res@vpHeightF= 0.2


	res@trYMinF            = min(data(1,:))-10               ; Y axis limits
	res@trYMaxF            = max(data(1,:))+10

    res@gsnCenterString = fig_title
	res@trXMinF  = 1                   ; min value on x-axis
	res@trXMaxF  = g_hours                   ; max value on x-axis
	res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiXAxisString = "Time"
	res@tiYAxisString = "PM2.5"
    res@tmXBValues = ispan(1, g_hours, 6) ;interval

    timelabel=var_time(0::6,1)/10000
    res@tmXBLabels = sprinti("%0.2i",timelabel)+"Z"       ;tick label
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
	 top_plot  = gsn_csm_xy (wks,ispan(1,g_hours,1),data,res)   ; create plot


    ;Add var1 Legend 
    
    yy = (/100.,100./)
    xx = (/12,18/)
    text_pos = xx(1)+1

    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 4.0                    ; line thicker
    res_lines@gsLineColor       = "blue"                 ; line color

    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.02                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification
    
    dum1 = gsn_add_polyline(wks,top_plot,xx,yy,res_lines)              ; add polyline
    dum2 = gsn_add_text(wks,top_plot,"AE6",text_pos,yy(0),res_text); add text

    ;Add var2 Legend
 
    yy = yy-20
    text_pos = xx(1)+1

    res_lines@gsLineColor       = "red"                 ; line color
    
    dum3 = gsn_add_polyline(wks,top_plot,xx,yy,res_lines)              ; add polyline
    dum4 = gsn_add_text(wks,top_plot,"AE5",text_pos,yy(0),res_text); add text

    draw(top_plot)
    frame(wks)
end




