;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"


begin
    
    ;grid file
    grid_fn="/disk/hq247/yhuangci/resource/map_info/research_domains/27km/GRIDCRO2D.27km"
    
    ;coast dis file 
    coast_fn     ="/disk/hq247/yhuangci/analy/halogen/result/ncl_files/v1/calc/dis_to_coast_27km.nc"  ; open output netCDF file

    ;Fig name
    g_fig_name="../fig/coastal_dis"
    
    ;Fig title
    fig_title="Distance to the Nearest Coast"

    g_font=0.02
    
    lonC=90.0
    latC=33.0
    
    ;grid file
    grid_fn="/disk/hq247/yhuangci/resource/map_info/research_domains/27km/GRIDCRO2D.27km"
    latlon_in   =  addfile(grid_fn,"r")
    lat2d = latlon_in->LAT(0,0,:,:)
    lon2d = latlon_in->LON(0,0,:,:)
    th    = latlon_in->HT(0,0,:,:) 
    th@lat2d=lat2d
    th@lon2d=lon2d
    point=getind_latlon2d(lat2d,lon2d,latC,lonC)
    cor_x=point(0,1)
    cor_y=point(0,0)


    ;Number of points
    coast_hdl=addfile(coast_fn, "r")
    dis_coast=coast_hdl->dis_to_coast
    var=dis_coast
    var1=where(dis_coast .eq. 999, 0, dis_coast) 
    var1=var1*27  ;convert to km
    var1@lat2d=lat2d
    var1@lon2d=lon2d
;**********************************************************************************************
;MISSION.4		Display 
;**********************************************************************************************
    wks = gsn_open_wks("eps",g_fig_name)       ; open file to plot 
;-----------------------------------------------------------------------------

plot = new((/1/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"NCV_jaisnd")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
; gsn_define_colormap(wks,"MPL_ocean")
 gsn_define_colormap(wks,"GMT_globe")

 gsn_reverse_colormap(wks)


  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



;  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
;  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -2900          ; set min contour level
 res@cnMaxLevelValF        = 2900          ; set max contour level
 res@cnLevelSpacingF       = 100          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  ;res@cnFillMode           = "CellFill"
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnSpreadColorStart  = 57               ; start at color 17
  res@gsnSpreadColorEnd    = 200                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnLeftString = fig_title 
  ;res@gsnCenterString = "PM2.5_diff(no-gz_test)"
  res@gsnRightString = "km"
  res@gsnStringFontHeightF = 0.03
  res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.015              ; make labels smaller
  ;res@lbLabelStride = 7 


  ;res@mpMinLatF            = 23       ; zoom in on map
  ;res@mpMaxLatF            = 24
  ;res@mpMinLonF            = 112
  ;res@mpMaxLonF            = 113


  res@mpMinLatF            = min(var1@lat2d)        ; zoom in on map
  res@mpMaxLatF            = max(var1@lat2d)
  res@mpMinLonF            = min(var1@lon2d)
  res@mpMaxLonF            = max(var1@lon2d)


  res@mpGeophysicalLineThicknessF = 2.0 ;costal line thick
  res@tmXBTickSpacingF = 15
  res@tmYLTickSpacingF = 10

res@tmXBLabelFontHeightF =g_font
res@tmYLLabelFontHeightF = g_font
res@gsnStringFontHeightF = g_font
res@tiMainFontHeightF= g_font
;res@lbLabelFontHeightF = 0.02
;res@pmLabelBarOrthogonalPosF = .12           ; move label bar down
res@tmXBMajorThicknessF = 2.0
res@tmYLMajorThicknessF = 2.0
res@tmXBMinorOn = False
res@tmXBMinorThicknessF = 2.0
res@tmYLMinorThicknessF = 2.0
res@tmBorderThicknessF = 2.0
res@tmYLMajorLengthF = 0.002


;res@mpFillOn                = True
;res@mpOutlineOn             = False  ; Use outlines from shapefile
;res@cnFillDrawOrder         = "PreDraw"
;res@mpDataBaseVersion       = "MediumRes"
;res@mpDataSetName           = "Earth..4"
;res@mpAreaMaskingOn         = True
;res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
;res@mpLandFillColor         = "white"
;res@mpInlandWaterFillColor  = "white"
;res@mpOceanFillColor        = "white"
;res@mpOutlineBoundarySets   = "NoBoundaries"

  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 3
  res3@cnLineColor      = "black"
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/ 3000./)
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "
   

  plot = gsn_csm_contour_map(wks,var1,res) ; dim1 = 0 for lvl = 0
  plotc= gsn_csm_contour(wks,th,res3) 
 ;---Resources for the polyline
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 3.0            ; line thickness   
  pres@gsLineColor      = "blue"         ; color of lines

  
  dum_track=gsn_add_polyline(wks,plot, lon2d(cor_y,:), lat2d(cor_y,:),pres)
  overlay(plot,plotc)
  draw(plot)
  frame(wks)
end




