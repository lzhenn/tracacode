;*************************************************************
;Aim: draw TS monthly change ratio 
;   R=((T/2)*tr(TSapr))/clim(TSmay-TSapr))
;
;Mission:
;   1. Read data from GISS-LOT data
;   2. Post-post process
;     2.1 take the trend of a specific month
;     2.2 caculate the trend of 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-05-07
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN
;   2015-04-20  Change to caculate SST trend
;   2015-05-07  Change to caculate TS change trend
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------TS
;================================================
;global variables
    ;Define parameters
    g_data_path = "/home/yangsong3/data-observation/SST/HadISST/HadISST_sst.nc"

    g_data_path2="/home/yangsong3/data/observation/NCEP_NCAR/monthly/uwnd.mon.mean.nc"
    g_data_path3="/home/yangsong3/data/observation/NCEP_NCAR/monthly/vwnd.mon.mean.nc"

    ;Fig region
    g_figlatS=-30
    g_figlatN=50
    g_figlonE=30
    g_figlonW=300

    ;Nino 3
    g_latS=-5.
    g_latN=5.
    g_lonW=210.
    g_lonE=270.

    ; Central
    g_clatS=-10.
    g_clatN=10.
    g_clonW=165.
    g_clonE=220.
    
    ; Eastern
    g_elatS=-15.
    g_elatN=5.
    g_elonW=250.
    g_elonE=290.
    
    
    ; Western 
    g_wlatS=-10.
    g_wlatN=20.
    g_wlonW=125.
    g_wlonE=145.
    
    
    
    
    g_season_rank0=(/"JJA", "SON"/)
    g_season_rank=(/"DJF", "MAM", "JJA"/)
; create an array of desired pressure levels:

        
    g_font = 0.018

    g_strt_mon = 197901 
    g_lst_mon = 201712
    g_fig_name    =   "../fig/yuan-2012-replot-left"
    g_fig_rank    =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    g_fig_title     = " PCOR ("+(/"JJA", "SON", "DJF", "MAM1", "JJA1"/)+" SSTA & Wind850, DJF Nino3)"


;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path
	ctrl_file2   = g_data_path2
	ctrl_file3   = g_data_path3
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    time_uv      = ctrl_in2->time
    yyyymm  = cd_calendar(time_hist,-1)
    yyyymm_uv=cd_calendar(time_uv,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
    istrt_uv   = ind(yyyymm_uv .eq. g_strt_mon)
    ilast_uv   = ind(yyyymm_uv .eq. g_lst_mon)
	var1  =ctrl_in1->sst(istrt:ilast,:,:)			; p for unify the var name
	var2  =ctrl_in2->uwnd(istrt_uv:ilast_uv,{850},:,:)			; p for unify the var name
	var3  =ctrl_in3->vwnd(istrt_uv:ilast_uv,{850},:,:)			; p for unify the var name
    var1_temp=var1
    var1(:,:,{-179.5:-0.5})=(/var1(:,:,{0.5:179.5})/)
    var1(:,:,{0.5:179.5})=(/var1_temp(:,:,{-179.5:-0.5})/)
    delete(var1_temp)
    var1&longitude=fspan(0.5,359.5,360)

    var1_djf=month_to_season(var1,"DJF")
    nino3=wgt_areaave_Wrap(var1_djf(:,{g_latS:g_latN},{g_lonW:g_lonE}), 1.0, 1.0, 0)
    w_p=wgt_areaave_Wrap(var1_djf(:,{g_wlatS:g_wlatN},{g_wlonW:g_wlonE}), 1.0, 1.0, 0)
    c_p=wgt_areaave_Wrap(var1_djf(:,{g_clatS:g_clatN},{g_clonW:g_clonE}), 1.0, 1.0, 0)
    e_p=wgt_areaave_Wrap(var1_djf(:,{g_elatS:g_elatN},{g_elonW:g_elonE}), 1.0, 1.0, 0)

    emi=w_p
    emi=c_p-0.5*e_p-0.5*w_p
    ;   sst     --- 1
    ;   nino3   --- 2
    ;   emi     --- 3
    
    pr12_3=var1_djf(0:4,:,:)
    pr12_3_u=var2(0:4,:,:)
    pr12_3_v=var3(0:4,:,:)
    psig = 0.05
    r23_temp=escorc(emi,nino3)
    r23=pr12_3(0,:,:)
    r23=(/r23_temp/)

    r23_uv=pr12_3_u(0,:,:)
    r23_uv=(/r23_temp/)
    years=dimsizes(nino3)

    ; JJA SON
    do ii = 0, 1
        var1_ssntemp=month_to_season(var1,g_season_rank0(ii))
        var1_ssn:=var1_ssntemp(latitude|:,longitude|:,time|:)
        var1_ssn:=var1_ssn(:,:,0:years-2)

        var2_ssntemp=month_to_season(var2,g_season_rank0(ii))
        var2_ssn:=var2_ssntemp(lat|:,lon|:,time|:)
        var2_ssn:=var2_ssn(:,:,0:years-2)
        var3_ssntemp=month_to_season(var3,g_season_rank0(ii))
        var3_ssn:=var3_ssntemp(lat|:,lon|:,time|:)
        var3_ssn:=var3_ssn(:,:,0:years-2)
 
        r12=escorc(nino3(1:),var1_ssn)
        r13=escorc(emi(1:),var1_ssn)
        pr12_3(ii,:,:)=(/(r12-r13*r23)/(sqrt(1-r13*r13)*sqrt(1-r23*r23))/)

        r12_u=escorc(nino3(1:),var2_ssn)
        r13_u=escorc(emi(1:),var2_ssn)
        pr12_3_u(ii,:,:)=(/(r12_u-r13_u*r23_uv)/(sqrt(1-r13_u*r13_u)*sqrt(1-r23_uv*r23_uv))/)
        
        r12_v=escorc(nino3(1:),var3_ssn)
        r13_v=escorc(emi(1:),var3_ssn)
        pr12_3_v(ii,:,:)=(/(r12_v-r13_v*r23_uv)/(sqrt(1-r13_v*r13_v)*sqrt(1-r23_uv*r23_uv))/)
        ; significance test
        n = years-1 
        df= n-1-2
        t=pr12_3(ii,:,:)*sqrt(df)/sqrt(1-pr12_3(ii,:,:)*pr12_3(ii,:,:))
        t_u=pr12_3_u(ii,:,:)*sqrt(df)/sqrt(1-pr12_3_u(ii,:,:)*pr12_3_u(ii,:,:))
        t_v=pr12_3_v(ii,:,:)*sqrt(df)/sqrt(1-pr12_3_v(ii,:,:)*pr12_3_v(ii,:,:))
        p=student_t(t,df)
        p_u=student_t(t_u,df)
        p_v=student_t(t_v,df)
        pr12_3(ii,:,:)=where(p .le. psig, pr12_3(ii,:,:), pr12_3@_FillValue)
        pr12_3_u(ii,:,:)=where((p_u .le. psig .or. p_v .le. psig), pr12_3_u(ii,:,:), pr12_3_u@_FillValue)
    end do



    ; DJF MAM1 JJA1
    do ii = 0, dimsizes(g_season_rank)-1
        var1_ssn:=month_to_season(var1,g_season_rank(ii))
        var2_ssn:=month_to_season(var2,g_season_rank(ii))
        var3_ssn:=month_to_season(var3,g_season_rank(ii))
        
        r12=escorc(nino3,var1_ssn(latitude|:,longitude|:,time|:))
        r13=escorc(emi,var1_ssn(latitude|:,longitude|:,time|:))
        pr12_3(ii+2,:,:)=(/(r12-r13*r23)/(sqrt(1-r13*r13)*sqrt(1-r23*r23))/)

        r12_u=escorc(nino3,var2_ssn(lat|:,lon|:,time|:))
        r13_u=escorc(emi,var2_ssn(lat|:,lon|:,time|:))
        pr12_3_u(ii+2,:,:)=(/(r12_u-r13_u*r23_uv)/(sqrt(1-r13_u*r13_u)*sqrt(1-r23_uv*r23_uv))/)
        
        r12_v=escorc(nino3,var3_ssn(lat|:,lon|:,time|:))
        r13_v=escorc(emi,var3_ssn(lat|:,lon|:,time|:))
        pr12_3_v(ii+2,:,:)=(/(r12_v-r13_v*r23_uv)/(sqrt(1-r13_v*r13_v)*sqrt(1-r23_uv*r23_uv))/)
        
        ; significance test
        n = years
        df= n-1-2
        t=pr12_3(ii+2,:,:)*sqrt(df)/sqrt(1-pr12_3(ii+2,:,:)*pr12_3(ii+2,:,:))
        t_u=pr12_3_u(ii+2,:,:)*sqrt(df)/sqrt(1-pr12_3_u(ii+2,:,:)*pr12_3_u(ii+2,:,:))
        t_v=pr12_3_v(ii+2,:,:)*sqrt(df)/sqrt(1-pr12_3_v(ii+2,:,:)*pr12_3_v(ii+2,:,:))
        
        p=student_t(t,df)
        p_u=student_t(t_u,df)
        p_v=student_t(t_v,df)
        pr12_3(ii+2,:,:)=where(p .le. psig, pr12_3(ii+2,:,:), pr12_3@_FillValue)
        pr12_3_u(ii+2,:,:)=where(p_u .le. psig .or. p_v .le. psig, pr12_3_u(ii+2,:,:), pr12_3_u@_FillValue)
    end do

; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/5/),graphic)
  plot_V = new((/5/),graphic)
;  plot_tp = new((/2/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks","Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
 gsn_define_colormap(wks,"temp_diff_18lev")


;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



 ; i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
 ; j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
  res@cnLevels = (/-0.45,-0.35,0.35,0.45/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

; res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
; res@cnMinLevelValF        = -1.          ; set min contour level
; res@cnMaxLevelValF        = 1.          ; set max contour level
; res@cnLevelSpacingF       = 0.05         ; set contour interval

  res@cnFillColors =(/5,8,10,12,15/)


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


  res@lbLabelBarOn = False   ; turn off the label bar
  res@lbOrientation          = "horizontal"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1

  res@mpFillOn   = False     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
  res@mpCenterLonF = 180.
  res@mpMaxLatF  = g_figlatN
  res@mpMinLatF  = g_figlatS
  res@mpMaxLonF  = g_figlonW
  res@mpMinLonF  = g_figlonE

  res@tmYLMajorLengthF=0.01
  res@tmXBMajorLengthF=0.01
  res@tmYROn = False
  res@tmXTOn = False
  res@tmYLTickSpacingF=10
  res@tmYLMinorOn = False
  res@tmXBMinorOn = False
  res@tmXBLabelFontHeightF = g_font
  res@tmYLLabelFontHeightF = g_font

;-----------------------------------------------------------------------------
          
  vcres = True
  vcres@gsnDraw          = False           ; don't draw
  vcres@gsnFrame         = False           ; don't advance frame
  vcres@gsnRightString   = " "             ; turn off right string
  vcres@gsnLeftString    = " "             ; turn off left string
  vcres@gsnCenterString    = " "
 
  vcres@vcRefAnnoOn      = True
  vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
  vcres@vcRefMagnitudeF         = 1.0             ; define vector ref mag
  vcres@vcRefLengthF            = 0.04            ; define length of vec ref
  vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
  vcres@vcMinDistanceF          = 0.015
  vcres@vcRefAnnoString1  = "1 m/s"
  vcres@vcRefAnnoString2  = ""
  vcres@vcRefAnnoFontHeightF = 0.012
 
  vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
;  vcres@vcLineArrowHeadMinSizeF   = 0.010
;  vcres@vcLineArrowHeadMaxSizeF   = 0.130
;--------------------------------------


do i = 0,4
    res@gsnLeftString = g_fig_rank(i)
    res@gsnCenterString = g_fig_title(i)
    res@gsnRightString = ""
    plot(i) = gsn_csm_contour_map_ce(wks,pr12_3(i,:,:),res) ; create a default plot
    plot_V(i) = gsn_csm_vector(wks,pr12_3_u(i,:,:),pr12_3_v(i,:,:),vcres)
    overlay(plot(i),plot_V(i))
end do





  ;plot_V(1) = gsn_csm_vector(wks,cp_diff_var1,cp_diff_var2,vcres)

;  plot_sh(0) = gsn_csm_contour(wks,diff_var3_sig,res4)

  ;plot_sh(1) = gsn_csm_contour(wks,cp_diff_var3_sig,res4)

  ;overlay(plot(1),plot_sh(1))

  ;overlay(plot(0),plot_V(0))
  ;overlay(plot(1),plot_V(1))
  pres= True 
  pres@gsnPanelLabelBar   = True      ;Universial colorbar
  pres@lbLabelFontHeightF = 0.012

  gsn_panel(wks,plot,(/5,1/),pres)

end 
