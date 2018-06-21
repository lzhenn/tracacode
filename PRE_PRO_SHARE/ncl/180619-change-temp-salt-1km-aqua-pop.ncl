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
    data_file_in   =   "/users/yangsong3/CESM/input/ocn/pop/gx1v6/ic/ts_PHC2_jan_ic_gx1v6_20090205.ieeer8"
    data_file_out   =   "/users/yangsong3/CESM/input/ocn/pop/gx1v6/ic/ts_pure_aqua_polar_mixed_layer_PHC2_jan_ic_gx1v6_20180613.ieeer8"
    
    latlon_in="/users/yangsong3/L_Zealot/B/B20f19-realworld/exe/B20f19-realworld.pop.h.0021-04.nc"
    latlonf=addfile(latlon_in,"r") 
    lat2d     = latlonf->TLAT
    lon2d     = latlonf->TLONG
    setfileoption("bin","ReadByteOrder","BigEndian")
    tracer = fbindirread (data_file_in, 0, -1, "double")
    tracer:=reshape(tracer,(/2,60,384,320/))
    print(tracer(1,0,49,:))
    tracer@lat2d=lat2d
    tracer@lon2d=lon2d
    tracer@_FillValue=-99

    guess     = 1                ; use zonal means
    is_cyclic = True             ; cyclic [global]
    nscan     = 1500             ; usually much less than this
    eps       = 1.e-2            ; variable dependent
    relc      = 0.6              ; relaxation coefficient
    opt       = 0                ; not used

    poisson_grid_fill( tracer(:,0:9,:,:), is_cyclic, guess, nscan, eps, relc, opt) 
    tracer(:,:,0:1,:)=-99
    tracer(:,:,382:383,:)=-99
    ;do ii=1,26
    ;    tracer(:,ii:,ii+1,:)=-99.0
    ;    tracer(:,ii:,382-ii,:)=-99.0
    ;end do
    


    wks  = gsn_open_wks("x11","../fig/pop-tracer")            ; send graphics to PNG file
    cmap = read_colormap_file("BlAqGrYeOrRe")       ; read color data
    res                      = True                 ; plot mods desired
    res@gsnDraw              = False                ; don't draw yet
    res@gsnFrame             = False                ; don't advance frame yet
    res@cnFillOn             = True                 ; turn on color fill
    res@cnLinesOn            = False                ; turn off contour lines
    res@cnLineLabelsOn       = False                ; turn off contour line labels
    ;res@cnFillMode           = "CellFill"
    res@gsnLeftString = "SURF_AQUA SURF T"
    res@gsnRightString = "degC"
    plot = gsn_csm_contour_map(wks,tracer(0,8,:,:),res)  
    draw(plot)
    frame(wks)

    sys=systemfunc("rm "+data_file_out)
    setfileoption("bin","WriteByteOrder","BigEndian")
    fbindirwrite (data_file_out, tracer)

end
