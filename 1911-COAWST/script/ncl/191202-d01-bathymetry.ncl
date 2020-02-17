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
   casename="sen"
   bath_dir    = "../data/1911-COAWST/joe_tc_"+casename+"/ocean_avg.nc"
   g_font=0.02

;***********************************************
; Read file date and use ROMS_utils.ncl
;***********************************************


   fbath=  addfile(bath_dir, "r")
   var = fbath->h
   latlonin= addfile("../data/1911-COAWST/joe_tc_ctrl/wrfout_d01.nc","r")
   lon2d = latlonin->XLONG(0,:,:)
   lat2d = latlonin->XLAT(0,:,:)

   var@lat2d = lat2d
   var@lon2d = lon2d


;************************************************
; create plot
;************************************************
   wks_type = "png"        ; or "ps"
  ;wks_type@wkWidth = 800 
  ;wks_type@wkHeight= 800 
  ;wks_type@wkOrientation = "Portrait"
   wks  = gsn_open_wks (wks_type, "../fig/roms_spatial_depth")         ; open workstation
  gsn_define_colormap(wks,"MPL_YlGnBu")
;---Set plotting parameters
   res                   = True              ; plot mods desired
;---Resources for filled contour plot
  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF        = 0.          ; set min contour level
  res@cnMaxLevelValF        = 1000.          ; set max contour level
  res@cnLevelSpacingF       = 10.          ; set contour interval
  
  
  res@gsnMaximize          = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@cnFillOn             = True  
  res@cnLinesOn            = False
  ;res@cnLevelSpacingF      = 2.           ; NCL chose 4.0
  res@lbOrientation        = "Vertical"

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay       = True
  res@gsnAddCyclic         = False
  res@cnFillMode           = "CellFill" ; Raster Mode
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnRightString = ""
  res@gsnStringFontHeightF = g_font 
  res@gsnMaximize      = True       ; fill up the page
  res@gsnPaperOrientation = "portrait"

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelStride = 5
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font
  
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines
  res@mpGridSpacingF         = 5.
  res@mpGridLineThicknessF   = 2.
;  res@mpGridLineColor        = "Gray30"


res@mpOutlineOn             = False  ; Use outlines from shapefile
res@cnFillDrawOrder         = "PreDraw"
;res@mpDataBaseVersion       = "MediumRes"
;res@mpDataSetName           = "Earth..4"
;res@mpAreaMaskingOn         = True
;res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
;res@mpLandFillColor         = "white"
;res@mpInlandWaterFillColor  = "white"


 res = wrf_map_resources(latlonin,res)
 plot_sh = gsn_csm_contour_map(wks,var,res)

 draw(plot_sh)
 frame(wks)
end
