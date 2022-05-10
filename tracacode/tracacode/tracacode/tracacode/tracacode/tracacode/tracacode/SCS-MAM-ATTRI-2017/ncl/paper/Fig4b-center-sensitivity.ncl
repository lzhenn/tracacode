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

  wks  = gsn_open_wks("eps","../../fig/paper/Fig4b-all")      ; send graphics to PNG file
  color_table="WhiteYellowOrangeRed"
  gsn_define_colormap(wks,color_table) ; choose a colormap 
  cmap = read_colormap_file(color_table)    ; returns 254 x 4 array
  rgba = span_color_rgba(cmap,20)


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
  res@gsnLeftString = "(b) Averaged Surf Wind"
  res@gsnRightString = "m/s"

 plot = gsn_csm_map(wks,res)        ; draw global map


  gsres=True
  gsres@gsMarkerIndex=16
  gsres@gsMarkerSizeF      = 0.018
  gsres@gsMarkerThicknessF = 0.7
  gsres_out=gsres
  gsres_out@gsMarkerSizeF      = 0.022
  gsres_out@gsMarkerColor="Black"
  
  
  lon0=90
  lat0=0
  wind1=(/0.8,1.3,1.5, 1.6, 2.0/)
  cn_level=0.1
  do ii=0,4
      n_color=floattoint(floor(wind1(ii)/cn_level))
      if n_color .gt. 19 then
        n_color = 19
      end if
      gsres@gsMarkerColor      = rgba(n_color,:)
      plot@$unique_string("fuck ncl")$ = gsn_add_polymarker(wks,plot,lon0,lat0,gsres_out)
      plot@$unique_string("fuck ncl")$ = gsn_add_polymarker(wks,plot,lon0,lat0,gsres)
      lon0=lon0+10
  end do
  lon0=110
  lat0=-10
  wind1=(/0.05, 0.33, 1.5, 0.45, 0.1/)
  do ii=0,4
      n_color=floattoint(floor(wind1(ii)/cn_level))
      if n_color .gt. 20 then
        n_color = 20
      end if
      print(n_color)
      gsres@gsMarkerColor      = rgba(n_color,:)
      plot@$unique_string("fuck ncl")$ = gsn_add_polymarker(wks,plot,lon0,lat0,gsres_out)
      plot@$unique_string("fuck ncl")$ = gsn_add_polymarker(wks,plot,lon0,lat0,gsres)
    lat0=lat0+5
  end do

  draw(plot)
  frame(wks)
end
