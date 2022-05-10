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
;	var1--------------U (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_strt_yr=1979
    g_lst_yr=2013
    g_strt_mon=197901
    g_lst_mon=201312
    g_yr_len = g_lst_yr-g_strt_yr+1
    g_day_strt=100
    g_day_lst=144
    g_var_name1 = "r"
    g_data2_path ="../data/obv/NCEP-DOE/daily/omega1979-2013/"
    g_data3_path ="../data/obv/NCEP-DOE/daily/air1979-2013/"
    g_plvl =200
    g_font = 0.035
    
    g_latS=5.
    g_latN=15.
    g_lonW=85.
    g_lonE=120.


    ; create an array of desired pressure levels:
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)"/)
    g_fig_title   = ispan(21,29,1)+"p Temp+Omega"
    g_fig_name   = "../fig/obv/"+g_plvl+"Temp_omega_21-29p_Clim"


;Prepare the variables

    ctrl_in2_files = systemfunc("ls "+g_data2_path)
    ctrl_in3_files = systemfunc("ls "+g_data3_path)
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in2     = addfiles (g_data2_path+ctrl_in2_files, "r")   ; note the "s" of addfile
    ctrl_in3     = addfiles (g_data3_path+ctrl_in3_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in2, "join")
    ListSetType (ctrl_in3, "join")
    var2  =short2flt(ctrl_in2[:]->omega(:,g_day_strt:g_day_lst,{:g_plvl},{g_latS:g_latN},{g_lonW:g_lonE}))
    var3  =short2flt(ctrl_in3[:]->air(:,g_day_strt:g_day_lst,{:g_plvl},{g_latS:g_latN},{g_lonW:g_lonE}))
    var2_366  =short2flt(ctrl_in2[1::4]->omega(:,g_day_strt:g_day_lst,{:g_plvl},{g_latS:g_latN},{g_lonW:g_lonE}))
    var3_366  =short2flt(ctrl_in3[1::4]->air(:,g_day_strt:g_day_lst,{:g_plvl},{g_latS:g_latN},{g_lonW:g_lonE}))
    var2_dim = dimsizes(var2)
    var2_data = new((/g_yr_len,var2_dim(1),var2_dim(2),var2_dim(3),var2_dim(4)/),"float")
    var3_data = new((/g_yr_len,var2_dim(1),var2_dim(2),var2_dim(3),var2_dim(4)/),"float")
    copy_VarMeta(var2,var2_data)
    copy_VarMeta(var3,var3_data)
    sp = 0
    do ii=0,g_yr_len-1
        if (mod((ii-1),4) .eq. 0) then
            var2_data(ii,:,:,:,:) = var2_366((ii-1)/4,:,:,:,:)
            var3_data(ii,:,:,:,:) = var3_366((ii-1)/4,:,:,:,:)
            sp=sp+1
        else
            var2_data(ii,:,:,:,:) = var2(ii-sp,:,:,:,:)
            var3_data(ii,:,:,:,:) = var3(ii-sp,:,:,:,:)
        end if
    end do
    var2_data_clim=dim_avg_n_Wrap(var2_data,0)
    var3_data_clim=dim_avg_n_Wrap(var3_data,0)
    var2_data_clim:=dim_avg_n_Wrap(var2_data_clim,2)
    var2_data_clim=-var2_data_clim
    var3_data_clim:=dim_avg_n_Wrap(var3_data_clim,2)
    var3_data_clim=dim_rmvmean_n_Wrap(var3_data_clim,2)
    ; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================
;---Create plot
 wks   = gsn_open_wks ("eps", g_fig_name )        ; send graphics to PNG file

 plot_sh = new((/9/),graphic)
 res                 = True                     ; plot mods desired
 ;res@tiMainString    = "Pressure/Height Vector" ; title

 res@gsnFrame         = False
 res@gsnDraw  = False

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = -1.0         ; set min contour level
 res@cnMaxLevelValF        = 1.0          ; set max contour level
 res@cnLevelSpacingF       = 0.1         ; set contour interval

 res@cnInfoLabelOn = False
 res@cnLineLabelsOn  = False                ; turn off line labels
 res@cnLinesOn  = False                ; turn off line labels
 res@cnFillOn        = True                 ; turn on color fill
 res@cnFillPalette   = "temp_19lev"  ; choose color map

 res@lbLabelStride   = 2                    ; every other color

 res@vcRefMagnitudeF = 0.05                ; define vector ref mag
 res@vcRefLengthF    = 0.045              ; define length of vec ref
 res@vcGlyphStyle    = "CurlyVector"      ; turn on curly vectors
 res@vcMinDistanceF  = 0.01               ; thin out vectors
 res@vcMapDirection  = False
 
    res@vcRefAnnoOn      = True
  ;  res@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
    res@vcRefAnnoString1  = "0.05 Pa/s"
    res@vcRefAnnoString2  = "Vertical Velocity"
    res@vcRefAnnoFontHeightF = 0.02

    res@vcLineArrowThicknessF     = 2.0    ;thickness of vector
    res@vcLineArrowHeadMinSizeF   = 0.01
    res@vcLineArrowHeadMaxSizeF   = 0.01

    res@gsnStringFontHeightF = g_font

  res@gsnPaperOrientation = "portrait"

  res@lbLabelBarOn = False   ; turn off the label bar
   
  res@tmXBTickSpacingF = 10
  res@tmXBLabelFontHeightF = g_font
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
  res@tmYLLabelFontThicknessF = 2.0
;-----------------------------------------------------------------------------
     
  res@gsnLeftString = ""
  res@gsnRightString = ""
 
;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
; resP@gsnPanelMainString = "A plot with a common label bar"
                                                 ; use this for NCL V6.3.0 and earlier
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.015               ; make labels smaller 
 
 do ii=0,8
    res@gsnLeftString = g_fig_rank(ii)
    res@gsnCenterString = g_fig_title(ii)
    var2_data_clim_pt=dim_avg_n_Wrap(var2_data_clim(ii*5:ii*5+4,:,:),0)
    var3_data_clim_pt=dim_avg_n_Wrap(var3_data_clim(ii*5:ii*5+4,:,:),0)
    var4_data_clim_pt=var3_data_clim_pt
    var4_data_clim_pt=0
    plot_sh(ii)  = gsn_csm_pres_hgt_vector(wks,var3_data_clim_pt,var4_data_clim_pt,var2_data_clim_pt,res )  
  end do
  gsn_panel(wks,plot_sh,(/3,3/),resP)

  draw(plot_sh)
  frame(wks)

end


