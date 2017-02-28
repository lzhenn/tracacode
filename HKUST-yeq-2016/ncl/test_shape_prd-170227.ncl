;*************************************************
; shapefiles_4.ncl
;
; Concepts illustrated:
;   - Drawing the Mississippi River Basin using data from a shapefile
;   - Masking a data array based on a geographical area obtained from a shapefile
;   - Attaching markers to a map
;   - Attaching polylines to a map plot
;
;*************************************************
; This script shows the "new" way (post NCL V6.0.0) of  masking
; data and adding shapefile outlines to an existing NCL map.
;*************************************************
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
; This file still has to be loaded manually
load "./shapefile_utils.ncl"

begin
;---Generate some dummy data over map
  minlat      =   20
  maxlat      =   60
  minlon      = -125
  maxlon      =  -60

  nlat            = 32
  nlon            = 64
  data            = generate_2d_array(10, 10, 0., 100., 0, (/nlat,nlon/))
  data@_FillValue = -9999

;---Add lat/lon coordinate array information.
  lat1d       = fspan(minlat,maxlat,nlat)
  lon1d       = fspan(minlon,maxlon,nlon)
  lat1d@units = "degrees_north"
  lon1d@units = "degrees_east"
  data!0      = "lat"
  data!1      = "lon"
  data&lat    = lat1d
  data&lon    = lon1d


;---Open shapefile and read lat/lon values.
  dir          = ncargpath("data") + "/shp/"
  shp_filename = dir + "mrb.shp"
  data_mask    = shapefile_mask_data(data,shp_filename,True)

;---Start the graphics
  wks  = gsn_open_wks("png","shapefiles")  ; send graphics to PNG file

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

  res@tiMainString        = "Mississippi River Basin with full data"

;---Create contours over map.
  map_data = gsn_csm_contour_map(wks,data,res)

;---Resources for polyline
  lnres                  = True
  lnres@gsLineColor      = "blue"
  lnres@gsLineThicknessF = 2.0            ; 2x thickness

  line_data = gsn_add_shapefile_polylines(wks, map_data, shp_filename, lnres)

;---Draw plot and advance frame
  draw(map_data)
  frame(wks)

;---Draw contours of masked data
  res@tiMainString  = "Mississippi River Basin with masked data"

  map_mask  = gsn_csm_contour_map(wks,data_mask,res)
  line_mask = gsn_add_shapefile_polylines(wks, map_mask, shp_filename, lnres)

  draw(map_mask)
  frame(wks)

;---Draw the part of the lat/lon grid that was masked out. 
;   Only draw the map this time (no contours).

  delete(res@gsnAddCyclic)

  res@tiMainString = "Area where lat/lon values were masked"
  map = gsn_csm_map(wks,res)

;---Generate the lat/lon values over the masked area.

  lat2d = conform_dims((/nlat,nlon/),lat1d,0)
  lon2d = conform_dims((/nlat,nlon/),lon1d,1)
  lat2d@_FillValue = -9999
  lon2d@_FillValue = -9999
  lat_markers = ndtooned(where(ismissing(data_mask),lat2d,lat2d@_FillValue))
  lon_markers = ndtooned(where(ismissing(data_mask),lon2d,lon2d@_FillValue))

;---Set up resources for markers
  mkres               = True
  mkres@gsMarkerIndex = 16    ; Filled dots
  mkres@gsMarkerSizeF = 0.003

  markers = gsn_add_polymarker(wks,map,lon_markers,lat_markers,mkres)
  line    = gsn_add_shapefile_polylines(wks, map, shp_filename, lnres)

  draw(map)
  frame(wks)
end

