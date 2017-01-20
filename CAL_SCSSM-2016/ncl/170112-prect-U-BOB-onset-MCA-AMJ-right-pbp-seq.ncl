;*************************************************************
;Aim: EMCA method on pentad observational U and Pr
;
;                       Zhenning Li
;                       2017-01-10
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;   2017-01-10  Change to fit MCA analysis
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
    g_day_lst=149

    g_p_strt=g_day_strt/5 ;(Index)
    g_p_lst=(g_day_lst+1)/5-1 ;

    g_var_name1 = "r"
    g_data2_path ="../data/obv/NCEP-DOE/daily/uwnd1979-2013/uwnd*"
    g_data1_path ="../data/obv/PRECT/precip.pentad.mean.nc"
    g_plvl =200
    g_font = 0.035
    
    g_latS1=0.
    g_latN1=45.
    g_lonW1=30.
    g_lonE1=130.
    
    g_latS2=5
    g_latN2=25
    g_lonW2=85.
    g_lonE2=125.
    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/mca_pr_u_left_pbp_U_Seq"
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)"/)


;Prepare the variables

    ctrl_in1 = addfile(g_data1_path, "r")
    time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    var1  = ctrl_in1->precip(:g_yr_len*73-1,{g_latS2:g_latN2},{g_lonW2:g_lonE2})
    
    
    ctrl_in2_files = systemfunc("ls "+g_data2_path)
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in2     = addfiles (ctrl_in2_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in2, "join")
    var2  =short2flt(ctrl_in2[:]->uwnd(:,g_day_strt:g_day_lst,{g_plvl},{g_latS1:g_latN1},{g_lonW1:g_lonE1}))
    var2_366  =short2flt(ctrl_in2[1::4]->uwnd(:,g_day_strt:g_day_lst,{g_plvl},{g_latS1:g_latN1},{g_lonW1:g_lonE1}))
    var2_dim = dimsizes(var2)
    var2_data = new((/g_yr_len,var2_dim(1),var2_dim(2),var2_dim(3)/),"float")
    copy_VarMeta(var2,var2_data)
    
    ; Merge normal and leap years 
    sp = 0
    do ii=0,g_yr_len-1
        if (mod((ii-1),4) .eq. 0) then
            var2_data(ii,:,:,:) = var2_366((ii-1)/4,:,:,:)
            sp=sp+1
        else
            var2_data(ii,:,:,:) = var2(ii-sp,:,:,:)
        end if
    end do

    var2_pt_data = var2_data(:,0:g_p_lst-g_p_strt,:,:)    
    
    ; Calculate pentad data
    do ii=g_p_strt-1,g_p_lst-1
        jj = ii - g_p_strt +1
        var2_pt_data(:,jj,:,:)=dim_avg_n_Wrap(var2_data(:,jj*5:jj*5+4,:,:),1)
    end do
    var2_pt_data!1="pentad"
    ;var2_pt_data_reshape =  reshape(var2_pt_data,(/g_yr_len,(g_p_lst-g_p_strt+1)*var2_dim(2),var2_dim(3)/))
    
    var1_dim = dimsizes(var1) 
    var1_4d  = reshape(var1,(/g_yr_len,73,var1_dim(1),var1_dim(2)/))
    var1_4d2 = var1_4d(:,g_p_strt:g_p_lst,:,:)
    ;printVarSummary(var1_pt_data_reshape)
   
    var1_4d2!0="year" 
    var1_4d2!1="pentad"
    var1_4d2!2="lat"
    var1_4d2!3="lon"
    var1_4d2&pentad=var2_pt_data&pentad
    var1_4d2&lat=var1&lat
    var1_4d2&lon=var1&lon

    ;var2_pt_data_reshape!0="time"
    ;var2_pt_data_reshape!1="lat"
    ;var2_pt_data_reshape!2="lon"

; ==============================================================
; Mission 3. post process the data
; ==============================================================
    nmca = 1 ; how many MCA we need



    ;Right field

    var1_ano = dim_rmvmean_n_Wrap(var1_4d2,0)
    
    var1_size = dimsizes(var1_ano)
    n_var1_size = var1_size(2)*var1_size(3)
    homrgt = new((/nmca,n_var1_size/),float)
    hetrgt = new((/nmca,n_var1_size/),float)
    var1_ano_pack_year = reshape(var1_ano,(/var1_size(0)*var1_size(1),var1_size(2),var1_size(3)/))
    
    var1_ano_pack_year!0 = "time" 
    var1_ano_pack_year!1 = "lat" 
    var1_ano_pack_year!2 = "lon" 
    var1_LLT = var1_ano_pack_year(lat|:,lon|:,time|:)

    var1_ano_line = reshape(var1_ano_pack_year,(/var1_size(0)*var1_size(1),n_var1_size/))
    var1_ano_line!0 = "time" 
    var1_ano_line!1 = "pattern" 

 
    ;Left field
    var2_LLLT = var2_pt_data(pentad|:,lat|:,lon|:,ncl_join|:)
    var2_ano = dim_rmvmean_n_Wrap(var2_pt_data,0)
    
    var2_size = dimsizes(var2_ano)
    n_var2_size = var2_size(2)*var2_size(3)
    homlft = new((/nmca,n_var2_size/),float)
    hetlft = new((/nmca,n_var2_size/),float)
    var2_ano_pack_year = reshape(var2_ano,(/var2_size(0)*var2_size(1),var2_size(2),var2_size(3)/))
    var2_ano_pack_year!0 = "time" 
    var2_ano_pack_year!1 = "lat" 
    var2_ano_pack_year!2 = "lon" 
    var2_LLT = var2_ano_pack_year(lat|:,lon|:,time|:)
    var2_ano_line = reshape(var2_ano_pack_year,(/var2_size(0)*var2_size(1),n_var2_size/))
    var2_ano_line!0 = "time" 
    var2_ano_line!1 = "pattern" 
    printVarSummary(var1_ano_line) 
    mca_var2 = svdcov(var1_ano_line(pattern|:,time|:),var2_ano_line(pattern|:,time|:),nmca,homrgt,hetrgt,homlft,hetlft) 
    
    ak   = onedtond(mca_var2@ak,(/nmca,var2_size(0)*var2_size(1)/)) ;timeseries
    bk   = onedtond(mca_var2@bk,(/nmca,var2_size(0)*var2_size(1)/)) ;timeseries
    ak!0 = "sv"
    ak!1 = "time"
    bk!0 = "sv"
    bk!1 = "time"
    print("svdcov: percent variance= " + mca_var2) 
    print("ak variance= " + variance(ak(0,:))) 
    print("bk variance= " + variance(bk(0,:))) 
    ak_reshape=reshape(ak(0,:),(/35,10/))
    bk_reshape=reshape(bk(0,:),(/35,10/))
    print(dim_variance_n(ak_reshape,0))
    print(dim_variance_n(bk_reshape,0))
    exit

    ak_std=dim_standardize_Wrap(ak,1)
    bk_std=dim_standardize_Wrap(bk,1)
    reg_var2 = var2_pt_data(0,0,:,:)
    printVarSummary(ak_std)
    printVarSummary(var2_LLT)
    reg_var2 = (/regCoef(bk_std(0,:), var2_LLT)/) 
    
    
    reg_var1 = var1_4d2(0,0,:,:)
    reg_var1 = (/regCoef(ak_std(0,:), var1_LLT)/) 

    print("MCA done!") 
  
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_S = new((/12/),graphic)
;  plot_tp = new((/2/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


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
 res@cnMinLevelValF        = -5         ; set min contour level
 res@cnMaxLevelValF        = 5         ; set max contour level
 res@cnLevelSpacingF       = 1         ; set contour interval
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
  res@gsnAddCyclic   = False
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
  res@mpMaxLatF  = g_latN1
  res@mpMinLatF  = g_latS1
  res@mpMaxLonF  = g_lonE1
  res@mpMinLonF  = g_lonW1

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
    do ii=0,0
        res@gsnCenterString="U200 Day101-150"
        res@gsnLeftString=g_fig_rank(ii)
        reg_var2=-reg_var2
        plot_S(ii)   =    gsn_csm_contour_map_ce(wks,reg_var2(:,:),res) ; create a default plot
    end do
    gsn_panel(wks,plot_S(0),(/1,1/),False)
   
    data_path="../data/obv/"
    ncdf_name="obv_pbp_seq_acbc.nc"
    system("rm "+data_path+ncdf_name)
    ncdf     = addfile(data_path+ncdf_name ,"c")  ; open output netCDF file
    ncdf->ak_std=ak
    ncdf->bk_std=bk
end 


