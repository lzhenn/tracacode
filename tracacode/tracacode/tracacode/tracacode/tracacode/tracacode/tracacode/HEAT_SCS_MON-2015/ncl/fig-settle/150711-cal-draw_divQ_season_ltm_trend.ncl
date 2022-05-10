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
    g_data_path = "../data/obv/U-197901-201408.nc"
    g_data_path2 = "../data/obv/V-197901-201408.nc"
    g_data_path3 = "../data/obv/SH-197901-201408.nc"

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

        
    g_font = 0.035

    g_strt_mon = 197901 
    g_lst_mon = 201312
    g_fig_name    =   "../fig/obv/"+g_strt_mon+"-"+g_lst_mon+"_divQ_season_ltm_trend_"+g_season
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    
    g_fig_title     = g_season +(/" divQ Long-term Trend"," divQ DynT Long-term Trend"," divQ ThermoT Long-term Trend"/)
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
    print(clmdivQ({0},:))
    dvar1_dt          = divQ(0,:,:) ; dvar1dt of every indivadual season
    var1bar = month_to_season(divQ,g_season_rank(1))
    ;var1bar = (var1bar*10)/365.  ; for UDel datasets
    var1bar!0 = "time"
    dimz = dimsizes(var1bar)
    yr_length = dimz(0)
    printVarSummary(var1bar)
    dvar1_dt(:,:) = (/regCoef(ispan(0,yr_length-1,1), var1bar(latitude|:,longitude|:,time|:))/)
    dvar1_dt = yr_length*dvar1_dt
    
    ;For the significance test
    cor_var1 = escorc(ispan(0,yr_length-1,1),var1bar(latitude|:,longitude|:,time|:))
    prob_var1 = rtest(cor_var1,yr_length,0) 

    siglvl = 0.1            ;specified sig level
    
    cor_var1_sig = cor_var1
    cor_var1_sig= mask(cor_var1,prob_var1 .lt. siglvl,True)

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

    dconq_dt          = wgt_conq(0,:,:) ; dvar1dt of every indivadual season
    printVarSummary(wgt_conq)
    conq_bar = month_to_season(wgt_conq,g_season)
    ;var1bar = (var1bar*10)/365.  ; for UDel datasets
    conq_bar!0 = "time"
    dimz = dimsizes(conq_bar)
    yr_length = dimz(0)
    dconq_dt(:,:) = (/regCoef(ispan(0,yr_length-1,1), conq_bar(latitude|:,longitude|:,time|:))/)
    dconq_dt = -yr_length*dconq_dt
 
    dadvq_dt          = wgt_adv_q(0,:,:) ; dvar1dt of every indivadual season
    advq_bar = month_to_season(wgt_adv_q,g_season_rank(1))
    ;var1bar = (var1bar*10)/365.  ; for UDel datasets
    advq_bar!0 = "time"
    dimz = dimsizes(advq_bar)
    yr_length = dimz(0)
    dadvq_dt(:,:) = (/regCoef(ispan(0,yr_length-1,1), advq_bar(latitude|:,longitude|:,time|:))/)
    dadvq_dt = -yr_length*dadvq_dt
    
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/3/),graphic)
  plot_cn_pos = new((/1/),graphic)
  plot_cn_neg = new((/1/),graphic)
  plot_sig = new((/1/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


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
     
  res@gsnLeftString = ""
  res@gsnCenterString = g_fig_title(0)
  res@gsnRightString = ""
  plot_sh(0) = gsn_csm_contour_map_ce(wks,dvar1_dt(:,:),res) ; create a default plot
  res@gsnCenterString = g_fig_title(1)
  plot_sh(1) = gsn_csm_contour_map_ce(wks,dconq_dt(:,:),res) ; create a default plot
  res@gsnCenterString = g_fig_title(2)
  plot_sh(2) = gsn_csm_contour_map_ce(wks,dadvq_dt(:,:),res) ; create a default plot
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
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 4 
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/1.2/)
  res3@cnLineColor      = "Red"
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "


 ; plot_cn_pos(0) = gsn_csm_contour(wks,dvar2_dt(1,:,:),res3)

  res3@cnLevels = (/-1.2/)
  res3@cnLineColor      = "Blue"
  res3@cnLineDashPattern      = 1
  
 ; plot_cn_neg(0) = gsn_csm_contour(wks,dvar2_dt(1,:,:),res3)

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
resp@gsLineThicknessF = 6.0                       ; thickness of lines
;resp@gsLineLabelString= "test"                    ; adds a line label string

; create array of dummy graphic variables. This is required, b/c each line
; must be associated with a unique dummy variable.

dum = new(12,graphic)  

; draw each line separately. Each line must contain two points.
do i = 0 , 3
do j = 0, 2
    dum(3*i+j)=gsn_add_polyline(wks,plot_sh(j),xpts(i:i+1),ypts(i:i+1),resp)      
end do
end do 
;************************************************
; create points for box in southern China
;************************************************

resp@gsLineDashPattern      = 1                     ; color of lines
ypts = (/ 35.0,  35.0, 20.0,  20.0, 35.0/)
xpts = (/110.0, 135.0,135.0, 110.0,110.0/)

dum2 = new(12,graphic)  

; draw each line separately. Each line must contain two points.
do i = 0 , 3
do j = 0, 2
    dum2(3*i+j)=gsn_add_polyline(wks,plot_sh(j),xpts(i:i+1),ypts(i:i+1),resp)      
end do
end do 


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
  vcres@vcRefMagnitudeF         = 5.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.017
  vcres@vcRefAnnoString1  = "5 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.01
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
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
    res_sig@cnFillScaleF = 2.
    res_sig@cnMonoFillColor = True
    res_sig@cnFillColor  =  "red"
    res_sig@cnFillDotSizeF = 0.005

    res_sig@lbLabelBarOn = False;True   ; turn off the label bar

    ;  res_sig@cnLevelSelectionMode="ExplicitLevels"
    ;  res_sig@cnLevels = (/3000,1000/)
    res_sig@gsnLeftString      = " "
    res_sig@gsnRightString      = " "



;  vcres@vcLineArrowHeadMinSizeF   = 0.010
;  vcres@vcLineArrowHeadMaxSizeF   = 0.130
;--------------------------------------

  ;plot_V(0) = gsn_csm_vector(wks,diff_var1,diff_var2,vcres)

  ;plot_V(1) = gsn_csm_vector(wks,cp_diff_var1,cp_diff_var2,vcres)

;  plot_sh(0) = gsn_csm_contour(wks,diff_var3_sig,res4)

  ;plot_sig(0) = gsn_csm_contour(wks,cor_var1_sig,res_sig)

  ; overlay(plot_sh(0),plot_sig(0))
  ; overlay(plot_sh(0),plot_cn_neg(0))
  ;overlay(plot(1),plot_sh(1))

  ;overlay(plot(0),plot_V(0))
  ;overlay(plot(1),plot_V(1))

 
  gsn_panel(wks,plot_sh,(/3,1/),False)

  draw(plot_sh)
  frame(wks)
end 
