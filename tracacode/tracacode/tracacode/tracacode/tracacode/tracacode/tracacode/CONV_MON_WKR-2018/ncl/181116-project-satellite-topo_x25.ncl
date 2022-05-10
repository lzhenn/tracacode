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
    
    g_font=0.02
    
    topo_file = "/home/lzhenn/array/lzhenn/data/topo/elev.0.25-deg.nc"
    a         = addfile(topo_file,"r")
    elev      = short2flt(a->data)
    elev = where(elev.lt.-100.,elev@_FillValue,elev)



    wks  = gsn_open_wks("x11","../fig/map_only_satelite_project")      ; send graphics to PNG file

    gsn_define_colormap(wks,"OceanLakeLandSnow")
    res                        = True         ; mods desired
    
    res@cnFillOn           = True     ; turn on contour fill
    res@cnLinesOn          = False    ; turn off contour lines
    res@cnLineLabelsOn     = False    ; turn off line labels
    res@cnInfoLabelOn      = False    ; turn off info label
    res@lbBoxLinesOn       = False    ; turn off labelbar box lines
    res@cnFillMode         = "MeshFill"   ; for faster draw
    res@gsnSpreadColorStart= 4            ; 2 and 3 are blue colors
    ;---Pick "nice" contour levels
    
    mnmxint = nice_mnmxintvl( min(elev), max(elev), 18, False)
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       = 0.
    res@cnMaxLevelValF       = mnmxint(1)
    res@cnLevelSpacingF      = mnmxint(2)/8.   ; Increase the number of levels 
                                             ; by choosing a smaller spacing.
    res@gsnAddCyclic         = False           ; don't add longitude cyclic point



    res@mpOceanFillColor       = "royalblue3"            ; array index in color map
    res@mpLandFillColor        = "transparent"          ; for land, ocean, and inland h20
    res@mpInlandWaterFillColor = "deepskyblue3"
    res@gsnFrame = False
    res@gsnDraw = False
    ;  res@mpMinLonF              = 60
    ;  res@mpMaxLonF              = 180
    ;  res@mpMinLatF              = -20
    ;  res@mpMaxLatF              = 20
    res@tmYLLabelFontHeightF = g_font
    res@tmXBLabelFontHeightF = g_font
    res@mpProjection = "satellite" 
    res@mpCenterLonF               = 120.0   
    res@gsnLeftString = ""

    res@mpFillOn             = True
    res@mpFillDrawOrder      = "PostDraw"
    res@pmTickMarkDisplayMode       = "Always"
    
    res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
    res@mpGridLineDashPattern  = 2                ; Dashed lines
    res@mpGridSpacingF         = 15
    res@mpGridLineThicknessF   = 2.0
    res@mpGridLineColor        = "Gray30"

    
    ;res@mpGeophysicalLineThicknessF = 2
    plot = gsn_csm_contour_map(wks,elev(0,:,:),res)
    draw(plot)
    frame(wks)
end
