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
    
    ;SCS
    ;g_day_rank=(/135,140,150,155,145,140,150,135,160,145,160,140,160,140,150,125,135,130,140,140,150,135,130,135,145,140,150,140,145,125,150,145,130,140/)
    
    ;BOB
    
    g_strt_yr=1979
    g_lst_yr=2013
    g_yr_len = g_lst_yr-g_strt_yr+1
 

    ; U200 P20-28
    g_day_strt2=70
    g_day_lst2=160
    g_day_comp_len=19
    
    ;BOB All
    ;g_comp="all"
    ;g_special_year=ispan(g_strt_yr,g_lst_yr,1)
    ;g_day_rank=(/125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119,123/)-1

    
    ;BOB Early
    g_comp="early"
    g_special_year=(/1984, 1990, 1999, 2000, 2006, 2009/)
    g_day_rank=(/108, 105, 93, 100, 107, 99/)
    
    ;BOB Late
    ;g_comp="late"
    ;g_special_year=(/1980, 1981, 1982, 1983, 1985, 1992, 1993, 1997, 1998, 2010/)
    ;g_day_rank=(/136, 133, 134, 143, 136, 132, 134, 133, 132, 134/)

    g_day_rank= g_day_rank-g_day_strt2-1

    g_data4_path ="../data/obv/NCEP-DOE/daily/air1979-2013/air*"
    g_data3_path ="../data/obv/NCEP-DOE/daily/uwnd1979-2013/uwnd*"
    g_data2_path ="../data/obv/NCEP-DOE/daily/rh1979-2013/rhum*"
    g_data1_path ="/Users/zhenningli/data/obv/NCEP-DOE/hgt.sfc.nc"
    g_font = 0.035
    
        
    g_latS=10
    g_latN=15
    g_lonW=87.5
    g_lonE=100
    
    g_latSmp=10
    g_latNmp=15
    g_lonWmp=87.5
    g_lonEmp=100

    g_plevel=200
    g_plevel1=200
    g_plevel2=850
    g_fig_name = "../fig/obv/RH-vert-dbd-hov-before-after-"+g_comp+"-"+g_plevel+"-"+g_lonWmp+"-"+g_lonEmp
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(n)","(o)","(p)","(q)","(r)","(s)"/)
    
    g_fig_title = "Level-Time RH Distribution" 
    g_special_cases=dimsizes(g_special_year) 
;Prepare the variables

    ctrl_in1 = addfile(g_data1_path, "r")
    var1  = short2flt(ctrl_in1->hgt(0,{g_latS:g_latN},{g_lonW:g_lonE}))
    var1 = 1013.25*(1-var1*0.0065/288.15)^5.25145
    var1_line=dim_min_n_Wrap(var1,1)
    var1_line=dim_median_n(var1,1)
    
    
    ctrl_in2_files = systemfunc("ls "+g_data2_path)
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in2     = addfiles (ctrl_in2_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in2, "join")
    var2  =short2flt(ctrl_in2[:]->rhum(:,g_day_strt2:g_day_lst2,{:100},{g_latS:g_latN},{g_lonW:g_lonE}))
    var2_366  =short2flt(ctrl_in2[1::4]->rhum(:,g_day_strt2:g_day_lst2,{:100},{g_latS:g_latN},{g_lonW:g_lonE}))
    var2_dim = dimsizes(var2)
    var2_data = new((/g_yr_len,var2_dim(1),var2_dim(2),var2_dim(3),var2_dim(4)/),"float")
    copy_VarMeta(var2,var2_data)
   
    ; Merge normal and leap years 
    sp = 0
    do ii=0,g_yr_len-1
        if (mod((ii-1),4) .eq. 0) then
            var2_data(ii,:,:,:,:) = var2_366((ii-1)/4,:,:,:,:)
            sp=sp+1
        else
            var2_data(ii,:,:,:,:) = var2(ii-sp,:,:,:,:)
        end if
    end do
    
    ctrl_in3_files = systemfunc("ls "+g_data3_path)
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in3     = addfiles (ctrl_in3_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in3, "join")
    var3  =short2flt(ctrl_in3[:]->uwnd(:,g_day_strt2:g_day_lst2,{:100},{g_latS:g_latN},{g_lonW:g_lonE}))
    var3_366  =short2flt(ctrl_in3[1::4]->uwnd(:,g_day_strt2:g_day_lst2,{:100},{g_latS:g_latN},{g_lonW:g_lonE}))
    var3_dim = dimsizes(var3)
    var3_data = new((/g_yr_len,var3_dim(1),var3_dim(2),var3_dim(3),var3_dim(4)/),"float")
    copy_VarMeta(var3,var3_data)
   
    ; Merge normal and leap years 
    sp = 0
    do ii=0,g_yr_len-1
        if (mod((ii-1),4) .eq. 0) then
            var3_data(ii,:,:,:,:) = var3_366((ii-1)/4,:,:,:,:)
            sp=sp+1
        else
            var3_data(ii,:,:,:,:) = var3(ii-sp,:,:,:,:)
        end if
    end do

    ctrl_in4_files = systemfunc("ls "+g_data4_path)
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in4     = addfiles (ctrl_in4_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in4, "join")
    var4  =short2flt(ctrl_in4[:]->air(:,g_day_strt2:g_day_lst2,{:100},{g_latS:g_latN},{g_lonW:g_lonE}))
    var4_366  =short2flt(ctrl_in4[1::4]->air(:,g_day_strt2:g_day_lst2,{:100},{g_latS:g_latN},{g_lonW:g_lonE}))
    var4_dim = dimsizes(var4)
    var4_data = new((/g_yr_len,var4_dim(1),var4_dim(2),var4_dim(3),var4_dim(4)/),"float")
    copy_VarMeta(var4,var4_data)
   
    ; Merge normal and leap years 
    sp = 0
    do ii=0,g_yr_len-1
        if (mod((ii-1),4) .eq. 0) then
            var4_data(ii,:,:,:,:) = var4_366((ii-1)/4,:,:,:,:)
            sp=sp+1
        else
            var4_data(ii,:,:,:,:) = var4(ii-sp,:,:,:,:)
        end if
    end do
    var4_data=var4_data-273.15

    ;var2_rmean= runave_n_Wrap(var2_data, 3, 0, 1)
    ;var3_rmean= runave_n_Wrap(var3_data, 3, 0, 1)

    var2_rmean= var2_data
    var3_rmean= var3_data
    var4_rmean= var4_data
    delete([/var2, var3, var4, var2_data, var3_data, var4_data/])
    var2_clim=dim_avg_n_Wrap(var2_rmean, 0)
    var3_clim=dim_avg_n_Wrap(var3_rmean, 0)
    var4_clim=dim_avg_n_Wrap(var4_rmean, 0)
   
    var2_cmp = var2_rmean(0:g_special_cases-1,0:g_day_comp_len-1,:,:,:)
    var3_cmp = var3_rmean(0:g_special_cases-1,0:g_day_comp_len-1,:,:,:)
    var4_cmp = var4_rmean(0:g_special_cases-1,0:g_day_comp_len-1,:,:,:)
    jj=0
    do ii=0,g_yr_len-1
        if (ii+1979) .eq. g_special_year(jj) then
            print("Year: "+g_special_year(jj))
            var2_cmp(jj,:,:,:,:)=var2_rmean(ii,g_day_rank(jj)-(g_day_comp_len-1)/2:g_day_rank(jj)+(g_day_comp_len-1)/2,:,:,:)
           ; var2_cmp(jj,:,:,:,:)=var2_cmp(jj,:,:,:,:)-var2_clim(g_day_rank(jj)-g_day_comp_len+1:g_day_rank(jj),:,:,:)
            var3_cmp(jj,:,:,:,:)=var3_rmean(ii,g_day_rank(jj)-(g_day_comp_len-1)/2:g_day_rank(jj)+(g_day_comp_len-1)/2,:,:,:)
            var4_cmp(jj,:,:,:,:)=var4_rmean(ii,g_day_rank(jj)-(g_day_comp_len-1)/2:g_day_rank(jj)+(g_day_comp_len-1)/2,:,:,:)
           ; var3_cmp(jj,:,:,:,:)=var3_cmp(jj,:,:,:,:)-var3_clim(g_day_rank(jj)-g_day_comp_len+1:g_day_rank(jj),:,:,:)
           
            jj=jj+1
            if jj .eq. g_special_cases
                break
            end if
        end if
    end do
    var2_cmp:=dim_avg_n_Wrap(var2_cmp,0)
    var3_cmp:=dim_avg_n_Wrap(var3_cmp,0)
    var4_cmp:=dim_avg_n_Wrap(var4_cmp,0)
    
    var2_cmp:=wgt_areaave_Wrap(var2_cmp(:,:,{10:15},{87.5:100}),1.0,1.0,0)
    var2_cmp:=var2_cmp(level|:,time|:)
    printVarSummary(var2_cmp)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/1/),graphic)
  plot_V = new((/1/),graphic)
  plot_cn_max = new((/1/),graphic)
  plot_cn_max_pre = new((/1/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)
  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
 
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
 ;gsn_define_colormap(wks,"MPL_bwr")

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
 gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
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
 res@cnMinLevelValF        = 20         ; set min contour level
 res@cnMaxLevelValF        = 100         ; set max contour level
 res@cnLevelSpacingF       = 5         ; set contour interval
;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)
 ;res@vpWidthF = 0.7
 ;res@vpHeightF = 0.4



 
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
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
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
  res3@cnLevels = (/-5, 5./)
  res3@cnLineColor      = "Black"
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "

  res4=res3
  res4@cnLineColor="Grey"

;************************************************
; create panel
;************************************************
 plot_sh = gsn_csm_pres_hgt(wks, var2_cmp, res )  
 draw(plot_sh)
 frame(wks)
end

