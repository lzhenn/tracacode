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
;                       2016-04-01
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-06  Change to fit Season jun
;   2015-06-23  Change to fit 973Report
;   2015-11-27  Change to automatic batch file
;   2016-04-01  Change to automatic batch file (ssn)
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

; Var Validation test

    if (.not. isvar("pro_ctrl_dir") .or. .not. isvar("ctrl_casename") .or..not. isvar("ctrl_pfile") .or.\
        .not. isvar("lats") .or. .not. isvar("latn") .or.\
        .not. isvar("lonw") .or. .not. isvar("lone") .or.\
        .not. isvar("ffrstyear") .or. .not. isvar("flstyear") .or. .not. isvar("fig_path")) then 
        print("ANNUAL Pr FIG: At least one argument has not been assigned, cannot continue!");
        exit
    end if



;================================================
;Variables List:
;	var3--------------TS
;================================================
;global variables
    g_font = 0.025
    


    g_nsmp        =   flstyear - ffrstyear + 1;number of samples for significance test
    g_idx_start = (ffrstyear-ffrstyear)*12
    g_idx_end = (flstyear-ffrstyear+1)*12-1

    g_run_period  =  ffrstyear+"-"+flstyear
    g_ctrl_period = ffrstyear+"-"+flstyear
        
;    g_var         = (/"PRECC","PRECL"/)
    g_var         = (/"PRECT"/)
    g_seasons     = (/"DJF","JJA","MAM","SON"/)
    g_file_profix = ".cam.h0."+g_var+"."+g_ctrl_period+".nc"

    g_fig_name    =   fig_path+"/clim-"+g_run_period+"-snn-"+(/"SuWi","SpFa"/)+"-PR-"+lats+latn+lonw+lone+"-"+ctrl_casename
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)"/)
    g_fig_title   =   (/"CMAP PR 81-10 "+g_seasons+" CLIM",ctrl_casename+" PR "+g_run_period+" "+g_seasons+" CLIM"/)


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================
    print(">>>> Reading data...")


    print("  >> CTRL Reading...")
    if (ctrl_pfile .eq. 0) then  ;multiple files, sen_year=ctrl_year
        print("    >> Multiple CTRL files, generating file list...")
        file_list_ctrl = new((/g_nsmp*12/),"string")
        pos = 0
        do ii=ffrstyear,flstyear
            do jj=1,12
                file_list_ctrl(pos)=ctrl_casename+".cam.h0."+sprinti("%0.4i", ii)+"-"+sprinti("%0.4i", jj)+".nc"
                pos = pos+1
            end do
        end do
	    
        file_list_ctrl = pro_ctrl_dir+file_list_ctrl
        setfileoption("nc","SuppressClose",False) ; close too many files
        ctrl_in      = addfiles (file_list_ctrl, "r")   ; note the "s" of addfile
    	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
	    ctrl_var3 = ctrl_in->$g_var(0)$			; p for unify the var name
    else
        print("    >> Reading...")
        ctrl_file1   = pro_ctrl_dir+ctrl_casename+g_file_profix(0)
        ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	    ctrl_var3 = ctrl_in1->$g_var(0)$(g_idx_start:g_idx_end,:,:)			; p for unify the var name
	    
    end if

	ctrl_var3 = 1000*86400*ctrl_var3		; p for unify the var name
    print("  >> CTRL reading done!!!")

    print("  >> OBV reading...")

    print("    >> Reading...")
    obv_file1   = "./clim_mon_data/CMAP_precip.mon.mean.197901-201503.nc"
    obv_in1     = addfile (obv_file1, "r")   ; note the "s" of addfile
    time_hist = obv_in1->time
    yyyymm = cd_calendar(time_hist,-1)
    istrt = ind(yyyymm .eq. "198101")
    ilast = ind(yyyymm .eq. "201012")
    obv_var3 = obv_in1->precip(istrt:ilast,:,:)			; p for unify the var name
    

    print("  >> OBV reading done!!!")
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================

    print(">>>> Processing data...")
    
    ctrl_season_var3_clim = ctrl_var3(0:3,:,:)

    obv_season_var3_clim = obv_var3(0:3,:,:)
    
    do ii = 0,3
        ctrl_var3_season =month_to_season (ctrl_var3, g_seasons(ii))
        obv_var3_season = month_to_season (obv_var3, g_seasons(ii))
        ctrl_season_var3_clim(ii,:,:) = dim_avg_n_Wrap(ctrl_var3_season,0)
        obv_season_var3_clim(ii,:,:) = dim_avg_n_Wrap(obv_var3_season,0)
    end do

;-----------------------------------------------------------------------------
 print(">>>> Processing figures")
 wks = gsn_open_wks("eps",g_fig_name(0))  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/4/),graphic)
  ;plot_tp = new((/2/),graphic)
  ;plot_V = new((/1/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
  gsn_define_colormap(wks,"precip2_17lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")

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
 res@cnMinLevelValF        = 0         ; set min contour level
 res@cnMaxLevelValF        = 16          ; set max contour level
 res@cnLevelSpacingF       = 1          ; set contour interval

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

  if (latn-lats .lt. 90) then  ;multiple files, sen_year=ctrl_year
    res@tmYLTickSpacingF = 15
  end if
  if (lone-lonw .lt. 180) then  ;multiple files, sen_year=ctrl_year
    res@tmYLTickSpacingF = 30
  end if

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
    do ii=0,1
        res@gsnRightString = "mm/day"
        
        if (ii .eq. 0) then  ;multiple files, sen_year=ctrl_year
            res@gsnLeftString = g_fig_rank(ii)
            res@gsnCenterString = g_fig_title(0,0)
            plot(ii) = gsn_csm_contour_map_ce(wks,obv_season_var3_clim(0,:,:),res) ; create a default plot
            res@gsnLeftString = g_fig_rank(ii+1)
            res@gsnCenterString = g_fig_title(1,0)
            plot(ii+2) = gsn_csm_contour_map_ce(wks,ctrl_season_var3_clim(0,:,:),res) ; create a default plot
        else
            res@gsnLeftString = g_fig_rank(2*ii)
            res@gsnCenterString = g_fig_title(0,1)
            plot(ii) = gsn_csm_contour_map_ce(wks,obv_season_var3_clim(1,:,:),res) ; create a default plot
            res@gsnLeftString = g_fig_rank(2*ii+1)
            res@gsnCenterString = g_fig_title(1,1)
            plot(ii+2) = gsn_csm_contour_map_ce(wks,ctrl_season_var3_clim(1,:,:),res) ; create a default plot
        end if
    end do
    gsn_panel(wks,plot,(/2,2/),False)
    
    print(">>>> FIG1 DONE!!!")

    delete(wks)
    wks = gsn_open_wks("eps",g_fig_name(1))  ; open a ps file
    gsn_define_colormap(wks,"precip2_17lev")
    do ii=2,3
        res@gsnLeftString = g_fig_rank(ii)
        res@gsnRightString = "mm/day"
        jj=ii-2
        if (jj .eq. 0) then  ;multiple files, sen_year=ctrl_season_year
            res@gsnLeftString = g_fig_rank(jj)
            res@gsnCenterString = g_fig_title(0,2)
            plot(jj) = gsn_csm_contour_map_ce(wks,obv_season_var3_clim(2,:,:),res) ; create a default plot
            res@gsnLeftString = g_fig_rank(jj+1)
            res@gsnCenterString = g_fig_title(1,2)
            plot(jj+2) = gsn_csm_contour_map_ce(wks,ctrl_season_var3_clim(2,:,:),res) ; create a default plot
        else
            res@gsnLeftString = g_fig_rank(2*jj)
            res@gsnCenterString = g_fig_title(0,3)
            plot(jj) = gsn_csm_contour_map_ce(wks,obv_season_var3_clim(3,:,:),res) ; create a default plot
            res@gsnLeftString = g_fig_rank(2*jj+1)
            res@gsnCenterString = g_fig_title(1,3)
            plot(jj+2) = gsn_csm_contour_map_ce(wks,ctrl_season_var3_clim(3,:,:),res) ; create a default plot
        end if
    end do
    gsn_panel(wks,plot,(/2,2/),False)
    print(">>>> ALL DONE!!!")
end 
