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



  setvalues NhlGetWorkspaceObjectId() 
    "wsMaximumSize" : 100000000000000
  end setvalues
;
; Using -999 here indicates using default lat/lon range
; 
  topo_file = "/home/lzhenn/array/lzhenn/data/topo/ETOPO2v2g_f4.nc"
  a         = addfile(topo_file,"r")
  elev      = a->z
  lat      = a->y
  lon      = a->x
  elev!0="lat"
  elev!1="lon"
  elev&lat=lat
  elev&lon=lon
  printVarSummary(elev)



  wks  = gsn_open_wks("eps","../fig/map_only_heating_center")      ; send graphics to PNG file

  elev = where(elev.lt.-100.,elev@_FillValue,elev)
  elev({0:60},{30:120}) = where(elev({0:60},{30:120}).lt.3500.,2500,elev({0:60},{30:120})+1500)
  elev = where(elev.lt.5000.,2500,elev)


  cmap = read_colormap_file("OceanLakeLandSnow") ; read color data

;---Set some resources for contouring and mapping
  res                    = True

  res@gsnMaximize        = True     ; maximize plot in frame

  res@cnFillOn           = True     ; turn on contour fill
  res@cnFillPalette      = cmap(2:,:) ; set color map
  res@cnLinesOn          = False    ; turn off contour lines
  res@cnLineLabelsOn     = False    ; turn off line labels
  res@cnInfoLabelOn      = False    ; turn off info label
  res@lbBoxLinesOn       = False    ; turn off labelbar box lines

  res@cnFillMode         = "MeshFill"   ; for faster draw

;---Pick "nice" contour levels
  mnmxint = nice_mnmxintvl( min(elev), max(elev), 18, False)
  res@mpCenterLonF=180.0
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 0.
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)/8.   ; Increase the number of levels 
                                             ; by choosing a smaller spacing.
  res@gsnAddCyclic         = False           ; don't add longitude cyclic point

;---Zoom in on map
  res@mpFillOn             = True
  res@mpOceanFillColor     = "LightBlue"
  res@mpLandFillColor      = "transparent"
  res@mpFillDrawOrder      = "PostDraw"

  res@pmTickMarkDisplayMode       = "Always"
  res@mpGeophysicalLineThicknessF = 1 

  plot = gsn_csm_contour_map(wks,elev,res)

end
