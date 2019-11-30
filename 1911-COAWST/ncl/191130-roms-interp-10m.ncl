;***********************************************
; roms_4.ncl
;
; Concepts illustrated:
;   - Plotting ROMS data
;   - Drawing curly vectors
;   - Loading NCL functions from another script
;***********************************************
; Example of using a donated library: ROMS_utils.ncl
;
; Specifically: roms depth slice using roms_3d_interp
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;
; This file still has to be loaded manually
load "./ROMS_utils.ncl"

begin
;***********************************************
; User settings
;***********************************************
   date    = 20121002
;  path    = "/mnt/drobilica2/OPERATIONAL/ROMS/archive/"
   path    = "./"    ; new input directory
   fhis    = "../data/1911-COAWST/joe_tc_ctrl/ocean_joe_tcs_his.nc"
   outfile = "roms_4"
   variable= "temp"
   depth   = -5.0
   rec     = 0
                     
   minValue = 15.0   ; manually set contour levels and spacing
   maxValue = 25.0
   step     =  0.2
   stride   =  10
   
;***********************************************
; Read file date and use ROMS_utils.ncl
;***********************************************
   his   =  addfile (fhis,"r")

   latlonin= addfile("../data/1911-COAWST/joe_tc_ctrl/wrfout_d01.nc","r")
   lon2d = latlonin->XLONG(0,:,:)
   lat2d = latlonin->XLAT(0,:,:)
   out   = roms_3d_interp(his,variable,rec,depth)

  print("Done with roms_3d_interp")
  out@lat2d = lat2d
  out@lon2d = lon2d
;************************************************
; create plot
;************************************************
   wks_type = "png"        ; or "ps"
  ;wks_type@wkWidth = 800 
  ;wks_type@wkHeight= 800 
  ;wks_type@wkOrientation = "Portrait"
   wks  = gsn_open_wks (wks_type, "../fig/roms")         ; open workstation
                                          
  vres1 = True               ; plot mods desired
  vres1@gsnDraw              = False
  vres1@gsnFrame             = False
  vres1@gsnMaximize          = True    ; Maximize plot in frame
  vres1@gsnPaperOrientation  = "Portrait"
  vres1@cnFillDrawOrder      = "PreDraw"
  vres1@cnFillOn             = True               ; turn on color for contours
  vres1@cnFillPalette        = "BlAqGrYeOrReVi200"; set color map
  vres1@cnLinesOn            = False              ; turn off contour lines
  vres1@cnLineLabelsOn       = False              ; turn off contour line labels
  vres1@cnFillMode           = "RasterFill"
  vres1@gsnScalarContour     = True               ; contours desired
  vres1@mpLandFillColor      = "gray"             ; set land to be gray
  vres1@lbLabelBarOn         = True
  vres1@lbLabelStride        = stride

  vres1@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  vres1@cnMinLevelValF       = minValue           ; set min contour level
  vres1@cnMaxLevelValF       = maxValue           ; set max contour level
  vres1@cnLevelSpacingF      = step               ; set contour spacing

; Also could use
;;maxlev  = ....
;;mnmxint = nice_mnmxintvl( min(out), max(out), maxlev, False)
;;res@cnLevelSelectionMode   = "ManualLevels"
;;res@cnMinLevelValF         = mnmxint(0)
;;res@cnMaxLevelValF         = mnmxint(1)
;;res@cnLevelSpacingF        = mnmxint(2)         ; step

  vres1@lbOrientation        = "Vertical"         ; Vertical label bar
  vres1@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer
  vres1@pmLabelBarDisplayMode= "Always"           ; Turn on a label bar.
  vres1@lbPerimOn            = False              ; no box around it
  vres1@lbBoxLinesOn         = True               ; Yes/No labelbar box lines.

  offset = 0.1                                    ; arbitrary space buffer around region
  lon1   = min(lon2d)-offset
  lat1   = min(lat2d)+offset
  lon2   = max(lon2d)-offset
  lat2   = max(lat2d)+offset

; MAP
  vres1@mpProjection = "Mercator"
  vres1@mpLimitMode         = "Corners"             ; choose range of map
  vres1@mpLeftCornerLatF    = lat1
  vres1@mpLeftCornerLonF    = lon1
  vres1@mpRightCornerLatF   = lat2
  vres1@mpRightCornerLonF   = lon2
  vres1@mpDataBaseVersion      = "HighRes"          ; use high resolution coast
  vres1@pmTickMarkDisplayMode  = "Always"           ; turn on tickmarks
  vres1@mpLandFillColor      = -1
   
  vres1@gsnLeftString  = "temperature at 10m depth"
  vres1@gsnRightString    = ""

  plot = gsn_csm_contour_map(wks,out,vres1)
  draw(plot)
  frame(wks)

end
