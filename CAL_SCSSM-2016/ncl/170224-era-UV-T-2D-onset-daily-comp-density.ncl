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

    g_data3_path ="$DATAOBV/ERA-interim/pressure/v/*"
    g_data2_path ="$DATAOBV/ERA-interim/pressure/u/*"
    g_data1_path ="$DATAOBV/ERA-interim/pressure/air/*"
    g_font = 0.035
    
        
    g_latS=0
    g_latN=30
    g_lonW=70
    g_lonE=120
    
    g_latSmp=0
    g_latNmp=30
    g_lonWmp=70
    g_lonEmp=120

    g_plevel=700
    g_fig_name = "../fig/obv/ERA-UV-2D-dbd-before-after-"+g_comp+"-"+g_plevel+"-"+g_lonWmp+"-"+g_lonEmp
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(n)","(o)","(p)","(q)","(r)","(s)"/)
    
    ;day_rank=ispan(0,g_day_comp_len-1,1)
    ;day_rank=day_rank(::-1)
    g_fig_title = (/"-9","-6","-3","0","+3","+6","+9"/)+" Day "+g_lonWmp+"-"+g_lonEmp

    g_special_cases=dimsizes(g_special_year) 

    var1_data=read_era_daily_3D("air", 200, 1000, g_latS, g_latN, g_lonW, g_lonE, g_data1_path) 
    var2_data=read_era_daily_3D("uwnd", 200, 1000, g_latS, g_latN, g_lonW, g_lonE, g_data2_path) 
    var3_data=read_era_daily_3D("vwnd", 200, 1000, g_latS, g_latN, g_lonW, g_lonE, g_data3_path) 
    var1_data:=var1_data(:,g_day_strt2:g_day_lst2,:,:,:)
    var2_data:=var2_data(:,g_day_strt2:g_day_lst2,:,:,:)
    var3_data:=var3_data(:,g_day_strt2:g_day_lst2,:,:,:)


;Prepare the variables
    var1_rmean= var1_data
    var2_rmean= var2_data
    var3_rmean= var3_data
    var1_clim=dim_avg_n_Wrap(var1_rmean, 0)
    var2_clim=dim_avg_n_Wrap(var2_rmean, 0)
    var3_clim=dim_avg_n_Wrap(var3_rmean, 0)
    
    var1_cmp = var1_rmean(0:g_special_cases-1,0:g_day_comp_len-1,:,:,:)
    var2_cmp = var2_rmean(0:g_special_cases-1,0:g_day_comp_len-1,:,:,:)
    var3_cmp = var3_rmean(0:g_special_cases-1,0:g_day_comp_len-1,:,:,:)
    jj=0
    do ii=0,g_yr_len-1
        if (ii+1979) .eq. g_special_year(jj) then
            print("Year: "+g_special_year(jj))
            var1_cmp(jj,:,:,:,:)=var1_rmean(ii,g_day_rank(jj)-(g_day_comp_len-1)/2:g_day_rank(jj)+(g_day_comp_len-1)/2,:,:,:)
            var2_cmp(jj,:,:,:,:)=var2_rmean(ii,g_day_rank(jj)-(g_day_comp_len-1)/2:g_day_rank(jj)+(g_day_comp_len-1)/2,:,:,:)
           ; var2_cmp(jj,:,:,:,:)=var2_cmp(jj,:,:,:,:)-var2_clim(g_day_rank(jj)-g_day_comp_len+1:g_day_rank(jj),:,:,:)
            var3_cmp(jj,:,:,:,:)=var3_rmean(ii,g_day_rank(jj)-(g_day_comp_len-1)/2:g_day_rank(jj)+(g_day_comp_len-1)/2,:,:,:)
           ; var3_cmp(jj,:,:,:,:)=var3_cmp(jj,:,:,:,:)-var3_clim(g_day_rank(jj)-g_day_comp_len+1:g_day_rank(jj),:,:,:)
           
            jj=jj+1
            if jj .eq. g_special_cases
                break
            end if
        end if
    end do
    var1_cmp:=dim_avg_n_Wrap(var1_cmp,0)
    var1_cmp=var1_cmp-273.15
    var2_cmp:=dim_avg_n_Wrap(var2_cmp,0)
    var3_cmp:=dim_avg_n_Wrap(var3_cmp,0)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/g_day_comp_len/),graphic)
  plot_V = new((/g_day_comp_len/),graphic)
  plot_cn_max = new((/g_day_comp_len/),graphic)
  plot_cn_max_pre = new((/g_day_comp_len/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)
  wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
 
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")


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

; res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
; res@cnMinLevelValF        = -20         ; set min contour level
; res@cnMaxLevelValF        = 20          ; set max contour level
; res@cnLevelSpacingF       = 1          ; set contour interval

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
  res@mpMaxLatF  = g_latNmp
  res@mpMinLatF  = g_latSmp
  res@mpMaxLonF  = g_lonEmp
  res@mpMinLonF  = g_lonWmp

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
  vcres@vcRefMagnitudeF         = 8.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.03
  vcres@vcRefAnnoString1  = "8 m/s"
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
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 4 
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/0./)
  res3@cnLineColor      = "Black"
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "

  res4=res3
  res4@cnLineColor="Grey"

;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
; resP@gsnPanelMainString = "A plot with a common label bar"
                                                 ; use this for NCL V6.3.0 and earlier
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.015               ; make labels smaller 
  do ii=0,g_day_comp_len-1
    if mod(ii,3) .eq. 0
        jj=ii/3
        res@gsnRightString=""
        res@gsnLeftString=g_fig_rank(jj)
        res@gsnCenterString=g_fig_title(jj)
        plot_cn_max(jj) = gsn_csm_contour(wks,var2_cmp(ii,{g_plevel},:,:),res3)

        plot_V(jj) = gsn_csm_vector(wks,var2_cmp(ii,{g_plevel},:,:),var3_cmp(ii,{g_plevel},:,:),vcres) 
        plot_sh(jj) = gsn_csm_contour_map(wks,var1_cmp(ii,{g_plevel},:,:), res) 
        overlay(plot_sh(jj),plot_V(jj))
        if jj .gt. 0 then
            plot_cn_max_pre(jj) = gsn_csm_contour(wks,var2_cmp(ii-3,{g_plevel},:,:),res4)
            overlay(plot_sh(jj),plot_cn_max_pre(jj))
        end if
        overlay(plot_sh(jj),plot_cn_max(jj))
    end if
  end do
  gsn_panel(wks,plot_sh,(/2,4/),resP)

end

