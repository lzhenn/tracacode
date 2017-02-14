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
    ;g_day_rank=(/125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119,123/)-1
    
    ;BOB Early
   ; g_special_year=(/1984, 1990, 1999, 2000, 2006, 2009/)
   ; g_day_rank=(/108, 105, 93, 100, 107, 99/)-1
    
    ;BOB Late
    g_special_year=(/1980, 1981, 1982, 1983, 1985, 1992, 1993, 1997, 1998, 2010/)
    g_day_rank=(/136, 133, 134, 143, 136, 132, 134, 133, 132, 134/)-1

    
    g_special_cases=dimsizes(g_special_year) 

    g_strt_yr=1979
    g_lst_yr=2013
    g_yr_len = g_lst_yr-g_strt_yr+1
 

    ; U200 P20-28
    g_day_strt2=0
    g_day_lst2=364
    g_day_comp_len=16

    g_var_name1 = "r"
    g_data2_path ="../data/obv/NCEP-DOE/daily/uwnd1979-2013/uwnd*"
    g_data1_path ="/Users/zhenningli/data/obv/NCEP-DOE/hgt.sfc.nc"
    g_font = 0.035
    
        
    g_latS=-10
    g_latN=45
    g_lonW=75
    g_lonE=95
    
    g_fig_name = "../fig/obv/U-sec-dbd-late-170213-"+g_lonW+"-"+g_lonE
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(n)","(o)","(p)","(q)","(r)","(s)"/)
    
    day_rank=ispan(0,g_day_comp_len-1,1)
    day_rank=day_rank(::-1)
    g_fig_title = "-"+day_rank+" Days "+g_lonW+"-"+g_lonE

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
    var2  =short2flt(ctrl_in2[:]->uwnd(:,g_day_strt2:g_day_lst2,{:100},{g_latS:g_latN},{g_lonW:g_lonE}))
    var2_366  =short2flt(ctrl_in2[1::4]->uwnd(:,g_day_strt2:g_day_lst2,{:100},{g_latS:g_latN},{g_lonW:g_lonE}))
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
    
    var2_rmean= runave_n_Wrap(var2_data, 3, 0, 1)
    var2_clim=dim_avg_n_Wrap(var2_rmean,0)
    ;var2_rmean=var2_rmean-conform(var2_rmean, var2_clim, (/1,2,3,4/))   

    var2_cmp_mx = var2_rmean(0:g_special_cases-1,0:g_day_comp_len-1,:,:,:)
    jj=0
    do ii=0,g_yr_len-1
        if (ii+1979) .eq. g_special_year(jj) then
            print("Year: "+g_special_year(jj))
            var2_cmp_mx(jj,:,:,:,:)=var2_rmean(ii,g_day_rank(jj)-g_day_comp_len+1:g_day_rank(jj),:,:,:)
            jj=jj+1
            if jj .eq. g_special_cases
                break
            end if
        end if
    end do
    
    var2_cmp=dim_avg_n_Wrap(var2_cmp_mx,0)
    var2_cmp:=dim_avg_n_Wrap(var2_cmp, 3)
    ;; Determine the terrain
    topo2d = conform(var2_cmp,var1_line,2)
    high2d = conform(var2_cmp,var2_cmp&level,1)
    var2_cmp = (/mask(var2_cmp,high2d .gt. topo2d,False)/)
    var2_clim_data = dim_avg_n_Wrap(var2_cmp,0)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/g_day_comp_len/),graphic)
  plot_cn_max = new((/g_day_comp_len/),graphic)
  plot_cn_max_pre = new((/g_day_comp_len/),graphic)
  plot_cn_zero = new((/g_day_comp_len/),graphic)
  plot_cn_zero_pre = new((/g_day_comp_len/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
 gsn_define_colormap(wks,"NCV_jaisnd")
; gsn_define_colormap(wks,"NCV_jaisnd")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options
  res@gsnFrame         = False
  res@gsnDraw  = False
 
  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels


  res@tmYRMode = "Automatic"
 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -30         ; set min contour level
 res@cnMaxLevelValF        = 30         ; set max contour level
 res@cnLevelSpacingF       = 4        ; set contour interval
;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)
 res@vpWidthF = 0.7
 res@vpHeightF = 0.4
 res@cnMissingValFillColor="black"


 
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

;  res@gsnMaximize      = True       ; fill up the page
;  res@gsnAddCyclic   = True;False
;  res@gsnPaperOrientation = "portrait"
;  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


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
  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 6 
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLineColor      = "black"
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "



  ; present zero u line
  res4=res3
  res4@cnLineColor = "black"
  res4@cnLineThicknessF = 3
  res4@cnLevels=(/0./)

  ; previous jet core
  res5=res3
  res5@cnLineColor="grey"

  ; previous zero u line
  res6=res4
  res6@cnLineColor = "grey"

do ii=0,g_day_comp_len-1
    res@gsnRightString=""
    res@gsnLeftString=g_fig_rank(ii)
    res@gsnCenterString=g_fig_title(ii)

    var2_core=max(var2_cmp(ii,:,:))

    res3@cnLevels = (/var2_core-0.01/)
    plot(ii) = gsn_csm_pres_hgt(wks, var2_cmp(ii,:,:), res ) 
    plot_cn_max(ii) = gsn_csm_contour(wks,var2_cmp(ii,:,:),res3)

    plot_cn_zero(ii) = gsn_csm_contour(wks,var2_cmp(ii,:,:),res4)
    if ii .gt.0 then
        plot_cn_max_pre(ii) = gsn_csm_contour(wks,var2_cmp(ii-1,:,:),res5)
        plot_cn_zero_pre(ii) = gsn_csm_contour(wks,var2_cmp(ii-1,:,:),res6)
        overlay(plot(ii),plot_cn_max_pre(ii))
        overlay(plot(ii),plot_cn_zero_pre(ii))
    end if
 
    overlay(plot(ii),plot_cn_max(ii))
    overlay(plot(ii),plot_cn_zero(ii))
   res5@cnLevels = res3@cnLevels 
  end do
  gsn_panel(wks,plot,(/4,4/),False)

end

