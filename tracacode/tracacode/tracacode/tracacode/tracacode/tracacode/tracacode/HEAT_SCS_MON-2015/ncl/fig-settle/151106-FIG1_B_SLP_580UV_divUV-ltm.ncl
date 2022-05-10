;*************************************************************
;Aim: draw HEAT_CP - CON_CP Pr and 850UV, do the significance test 
;
;Mission:
;   1. Read data from post model datasets
;   2. Post-post process
;     2.1 Climatology 
;     2.2 Difference
;     2.3 Sig test
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-04-06
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-06  Change to fit Season jun
;   2015-06-23  Change to fit caculate ltm Wind and SLP trend
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------TS
;================================================
;global variables
    g_data_path = "../../data/obv/MSL-197901-201503.nc"
    g_data_path1 = "../../data/obv/U-197901-201408.nc"
    g_data_path2 = "../../data/obv/V-197901-201408.nc"
    g_data_path3 = "../../data/obv/VV-197901-201408.nc"

    g_latS=-5.
    g_latN=45.
    g_lonW=90.
    g_lonE=160.
; create an array of desired pressure levels:

    g_plvl = 850    
    g_font = 0.03
    g_season = "MAM"
    g_strt_mon = 197901 
    g_lst_mon = 201312
    g_date =systemfunc("date '+%Y%m%d'")
    g_fig_name    =   "../../fig/scientific_reports/Fig1b_MAM_850UV-SLP-"+g_date
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    g_fig_title     =  "UV850 SLP W500 Trend"
    ;g_fig_title1   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" SST trend"  ;for dsstdt
    ;g_fig_title2   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" SST' trend" ;for dsst'dt

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	var1  =short2flt(ctrl_in1->msl(istrt:ilast,:,:))			; p for unify the var name

    ctrl_file2   = g_data_path1
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	time_hist2    = ctrl_in2->time
    yyyymm2  = cd_calendar(time_hist2,-1)
    istrt   = ind(yyyymm2 .eq. g_strt_mon)
    ilast   = ind(yyyymm2 .eq. g_lst_mon)
	var2  =short2flt(ctrl_in2->u(istrt:ilast,{850},:,:))			; p for unify the var name

    ctrl_file3   = g_data_path2
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile
	time_hist3    = ctrl_in3->time
    yyyymm3  = cd_calendar(time_hist3,-1)
    istrt   = ind(yyyymm3 .eq. g_strt_mon)
    ilast   = ind(yyyymm3 .eq. g_lst_mon)
	var3  =short2flt(ctrl_in3->v(istrt:ilast,{850},:,:))			; p for unify the var name

    ctrl_file4   = g_data_path3
	ctrl_in4     = addfile (ctrl_file4, "r")   ; note the "s" of addfile
	time_hist4    = ctrl_in4->time
    yyyymm4  = cd_calendar(time_hist4,-1)
    istrt   = ind(yyyymm4 .eq. g_strt_mon)
    ilast   = ind(yyyymm4 .eq. g_lst_mon)
	var4  =short2flt(ctrl_in4->w(istrt:ilast,{500},:,:))			; p for unify the var name


; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    dvar1bar_dt       = var1(0,:,:) ; dvar1dt of the annual mean of var1
    dvar2bar_dt       = var2(0,:,:) ; dvar1dt of the annual mean of var1
    dvar3bar_dt       = var3(0,:,:) ; dvar1dt of the annual mean of var1
    dvar4bar_dt       = var4(0,:,:) ; dvar1dt of the annual mean of var1
    cor_var1 = dvar1bar_dt
    cor_var2 = dvar2bar_dt
    cor_var3 = dvar3bar_dt
    cor_var4 = dvar4bar_dt
    
    var1bar = month_to_season(var1,g_season)
    var2bar = month_to_season(var2,g_season)
    var3bar = month_to_season(var3,g_season)
    var4bar = month_to_season(var4,g_season)
    
    ;var1bar=runave_Wrap(var1bar,3,0)
    ;var2bar=runave_Wrap(var2bar,3,0)
    ;var3bar=runave_Wrap(var3bar,3,0)
    var1bar!0 = "time"
    var2bar!0 = "time"
    var3bar!0 = "time"
    var4bar!0 = "time"
    dimz = dimsizes(var1bar)
    yr_length = dimz(0)
    dvar1bar_dt = (/regCoef(ispan(0,yr_length-1,1), var1bar(latitude|:,longitude|:,time|:))/)
    dvar2bar_dt = (/regCoef(ispan(0,yr_length-1,1), var2bar(latitude|:,longitude|:,time|:))/)
    dvar3bar_dt = (/regCoef(ispan(0,yr_length-1,1), var3bar(latitude|:,longitude|:,time|:))/)
    dvar4bar_dt = (/regCoef(ispan(0,yr_length-1,1), var4bar(latitude|:,longitude|:,time|:))/)
   

    ;For the significance test
    cor_var1 = escorc(ispan(0,yr_length-1,1),var1bar(latitude|:,longitude|:,time|:))
    prob_var1 = rtest(cor_var1,yr_length,0) 

    cor_var2 = escorc(ispan(0,yr_length-1,1),var2bar(latitude|:,longitude|:,time|:))
    prob_var2 = rtest(cor_var1,yr_length,0) 

    cor_var3 = escorc(ispan(0,yr_length-1,1),var3bar(latitude|:,longitude|:,time|:))
    prob_var3 = rtest(cor_var3,yr_length,0) 
    
    cor_var4 = escorc(ispan(0,yr_length-1,1),var4bar(latitude|:,longitude|:,time|:))
    prob_var4 = rtest(cor_var4,yr_length,0) 
    siglvl = 0.1            ;specified sig level
    
    cor_var1_sig = cor_var1
    cor_var1_sig= mask(cor_var1,prob_var1 .lt. siglvl,True)

    dvar3bar_dt_sig = dvar3bar_dt
    dvar2bar_dt_sig = dvar2bar_dt
	dvar3bar_dt_sig= (/mask(dvar3bar_dt,(prob_var3 .lt. siglvl) .or. (prob_var2 .lt. siglvl),True)/)
 

   
    dvar1bar_dt = yr_length*dvar1bar_dt
    
    dvar2bar_dt_sig = yr_length*dvar2bar_dt_sig
    dvar3bar_dt_sig = yr_length*dvar3bar_dt_sig
    dvar2bar_dt = yr_length*dvar2bar_dt
    dvar3bar_dt = yr_length*dvar3bar_dt
 
    dvar4bar_dt = yr_length*dvar4bar_dt

    dvar4bar_dt = where(prob_var4 .lt. siglvl,dvar4bar_dt,dvar4bar_dt@_FillValue)
    dvar4bar_dt = where(dvar4bar_dt .gt. 0.025,dvar4bar_dt,dvar4bar_dt@_FillValue)

    clim_var2bar = dim_avg_n_Wrap(var2bar,0)
    clim_var3bar = dim_avg_n_Wrap(var3bar,0)
    ;Get divUV
    div_var23 = uv2dv_cfd(clim_var2bar,clim_var3bar,dvar2bar_dt&latitude,dvar2bar_dt&longitude,1)
    div_var23_trend = uv2dv_cfd(clim_var2bar+dvar2bar_dt,clim_var3bar+dvar3bar_dt,dvar2bar_dt&latitude,dvar2bar_dt&longitude,1)
    ddiv_var23bar_dt = div_var23_trend-div_var23
    
    print(ddiv_var23bar_dt)
    dwind_speed = dvar2bar_dt
    dwind_speed = sqrt(dvar3bar_dt*dvar3bar_dt+dvar2bar_dt*dvar2bar_dt)
    
    ;Mask out small wind
    dvar3bar_dt_sig = where(dwind_speed .lt. 1.0, dvar3bar_dt_sig@_FillValue, dvar3bar_dt_sig) 


    printVarSummary(cor_var1_sig)
    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot_C = new((/2/),graphic)     ;contour
    plot_V = new((/1/),graphic)     ;vector
    plot_S = new((/1/),graphic)     ;shading
    plot_sig = new((/1/),graphic)   ;sig in shading

    ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;gsn_define_colormap(wks,"precip4_diff_19lev")
    ;gsn_define_colormap(wks,"precip_diff_12lev")
    ; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    ;gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
    ;gsn_define_colormap(wks,"GMT_jet")
    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")
    ;gsn_define_colormap(wks,"BlWhRe")
    gsn_define_colormap(wks,"MPL_bwr")


    ;-----------------------------------------------------------------------------
    res                  = True       ; use plot options

    res@cnFillOn             = True               ; turn on color for contours
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off contour line labels



    ;i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
    ;j = NhlNewColor(wks,1,0.,0.)
    ;  res@mpLandFillColor       = "gray"            ; set land to be gray

    ;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
    ;   res@cnLevels = ispan(0,60,10)
    ;  res@cnFillColors =(/-1,20,47,57,94,127,152/)

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        =  -250          ; set min contour level
    res@cnMaxLevelValF        =  250          ; set max contour level
    res@cnLevelSpacingF       =  25          ; set contour interval

    ;res@cnMinLevelValF        =  -0.15          ; set min contour level
    ;res@cnMaxLevelValF        =  0.15        ; set max contour level
    ;res@cnLevelSpacingF       =  0.025          ; set contour interval
    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

    res@gsnSpreadColors      = True               ; use full color map
    ;res@gsnSpreadColorStart  = 21                ; start at color 17
    ;res@gsnSpreadColorEnd    = 236                ; end at color 200

    ;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
    res@gsnRightString = ""
    res@gsnCenterString = g_fig_title
    res@gsnLeftString = g_fig_rank(1) 

   ; res@gsnMaximize      = True       ; fill up the page
    res@gsnAddCyclic   = False
   ; res@gsnPaperOrientation = "portrait"
   ; res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller
    res@lbLabelStride = 4 

    res@mpFillOn   = True;False     ; turn off gray continents
    res@mpGeophysicalLineThicknessF = 2 
    res@mpGeophysicalLineColor      = "black";"white" 
    ;res@mpFillDrawOrder="PostDraw"

    res@mpCenterLonF = 180.
    res@mpMaxLonF  = g_lonE
    res@mpMinLonF  = g_lonW

    res@mpMaxLatF  = g_latN
    res@mpMinLatF  = g_latS
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
    res@tmXBTickSpacingF = 30
    res@tmYLTickSpacingF = 15 
    ; res@tmXBLabelFontAspectF = 1.6
    res@tmXBLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontAspectF = 1.3
    res@tmYLLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontQuality =
   	res@tmXBMajorThicknessF = 3.0
	res@tmYLMajorThicknessF = 3.0
	res@tmXBMinorThicknessF = 3.0
	res@tmYLMinorThicknessF = 3.0
	res@tmBorderThicknessF = 3.0
   ;-----------------------------------------------------------------------------
     
    
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    res@gsnStringFontHeightF = g_font
;-------Set for the vector plot------
    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    vcres@vcRefAnnoOrthogonalPosF = -1             ; move ref vector up
    vcres@vcRefMagnitudeF         = 2.0             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.03
    vcres@vcRefAnnoString1  = "2 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.018
    vcres@vcLineArrowThicknessF     = 1.5    ;thickness of vector

  vcres@vcLineArrowHeadMinSizeF   = 0.015
  vcres@vcLineArrowHeadMaxSizeF   = 0.03
    ;----------Set res sig-----------
    res_sig                  = True       ; use plot options
    res_sig@cnFillOn         = True       ; Fill contours
    res_sig@cnLinesOn        = False;True      ; turn off contour lines
    res_sig@gsnFrame         = False
    res_sig@gsnDraw  = False
    res_sig@cnLineLabelsOn   = False      ; turn off contour line labels
    res_sig@cnLineThicknessF = 2
    ;res_sig@cnLineColor      = "black"
    res_sig@cnInfoLabelOn = False
    res_sig@cnMonoFillPattern    = True;False
    res_sig@cnFillPattern = 17
    res_sig@cnMonoFillScale = True
    res_sig@cnFillScaleF = 1.2
    res_sig@cnMonoFillColor = True
    res_sig@cnFillColor  =  "black"
    res_sig@cnFillDotSizeF = 0.0035

    res_sig@lbLabelBarOn = False;True   ; turn off the label bar

    ;  res_sig@cnLevelSelectionMode="ExplicitLevels"
    ;  res_sig@cnLevels = (/3000,1000/)
    res_sig@gsnLeftString      = " "
    res_sig@gsnRightString      = " "


  plot_V(0) = gsn_csm_vector(wks,dvar2bar_dt_sig(:,:),dvar3bar_dt_sig(:,:),vcres)

  plot_S(0) = gsn_csm_contour_map_ce(wks,dvar1bar_dt(:,:),res)
  
  plot_sig(0) = gsn_csm_contour(wks,cor_var1_sig,res_sig)

    res_sig@cnFillPattern = 6
    res_sig@cnFillScaleF = 1.2
    res_sig@cnMonoFillColor = True
    res_sig@cnFillColor  =  "Red"
    res_sig@cnFillDotSizeF = 0.0035


  plot_C(0) = gsn_csm_contour(wks,dvar4bar_dt,res_sig)
  
  
  overlay(plot_S(0),plot_sig(0))
  overlay(plot_S(0),plot_C(0))
  ;overlay(plot_S(0),plot_C(1))
  overlay(plot_S(0),plot_V(0))

 
  gsn_panel(wks,plot_S(0),(/1,1/),False)

  draw(plot_S)
  frame(wks)
end 
