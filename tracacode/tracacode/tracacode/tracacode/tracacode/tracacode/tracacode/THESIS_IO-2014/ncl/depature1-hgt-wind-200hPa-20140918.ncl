; NCL script
; For Climato JJA Mass-weighted  T &  equivalent potential temperature
; Qing BAO APR. 2005
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin


  b = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   ; read in land sea mask basemap file



 f = addfile("ctrl_1949_sur_me1011-1030.nc","r")
 ter= addfile("phis.nc","r")
 f3 = addfile("/disk6/home/heb/draw/ctrl_1949_tq2/ctrl_1949_tq2_sur_me1011-1030.nc","r")

 fcp = addfile("/disk6/home/heb/draw/ctrl_1949_cp/ctrl_1949_cp_sur_me1031-1050.nc","r")
 f3cp = addfile("/disk6/home/heb/draw/ctrl_1949_tq_cp/ctrl_1949_tq_cp_sur_me1031-1050.nc","r")


 f_l = addfile("ctrl_1949_lev_me1011-1030.nc","r")
 f3_l = addfile("/disk6/home/heb/draw/ctrl_1949_tq2/ctrl_1949_tq2_lev_me1011-1030.nc","r")
 fcp_l = addfile("/disk6/home/heb/draw/ctrl_1949_cp/ctrl_1949_cp_lev_me1031-1050.nc","r")
 f3cp_l = addfile("/disk6/home/heb/draw/ctrl_1949_tq_cp/ctrl_1949_tq_cp_lev_me1031-1050.nc","r")


  phis = ter->PHIS
  phis = ter->PHIS/9.8

;printVarSummary(f->sst)
print(f_l->lev)
lv=9
print(f_l->lev(lv))

 sst_bef = f_l->hgt(:,lv,:,:)
 sst_aft = f3_l->hgt(:,lv,:,:)

  sst_bef_JJA = month_to_season(sst_bef,"JJA")
  sst_aft_JJA = month_to_season(sst_aft,"JJA")

  sst_bef_ANN = month_to_annual(sst_bef,1)
  sst_aft_ANN = month_to_annual(sst_aft,1)

  sst_bef_JJA_m = dim_avg_n_Wrap(sst_bef_JJA,0)
  sst_aft_JJA_m = dim_avg_n_Wrap(sst_aft_JJA,0)

  sst_bef_JJA_var = dim_variance_n_Wrap(sst_bef_JJA,0)
  sst_aft_JJA_var = dim_variance_n_Wrap(sst_aft_JJA,0)


 uwnd_bef = f_l->u(:,lv,:,:)   ; 850hPa
 uwnd_aft = f3_l->u(:,lv,:,:)
 
  uwnd_bef_JJA = month_to_season(uwnd_bef,"JJA")
  uwnd_aft_JJA = month_to_season(uwnd_aft,"JJA")
 
  uwnd_bef_ANN = month_to_annual(uwnd_bef,1)
  uwnd_aft_ANN = month_to_annual(uwnd_aft,1)
 
  uwnd_bef_JJA_m = dim_avg_n_Wrap(uwnd_bef_JJA,0)
  uwnd_aft_JJA_m = dim_avg_n_Wrap(uwnd_aft_JJA,0)
 
  uwnd_bef_JJA_var = dim_variance_n_Wrap(uwnd_bef_JJA,0)
  uwnd_aft_JJA_var = dim_variance_n_Wrap(uwnd_aft_JJA,0)

 vwnd_bef = f_l->v(:,lv,:,:)   ; 850hPa
 vwnd_aft = f3_l->v(:,lv,:,:)
 
  vwnd_bef_JJA = month_to_season(vwnd_bef,"JJA")
  vwnd_aft_JJA = month_to_season(vwnd_aft,"JJA")
 
  vwnd_bef_ANN = month_to_annual(vwnd_bef,1)
  vwnd_aft_ANN = month_to_annual(vwnd_aft,1)
 
  vwnd_bef_JJA_m = dim_avg_n_Wrap(vwnd_bef_JJA,0)
  vwnd_aft_JJA_m = dim_avg_n_Wrap(vwnd_aft_JJA,0)
 
  vwnd_bef_JJA_var = dim_variance_n_Wrap(vwnd_bef_JJA,0)
  vwnd_aft_JJA_var = dim_variance_n_Wrap(vwnd_aft_JJA,0)


;------
 
 sst_cp_bef = fcp_l->hgt(:,lv,:,:)
 sst_cp_aft = f3cp_l->hgt(:,lv,:,:)
 
  sst_cp_bef_JJA = month_to_season(sst_cp_bef,"JJA")
  sst_cp_aft_JJA = month_to_season(sst_cp_aft,"JJA")
 
  sst_cp_bef_ANN = month_to_annual(sst_cp_bef,1)
  sst_cp_aft_ANN = month_to_annual(sst_cp_aft,1)
 
  sst_cp_bef_JJA_m = dim_avg_n_Wrap(sst_cp_bef_JJA,0)
  sst_cp_aft_JJA_m = dim_avg_n_Wrap(sst_cp_aft_JJA,0)
 
  sst_cp_bef_JJA_var = dim_variance_n_Wrap(sst_cp_bef_JJA,0)
  sst_cp_aft_JJA_var = dim_variance_n_Wrap(sst_cp_aft_JJA,0)

print("hgt")
printMinMax(sst_bef_JJA_m,True)
printMinMax(sst_aft_JJA_m,True)
printMinMax(sst_cp_bef_JJA_m,True)
printMinMax(sst_cp_aft_JJA_m,True)

printMinMax(sst_cp_bef_JJA_var,True)
printMinMax(sst_cp_aft_JJA_var,True)


 uwnd_cp_bef = fcp_l->u(:,lv,:,:)   ; 850hPa
 uwnd_cp_aft = f3cp_l->u(:,lv,:,:)
  
  uwnd_cp_bef_JJA = month_to_season(uwnd_cp_bef,"JJA")
  uwnd_cp_aft_JJA = month_to_season(uwnd_cp_aft,"JJA")
  
  uwnd_cp_bef_ANN = month_to_annual(uwnd_cp_bef,1)
  uwnd_cp_aft_ANN = month_to_annual(uwnd_cp_aft,1)
  
  uwnd_cp_bef_JJA_m = dim_avg_n_Wrap(uwnd_cp_bef_JJA,0)
  uwnd_cp_aft_JJA_m = dim_avg_n_Wrap(uwnd_cp_aft_JJA,0)
 
  uwnd_cp_bef_JJA_var = dim_variance_n_Wrap(uwnd_cp_bef_JJA,0)
  uwnd_cp_aft_JJA_var = dim_variance_n_Wrap(uwnd_cp_aft_JJA,0)
 
 vwnd_cp_bef = fcp_l->v(:,lv,:,:)   ; 850hPa
 vwnd_cp_aft = f3cp_l->v(:,lv,:,:)
  
  vwnd_cp_bef_JJA = month_to_season(vwnd_cp_bef,"JJA")
  vwnd_cp_aft_JJA = month_to_season(vwnd_cp_aft,"JJA")
 
  vwnd_cp_bef_ANN = month_to_annual(vwnd_cp_bef,1)
  vwnd_cp_aft_ANN = month_to_annual(vwnd_cp_aft,1)
 
  vwnd_cp_bef_JJA_m = dim_avg_n_Wrap(vwnd_cp_bef_JJA,0)
  vwnd_cp_aft_JJA_m = dim_avg_n_Wrap(vwnd_cp_aft_JJA,0)
  
  vwnd_cp_bef_JJA_var = dim_variance_n_Wrap(vwnd_cp_bef_JJA,0)
  vwnd_cp_aft_JJA_var = dim_variance_n_Wrap(vwnd_cp_aft_JJA,0)

print("read in")
;---------------------------------------------



  sst_dif_JJA_m =   sst_aft_JJA_m
  sst_dif_JJA_m =   sst_aft_JJA_m -  sst_bef_JJA_m

  uwnd_dif_JJA_m =   uwnd_aft_JJA_m
  uwnd_dif_JJA_m =   uwnd_aft_JJA_m -  uwnd_bef_JJA_m
  vwnd_dif_JJA_m =   vwnd_aft_JJA_m
  vwnd_dif_JJA_m =   vwnd_aft_JJA_m -  vwnd_bef_JJA_m

sst_dif_JJA_m!0="lat"
sst_dif_JJA_m&lat=f->lat
sst_dif_JJA_m!1="lon"
sst_dif_JJA_m&lon=f->lon


  sst_cp_dif_JJA_m =   sst_cp_aft_JJA_m
  sst_cp_dif_JJA_m =   sst_cp_aft_JJA_m -  sst_cp_bef_JJA_m
 
  uwnd_cp_dif_JJA_m =   uwnd_cp_aft_JJA_m
  uwnd_cp_dif_JJA_m =   uwnd_cp_aft_JJA_m -  uwnd_cp_bef_JJA_m
  vwnd_cp_dif_JJA_m =   vwnd_cp_aft_JJA_m
  vwnd_cp_dif_JJA_m =   vwnd_cp_aft_JJA_m -  vwnd_cp_bef_JJA_m

sst_cp_dif_JJA_m!0="lat"
sst_cp_dif_JJA_m&lat=f->lat
sst_cp_dif_JJA_m!1="lon"
sst_cp_dif_JJA_m&lon=f->lon


  dim_bef = dimsizes(sst_bef_JJA)
  dim_aft = dimsizes(sst_aft_JJA)
  ndim_bef = dim_bef(0)
  ndim_aft = dim_aft(0)
print(ndim_bef)
  sst_b1 = ((ndim_bef-1.)*sst_bef_JJA_var + ((ndim_aft-1.)*sst_aft_JJA_var))/(ndim_bef + ndim_aft - 2.)
  sst_b1 = sst_b1 > 0.01
printMinMax(sst_b1,True)
  sst_b2 = (1./ndim_bef) + (1./ndim_aft)
  sst_t  = (sst_bef_JJA_m - sst_aft_JJA_m)/(sqrt(sst_b1)*sqrt(sst_b2))
printMinMax(sst_t,True)

  uwnd_b1 = ((ndim_bef-1.)*uwnd_bef_JJA_var + ((ndim_aft-1.)*uwnd_aft_JJA_var))/(ndim_bef + ndim_aft - 2.)
  uwnd_b1 = uwnd_b1 > 0.01
printMinMax(uwnd_b1,True)
  uwnd_b2 = (1./ndim_bef) + (1./ndim_aft)
  uwnd_t  = (uwnd_bef_JJA_m - uwnd_aft_JJA_m)/(sqrt(uwnd_b1)*sqrt(uwnd_b2))
printMinMax(uwnd_t,True)

  vwnd_b1 = ((ndim_bef-1.)*vwnd_bef_JJA_var + ((ndim_aft-1.)*vwnd_aft_JJA_var))/(ndim_bef + ndim_aft - 2.)
  vwnd_b1 = vwnd_b1 > 0.01
printMinMax(vwnd_b1,True)
  vwnd_b2 = (1./ndim_bef) + (1./ndim_aft)
  vwnd_t  = (vwnd_bef_JJA_m - vwnd_aft_JJA_m)/(sqrt(vwnd_b1)*sqrt(vwnd_b2))
printMinMax(vwnd_t,True)


  sst_cp_b1 = ((ndim_bef-1.)*sst_cp_bef_JJA_var + ((ndim_aft-1.)*sst_cp_aft_JJA_var))/(ndim_bef + ndim_aft - 2.)
  sst_cp_b1 = sst_cp_b1 > 0.01
printMinMax(sst_cp_b1,True)
  sst_cp_b2 = (1./ndim_bef) + (1./ndim_aft)
  sst_cp_t  = (sst_cp_bef_JJA_m - sst_cp_aft_JJA_m)/(sqrt(sst_cp_b1)*sqrt(sst_cp_b2))
printMinMax(sst_cp_t,True)

  uwnd_cp_b1 = ((ndim_bef-1.)*uwnd_cp_bef_JJA_var + ((ndim_aft-1.)*uwnd_cp_aft_JJA_var))/(ndim_bef + ndim_aft - 2.)
  uwnd_cp_b1 = uwnd_cp_b1 > 0.01
printMinMax(uwnd_cp_b1,True)
  uwnd_cp_b2 = (1./ndim_bef) + (1./ndim_aft)
  uwnd_cp_t  = (uwnd_cp_bef_JJA_m - uwnd_cp_aft_JJA_m)/(sqrt(uwnd_cp_b1)*sqrt(uwnd_cp_b2))
printMinMax(uwnd_cp_t,True)
 
  vwnd_cp_b1 = ((ndim_bef-1.)*vwnd_cp_bef_JJA_var + ((ndim_aft-1.)*vwnd_cp_aft_JJA_var))/(ndim_bef + ndim_aft - 2.)
  vwnd_cp_b1 = vwnd_cp_b1 > 0.01
printMinMax(vwnd_cp_b1,True)
  vwnd_cp_b2 = (1./ndim_bef) + (1./ndim_aft)
  vwnd_cp_t  = (vwnd_cp_bef_JJA_m - vwnd_cp_aft_JJA_m)/(sqrt(vwnd_cp_b1)*sqrt(vwnd_cp_b2))
printMinMax(vwnd_cp_t,True)




siglvl = 2.02  ; 95%, 40 num

  lat = f->lat
  lon = f->lon
 nlat = dimsizes(lat)
 nlon = dimsizes(lon)

            sst_ttt =  sst_dif_JJA_m
            sst_cp_ttt =  sst_cp_dif_JJA_m
            uwnd_ttt =  uwnd_dif_JJA_m
            uwnd_cp_ttt =  uwnd_cp_dif_JJA_m
            vwnd_ttt =  vwnd_dif_JJA_m
            vwnd_cp_ttt =  vwnd_cp_dif_JJA_m

   do i=0,nlat-1
     do j=0,nlon-1
         if( abs(sst_t(i,j)) .lt. siglvl ) then

              sst_ttt(i,j) = -999

         end if

         if( abs(sst_cp_t(i,j)) .lt. siglvl ) then
 
              sst_cp_ttt(i,j) = -999
 
         end if


         if( .not. ismissing(uwnd_t(i,j)) .and.  .not. ismissing(vwnd_t(i,j)) .and. abs(uwnd_t(i,j)) .lt. siglvl .and. abs(vwnd_t(i,j)) .lt. siglvl ) then
 
              uwnd_dif_JJA_m(i,j) = -999
              vwnd_dif_JJA_m(i,j) = -999
         end if

      if(  .not. ismissing(uwnd_cp_t(i,j)) .and.  .not. ismissing(vwnd_cp_t(i,j)) .and. abs(uwnd_cp_t(i,j)) .lt. siglvl .and. abs(vwnd_cp_t(i,j)) .lt. siglvl ) then
 
              uwnd_cp_dif_JJA_m(i,j) = -999
              vwnd_cp_dif_JJA_m(i,j) = -999
         end if

     end do
   end do

sst_ttt@_FillValue = -999
sst_cp_ttt@_FillValue = -999
uwnd_dif_JJA_m@_FillValue = -999
uwnd_cp_dif_JJA_m@_FillValue = -999
vwnd_dif_JJA_m@_FillValue = -999
vwnd_cp_dif_JJA_m@_FillValue = -999

;-----------------------------------------------------------------------------
   wks = gsn_open_wks("ps","Fig_hgt-wind-200hPa-dif")  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/2/),graphic)
  plot_tp = new((/2/),graphic)
  plot_sh = new((/2/),graphic)
  plot_V = new((/2/),graphic)
  plot_bef = new((/2/),graphic)
  plot_aft = new((/2/),graphic)

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks1,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -50.          ; set min contour level
 res@cnMaxLevelValF        =  50.          ; set max contour level
 res@cnLevelSpacingF       =  10.          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
  res@gsnSpreadColorStart  = 2                ; start at color 17
  res@gsnSpreadColorEnd    = 102                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnLeftString = "(a)"
  res@gsnCenterString = "Upper-level temperature"
  res@gsnRightString = " "
  res@gsnStringFontHeightF = 0.02

  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = 0.02             ; make labels smaller
  res@lbLabelStride = 1

  res@mpFillOn   = True;False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 

   res@mpCenterLonF = 180.
  res@mpMaxLatF  = 60.
  res@mpMinLatF  = -40.
;  res@mpMaxLonF  = 220.
;  res@mpMinLonF  = 20.

;  res@mpShapeMode = "FreeAspect" 

;  res@vpWidthF = 0.8
;  res@vpHeightF = 0.6

;  res@tmXBMajorOutwardLengthF = -0.
;  res@tmYLMajorOutwardLengthF = -0.
;  res@tmYRMajorOutwardLengthF = -0.
  
;  res@tmXBMinorOutwardLengthF = -0.
;  res@tmYLMinorOutwardLengthF = -0.
;  res@tmYRMinorOutwardLengthF = -0.

     ; now change the size of the tickmark labels
  res@tmXBTickSpacingF = 60
  res@tmYLTickSpacingF = 20
  res@tmXBLabelFontHeightF = 0.02
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = 0.02
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     


 res@gsnLeftString = "(a)"
 res@gsnCenterString = "HEAT - CON"

 plot(0) = gsn_csm_contour_map_ce(wks,sst_dif_JJA_m,res) ; create a default plot
 
; res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
; res@cnMinLevelValF        = -3.          ; set min contour level
; res@cnMaxLevelValF        =  3.          ; set max contour level
; res@cnLevelSpacingF       =  0.5          ; set contour interval
 

 res@gsnLeftString = "(b)"
 res@gsnCenterString = "HEAT_CP - CON_CP"
 plot(1) = gsn_csm_contour_map_ce(wks,sst_cp_dif_JJA_m,res) ; create a default plot


;-------------------------------------------------------------------
  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 2
  res3@cnLineColor      = "black"
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/3000,1000/)
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "


  plot_tp = gsn_csm_contour(wks,phis,res3)

;-------------------------------------------------
;-----------------------------------------------------
  res4                  = True       ; use plot options
  res4@cnFillOn         = True       ; Fill contours
  res4@cnLinesOn        = False;True      ; turn off contour lines
  res4@gsnFrame         = False
  res4@gsnDraw  = False
  res4@cnLineLabelsOn   = False      ; turn off contour line labels
  res4@cnLineThicknessF = 2
  res4@cnLineColor      = "black"
  res4@cnInfoLabelOn = False
  res4@cnMonoFillPattern    = True;False
  res4@cnFillPattern = 17
  res4@cnMonoFillScale = True
  res4@cnFillScaleF = 1.
  res4@cnMonoFillColor = True
  res4@cnFillColor  =  "red"
  res4@cnFillDotSizeF = 0.003
 
  res4@lbLabelBarOn = False;True   ; turn off the label bar
 
;  res4@cnLevelSelectionMode="ExplicitLevels"
;  res4@cnLevels = (/3000,1000/)
  res4@gsnLeftString      = " "
  res4@gsnRightString      = " "
;-----------------------------------------------------------------------------
          
  vcres = True
  vcres@gsnDraw          = False           ; don't draw
  vcres@gsnFrame         = False           ; don't advance frame
  vcres@gsnRightString   = " "             ; turn off right string
  vcres@gsnLeftString    = " "             ; turn off left string
  vcres@gsnCenterString    = " "
 
  vcres@vcRefAnnoOn      = True
  vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  vcres@vcRefMagnitudeF         = 10.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017
  vcres@vcRefAnnoString1  = "10 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.01
 
  vcres@vcLineArrowThicknessF     = 1.5    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.001
  vcres@vcLineArrowHeadMaxSizeF   = 0.015

;--------------------------------------
;-------------------------------------------------------------------
  res5                  = True       ; use plot options
  res5@cnFillOn         = False;True       ; Fill contours
  res5@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res5@gsnFrame         = False
  res5@gsnDraw  = False 
  res5@cnLineLabelsOn   = False      ; turn off contour line labels

  res5@cnLineThicknessF = 3
  res5@cnLineColors      = (/"black"/)
  res5@cnInfoLabelOn = False
  res5@cnMonoLineDashPattern  = False 
  res5@cnLineDashPatterns = (/1/)

  res5@cnLevelSelectionMode="ExplicitLevels"
  res5@cnLevels = (/12480/)
  res5@gsnLeftString      = " "
  res5@gsnRightString      = " "
  
 
  plot_bef(0) = gsn_csm_contour(wks,sst_bef_JJA_m,res5)

  res5@cnLevels = (/12480/)
  plot_bef(1) = gsn_csm_contour(wks,sst_cp_bef_JJA_m,res5)

  res5@cnLineDashPatterns = (/0/)
  res5@cnLevels = (/12480/)
  plot_aft(0) = gsn_csm_contour(wks,sst_aft_JJA_m,res5)

  res5@cnLevels = (/12480/)
  plot_aft(1) = gsn_csm_contour(wks,sst_cp_aft_JJA_m,res5)



   plot_V(0) = gsn_csm_vector(wks,uwnd_dif_JJA_m,vwnd_dif_JJA_m,vcres)

   plot_V(1) = gsn_csm_vector(wks,uwnd_cp_dif_JJA_m,vwnd_cp_dif_JJA_m,vcres)








  plot_sh(0) = gsn_csm_contour(wks,sst_ttt,res4)

  plot_sh(1) = gsn_csm_contour(wks,sst_cp_ttt,res4)

  overlay(plot(0),plot_sh(0))
  overlay(plot(1),plot_sh(1))

  overlay(plot(0),plot_V(0))
  overlay(plot(1),plot_V(1))

  overlay(plot(0),plot_bef(0))
  overlay(plot(1),plot_bef(1))
 
  overlay(plot(0),plot_aft(0))
  overlay(plot(1),plot_aft(1))


        gsn_panel(wks,plot,(/2,1/),False)

;  draw(plot)
  frame(wks)
 
 end
