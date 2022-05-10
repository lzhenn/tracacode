load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"

begin
;  f0=addfile("/ees/users/EMG/chang/wrf/WPS/geo_em.d03.nc","r")
;  lon=f0->XLONG(0,:,:)
;  lat=f0->XLAT(0,:,:)
  f0=addfile("/users/yangsong3/L_Zealot/wrf/WPS/geo_em/no-urb/geo_em.d03.nc","r")
;   f0=addfile("/ees/users/EMG/zhiyong/wrfchem/3.4.1/WPS2/met_em.d01.2010-06-30_12:00:00.nc","r")
  lon=f0->XLONG_M(0,:,:)
  lat=f0->XLAT_M(0,:,:)
  lu=f0->LU_INDEX(0,:,:)
  lu@description = ""
  lu@units = ""
  

  g_font=0.025

  printVarSummary(lon)
  printVarSummary(lat)
  printVarSummary(lu)
   info     = (/ "1 Evergreen Needleleaf Forest          ", \  ; n=0   
                 "2 Evergreen Broadleaf Forest           ", \
                 "3 Deciduous Needleleaf Forest          ", \
                 "4 Deciduous Broadleaf Forest           ", \
                 "5 Mixed Forests                        ", \
                 "6 Closed Shrublands                    ", \
                 "7 Open Shrublands                      ", \
                 "8 Woody Savannas                       ", \
                 "9 Savannas                             ", \
                 "10 Grasslands                          ", \
                 "11 Permanent Wetlands                  ", \
                 "12 Croplands                           ", \
                 "13 Urban and Built-Up                  ", \
                 "14 Cropland/Natural Vegetation Mosaic  ", \
                 "15 Snow and Ice                        ", \
                 "16 Barren or Sparsely Vegetated        ", \
                 "17 Water                               ", \
                 "18 Wooded Tundra                       ", \
                 "19 Mixed Tundra                        ", \
                 "20 Barren Tundra                       " /) 

colors     = (/\ 
"white",\
"black",\
"darkolivegreen", \ ;1
"darkgreen", \ ;2
"limegreen", \ ;3
"darkolivegreen3", \ ;4
"darkolivegreen2", \ ;5
"green2", \ ;6
"darkolivegreen1", \    ;7
"darkkhaki", \ ;8
"greenyellow", \ ;9
"palegreen1", \ ;10
"lightblue", \;11
"chocolate4", \         ;12
"gray", \ ;13
"coral", \      ;14
"white", \     ;15
"lightgoldenrod1", \    ;16
"blue", \ ; 17 water
"orange1", \
"orange3", \
"lightyellow1"/) ; n=20

;************************************************
; create plot
;************************************************

  wks = gsn_open_wks("png","../fig/landuse.png")  

 ;colors = gsn_retrieve_colormap(wks)     ; retrieve color map for editing
 ;colors(2,:) = (/ 1.0, 1.0, 1.0 /)       ; replace 1st contour color with background
 gsn_define_colormap(wks,colors)     
   res                   = True              ; plot mods desired
;---Resources for filled contour plot
  
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
  res@gsnMaximize          = True
  res@gsnFrame = False
  res@gsnDraw = False
  res@cnFillOn             = True  
  res@cnLinesOn            = False
  
  res@cnLevelSelectionMode = "ExplicitLevels" ; set explict contour levels
  res@cnLevels         = ispan(1,20,1)

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = ispan(0,20,1)  

  res@pmLabelBarOrthogonalPosF = -0.08    ; move up smidge
  res@pmTickMarkDisplayMode = "Always"
 

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay       = True
  res@gsnAddCyclic         = False
  res@cnFillMode           = "CellFill" ; Raster Mode
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnRightString = ""
  res@gsnStringFontHeightF = g_font 
  res@gsnMaximize      = True       ; fill up the page
  res@gsnPaperOrientation = "portrait"

  res@tmYLMajorLengthF = 0.01
  res@tmXBMajorLengthF = 0.01
  ;res@lbLabelStride = 1  
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines
  res@mpGridSpacingF         = 0.5
  res@mpGridLineThicknessF   = 2.0
;  res@mpGridLineColor        = "Gray30"


res@mpOutlineOn             = False  ; Use outlines from shapefile
res@cnFillDrawOrder         = "PreDraw"
res@mpDataBaseVersion       = "MediumRes"
res@mpDataSetName           = "Earth..4"
res@mpAreaMaskingOn         = True
res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
res@mpLandFillColor         = "white"
res@mpInlandWaterFillColor  = "white"
;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = True       ; draw diqujie or not

  polyres                   = True
  polyres@gsMarkerIndex     = 14          ; polymarker style
  polyres@gsMarkerSizeF     = 11.          ; polymarker size
  polyres@gsMarkerThicknessF     = 3.          ; polymarker size
  polyres@gsMarkerColor     = "Red"          ; polymarker size

  tres  = True
  tres@txFontHeightF = 0.012 
  tres@txJust="TopLeft"
  tlat=36.0
  tlon=121.0

  polymaxres=polyres
  polymaxres@gsMarkerIndex     = 5          ; polymarker style
  polymaxres@gsMarkerColor     = "red"          ; polymarker size
  polymaxres@gsMarkerThicknessF     = 5.          ; polymarker size

res = wrf_map_resources(f0,res)


  ;  plot = gsn_csm_contour_map_ce(wks, lu, res) ; create plot
   plot = gsn_csm_contour_map(wks, lu, res)

    chinamap = add_china_map(wks,plot,cnres)
;
;add text 
;
  rtxt = True
  rtxt@txJust        = "CenterLeft"
  rtxt@txFontHeightF = 0.011

                            ; 4 rows x 6 columns of text
  n  = -1
  xx = 0.05   
  do ncol=0,3
     yy = 0.15 
    do nrow=0,5
       n = n+1
       if n .lt. 20 then
        gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       end if
       yy = yy - 1.5*rtxt@txFontHeightF
    end do
     xx = xx + 0.24 
  end do

 draw(plot)
  frame(wks)
end
