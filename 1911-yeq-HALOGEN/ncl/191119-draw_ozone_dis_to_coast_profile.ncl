;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/disk/hq247/yhuangci/resource/ncl-resource/cnmap-zhenning/cnmap.ncl"
;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
        
    mon="oct"
    name="(d) Oct"
    type="with"
    g_font=0.015
    
    g_fig_name="profile-dis-coast_"+mon

    ;File IO
    ocean_fn=addfile("dis_to_coast_27km.nc","r")
    dis_coast=ocean_fn->dis_to_coast
    dis_coast=where(dis_coast .eq. 999, 0, dis_coast) 
    dis_coast=dis_coast*27  ;convert to km

    ;File IO
    pdata_fn  =systemfunc("ls ../../../data/cmaq/with/"+mon+"/COMBINE_CCTM_ACONC_27km_2016*") 
    ctrl_in = addfiles(pdata_fn ,"r")  ; open output netCDF file
    ;var1_with = ctrl_in[:]->O3(0,0:18,:,:)
    var1_with = ctrl_in[:]->O3(:,0:18,:,:)
    var1_with:=dim_avg_n_Wrap(var1_with,0)

    pdata_fn  =systemfunc("ls ../../../data/cmaq/without/"+mon+"/COMBINE_CCTM_ACONC_27km_2016*") 
    ctrl_in = addfiles(pdata_fn ,"r")  ; open output netCDF file
    ;var1_without = ctrl_in[:]->O3(0,0:18,:,:)
    var1_without = ctrl_in[:]->O3(:,0:18,:,:)
    var1_without:=dim_avg_n_Wrap(var1_without,0)
    
    var1_diff_surf=var1_with(0,:,:)

    ;layer 19, ~1500m
    height = var1_with
    height_fn = systemfunc("ls /disk/v092.yhuangci/halogen_output/mcip_dir/"+mon+"/METCRO3D.27km.2016*")
    height_in = addfiles(height_fn ,"r")  ; open output netCDF file
    height = height_in[:]->ZF(0,0:18,:,:)
    height := wgt_areaave(height,1.0,1.0,0)   
    ;calc diff
    var1_diff=var1_with
    var1_diff=(/var1_with-var1_without/)*1000
    

    dis_1d=ndtooned(dis_coast)
    var1_1d_by_dis=new((/19,dimsizes(dis_1d)/),"float")

    ;-------below take bins, cal bin mean and stddev----------
    rank_ascend=dim_pqsort(dis_1d,2)
    nends=150
    dis_range=fspan(dis_1d(0),dis_1d(dimsizes(dis_1d)-1),nends)
    dis_center=new(nends-1, "float")
    bin_var1=new((/19,nends-1/),"float")
    bin_nvar1=new(nends-1,"float")

    tmp_avg=var1_diff(:,0,0) ; individual bin avg
    tmp_avg=0.
    bin_nsmp=0      ; sub n samples in individual bin
    acc_count=0     ; total count in dis_1d
    ;print(dis_range)
    do ii=0,nends-2
        do while (.not.(dis_1d(acc_count) .gt.dis_range(ii+1)))
            ind2d=ind_resolve(rank_ascend(acc_count),dimsizes(var1_diff_surf)); ind2d(0,0)-->var1(:,x,:), ind2d(0,1)-->var1(:,:,y)
            indx=ind2d(0,0)
            indy=ind2d(0,1)
            tmp_avg=tmp_avg+var1_diff(:,indx,indy)
            acc_count=acc_count+1
            bin_nsmp=bin_nsmp+1
            if (acc_count .gt. dimsizes(dis_1d)-1) then
                break
            end if
        end do
        tmp_avg=tmp_avg/bin_nsmp
        bin_nvar1(ii)=bin_nsmp
        bin_var1(:,ii)=tmp_avg
        dis_center(ii)=(dis_range(ii)+dis_range(ii+1))/2
        bin_nsmp=0
        tmp_avg=0
        tmp_avg_surf=0
    end do


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
 
; gsn_define_colormap(wks,"BlRe")
; gsn_define_colormap(wks,"GMT_ocean")

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
 gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
 gsn_reverse_colormap(wks)

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
  res@cnMinLevelValF        = -8        ; set min contour level
  res@cnMaxLevelValF        = 0        ; set max contour level
  res@cnLevelSpacingF       = 0.25       ; set contour interval
; res@cnFillColors =(/2,4,7,8,8,9,11,13/)
  res@vpWidthF = 0.78
  res@vpHeightF = 0.28

  ;res@gsnYAxisIrregular2Linear=True
 
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  res@gsnMaximize      = True       ; fill up the page
;  res@gsnAddCyclic   = True;False
;  res@gsnPaperOrientation = "portrait"
  res@cnFillMode="CellFill"
  res@tiYAxisString=""
  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  res@lbBoxLinesOn=False
 res@lbLabelStride = 4
; res@tmYLMajorOutwardLengthF=0
 res@tmYLMajorLengthF=0.005
 res@tmXBMajorLengthF=0.005
  res@tmXBMinorOn=False
  
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = g_font
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = g_font
; res@tmYLLabelFontQuality =

  ;---Set some axis labels, otherwise all we'll get is "10^3".
  res@tmYLMode              = "Explicit"
  res@tmYLValues            = ispan(0,18,2)

  res@tmYLLabels            =floor( height(::-2))

;---Set some axis labels, otherwise all we'll get is "10^3".
  res@tmXBMode              = "Explicit"
  res@tmXBValues            = (/13,30,47,63,80,97,114, 130,147/) 
  res@tmXBLabels            = ispan(-2500, 1500, 500) 

;--
;-----------------------------------------------------------------------------
     
  res@gsnLeftString = name
;  res@gsnCenterString = "Obv theta-e and RH"
  res@gsnRightString = "Ozone Diff"
       
 res@tiYAxisFontHeightF = g_font
 res@tiXAxisFontHeightF = g_font
 res@tiYAxisString = "Height (m)"
 res@tiXAxisString = "Distance (km)"
;************************************************
; create panel
;************************************************
 plot_sh = gsn_csm_contour(wks, bin_var1(::-1,:), res )  ; reverse bin_var1 as contour bottom is the array top in dim0


    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 1.                    ; solid line
    res_lines@gsLineThicknessF  = 3.                    ; line thicker
    res_lines@gsLineColor       = "black"

    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification
    res_text@txFontColor        = "Blue"
    res_text@txFontHeightF      = 0.02

    yy = (/19.0,0.0/)
    xx = (/97,97/)
    dum11 = gsn_add_polyline(wks,plot_sh,xx,yy,res_lines)              ; add polyline
    dum12 = gsn_add_text(wks,plot_sh,"At Sea",110,2,res_text); add text
    
    res_text@txFontColor        = "Brown"
    dum22 = gsn_add_text(wks,plot_sh,"In Land",50,2,res_text); add text
    draw(plot_sh)
    frame(wks)
end




