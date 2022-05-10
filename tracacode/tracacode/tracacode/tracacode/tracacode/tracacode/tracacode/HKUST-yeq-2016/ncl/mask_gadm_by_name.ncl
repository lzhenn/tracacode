;----------------------------------------------------------------------
; This script draws a filled contour plot of precipitation, and
; and then masks the data over all areas except for a given list
; of specific areas in a level 1 adm shapefile. The BOL_adm1.shp
; shapefile is used in this example, downloaded from 
; http://wwwgadm.org/country/
;
; The NAME_1 variable in the BOL_adm1.shp file is used to determine
; the areas of interest.  The names in this file are:
;
;     Chuquisaca, Cochabamba, El Beni, La Paz, Oruro, Pando,
;     Potosí, Santa Cruz, Tarija
;
; This script masks out all data except for those that fall in the
; Chuquisaca and Cochabamba regions.
;
; This script assumes you have a rectilinear grid. That is, your 
; data has 1D coordinate arrays. It will work with 2D (curvilinear)
; data or 1D unstructured data, but you will need to modify the 
; "mask_data_with_gadm_country" function to correctly handle the
; lat/lon data.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 

;==================================================
; This function masks a rectilinear data array
; against a country area by name.
;==================================================
function mask_data_by_gadm_name(sfilename,data,mask_names[*]:string)
begin
  mask_start_time = get_cpu_time()

;---Convert rectilinear grid to 2D grid, but laid out as 1D array.
  dims  = dimsizes(data)
  lat1d = ndtooned(conform_dims(dims,data&$data!0$,0))
  lon1d = ndtooned(conform_dims(dims,data&$data!1$,1))

;---Open shapefile and read lat/lon values.
  f = addfile(sfilename,"r")

;---Read data off the shapefile
  segments = f->segments
  geometry = f->geometry
  segsDims = dimsizes(segments)
  geomDims = dimsizes(geometry)

;---Read global attributes  
  geom_segIndex = f@geom_segIndex
  geom_numSegs  = f@geom_numSegs
  segs_xyzIndex = f@segs_xyzIndex
  segs_numPnts  = f@segs_numPnts
  numFeatures   = geomDims(0)

;---Read sapefile lat/lon
  lon  = f->x
  lat  = f->y
  nlatlon = dimsizes(lat)

;
; Get the approximate lat/lon box that encloses all of the
; given country. This will make our checking go faster.
;
  min_lat = min(lat)
  max_lat = max(lat)
  min_lon = min(lon)
  max_lon = max(lon)

  print("==================================================")
  print("Shapefile:         "  + sfilename)
  print("Areas of interest: " + str_join(mask_names,","))
  print("min_lat " + min_lat)
  print("max_lat " + max_lat)
  print("min_lon " + min_lon)
  print("max_lon " + max_lon)
;
; Get the approximate index values that contain the area of interest.
;
; This will make our gc_inout loop below go faster, because we're
; not checking every single lat/lon point to see if it's within
; the area of interest.
;
  ii_latlon = ind(min_lat.le.lat1d.and.lat1d.le.max_lat.and.\
                  min_lon.le.lon1d.and.lon1d.le.max_lon)
  nii = dimsizes(ii_latlon)
  print(nii + " values to check")

;
; These are the names in BOL_adm1.shp:
; Chuquisaca, Cochabamba, El Beni, La Paz, Oruro
; Pando, Potosí, Santa Cruz, Tarija
;
  names = f->NAME_1

;---Create array to hold new data mask, and set all values to 0 initially.
  data_mask_1d = new(dimsizes(lat1d),integer)
  data_mask_1d = 0

;
; This is the loop that checks every point in lat1d/lon1d to see if it
; is inside or outside of the country. If it is inside, then data_mask_1d
; will be set to 1.
;
  ikeep = 0    ; Counter to see how many points were found inside the country
  do i=0,numFeatures-1
    if(any(names(i).eq.mask_names)) then
      do n=0,nii-1
        ii = ii_latlon(n)
        startSegment = geometry(i, geom_segIndex)
        numSegments  = geometry(i, geom_numSegs)
        do seg=startSegment, startSegment+numSegments-1
          startPT = segments(seg, segs_xyzIndex)
          endPT   = startPT + segments(seg, segs_numPnts) - 1
          if(data_mask_1d(ii).ne.1.and.\
             gc_inout(lat1d(ii),lon1d(ii),\
                      lat(startPT:endPT),lon(startPT:endPT))) then
            data_mask_1d(ii) = 1
            ikeep = ikeep+1
          end if
        end do
      end do
    end if
  end do
  print(ikeep + " values kept")
  print("==================================================")

;
; Create a 2D data array of same size as original data,
; but with appropriate values masked.
;
  data_mask = (where(onedtond(data_mask_1d,dims).eq.1,data,\
              data@_FillValue))
  copy_VarMeta(data,data_mask)      ; Copy all metadata

;---Print timings
  mask_end_time = get_cpu_time()
  print("Elapsed time in CPU second for 'mask_data_by_gadm_name' = " + \
         (mask_end_time-mask_start_time))

  return(data_mask)
end

;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
;---Shapefile to use for masking
 gadm_shp  = "$NCL_SELFLIB/../shp/cnmap/gadm36_CHN_1.shp"
 mask_name = "Shanghai"

;---Read lat/lon off shapefile
 s         = addfile(gadm_shp,"r")
 slat      = s->y
 slon      = s->x

;---Read precipitation data to contour and mask
  dir      = "/home/yangsong3/data-observation/PRECPT/"
  filename = "GPCC_precip.mon.total.05x05.v7.nc"
  f        = addfile(dir+filename,"r")
  ts       = f->p(0,:,:)
  printVarSummary(ts)

;---Start the graphics
  wtype          = "png"
  wtype@wkWidth  = 2500        ; use for "png" or "x11"
  wtype@wkHeight = 2500
  wks = gsn_open_wks(wtype,"../fig/mask_gadm_by_name")

  res                 = True                    ; plot mods desired

  res@cnFillOn        = True                    ; turn on color
  res@cnFillMode      = "RasterFill"
  res@cnLinesOn       = False                   ; turn off lines
  res@cnLineLabelsOn  = False                   ; turn off labels

  res@mpMinLatF       = min(ts&lat)
  res@mpMaxLatF       = max(ts&lat)
  res@mpMinLonF       = min(ts&lon)
  res@mpMaxLonF       = max(ts&lon)

;---Create global plot of original data
  res@tiMainString    = filename
  plot = gsn_csm_contour_map(wks,ts, res)

;---Mask "ts" against named areas in the shapefile
  areas_of_interest = (/"Shanghai"/)
  ts_mask = mask_data_by_gadm_name(gadm_shp,ts,areas_of_interest)
  printVarSummary(ts_mask)

;---Set some additional resources for the second set of plots

  res@gsnDraw         = False                   ; don't draw yet
  res@gsnFrame        = False                   ; don't advance frame yet

;---Pick "nice" contour levels for both plots
  mnmxint = nice_mnmxintvl( min(ts_mask), max(ts_mask), 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = mnmxint(0)
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)/4.

  res@mpMinLatF       := min(slat)
  res@mpMaxLatF       := max(slat)
  res@mpMinLonF       := min(slon)
  res@mpMaxLonF       := max(slon)

  res@mpFillOn        = False
  res@mpOutlineOn     = False

  res@gsnRightString  = ""
  res@gsnLeftString   = ""

  res@lbLabelBarOn    = False

;---Create plot of original data
  res@tiMainString    = "original data zoomed in"
  plot_orig = gsn_csm_contour_map(wks,ts, res)

;---Create plot of masked data
  res@tiMainString = str_join(areas_of_interest,",")
  plot_mask = gsn_csm_contour_map(wks, ts_mask, res)

;---Add shapefile outlines to both plots
  lnres             = True
  lnres@gsLineColor = "NavyBlue"

  id_orig = gsn_add_shapefile_polylines(wks,plot_orig,gadm_shp,lnres)
  id_mask = gsn_add_shapefile_polylines(wks,plot_mask,gadm_shp,lnres)

;---Panel both plots on one page
  pres                  = True
  pres@txString         = ts@long_name + " (" + ts@units + ")"
  pres@gsnMaximize      = True
  pres@gsnPanelLabelBar = True
  gsn_panel(wks,(/plot_orig,plot_mask/),(/1,2/),pres)
end
