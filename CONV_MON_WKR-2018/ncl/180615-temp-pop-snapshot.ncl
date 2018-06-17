;================================================;
;  Popgrid_1.ncl
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  case="pure-aqua"
  f         = addfile("/users/yangsong3/L_Zealot/B/B20f19-"+case+"/exe/B20f19-"+case+".pop.h.0001-03.nc","r")

  t         = f->TEMP
  lat2d     = f->TLAT
  lon2d     = f->TLONG
  t@lat2d=lat2d
  t@lon2d=lon2d
 printVarSummary(lat2d)
;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("x11","../fig/popgrid")            ; send graphics to PNG file
  cmap = read_colormap_file("BlAqGrYeOrRe")       ; read color data
  res                      = True                 ; plot mods desired
  res@gsnDraw              = False                ; don't draw yet
  res@gsnFrame             = False                ; don't advance frame yet
  res@cnFillOn             = True                 ; turn on color fill
  res@cnFillPalette        = cmap(8:94,:)         ; set color map
  res@cnLinesOn            = False                ; turn off contour lines
  res@cnLineLabelsOn       = False                ; turn off contour line labels
  res@mpMaxLatF=-60
  res@gsnPolar = "SH"
  plot = gsn_csm_contour_map_polar(wks,t(0,0,:,:),res)  
  polyres                   = True
  polyres@gsMarkerIndex     = 1          ; polymarker style
;  polyres@gsMarkerSizeF     = 1.          ; polymarker size
  polyres@gsMarkerThicknessF     = 1.          ; polymarker size
  polyres@gsMarkerColor     = "black"          ; polymarker size


dims=dimsizes(lat2d)
do ii=0,dims(0)-1
    do jj=0,dims(1)-1
        if (lat2d(ii,jj) .gt. 60) then
;            plot@$unique_string("fxxk ncl")$    = gsn_add_polymarker(wks,plot,lon2d(ii,jj),lat2d(ii,jj),polyres)
        end if
    end do
end do
;************************************
; create overlays of both lat/lon contours
; and add to the map plot
;************************************
; now we draw the whole thing and advance the frame.
  draw(plot)
  frame(wks)
  end

