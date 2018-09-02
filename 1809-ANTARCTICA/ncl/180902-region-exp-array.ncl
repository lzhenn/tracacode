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

  wks  = gsn_open_wks("x11","../fig/map_only_heating_center")      ; send graphics to PNG file

  res                        = True         ; mods desired
  res@mpOceanFillColor       = "lightskyblue"            ; array index in color map
  res@mpLandFillColor        = "lightyellow4"          ; for land, ocean, and inland h20
  res@mpInlandWaterFillColor = "cyan"
  res@gsnFrame = False
  res@gsnDraw = False
  res@mpMinLonF              = 60
  res@mpMaxLonF              = 220
  res@mpMinLatF              = -30
  res@mpMaxLatF              = 30
  res@tmYLLabelFontHeightF = g_font
  res@tmXBLabelFontHeightF = g_font
 
  res@gsnLeftString = "Array of Idealized Simulation Heating Centers"

  polyres                   = True
  polyres@gsMarkerIndex     = 2          ; polymarker style
  polyres@gsMarkerSizeF     = 16.          ; polymarker size
  polyres@gsMarkerThicknessF     = 6.          ; polymarker size
  polyres@gsMarkerColor     = "black"          ; polymarker size

  plot = gsn_csm_map(wks,res)        ; draw global map

  lon_array=ispan(90,180,15)
  lat_array=ispan(-20,20,10)
  dimlon=dimsizes(lon_array) 
  dimlat=dimsizes(lat_array) 
  
  do ii=0,dimlon-1
    do jj=0,dimlat-1
        plot@$unique_string("fxxk ncl")$    = gsn_add_polymarker(wks,plot,lon_array(ii),lat_array(jj),polyres)
    end do
  end do
  draw(plot)
  frame(wks)
end
