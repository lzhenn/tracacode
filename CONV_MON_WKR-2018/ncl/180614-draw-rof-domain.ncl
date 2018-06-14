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
    data_file_in   =   "/users/yangsong3/CESM/input/lnd/clm2/rtmdata/rdirc_0.5x0.5_simyr2000_slpmxvl_c120717.nc"
    dataf=addfile(data_file_in,"r")
    lat2d     = dataf->yc
    lon2d     = dataf->xc
    idx       = dataf->RTM_FLOW_DIRECTION
    printMinMax(idx,0)
    idx@lat2d=lat2d
    idx@lon2d=lon2d
  
  
  wks  = gsn_open_wks("x11","../fig/rof-domain")            ; send graphics to PNG file
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
