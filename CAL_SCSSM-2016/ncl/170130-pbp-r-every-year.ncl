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
;	var1--------------U (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_strt_yr=1979
    g_lst_yr=2010
    g_strt_mon=197901
    g_lst_mon=201012
    g_yr_len = g_lst_yr-g_strt_yr+1
    g_day_strt=99
    g_day_lst=144
    g_var_name1 = "r"
    g_data3_path ="$DATAOBV/ERA-interim/pressure/v/*"
    g_data2_path ="$DATAOBV/ERA-interim/pressure/u/*"
    g_data1_path ="$DATAOBV/PRECPT/cmap.precip.pentad.mean.nc"
    g_plvl =850
    g_font = 0.035
    
    g_latS=0.
    g_latN=50.
    g_lonW=60.
    g_lonE=140.


    ; create an array of desired pressure levels:
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)"/)
    g_fig_title   = ispan(21,29,1)+"p R+UV"+g_plvl


;Prepare the variables

    ctrl_in1 = addfile(g_data1_path, "r")
    time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    var1  = ctrl_in1->precip(:g_yr_len*73-1,{g_latS:g_latN},{g_lonW:g_lonE})
    var2_data=read_era_daily_2Din3D("uwnd", g_plvl, g_latS, g_latN, g_lonW, g_lonE, g_data2_path)
    var3_data=read_era_daily_2Din3D("vwnd", g_plvl, g_latS, g_latN, g_lonW, g_lonE, g_data3_path)
    var2_data:=var2_data(:,g_day_strt:g_day_lst,:,:) 
    var3_data:=var3_data(:,g_day_strt:g_day_lst,:,:) 
    
    var2_data_clim=dim_avg_n_Wrap(var2_data,0)
    var3_data_clim=dim_avg_n_Wrap(var3_data,0)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/9/),graphic)
  plot_V = new((/9/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



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
 res@cnMaxLevelValF        = 16.0          ; set max contour level
 res@cnLevelSpacingF       = 2.0          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
;  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  ;res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = False
  res@gsnPaperOrientation = "portrait"
  ;res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = False   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  res@lbLabelStride = 2 


  res@mpFillOn   = False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
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
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
  vcres@vcLineArrowHeadMinSizeF   = 0.01
  vcres@vcLineArrowHeadMaxSizeF   = 0.01
  
;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
; resP@gsnPanelMainString = "A plot with a common label bar"
                                                 ; use this for NCL V6.3.0 and earlier
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.015               ; make labels smaller 
  
  do jj=0,g_yr_len-1
      g_fig_name   = "../fig/obv/every-year/era"+g_plvl+"UVrmmean_Pr_21-29p-"+(jj+1979)
      wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
      gsn_define_colormap(wks,"precip2_17lev")
      do ii=0,8
        res@gsnLeftString = g_fig_rank(ii)
        res@gsnCenterString = (jj+1979)+" "+g_fig_title(ii)
        var1_data_clim_pt = var1((ii+20)+73*jj,:,:)
        var2_data_clim_pt=dim_avg_n_Wrap(var2_data(jj,ii*5:ii*5+4,:,:),0)
        var2_data_clim_pt= var2_data_clim_pt-dim_avg_n_Wrap(dim_avg_n_Wrap(var2_data(:,ii*5:ii*5+4,:,:),0),0)
        var3_data_clim_pt=dim_avg_n_Wrap(var3_data(jj,ii*5:ii*5+4,:,:),0)
        var3_data_clim_pt= var3_data_clim_pt-dim_avg_n_Wrap(dim_avg_n_Wrap(var3_data(:,ii*5:ii*5+4,:,:),0),0)
        plot_sh(ii) = gsn_csm_contour_map(wks,var1_data_clim_pt,res) ; create a default plot
        plot_V(ii) = gsn_csm_vector(wks,var2_data_clim_pt,var3_data_clim_pt,vcres) 
        overlay(plot_sh(ii),plot_V(ii))
      end do
      print((jj+1979)+"done")
      gsn_panel(wks,plot_sh,(/3,3/),resP)
      delete(wks)
  end do
end


