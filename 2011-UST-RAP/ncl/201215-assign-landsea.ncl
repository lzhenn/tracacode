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
load "$NCL_SELFLIB/shapefile_utils.ncl"

begin

    ;grid file
    grid_fn="/home/metctm1/array/app/COAWST/COAWST_operational/Projects/GBA_operational/roms_swan_grid/geo_em.d03.smp.roms.d02.nc"
    grid_out="/home/metctm1/array/app/COAWST/COAWST_operational/Projects/GBA_operational/roms_swan_grid/geo_em.d03.out.roms.d02.nc"

    latlon_in   =  addfile(grid_fn,"r")
    lat2d = latlon_in->XLAT_M(0,:,:)
    lon2d = latlon_in->XLONG_M(0,:,:)
    data = latlon_in->LANDMASK
    data = 0
    data@_FillValue=1 
;---Add lat/lon coordinate array information.
  data@lat2d    = lat2d
  data@lon2d    = lon2d



;---Open shapefile and read lat/lon values.
  dir          = "/disk/hq247/yhuangci/resource/ncl-resource/map-hkairport/"
  shp_filename = dir + "p01.shp"
  data_mask    = shapefile_mask_data(data(0,:,:),shp_filename,True)
  delete([/data_mask@_FillValue, data_mask@lat2d, data_mask@lon2d/])
  ncdf     = addfile(grid_out, "w")  ; open output netCDF file

  ncdf->LANDMASK(0,:,:)=(/data_mask/)
end

