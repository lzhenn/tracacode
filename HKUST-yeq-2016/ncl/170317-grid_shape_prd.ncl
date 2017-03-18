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
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
load "$NCL_SELFLIB/shapefile_utils.ncl"

grid_fn="/Users/zhenningli/data/HKUST-yeq-2016/gridsys/GRIDCRO2D_3km"

latlon_in   =  addfile(grid_fn,"r")
lat2d0 = latlon_in->LAT(0,0,:,:)
lon2d0 = latlon_in->LON(0,0,:,:)
    

begin
;---Generate some dummy data over map
  minlat      =   min(lat2d0)
  maxlat      =   max(lat2d0)
  minlon      =   min(lon2d0)
  maxlon      =   max(lon2d0)

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
  dir          = "$NCL_SELFLIB/../shp/PRD/"
  shp_filename = dir + "PRD.shp"
  data_mask    = shapefile_mask_data(data,shp_filename,True)

;---Start the graphics
  wks  = gsn_open_wks("png","../fig/shapefiles")  ; send graphics to PNG file

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
 res@tmXBTickSpacingF = 1
 res@tmYLTickSpacingF = 1

  res@tiMainString = "Area where lat/lon values were masked"
    res@mpDataBaseVersion       = "MediumRes"
    res@mpDataSetName           = "Earth..4"
    res@mpAreaMaskingOn         = True
    res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
    res@mpLandFillColor         = "white"
    res@mpInlandWaterFillColor  = "white"



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
  
  ;>============================================================<
  ;                      add China map
  ;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = True       ; draw diqujie or not

  ;chinamap = add_china_map(wks,map,cnres)
  
  draw(map)
  frame(wks)
end

