;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"

begin


;======================================================
;Variables List:
;	t2m--------------Air Temperature (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    
    ;SCS
    ;g_day_rank=(/135,140,150,155,145,140,150,135,160,145,160,140,160,140,150,125,135,130,140,140,150,135,130,135,145,140,150,140,145,125,150,145,130,140/)
    
    ;BOB
    g_data_path ="/home/yangsong3/L_Zealot/data-mirror/obv/L_Zealot/ERAI/CAL_SCSSM-2016/interim.51days.rh.nc"
    g_data2_path ="/home/yangsong3/L_Zealot/data-mirror/obv/L_Zealot/ERAI/CAL_SCSSM-2016/interim.51days.lcl.nc"




    g_font = 0.025
    
        
    g_latS=9
    g_latN=15
    g_lonW=87.5
    g_lonE=100
    
    g_fig_name = "../../fig/FINAL/Sep-vert"
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(n)","(o)","(p)","(q)","(r)","(s)"/)
    
    g_fig_title = "Level-Time RH Distribution" 

    ;Prepare the variables
    ctrl_in=addfile(g_data_path,"r")
    var1=ctrl_in->rh(:,:,:,{g_latS:g_latN},{g_lonW:g_lonE})
   
    ctrl_in2=addfile(g_data2_path,"r")
    var2=ctrl_in2->lcl(:,:,{g_latS:g_latN},{g_lonW:g_lonE})
    
    var_cmp:=dim_avg_n_Wrap(var1,0)
    
    var_cmp:=wgt_areaave_Wrap(var_cmp(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
   ; Anomaly percentage
   ; var_cmp_mean=dim_avg_n_Wrap(var_cmp,0)
   ; var_cmp=100*dim_rmvmean_n_Wrap(var_cmp,0)/conform(var_cmp,var_cmp_mean,1)
   ; var_cmp=dim_standardize_n_Wrap(var_cmp,1,0)
    var_cmp:=var_cmp(level|:,day|:)
    ;var_cmp=var_cmp*100
    var_cmp&level=var_cmp&level(::-1)
;    var_cmp=var_cmp(::-1,:)
    var_cmp&day=ispan(-25,25,1)
    do ii = 0,50
        var_cmp(:,ii)=var_cmp(:,ii)-var_cmp(:,25)
    end do
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/1/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)
  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
 
 gsn_define_colormap(wks,"MPL_BrBG")
; gsn_define_colormap(wks,"MPL_greens")

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options
  res@gsnFrame         = False
  res@gsnDraw  = False
 
  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels


  res@tmYRMode = "Automatic"
  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF        = -30        ; set min contour level
  res@cnMaxLevelValF        = 30         ; set max contour level
  res@cnLevelSpacingF       = 0.5        ; set contour interval
 ; res@cnFillColors =(/2,4,7,8,8,9,11,13/)
 res@vpWidthF = 0.5
 res@vpHeightF = 0.4

 res@gsnYAxisIrregular2Linear=True

 
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

;  res@gsnMaximize      = True       ; fill up the page
;  res@gsnAddCyclic   = True;False
;  res@gsnPaperOrientation = "portrait"
;  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  res@cnFillMode           = "CellFill"

  res@lbLabelBarOn = True   ; turn off the label bar
 ; res@lbOrientation          = "Vertical"
  res@lbLabelFontHeightF  = 0.02             ; make labels smaller
;  res@tmXBValues = ispan(-9,9,1) ;interval
;  res@tmXBLabels = ispan(-9,9,1)+" Day"         ;tick label
;res@lbLabelStride = 1
;  res@tmXBTickSpacingF = 15
;  res@tmYLTickSpacingF = 15
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = g_font
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = g_font
; res@tmYLLabelFontQuality =


;-----------------------------------------------------------------------------
     
  res@gsnLeftString = ""
  res@gsnRightString = ""
       
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
  vcres@vcMinDistanceF          = 0.03
  vcres@vcRefAnnoString1  = "5 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.02
 
  vcres@vcLineArrowThicknessF     = 1.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.01
  vcres@vcLineArrowHeadMaxSizeF   = 0.01
 

  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = True      ; turn off contour line labels
  res3@cnLineThicknessF = 4
  res3@cnInfoLabelOn = False
 
  res3@tmYRMode = "Automatic"
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/1, 2, 3, 4, 5/)
  res3@cnLineColor      = "Black"
  res3@gsnLeftString      = "shum & U"
  res3@gsnRightString      = " "

  res4=res3

  res4@cnLevels = -res3@cnLevels
  res4@cnLineColor="grey"

;************************************************
; create panel
;************************************************
 plot_sh = gsn_csm_pres_hgt(wks, var_cmp(:,19:31), res )  
; plot_cn_pos = gsn_csm_pres_hgt(wks, var2_cmp, res3 )  
; plot_cn_neg = gsn_csm_pres_hgt(wks, var2_cmp, res4 )  
; overlay(plot_sh, plot_cn_pos)
; overlay(plot_sh, plot_cn_neg)
 draw(plot_sh)
 frame(wks)
end

