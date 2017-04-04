;*************************************************************
;Aim: draw SEN-CTRL Seasonal Pr and 850UV, do the significance test 
;
;Mission:
;   1. Read data from post model datasets
;   2. Post-post process
;     2.1 Climatology 
;     2.2 Difference
;     2.3 Sig test
;   4. Draw and overlap
;                       Zhenning Li
;                       2016-01-13
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-06  Change to fit Season jun
;   2015-06-23  Change to fit 973Report
;   2015-11-27  Change to automatic batch file
;   2015-11-27  Change to automatic batch file (ssn->ann)
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; Var Validation test

    if (.not. isvar("pro_ctrl_dir") .or. .not. isvar("ctrl_casename") .or.\
        .not. isvar("pro_sen_dir") .or. .not. isvar("sen_casename") .or.\
        .not. isvar("sub_frstyear") .or. .not. isvar("sub_lstyear") .or.\
        .not. isvar("sen_sub_frstyear") .or. .not. isvar("sen_sub_lstyear") .or.\
        .not. isvar("sen_ffrstyear") .or. .not. isvar("sen_flstyear") .or.\
        .not. isvar("lats") .or. .not. isvar("latn") .or.\
        .not. isvar("lonw") .or. .not. isvar("lone") .or.\
        .not. isvar("ffrstyear") .or. .not. isvar("flstyear") .or. .not. isvar("fig_path")) then 
        print("SEASONAL UV850+Pr FIG: At least one argument has not been assigned, cannot continue!");
        exit
    end if



;================================================
;Variables List:
;	var1--------------TS
;================================================
;global variables
    g_font = 0.025
    


    g_season      =   (/"DJF","MAM","JJA","SON"/)
    g_nsmp        =   sub_lstyear - sub_frstyear + 1;number of samples for significance test
    g_idx_start = (sub_frstyear-ffrstyear)*12
    g_idx_end = (sub_lstyear-ffrstyear+1)*12-1

    g_run_period  =  ffrstyear+"-"+flstyear

        
    g_var         = (/"TS"/)
    
    g_ctrl_file_profix = ".cam.h0."+g_var+"."+g_run_period+".nc"

    g_idx_start_sen = (sen_sub_frstyear-sen_ffrstyear)*12
    g_idx_end_sen = (sen_sub_lstyear-sen_ffrstyear+1)*12-1
    g_run_period_sen  =  sen_ffrstyear+"-"+sen_flstyear
    g_sen_file_profix = ".cam.h0."+g_var+"."+g_run_period_sen+".nc"

    g_fig_name    =   fig_path+"/diff-"+g_run_period_sen+"-season-"+g_var+"-"+sen_casename+"_"+ctrl_casename
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)"/)
    g_fig_title   =    "TS SEN - CON ("+g_season+")"


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================
    print(">>>> Reading data...")
   
    ctrl_file1   = pro_ctrl_dir+ctrl_casename+g_ctrl_file_profix(0)
    ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	ctrl_var3 = ctrl_in1->$g_var(0)$(g_idx_start:g_idx_end,:,:)			; p for unify the var name

    
    sen_file1   = pro_sen_dir+sen_casename+g_sen_file_profix(0)
    sen_in1     = addfile (sen_file1, "r")   ; note the "s" of addfile
	exp_var3  = sen_in1->$g_var(0)$(g_idx_start_sen:g_idx_end_sen,:,:)			; p for unify the var name

; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================

    print(">>>> Processing data...")
    
    ctrl_var3_season_clim = ctrl_var3(0:3,:,:)
    ctrl_var3_var = ctrl_var3_season_clim

    exp_var3_season_clim = exp_var3(0:3,:,:)
    exp_var3_var = exp_var3_season_clim
    do ii = 0,3
        ctrl_var3_season = month_to_season (ctrl_var3, g_season(ii))
        ctrl_var3_season_clim(ii,:,:) = dim_avg_n_Wrap(ctrl_var3_season,0)
        ctrl_var3_var(ii,:,:) = dim_variance_n(ctrl_var3_season,0)

        exp_var3_season = month_to_season (exp_var3, g_season(ii))
        exp_var3_season_clim(ii,:,:) = dim_avg_n_Wrap(exp_var3_season,0)
        exp_var3_var(ii,:,:) = dim_variance_n(exp_var3_season,0)
    end do
    diff_var3 = exp_var3_season_clim	

    diff_var3 = (exp_var3_season_clim-ctrl_var3_season_clim)		
    diff_var3_sig = diff_var3

    ;============================================================
    ;Sig test
    ;============================================================

    sigr = 0.1                        ; critical sig lvl for r

    iflag= False                        ; population variance similar
 ;   prob3 = ttest(ctrl_var3_season_clim,ctrl_var3_var,g_nsmp, exp_var3_season_clim,exp_var3_var,g_nsmp, iflag, False)
    
 ;   diff_var3_sig=mask(diff_var3, prob3 .lt. sigr, True)

;-----------------------------------------------------------------------------
 print(">>>> Processing figures")
 wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/4/),graphic)
  ;plot_tp = new((/2/),graphic)
  plot_sig = new((/4/),graphic)
  plot_V = new((/1/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")

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
 res@cnMinLevelValF        = -1.5         ; set min contour level
 res@cnMaxLevelValF        = 1.5          ; set max contour level
 res@cnLevelSpacingF       = 0.1          ; set contour interval

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
  res@mpMaxLatF  = latn
  res@mpMinLatF  = lats
  res@mpMaxLonF  = lone
  res@mpMinLonF  = lonw

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
  res@tmYLTickSpacingF = 30 
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
; res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
; res@cnMinLevelValF        = -3.          ; set min contour level
; res@cnMaxLevelValF        =  3.          ; set max contour level
; res@cnLevelSpacingF       =  0.5          ; set contour interval
 

; plot(1) = gsn_csm_contour_map_ce(wks,cp_diff_var3,res) ; create a default plot

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
;--------------------------------------
do ii=0,3
    res@gsnLeftString = g_fig_rank(ii)
    res@gsnCenterString = g_fig_title(ii)
    plot(ii) = gsn_csm_contour_map_ce(wks,diff_var3(ii,:,:),res) ; create a default plot
   ; plot_sig(ii) = gsn_csm_contour(wks,diff_var3_sig(ii,:,:),res_sig)
  
    ;overlay(plot(ii),plot_sig(ii))
end do
 
  gsn_panel(wks,plot,(/2,2/),False)

  print(">>>> DONE!!!")
end 
