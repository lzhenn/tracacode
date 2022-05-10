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
    
    ;grid file
    grid_fn="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/gridsys/wrf/wrf-9km.nc"
    
    ;Traj Scenary
    tra_scen="traj_100m"

    ;Resident time file
    data_file_name1="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/xiamen/"+tra_scen+"/2015/"
   

    ;Fig name
    g_fig_name="../fig/source-grid-xiamen-2015"
    
    ;Fig title
    fig_title="Source grid density"

    ;
    g_font=0.025
    ncol=5
;---------------Read lat-lon config-------------------
    latlon_in   =  addfile(grid_fn,"r")
    lat2d = latlon_in->XLAT(0,:,:)
    lon2d = latlon_in->XLONG(0,:,:)
    grid_dim=dimsizes(lat2d) 
    var1=new((/grid_dim(0),grid_dim(1)/), float)  ; just get the gridsystem, resident time
    var1!0="corx"
    var1!1="cory"
    var1&corx=ispan(1,grid_dim(0),1)
    var1&cory=ispan(1,grid_dim(1),1)
    var1@lat2d=lat2d
    var1@lon2d=lon2d


    printVarSummary(var1)

    all_res_files = systemfunc ("ls "+data_file_name1+"record-hr*"); ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")

; set plot----------------------------------------------------
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
 res@cnMinLevelValF        = 1          ; set min contour level
 res@cnMaxLevelValF        = 20          ; set max contour level
 res@cnLevelSpacingF       = 1          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

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

  res@mpMinLatF            = min(var1@lat2d)        ; zoom in on map
  res@mpMaxLatF            = max(var1@lat2d)
  res@mpMinLonF            = min(var1@lon2d)
  res@mpMaxLonF            = max(var1@lon2d)

;  res@mpMinLatF            = 22        ; zoom in on map
;  res@mpMaxLatF            = 29
;  res@mpMinLonF            = 115
;  res@mpMaxLonF            = 121

  res@mpGeophysicalLineThicknessF = 2.0 ;costal line thick
  res@tmXBTickSpacingF = 4
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

;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = True       ; draw diqujie or not

var1=0
do ff=0, dimsizes(all_res_files)-1
;---------------Read data-------------------
    pt_record = readAsciiTable(all_res_files(ff), ncol, "float",0)
    dim_pt=dimsizes(pt_record)
    n_pts=dim_pt(0)
    ; Get point coordinate and regrid 
    do ii = 0, n_pts-1
        lat0=pt_record(ii,3)  ; pt_record--> [3] lat, [4] lon
        lon0=pt_record(ii,4)
        point=getind_latlon2d(lat2d,lon2d,lat0,lon0)
        cor_x=point(0,0)
        cor_y=point(0,1)
        ; Organize points in to var1
        var1(floattoint(cor_x),floattoint(cor_y))=var1(floattoint(cor_x),floattoint(cor_y))+1
    end do
    wks = gsn_open_wks("png",g_fig_name+"_"+(ff+1)+"day-24hr")       ; open file to plot 
    gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
    res@gsnLeftString="-"+(ff+1)+" Day Traj Density, Sep 2015"
    plot = gsn_csm_contour_map(wks,var1,res) ; dim1 = 0 for lvl = 0
    chinamap = add_china_map(wks,plot,cnres)
    draw(plot)
    frame(wks)
    delete([/pt_record, wks, plot, chinamap/])
    var1=0
end do
end
