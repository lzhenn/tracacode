;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"

begin


;======================================================
;Variables List:
;	t2m--------------Air Temperature (K, TLL)
;======================================================

  case1="surf-aqua"
  ctrl_in1         = addfile("/users/yangsong3/L_Zealot/B/B20f19-"+case1+"/exe/B20f19-"+case1+".cam.h0.0005-08.nc","r")

  case2="topo"
  ctrl_in2         = addfile("/users/yangsong3/L_Zealot/B/B20f19-"+case2+"/exe/B20f19-"+case2+".cam.h0.0005-08.nc","r")

;global variables
    ;Define parameters
    var1 = ctrl_in1->TS
    var2 = ctrl_in2->TS
    diffvar=var1
    diffvar=var1-var2
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
  ;res@mpMinLatF=60
  res@gsnPolar = "NH"
  res@gsnLeftString=case1+ "-" + case2
  plot = gsn_csm_contour_map_polar(wks,diffvar(0,:,:),res)  
  polyres                   = True
  polyres@gsMarkerIndex     = 1          ; polymarker style
;  polyres@gsMarkerSizeF     = 1.          ; polymarker size
  polyres@gsMarkerThicknessF     = 1.          ; polymarker size
  polyres@gsMarkerColor     = "black"          ; polymarker size


;************************************
; create overlays of both lat/lon contours
; and add to the map plot
;************************************
; now we draw the whole thing and advance the frame.
  draw(plot)
  frame(wks)
end

