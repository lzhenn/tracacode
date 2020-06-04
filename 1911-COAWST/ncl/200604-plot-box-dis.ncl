load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin
    fig_name="../fig/box_dis_"
    wrfout_fn="/disk/v092.yhuangci/lzhenn/1911-COAWST/ERA5_C2008/wrfout_d02"
    g_font=0.02

    ; tc box radius
    ctrl_in      = addfile (wrfout_fn, "r")   ; note the "s" of addfile
    ctrl_var1  = wrf_user_getvar(ctrl_in,"RAINNC", 0)  
    boxR=80
    var_comp=ctrl_var1(0:2*boxR,0:2*boxR)
    do ii=0,2*boxR
        do jj=0,2*boxR
            var_comp(ii,jj)=sqrt((ii-boxR)*(ii-boxR)+(jj-boxR)*(jj-boxR))*3.
        end do
    end do

    wks_type="png"
    wks_type@wkWidth=800
    wks_type@wkHeight=800


    wks = gsn_open_wks(wks_type,fig_name)      ; send graphics to PNG file
    gsn_define_colormap(wks,"WhBlGrYeRe")

    res                   = True              ; plot mods desired
;---Resources for filled contour plot
  
    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    res@cnLevels = ispan(3,360,3)   

    res@gsnMaximize          = True
    res@gsnFrame = False
    res@gsnDraw = False
    res@cnFillOn             = True  
    res@cnLinesOn            = False
    res@cnLevelSpacingF      = 2.           ; NCL chose 4.0
    res@lbOrientation        = "Vertical"

    ;---Necessary for contours to be overlaid correctly on WRF projection
    res@tfDoNDCOverlay       = True
    res@gsnAddCyclic         = False
    res@cnFillMode           = "CellFill" ; Raster Mode
    res@gsnSpreadColors      = True               ; use full color map
    res@gsnStringFontHeightF = g_font 
    res@gsnMaximize      = True       ; fill up the page
    res@gsnPaperOrientation = "portrait"

    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = 0.02              ; make labels smaller
    res@tmYLMajorLengthF = 0.01
    res@tmXBMajorLengthF = 0.01
    res@lbLabelStride = 2  
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    res@gsnLeftString="Radius to TC center"
    res@gsnRightString = "km"
    plot = gsn_csm_contour(wks,var_comp,res)

    draw(plot)
    frame(wks)
     

end

