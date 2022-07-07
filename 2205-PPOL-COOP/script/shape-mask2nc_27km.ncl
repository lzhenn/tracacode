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
load "/disk/hq247/yhuangci/resource/ncl-resource/shapefile_utils.ncl"

begin

    shpdir_name = "CHN" ;(/"CHN","AFG","BGD","IND","JPN","KHM","KOR","LAO","MMR","MNG","PAK",\
                  ;   "PHL","PRK","THA","TWN","VNM"/)
    country_name = "China" ;(/"China","Afghanistan","Bangladesh","India","Japan","Cambodia","South Korea","Laos","Myanmar","Mongolia","Pakistan",\
                   ;  "Philippines","North Korea","Thailand","Taiwan","Vietnam"/)
    out_name = "GD" ;(/"China","Afghanistan","Bangladesh","India","Japan","Cambodia","SouthKorea","Laos","Myanmar","Mongolia","Pakistan",\
               ;  "Philippines","NorthKorea","Thailand","Taiwan","Vietnam"/)
    ;grid file
    grid_fn="./GRIDCRO2D.27km"

    latlon_in   =  addfile(grid_fn,"r")
    lat2d = latlon_in->LAT(0,0,:,:)
    lon2d = latlon_in->LON(0,0,:,:)
    data = latlon_in->LON(0,0,:,:)
    data = 1
    data@_FillValue=0
;---Add lat/lon coordinate array information.
  data@lat2d    = lat2d
  data@lon2d    = lon2d

;---Open shapefile and read lat/lon values.
  dir          = "/disk/hq247/yhuangci/resource/country_mask_nc/country_shp/gadm36_"+shpdir_name(i)+"_shp/"
  shp_filename = dir + "gadm36_"+shpdir_name(i)+"_0.shp"
  ;---Set all hgt values to missing except for those over Ohio.
  opt             = True
  opt@debug       = True
  opt@shape_var   = "NAME_0"
  opt@shape_names = country_name(i)

do i = 0,dimsizes(shpdir_name)-1
  data_mask    = shapefile_mask_data(data,shp_filename,opt)

  delete([/data_mask@_FillValue, data_mask@lat2d, data_mask@lon2d/])
  ncdf     = addfile("./GRIDCRO2D.27km."+out_name(i)+".nc" ,"c")  ; open output netCDF file

  ncdf->$out_name(i)$=data_mask
  ncdf->lat2d=lat2d
  ncdf->lon2d=lon2d

  delete(ncdf)

end do

end

