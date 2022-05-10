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
    g_data_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ERA-clim/interim.51days.rh.nc"
    g_data2_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ERA-clim/interim.51days.theta_e.nc"
    g_data3_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ERA-clim/interim.51days.theta_es.nc"

    ; Early
    ;g_comp_years=(/1990, 1999, 2000, 2006, 2009, 2012, 2015/)
    ; Late
    g_comp_years=(/1980, 1981, 1985, 1992, 1993, 1997, 1998, 2010/)




    g_font = 0.025
    
        
    g_latS=9
    g_latN=15
    g_lonW=87.5
    g_lonE=100
    
    g_fig_name = "../../fig/FINAL/Sep-vert-shum"
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(n)","(o)","(p)","(q)","(r)","(s)"/)
    
    g_fig_title = "Level-Time RH Distribution" 

    ;Prepare the variables
    ctrl_in=addfile(g_data_path,"r")
    var1=ctrl_in->rh(:,:,:,{g_latS:g_latN},{g_lonW:g_lonE})
    ctrl_in=addfile(g_data2_path,"r")
    var2=ctrl_in->theta_e(:,:,:,{g_latS:g_latN},{g_lonW:g_lonE})     ;Prepare the variables
    ;ctrl_in=addfile(g_data3_path,"r")
    ;var3=ctrl_in->theta_es(:,:,:,{g_latS:g_latN},{g_lonW:g_lonE})
 
    var_cmp:=dim_avg_n_Wrap(var1,0)
    var_cmp:=wgt_areaave_Wrap(var_cmp(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)

    ;var_cmp&day=ispan(-25,25,1)
    ;printVarSummary(var_cmp)
    var2_cmp:=dim_avg_n_Wrap(var2,0)
    var2_cmp:=wgt_areaave_Wrap(var2_cmp(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    var_cmp&day=ispan(-26,24,1)
    var2_cmp&day=ispan(-26,24,1)
    var2_pbl=dim_avg_n_Wrap(var2_cmp(:,{1000:1000}),1)
    var2_cmp:=var2_cmp(level|:,day|:)
    var_cmp:=var_cmp(level|:,day|:)
    ;var2_cmp&level=var2_cmp&level(::-1)

    ;var3_cmp:=dim_avg_n_Wrap(var3(:,:,:,{g_latS:g_latN},{g_lonW:g_lonE}),0)
    ;var3_cmp:=wgt_areaave_Wrap(var3_cmp(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    ;var2_dim=conform(var3_cmp,var2_pbl,0)
    ;var3_cmp=var2_dim-var3_cmp
    ;var3_cmp&level=var3_cmp&level(::-1)
    ;var3_cmp:=var3_cmp(level|:,day|:)
    ;var3_cmp=where(var3_cmp .lt. 0, var3_cmp, var3_cmp@_FillValue)

;    var_cmp=dim_standardize_n_Wrap(var_cmp,1,1)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/1/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)
  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
 
 gsn_define_colormap(wks,"BlRe")
; gsn_define_colormap(wks,"MPL_greens")

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options
  res@gsnFrame         = False
  res@gsnDraw  = False
 
  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels
  res@trYReverse = True

  res@tmYRMode = "Automatic"
  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
  res@cnMinLevelValF        = 325        ; set min contour level
  res@cnMaxLevelValF        = 340        ; set max contour level
  res@cnLevelSpacingF       = 0.25       ; set contour interval
; res@cnFillColors =(/2,4,7,8,8,9,11,13/)
 res@vpWidthF = 0.7
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
  res@cnFillMode="CellFill"
  res@tiYAxisString=""
  res@lbLabelBarOn = True   ; turn off the label bar
  ;res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  res@lbBoxLinesOn=False
 res@lbLabelStride = 12
;  res@tmYLValues = fspan(100,1000,10)
;  res@tmYLLabels = fspan(100,1000,10)
res@tmYLMajorOutwardLengthF=0
res@tmYLMajorLengthF=0.0
  res@tmXBMinorOn=False
  
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = g_font
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = g_font
; res@tmYLLabelFontQuality =

;-----------------------------------------------------------------------------
     
  res@gsnLeftString = "(a)"
  res@gsnCenterString = "Obv theta-e and RH"
  res@gsnRightString = ""
       
  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 3
  res3@cnInfoLabelOn = False
 
  res3@tmYRMode = "Automatic"
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/35,40,45,50,55,60/)
  res3@cnLineColor      = "Black"
  res3@gsnLeftString      = ""
  res3@gsnRightString      = " "

;************************************************
; create panel
;************************************************
 plot_sh = gsn_csm_pres_hgt(wks, var2_cmp(:,{-10:10}), res )  
printVarSummary(var_cmp)
plot_cn_pos = gsn_csm_contour(wks, var_cmp(:,{-10:10}), res3 )  
; plot_cn_neg = gsn_csm_pres_hgt(wks, var2_cmp, res4 )  
 overlay(plot_sh, plot_cn_pos)
; overlay(plot_sh, plot_cn_neg)
res_lines                   = True                  ; polyline mods desired
res_lines@gsLineDashPattern = 0.                    ; solid line
;dum1 = gsn_add_polyline(wks,plot_sh,ispan(-10,10,1),var_cmp,res_lines)              ; add polyline



draw(plot_sh)
 frame(wks)
end

