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

begin


;======================================================
;Variables List:
;	t2m--------------Air Temperature (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_day_rank=(/135,140,150,155,145,140,150,135,160,145,160,140,160,140,150,125,135,130,140,140,150,135,130,135,145,140,150,140,145,125,150,145,130,140/)
    g_strt_yr=1979
    g_lst_yr=2010
    g_day_shift=10

    g_var_name = "r"

    g_data_path ="../data/daily/ERA-rain/"
    g_font = 0.035
    
    g_latS=0.
    g_latN=60.
    g_lonW=60.
    g_lonE=140.
    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/"+g_var_name+"_comp_rmanncyc_P1-P0"
        
    g_fig_rank    = (/"(a)","(b)","(c)"/)
    g_fig_title   = (/" -2Pts Diff ","+2Pts ", "Diff "/)+g_var_name

    npos_year = 0
    nneg_year = 0


;Prepare the variables
    setfileoption("nc","SuppressClose",False) ; don't close too many files
    all_files = systemfunc("ls "+g_data_path+"*.nc")  
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
    ctrl_var1 = ctrl_in[:]->$g_var_name$ 
    time    = ctrl_in[:]->time                          ; time:units = "hours since 1-1-1 00:00:0.0"                               
    TIME    = cd_calendar(time, 0)          ; type float 
    year    = toint( TIME(:,0) )
    month   = toint( TIME(:,1) )
    day     = toint( TIME(:,2) ) 
    ddd     = day_of_year(year, month, day) 
    yyyyddd = year*1000 + ddd                                  ; needed for input

    clim_ctrl_var1    = clmDayTLL(ctrl_var1, yyyyddd)     ; daily climatology at each grid point   

    
    ctrl_in1     = addfile (g_data_path+g_var_name+"ain.daily.interim.1979.nc", "r")   ; note the "s" of addfile
    ref_day_rank =g_day_rank(0)-1
    t2m_accu_pos  =ctrl_in1->$g_var_name$(ref_day_rank-g_day_shift:ref_day_rank+g_day_shift-1,:,:)
    t2m_accu_pos = 0
    t2m_accu_neg = t2m_accu_pos
    print("1979 done!")
    do nyr = g_strt_yr+1, g_lst_yr
        print(nyr+" done!")
        ctrl_in1     = addfile (g_data_path+g_var_name+"ain.daily.interim."+nyr+".nc", "r")   ; note the "s" of addfile
        ref_day_rank =g_day_rank(nyr-1979)-1
        ;time_hist    = ctrl_in1->time
        ;yyyymmdd  = cd_calendar(time_hist,-2)
        ;istrt   = ind(yyyymmdd .eq. g_strt_day)
        ;ilast   = ind(yyyymmdd .eq. g_lst_day)
        t2m  =ctrl_in1->$g_var_name$(ref_day_rank-g_day_shift:ref_day_rank+g_day_shift-1,:,:)
        t2m  = t2m - clim_ctrl_var1(ref_day_rank-g_day_shift:ref_day_rank+g_day_shift-1,:,:)
        if (g_day_rank(nyr-1979) .gt. 149) then
            t2m_accu_pos = t2m + t2m_accu_pos
            npos_year = npos_year+1
        else if (g_day_rank(nyr-1979) .lt. 131) then
            t2m_accu_neg = t2m + t2m_accu_neg
            nneg_year = nneg_year+1
        end if
        end if
    end do
    
    t2m_pt0 = t2m_accu_pos(0,:,:)
    t2m_pt1 = t2m_accu_pos(0,:,:)
    t2m_diff = t2m_accu_pos(0,:,:)
    t2m_pt0 = dim_avg_n_Wrap(t2m_accu_pos(0:g_day_shift-1,:,:),0)/npos_year
    t2m_pt1 = dim_avg_n_Wrap(t2m_accu_neg(0:g_day_shift-1,:,:),0)/nneg_year
    t2m_diff = t2m_pt1 - t2m_pt0
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/3/),graphic)
;  plot_tp = new((/2/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)

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
 res@cnMinLevelValF        = -6         ; set min contour level
 res@cnMaxLevelValF        = 6         ; set max contour level
 res@cnLevelSpacingF       = 0.5         ; set contour interval
 res@mpDataBaseVersion    = "MediumRes"
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
  ;res@lbLabelStride = 1

  res@mpFillOn   = False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
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
  res@tmXBTickSpacingF = 15
  res@tmYLTickSpacingF = 15
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =
;-----------------------------------------------------------------------------
    res@gsnRightString=""
    res@gsnLeftString=g_fig_rank(0)
    res@gsnCenterString=g_fig_title(0)
    plot(0) = gsn_csm_contour_map_ce(wks,t2m_diff,res)

  gsn_panel(wks,plot(0),(/1,1/),False)

  draw(plot)
  frame(wks)
 
end

