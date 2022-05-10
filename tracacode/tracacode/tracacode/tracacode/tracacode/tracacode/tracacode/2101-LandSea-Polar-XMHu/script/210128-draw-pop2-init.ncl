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
    ;data_file_in   =   "/home/lzhenn/workspace/xmhu-largerAU/ts_PHC2_jan_ic_gx1v6_20090205.ieeer8"
    data_file_in   =   "/home/lzhenn/workspace/xmhu-largerAU/ts_PHC2_jan_ic_gx1v6_larger_aus_20090205.ieeer8"
    latlon_in="/home/lzhenn/array2/lzhenn/data/CONV_MON_WRK-2018/MX_AQUAP_SCON/B20f19-pure-aqua-no-orb.pop.h.0001-01.nc"
    latlonf=addfile(latlon_in,"r") 
    lat2d     = latlonf->TLAT
    lon2d     = latlonf->TLONG
    setfileoption("bin","ReadByteOrder","BigEndian")
    tracer = fbindirread (data_file_in, 0, -1, "double")
    tracer:=reshape(tracer,(/2,60,384,320/))
    tracer@lat2d=lat2d
    tracer@lon2d=lon2d
    tracer@_FillValue=-99

    wks  = gsn_open_wks("png","../fig/pop-tracer")            ; send graphics to PNG file
    cmap = read_colormap_file("BlAqGrYeOrRe")       ; read color data
    res                      = True                 ; plot mods desired
    res@gsnDraw              = False                ; don't draw yet
    res@gsnFrame             = False                ; don't advance frame yet
    res@cnFillOn             = True                 ; turn on color fill
    res@cnLinesOn            = False                ; turn off contour lines
    res@cnLineLabelsOn       = False                ; turn off contour line labels
    res@cnFillMode           = "CellFill"
    res@gsnLeftString = "PURE_AQUA SURF T"
    res@gsnRightString = "degC"
    plot = gsn_csm_contour_map(wks,tracer(0,0,:,:),res)  
    draw(plot)
    frame(wks)

end
