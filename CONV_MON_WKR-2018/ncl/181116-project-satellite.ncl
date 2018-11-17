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

  wks  = gsn_open_wks("x11","../fig/map_only_satelite_project")      ; send graphics to PNG file

  res                        = True         ; mods desired
  res@mpOceanFillColor       = "blue"            ; array index in color map
  res@mpLandFillColor        = "lightyellow4"          ; for land, ocean, and inland h20
  res@mpInlandWaterFillColor = "cyan"
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

  polyres                   = True
  polyres@gsMarkerIndex     = 13          ; polymarker style
  polyres@gsMarkerSizeF     = 16.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "black"          ; polymarker size

  plot = gsn_csm_map(wks,res)        ; draw global map

  draw(plot)
  frame(wks)
end
