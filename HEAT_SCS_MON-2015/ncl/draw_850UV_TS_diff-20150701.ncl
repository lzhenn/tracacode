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
;   2015-06-23  Change to to calculate 850UV and 500HGT change
;               between 1999-2013 and 1979-1998
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------Z3
;	var2--------------U
;	var3--------------V
;================================================
;global variables
    g_data_path = "../data/obv/Z3-197901-201408.nc"
    g_data_path1 = "../data/obv/U-197901-201408.nc"
    g_data_path2 = "../data/obv/V-197901-201408.nc"

    g_latS=-30.
    g_latN=45.
    g_lonW=90.
    g_lonE=180.
; create an array of desired pressure levels:

    g_plvl1 = 500    
    g_plvl2 = 500    
    g_font = 0.035
    g_season = "MAM"
    g_strt_mon = 197901 
    g_lst_mon = 201312
    g_fig_name    =   "../fig/obv/"+g_strt_mon+"-"+g_lst_mon+"_850UV-500HGT_diff_pattern_"+g_season
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    g_fig_title     =  "MAM UV850 & 500HGT 1999-2015 minus 1979-1998"
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
	var1  =short2flt(ctrl_in1->z(istrt:ilast,{g_plvl1},:,:))			; p for unify the var name

    ctrl_file2   = g_data_path1
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	time_hist2    = ctrl_in2->time
    yyyymm2  = cd_calendar(time_hist2,-1)
    istrt   = ind(yyyymm2 .eq. g_strt_mon)
    ilast   = ind(yyyymm2 .eq. g_lst_mon)
	var2  =short2flt(ctrl_in2->u(istrt:ilast,{g_plvl2},:,:))			; p for unify the var name

    ctrl_file3   = g_data_path2
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile
	time_hist3    = ctrl_in3->time
    yyyymm3  = cd_calendar(time_hist3,-1)
    istrt   = ind(yyyymm3 .eq. g_strt_mon)
    ilast   = ind(yyyymm3 .eq. g_lst_mon)
	var3  =short2flt(ctrl_in3->v(istrt:ilast,{g_plvl2},:,:))			; p for unify the var name
; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================
    
    var1bar = month_to_season(var1,g_season)
    var2bar = month_to_season(var2,g_season)
    var3bar = month_to_season(var3,g_season)
   
	var1_sn_clim_former = dim_avg_n_Wrap(var1bar(0:19,:,:),0)
	var1_sn_clim_latter =  dim_avg_n_Wrap(var1bar(20:,:,:),0)
    
	var2_sn_clim_former = dim_avg_n_Wrap(var2bar(0:19,:,:),0)
	var2_sn_clim_latter =  dim_avg_n_Wrap(var2bar(20:,:,:),0)

	var3_sn_clim_former = dim_avg_n_Wrap(var3bar(0:19,:,:),0)
	var3_sn_clim_latter =  dim_avg_n_Wrap(var3bar(20:,:,:),0)


	var1_sn_var_former = dim_variance_n(var1bar(0:19,:,:),0)
	var1_sn_var_latter = dim_variance_n(var1bar(20:,:,:),0)

	var2_sn_var_former = dim_variance_n(var2bar(0:19,:,:),0)
	var2_sn_var_latter = dim_variance_n(var2bar(20:,:,:),0)
	
    var3_sn_var_former = dim_variance_n(var3bar(0:19,:,:),0)
	var3_sn_var_latter = dim_variance_n(var3bar(20:,:,:),0)

    diff_var1 = var1_sn_clim_former 
    diff_var2 = var2_sn_clim_former
    diff_var3 = var3_sn_clim_former

    diff_var1 = var1_sn_clim_latter - var1_sn_clim_former
    diff_var2 = var2_sn_clim_latter - var2_sn_clim_former
    diff_var3 = var3_sn_clim_latter - var3_sn_clim_former
    diff_var1_sig = diff_var1
	;============================================================
    ;Sig test
    ;============================================================

    sigr = 0.05                        ; critical sig lvl for r

    nsmp_former = dimsizes(var1_sn_clim_former)
    nsmp_latter = dimsizes(var1_sn_clim_latter)

    iflag= False                        ; population variance similar
    prob1 = ttest(var1_sn_clim_former,var1_sn_var_former,nsmp_former(0), var1_sn_clim_latter, var1_sn_var_latter, nsmp_latter(0), iflag, False) 
    prob2 = ttest(var2_sn_clim_former,var2_sn_var_former,nsmp_former(0), var2_sn_clim_latter, var2_sn_var_latter, nsmp_latter(0), iflag, False) 
    prob3 = ttest(var3_sn_clim_former,var3_sn_var_former,nsmp_former(0), var3_sn_clim_latter, var3_sn_var_latter, nsmp_latter(0), iflag, False) 
    
    diff_var3=mask(diff_var3, (prob3 .lt. sigr) .or. (prob2 .lt. sigr), True)
    diff_var1_sig=mask(diff_var1, prob1 .lt. sigr, True)



    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    ;plot_C = new((/4/),graphic)     ;contour
    plot_V = new((/1/),graphic)     ;vector
    plot_S = new((/1/),graphic)     ;shading
    plot_sig = new((/1/),graphic)   ;sig in shading

    ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;gsn_define_colormap(wks,"precip4_diff_19lev")
    ;gsn_define_colormap(wks,"precip_diff_12lev")
    ; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


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
    res@cnMinLevelValF        =  -300          ; set min contour level
    res@cnMaxLevelValF        =  300          ; set max contour level
    res@cnLevelSpacingF       =  25          ; set contour interval

    ;res@cnMinLevelValF        =  100000          ; set min contour level
    ;res@cnMaxLevelValF        =  102000          ; set max contour level
    ;res@cnLevelSpacingF       =  50          ; set contour interval
    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

    res@gsnSpreadColors      = True               ; use full color map
    ;res@gsnSpreadColorStart  = 2                ; start at color 17
    ;res@gsnSpreadColorEnd    = 14                ; end at color 200

    ;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
    res@gsnRightString = ""
    res@gsnCenterString = g_fig_title
    res@gsnLeftString = ""

   ; res@gsnMaximize      = True       ; fill up the page
    res@gsnAddCyclic   = False
   ; res@gsnPaperOrientation = "portrait"
   ; res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller
    res@lbLabelStride = 4 

    res@mpFillOn   = True;False     ; turn off gray continents
    res@mpGeophysicalLineThicknessF = 3 
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
;-------Set for contour plot--------

    resC                  = True       ; use plot options
    resC@cnLinesOn            = True              ; turn off contour lines
    resC@cnLineLabelsOn       = True              ; turn off contour line labels
    resC@cnInfoLabelOn        = False             ; turn off info label
    resC@gsnFrame         = False
    resC@gsnDraw  = False
    resC@gsnMaximize      = True       ; fill up the page
    resC@gsnAddCyclic   = False
    resC@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
   ; resC@cnLevelSelectionMode = "ExplicitLevels"  ; use explicit levels
   ; resC@cnLevels             = fspan(-1.5,2.0,8 )   ; set the contour levels
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


  plot_V(0) = gsn_csm_vector(wks,diff_var2,diff_var3,vcres)

  plot_S(0) = gsn_csm_contour_map_ce(wks,diff_var1,res)
  
  plot_sig(0) = gsn_csm_contour(wks,diff_var1_sig,res_sig)

  overlay(plot_S(0),plot_sig(0))
  overlay(plot_S(0),plot_V(0))

 
  gsn_panel(wks,plot_S(0),(/1,1/),False)

  draw(plot_S)
  frame(wks)
end 
