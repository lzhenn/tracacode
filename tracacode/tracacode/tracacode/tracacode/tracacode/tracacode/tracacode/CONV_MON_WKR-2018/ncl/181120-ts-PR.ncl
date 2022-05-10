;**************************************
;  meteo_1.ncl
;
; Concepts illustrated:
;   - Drawing a meteogram
;   - Creating a color map using RGB triplets
;   - Reversing the Y axis
;   - Explicitly setting tickmarks and labels on the bottom X axis
;   - Increasing the thickness of contour lines
;   - Drawing wind barbs
;   - Drawing a bar chart
;   - Changing the width and height of a plot
;   - Overlaying wind barbs and line contours on filled contours
;   - Changing the position of individual plots on a page
;
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin
    g_fig_name="../fig/ts_PR"
    g_font=0.015
   
    g_fig_title="Precipitation"
    g_vars=(/"PRECC","PRECL"/)
    g_path="/home/lzhenn/array/lzhenn/data/CONV_MON_WRK-2018/" 
    g_path_names=(/"MX_AQUAP_SCYC","SF_AQUAP_SCYC","NO_TOPO_SCYC", "REAL_WORLD_SCYC"/)
    g_case_names=(/"B20f19-pure-aqua","B20f19-surf-aqua","B20f19-topo","B20f19-realworld"/)
    g_fig_names=(/"MX_AQUA","SF_AQUA","NO_TOPO", "REAL_WORLD"/)
    n_cases=4
     
    data2      = new((/n_cases,100/),float)
    rad    = 4.0*atan(1.0)/180.0
    do ii=0, n_cases-1
        ctrl_in      = addfile (g_path+g_path_names(ii)+"/pro/"+g_case_names(ii)+".cam.h0."+g_vars(0)+".1-100.nc", "r")   ; note the "s" of addfile
        var1:=ctrl_in->$g_vars(0)$
        ctrl_in      = addfile (g_path+g_path_names(ii)+"/pro/"+g_case_names(ii)+".cam.h0."+g_vars(1)+".1-100.nc", "r")   ; note the "s" of addfile
        var2=ctrl_in->$g_vars(1)$
        var1=var1+var2
        var1=var1*86400*1000*365
        var1:=month_to_annual(var1,1)
;        var1=var1-273.15
        printVarSummary(var1)
        clat= cos(var1&lat*rad)
        var1_aavg=runave_Wrap(wgt_areaave_Wrap(var1, clat, 1.0, 1),3,0 )
        data2(ii,:)=(/var1_aavg/)
    end do
          
;**********************************************************************************************
;MISSION.3      Display timeseries 
;**********************************************************************************************



    ;************************************************ 
    ; plotting parameters
    ;************************************************
    wks   = gsn_open_wks ("pdf",g_fig_name)                 ; open workstation

    res               = True                    ; plot mods desired

    plot = new((/1/),graphic)
    res@gsnFrame         = False
    res@gsnDraw  = False
             
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.25


    ;res@trYMinF            = 0.9*min(var1_season_scmean)                ; Y axis limits
    ;res@trYMaxF            = 1.1*max(var1_season_scmean)

    ;res@trYMinF            = 3.5                ; Y axis limits
    ;res@trYMaxF            = 6.5
    res@gsnCenterString = g_fig_title
    res@gsnLeftString = ""
    res@gsnRightString = "mm/year"
    res@trXMinF  = 0                   ; min value on x-axis
    res@trXMaxF  = dimsizes(var1_aavg)-1                   ; max value on x-axis
    res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiYAxisString = "PR"
    res@tmXTOn=False
    res@tmXBValues = ispan(0,dimsizes(var1_aavg)-1,10) ;interval
    res@tmXBLabels = ispan(0,100,10)         ;tick label
    res@xyMonoLineColor    = False             ; want colored lines
    res@xyLineColors       = (/"blue","deepskyblue","brown","darkgreen"/) ; colors chosen
    res@xyLineThicknesses    = (/2.0,2.0,2.0,2.0/)      ; line thicknesses
    res@xyDashPatterns   = (/0.,0.,0.,0./)      ; make all lines solid
    res@tmXBMajorThicknessF = 4.0
    res@tmYLMajorThicknessF = 4.0
    res@tmXBMinorThicknessF = 3.0
    res@tmYLMinorThicknessF = 3.0
    res@tmBorderThicknessF = 3.0
    res@tmXBLabelFontHeightF =0.022
    res@tmYLLabelFontHeightF = 0.022
    ; Note that a colon is the default function code. We recommend
    ; setting default code to be a tilde (~) in your .hluresfile.
    ; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml

    plot(0)  = gsn_csm_xy (wks,ispan(0,dimsizes(var1_aavg)-1,1),data2,res)   ; create plot
    ;---------------------------Add plot legend-----------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 2.                    ; line thicker

    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    res_lines@gsLineColor       = "blue"
    yy = (/7.0,7.0/)
    xx = (/70,75/)
    text_pos = 76
    dum11 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum12 = gsn_add_text(wks,plot(0),"MX_AQUA",text_pos,yy(0),res_text); add text

    yy=yy-1.0
    res_lines@gsLineColor       = "deepskyblue"
    dum21 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum22 = gsn_add_text(wks,plot(0),"SF_AQUA",text_pos,yy(0),res_text); add text
    
    yy=yy-1.0
    res_lines@gsLineColor       = "brown"
    dum31 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum32 = gsn_add_text(wks,plot(0),"NO_TOPO",text_pos,yy(0),res_text); add text
    
    yy=yy-1.0
    res_lines@gsLineColor       = "darkgreen"
    dum41 = gsn_add_polyline(wks,plot(0),xx,yy,res_lines)              ; add polyline
    dum42 = gsn_add_text(wks,plot(0),"REAL_WORLD",text_pos,yy(0),res_text); add text
    

    draw(plot)
    frame(wks)
end
