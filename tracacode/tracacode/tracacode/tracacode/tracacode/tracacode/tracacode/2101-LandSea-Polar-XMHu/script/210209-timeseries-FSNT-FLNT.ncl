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
    g_fig_name="../fig/ts_FSNT_FLNT"
    g_font=0.015
   
    g_fig_title="TOA Radiative Budget"
    g_vars=(/"FSNT","FLNT"/)
    g_case_names=(/"B2000_largAUS_spinup"/)
    g_path="/WORK/sysu_hjkx_ys/huxm/CESM/B2000_largAUS_spinup/post_data/" 
    n_cases=1
    n_yrs= 104
    data2      = new((/n_cases,n_yrs/),float)
    rad    = 4.0*atan(1.0)/180.0
    do ii=0, n_cases-1
        ctrl_in      = addfile (g_path+g_case_names(ii)+".cam.h0."+g_vars(0)+".1-"+n_yrs+".nc", "r")   ; note the "s" of addfile
        var1:=ctrl_in->$g_vars(0)$
        ctrl_in      = addfile (g_path+g_case_names(ii)+".cam.h0."+g_vars(1)+".1-"+n_yrs+".nc", "r")   ; note the "s" of addfile
        var2=ctrl_in->$g_vars(1)$
        var1=var1-var2
        var1:=month_to_annual(var1,1)
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
    wks   = gsn_open_wks ("png",g_fig_name)                 ; open workstation

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
    res@gsnRightString = "W/m~S~2"
    res@tmXBOn=True
    res@tmXTOn=False
    res@tmYROn=False
    res@trXMinF  = 1                   ; min value on x-axis
    res@trXMaxF  = dimsizes(var1_aavg)-1                   ; max value on x-axis
    res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiYAxisString = "FSNT-FLNT"
    res@tmXBValues = ispan(1,dimsizes(var1_aavg)-1,10) ;interval
    res@tmXBLabels = ispan(1,n_yrs,10)         ;tick label
    res@xyMonoLineColor    = False             ; want colored lines
    res@xyLineColors       = (/"blue","deepskyblue","brown","darkgreen"/) ; colors chosen
    res@xyLineThicknesses    = (/4.0/)      ; line thicknesses
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

    draw(plot)
    frame(wks)
end
