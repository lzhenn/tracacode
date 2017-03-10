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
    
    g_strt_yr=1979
    g_lst_yr=2010
    g_yr_len = g_lst_yr-g_strt_yr+1
 

    ; U200 P20-28
    g_day_strt2=70
    g_day_lst2=160
    g_day_comp_len=19
    
    ;BOB All
    g_comp="all"
    g_special_year=ispan(g_strt_yr,g_lst_yr,1)
    g_day_rank=(/125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119,123/)-1

    
    ;BOB Early
    ;g_comp="early"
    ;g_special_year=(/1984, 1990, 1999, 2000, 2006, 2009/)
    ;g_day_rank=(/108, 105, 93, 100, 107, 99/)
    
    ;BOB Late
    ;g_comp="late"
    ;g_special_year=(/1980, 1981, 1982, 1983, 1985, 1992, 1993, 1997, 1998, 2010/)
    ;g_day_rank=(/136, 133, 134, 143, 136, 132, 134, 133, 132, 134/)

    g_day_rank= g_day_rank-g_day_strt2-1

    g_data_path ="/home/yangsong3/L_Zealot/data-mirror/obv/ERA-interim/pressure/shum/*"
    g_data2_path ="$DATAOBV/ERA-interim/pressure/air/*"
    g_data3_path ="$DATAOBV/ERA-interim/pressure/v/*"






    g_font = 0.025
    
        
    g_latS=9
    g_latN=15
    g_lonW=87.5
    g_lonE=100
    
    g_fig_name = "../fig/obv/RH-V-vert-dbd-hov-pbl-before-after-"+g_comp+"-"+g_lonW+"-"+g_lonE
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(n)","(o)","(p)","(q)","(r)","(s)"/)
    
    g_fig_title = "Level-Time RH Distribution" 
    g_special_cases=dimsizes(g_special_year) 

    ;Prepare the variables

    var=read_era_daily_3D("shum", 200, 1000, g_latS, g_latN, g_lonW, g_lonE, g_data_path)
    var2=read_era_daily_3D("air", 200, 1000, g_latS, g_latN, g_lonW, g_lonE, g_data2_path)
    var3=read_era_daily_3D("vwnd", 200, 1000, g_latS, g_latN, g_lonW, g_lonE, g_data3_path)
    var:=var(:,g_day_strt2:g_day_lst2,:,:,:)
    var2:=var2(:,g_day_strt2:g_day_lst2,:,:,:)
    var3:=var3(:,g_day_strt2:g_day_lst2,:,:,:)

    var_rmean= runave_n_Wrap(var, 3, 0, 1)
    ;var_rmean= var_data
    var_clim=dim_avg_n_Wrap(var_rmean, 0)
   
    var_cmp = var_rmean(0:g_special_cases-1,0:g_day_comp_len-1,:,:,:)
    
    ;Composite
    jj=0
    do ii=0,g_yr_len-1
        if (ii+1979) .eq. g_special_year(jj) then
            print("Year: "+g_special_year(jj))
            var_cmp(jj,:,:,:,:)=var_rmean(ii,g_day_rank(jj)-(g_day_comp_len-1)/2:g_day_rank(jj)+(g_day_comp_len-1)/2,:,:,:)
            jj=jj+1
            if jj .eq. g_special_cases
                break
            end if
        end if
    end do
    var_cmp:=dim_avg_n_Wrap(var_cmp,0)
    
    var_cmp:=wgt_areaave_Wrap(var_cmp(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
   ; Anomaly percentage
   ; var_cmp_mean=dim_avg_n_Wrap(var_cmp,0)
   ; var_cmp=100*dim_rmvmean_n_Wrap(var_cmp,0)/conform(var_cmp,var_cmp_mean,1)
   ; var_cmp=dim_standardize_n_Wrap(var_cmp,1,0)
    var_cmp:=var_cmp(level|:,time|:)
    var_cmp&time=ispan(-9,9,1)
    printVarSummary(var_cmp)

    ;var2_rmean= runave_n_Wrap(var2, 3, 0, 1)
    var2_rmean= var2
    var2_clim=dim_avg_n_Wrap(var2_rmean, 0)
   
    var2_cmp = var2_rmean(0:g_special_cases-1,0:g_day_comp_len-1,:,:,:)
    
    ;Composite
    jj=0
    do ii=0,g_yr_len-1
        if (ii+1979) .eq. g_special_year(jj) then
            print("Year: "+g_special_year(jj))
            var2_cmp(jj,:,:,:,:)=var2_rmean(ii,g_day_rank(jj)-(g_day_comp_len-1)/2:g_day_rank(jj)+(g_day_comp_len-1)/2,:,:,:)
            jj=jj+1
            if jj .eq. g_special_cases
                break
            end if
        end if
    end do
    var2_cmp:=dim_avg_n_Wrap(var2_cmp,0)
    
    var2_cmp:=wgt_areaave_Wrap(var2_cmp(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
   ; Anomaly percentage
   ; var2_cmp_mean=dim_avg_n_Wrap(var2_cmp,0)
   ; var2_cmp=100*dim_rmvmean_n_Wrap(var2_cmp,0)/conform(var2_cmp,var2_cmp_mean,1)
   ; var2_cmp=dim_standardize_n_Wrap(var2_cmp,1,0)
    var2_cmp:=var2_cmp(level|:,time|:)
    var2_cmp&time=ispan(-9,9,1)

    level=conform(var2_cmp, var2_cmp&level, 0)
    var_cmp=relhum(var2_cmp, var_cmp, level*100)
    
    
    var3_rmean= var3
    var3_clim=dim_avg_n_Wrap(var3_rmean, 0)
   
    var3_cmp = var3_rmean(0:g_special_cases-1,0:g_day_comp_len-1,:,:,:)
    
    ;Composite
    jj=0
    do ii=0,g_yr_len-1
        if (ii+1979) .eq. g_special_year(jj) then
            print("Year: "+g_special_year(jj))
            var3_cmp(jj,:,:,:,:)=var3_rmean(ii,g_day_rank(jj)-(g_day_comp_len-1)/2:g_day_rank(jj)+(g_day_comp_len-1)/2,:,:,:)
            jj=jj+1
            if jj .eq. g_special_cases
                break
            end if
        end if
    end do
    var3_cmp:=dim_avg_n_Wrap(var3_cmp,0)
    
    var3_cmp:=wgt_areaave_Wrap(var3_cmp(:,:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
   ; Anomaly percentage
   ; var3_cmp_mean=dim_avg_n_Wrap(var3_cmp,0)
   ; var3_cmp=100*dim_rmvmean_n_Wrap(var3_cmp,0)/conform(var3_cmp,var3_cmp_mean,1)
   ; var3_cmp=dim_standardize_n_Wrap(var3_cmp,1,0)
    var3_cmp:=var3_cmp(level|:,time|:)
    var3_cmp&time=ispan(-9,9,1)


; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/1/),graphic)
  plot_V = new((/1/),graphic)
  plot_cn_pos = new((/1/),graphic)
  plot_cn_neg = new((/1/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)
  wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
 
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
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
;  res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
;  res@cnMinLevelValF        = 0.006        ; set min contour level
;  res@cnMaxLevelValF        = 0.016         ; set max contour level
;  res@cnLevelSpacingF       = 0.0005        ; set contour interval
 ; res@cnFillColors =(/2,4,7,8,8,9,11,13/)
 res@vpWidthF = 0.5
 res@vpHeightF = 0.4



 
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
  res@tmXBValues = ispan(-9,9,1) ;interval
  res@tmXBLabels = ispan(-9,9,1)+" Day"         ;tick label
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
  res3@gsnLeftString      = "RH"
  res3@gsnRightString      = " "

  res4=res3
    delete(res4@cnLevels)
  res4@cnLevels = (/0./) 
  res4@cnLineColor="grey"
  res4@cnLineThicknessF = 6

;************************************************
; create panel
;************************************************
 plot_sh = gsn_csm_pres_hgt(wks, var_cmp, res )  
 plot_cn_pos = gsn_csm_pres_hgt(wks, var3_cmp, res3 )  
 plot_cn_neg = gsn_csm_pres_hgt(wks, var3_cmp, res4 )  
 overlay(plot_sh, plot_cn_pos)
 overlay(plot_sh, plot_cn_neg)
 draw(plot_sh)
 frame(wks)
end

