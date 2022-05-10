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
load "/disk/hq247/yhuangci/resource/ncl-resource/cnmap-zhenning/cnmap.ncl"
;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
        
    mon="oct"
    type="with"

    species=(/"CL2","CL","HOCL","CLO","FMCL","HCL","CLNO2","CLNO3","BR","BRO",\
              "HOBR","HBR","BR2","BRNO3","BRNO2","FMBR","CH3BR","MB3","MB2","MB2C",\
              "MBC2","MBC","DMS","MSA","BRCL","I","IO","HI","I2","HOI",\
              "INO","INO2","INO3","OIO","I2O4","I2O2","I2O3","CH3I","ICL","IBR",\
              "MI2","MIB","MIC"/)
    ;
    g_font=0.015


    ;grid file
    grid_fn="/disk/hq247/yhuangci/resource/map_info/research_domains/27km/GRIDCRO2D.27km"
    latlon_in   =  addfile(grid_fn,"r")
    lat2d = latlon_in->LAT(0,0,:,:)
    lon2d = latlon_in->LON(0,0,:,:)

    ;File IO
    ocean_fn=addfile("dis_to_coast_27km.nc","r")
    dis_coast=ocean_fn->dis_to_coast
    dis_coast=where(dis_coast .eq. 999, 0, dis_coast) 
    dis_coast=dis_coast*27  ;convert to km

    ;File IO
    pdata_fn  =systemfunc("ls ../../../data/cmaq/with/"+mon+"/COMBINE_CCTM_ACONC_27km_2016*") 
    ctrl_in = addfiles(pdata_fn ,"r")  ; open output netCDF file
    var1_with = ctrl_in[:]->O3(:,0,:,:)

    var1_with_mean=dim_avg_n_Wrap(var1_with,0)


    pdata_fn  =systemfunc("ls ../../../data/cmaq/without/"+mon+"/COMBINE_CCTM_ACONC_27km_2016*") 
    ctrl_in = addfiles(pdata_fn ,"r")  ; open output netCDF file
    var1_without = ctrl_in[:]->O3(:,0,:,:)

    var1_without_mean=dim_avg_n_Wrap(var1_without,0)
    var1_diff=var1_with_mean
    var1_diff=(/var1_with_mean-var1_without_mean/)*1000

    dis_1d=ndtooned(dis_coast)
    print(max(dis_1d))
    print(min(dis_1d))
    var1_1d=ndtooned(var1_diff)
;************************************************
; plotting parameters
;************************************************
 wks  = gsn_open_wks("png","scatter")             ; send graphics to PNG file
 
 res                     = True                   ; plot mods desired
 
 res@gsnFrame         = False
 res@gsnDraw  = False
 res@gsnMaximize         = True                   ; maximize plot in frame
 res@xyMarkLineModes     = (/"Markers"/)  ; choose which have markers
 res@xyMarkers           = 1                     ; choose type of marker 
 res@xyMarkerColor       = "gray"                  ; Marker color
 res@xyMarkerSizeF       = 0.01                  ; Marker size (default 0.01)
 res@xyDashPatterns      = 1                      ; solid line 
; res@xyLineThicknesses   = (/1,2/)                ; set second line to 2
 res@tiYAxisFontHeightF = g_font
 res@tiXAxisFontHeightF = g_font
 res@tiYAxisString = "O3 Diff (HAL-BASE, ppb)"
 res@tiXAxisString = "Distance (km)"
 res@gsnStringFontHeightF=g_font
 res@gsnLeftString = "(d) "+mon
 res@gsnRightString = "O3 Diff (ppb)"

 plot  = gsn_csm_xy (wks,dis_1d, var1_1d,res)        ; create plot

;---------------------------Add plot legend-----------------------------------
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 1.                    ; solid line
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    res_lines@gsLineColor       = "black"

    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification
    res_text@txFontColor        = "Blue"
    res_text@txFontHeightF      = 0.03

    yy = (/-12.0,0.0/)
    xx = (/0,0/)
    dum11 = gsn_add_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    dum12 = gsn_add_text(wks,plot,"At Sea",500,-10.0,res_text); add text
    
    res_text@txFontColor        = "Brown"
    dum22 = gsn_add_text(wks,plot,"In Land",-2000,-10.0,res_text); add text
    draw(plot)
    frame(wks)
end




