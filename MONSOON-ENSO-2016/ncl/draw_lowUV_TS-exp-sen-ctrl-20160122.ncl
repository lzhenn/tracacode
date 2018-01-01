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
;   2015-06-23  Change to fit 973Report
;   2015-10-05  Change to fit dycore test
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
    g_casename_ctrl  = "B2000_f09_CAM5PM_spin-up"
    g_casename_sen  = "B2000_f09_CAM5PM_SCS_ANNCYC"
    ;Define parameters
    g_data_path_var1_sen = "/home/yangsong3/L_Zealot/data-mirror/model/SCS_ANNCYC-2015/pro/"+g_casename_sen+".cam.h0.TS.201-250.nc"
    g_data_path_var2_sen = "/home/yangsong3/L_Zealot/data-mirror/model/SCS_ANNCYC-2015/pro/"+g_casename_sen+".cam.h0.lowest.U.201-250.nc"
    g_data_path_var3_sen = "/home/yangsong3/L_Zealot/data-mirror/model/SCS_ANNCYC-2015/pro/"+g_casename_sen+".cam.h0.lowest.V.201-250.nc"
    
    g_data_path_var1_ctrl = "/home/yangsong3/data/model/CESM_CTRL/B2000_F09G16_CAM5PM_CTRL/pro/"+g_casename_ctrl+".cam.h0.TS.201-250.nc"
    g_data_path_var2_ctrl = "/home/yangsong3/data/model/CESM_CTRL/B2000_F09G16_CAM5PM_CTRL/pro/"+g_casename_ctrl+".cam.h0.lowest.U.201-250.nc"
    g_data_path_var3_ctrl = "/home/yangsong3/data/model/CESM_CTRL/B2000_F09G16_CAM5PM_CTRL/pro/"+g_casename_ctrl+".cam.h0.lowest.V.201-250.nc"
    
    g_season      =   "JJA"
    g_latS=-30.
    g_latN=30.
    g_lonW=80.
    g_lonE=280.
    ;g_latS=-90.
    ;g_latN=90.
    ;g_lonE=360.
    ;g_lonW=0.
; create an array of desired pressure levels:
    g_smp_years   = (/2,3,6,9,13,17,20,21,23,29,34,37,38,43,46,47,48/)
    ;g_smp_years   = (/4,11,13,15,18,20,26,28,29,30,39,41,42,45,46,49/)
    g_nsmp        = dimsizes(g_smp_years)
    g_idx_start = (g_smp_years-1)*12

    g_sen_cases = 1    
    g_font = 0.02

    g_var         = (/"TS","U","V"/)

    g_date =systemfunc("date '+%Y%m%d'")
    g_fig_name    =   "../fig/"+g_season+"-SEN-CTRL-Tropical-botUV-TS-20NS-"+g_date
    ;g_fig_rank    =   "B2000_F19G16_CAM4_CTRL"
    g_fig_rank    =   (/"a","a","a","b","b","b","c","c","c"/)
    ;g_fig_title   =   g_season+" HEAT_CP-CON_CP"
    g_fig_title   =    g_season+" SEN-CTRL bottom UV and TS"


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================
    
    ctrl_in1 = addfile(g_data_path_var1_ctrl,"r")
    ctrl_in2 = addfile(g_data_path_var2_ctrl,"r")
    ctrl_in3 = addfile(g_data_path_var3_ctrl,"r")

	ctrl_var1  = ctrl_in1->TS(:,:,:)			; p for unify the var name
	ctrl_var2 = ctrl_in2->U(:,:,:)			; p for unify the var name
	ctrl_var3  = ctrl_in3->V(:,:,:)			; p for unify the var name

    sen_in1 = addfile(g_data_path_var1_sen,"r")
    sen_in2 = addfile(g_data_path_var2_sen,"r")
    sen_in3 = addfile(g_data_path_var3_sen,"r")

	sen_var1  = sen_in1->TS(:,:,:)			; p for unify the var name
	sen_var2 = sen_in2->U(:,:,:)			; p for unify the var name
	sen_var3  = sen_in3->V(:,:,:)			; p for unify the var name


; ==============================================================
; Mission 2. Post process the data, composite
; ==============================================================
    
    ctrl_var1_season = month_to_season(ctrl_var1,g_season) 
    ctrl_var2_season = month_to_season(ctrl_var2,g_season) 
    ctrl_var3_season = month_to_season(ctrl_var3,g_season) 
    
    clim_ctrl_var1_season = dim_avg_n_Wrap(ctrl_var1_season,0)
    clim_ctrl_var2_season = dim_avg_n_Wrap(ctrl_var2_season,0)
    clim_ctrl_var3_season = dim_avg_n_Wrap(ctrl_var3_season,0)
    printVarSummary(ctrl_var1_season)

    sen_var1_season = month_to_season(sen_var1,g_season) 
    sen_var2_season = month_to_season(sen_var2,g_season) 
    sen_var3_season = month_to_season(sen_var3,g_season) 
    
    clim_sen_var1_season = dim_avg_n_Wrap(sen_var1_season,0)
    clim_sen_var2_season = dim_avg_n_Wrap(sen_var2_season,0)
    clim_sen_var3_season = dim_avg_n_Wrap(sen_var3_season,0)
    printVarSummary(sen_var1_season)


    diff_var1_season = ctrl_var1_season(g_smp_years(0),:,:)
    diff_var2_season = ctrl_var2_season(g_smp_years(0),:,:)
    diff_var3_season = ctrl_var3_season(g_smp_years(0),:,:)

    diff_var1_season = clim_sen_var1_season-clim_ctrl_var1_season
    diff_var2_season = clim_sen_var2_season-clim_ctrl_var2_season
    diff_var3_season = clim_sen_var3_season-clim_ctrl_var3_season

    diff_speed = diff_var2_season
    diff_speed = sqrt(diff_var2_season*diff_var2_season + diff_var3_season*diff_var3_season)
    diff_var2_season@_FillValue= -999
    diff_var2_season = where(diff_speed .gt. 0.5, diff_var2_season, diff_var2_season@_FillValue)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file
;  plot_cn_pos = new((/9/),graphic)
;  plot_cn_neg = new((/9/),graphic)
  plot_V = new((/1/),graphic)
  plot_sh = new((/1/),graphic)
;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
 gsn_define_colormap(wks,"MPL_bwr")

 do n = 0,0
    
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
    res@cnMinLevelValF        =  -1          ; set min contour level
    res@cnMaxLevelValF        =  1          ; set max contour level
    res@cnLevelSpacingF       =  0.05          ; set contour interval

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
    res@gsnLeftString = ""

   res@gsnMaximize      = True       ; fill up the page
    res@gsnAddCyclic   = False
   ; res@gsnPaperOrientation = "portrait"
   ; res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller
    res@lbLabelStride = 2

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
    res@tmXBTickSpacingF = 60
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
    
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    res@gsnStringFontHeightF = g_font    


    plot_sh(n) = gsn_csm_contour_map_ce(wks,diff_var1_season,res) ; create a default plot
      
      res3                  = True       ; use plot options
      res3@cnFillOn         = False;True       ; Fill contours
      res3@cnLinesOn        = True      ; turn off contour lines
    ;for tp masking
      res3@gsnFrame         = False
      res3@gsnDraw  = False
      res3@cnLineLabelsOn   = False      ; turn off contour line labels
      res3@cnLineThicknessF = 2 
      res3@cnInfoLabelOn = False
     
     
      res3@cnLevelSelectionMode="ExplicitLevels"
      res3@cnLevels = (/0.004,0.008,0.012,0.016/)
      res3@cnLineColor      = "Red"
      res3@gsnLeftString      = " "
      res3@gsnRightString      = " "


      ;plot_cn_pos(n) = gsn_csm_contour(wks,diff_var4(n+1,:,:),res3)

      res3@cnLevels = (/-0.004,-0.008,-0.012,-0.016/)
      res3@cnLineColor      = "Blue"
      res3@cnLineDashPattern      = 1
      
      ;plot_cn_neg(n) = gsn_csm_contour(wks,diff_var4(n+1,:,:),res3)

    ;
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
    vcres@vcRefMagnitudeF         = 1.5             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.03
    vcres@vcRefAnnoString1  = "1.5 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.01
    vcres@vcLineArrowThicknessF     = 1.5    ;thickness of vector

    vcres@vcLineArrowHeadMinSizeF   = 0.015
    vcres@vcLineArrowHeadMaxSizeF   = 0.015       
    
    plot_V(n) = gsn_csm_vector(wks,diff_var2_season,diff_var3_season,vcres)

    ;do i = 0,3
    ;    res@gsnLeftString = g_fig_rank(i)
    ;    res@gsnCenterString = g_fig_title(i)
    ;    res@gsnRightString = ""
    ;    plot(i) = gsn_csm_contour_map_ce(wks,dvar1_dt(i,:,:),res) ; create a default plot
    ;end do


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

;    ; create array of dummy graphic variables. This is required, b/c each line
;    ; must be associated with a unique dummy variable.
;
;    dum = new(4,graphic)  
;
;    ; draw each line separately. Each line must contain two points.
;    do i = 0 , 3
;        dum(i)=gsn_add_polyline(wks,plot_sh(n),xpts(i:i+1),ypts(i:i+1),resp)      
;    end do 
;    ;************************************************
;    ; create points for box in southern China
;    ;************************************************
;
;    resp@gsLineDashPattern      = 1                     ; color of lines
;    ypts = (/ 35.0,  35.0, 20.0,  20.0, 35.0/)
;    xpts = (/110.0, 135.0,135.0, 110.0,110.0/)
;
;    dum2 = new(4,graphic)  
;
;    ; draw each line separately. Each line must contain two points.
;    do i = 0 , 3
;        dum2(i)=gsn_add_polyline(wks,plot_sh(n),xpts(i:i+1),ypts(i:i+1),resp)      
;    end do 
;      overlay(plot_sh(n),plot_cn_pos(n))
;      overlay(plot_sh(n),plot_cn_neg(n))
      overlay(plot_sh(n),plot_V(n))
;    delete([/resp,res,res3,vcres/])
end do

  ;gsn_panel(wks,plot_sh(0),(/2,2/),False)
  
  draw(plot_sh)
  frame(wks)
end 
