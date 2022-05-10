;************************************************
; precip.ncl
;
; Concepts illustrated:
;   - Creat 10m wind field and hourly precipitation
;
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

;************************************************
; open file and read in variable
;************************************************
  domain = (/"071300", "071500", "071700"/)
do dom = 2,2
  files           = systemfunc("ls -1 wrfout/wrfout_d0*") + ".nc"
  filename        = files(dom)
  in              = addfile(filename,"r")

  rain_exp        = wrf_user_getvar(in,"RAINNC",-1)
  rain_con        = wrf_user_getvar(in,"RAINC",-1)
  rain_tot        = rain_exp + rain_con
;  rain_tot        = rain_exp - 0.1
  copy_VarCoords(rain_exp,rain_tot)
  rain_tot@lat2d  = wrf_user_getvar(in,"XLAT",0)   ; latitude/longitude
  rain_tot@lon2d  = wrf_user_getvar(in,"XLONG",0)  ; required for plotting

  minlat = (/min(rain_tot@lat2d), min(rain_tot@lat2d), 14/)
  maxlat = (/max(rain_tot@lat2d), max(rain_tot@lat2d), 26/)
  minlon = (/min(rain_tot@lon2d), min(rain_tot@lon2d), 104/)
  maxlon = (/max(rain_tot@lon2d), max(rain_tot@lon2d), 118/)
;  xlat = wrf_user_getvar(in,"XLONG",0)
;print(xlat(0,:))
;break

  minla  = (/0,   26,  170/)
  maxla  = (/98, 125,  323/)
  minlo  = (/0,   74,   60/)
  maxlo  = (/98, 173,  216/)

  u10             = wrf_user_getvar(in,"U10",-1)
  u10@lat2d       = wrf_user_getvar(in,"XLAT",0)   ; latitude/longitude
  u10@lon2d       = wrf_user_getvar(in,"XLONG",0)  ; required for plotting
  v10             = wrf_user_getvar(in,"V10",-1)
  v10@lat2d       = wrf_user_getvar(in,"XLAT",0)   ; latitude/longitude
  v10@lon2d       = wrf_user_getvar(in,"XLONG",0)  ; required for plotting

  times           = wrf_user_getvar(in,"times",-1)  
  dims            = dimsizes(times)       
  tmp_day         = stringtoint(str_get_cols(times,8,9))
  tmp_hour        = stringtoint(str_get_cols(times,11,12)) + 8
  day             = new(dims(0),string)
  hour            = new(dims(0),string)

  do i = 0,dims(0)-1
    if ( tmp_hour(i).gt.23 ) then
      tmp_hour(i) = tmp_hour(i)-24
      tmp_day(i)  = tmp_day(i) +1
    end if
    hour(i)       = sprinti("%0.2i", tmp_hour(i))
    day(i)        = sprinti("%0.2i", tmp_day(i))
  end do

  dim = dimsizes(rain_tot)
  rain_exp_tend   = new(dim,float)
  rain_con_tend   = new(dim,float)
  rain_tot_tend   = new(dim,float)
  do it = 1,dims(0)-1             ; TIME LOOP - start at half-hour half-hourly tendencies
    rain_exp_tend(it,:,:) = rain_exp(it,:,:) - rain_exp(it-1,:,:)
    rain_con_tend(it,:,:) = rain_con(it,:,:) - rain_con(it-1,:,:)
    rain_tot_tend(it,:,:) = rain_tot(it,:,:) - rain_tot(it-1,:,:)
  end do
  copy_VarCoords(rain_tot,rain_tot_tend)
;************************************************
; plot the correlations
;************************************************

  wks_type                      = "png"         

;  wks_type@wkOrientation        = "landscape"
;  wks_type@wkOrientation        = "portrait"

;  wks_type@wkWidth              = 2500
;  wks_type@wkHeight             = 2500 

  wks                           = gsn_open_wks(wks_type,"images/"+domain(dom)+"_rainfall")           
 
;---Nuclear material contour plot
  pre_res                       = True                ; make plot mods
  pre_res@gsnMaximize           = True
  pre_res@mpDataSetName         = "Earth..4"   ; This new database contains
  pre_res@mpOutlineSpecifiers   = (/"China:states","Taiwan"/) 
  pre_res@mpDataBaseVersion     = "MediumRes"  ; Medium resolution database

  pre_res@cnFillOn              = True                ; turn on color
  pre_res@cnFillPalette         = "precip3_16lev"
  pre_res@cnConstFEnableFill    = True
  pre_res@tfDoNDCOverlay        = True
  pre_res@gsnScalarContour      = True

  pre_res@cnLinesOn             = False               ; turn off contour lines
  pre_res@cnLineLabelsOn        = False

  pre_res@cnLevelSelectionMode  = "ExplicitLevels"   ; set explicit contour levels
  pre_res@cnFillColors          = (/0,2,4,6,8,10,12,14,16/)
  pre_res@cnLevels              = (/0.1,5,10,20,30,50,70,100/)

;  pre_res@cnLabelBarEndStyle    = "ExcludeOuterBoxes"

;---Zoom in on plot
  pre_res@mpFillOn                    = False        ; turn off map fill
  pre_res@pmTickMarkDisplayMode       = "Always"      ; turn on built-in tickmarks
  pre_res@mpGeophysicalLineThicknessF = 2
  pre_res@mpGeophysicalLineColor      = "Brown"
  pre_res@mpProvincialLineColor       = "Brown"
  pre_res@mpProvincialLineThicknessF  = 2


  pre_res@mpMinLatF             = minlat(dom)
  pre_res@mpMaxLatF             = maxlat(dom)
  pre_res@mpMinLonF             = minlon(dom)
  pre_res@mpMaxLonF             = maxlon(dom)

  pre_res@gsnAddCyclic          = False               ; regional data 
  pre_res@gsnDraw               = False               ; Do not draw plot
  pre_res@gsnFrame              = False               ; Do not advance frome

  pre_res@tiMainString          = "Rammasun (1409) hourly rainfall and 10 m wind field"
  pre_res@tiMainOffsetXF        = -0.05
  pre_res@tiMainOffsetYF        = -0.025
  pre_res@tiMainFontHeightF     = 0.018

  pre_res@lbLabelBarOn          = True                ; turn off the label bar
  pre_res@lbBoxLinesOn          = False
  pre_res@lbTitleString         = "mm"
  pre_res@lbTitlePosition       = "Bottom" 
  pre_res@lbTitleFontHeightF    = 0.013
  pre_res@lbTitleOffsetF        = -0.15
  pre_res@lbLabelFontHeightF    = 0.013

  pre_res@pmLabelBarParallelPosF = 0.38
  pre_res@pmLabelBarWidthF       = 0.6
  pre_res@pmLabelBarHeightF      = 0.1

  pre_res@gsnLeftStringParallelPosF    = -0.15
  pre_res@gsnLeftStringOrthogonalPosF  = 0.05
  pre_res@gsnRightStringOrthogonalPosF = 0.047
  pre_res@gsnLeftStringFontHeightF     = 0.015
  pre_res@gsnRightStringFontHeightF    = 0.015

;************************************************
; add China map
;************************************************

  cn_res                        = True
  cn_res@china                  = False       ;draw china map or not
  cn_res@river                  = False       ;draw changjiang&huanghe or not
  cn_res@province               = False       ;draw province boundary or not
  cn_res@nanhai                 = False       ;draw nanhai or not 
  cn_res@diqu                   = True        ;draw diqujie or not

;************************************************
; add wind vector
;************************************************

  pre_res@vcLineArrowThicknessF   = 2.0              ; change vector thickness
  pre_res@vcRefAnnoOrthogonalPosF = -0.1             ; move ref vector
  pre_res@vcRefMagnitudeF         = 30.0             ; define vector ref mag
  pre_res@vcRefLengthF            = 0.05             ; define length of vec ref
  pre_res@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  pre_res@vcMinDistanceF          = 0.03
  pre_res@vcRefAnnoFontHeightF    = 0.012
  pre_res@vcLineArrowThicknessF   = 4.5              ; chang
; pre_res@vcLineArrowColor        = "purple"         ; change vector colorpurple

  pre_res@vcMonoLineArrowColor    = False
  pre_res@vcLevelSelectionMode    = "ExplicitLevels" 
  pre_res@vcLevelPalette          = "wrfwind"
  pre_res@vcLevelColors           = (/0,1,2/)
  pre_res@vcLevels                = (/17.2,32.7/)

;************************************************
; individual plots
;************************************************

  ntim  = dimsizes(times) 
  j     = 0.
  do i = 0,ntim-1
;---Pollution and Wind vector plot
    pre_res@gsnLeftString        = "Fcst: " + sprintf("%4.0f",j) + " h"
    pre_res@gsnRightString       = "LST: " + str_get_cols(times(i),0,7) + day(i) + "_" + hour(i) + str_get_cols(times(i),13,15)
;   plot                         = gsn_csm_vector_scalar_map(wks,u10(i,:,:),v10(i,:,:),rain_tot_tend(i,:,:),pre_res)
    plot                         = gsn_csm_vector_scalar_map(wks,u10(i,minla(dom):maxla(dom),minlo(dom):maxlo(dom)),v10(i,minla(dom):maxla(dom),minlo(dom):maxlo(dom)),rain_tot_tend(i,minla(dom):maxla(dom),minlo(dom):maxlo(dom)),pre_res)
;---Shi jie
;   chinamap                     = add_china_map(wks,plot,cn_res)

    ndcres               = True
    ndcres@txFontColor   = "black"
    ndcres@txFontHeightF = 0.013
    ndcres@txJust        = "BottomRight"
    name                 = "~F35~c ~F21~~N~AS.SYSU"
    gsn_text_ndc(wks,name,0.95,0.02,ndcres)

    j = j + 1
    draw(plot)
    frame(wks)
  end do
  delete(rain_exp)
  delete(rain_con)
  delete(rain_tot)
  delete(rain_exp_tend)
  delete(rain_con_tend)
  delete(rain_tot_tend)
  delete(u10)
  delete(v10)
  delete(times)
end do
;************************************************
end
