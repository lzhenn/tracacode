;************************************************************
;Aim: Regression SST anomaly from TCP_index, and insert these 
;     anomalies to clim SST
;     
;
;Mission:
;   1. Read index data from ascii file, read sst data
;   2. Post process
;       2.1 Regression NINO3
;       2.2 Departure NINO3 signal from Anomaly pattern
;       2.3 Detrend
;       2.4 Regression TCP
;
;   3. Draw patterns 
;   4. Output SST forcing field
;                       Zhenning Li
;                       2015-01-18
;Last Edited:
;   2015-01-18  Create
;*************************************************************

begin
    data_file_in   =   "/users/yangsong3/CESM/input/ocn/pop/gx1v6/grid/region_mask_aqua_20180612.ieeei4"
    latlon_in="/users/yangsong3/L_Zealot/B/B20f19-realworld/exe/B20f19-realworld.pop.h.0021-04.nc"
    latlonf=addfile(latlon_in,"r") 
    lat2d     = latlonf->TLAT
    lon2d     = latlonf->TLONG
        setfileoption("bin","ReadByteOrder","BigEndian")
    idx = fbindirread (data_file_in, 0, -1, "integer")
    printMinMax(idx,0)
    idx:=reshape(idx,(/384,320/))
    idx@lat2d=lat2d
    idx@lon2d=lon2d
  
  
  wks  = gsn_open_wks("x11","../fig/pop-domain")            ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrRe")       ; read color data
  res                      = True                 ; plot mods desired
  res@gsnDraw              = False                ; don't draw yet
  res@gsnFrame             = False                ; don't advance frame yet
  res@cnFillOn             = True                 ; turn on color fill
  res@cnLinesOn            = False                ; turn off contour lines
  res@cnLineLabelsOn       = False                ; turn off contour line labels
  res@cnFillMode           = "CellFill"
  plot = gsn_csm_contour_map(wks,idx,res)  
  draw(plot)
  frame(wks)

end
