
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
begin
    
    ; lvl weight array, 0=++, 4=--
    wgt_arr=(/1.,1.,1.,1.,1./)
    ;wgt_arr=(/0.05, 0.1, 0.45, 0.3, 0.1/)

    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
    ; fcst_mon is the flag of which mon is predicted, 1-Jan and 12-Dec
    fcst_mon=6

    ;Fig name
    g_fig_name="../../fig/forecast-station-cfs-prec"
    
    ;Font size
    g_font=0.012

    ;Countor Level for Stations
    cn_levels=5


    ; *** T+1 EC S2S in ***
    raw_data="../../data/realtime/CFSv2.Prec.202005*"
    all_files=systemfunc("ls "+raw_data)
    print(all_files)
    raw_in=addfiles(all_files, "r")
    
    ; var1(nlat0, nlon0)
    var=raw_in[:]->anom
    var:=var(:,0,0,:,:)
    var_ano=dim_avg_n_Wrap(var,0)
    var_ano=(var_ano*30/80.88)*100
    ; fcst_mon is the flag of which mon is predicted, 1-Jan and 12-Dec
    ;fcst_mon=raw_in->fcst_mon
     
    ;Fig title
    fig_title=month_abbr(fcst_mon)+" Prec Anom Fcst"

   
    ; *** Sta in ***
    pdata_fn     = "../../data/station/south_china_result.csv"
    rec=readAsciiTable(pdata_fn, 5, "float",1 )
    
    ; rec
    ; 0     station number
    ; 1     lat*100
    ; 2     lon*100
    ; 3     alt in m 
    ; 4     pc score
    n_sta=dimsizes(rec)
    n_sta:=n_sta(0)


   ; *** Sta Statistics in ***
    ; rec
    ; 0     station number
    ; 1-12  prob of positive anomaly in each mon

    pdata_fn     = "../../data/station/south_china_statistics.csv"
    rec_prob=readAsciiTable(pdata_fn, 13, "float",0 )


;**********************************************************************************************
    wks = gsn_open_wks("png",g_fig_name)       ; open file to plot 
;-----------------------------------------------------------------------------

    plot = new((/1/),graphic)

    ;color table
    color_table="precip_diff_12lev"
    ;color_table="radar"
    gsn_define_colormap(wks,color_table) ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;  gsn_define_colormap(wks,"precip4_diff_19lev")
    ;  gsn_define_colormap(wks,"precip_diff_12lev")
    ; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    ; gsn_define_colormap(wks,"NCV_jaisnd")
    ; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
    ; gsn_define_colormap(wks,"MPL_ocean")
    ; gsn_define_colormap(wks,"MPL_Blues")

    cmap = read_colormap_file(color_table)    ; returns 254 x 4 array (R, G, B, T) dim4-Transparency
    rgba = span_color_rgba(cmap,cn_levels)
    rgb_all=new((/cn_levels,4/),"float")
   ; rgb_all(0,:)=(/0.5,0.5,0.5,1.0/) 
    rgb_all(:,:)=(/rgba/)


  res                  = True       ; use plot options

  res@gsnFrame         = False
  res@gsnDraw  = False
  res@gsnLeftString =  fig_title
  ;res@gsnCenterString = "PM2.5_diff(no-gz_test)"
  res@gsnRightStringFontHeightF=0.01
  res@gsnRightString = "Updated On: "+systemfunc("date")
  res@gsnStringFontHeightF = g_font
  res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
 
  res@cnFillOn=True
  res@cnFillMode           = "CellFill" ; Raster Mode

  res@cnLevelSelectionMode="ExplicitLevels"
  ;res@cnLevels = (/-2, -1, 1, 2/) ; fake values to erease shading colors
  res@cnLevels = (/-3000, -2000, 2000, 3000/) ; fake values to erease shading colors in the map
  res@lbLabelStrings      =(/"-50%","-20%","+20%","+50%"/)

  res@mpMinLatF            = 16        ; zoom in on map
  res@mpMaxLatF            = 27
  res@mpMinLonF            = 104
  res@mpMaxLonF            = 118
 
;  res@mpMinLatF            = 20       ; zoom in on map
;  res@mpMaxLatF            = 60
;  res@mpMinLonF            = 90
;  res@mpMaxLonF            = 140



  res@mpGeophysicalLineThicknessF = 2.0 ;costal line thick
  res@tmXBTickSpacingF = 4.0
  res@tmYLTickSpacingF = 2.0

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
res@mpDataBaseVersion       = "MediumRes"
res@mpDataSetName           = "Earth..4"
res@mpAreaMaskingOn         = True
res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
res@mpLandFillColor         = "white"
res@mpInlandWaterFillColor  = "white"
res@mpOceanFillColor        = "blue"
;res@mpOutlineBoundarySets   = "NoBoundaries"

  plot = gsn_csm_contour_map_ce(wks,var_ano, res) ; dim1 = 0 for lvl = 0
;  plot2 = gsn_csm_map(wks, res) ; dim1 = 0 for lvl = 0
;  overlay(plot,plot2)
;>============================================================<
;                      add China map
;>------------------------------------------------------------<
  cnres           = True
  cnres@china     = False       ;draw china map or not
  cnres@river     = False       ;draw changjiang&huanghe or not
  cnres@province  = True       ;draw province boundary or notcnres@nanhai    = False       ;draw nanhai or not 
  cnres@nanhai    = False       ;draw nanhai or not 
  cnres@city      = True     ; draw diqujie or not
  cnres@county      = True     ; draw county

  chinamap = add_china_map(wks,plot,cnres)


  gsres=True
  gsres@gsMarkerIndex=16
  gsres@gsMarkerSizeF      = 0.015
  gsres@gsMarkerThicknessF = 0.7
  gsres_out=gsres
  gsres_out@gsMarkerSizeF      = 0.018
  gsres_out@gsMarkerColor="Black"
  
  ; 6-lv PS counts  
  n_lvls=(/0,0,0,0,0/)
  
  
  ; loop stations
  do ii = 0, n_sta-1
   
    ; get station lat lon  
    lon_int=floor(rec(ii,2)/100.0)
    lon_flot=(rec(ii,2)-lon_int*100)/60
    
    lat_int=floor(rec(ii,1)/100.0)
    lat_flot=(rec(ii,1)-lat_int*100)/60
    
    sta_lon=lon_int+lon_flot
    sta_lat=lat_int+lat_flot
    
    sta_ano=0.0

    ; loop thru esms
    sta_ano=wgt_areaave(var_ano({sta_lat-1.0:sta_lat+1.0},{sta_lon-1.0:sta_lon+1.0}),1.0 ,1.0, 0)
    ;sta_ano=var_ano(jj,{sta_lat},{sta_lon})
    ;sta_ano=var_ano_mean({sta_lat},{sta_lon})
    ;sta_ano=sta_ano+100*(0.5-rec_prob(ii, fcst_mon))
    ; anom levels based on PS
    if sta_ano .gt. 50 then
        n_color = 4 
        n_lvls(4)=n_lvls(4)+1
    else if sta_ano .gt. 20 then
        n_color = 3
        n_lvls(3)=n_lvls(3)+1
    else if sta_ano .gt. -20 then
        n_color = 2
        n_lvls(2)=n_lvls(2)+1
    else if sta_ano .gt. -50 then
        n_color =1
        n_lvls(1)=n_lvls(1)+1
    else
        n_color =0
        n_lvls(0)=n_lvls(0)+1
    end if
    end if
    end if
    end if
    gsres@gsMarkerColor      = rgb_all(n_color,:)
    
    plot@$unique_string("fuck ncl")$ = gsn_add_polymarker(wks,plot,sta_lon,sta_lat,gsres_out)
    plot@$unique_string("fuck ncl")$ = gsn_add_polymarker(wks,plot,sta_lon,sta_lat,gsres)


  end do

  tres  = True
  tres@txFontHeightF = 0.014
  tres@txJust="TopLeft"
  tlat=20.5
  tlon=113.0
  
  dum5    = gsn_add_text(wks,plot,"Num Station: "+n_sta,tlon,tlat,tres)
  tlat=20.0
  dum4    = gsn_add_text(wks,plot,"Num Ano+2: "+n_lvls(4),tlon,tlat,tres)
  tlat=19.5
  dum3    = gsn_add_text(wks,plot,"Num Ano+1: "+n_lvls(3),tlon,tlat,tres)
  tlat=19.0
  dum2    = gsn_add_text(wks,plot,"Num Ano00: "+n_lvls(2),tlon,tlat,tres)
  tlat=18.5
  dum1    = gsn_add_text(wks,plot,"Num Ano-1: "+n_lvls(1),tlon,tlat,tres)
  tlat=18.0
  dum0    = gsn_add_text(wks,plot,"Num Ano-2: "+n_lvls(0),tlon,tlat,tres)


  draw(plot)
  frame(wks)
end
