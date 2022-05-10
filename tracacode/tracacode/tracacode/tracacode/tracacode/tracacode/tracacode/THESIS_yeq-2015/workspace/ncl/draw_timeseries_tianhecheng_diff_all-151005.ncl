;***********************************************
; Draw PM2.5 diff between SEN and BASE 
;      from CCTM
;
; jobs:
;   1.Read CCTM data (SEN and BASE)
;   2.Post process the data
;   3.Display the figure
;                       L_Zealot
;                       2015-06-15
; 2015-06-15    Created;
; 2015-08-19    Modified to fit PM2.5 from CCTM
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"
begin

	g_font =0.025
	g_species = "PM25"
    g_pm25_species = (/"ASO4J","ASO4I","ANO3J","ANO3I","ANH4J","ANH4I","AALKJ","AXYL1J","AXYL2J","AXYL3J",\
                       "ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J",\
                       "ASQTJ","AORGCJ","AORGPAI","AORGPAJ","AECJ","AECI","A25J","A25I","ANAJ","ACLJ",\
                       "ACLI","ANAI","AISO3J","AOLGAJ","AOLGBJ"/)
    g_filetime = (/"07","10","13","16","19","22","25"/)
    ;g_filename = (/"sw","gz","fs","sz","gd1","gd2","gd3","gd4","gd5"/)
    g_filename = (/"sw","gz","gd1","gd4","gd5"/)
    g_filename_true = (/"SW","GZ","ZQS","DH","YD"/)
    ;g_fig_name =  "../fig/CMAQ_grid_city"
    g_fig_name = "../fig/plot_tianhecheng_diff_timeseriesi"
    g_lat = 58
    g_lon = 75
; ==============================================================
; Mission1.    Read PM2.5
; ==============================================================

    ;read PM25 CCTM ctrl result
    ctrl_in      = addfiles("../data/CCTM/base/201011"+g_filetime+"00_3km.ACONC.ncf","r")
    ctrl_var     = ctrl_in[:]->$g_pm25_species(0)$                 ; znw(bottom_top_stag)
    do i=1,dimsizes(g_pm25_species)-1
        ctrl_var     =ctrl_var+ctrl_in[:]->$g_pm25_species(i)$                 ; znw(bottom_top_stag)
    end do
   
    dim_ctrl_var = dimsizes(ctrl_var)
    g_hours =dim_ctrl_var(0)

    ;read PM25 CCTM sen result
    sen_var = new((/dimsizes(g_filename),g_hours,1,110,152/),double)  
    do i = 0,dimsizes(g_filename)-1
        sen_in = addfiles("../data/CCTM/no-"+g_filename(i)+"-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")    
        sen_var(i,:,:,:,:)     = sen_in[:]->$g_pm25_species(0)$                 ; znw(bottom_top_stag)
        do j=1,dimsizes(g_pm25_species)-1
            sen_var(i,:,:,:,:)     =sen_var(i,:,:,:,:)+sen_in[:]->$g_pm25_species(j)$                 ; znw(bottom_top_stag)
        end do
    end do
    
    diff = new((/dimsizes(g_filename),433/),double)
    do i = 0,dimsizes(g_filename)-1
        diff(i,:) = sen_var(i,48:480,0,g_lat,g_lon)-ctrl_var(48:480,0,g_lat,g_lon)
    end do

;**********************************************************************************************
;MISSION.3		Plot Clim monthly mean to check the result
;**********************************************************************************************
	wks = gsn_open_wks("eps",g_fig_name)       ; open file to plot 
;-----------------------------------------------------------------------------
    plot = new((/1/),graphic)
 
    res                  = True       ; use plot options
    res@gsnFrame         = False
    res@gsnDraw  = False
                     
    res@gsnMaximize      = True 
    res@xyLineColors      = (/"blue","red","green","orange","purple"/)          ; change line color

    ;res@vpXF     = 0.15
   
    res@vpWidthF = 0.8                  ;figure width
    res@vpHeightF= 0.25                 ;figure height
    res@trXMinF  = 1                   ; min value on x-axis
    res@trXMaxF  = 433                   ; max value on x-axis
    res@trYMinF  = -45
    res@trYMaxF  = 1
    res@xyLineThicknesses    = (/3.0,3.0,3.0,3.0,3.0/) 
    res@xyDashPattern = (/0,0,0,0,0/)               ; Make curves all solid

    res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiMainString = "TianHe" 
    res@tiMainFontHeightF= 0.025
    res@tiYAxisString = "PM25(ug/m3)"
    ;res@tiXAxisString = "Date"
    res@tmXBValues = ispan(1,433,48) ;interval
    res@tmXBLabels = "11/"+ispan(9,27,2) ;tick label

    ;res@xyMarkLineMode = "MarkLines"    ; Markers *and* lines
    ;res@xyMarkers      = (/6,11,16/)    ; 3 different markers
    ;res@xyMarkerColors = (/"blue","red","green","orange","purple"/)  ; 3 different colors

    ;res@tiMainString      = "Mulitple XY plot with markers"      ; add title

    plot  = gsn_csm_y (wks,diff,res) ; create plot

    ;---------------------------Add plot legend-----------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0                    ; solid line
    res_lines@gsLineThicknessF  = 2.                    ; line thicker

    ;res_lines@gsMarkerColor     = "blue"
    ;res_lines@gsMarkerIndex     = 16
    ;res_lines@gsMarkerSizeF     = 0.01

    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.012                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification
    xx = (/390,400/)
    text_pos = 402
    
    do i=0,dimsizes(g_filename)-1
        res_lines@gsLineColor       = res@xyLineColors(i) 
        yy = (/-30,-30/) - 3.2*i
        plot@$unique_string("fuck")$=gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
        plot@$unique_string("fuck ncl")$= gsn_add_text(wks,plot,g_filename_true(i),text_pos,yy(0),res_text); add text
    end do
    draw(plot)
    frame(wks)


end
