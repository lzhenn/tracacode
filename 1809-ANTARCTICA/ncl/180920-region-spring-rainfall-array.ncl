;================================================;
;  maponly_3.ncl
;================================================;
;
; Concepts illustrated:
;   - Changing the color of the oceans, land, and inland water areas
;
;=================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;=================================================;
begin

    g_data_path = "/home/yangsong3/data-observation/PRECPT/GPCP_precip.mon.mean.nc"
    g_font=0.02


    g_season="SON"

    g_latS=-40.
    g_latN=40.
     
    g_strt_mon = 197901 
    g_lst_mon = 201612

	ctrl_file1   = g_data_path
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	var1  =ctrl_in1->precip(istrt:ilast,:,:)			; p for unify the var name

    var1_ssn = month_to_season(var1,g_season)
    var1_ssn_mean=dim_avg_n_Wrap(var1_ssn,0) 
    printVarSummary(var1_ssn_mean)
    
    wks  = gsn_open_wks("x11","../fig/map_only_heating_center")      ; send graphics to PNG file

  gsn_define_colormap(wks,"precip2_17lev")
    res                        = True         ; mods desired
    
    
    res@cnFillOn             = True               ; turn on color for contours
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off contour line labels
    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = 4.0         ; set min contour level
    res@cnMaxLevelValF        = 12.0          ; set max contour level
    res@cnLevelSpacingF       = 1.0          ; set contour interval

    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

    res@gsnSpreadColors      = True               ; use full color map
    res@gsnSpreadColorStart  = 2               ; start at color 17
    res@gsnSpreadColorEnd    = 14                ; end at color 200

    ;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
    res@gsnStringFontHeightF = g_font

    res@gsnMaximize      = True       ; fill up the page
    res@gsnAddCyclic   = True;False
    res@gsnPaperOrientation = "portrait"

    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller
    res@lbLabelStride = 2 

    res@mpFillOn   = False     ; turn off gray continents
    res@mpGeophysicalLineThicknessF = 2
    res@mpGeophysicalLineColor      = "black";"white" 
    ;res@mpFillDrawOrder="PostDraw"
    res@mpCenterLonF = 180.
    res@mpMaxLatF  = g_latN
    res@mpMinLatF  = g_latS
;    res@mpMaxLonF  = g_lonE
;    res@mpMinLonF  = g_lonW

    ;  res@mpShapeMode = "FreeAspect" 

    ;  res@vpWidthF = 0.8
    ;  res@vpHeightF = 0.6

    ;  res@tmXBMajorOutwardLengthF = -0.
    ;  res@tmYLMajorOutwardLengthF = -0.
    ;  res@tmYRMajorOutwardLengthF = -0.

    ;  res@tmXBMinorOutwardLengthF = -0.
    ;  res@tmYLMinorOutwardLengthF = -0.
    ;  res@tmYRMinorOutwardLengthF = -0.

     ; now change the size of the tickmark labels
    res@tmXBTickSpacingF = 60 
    res@tmYLTickSpacingF = 15
    res@tmXBLabelFontHeightF = g_font
    ; res@tmXBLabelFontAspectF = 1.6
    res@tmXBLabelFontThicknessF = 2.0
    res@tmYLLabelFontHeightF = g_font
    ; res@tmYLLabelFontAspectF = 1.3
    res@tmYLLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontQuality =
    ;-----------------------------------------------------------------------------
     
    res@gsnLeftString = ""
    res@gsnRightString = ""


        
    
    res@gsnLeftString = "Array of Heating Centers ("+g_season+")"

    polyres                   = True
    polyres@gsMarkerIndex     = 2          ; polymarker style
    polyres@gsMarkerSizeF     = 16.          ; polymarker size
    polyres@gsMarkerThicknessF     = 6.          ; polymarker size
    polyres@gsMarkerColor     = "black"          ; polymarker size

    plot = gsn_csm_contour_map_ce(wks,var1_ssn_mean,res) ; create a default plot

    ; summer
    ;lon_array=(/90.0, 140.0, 250.0, 295.0, 345.0,  10.0/)
    ;lat_array=(/20.0, 5.0,   10.0,  5.0,   10.0,  5.0/)
    
    ; winter
    ;lon_array=(/110.0, 140.0,  175.0, 300.0,  47.5/)
    ;lat_array=(/0.0,   -5.0,   -10.0, -7.5,   -17.5/)
    
    ; autumn
    lon_array=(/100.0, 140.0,  220.0, 280.0,  330.0, 10.0/)
    lat_array=(/0.0,   -5.0,   7.5,   5.0,    7.5,   0.0/)
    

    dimlon=dimsizes(lon_array) 

    do ii=0,dimlon-1
        plot@$unique_string("fxxk ncl")$    = gsn_add_polymarker(wks,plot,lon_array(ii),lat_array(ii),polyres)
    end do
    draw(plot)
    frame(wks)
end
