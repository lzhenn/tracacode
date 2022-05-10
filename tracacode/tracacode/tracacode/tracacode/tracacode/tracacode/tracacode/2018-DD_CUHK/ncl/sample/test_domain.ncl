begin
;---Generate some dummy data over map
  minlat      =  25 
  maxlat      =  45
  minlon      =  100 
  maxlon      =  130

;---Read domain data
latlon_in   =  addfile("/home/lzhenn/package/WPS/geo_em.d03.nc","r")
lat2d = latlon_in->XLAT_M(0,::5,::5)
lon2d = latlon_in->XLONG_M(0,::5,::5)


wks  = gsn_open_wks("x11","../fig/shapefiles")  ; send graphics to PNG file

  res                     = True

  res@gsnMaximize         = True           ; maximize plot in frame
  res@gsnDraw             = False          ; don't draw plot yet
  res@gsnFrame            = False          ; don't advance frame yet

  res@gsnAddCyclic        = False          ; Don't add a cyclic point.

  res@mpDataBaseVersion   = "MediumRes"    ; slightly better resolution

;---Zoom in on North America.
  res@mpMinLatF           = minlat
  res@mpMaxLatF           = maxlat
  res@mpMinLonF           = minlon
  res@mpMaxLonF           = maxlon


  res@tmXBTickSpacingF = 15
  res@tmYLTickSpacingF = 15

  res@tiMainString = "Area where lat/lon sets"
  map = gsn_csm_map(wks,res)

;---Generate the lat/lon values over the masked area.

  lat_markers = ndtooned(lat2d)
  lon_markers = ndtooned(lon2d)

;---Set up resources for markers
  mkres               = True
  mkres@gsMarkerIndex = 16    ; Filled dots
  mkres@gsMarkerSizeF = 0.003

  markers = gsn_add_polymarker(wks,map,lon_markers,lat_markers,mkres)

  draw(map)
  frame(wks)
end

