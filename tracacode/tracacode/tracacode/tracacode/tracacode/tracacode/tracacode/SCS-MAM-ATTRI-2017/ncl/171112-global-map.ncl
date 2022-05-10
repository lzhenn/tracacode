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

  wks  = gsn_open_wks("x11","../fig/maponly")      ; send graphics to PNG file

  res                        = True         ; mods desired
  res@mpOceanFillColor       = "cyan"            ; array index in color map
  res@mpLandFillColor        = "sienna"          ; for land, ocean, and inland h20
  res@mpInlandWaterFillColor = "cyan"
 
  res@mpMinLonF              = 30
  res@mpMaxLonF              = 160
  res@mpMinLatF              = -10
  res@mpMaxLatF              = 60
  res@tmYLLabelFontHeightF = g_font
  res@tmXBLabelFontHeightF = g_font
 
  plot = gsn_csm_map(wks,res)        ; draw global map

  end
