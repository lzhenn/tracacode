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
    g_lonE=210
    g_file_name="/Users/zhenningli/data/obv/SODA/soda3.3.1_mn_ocean_reg_"
    g_data_path1 = "/Users/zhenningli/data/obv/NCEP-DOE/monthly/uwnd.10m.mon.mean.nc"
    g_data_path2 = "/Users/zhenningli/data/obv/PRECT/gpcp.precip.mon.nc"


    g_strt_mon = 198001 
    g_lst_mon = 201512
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
    var1:=clmMonTLL(var1)
    clim_lonmean_var1=dim_avg_n_Wrap(var1,2)
    clim_lonmean_var1=-clim_lonmean_var1
    ctrl_file4   = g_data_path2
	ctrl_in4     = addfile (ctrl_file4, "r")   ; note the "s" of addfile
	time_hist1    := ctrl_in4->time
    yyyymm1  := cd_calendar(time_hist1,-1)
    istrt   = ind(yyyymm1 .eq. g_strt_mon)
    ilast   = ind(yyyymm1 .eq. g_lst_mon)
	var4  =ctrl_in4->precip(istrt:ilast,:,:)		; p for unify the var name
    var4:=var4(:,{g_latS:g_latN},{g_lonW:g_lonE})
    var4=month_to_season12(var4)
    var4:=clmMonTLL(var4)
    clim_lonmean_var4=dim_avg_n_Wrap(var4,2)
    all_files = systemfunc ("ls "+g_file_name+"198[2]*"); ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile

    t    = ctrl_in[:]->temp(:,{:500},{g_latS:g_latN},{g_lonW:g_lonE})     ; global 5 meter temperature
    v    = ctrl_in[:]->v(:,{:500},{g_latS:g_latN},{g_lonW:g_lonE})     ; global 5 meter temperature
    mlt    = ctrl_in[:]->mlt(:,{g_latS:g_latN},{g_lonW:g_lonE})     ; global 5 meter temperature
    
    season_t=month_to_season12(t)
    clim_t=clmMonTLLL(season_t)
    clim_lonmean_t=dim_avg_n_Wrap(clim_t,3)
  
    season_mlt=month_to_season12(mlt)
    clim_mlt=clmMonTLL(season_mlt)
    clim_lonmean_mlt=dim_avg_n_Wrap(clim_mlt,2)

    printVarSummary(clim_lonmean_mlt)
    xx=clim_lonmean_mlt&latitude
    yy=clim_lonmean_mlt(3,:)
  
  
    season_v=month_to_season12(v)
    clim_v=clmMonTLLL(season_v)
    clim_lonmean_v=dim_avg_n_Wrap(clim_v,3)
    ;clim_lonmean_v=where(clim_lonmean_v .lt. 0.01, clim_lonmean_v@_FillValue,clim_lonmean_v)
    clim_lonmean_w=clim_lonmean_v
    clim_lonmean_w=0
;    dzdt = f->DZDT_GDS0_DBSL_ave1m (:,:,{0},:)    ; vertical slice at the Eq. 

;************************************************
; plotting parameters
;************************************************
    wks   = gsn_open_wks ("png","../fig/depth-test")        ; open workstation
    ;gsn_define_colormap(wks,"amwg")               ; choose colormap
    gsn_define_colormap(wks,"BlAqGrYeOrReVi200")               ; choose colormap
    ;gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")               ; choose colormap

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
    res@gsnMaximize      = True                   ; make ps, eps, pdf large
    res@gsnPaperOrientation = "portrait"          ; force portrait
    res@gsnSpreadColors  = True                   ; Use full color map
    res@gsnSpreadColorStart=20                      ; do not use gray for contours

    res@cnFillOn         = True                   ; color
    res@cnLinesOn        = False
    res@cnLineLabelsOn   = False

    res@lbLabelAutoStride= True                   ; let NCL choose stride

    res@tiMainString     = "" 

    res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
    res@cnMinLevelValF       =  8.               ; set min contour level
    res@cnMaxLevelValF       =  30.               ; set max contour level
    res@cnLevelSpacingF      =  1               ; set contour spacing

    res@lbOrientation    = "Vertical"
    res@trYReverse       = True     
    res@vpHeightF= 0.5
    res@gsnLeftString="(c)"
    res@gsnCenterString=" MAM Clim Potential Temp & Meridional Current"
    res@gsnRightString=""
    ;res@gsnYAxisIrregular2Linear = True

;    dzdt = dzdt*1e5      ; scale .... arbitrary  .... nicer values 
;    dzdt@units = "1e5*( "+dzdt@units+" )"

;    plot = gsn_csm_contour(wks, dzdt(nt,:,{120:285}), res)  ; Pacific

    res@cnFillMode       = "RasterFill"           ; option
    res@gsnDraw=False
    res@gsnFrame=False

    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    vcres@vcRefAnnoOrthogonalPosF = -0.098            ; move ref vector up
    vcres@vcRefMagnitudeF         = 0.05             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.03
    vcres@vcRefAnnoString1  = "5 cm/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.015

    vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector


    plot = gsn_csm_contour(wks, clim_lonmean_t(3,:,:), res)  ; Pacific
    
    
        
    plot_V = gsn_csm_vector(wks, clim_lonmean_v(3,:,:), clim_lonmean_w(3,:,:), vcres)  ; Pacific
    overlay(plot,plot_V)
    
    xyres                 = True         ; xy plot mods desired
    xyres@vpHeightF        = .20          ; set width of second plot
    ;xyres@tmXBMinorOn     = False        ; no minor tickmarks
    xyres@tmXBLabelStride = 1            ; label stride

    xyres@gsnDraw         = False        ; don't draw yet
    xyres@gsnFrame        = False        ; don't advance frame yet

    xyres@txFontHeightF   = .015         ; change font height
    xyres@gsnCenterString=""
    xyres@trXMinF         = min(clim_lonmean_var1&lat)
    xyres@trXMaxF         = max(clim_lonmean_var1&lat)
    xyres@trYMinF         = 0 
    xyres@trYMaxF         = 10
    xyres@gsnAttachPlotsXAxis = True
    xyres@tiYAxisString=""
    xyres@xyLineThicknesses    = 4.0      ; line thicknesses
    
    xy2res=xyres
    xy2res@gsnXYBarChart=True
    xy2res@xyLineThicknesses    = 1.0      ; line thicknesses
    xy2res@gsnYRefLine=0.0
    xy2res@gsnXYBarChartBarWidth = 1.75                 ; change bar widths
    xy2res@gsnAboveYRefLineColor = "skyblue2"             ; below ref line fill blue
    xyres@trXMinF         = min(clim_lonmean_var4&lat)
    xyres@trXMaxF         = max(clim_lonmean_var4&lat)

    plotxy = gsn_csm_xy(wks,clim_lonmean_var1&lat,clim_lonmean_var1(3,:),xyres)
    plotxy2 = gsn_csm_xy(wks,clim_lonmean_var4&lat,clim_lonmean_var4(3,:),xy2res)
    overlay(plotxy,plotxy2)
    
    pres                  = True               ; polyline resources
    pres@gsLineThicknessF = 5.0                ; line thickness
    pres@gsLineColor      = "gray"
    dum=gsn_add_polyline(wks,plot,xx,yy,pres) 
    newplot = gsn_attach_plots(plot,(/plotxy/),res,xyres)
    
    draw(plot)
    frame(wks)
end
