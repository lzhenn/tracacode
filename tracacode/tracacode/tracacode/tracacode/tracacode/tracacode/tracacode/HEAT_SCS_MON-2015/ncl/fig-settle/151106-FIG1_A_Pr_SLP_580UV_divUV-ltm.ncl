;*************************************************************
;Aim: draw FIG1 (a) for Scientific Reports 
;Mission:
;   1. Read data
;       Pr (GPCP+CMAP) 
;       850UV
;       SLP
;   2. Post-post process
;     2.1 calculate the divergence
;     2.2 take the trend 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-11-06
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN
;   2015-05-03  Change to caculate season trend 
;   2015-06-22  Change to fit 973 Report Fig1
;   2015-11-06  Change to fit Scientific Reports
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------CMAP PRECC
;	var2--------------GPCP PRECC
;	var3--------------ERA U
;	var4--------------ERA V
;	var5--------------ERA MSL
;================================================
;global variables
    ;Define parameters
    g_data_path = "../../data/obv/CMAP_precip.mon.mean.nc"
    g_data_path2 = "../../data/obv/GPCP_precip.mon.mean.nc"
    g_data_path3 = "../../data/obv/U-197901-201408.nc"
    g_data_path4 = "../../data/obv/V-197901-201408.nc"
    g_data_path5 = "../../data/obv/MSL-197901-201503.nc"


    ;g_latS=-30.
    ;g_latN=60.
    ;g_lonW=30.
    ;g_lonE=180.

    g_latS=-5.
    g_latN=45.
    g_lonW=90.
    g_lonE=160.
    g_season="MAM"
    g_season_rank=(/"DJF","MAM","JJA","SON"/)
; create an array of desired pressure levels:

        
    g_font = 0.03

    g_strt_mon = 197901 
    g_lst_mon = 201312
    g_date =systemfunc("date '+%Y%m%d'")
    g_fig_name    =   "../../fig/scientific_reports/FIG1a_MAM_Pr-"+g_date
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    
    g_fig_title1     = "Pr Trend"
    g_fig_title2     = "850UV+Div & SLP Trend"
   ;g_fig_title1   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr trend"  ;for dsstdt
   ;g_fig_title2   =   (/"Mar","Apr","May","Jun","Jul","Aug","Sep"/)+" Pr' trend" ;for dsst'dt


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	var1  =ctrl_in1->precip(istrt:ilast,:,:)			; p for unify the var name

    ctrl_file2   = g_data_path2
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	time_hist2    = ctrl_in2->time
    yyyymm2  = cd_calendar(time_hist2,-1)
    istrt   = ind(yyyymm2 .eq. g_strt_mon)
    ilast   = ind(yyyymm2 .eq. g_lst_mon)
	var2  =ctrl_in2->precip(istrt:ilast,:,:)			; p for unify the var name
    
    ctrl_file3   = g_data_path3
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile
	time_hist3    = ctrl_in3->time
    yyyymm3  = cd_calendar(time_hist3,-1)
    istrt   = ind(yyyymm3 .eq. g_strt_mon)
    ilast   = ind(yyyymm3 .eq. g_lst_mon)
	var3  =short2flt(ctrl_in3->u(istrt:ilast,{850},:,:))			; p for unify the var name

    ctrl_file4   = g_data_path4
	ctrl_in4     = addfile (ctrl_file4, "r")   ; note the "s" of addfile
	time_hist4    = ctrl_in4->time
    yyyymm4  = cd_calendar(time_hist4,-1)
    istrt   = ind(yyyymm4 .eq. g_strt_mon)
    ilast   = ind(yyyymm4 .eq. g_lst_mon)
	var4  =short2flt(ctrl_in4->v(istrt:ilast,{850},:,:))			; p for unify the var name

    ctrl_file5   = g_data_path5
	ctrl_in5     = addfile (ctrl_file5, "r")   ; note the "s" of addfile
	time_hist5   = ctrl_in5->time
    yyyymm5  = cd_calendar(time_hist5,-1)
    istrt   = ind(yyyymm5 .eq. g_strt_mon)
    ilast   = ind(yyyymm5 .eq. g_lst_mon)
	var5  =short2flt(ctrl_in5->msl(istrt:ilast,:,:))			; p for unify the var name


; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
;    dvar1_dt          = var1(0:3,:,:) ; dvar1dt of every indivadual season
;    dvar2_dt          = var2(0:3,:,:) ; dvar1dt of every indivadual season
;    do i = 0,3
;        var1bar = month_to_season(var1,g_season_rank(i))
;        ;var1bar = (var1bar*10)/365.  ; for UDel datasets
;        var1bar!0 = "time"
;        dimz = dimsizes(var1bar)
;        yr_length = dimz(0)
;        printVarSummary(var1bar)
;        dvar1_dt(i,:,:) = (/regCoef(ispan(0,yr_length-1,1), var1bar(lat|:,lon|:,time|:))/)
;        
;        var2bar = month_to_season(var2,g_season_rank(i))
;        ;var1bar = (var1bar*10)/365.  ; for UDel datasets
;        var2bar!0 = "time"
;        dimz2 = dimsizes(var2bar)
;        yr_length2 = dimz2(0)
;        printVarSummary(var2bar)
;        dvar2_dt(i,:,:) = (/regCoef(ispan(0,yr_length2-1,1), var2bar(lat|:,lon|:,time|:))/)
;    end do
;    dvar1_dt = yr_length*dvar1_dt
;    dvar2_dt = yr_length*dvar2_dt
;
    
    dvar2bar_dt       = var2(0,:,:) ; dvar1dt of the annual mean of var1
    dvar3bar_dt       = var3(0,:,:) ; dvar1dt of the annual mean of var1
    dvar4bar_dt       = var4(0,:,:) ; dvar1dt of the annual mean of var1
    dvar5bar_dt       = var5(0,:,:) ; dvar1dt of the annual mean of var1
    
    cor_var2 = dvar2bar_dt
    cor_var3 = dvar3bar_dt
    cor_var4 = dvar4bar_dt
    cor_var5 = dvar5bar_dt
    
    var2bar = month_to_season(var2,g_season)
    var3bar = month_to_season(var3,g_season)
    var4bar = month_to_season(var4,g_season)
    var5bar = month_to_season(var5,g_season)
   
    var2bar!0 = "time"
    var3bar!0 = "time"
    var4bar!0 = "time"
    var5bar!0 = "time"

    dimz = dimsizes(var3bar)
    yr_length = dimz(0)
    dvar2bar_dt = (/regCoef(ispan(0,yr_length-1,1), var2bar(lat|:,lon|:,time|:))/)
    dvar3bar_dt = (/regCoef(ispan(0,yr_length-1,1), var3bar(latitude|:,longitude|:,time|:))/)
    dvar4bar_dt = (/regCoef(ispan(0,yr_length-1,1), var4bar(latitude|:,longitude|:,time|:))/)
    dvar5bar_dt = (/regCoef(ispan(0,yr_length-1,1), var5bar(latitude|:,longitude|:,time|:))/)

    ;For the significance test

    cor_var2 = escorc(ispan(0,yr_length-1,1),var2bar(lat|:,lon|:,time|:))
    prob_var2 = rtest(cor_var2,yr_length,0) 
    
    cor_var3 = escorc(ispan(0,yr_length-1,1),var3bar(latitude|:,longitude|:,time|:))
    prob_var3 = rtest(cor_var3,yr_length,0) 

    cor_var4 = escorc(ispan(0,yr_length-1,1),var4bar(latitude|:,longitude|:,time|:))
    prob_var4 = rtest(cor_var4,yr_length,0) 
    
    cor_var5 = escorc(ispan(0,yr_length-1,1),var4bar(latitude|:,longitude|:,time|:))
    prob_var5 = rtest(cor_var5,yr_length,0) 
    
    siglvl = 0.15            ;specified sig level
    
    dvar2bar_dt_sig = dvar2bar_dt
    dvar3bar_dt_sig = dvar3bar_dt
    dvar4bar_dt_sig = dvar4bar_dt
    dvar5bar_dt_sig = dvar5bar_dt
 
    dvar2bar_dt_sig= mask(dvar2bar_dt,prob_var2 .lt. siglvl,True)
    dvar5bar_dt_sig= mask(cor_var5,prob_var5 .lt. siglvl,True)
	dvar3bar_dt_sig= (/mask(dvar3bar_dt,(prob_var3 .lt. siglvl) .or. (prob_var4 .lt. siglvl),True)/)
 

    dvar2bar_dt_sig = yr_length*dvar2bar_dt_sig
    dvar3bar_dt_sig = yr_length*dvar3bar_dt_sig
    dvar4bar_dt_sig = yr_length*dvar4bar_dt_sig
    dvar5bar_dt_sig = yr_length*dvar5bar_dt_sig

    dvar3bar_dt = yr_length*dvar3bar_dt
    dvar2bar_dt = yr_length*dvar2bar_dt
    dvar4bar_dt = yr_length*dvar4bar_dt
    dvar5bar_dt = yr_length*dvar5bar_dt

    ; For area where MAM Pr/ANN Pr >0.3 and Pr rate > 3mm/day
    clim_var2_annual = dim_avg_n_Wrap(var2,0)
    clim_var2_season = dim_avg_n_Wrap(var2bar,0)
    
    clim_var2_season_ratio = clim_var2_season
    clim_var2_season_ratio = clim_var2_season*92.0/(clim_var2_annual*365.25)
    print(clim_var2_season_ratio)
    clim_var2_season@_FillValue = -999.0
    clim_var2_season_ratio({g_latS:g_latS+15},:) = 0.0
    ;clim_var2_season_ratio = where(clim_var2_season .gt. 2.0,clim_var2_season_ratio,clim_var2_season_ratio@_FillValue)


; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh_pr = new((/1/),graphic)     ; GPCP Shading
  plot_cn_pr = new((/1/),graphic)     ; GPCP 0.3 3mm/day line
  plot_sh_pr_sig = new((/1/),graphic) ; GPCP Sig test
;  plot_cn_pos = new((/1/),graphic)
;  plot_cn_neg = new((/1/),graphic)
;  plot_sh = new((/2/),graphic)
  plot_V = new((/1/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



 ; i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
 ; j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -2.5         ; set min contour level
 res@cnMaxLevelValF        = 2.5          ; set max contour level
 res@cnLevelSpacingF       = 0.25          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  res@lbLabelStride = 4 

  res@mpFillOn   = False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  ;res@mpFillDrawOrder="PostDraw"
  res@mpCenterLonF = 180.
  res@mpMaxLatF  = g_latN
  res@mpMinLatF  = g_latS
  res@mpMaxLonF  = g_lonE
  res@mpMinLonF  = g_lonW

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
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
     
  res@gsnLeftString = g_fig_rank(0)
  res@gsnCenterString = g_fig_title1
  res@gsnRightString = ""
  plot_sh_pr(0) = gsn_csm_contour_map_ce(wks,dvar2bar_dt,res) ; create a default plot
;do i = 0,3
;    res@gsnLeftString = g_fig_rank(i)
;    res@gsnCenterString = g_fig_title(i)
;    res@gsnRightString = ""
;    plot(i) = gsn_csm_contour_map_ce(wks,dvar1_dt(i,:,:),res) ; create a default plot
;end do


;-------------------------------------------------------------------
  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  ;res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineLabelFontHeightF = 0.02
  res3@cnLineThicknessF = 2 
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/0.25,0.3,0.35/)
  res3@cnLineColor      = "Blue"
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "


  plot_cn_pr(0) = gsn_csm_contour(wks,clim_var2_season_ratio,res3)

;************************************************
; create points for box in SCS and WNP
;************************************************
ypts = (/ 15.0,  15.0, -0.0,  -0.0, 15.0/)
xpts = (/110.0, 155.0,155.0, 110.0,110.0/)
;************************************************
; add the box
;************************************************
resp                  = True                      ; polyline mods desired
resp@gsLineColor      = "Black"                     ; color of lines
resp@gsLineThicknessF = 2.0                       ; thickness of lines
;resp@gsLineLabelString= "test"                    ; adds a line label string

; create array of dummy graphic variables. This is required, b/c each line
; must be associated with a unique dummy variable.

dum = new(4,graphic)  

; draw each line separately. Each line must contain two points.
do ii = 0 , 3
    dum(ii)=gsn_add_polyline(wks,plot_sh_pr,xpts(ii:ii+1),ypts(ii:ii+1),resp)      
end do 
;************************************************
; create points for box in southern China
;************************************************

resp@gsLineDashPattern      = 1                     ; color of lines
ypts = (/ 35.0,  35.0, 20.0,  20.0, 35.0/)
xpts = (/110.0, 135.0,135.0, 110.0,110.0/)

dum2 = new(4,graphic)  

; draw each line separately. Each line must contain two points.
do ii = 0 , 3
    dum2(ii)=gsn_add_polyline(wks,plot_sh_pr,xpts(ii:ii+1),ypts(ii:ii+1),resp)      
end do 


;-------------------------------------------------
;-----------------------------------------------------
  res4                  = True       ; use plot options
  res4@cnFillOn         = True       ; Fill contours
  res4@cnLinesOn        = False;True      ; turn off contour lines
  res4@gsnFrame         = False
  res4@gsnDraw  = False
  res4@cnLineLabelsOn   = False      ; turn off contour line labels
;  res4@cnLineThicknessF = 2
;  res4@cnLineColor      = "black"
  res4@cnInfoLabelOn = False
  res4@cnMonoFillPattern    = True;False
  res4@cnFillPattern = 17
  res4@cnMonoFillScale = True
  res4@cnFillScaleF = 1.2
  res4@cnMonoFillColor = True
  res4@cnFillColor  =  "red"
  res4@cnFillDotSizeF = 0.0035
 
  res4@lbLabelBarOn = False;True   ; turn off the label bar
 
;  res4@cnLevelSelectionMode="ExplicitLevels"
;  res4@cnLevels = (/3000,1000/)
  res4@gsnLeftString      = " "
  res4@gsnRightString      = " "

  plot_sh_pr_sig = gsn_csm_contour(wks,dvar2bar_dt_sig,res4)
 


;-----------------------------------------------------------------------------
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
    vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.025
    vcres@vcRefAnnoString1  = "2 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.018
    vcres@vcLineArrowThicknessF     = 3.0    ;thickness of vector

   vcres@vcLineArrowHeadMinSizeF   = 0.010
   vcres@vcLineArrowHeadMaxSizeF   = 0.010
;--------------------------------------

;  plot_V(0) = gsn_csm_vector(wks,dvar3bar_dt_sig,dvar4bar_dt_sig,vcres)

  ;plot_V(1) = gsn_csm_vector(wks,cp_diff_var1,cp_diff_var2,vcres)

;  plot_sh(0) = gsn_csm_contour(wks,diff_var3_sig,res4)

  ;plot_sh(1) = gsn_csm_contour(wks,cp_diff_var3_sig,res4)

   overlay(plot_sh_pr(0),plot_cn_pr(0))
   overlay(plot_sh_pr(0),plot_sh_pr_sig(0))
;   overlay(plot_sh(0),plot_cn_neg(0))
;   overlay(plot_sh(0),plot_V(0))
;  ;overlay(plot(1),plot_sh(1))

  ;overlay(plot(0),plot_V(0))
  ;overlay(plot(1),plot_V(1))

 
  gsn_panel(wks,plot_sh_pr,(/1,1/),False)

  draw(plot_sh_pr)
  frame(wks)
end 
