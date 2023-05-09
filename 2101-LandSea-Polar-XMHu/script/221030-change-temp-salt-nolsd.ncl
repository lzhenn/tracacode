;************************************************************
;Aim: Change pop init to NO_LSD 
;     
;
;                       Zhenning Li
;                       2022-10-30
;Last Edited:
;   2015-01-18  Create
;   2022-10-30  Modify for XM's exp (I am still in science...)
;*************************************************************

begin
    data_file_in   =   "/home/lzhenn/temp/Drake_Closure/ts_PHC2_jan_ic_gx1v6_20210211.ieeer8"
    data_file_out   =   "/home/lzhenn/temp/NO_LSD/ts_PHC2_jan_ic_gx1v6_20221030.ieeer8"
    
    latlon_in="/home/lzhenn/temp/Drake_Closure/domain.ocn.gx1v6.210211.nc"
    latlonf=addfile(latlon_in,"r") 
    lat2d     = latlonf->yc
    lon2d     = latlonf->xc
    setfileoption("bin","ReadByteOrder","BigEndian")
    tracer = fbindirread (data_file_in, 0, -1, "double")
    tracer:=reshape(tracer,(/2,60,384,320/))
    print(tracer(1,0,49,:))
    tracer@lat2d=lat2d
    tracer@lon2d=lon2d
    tracer@_FillValue=-99

    guess     = 1                ; use zonal means
    is_cyclic = True             ; cyclic [global]
    nscan     = 150             ; usually much less than this
    eps       = 1.e-2            ; variable dependent
    relc      = 0.6              ; relaxation coefficient
    opt       = 0                ; not used

    poisson_grid_fill( tracer(:,0,:,:), is_cyclic, guess, nscan, eps, relc, opt) 
    tracer(:,:,0:1,:)=-99
    tracer(:,:,382:383,:)=-99

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
    plot = gsn_csm_contour_map(wks,tracer(0,0,:,:),res)  
    draw(plot)
    frame(wks)

    sys=systemfunc("rm "+data_file_out)
    setfileoption("bin","WriteByteOrder","BigEndian")
    fbindirwrite (data_file_out, tracer)

end
