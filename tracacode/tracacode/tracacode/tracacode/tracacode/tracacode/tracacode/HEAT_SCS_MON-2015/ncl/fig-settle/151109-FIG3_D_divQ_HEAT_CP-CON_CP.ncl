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
;   2015-11-09  Change to fit GRL Fig.3d
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    g_res  = "f19"
    ;Define parameters
    g_data_path = "../../data/model/pro/"
    g_ctrl_case = "B2000_f19g16_CP_CTRL"
    g_sen_cases = (/"HEAT_SCS_MAM-2015"/)


    g_season      =   "MAM"
    g_latS=-5.
    g_latN=45.
    g_lonW=90.
    g_lonE=160.
; create an array of desired pressure levels:

    g_year_start   =   10 ;Rank from 0
    g_year_end     =   49;Rank from 0 
    g_nsmp        =   g_year_end - g_year_start + 1;number of samples for significance test
    g_idx_start = g_year_start*12
    g_idx_end = (g_year_end+1)*12-1

    g_run_period  =   "250-349"
        
    g_font = 0.03
    g_var         = (/"U","V","Q"/)

    g_date =systemfunc("date '+%Y%m%d'")
    g_fig_name    =   "../../fig/scientific_reports/FIG4d_diff_divQ-"+g_date

    ;g_fig_rank    =   "B2000_F19G16_CAM4_CTRL"
    g_fig_rank    =   "(d)"
    ;g_fig_title   =   g_season+" HEAT_CP-CON_CP"
    g_fig_title   =    " CESM Integrated Moisture Flux Diff"


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================
    ctrl_file1   = g_data_path+g_ctrl_case+"/"+g_ctrl_case+".cam.h0.U."+g_run_period+".nc"
    ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    ctrl_var1  = ctrl_in1->U(g_idx_start:g_idx_end,:,:,:)			; p for unify the var name
    print("ctrl_var1 done!") 
    ctrl_file1   = g_data_path+g_ctrl_case+"/"+g_ctrl_case+".cam.h0.V."+g_run_period+".nc"
    ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    ctrl_var2  = ctrl_in1->V(g_idx_start:g_idx_end,:,:,:)			; p for unify the var name
    
    print("ctrl_var2 done!") 
    ctrl_file1   = g_data_path+g_ctrl_case+"/"+g_ctrl_case+".cam.h0.Q."+g_run_period+".nc"
    ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    ctrl_var3  = ctrl_in1->Q(g_idx_start:g_idx_end,:,:,:)			; p for unify the var name

    print("ctrl_var3 done!") 
;*************************For F_Compset Heat***********************************

;  Mission 1. Open the file: Read only the user specified period
; ==============================================================
    exp_file1   = g_data_path+g_sen_cases(0)+"/"+g_sen_cases(0)+".cam.h0.U."+g_run_period+".nc"
    exp_in1     = addfile (exp_file1, "r")   ; note the "s" of addfile
    exp_var1  = exp_in1->U(g_idx_start:g_idx_end,:,:,:)			; p for unify the var name
    
    print("exp_var1 done!") 
    exp_file1   = g_data_path+g_sen_cases(0)+"/"+g_sen_cases(0)+".cam.h0.V."+g_run_period+".nc"
    exp_in1     = addfile (exp_file1, "r")   ; note the "s" of addfile
    exp_var2  = exp_in1->V(g_idx_start:g_idx_end,:,:,:)			; p for unify the var name
    
    print("exp_var2 done!") 
    exp_file1   = g_data_path+g_sen_cases(0)+"/"+g_sen_cases(0)+".cam.h0.Q."+g_run_period+".nc"
    exp_in1     = addfile (exp_file1, "r")   ; note the "s" of addfile
    exp_var3  = exp_in1->Q(g_idx_start:g_idx_end,:,:,:)			; p for unify the var name
    
    print("exp_var3 done!") 


    ;Amplify to fit the plot
    ctrl_var1 = ctrl_var1*1.25
    ctrl_var2 = ctrl_var2*1.25
    ctrl_var3 = ctrl_var3*1.25
    
    exp_var1 = exp_var1*1.25
    exp_var2 = exp_var2*1.25
    exp_var3 = exp_var3*1.25
    
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    ctrl_qu  = ctrl_var3
    ctrl_qv  = ctrl_var3
    ctrl_qu  = ctrl_var1*ctrl_var3
    ctrl_qv  = ctrl_var2*ctrl_var3
    ctrl_wgt_qu = ctrl_qu(:,0,:,:)
    ctrl_wgt_qv = ctrl_qv(:,0,:,:)
    
    
    ;------Cal DivQ-------
    ;-----------Follow is the vertical integral-----------
    pver=ctrl_qu&lev_p
    pver=pver*100
    pver@units="Pa"
    dp=dpres_plevel(pver,100000,5000,0)              ; caculate dp
    dp_cfm=conform_dims(dimsizes(ctrl_qu),dp,1)        ; confirm dp to caculate sum(var*dp)
    ctrl_wgt_qu=dim_sum_n(dp_cfm*ctrl_qu,1)               ; sum(var*dp)
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    ctrl_qu  = ctrl_var3
    ctrl_qv  = ctrl_var3
    ctrl_qu  = ctrl_var1*ctrl_var3
    ctrl_qv  = ctrl_var2*ctrl_var3
    ctrl_wgt_qu = ctrl_qu(:,0,:,:)
    ctrl_wgt_qv = ctrl_qv(:,0,:,:)
    
    
    ;------Cal DivQ-------
    ;-----------Follow is the vertical integral-----------
    pver=ctrl_qu&lev_p
    pver=pver*100
    pver@units="Pa"
    dp=dpres_plevel(pver,100000,5000,0)              ; caculate dp
    dp_cfm=conform_dims(dimsizes(ctrl_qu),dp,1)        ; confirm dp to caculate sum(var*dp)
    ctrl_wgt_qu=dim_sum_n(dp_cfm*ctrl_qu,1)               ; sum(var*dp)

    ctrl_wgt_qv=dim_sum_n(dp_cfm*ctrl_qv,1)               ; sum(var*dp)
    
    ctrl_wgt_qu = ctrl_wgt_qu/9.8
    ctrl_wgt_qv = ctrl_wgt_qv/9.8
    
    ctrl_dQdx_flt  = ctrl_wgt_qu
    ctrl_dQdx   = flt2dble(ctrl_dQdx_flt)
    ctrl_dQdy_flt  = ctrl_wgt_qv
    ctrl_dQdy   = flt2dble(ctrl_dQdy_flt)
    g_lon   =   ctrl_wgt_qu&lon
    g_lat   =   ctrl_wgt_qu&lat
    g_nlat  =   dimsizes(g_lat)

    delete([/ctrl_qu,ctrl_qv/])
    
    ;dQdx
    dlon = (g_lon(2)-g_lon(1))*0.0174533 ; convert to radians
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        ctrl_dQdx(:,i,:) = center_finite_diff_n (ctrl_wgt_qu(:,i,:), dx , True,0,1) ; be careful with the dimison downscale
        ;test = center_finite_diff_n (ctrl_wgt_qu(:,i,:), dx , True,0,1) ; be careful with the dimison downscale
    end do

    ;dQdy
    dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    ctrl_dQdy = center_finite_diff_n (ctrl_wgt_qv, dy , False,0,1)
    
    ctrl_divQ   =   ctrl_dQdx ; copy metadata
    ctrl_divQ   =   ctrl_dQdx + ctrl_dQdy
    ctrl_divQ   =   -ctrl_divQ*86400
    ctrl_dvar1_dt          = ctrl_divQ(0,:,:) ; dvar1dt of every indivadual season
    ctrl_divQbar = month_to_season(ctrl_divQ,g_season)
   
    ;Convergence Term
    ctrl_dudx_flt = ctrl_var1
    ctrl_dvdy_flt = ctrl_var2
    ctrl_dudx = flt2dble(ctrl_dudx_flt)
    ctrl_dvdy = flt2dble(ctrl_dvdy_flt)
    ;dudx
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        ctrl_dudx(:,:,i,:) = center_finite_diff_n (ctrl_var1(:,:,i,:), dx , True,0,2) ; be careful with the dimison downscale
    end do

    ;dvdy
    dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    ctrl_dvdy = center_finite_diff_n (ctrl_var2, dy , False,0,2)
    
    ctrl_conq_flt = ctrl_var3
    ctrl_conq = flt2dble(ctrl_conq_flt)
    ctrl_conq = ctrl_var3*(ctrl_dudx+ctrl_dvdy)
    ctrl_wgt_conq=ctrl_conq(:,0,:,:)
    ctrl_wgt_conq=dim_sum_n(dp_cfm*ctrl_conq,1)               ; sum(var*dp)
    ctrl_wgt_conq = 86400*ctrl_wgt_conq/9.8

    ctrl_wgt_conqbar = month_to_season(ctrl_wgt_conq,g_season)

    ;Advection Term
    ctrl_dqdx_flt = ctrl_var3
    ctrl_dqdy_flt = ctrl_var3
    ctrl_dqdx = flt2dble(ctrl_dqdx_flt)
    ctrl_dqdy = flt2dble(ctrl_dqdy_flt)
    ;dqdx
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        ctrl_dqdx(:,:,i,:) = center_finite_diff_n (ctrl_var3(:,:,i,:), dx , True,0,2) ; be careful with the dimison downscale
    end do

    ;dqdy
    ctrl_dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    ctrl_dqdy = center_finite_diff_n (ctrl_var3, dy , False,0,2)

    ctrl_adv_q_flt = ctrl_var3
    ctrl_adv_q = flt2dble(ctrl_adv_q_flt)
    ctrl_adv_q = ctrl_var1*ctrl_dqdx+ctrl_var2*ctrl_dqdy

    ctrl_wgt_adv_q=ctrl_adv_q(:,0,:,:)
    ctrl_wgt_adv_q=dim_sum_n(dp_cfm*ctrl_adv_q,1)               ; sum(var*dp)
    ctrl_wgt_adv_q = 86400*ctrl_wgt_adv_q/9.8
       
    ctrl_wgt_adv_qbar = month_to_season(ctrl_wgt_adv_q,g_season)

    print("CTRL process done")

    exp_qu  = exp_var3
    exp_qv  = exp_var3
    exp_qu  = exp_var1*exp_var3
    exp_qv  = exp_var2*exp_var3
    exp_wgt_qu = exp_qu(:,0,:,:)
    exp_wgt_qv = exp_qv(:,0,:,:)
    
    
    ;------Cal DivQ-------
    ;-----------Follow is the vertical integral-----------
    pver=exp_qu&lev_p
    pver=pver*100
    pver@units="Pa"
    dp=dpres_plevel(pver,100000,1,0)              ; caculate dp
    dp_cfm=conform_dims(dimsizes(exp_qu),dp,1)        ; confirm dp to caculate sum(var*dp)
    exp_wgt_qu=dim_sum_n(dp_cfm*exp_qu,1)               ; sum(var*dp)

    exp_wgt_qv=dim_sum_n(dp_cfm*exp_qv,1)               ; sum(var*dp)
    
    exp_wgt_qu = exp_wgt_qu/9.8
    exp_wgt_qv = exp_wgt_qv/9.8
    
    exp_dQdx_flt  = exp_wgt_qu
    exp_dQdy_flt  = exp_wgt_qv
    exp_dQdx = flt2dble(exp_dQdx_flt)
    exp_dQdy = flt2dble(exp_dQdy_flt)
    g_lon   =   exp_wgt_qu&lon
    g_lat   =   exp_wgt_qu&lat
    g_nlat  =   dimsizes(g_lat)
    ;dQdx
    dlon = (g_lon(2)-g_lon(1))*0.0174533 ; convert to radians
    
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        exp_dQdx(:,i,:) = center_finite_diff_n (exp_wgt_qu(:,i,:), dx , True,0,1) ; be careful with the dimison downscale
    end do

    ;dQdy
    dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    exp_dQdy = center_finite_diff_n (exp_wgt_qv, dy , False,0,1)
    
    exp_divQ   =   exp_dQdx ; copy metadata
    exp_divQ   =   exp_dQdx + exp_dQdy
    exp_divQ   =   -exp_divQ*86400
    exp_dvar1_dt          = exp_divQ(0,:,:) ; dvar1dt of every indivadual season
    exp_divQbar = month_to_season(exp_divQ,g_season)
   
    ;Convergence Term
    exp_dudx_flt = exp_var1
    exp_dvdy_flt = exp_var2
   
    exp_dudx = flt2dble(exp_dudx_flt)
    exp_dvdy = flt2dble(exp_dvdy_flt)
    ;dudx
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        exp_dudx(:,:,i,:) = center_finite_diff_n (exp_var1(:,:,i,:), dx , True,0,2) ; be careful with the dimison downscale
    end do

    ;dvdy
    dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    exp_dvdy = center_finite_diff_n (exp_var2, dy , False,0,2)
    
    exp_conq_flt = exp_var3
    exp_conq  = flt2dble(exp_conq_flt)
    exp_conq = exp_var3*(exp_dudx+exp_dvdy)
    exp_wgt_conq=exp_conq(:,0,:,:)
    exp_wgt_conq=dim_sum_n(dp_cfm*exp_conq,1)               ; sum(var*dp)
    exp_wgt_conq = 86400*exp_wgt_conq/9.8

    exp_wgt_conqbar = month_to_season(exp_wgt_conq,g_season)

    ;Advection Term
    exp_dqdx_flt = exp_var3
    exp_dqdy_flt = exp_var3
   
    exp_dqdx = flt2dble(exp_dqdx_flt)
    exp_dqdy = flt2dble(exp_dqdy_flt)
    ;dqdx
    do i=0,g_nlat-1                      ; loop over each latitude
        dx = 6378388.*cos(0.0174533*g_lat(i))*dlon  ; constant at this latitude
        exp_dqdx(:,:,i,:) = center_finite_diff_n (exp_var3(:,:,i,:), dx , True,0,2) ; be careful with the dimison downscale
    end do

    ;dqdy
    exp_dlat = (g_lat(2)-g_lat(1))*0.0174533 ; convert to radians
    dy   = 6378388.*dlat   
    exp_dqdy = center_finite_diff_n (exp_var3, dy , False,0,2)

    exp_adv_q_flt = exp_var3
    exp_adv_q = flt2dble(exp_adv_q_flt)
    exp_adv_q = exp_var1*exp_dqdx+exp_var2*exp_dqdy

    exp_wgt_adv_q=exp_adv_q(:,0,:,:)
    exp_wgt_adv_q=dim_sum_n(dp_cfm*exp_adv_q,1)               ; sum(var*dp)
    exp_wgt_adv_q = 86400*exp_wgt_adv_q/9.8
       
    exp_wgt_adv_qbar = month_to_season(exp_wgt_adv_q,g_season)

    diff_divQ = ctrl_divQbar
    diff_conQ = ctrl_wgt_conqbar
    diff_advQ = ctrl_wgt_adv_qbar

    diff_divQ = exp_divQbar-diff_divQ
    diff_conQ = diff_conQ-exp_wgt_conqbar
    diff_advQ = diff_advQ-exp_wgt_adv_qbar
    
    clm_diff_divQ = dim_avg_n_Wrap(diff_divQ,0)
    clm_diff_conQ = dim_avg_n_Wrap(diff_conQ,0)
    clm_diff_advQ = dim_avg_n_Wrap(diff_advQ,0)

    ;Caculate Relative Contribution
    contrib_conq = clm_diff_conQ
    contrib_adv = clm_diff_advQ
    contrib_conq = where(abs(clm_diff_divQ) .lt. 1.0, contrib_conq@_FillValue, contrib_conq)
    contrib_adv = where(abs(clm_diff_divQ) .lt. 1.0, contrib_adv@_FillValue, contrib_adv)
    contrib_conq = contrib_conq / clm_diff_divQ
    contrib_adv = contrib_adv / clm_diff_divQ
    
    contrib_conq_pos = contrib_conq
    contrib_adv_pos = contrib_adv

    contrib_conq_pos = where(contrib_conq .lt. 0.5, contrib_conq@_FillValue, contrib_conq)
    contrib_adv_pos = where(contrib_adv .lt. 0.5, contrib_adv@_FillValue, contrib_adv)



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
     
  res@gsnLeftString = "(d)"
  res@gsnCenterString = g_fig_title(0)
  res@gsnRightString = ""
  plot_sh(0) = gsn_csm_contour_map_ce(wks,clm_diff_divQ,res) ; create a default plot
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
    res_sig@cnFillPattern = 6 
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

