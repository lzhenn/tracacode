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
    ctrl_file="/home/lzhenn/array/lzhenn/data/IDEAL/CTRL/Ideal_phy.cam.h0.0001-01-04-00000.nc"
    sen_file="/home/lzhenn/array/lzhenn/data/IDEAL/SEN/Ideal_phy.cam.h0.0001-01-04-00000.nc"

    a         = addfile(topo_file,"r")
    elev      = short2flt(a->data)
    elev = where(elev.lt.-100.,elev@_FillValue,elev)

    ctrl_in=addfile(ctrl_file, "r")
    sen_in=addfile(sen_file, "r")
    
    ctrl_var1=ctrl_in->U(0,29,:,:)
    sen_var1=sen_in->U(0,29,:,:)
    diff_var1=ctrl_var1
    diff_var1=sen_var1-ctrl_var1

    wks  = gsn_open_wks("x11","../fig/satelite_z3_diff")      ; send graphics to PNG file

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
    ;res@mpFillDrawOrder      = "PostDraw"
    res@pmTickMarkDisplayMode       = "Always"
    
    res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
    res@mpGridLineDashPattern  = 2                ; Dashed lines
    res@mpGridSpacingF         = 15
    res@mpGridLineThicknessF   = 2.0
    res@mpGridLineColor        = "Gray30"

    res3                  = True       ; use plot options
    res3@cnFillOn         = False;True       ; Fill contours
    res3@cnLinesOn        = True      ; turn off contour lines
  ;for tp masking
    res3@gsnFrame         = False
    res3@gsnDraw  = False
    res3@cnLineLabelsOn   = False      ; turn off contour line labels
    res3@cnLineThicknessF = 3 
    res3@cnInfoLabelOn = False
   
   
    res3@cnLevelSelectionMode="ExplicitLevels"
;    res3@cnLevels = ispan(1,12,1) 
;    res3@cnLevels = (/ 0.001, 0.005, 0.01, 0.05/)
    res3@cnLevels = (/ 0.1, 0.2, 0.5, 1.0, 1.5/)
    res3@cnLineColor      = "Red"
    res3@gsnLeftString      = " "
    res3@gsnRightString      = " "
    res3@mpProjection = "satellite" 

    
    ;res@mpGeophysicalLineThicknessF = 2
    plot = gsn_csm_contour_map(wks,elev(0,:,:),res)
    plot_cn_pos = gsn_csm_contour(wks,diff_var1,res3)
    res3@cnLevels = -res3@cnLevels
    res3@cnLineColor      = "Blue"
    res3@cnLineDashPattern      = 1
    plot_cn_neg = gsn_csm_contour(wks,diff_var1,res3)
    
    overlay(plot,plot_cn_neg)
    overlay(plot,plot_cn_pos)
    draw(plot)
    frame(wks)
end
