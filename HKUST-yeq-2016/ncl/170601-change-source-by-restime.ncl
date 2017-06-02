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
;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
    
    ; Grid file
    grid_fn="/Users/zhenningli/data/HKUST-yeq-2016/gridsys/GRIDCRO2D_3km"
    
   
    ;Smoke output file
    pdata_fn     = "/Users/zhenningli/data/HKUST-yeq-2016/smoke-out/emiss_CB05.HongKong.3km_2015020.ncf"  ; open output netCDF file
    
    ;Modified output file with Long Restime Grid PM source
    pdata_long_fn     = "/Users/zhenningli/data/HKUST-yeq-2016/smoke-out/emiss_CB05.HongKong.3km_2015020.LongRestimePM.ncf"  ; open output netCDF file
   
    ;Modified output file with Short Restime Grid PM source
    pdata_short_fn     = "/Users/zhenningli/data/HKUST-yeq-2016/smoke-out/emiss_CB05.HongKong.3km_2015020.ShortRestimePM.ncf"  ; open output netCDF file

    ; Diff Fig name
    g_fig_name="../fig/PMC-0-lv5-distribute"
    
    ; Fig title
    fig_title="PMC Diff after insert new source"

    ;font size
    g_font=0.025


    ; open grid file 
    latlon_in   =  addfile(grid_fn,"r")
    lat2d = latlon_in->LAT(0,0,:,:)
    lon2d = latlon_in->LON(0,0,:,:)
    

    ;long res=68hr, short res=11hr. start @ 2015011900
    long_corx=73
    long_cory=106
    short_corx=84
    short_cory=104

    ;strong guy, typical pmc=20g/s@level13 (102m); pmfine=20g/s@level13 (102m).
    emis_corx=12
    emis_cory=60
    
    ; Process smoke outputfile
    print("Process the smoke output...")
    source_in=addfile(pdata_fn,"r")
    pmfine=source_in->PMFINE
    pmc=source_in->PMC
    
    print("Modify long restime grid PM source...")
    pmc_long=pmc
    pmfine_long=pmfine
    pmc_long(:,:,long_corx,long_cory)=pmc(:,:,long_corx,long_cory)+pmc(:,:,emis_corx,emis_cory)
    pmfine_long(:,:,long_corx,long_cory)=pmfine(:,:,long_corx,long_cory)+pmfine(:,:,emis_corx,emis_cory)
    cphdl=systemfunc("cp "+pdata_fn+" "+pdata_long_fn)
    in = addfile(pdata_long_fn,"w")
    in->PMFINE=(/pmfine_long/)
    in->PMC=(/pmc_long/)

    print("Modify short restime grid PM source...")
    pmc_short=pmc
    pmfine_short=pmfine
    pmc_short(:,:,short_corx,short_cory)=pmc(:,:,short_corx,short_cory)+pmc(:,:,emis_corx,emis_cory)
    pmfine_short(:,:,short_corx,short_cory)=pmfine(:,:,short_corx,short_cory)+pmfine(:,:,emis_corx,emis_cory)
    cphdl=systemfunc("cp "+pdata_fn+" "+pdata_short_fn)
    in = addfile(pdata_short_fn,"w")
    in->PMFINE=(/pmfine_short/)
    in->PMC=(/pmc_short/)




    ;Assign lat lon grid system
    pmc@lat2d=lat2d
    pmc@lon2d=lon2d
    pmfine@lat2d=lat2d
    pmfine@lon2d=lon2d

    pmc=pmc_short-pmc

;**********************************************************************************************
    wks = gsn_open_wks("png",g_fig_name)       ; open file to plot 
;-----------------------------------------------------------------------------

plot = new((/1/),graphic)

  gsn_define_colormap(wks,"WhViBlGrYeOrRe") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;gsn_define_colormap(wks,"ViBlGrWhYeOrRe") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"NCV_jaisnd")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
; gsn_define_colormap(wks,"MPL_ocean")
; gsn_define_colormap(wks,"MPL_Blues")

; gsn_reverse_colormap(wks)


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

; res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
; res@cnMinLevelValF        = -30          ; set min contour level
; res@cnMaxLevelValF        = 30          ; set max contour level
; res@cnLevelSpacingF       = 5          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  ;res@gsnLeftString = "11-07:00(UTC+8h)"
  ;res@gsnCenterString = "PM2.5_diff(no-gz_test)"
  res@gsnRightString = ""
  res@gsnStringFontHeightF = 0.03
  res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  
  res@cnFillMode           = "CellFill" ; Raster Mode

  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02              ; make labels smaller
  ;res@lbLabelStride = 1


  ;res@mpMinLatF            = 23       ; zoom in on map
  ;res@mpMaxLatF            = 24
  ;res@mpMinLonF            = 112
  ;res@mpMaxLonF            = 113


  res@mpMinLatF            = min(pmc@lat2d)        ; zoom in on map
  res@mpMaxLatF            = max(pmc@lat2d)
  res@mpMinLonF            = min(pmc@lon2d)
  res@mpMaxLonF            = max(pmc@lon2d)


  res@mpGeophysicalLineThicknessF = 2.0 ;costal line thick
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

 plot = gsn_csm_contour_map(wks,pmc(0,13,:,:),res) ; dim1 = 0 for lvl = 0
 
;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = True       ; draw diqujie or not

  chinamap = add_china_map(wks,plot,cnres)
  
  draw(plot)
  frame(wks)
end




