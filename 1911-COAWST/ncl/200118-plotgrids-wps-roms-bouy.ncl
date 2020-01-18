
;   Script display location of model domains
;   Only works for ARW domains
;   Reads namelist file directly

load "/disk/hq247/yhuangci/resource/ncl-resource/cnmap/cnmap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/disk/hq247/yhuangci/resource/ncl-resource/wrf/WRFUserARW.ncl"

begin
;

; We generate plots, but what kind do we prefer?
;  type = "x11"
 type = "png"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"../fig/wps_show_dom")

  bouy1=(/31.831, -69.573, 41048/)
  bouy2=(/38.457, -74.702, 44009/)

; read the following namelist file
  filename = "/disk/hq247/yhuangci/lzhenn/project/1911-COAWST/data/1911-COAWST/sandy/namelist.wps"


    ; Ocean grid file
    ocn_in     = addfile("../data/1911-COAWST/sandy/Sandy_ocean_avg.nc", "r")
    lon2d=ocn_in->lon_rho
    lat2d=ocn_in->lat_rho

    dimz=dimsizes(lat2d)
    
    ; Ocean grid file
    ocn_child_in     = addfile("../data/1911-COAWST/sandy/Sandy_ocean_ref3_avg.nc", "r")
    lon2dc=ocn_child_in->lon_rho
    lat2dc=ocn_child_in->lat_rho

    dimzc=dimsizes(lat2dc)
 




; Set the colors to be used
  colors = (/"white","black","White","ForestGreen","DeepSkyBlue","white","Blue"/)
  gsn_define_colormap(wks, colors)  


; Set some map information ; line and text information
  mpres = True
  mpres@gsnDraw                 = False 
  mpres@gsnFrame                = False


  mpres@mpFillOn = True
  mpres@mpFillColors  = (/"background","DeepSkyBlue","ForestGreen","DeepSkyBlue", "LightBlue"/)
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpGridLineColor             = "Black"
  mpres@mpLimbLineColor             = "Black"
  mpres@mpNationalLineColor         = "Black"
  mpres@mpPerimLineColor            = "Black"
  mpres@mpUSStateLineColor          = "Black"
  ;mpres@mpGridSpacingF              = 45
  mpres@tiMainString                = "Domain Configuration for Sandy (2012)"

  lnres = True 
  lnres@gsLineThicknessF = 4. 
  lnres@domLineColors    = (/"White" , "Blue", "Red" , "Blue", "Red" /)

  txres = True
  txres@txString=""
  txres@txFont = "helvetica-bold"
  ;txres@txJust = "BottomLeft"
  txres@txJust = "TopLeft"
  txres@txPerimOn = False
  txres@txFontHeightF = 0.015

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not change anything between the ";;;;;" lines

  mpres@max_dom   = stringtoint  (systemfunc("grep max_dom    " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  mpres@dx        = stringtofloat(systemfunc("grep dx         " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  mpres@dy        = stringtofloat(systemfunc("grep dy         " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  mpres@ref_lat   = stringtofloat(systemfunc("grep ref_lat    " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  mpres@ref_lon   = stringtofloat(systemfunc("grep ref_lon    " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  test = systemfunc("grep truelat1 " +filename ) 
  if ( .not. ismissing(test) )
    mpres@truelat1  = stringtofloat(systemfunc("grep truelat1   " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  else
    mpres@truelat1  = 0.0
  end if
  test = systemfunc("grep truelat2 " +filename ) 
  if ( .not. ismissing(test) )
    mpres@truelat2  = stringtofloat(systemfunc("grep truelat2   " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  else
    mpres@truelat2  = 0.0
  end if
  mpres@stand_lon = stringtofloat(systemfunc("grep stand_lon  " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )

  test = systemfunc("grep lambert " +filename ) 
  if ( .not. ismissing(test) )
    mpres@map_proj          = "lambert"
  end if
  test = systemfunc("grep mercator " +filename ) 
  if ( .not. ismissing(test) )
    mpres@map_proj          = "mercator"
  end if
  test = systemfunc("grep polar " +filename ) 
  if ( .not. ismissing(test) )
    mpres@map_proj          = "polar"
  end if
  testa = systemfunc("grep 'lat-lon' " +filename ) 
  if ( .not. ismissing(testa) )
    mpres@map_proj          = "lat-lon"
    mpres@pole_lat = stringtofloat(systemfunc("grep pole_lat  " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
    mpres@pole_lon = stringtofloat(systemfunc("grep pole_lon  " +filename+ " | cut -f2 -d'=' | cut -f1 -d','" ) )
  end if

  parent_id         = new ( mpres@max_dom , integer )
  parent_grid_ratio = new ( mpres@max_dom , integer )
  i_parent_start    = new ( mpres@max_dom , integer )
  j_parent_start    = new ( mpres@max_dom , integer )
  e_we              = new ( mpres@max_dom , integer )
  e_sn              = new ( mpres@max_dom , integer )

  do n = 1, mpres@max_dom 

    n0 = n - 1
    parent_id(n0)         = stringtoint(systemfunc("grep parent_id         " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
    parent_grid_ratio(n0) = stringtoint(systemfunc("grep parent_grid_ratio " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
    i_parent_start(n0)    = stringtoint(systemfunc("grep i_parent_start    " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
    j_parent_start(n0)    = stringtoint(systemfunc("grep j_parent_start    " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
    e_we(n0)              = stringtoint(systemfunc("grep e_we              " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
    e_sn(n0)              = stringtoint(systemfunc("grep e_sn              " +filename+ " | cut -f2 -d'=' | cut -f"+n+" -d','" ) )
 
  end do 
  mpres@parent_id         = parent_id
  mpres@parent_grid_ratio = parent_grid_ratio
  mpres@i_parent_start    = i_parent_start
  mpres@j_parent_start    = j_parent_start
  mpres@e_we              = e_we 
  mpres@e_sn              = e_sn


mpres@mpOutlineOn             = True  ; Use outlines from shapefile
mpres@mpOutlineBoundarySets = "National" ;Turns on country boundaries.
mpres@mpGeophysicalLineColor = "black"
;mpres@cnFillDrawOrder         = "PreDraw"
mpres@mpDataBaseVersion       = "MediumRes"
mpres@mpDataSetName           = "Earth..4"
mpres@mpAreaMaskingOn         = True
;mpres@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
mpres@mpLandFillColor         = "gray80"
mpres@mpOceanFillColor         = "Blue"
mpres@mpInlandWaterFillColor  = "Skyblue"
;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = True       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@diqu      = True       ; draw diqujie or not

  plot = wrf_wps_dom (wks,mpres,lnres,txres)
  
;  chinamap = add_china_map(wks,plot,cnres)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Now you can add some information to the plot. 
; Below is an example of adding a white dot over the DC location.
  ;pmres = True
  ;pmres@gsMarkerColor = "White"
  ;pmres@gsMarkerIndex = 16
  ;pmres@gsMarkerSizeF = 0.01
  ;gsn_polymarker(wks,mp,-77.26,38.56,pmres)

    ;Outer Box
    res_lines=True
    res_lines@gsLineColor       = "black"
    res_lines@gsLineDashPattern = 1.
    res_lines@gsLineThicknessF  = 4.                    ; line thicker
    
    x_max=dimz(0)-1
    y_max=dimz(1)-1
    yy = (/lon2d(0,0),lon2d(0,y_max),lon2d(x_max,y_max),lon2d(x_max,0),lon2d(0,0)/)
    xx = (/lat2d(0,0),lat2d(0,y_max),lat2d(x_max,y_max),lat2d(x_max,0),lat2d(0,0)/)
    gsn_polyline(wks,plot,yy,xx,res_lines)              ; N
  
    ;Inner Box
    x_max=dimzc(0)-1
    y_max=dimzc(1)-1
    yy = (/lon2dc(0,0),lon2dc(0,y_max),lon2dc(x_max,y_max),lon2dc(x_max,0),lon2dc(0,0)/)
    xx = (/lat2dc(0,0),lat2dc(0,y_max),lat2dc(x_max,y_max),lat2dc(x_max,0),lat2dc(0,0)/)
    gsn_polyline(wks,plot,yy,xx,res_lines)              ; N
  
    pmres = True
    
    pmres@gsMarkerIndex = 16

    ; outer border
    pmres@gsMarkerColor = "Black"
    pmres@gsMarkerSizeF = 0.024
    gsn_polymarker(wks,plot,bouy1(1),bouy1(0),pmres)
    gsn_polymarker(wks,plot,bouy2(1),bouy2(0),pmres)


    ; inner border
    pmres@gsMarkerColor = "red3"
    pmres@gsMarkerSizeF = 0.018
    gsn_polymarker(wks,plot,bouy1(1),bouy1(0),pmres)
    gsn_polymarker(wks,plot,bouy2(1),bouy2(0),pmres)
    
      tres  = True
      tres@txFontHeightF = 0.018
      tres@txFontThicknessF=3.
      tres@txFontColor="White"
      tres@txJust="TopLeft"
      tlat=bouy1(0)-0.3
      tlon=bouy1(1)-1.0
    gsn_text(wks,plot,bouy1(2),tlon,tlat,tres)
     tlat=bouy2(0)-0.3
      tlon=bouy2(1)-1.0
    gsn_text(wks,plot,bouy2(2),tlon,tlat,tres)
    

    frame(wks)           ; lets frame the plot - do not delete

end
