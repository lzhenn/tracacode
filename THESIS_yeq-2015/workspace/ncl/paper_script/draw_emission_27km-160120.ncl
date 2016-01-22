;***********************************************
; Draw PM2.5 diff between SEN and BASE 
;      from CCTM
;
; jobs:
;   1.Read CCTM 9km data (BASE)
;   2.Post process the data
;   3.Display the figure
;                       L_Zealot
;                       2015-06-15
; 2015-06-15    Created;
; 2015-08-23   Modified to fit PM2.5 from CCTM
; 2015-08-24   Modified to overlap wind from WRF
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"
begin

	g_font =0.022

; ==============================================================
; Mission1.    Read emission & CMAQ_27km lat, lon
; ==============================================================
    
    ctrl_in      = addfile("/home/yangsong3/data/model/L_Zealot/THESIS_yeq-2015/SMOKE_source/egt27-all-2010110700.ncf","r")
    ctrl_var     = ctrl_in->SO2(24,0,:,:)                 ; znw(bottom_top_stag)
    ctrl_var     = ctrl_var*64/1000
    ;ave_so2 = dim_avg_n_Wrap(ctrl_var(:,:,:),0)

    latlon_in   =  addfile("/home/yangsong3/data/model/L_Zealot/THESIS_yeq-2015/mcip/GRIDCRO2D_27km","r")
    ctrl_var@lat2d     = latlon_in->LAT(0,0,:,:) 
    ctrl_var@lon2d     = latlon_in->LON(0,0,:,:)
    ;ave_so2@lat2d     = latlon_in->LAT(0,0,:,:)                ; znw(bottom_top_stag)
    ;ave_so2@lon2d     = latlon_in->LON(0,0,:,:)                ; znw(bottom_top_stag)

;**********************************************************************************************
;MISSION.3		Plot Clim monthly mean to check the result
;**********************************************************************************************
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
 res@cnMinLevelValF        = 0          ; set min contour level
 res@cnMaxLevelValF        = 150          ; set max contour level
 res@cnLevelSpacingF       = 2          ; set contour interval

  ;res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnLeftString = ""
  res@gsnCenterString = "SO2" 
  res@gsnRightString = ""
  res@gsnStringFontHeightF = g_font
  res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelStride          = 10
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  
  res@mpMinLatF            = 18       ; zoom in on map
  res@mpMaxLatF            = 44
  res@mpMinLonF            = 90
  res@mpMaxLonF            = 130

  res@mpGeophysicalLineThicknessF = 2.0	;costal line thick
  res@tmXBTickSpacingF = 2
  res@tmYLTickSpacingF = 2

res@tmXBLabelFontHeightF =g_font
res@tmYLLabelFontHeightF = g_font
res@gsnStringFontHeightF = g_font
res@tiMainFontHeightF= g_font
;res@lbLabelFontHeightF = 0.02
;res@pmLabelBarOrthogonalPosF = .12           ; move label bar down
res@tmXBMajorThicknessF = 2.0
res@tmYLMajorThicknessF = 2.0
res@tmXBMinorThicknessF = 2.0
res@tmYLMinorThicknessF = 2.0
res@tmBorderThicknessF = 2.0
res@tmYLMajorLengthF = 0.002


res@mpFillOn                = True
res@mpOutlineOn             = False  ; Use outlines from shapefile
res@cnFillDrawOrder         = "PreDraw"
res@mpDataBaseVersion       = "MediumRes"
res@mpDataSetName           = "Earth..4"
res@mpAreaMaskingOn         = True
res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
res@mpLandFillColor         = "white"
res@mpInlandWaterFillColor  = "white"
;res@mpOceanFillColor        = "white"
;res@mpOutlineBoundarySets   = "NoBoundaries"

    g_fig_name =  "../../fig/emission-27km"
	wks = gsn_open_wks("png",g_fig_name)       ; open file to plot 
    ;-----------------------------------------------------------------------------

    ;plot = new((/1/),graphic)

    ;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;  gsn_define_colormap(wks,"precip4_diff_19lev")
    ;  gsn_define_colormap(wks,"precip_diff_12lev")
    ; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    ; gsn_define_colormap(wks,"NCV_jaisnd")
    ; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
    ; gsn_define_colormap(wks,"MPL_ocean")
     gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

      plot = gsn_csm_contour_map(wks,ctrl_var,res) ; dim1 = 0 for lvl = 0
     ;>============================================================<
     ;                      add China map
     ;>------------------------------------------------------------<
;             cnres           = True
;             cnres@china     = False       ;draw china map or not
;             cnres@river     = False       ;draw changjiang&huanghe or not
;             cnres@province  = True       ;draw province boundary or not
;             cnres@nanhai    = False       ;draw nanhai or not 
;             cnres@diqu      = True       ; draw diqujie or not
;
;             chinamap = add_china_map(wks,plot,cnres)
     ;>============================================================<
      draw(plot)
      frame(wks)

end
