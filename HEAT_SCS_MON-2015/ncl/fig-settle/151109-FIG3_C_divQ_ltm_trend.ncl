;*************************************************************
;Aim: draw PRECC annually ltm trend 
;Mission:
;   1. Read data
;   2. Post-post process
;     2.1 take the trend 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-05-03
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN
;   2015-05-03  Change to caculate season trend 
;   2015-06-22  Change to fit 973 Report Fig1
;   2015-11-09  Change to fit GRL Fig.3c
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------PRECC
;================================================
;global variables
    ;Define parameters
    g_data_path = "../../data/obv/U-197901-201408.nc"
    g_data_path2 = "../../data/obv/V-197901-201408.nc"
    g_data_path3 = "../../data/obv/SH-197901-201408.nc"

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
    g_fig_name    =   "../../fig/scientific_reports/FIG3c_divQ-"+g_date
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
  
    g_fig_title     = (/"Integrated Moisture Flux Trend"," divQ DynT Long-term Trend"," divQ ThermoT Long-term Trend"/)
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
	var1  =short2flt(ctrl_in1->u(istrt:ilast,:,:,:))			; p for unify the var name

    ctrl_file2   = g_data_path2
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	time_hist2    = ctrl_in2->time
    yyyymm2  = cd_calendar(time_hist2,-1)
    istrt   = ind(yyyymm2 .eq. g_strt_mon)
    ilast   = ind(yyyymm2 .eq. g_lst_mon)
	var2  =short2flt(ctrl_in2->v(istrt:ilast,:,:,:))			; p for unify the var name

    ctrl_file3   = g_data_path3
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile
	time_hist3    = ctrl_in3->time
    yyyymm3  = cd_calendar(time_hist3,-1)
    istrt   = ind(yyyymm3 .eq. g_strt_mon)
    ilast   = ind(yyyymm3 .eq. g_lst_mon)
	var3  =short2flt(ctrl_in3->q(istrt:ilast,:,:,:))			; p for unify the var name

    print("Var Read Done!")
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    qu  = var3
    qv  = var3
    qu  = var1*var3
    qv  = var2*var3
    wgt_qu = qu(:,0,:,:)
    wgt_qv = qv(:,0,:,:)
    
    
    ;------Cal DivQ-------
    ;-----------Follow is the vertical integral-----------
    pver=qu&level
    pver=pver*100
    pver@units="Pa"
    dp=dpres_plevel(pver,100000,1,0)              ; caculate dp
    dp_cfm=conform_dims(dimsizes(qu),dp,1)        ; confirm dp to caculate sum(var*dp)
    wgt_qu=dim_sum_n(dp_cfm*qu,1)               ; sum(var*dp)

    wgt_qv=dim_sum_n(dp_cfm*qv,1)               ; sum(var*dp)
    
    wgt_qu = wgt_qu/9.8
    wgt_qv = wgt_qv/9.8
    delete([/qu,qv/])


    dQdx  = wgt_qu
    dQdy  = wgt_qv
    g_lon   =   wgt_qu&longitude
    g_lat   =   wgt_qu&latitude
    g_nlat  =   dimsizes(g_lat)
    ;dQdx
    dlon = (g_lon(2)-g_lon(1))*0.0174533 ; convert to radians
    
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        dQdx(:,i,:) = center_finite_diff_n (wgt_qu(:,i,:), dx , True,0,1) ; be careful with the dimison downscale
    end do

    ;dQdy
    dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    dQdy = center_finite_diff_n (wgt_qv, dy , False,0,1)
    
    divQ   =   dQdx ; copy metadata
    divQ   =   dQdx + dQdy
    divQ   =   -divQ*86400
    clmdivQ = dim_avg_n_Wrap(divQ,0) 
    print("Total divQ Done!")
    
    dvar1_dt          = divQ(0,:,:) ; dvar1dt of every indivadual season
    var1bar = month_to_season(divQ,g_season_rank(1))
    ;var1bar = (var1bar*10)/365.  ; for UDel datasets
    var1bar!0 = "time"
    dimz = dimsizes(var1bar)
    yr_length = dimz(0)
    dvar1_dt(:,:) = (/regCoef(ispan(0,yr_length-1,1), var1bar(latitude|:,longitude|:,time|:))/)
    dvar1_dt = yr_length*dvar1_dt
    print("Trend Total divQ Done!")

    ;For the significance test
    ;cor_var1 = escorc(ispan(0,yr_length-1,1),var1bar(latitude|:,longitude|:,time|:))
    ;prob_var1 = rtest(cor_var1,yr_length,0) 

    ;siglvl = 0.1            ;specified sig level
    
    ;cor_var1_sig = cor_var1
    ;cor_var1_sig= mask(cor_var1,prob_var1 .lt. siglvl,True)

    ;Convergence Term
    dudx = var1
    dvdy = var2
   
    ;dudx
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        dudx(:,:,i,:) = center_finite_diff_n (var1(:,:,i,:), dx , True,0,2) ; be careful with the dimison downscale
    end do

    ;dvdy
    dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    dvdy = center_finite_diff_n (var2, dy , False,0,2)
    
    conq = var3
    conq = var3*(dudx+dvdy)
    wgt_conq=conq(:,0,:,:)
    wgt_conq=dim_sum_n(dp_cfm*conq,1)               ; sum(var*dp)
    wgt_conq = 86400*wgt_conq/9.8

    delete([/dudx,dvdy,conq/])
    print("Convergence Term Done!")

    ;Advection Term
    dqdx = var3
    dqdy = var3
   
    ;dqdx
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        dqdx(:,:,i,:) = center_finite_diff_n (var3(:,:,i,:), dx , True,0,2) ; be careful with the dimison downscale
    end do

    ;dqdy
    dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    dqdy = center_finite_diff_n (var3, dy , False,0,2)

    adv_q = var3
    adv_q = var1*dqdx+var2*dqdy

    wgt_adv_q=adv_q(:,0,:,:)
    wgt_adv_q=dim_sum_n(dp_cfm*adv_q,1)               ; sum(var*dp)
    wgt_adv_q = 86400*wgt_adv_q/9.8
    print("Advection Term Done!")

    dconq_dt          = wgt_conq(0,:,:) ; dvar1dt of every indivadual season
    conq_bar = month_to_season(wgt_conq,g_season)
    conq_bar!0 = "time"
    dimz = dimsizes(conq_bar)
    yr_length = dimz(0)
    dconq_dt(:,:) = (/regCoef(ispan(0,yr_length-1,1), conq_bar(latitude|:,longitude|:,time|:))/)
    dconq_dt = -yr_length*dconq_dt
    print("Trend Convergence Term Done!")

    dadvq_dt          = wgt_adv_q(0,:,:) ; dvar1dt of every indivadual season
    advq_bar = month_to_season(wgt_adv_q,g_season_rank(1))
    ;var1bar = (var1bar*10)/365.  ; for UDel datasets
    advq_bar!0 = "time"
    dimz = dimsizes(advq_bar)
    yr_length = dimz(0)
    dadvq_dt(:,:) = (/regCoef(ispan(0,yr_length-1,1), advq_bar(latitude|:,longitude|:,time|:))/)
    dadvq_dt = -yr_length*dadvq_dt
    print("Trend Advection Term Done!")

    delete([/conq_bar,advq_bar,wgt_conq/])

    ;Caculate Relative Contribution
    contrib_conq = dconq_dt
    contrib_adv = dadvq_dt
    contrib_conq = where(abs(dvar1_dt) .lt. 1.0, contrib_conq@_FillValue, contrib_conq)
    contrib_adv = where(abs(dvar1_dt) .lt. 1.0, contrib_adv@_FillValue, contrib_adv)
    contrib_conq = contrib_conq / dvar1_dt
    contrib_adv = contrib_adv / dvar1_dt
    
    contrib_conq_pos = contrib_conq
    contrib_adv_pos = contrib_adv

    contrib_conq_pos = where(contrib_conq .lt. 0.5, contrib_conq@_FillValue, contrib_conq)
    contrib_adv_pos = where(contrib_adv .lt. 0.6, contrib_adv@_FillValue, contrib_adv)

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/1/),graphic)
  plot_cn_conv_pos = new((/1/),graphic)
  plot_cn_conv_neg = new((/1/),graphic)
  plot_cn_adv_pos = new((/1/),graphic)
  plot_cn_adv_neg = new((/1/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
; gsn_define_colormap(wks,"MPL_BrBG")
 gsn_define_colormap(wks,"MPL_RdBu")


;-----------------------------------------------------------------------------
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
 res@cnMinLevelValF        = -5         ; set min contour level
 res@cnMaxLevelValF        = 5          ; set max contour level
 res@cnLevelSpacingF       = 0.5          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
; res@gsnSpreadColorEnd    = 14                ; end at color 200

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
     
  res@gsnLeftString = "(c)"
  res@gsnCenterString = g_fig_title(0)
  res@gsnRightString = ""
  plot_sh(0) = gsn_csm_contour_map_ce(wks,dvar1_dt(:,:),res) ; create a default plot
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
    res_sig@cnFillPattern = 5
    res_sig@cnMonoFillScale = True
    res_sig@cnFillScaleF = 1.2
    res_sig@cnMonoFillColor = True
    res_sig@cnFillColor  =  "darkgreen"
    res_sig@cnFillDotSizeF = 0.0035
    res_sig@lbLabelBarOn = False;True   ; turn off the label bar

    ;  res_sig@cnLevelSelectionMode="ExplicitLevels"
    ;  res_sig@cnLevels = (/3000,1000/)
    res_sig@gsnLeftString      = " "
    res_sig@gsnRightString      = " "

    plot_cn_conv_pos(0) = gsn_csm_contour(wks,contrib_conq_pos,res_sig)
    
    res_sig@cnFillPattern = 17
    res_sig@cnFillColor  =  "black"
    plot_cn_adv_pos(0) =  gsn_csm_contour(wks,contrib_adv_pos,res_sig)


   overlay(plot_sh(0),plot_cn_conv_pos(0))
   overlay(plot_sh(0),plot_cn_adv_pos(0))
  gsn_panel(wks,plot_sh,(/1,1/),False)

  draw(plot_sh)
  frame(wks)
end 
