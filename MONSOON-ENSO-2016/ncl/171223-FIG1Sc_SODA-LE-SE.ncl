;******************************************************************
; godas_1.ncl
;
; Concepts illustrated:
;   - Reading SODA data files
;   - Illustrating difference between "area fill" and "raster fill" contours
;
;************************************************
; Import Libraries
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
;************************************************
;             MAIN
;************************************************
begin
    g_latS=-20
    g_latN=20
    g_lonW=150
    g_lonE=180
    g_file_name="/home/yangsong3/data/observation/SODA/soda3.3.1_mn_ocean_reg_"
    g_data_path1 = "/home/yangsong3/data/observation/NCEP_DOE/monthly/uwnd.10m.mon.mean.nc"
    g_data_path2 = "/home/yangsong3/data/observation/PRECPT/GPCP_precip.mon.mean.nc"


    g_strt_mon = 198001 
    g_lst_mon = 201512
    g_yr_start=1980
     g_nyears = g_lst_mon/100-g_strt_mon/100+1
    ; long events larger than 10 months, develop
    ;g_sp_events = (/198001,198101/) ; for test
;    g_sp_events = (/198201,198601,199101,199701,201501/)
    g_sp_events = (/198201,199101,199701/)
    n_sp_events=dimsizes(g_sp_events)
    ;g_sp_events = (/201501/)
    ; short events with 10 months, develop
    ;g_su_events = (/198201,198301/) ; for test
    g_su_events = (/199401,200201,200401,200601,200901/)
    ;g_su_events = (/201401/)
    n_su_events=dimsizes(g_su_events)


    
    ctrl_file1   = g_data_path1
	
    ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	var1  =short2flt(ctrl_in1->uwnd(istrt:ilast,0,:,:))			; p for unify the var name
   
    ;var1:=f2fsh_Wrap(var1,(/72,144/))
    var1:=var1(:,{g_latS:g_latN},{g_lonW:g_lonE})

    var1=month_to_season12(var1)
    clim_var1:=clmMonTLL(var1)
    clim_lonmean_var1=dim_avg_n_Wrap(clim_var1,2)
    ;clim_lonmean_var1=-clim_lonmean_var1
    ctrl_file4   = g_data_path2
	ctrl_in4     = addfile (ctrl_file4, "r")   ; note the "s" of addfile
	time_hist1    := ctrl_in4->time
    yyyymm1  := cd_calendar(time_hist1,-1)
    istrt1   = ind(yyyymm1 .eq. g_strt_mon)
    ilast1   = ind(yyyymm1 .eq. g_lst_mon)
	var4  =ctrl_in4->precip(istrt:ilast,:,:)		; p for unify the var name
    var4:=var4(:,{g_latS:g_latN},{g_lonW:g_lonE})
    var4=month_to_season12(var4)
    clim_var4:=clmMonTLL(var4)
    clim_lonmean_var4=dim_avg_n_Wrap(clim_var4,2)
    all_files = systemfunc ("ls "+g_file_name+"*"); ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile

    t    = ctrl_in[:]->temp(:,{:500},{g_latS:g_latN},{g_lonW:g_lonE})     ; global 5 meter temperature
    v    = ctrl_in[:]->v(:,{:500},{g_latS:g_latN},{g_lonW:g_lonE})     ; global 5 meter temperature
    mlt    = ctrl_in[:]->mlt(:,{g_latS:g_latN},{g_lonW:g_lonE})     ; global 5 meter temperature
    
    season_t=month_to_season(t,"MAM")
    clim_t=dim_avg_n_Wrap(season_t,0)
    clim_lonmean_t=dim_avg_n_Wrap(clim_t,2)
  
    season_v=month_to_season(v,"MAM")
    clim_v=dim_avg_n_Wrap(season_v,0)
    clim_lonmean_v=dim_avg_n_Wrap(clim_v,2)
    clim_lonmean_w=clim_lonmean_v
    clim_lonmean_w=0

    season_mlt=month_to_season(mlt,"MAM")
    clim_mlt=dim_avg_n_Wrap(season_mlt,0)
    clim_lonmean_mlt=dim_avg_n_Wrap(clim_mlt,1)




    smp_sp_var1 = var1(0:12*n_sp_events-1,:,:)
; var1---U var4---Pr
    do ii=0,n_sp_events-1
        i_evstrt= ind(yyyymm .eq. g_sp_events(ii)) - istrt
        smp_sp_var1(ii*12:ii*12+11,:,:) = var1(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_sp_var1_avg = clmMonTLL(smp_sp_var1)
    sp_lonmean_var1=dim_avg_n_Wrap(cmp_sp_var1_avg,2)
    sp_lonmean_var1=-(sp_lonmean_var1-clim_lonmean_var1)
    
    smp_su_var1 = var1(0:12*n_su_events-1,:,:)
    do ii=0,n_su_events-1
        i_evstrt= ind(yyyymm .eq. g_su_events(ii)) - istrt
        smp_su_var1(ii*12:ii*12+11,:,:) = var1(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_su_var1_avg = clmMonTLL(smp_su_var1)
    su_lonmean_var1=dim_avg_n_Wrap(cmp_su_var1_avg,2)
    su_lonmean_var1=-(su_lonmean_var1-clim_lonmean_var1)
 
    smp_sp_var4 = var4(0:12*n_sp_events-1,:,:)
    do ii=0,n_sp_events-1
        i_evstrt= ind(yyyymm1 .eq. g_sp_events(ii)) - istrt1
        smp_sp_var4(ii*12:ii*12+11,:,:) = var4(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_sp_var4_avg = clmMonTLL(smp_sp_var4)
    sp_lonmean_var4=dim_avg_n_Wrap(cmp_sp_var4_avg,2)
    sp_lonmean_var4=sp_lonmean_var4-clim_lonmean_var4
    
    smp_su_var4 = var4(0:12*n_su_events-1,:,:)
    do ii=0,n_su_events-1
        i_evstrt= ind(yyyymm1 .eq. g_su_events(ii)) - istrt1
        smp_su_var4(ii*12:ii*12+11,:,:) = var4(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_su_var4_avg = clmMonTLL(smp_su_var4)
    su_lonmean_var4=dim_avg_n_Wrap(cmp_su_var4_avg,2)
    su_lonmean_var4=su_lonmean_var4-clim_lonmean_var4



    smp_sp_t = t(0:n_sp_events-1,:,:,:)
    do ii=0,n_sp_events-1
        smp_sp_t(ii,:,:,:) = season_t(floattoint(floor(g_sp_events(ii)/100))-g_yr_start,:,:,:)
    end do
    cmp_sp_t_avg = dim_avg_n_Wrap(smp_sp_t,0)
    sp_lonmean_t=dim_avg_n_Wrap(cmp_sp_t_avg,2)
    
    smp_su_t = t(0:n_su_events-1,:,:,:)
    do ii=0,n_su_events-1
        smp_su_t(ii,:,:,:) = season_t(floattoint(floor(g_su_events(ii)/100))-g_yr_start,:,:,:)
    end do
    cmp_su_t_avg = dim_avg_n_Wrap(smp_su_t,0)
    su_lonmean_t=dim_avg_n_Wrap(cmp_su_t_avg,2)
    diff_lonmean_t=sp_lonmean_t
    diff_lonmean_t=sp_lonmean_t-su_lonmean_t

    sp_smplon_t=dim_avg_n_Wrap(smp_sp_t,3)
    su_smplon_t=dim_avg_n_Wrap(smp_su_t,3)
    
    smp_sp_v = v(0:n_sp_events-1,:,:,:)
    do ii=0,n_sp_events-1
        smp_sp_v(ii,:,:,:) = season_v(floattoint(floor(g_sp_events(ii)/100))-g_yr_start,:,:,:)
    end do
    cmp_sp_v_avg = dim_avg_n_Wrap(smp_sp_v,0)
    sp_lonmean_v=dim_avg_n_Wrap(cmp_sp_v_avg,2)
    
    smp_su_v = v(0:n_su_events-1,:,:,:)
    do ii=0,n_su_events-1
        smp_su_v(ii,:,:,:) = season_v(floattoint(floor(g_su_events(ii)/100))-g_yr_start,:,:,:)
    end do
    cmp_su_v_avg = dim_avg_n_Wrap(smp_su_v,0)
    su_lonmean_v=dim_avg_n_Wrap(cmp_su_v_avg,2)
    diff_lonmean_v=sp_lonmean_v
    diff_lonmean_v=sp_lonmean_v-su_lonmean_v

    sp_smplon_v=dim_avg_n_Wrap(smp_sp_v,3)
    su_smplon_v=dim_avg_n_Wrap(smp_su_v,3)

    smp_sp_mlt = mlt(0:n_sp_events-1,:,:)
    do ii=0,n_sp_events-1
        smp_sp_mlt(ii,:,:) = season_mlt(floattoint(floor(g_sp_events(ii)/100))-g_yr_start,:,:)
    end do
    cmp_sp_mlt_avg = dim_avg_n_Wrap(smp_sp_mlt,0)
    sp_lonmean_mlt=dim_avg_n_Wrap(cmp_sp_mlt_avg,1)
    
    smp_su_mlt = mlt(0:n_su_events-1,:,:)
    do ii=0,n_su_events-1
        smp_su_mlt(ii,:,:) = season_mlt(floattoint(floor(g_su_events(ii)/100))-g_yr_start,:,:)
    end do
    cmp_su_mlt_avg = dim_avg_n_Wrap(smp_su_mlt,0)
    su_lonmean_mlt=dim_avg_n_Wrap(cmp_su_mlt_avg,1)

    cmp_sp_t_var = sp_lonmean_t
    cmp_su_t_var = su_lonmean_t
    cmp_sp_v_var = sp_lonmean_v
    cmp_su_v_var = su_lonmean_v

    cmp_sp_t_var = dim_variance_n(sp_smplon_t, 0)
    cmp_su_t_var = dim_variance_n(su_smplon_t, 0)
    cmp_sp_v_var = dim_variance_n(sp_smplon_v, 0)
    cmp_su_v_var = dim_variance_n(su_smplon_v, 0)
    
  
  
    ;--------------------------------
    ;--------Sig Test----------------
    ;--------------------------------
  
    siglvl = 0.1                       ; critical sig lvl for r

    iflag= False                        ; population variance similar
    prob1 = ttest(sp_lonmean_t,cmp_sp_t_var,n_sp_events, su_lonmean_t,cmp_su_t_var,n_su_events, iflag, False) 
    prob2 = ttest(sp_lonmean_v,cmp_sp_v_var,n_sp_events, su_lonmean_v,cmp_su_v_var,n_su_events, iflag, False) 
  
   diff_lonmean_t_sig=diff_lonmean_t
    diff_lonmean_t_sig = mask(diff_lonmean_t, prob1 .lt. siglvl,True)
    diff_lonmean_v_sig=diff_lonmean_v
    diff_lonmean_v_sig = mask(diff_lonmean_v, prob2 .lt. siglvl,True)
    diff_lonmean_v_sig({0:60},{2:6}) =diff_lonmean_v({0:60},{2:6})
    diff_lonmean_v_sig({0:20},{2:8}) =diff_lonmean_v({0:20},{2:8})


    
    xx=clim_lonmean_mlt&latitude
    yy=clim_lonmean_mlt
  
  
   ;    dzdt = f->DZDT_GDS0_DBSL_ave1m (:,:,{0},:)    ; vertical slice at the Eq. 

;************************************************
; plotting parameters
;************************************************
    wks   = gsn_open_wks ("eps","../fig/paper/R1/FIGS1c_temp_depth_pr_u")        ; open workstation
    ;gsn_define_colormap(wks,"amwg")               ; choose colormap
    gsn_define_colormap(wks,"temp_diff_18lev")               ; choose colormap
    ;gsn_define_colormap(wks,"ViBlGrWhYeOrRe")               ; choose colormap

; add gray to colormap for continents  [optional]  
;
; This will not be necessary in V6.1.0 and later. Named colors can
; be used without having to first add them to the color map.
;
;  i = NhlNewColor(wks,0.7,0.7,0.7)                ; medium grey  

;****************************************************
; Standard contour with a few simple options
;****************************************************

    res                  = True                   ; plot mods desired
;    res@gsnMaximize      = True                   ; make ps, eps, pdf large
    res@gsnPaperOrientation = "portrait"          ; force portrait
    res@gsnSpreadColors  = True                   ; Use full color map
;    res@gsnSpreadColorStart=20                      ; do not use gray for contours

    res@cnFillOn         = True                   ; color
    res@cnLinesOn        = False
    res@cnLineLabelsOn   = False

    res@lbLabelAutoStride= True                   ; let NCL choose stride

    res@tiMainString     = "" 
    res@tiYAxisString="Depth (m)"
    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF       =  -2.               ; set min contour level
    res@cnMaxLevelValF       =  2.               ; set max contour level
    res@cnLevelSpacingF      =  0.25               ; set contour spacing
    res@lbOrientation    = "Vertical"
    res@trYReverse       = True     
    res@vpHeightF= 0.45
    res@gsnLeftString="(d)"
    res@gsnCenterString=" MAM LE-SE Potential Temp & Meridional Current"
    res@gsnRightString=""
    ;res@gsnYAxisIrregular2Linear = True
    res@tmYLMode="Explicit"
    res@tmYLValues = (/ 25, 50, 75, 100, 125, 150, 200,  300 /) ;interval
    res@tmYLLabels =  (/ 25, 50, 75, 100, 125, 150, 200, 300/)
    ;res@cnFillMode       = "RasterFill"           ; option
    res@gsnDraw=False
    res@gsnFrame=False

    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    vcres@vcRefAnnoOrthogonalPosF = -0.125            ; move ref vector up
    vcres@vcRefMagnitudeF         = 0.02             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.02
    vcres@vcRefAnnoString1  = "2 cm/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.015

    vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector


    plot = gsn_csm_contour(wks, diff_lonmean_t, res)  ; Pacific
    
    res3                  = True       ; use plot options
    res3@cnFillOn         = False;True       ; Fill contours
    res3@cnLinesOn        = True      ; turn off contour lines
    res3@gsnFrame         = False
    res3@gsnDraw  = False
    res3@cnLineLabelsOn   = False      ; turn off contour line labels
    res3@cnLineThicknessF = 2.0
    res3@cnInfoLabelOn = False

    res3@cnLevelSelectionMode="ExplicitLevels"
    res3@cnLevels = (/20/)
    res3@cnLineColor      = "Black"
    res3@gsnLeftString      = " "
    res3@gsnRightString      = " " 
    plot_cn=gsn_csm_contour(wks,clim_lonmean_t,res3)
    overlay(plot,plot_cn)
    res3@cnLineDashPattern      = 1
    res3@cnLineThicknessF = 2
    plot_sp=gsn_csm_contour(wks,sp_lonmean_t,res3)
    overlay(plot,plot_sp)
    res3@cnLineDashPattern      = 2
    plot_su=gsn_csm_contour(wks,su_lonmean_t,res3)
    overlay(plot,plot_su)

plot_V = gsn_csm_vector(wks, diff_lonmean_v_sig, clim_lonmean_w, vcres)  ; Pacific
    overlay(plot,plot_V)
   

;-------------------------------------------------
;-----------------------------------------------------
  res4                  = True       ; use plot options
  res4@cnFillOn         = True       ; Fill contours
  res4@cnLinesOn        = False;True      ; turn off contour lines
  res4@gsnFrame         = False
  res4@gsnDraw  = False
  res4@cnLineLabelsOn   = False      ; turn off contour line labels
  res4@cnLineThicknessF = 2.0
  res4@cnLineColor      = "black"
  res4@cnInfoLabelOn = False
  res4@cnMonoFillPattern    = True;False
  res4@cnFillPattern = 3 
  res4@cnMonoFillScale = True
  res4@cnFillScaleF = 1
  res4@cnMonoFillColor = True
  res4@cnFillColor  =  "black"
  res4@cnFillDotSizeF = 0.005
 
  res4@lbLabelBarOn = False;True   ; turn off the label bar
 
;  res4@cnLevelSelectionMode="ExplicitLevels"
;  res4@cnLevels = (/3000,1000/)
  res4@gsnLeftString      = " "
  res4@gsnRightString      = " "
 
    plot_sig = gsn_csm_contour(wks,diff_lonmean_t_sig,res4)  ; Create shaded contours
    overlay(plot,plot_sig)

    xyres                 = True         ; xy plot mods desired
    xyres@vpHeightF        = .20          ; set width of second plot
    ;xyres@tmXBMinorOn     = False        ; no minor tickmarks

    xyres@gsnDraw         = False        ; don't draw yet
    xyres@gsnFrame        = False        ; don't advance frame yet

    xyres@txFontHeightF   = .015         ; change font height
    xyres@gsnCenterString=""
    xyres@trXMinF         = min(clim_lonmean_var1&lat)
    xyres@trXMaxF         = max(clim_lonmean_var1&lat)
    xyres@trYMinF         = -2 
    xyres@trYMaxF         = 4
    xyres@gsnAttachPlotsXAxis = True
    xyres@xyLineThicknesses    = 2.0      ; line thicknesses
   
    xyres@tmXBTickSpacingF = 5
    xyres@tmXBMinorOn=False
    xyres@tmYROn              = True 
    xyres@tiYAxisString="Pr Rate (mm/day)"
    xyres@tmYROn              = True 
    ;xyres@tmYRMode="Explicit"
    xyres@tmYRLabelsOn=True
    ;xyres@tmYRValues=ispan(0,10,4)
    ;xyres@tmYRLabels=ispan(0,10,4)
    xyres@tiYAxisString="Pr Rate (mm/day)"

 
    xy2res=xyres
   ; xyres@tiYAxisString       = "Easterly Speed (m/s)"
    xy2res@tiYAxisSide="Right"
    xy2res@xyLineThicknesses    = 2.0      ; line thicknesses
    xy2res@gsnYRefLine=0.0
    xy2res@gsnXYBarChart=True
    xy2res@gsnXYBarChartBarWidth = 1                 ; change bar widths
    xy2res@gsnXYBarChartColors = (/"skyblue2"/)             ; below ref line fill blue

    xyres@xyDashPattern=1
    plotxy_sp = gsn_csm_xy(wks,sp_lonmean_var1&lat,sp_lonmean_var1(3,:),xyres)
    xyres@xyDashPattern=2
    plotxy_su = gsn_csm_xy(wks,su_lonmean_var1&lat,su_lonmean_var1(3,:),xyres)
    plotxy2_sp = gsn_csm_xy(wks,sp_lonmean_var4&lat-0.5,sp_lonmean_var4(3,:),xy2res)
    
    xy2res@gsnXYBarChartColors = (/"orangered"/)    
    plotxy2_su = gsn_csm_xy(wks,su_lonmean_var4&lat+0.5,su_lonmean_var4(3,:),xy2res)

    overlay(plotxy_sp,plotxy_su)
    overlay(plotxy_sp,plotxy2_sp)
    overlay(plotxy_sp,plotxy2_su)
    
    pres                  = True               ; polyline resources
    pres@gsLineThicknessF = 2.0                ; line thickness
    pres@gsLineColor      = "gray35"
    dum=gsn_add_polyline(wks,plot,xx,yy,pres) 


    yy=sp_lonmean_mlt
    pres@gsLineThicknessF = 2.0                ; line thickness
    pres@gsLineDashPattern      = 1
    dum1=gsn_add_polyline(wks,plot,xx,yy,pres) 
    
    yy=su_lonmean_mlt
    pres@gsLineDashPattern      = 2
    dum2=gsn_add_polyline(wks,plot,xx,yy,pres) 


    newplot = gsn_attach_plots(plot,(/plotxy_sp/),res,xy2res)

    ; add labelbar to second plot
    ;**********************************************************
  labels=(/"Long Events ----","Short Events ...."/) 
  getvalues plotxy_sp                ; get plot size for use in creating labelbar
  "vpXF"      : vpx
  "vpYF"      : vpy
  "vpHeightF" : vph
  "vpWidthF"  : vpw
  end getvalues

  nboxes = 2
  lbres                    = True          ; labelbar only resources
  lbres@vpWidthF           = 0.18 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.23 * vph     ; labelbar height
  lbres@lbBoxMajorExtentF  = 0.75          ; puts space between color boxes
  lbres@lbFillColors       = (/"skyblue2","orangered"/); labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.012         ; font height. default is small
  lbres@lbLabelJust        = "CenterLeft"  ; left justify labels
   
  gsn_labelbar_ndc(wks,nboxes,labels,0.2,0.33,lbres)

    draw(plot)
    frame(wks)
end
