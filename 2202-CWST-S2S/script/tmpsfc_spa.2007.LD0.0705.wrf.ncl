;******************************************************************
; WUDAPT test plots
;******************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"

begin

  latS            = 17.
  latN            = 27.5
  lonL            = 108.5
  lonR            = 119.5

  ymStrt_wrf      = 2007072000                           ; start yyyymmddhh
  ymLast_wrf      = 2007080523                           ; last

  ymStrt_cfs      = 20070720                             ; start yyyymmddhh
  ymLast_cfs      = 20070805                             ; last

  ymStrt_clm      = 20050720                             ; start yyyymmddhh
  ymLast_clm      = 20050805                             ; last

;************************************************
; open file and read in variable
;************************************************
; wrf simulation
;  files_wrf       = systemfunc("ls -1 ~/data1/model/WRF/results/forecast/atm/2007072000/wrfout_d02_2007-0*00") + ".nc"
;   files_wrf       = systemfunc("ls -1 ~/data1/model/WRF/results/forecast/atm/2007071500/wrfout_d02_2007-0*00") + ".nc"
;  files_wrf       = systemfunc("ls -1 ~/data1/model/WRF/results/forecast/atm/2007071000/wrfout_d02_2007-0*00") + ".nc"
   files_wrf       = systemfunc("ls -1 ~/data1/model/WRF/results/forecast/atm/2007070500/wrfout_d02_2007-0*00") + ".nc"
  in_wrf          = addfiles(files_wrf,"r")

  times_wrf       = in_wrf[:]->Times
  printVarSummary(times_wrf)

  times           = wrf_times_c(times_wrf,1)
  printVarSummary(times)

  yyyymmddhh_temp = cd_calendar(times,-3)

  ntStrt          = ind(yyyymmddhh_temp.eq.ymStrt_wrf)            ; index start
  ntLast          = ind(yyyymmddhh_temp.eq.ymLast_wrf)            ; index last

  yyyymmddhh      = yyyymmddhh_temp(ntStrt:ntLast)

  t2_wrf          = in_wrf[:]->TSK(ntStrt:ntLast,:,:)
  t2_wrf@lat2d    = wrf_user_getvar(in_wrf,"XLAT",0)   ; latitude/longitude
  t2_wrf@lon2d    = wrf_user_getvar(in_wrf,"XLONG",0)  ; required for plotting
  printVarSummary(t2_wrf)

  t2_wrf          = t2_wrf-273.15

  t2max_wrf       = new((/dimsizes(t2_wrf(:,0,0))/24,dimsizes(t2_wrf(0,:,0)),dimsizes(t2_wrf(0,0,:))/),"float")

  do i = 0,dimsizes(t2_wrf(:,0,0))/24-1
    t2max_wrf(i,:,:) = dim_avg_n_Wrap(t2_wrf(i*24:i*24+23,:,:),0)
  end do
  printVarSummary(t2max_wrf)
  printMinMax(t2max_wrf,False)

;  files_wrf_max   = systemfunc("ls -1 ~/data1/model/WRF/results/forecast/atm/2007072000/wrfxtrm_d02_2007-0*00") + ".nc"
;  files_wrf_max   = systemfunc("ls -1 ~/data1/model/WRF/results/forecast/atm/2007071500/wrfxtrm_d02_2007-0*00") + ".nc"
;  files_wrf_max   = systemfunc("ls -1 ~/data1/model/WRF/results/forecast/atm/2007071000/wrfxtrm_d02_2007-0*00") + ".nc"
;   files_wrf_max   = systemfunc("ls -1 ~/data1/model/WRF/results/forecast/atm/2007070500/wrfxtrm_d02_2007-0*00") + ".nc"
;  in_wrf_max      = addfiles(files_wrf_max,"r")

;  t2max_wrf_temp       = in_wrf_max[:]->SKINTEMPMEAN(ntStrt:ntLast,:,:)
;  t2max_wrf_temp@lat2d = wrf_user_getvar(in_wrf,"XLAT",0)   ; latitude/longitude
;  t2max_wrf_temp@lon2d = wrf_user_getvar(in_wrf,"XLONG",0)  ; required for plotting

;  t2_wrf_min_temp       = in_wrf_max[:]->T2MIN(ntStrt:ntLast,:,:)
;  t2_wrf_min_temp@lat2d = wrf_user_getvar(in_wrf,"XLAT",0)   ; latitude/longitude
;  t2_wrf_min_temp@lon2d = wrf_user_getvar(in_wrf,"XLONG",0)  ; required for plotting

;  t2max_wrf_temp  = t2max_wrf_temp-273.15
;  t2_wrf_min_temp  = t2_wrf_min_temp-273.15
;  printVarSummary(t2max_wrf_temp)

;  t2max_wrf       = new((/dimsizes(t2max_wrf_temp(:,0,0))/24,dimsizes(t2max_wrf_temp(0,:,0)),dimsizes(t2max_wrf_temp(0,0,:))/),"float")
;  t2_wrf_min       = new((/dimsizes(t2max_wrf_temp(:,0,0))/24,dimsizes(t2max_wrf_temp(0,:,0)),dimsizes(t2max_wrf_temp(0,0,:))/),"float")

;  do i = 0,dimsizes(t2max_wrf_temp(:,0,0))/24-1
;    t2max_wrf(i,:,:) = dim_max_n_Wrap(t2max_wrf_temp(i*24:i*24+23,:,:),0)
;    t2_wrf_min(i,:,:) = dim_min_n_Wrap(t2_wrf_min_temp(i*24:i*24+23,:,:),0)
;  end do
;  copy_VarMeta(t2max_wrf_temp,t2max_wrf(0,:,:))
;  copy_VarMeta(t2min_wrf_temp,t2_wrf_min(0,:,:))
;  printVarSummary(t2max_wrf)

; read regrid cfsv2 climo
;  in_cfs_r        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007072000/tmax.day.07.20.00Z.mean.clim.daily.regrid.nc","r")
;  in_cfs_r        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007071500/tmax.day.07.15.00Z.mean.clim.daily.regrid.nc","r")
;  in_cfs_r        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007071000/tmax.day.07.10.00Z.mean.clim.daily.regrid.nc","r")
  in_cfs_r        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007070500/tmpsfc.day.07.05.00Z.mean.clim.daily.regrid.nc","r")

  times_cfs_r     = in_cfs_r->forecast_time0
  printVarSummary(times_cfs_r)

  yyyymmdd_cfs_r_temp = cd_calendar(times_cfs_r,-2)

  ntStrt_cfs_r    = ind(yyyymmdd_cfs_r_temp.eq.ymStrt_clm)            ; index start
  ntLast_cfs_r    = ind(yyyymmdd_cfs_r_temp.eq.ymLast_clm)            ; index last

  yyyymmdd_cfs_r  = yyyymmdd_cfs_r_temp(ntStrt_cfs_r:ntLast_cfs_r)

  t2max_cfs_clm_r = in_cfs_r->tmpsfc(ntStrt_cfs_r:ntLast_cfs_r,:,:)
  t2max_cfs_clm_r = t2max_cfs_clm_r-273.15  
  printVarSummary(t2max_cfs_clm_r)

;  t2max_anom_wrf  = t2max_wrf-t2max_cfs_clm_r
  t2max_anom_wrf  = t2max_wrf
  copy_VarMeta(t2max_wrf,t2max_anom_wrf)
  printVarSummary(t2max_anom_wrf)
  printMinMax(t2max_anom_wrf,False)

  t2max_avg_wrf   = dim_avg_n_Wrap(t2max_anom_wrf,0)
  printVarSummary(t2max_avg_wrf)

; read cfsv2 hindcast


;  in_cfs          = addfile("~/data1/model/WRF/CFSv2/20070720-0805/hindcast/daily_wrf/2007072000/tmax.2007072000.2007090200.2007072000.nc","r") 
;  in_cfs          = addfile("~/data1/model/WRF/CFSv2/20070720-0805/hindcast/daily_wrf/2007071500/tmax.2007071500.2007082800.2007071500.nc","r") 
;  in_cfs          = addfile("~/data1/model/WRF/CFSv2/20070720-0805/hindcast/daily_wrf/2007071000/tmax.2007071000.2007082300.2007071000.nc","r") 
   in_cfs          = addfile("~/data1/model/WRF/CFSv2/20070720-0805/hindcast/daily_wrf/2007070500/tmpsfc.2007070500.2007081800.2007070500.nc","r") 
;   in_cfs          = addfile("~/data1/model/WRF/CFSv2/20070720-0805/hindcast/daily_wrf/2007063000/tmax.2007063000.2007081300.2007063000.nc","r") 
;   in_cfs          = addfile("~/data1/model/WRF/CFSv2/20070720-0805/hindcast/daily_wrf/2007062500/tmax.2007062500.2007080800.2007062500.nc","r") 
;  in_cfs          = addfile("~/data1/model/WRF/CFSv2/20070720-0805/hindcast/daily_wrf/2007062200/tmax.2007062200.2007080500.2007062200.nc","r") 

  times_cfs       = in_cfs->forecast_time0
  printVarSummary(times_cfs)

  yyyymmdd_cfs_temp = cd_calendar(times_cfs,-2)

  ntStrt_cfs      = ind(yyyymmdd_cfs_temp.eq.ymStrt_cfs)            ; index start
  ntLast_cfs      = ind(yyyymmdd_cfs_temp.eq.ymLast_cfs)            ; index last

  yyyymmdd_cfs    = yyyymmdd_cfs_temp(ntStrt_cfs:ntLast_cfs)

  t2max_cfs       = in_cfs->tmpsfc(ntStrt_cfs:ntLast_cfs,:,:)
  printVarSummary(t2max_cfs)

; read cfsv2 climo

  
;  in_cfs_c        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007072000/tmax.day.07.20.00Z.mean.clim.daily.nc","r")
;  in_cfs_c        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007071500/tmax.day.07.15.00Z.mean.clim.daily.nc","r")
;   in_cfs_c        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007071000/tmax.day.07.10.00Z.mean.clim.daily.nc","r")
   in_cfs_c        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007070500/tmpsfc.day.07.05.00Z.mean.clim.daily.nc","r")
;   in_cfs_c        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007063000/tmax.day.06.30.00Z.mean.clim.daily.nc","r")
;   in_cfs_c        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007062500/tmax.day.06.25.00Z.mean.clim.daily.nc","r")
;  in_cfs_c        = addfile("~/data1/model/WRF/CFSv2/20070720-0805/climo_1999-2010/daily_wrf/2007062200/tmax.day.06.22.00Z.mean.clim.daily.nc","r")

  times_cfs_c     = in_cfs_c->forecast_time0
  printVarSummary(times_cfs_c)

  yyyymmdd_cfs_c_temp = cd_calendar(times_cfs_c,-2)

  ntStrt_cfs_c    = ind(yyyymmdd_cfs_c_temp.eq.ymStrt_clm)            ; index start
  ntLast_cfs_c    = ind(yyyymmdd_cfs_c_temp.eq.ymLast_clm)            ; index last

  yyyymmdd_cfs_c  = yyyymmdd_cfs_c_temp(ntStrt_cfs_c:ntLast_cfs_c)

  t2max_cfs_clm_c = in_cfs_c->tmpsfc(ntStrt_cfs_c:ntLast_cfs_c,:,:)
  printVarSummary(t2max_cfs_clm_c)

;  t2max_anom_cfs  = t2max_cfs-t2max_cfs_clm_c
  t2max_anom_cfs  = t2max_cfs-273.15
  copy_VarMeta(t2max_cfs,t2max_anom_cfs)
  printVarSummary(t2max_anom_cfs)
  printMinMax(t2max_anom_cfs,False)

  t2max_avg_cfs   = dim_avg_n_Wrap(t2max_anom_cfs,0)
  printVarSummary(t2max_avg_cfs)

; read in-situ obervation 
  in_obs          = addfile("~/project/station/temp/daily/sta_hw_daily_mjjas_1999-2019_sel3.nc","r")
  in_obs_clm      = addfile("~/project/station/temp/daily/tmp_max_climo_1999-2010.nc","r")

  times_obs       = in_obs->time
  yyyymmdd_obs_temp = cd_calendar(times_obs,-2)

  ntStrt_obs      = ind(yyyymmdd_obs_temp.eq.ymStrt_cfs)            ; index start
  ntLast_obs      = ind(yyyymmdd_obs_temp.eq.ymLast_cfs)            ; index last

  yyyymmdd_obs    = yyyymmdd_obs_temp(ntStrt_obs:ntLast_obs)
  yyyy_obs        = yyyymmdd_obs/10000
  mm_obs          = yyyymmdd_obs/100-yyyy_obs*100
  dd_obs          = yyyymmdd_obs-yyyy_obs*10000-mm_obs*100

  sta_obs         = in_obs->sta
  lat_obs         = in_obs->lat(ntStrt_obs:ntLast_obs,:)
  lon_obs         = in_obs->lon(ntStrt_obs:ntLast_obs,:)
  t2max_obs       = in_obs->tmp_max(ntStrt_obs:ntLast_obs,:)
  printVarSummary(t2max_obs)

  lat_avg_obs     = dim_avg_n_Wrap(lat_obs,0)
  lon_avg_obs     = dim_avg_n_Wrap(lon_obs,0)
  printVarSummary(lat_avg_obs)

  sta_all         = in_obs_clm->sta
  sta_idx         = get1Dindex(sta_all,sta_obs)

  yyyy_obs        = 2000
  day_idx         = day_of_year(yyyy_obs,mm_obs,dd_obs)

  t2max_clm       = in_obs_clm->tmp_max_clm(day_idx,sta_idx)
  printVarSummary(t2max_clm)

  t2max_anom_obs  = t2max_obs-t2max_clm
;  t2max_anom_obs  = t2max_obs
  copy_VarMeta(t2max_obs,t2max_anom_obs)
  printVarSummary(t2max_anom_obs)
  printMinMax(t2max_anom_obs,False)

  t2max_avg_obs   = dim_avg_n_Wrap(t2max_anom_obs,0)
  printVarSummary(t2max_avg_obs)

;************************************************
; plot the correlations
;************************************************ 

  wks                       = gsn_open_wks("pdf","tmpsfc_spa_0705.2007.wrf") 

  plot                      = new(3,graphic)
  
;---Nuclear material contour plot
  res                       = True                ; make plot mods
  res@gsnMaximize           = False

  res@cnFillOn              = True                ; turn on color
  res@cnConstFEnableFill    = True
  res@cnFillMode            = "RasterFill"
  
;  res@cnFillPalette              = "MPL_Reds"
;  res@cnLevelSelectionMode       = "ManualLevels"
;  res@cnMinLevelValF             = 25.
;  res@cnMaxLevelValF             = 31.
;  res@cnLevelSpacingF            = 0.5

  res@cnLinesOn             = False               ; turn off contour lines
  res@cnLineLabelsOn        = False
  
    res@cnLevelSelectionMode  = "ExplicitLevels"   ; set explicit contour levels
;  res@cnFillColors          = (/0,2,4,6,8,10,12,14,16/)
  res@cnLevels             = (/-5.,-4.,-3.,-2.,-1.5,-1.,-0.5,-0.2,-0.1,-0.05,0.,\
                                0.05,0.1,0.2,0.5,1,1.5,2.,4.,3.,5./)

 
;  res@cnLabelBarEndStyle    = "ExcludeOuterBoxes"

;---Zoom in on plot
  res@mpFillOn                    = False

;  res@mpDataBaseVersion           = "RANGS"
;  res@mpDataResolution            = "Finest"

  res@mpDataSetName               = "./database/Earth..4"   ; This new database contains
  res@mpDataBaseVersion           = "MediumRes"
  res@mpOutlineSpecifiers         = (/"China","China:Provinces"/)
;  res@mpOutlineBoundarySets       = "National"
;  res@mpOutlineBoundarySets       = "NoBoundaries"  ;or National
  res@mpGeophysicalLineColor      = "DimGrey"
  res@mpNationalLineColor         = "DimGrey"
  res@mpCountyLineColor           = "DimGrey"
  res@mpProvincialLineColor       = "DimGrey"

;  res@pmTickMarkDisplayMode       = "Always"      ; turn on built-in tickmarks
;  res@mpGeophysicalLineColor      = "Black"
;  res@mpProvincialLineColor       = "Black"
;  res@mpNationalLineColor         = "Black"
  res@mpGeophysicalLineThicknessF = 2
  res@mpProvincialLineThicknessF  = 2
  res@mpNationalLineThicknessF    = 2

  res@mpMinLatF             = latS
  res@mpMaxLatF             = latN
  res@mpMinLonF             = lonL
  res@mpMaxLonF             = lonR

  res@mpCenterLonF          = 180
  res@gsnMajorLatSpacing    = 3
  res@gsnMajorLonSpacing    = 3
  res@gsnMinorLatSpacing    = 1
  res@gsnMinorLonSpacing    = 1

  res@gsnAddCyclic          = False               ; regional data 
  res@gsnDraw               = False               ; Do not draw plot
  res@gsnFrame              = False               ; Do not advance frome

  res@lbLabelBarOn          = False                ; turn off the label bar
  res@lbLabelFontHeightF    = 0.026

;  res@pmLabelBarParallelPosF   = 0.4
  res@pmLabelBarOrthogonalPosF = 0.15

  res@gsnLeftStringFontHeightF     = 0.03
  res@gsnRightStringFontHeightF    = 0.03
  res@tmXBLabelFontHeightF         = 0.03
  res@tmYLLabelFontHeightF         = 0.03

;************************************************
; individual plots
;************************************************

  res@cnFillPalette            = "BlueWhiteOrangeRed"
  res@cnLevelSelectionMode     = "ManualLevels"         ; set manual contour levels
  res@cnMinLevelValF           = 25.             ; set min contour level
  res@cnMaxLevelValF           = 32.             ; set max contour level
  res@cnLevelSpacingF          = 0.5             ; set contour spacing

  res@gsnLeftString            = "(a) OBS 2007"
  res@gsnRightString           = "~S~o~N~C"
  plot(0)                      = gsn_csm_map(wks,res)

  res@gsnLeftString            = "(b) CFSv2 0705"
  plot(1)                      = gsn_csm_contour_map(wks,t2max_avg_cfs,res)

  res@gsnLeftString            = "(c) WRF 0705"
  plot(2)                      = gsn_csm_contour_map(wks,t2max_avg_wrf,res)

  getvalues plot@contour
    "cnFillColors" : colors
    "cnLevels"     : levels
  end getvalues

  dumDot11  = new(dimsizes(t2max_avg_obs),graphic)
  dumDot12  = new(dimsizes(t2max_avg_obs),graphic)

  resDot                    = True
  resDot@gsMarkerSizeF      = 0.008
  resDot@gsMarkerThicknessF = 1.5

  do i = 0,dimsizes(t2max_avg_obs)-1

    if (.not.ismissing(t2max_avg_obs(i))) then
      idx = ind(t2max_avg_obs(i).le.levels)
      if (ismissing(idx(0))) then 
        resDot@gsMarkerColor = colors(dimsizes(colors)-1)
      else
        resDot@gsMarkerColor = colors(idx(0))
      end if
      resDot@gsMarkerIndex   = 16
      dumDot11(i) = gsn_add_polymarker(wks,plot(0),lon_avg_obs(i),lat_avg_obs(i),resDot)

;      resDot@gsMarkerIndex   = 4           ; Hollow dots
;      resDot@gsMarkerColor   = 1
;      dumDot12(i) = gsn_add_polymarker(wks,plot(0),lon_avg_obs(i),lat_avg_obs(i),resDot)
      delete(idx)
	end if

  end do

; panel the two plots together
  resPanel                     = True                 ; panel mods desired
  resPanel@gsnPanelLabelBar    = True                ; label bar on panel
  resPanel@gsnMaximize         = False                 ; fill up the page
  resPanel@lbLabelFontHeightF  = 0.014               ; label font height
  resPanel@pmLabelBarWidthF    = 0.8
  resPanel@pmLabelBarHeightF   = 0.07
  resPanel@gsnPanelYWhiteSpacePercent = 3
  resPanel@gsnPanelXWhiteSpacePercent = 3
  gsn_panel(wks,plot(0:2),(/1,3/),resPanel)

end
