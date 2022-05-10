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

    wks  = gsn_open_wks("eps","../../fig/paper/FigS1a-heating-spatial")      ; send graphics to PNG file

    ctrl_dir="/users/yangsong3/L_Zealot/F/Ideal_phy/ctrl/Ideal_phy.cam.h0.0001-01-01-00000.nc"    
   
    sen_dir="/users/yangsong3/L_Zealot/F/Ideal_phy/exe/Ideal_phy.cam.h0.0001-01-01-00000.nc"    



    g_start=0
    g_end=0
    ;Prepare the variables
    ctrl_in     = addfile (ctrl_dir, "r")   ; note the "s" of addfile
    var1  =ctrl_in->CONHEAT
    printVarSummary(var1)

    sen_in     = addfile (sen_dir, "r")   ; note the "s" of addfile
    sen_var1  =sen_in->CONHEAT

    diff_var1=var1
    diff_var1=86400*(sen_var1-var1)


  res                        = True         ; mods desired
  res@mpOceanFillColor       = "lightskyblue"            ; array index in color map
  res@mpLandFillColor        = "lightyellow4"          ; for land, ocean, and inland h20
  res@mpInlandWaterFillColor = "cyan"
  res@gsnFrame = False
  res@gsnDraw = False
  res@mpMinLonF              = 60
  res@mpMaxLonF              = 180
  res@mpMinLatF              = -20
  res@mpMaxLatF              = 20
  res@tmYLLabelFontHeightF = g_font
  res@tmXBLabelFontHeightF = g_font 
  res@gsnStringFontHeightF = g_font
  res@gsnLeftString = "(a) Heating Spatial Distrabution @ Model Layer 18"
  res@gsnRightString = "K/day"

  plot = gsn_csm_map(wks,res)        ; draw global map


  gsres=True
  gsres@gsMarkerIndex=13
  gsres@gsMarkerSizeF      = 0.018
  gsres@gsMarkerThicknessF = 3
  gsres_out=gsres
  gsres_out@gsMarkerSizeF      = 0.022
  gsres_out@gsMarkerColor="Black"
  
  lat0=0
  lon0=110
  plot@$unique_string("fuck ncl")$ = gsn_add_polymarker(wks,plot,lon0,lat0,gsres_out)
     
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
  res3@cnLevels = (/0.1, 0.3, 0.5, 0.7, 0.9/)
  res3@cnLineColor      = "Red"
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "


  plot_cn_pos = gsn_csm_contour(wks,diff_var1(0,18,:,:),res3)
  overlay(plot,plot_cn_pos)

  draw(plot)
  frame(wks)
end
