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
    
   
    ;Fig name
    g_fig_name="../fig/anom_pc_score_psedo"
    
    ;Fig title
    fig_title="Pc Score on Test Set (2008-2016)"

    ;Font size
    g_font=0.02

    ;Countor Level for Stations
    cn_bin=0.05
    cn_levels=10

    ;File IO
    pdata_fn     = "../testdata/south_china_result.csv"
    rec=readAsciiTable(pdata_fn, 5, "float",1 )
    
    ; rec
    ; 0     station number
    ; 1     lat*100
    ; 2     lon*100
    ; 3     alt in m 
    ; 2     pc score
    n_sta=dimsizes(rec)
    n_sta:=n_sta(0)

    print("nstations="+n_sta)
;**********************************************************************************************
    wks = gsn_open_wks("png",g_fig_name)       ; open file to plot 
;-----------------------------------------------------------------------------

plot = new((/1/),graphic)

;color table
color_table="radar"

;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"NCV_jaisnd")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
; gsn_define_colormap(wks,"MPL_ocean")
; gsn_define_colormap(wks,"MPL_Blues")

cmap = read_colormap_file(color_table)    ; returns 254 x 4 array
rgba = span_color_rgba(cmap,cn_levels)
rgb_all=new((/cn_levels+1,4/),"float")
rgb_all(0,:)=(/0.5,0.5,0.5,1.0/)
rgb_all(1:,:)=(/rgba/)

;gsn_define_colormap(wks,rgb_all) ; choose a colormap 
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
 res@cnMinLevelValF        = 0.5          ; set min contour level
 res@cnMaxLevelValF        = 0.95          ; set max contour level
 res@cnLevelSpacingF       = 0.05         ; set contour interval
 res@cnFillColors=rgb_all
 res@gsnSpreadColors      = True               ; use full color map
  
  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  res@lbLabelStride = 1

  psedo=new((/50,50/), "float")
  psedo=0.4
  psedo(0,:)=fspan(0.45,1.0,50)

  plot = gsn_csm_contour(wks,psedo,res) ; dim1 = 0 for lvl = 0
 

 exit
;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = True      ; draw diqujie or not

  chinamap = add_china_map(wks,plot,cnres)

  gsres=True
  gsres@gsMarkerIndex=16
  gsres@gsMarkerSizeF      = 0.015
  gsres@gsMarkerThicknessF = 0.7
  gsres_out=gsres
  gsres_out@gsMarkerSizeF      = 0.018
  gsres_out@gsMarkerColor="Black"
  
  
  do ii = 0, n_sta-1
    n_color=floattoint(floor((rec(ii,4)-0.5)/cn_bin))
    if n_color .lt. 0.0 then
        n_color = 0
    end if
    gsres@gsMarkerColor      = rgb_all(n_color,:)
    
    lon_int=floor(rec(ii,2)/100.0)
    lon_flot=(rec(ii,2)-lon_int*100)/60
    
    lat_int=floor(rec(ii,1)/100.0)
    lat_flot=(rec(ii,1)-lat_int*100)/60
    
    sta_lon=lon_int+lon_flot
    sta_lat=lat_int+lat_flot
    
    plot@$unique_string("fuck ncl")$ = gsn_add_polymarker(wks,plot,sta_lon,sta_lat,gsres_out)
    plot@$unique_string("fuck ncl")$ = gsn_add_polymarker(wks,plot,sta_lon,sta_lat,gsres)
  end do

  draw(plot)
  frame(wks)

end
