;*************************************************************
;Aim: draw MCA map of SST~Pr, draw timeseries of SST and  
;     Pr, caculate regression of SST against Pr
;     
;Mission:
;   1. Read data from GPCP datasets
;   2. Post-post process to deserved results in diff Region of
;      IO
;   3. Draw the MCA map (BIO, NIO, SIO, TIO) 
;                       Zhenning Li
;                       2014-12-18
;Last Edited:
;   2014-12-18  Create
;*************************************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

;================================================
;Variables List:
;   var2--------------Precpt
;================================================

;initial data


    sst_path   =   "../../../data/sst/monthly/"

    fig_name    =   "../../../fig/IO_paper/fig5_2_mca_Pr_BIO"
    setfileoption("bin","ReadByteOrder","Native")       ; default

    nyears  =   32
    nt     =   384 
    season  =   "JJA"
    season0 =   "MAM"

    lonL        =   20
    lonR        =   180
    latS        =   -30
    latN        =   60

    global_font = 0.035
 
    need_start  =   1979
    need_end    =   2010 ; ERSST only extended to 2010-12

    sst_start  =   12*(need_start-1850) 
    sst_end  =   12*(need_end-1850)+11 
	
    latS_IO    =   (/-30.,  0.,-30.,-15./)
	latN_IO    =   (/ 30., 30.,  0., 15./)
    lonL_IO    =   50.
    lonR_IO    =   110.


	fig_ranks    = (/"b","d","e","f"/)
    fig_titles   = (/"JJA Pr","JJA Pr","JJA Pr","JJA Pr"/)

    sigr    =   0.1
    iflag   =   False   ; population variance similar
; ==============================================================
; Mission 1. Open the file: Read data and merge metadata 
; ==============================================================


;--------------Read SST Out----------------------

;CAMSST
    ctrl_file1   = sst_path+"sst_HadOIBl_bc_0.9x1.25_1850_2012_c130411.nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    
    TIME   = ctrl_in1->time
    YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
	
    sst_org  = ctrl_in1->SST_cpl(sst_start:sst_end,:,:)			; p for unify the var name
    sst_0    = f2fsh_Wrap(sst_org,(/180,360/)) 
; for land sea mask

    a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
    lsdata = a->LSMASK
    lsm  = landsea_mask(lsdata,sst_0&lat,sst_0&lon)
    sst = sst_0
    sst = mask(sst_0,lsm.eq.1,False)

; process the ssts, generate seasons mean and EOF 
    printVarSummary(sst)
    sst_season   = month_to_season (sst, season0)
    sst_all_anom = dim_rmvmean_n_Wrap(sst_season, 0)                ; (time, lat,lon)
    
    sst0_season   = month_to_season (sst_0, season0)
    sst0_all_anom = dim_rmvmean_n_Wrap(sst0_season, 0)                ; (time, lat,lon)

    print("sst has been loaded...")

;-----var2 standard netcdf file
    var2_file   = "../../../data/GPCP/precip.mon.mean.nc"
	ctrl_in1     = addfile (var2_file, "r")   ; note the "s" of addfile
	var2        = ctrl_in1->precip(0:nt-1,:,:)



  ;----read var1 var3 var4 from Binary files 
    print("var2, has been loaded...")
    

; ==============================================================
; Mission 2. Set the figure parameters
; ==============================================================

    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot_C = new((/4/),graphic)     ;contour
    plot_V = new((/4/),graphic)     ;vector
    plot_S = new((/4/),graphic)     ;shading
    plot_sig = new((/4/),graphic)   ;sig in shading

    ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;gsn_define_colormap(wks,"precip4_diff_19lev")
    gsn_define_colormap(wks,"precip_diff_12lev")
    ; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    ;gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


    ;-----------------------------------------------------------------------------
    res                  = True       ; use plot options

    res@cnFillOn             = True               ; turn on color for contours
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off contour line labels



    i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
    j = NhlNewColor(wks,1,0.,0.)
    ;  res@mpLandFillColor       = "gray"            ; set land to be gray

    ;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
    ;   res@cnLevels = ispan(0,60,10)
    ;  res@cnFillColors =(/-1,20,47,57,94,127,152/)

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        =  -1.2          ; set min contour level
    res@cnMaxLevelValF        =  1.2          ; set max contour level
    res@cnLevelSpacingF       =  0.2          ; set contour interval

    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

    res@gsnSpreadColors      = True               ; use full color map
    res@gsnSpreadColorStart  = 2                ; start at color 17
    res@gsnSpreadColorEnd    = 14                ; end at color 200

    ;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
    res@gsnRightString = ""

    res@gsnMaximize      = True       ; fill up the page
    res@gsnAddCyclic   = False
    res@gsnPaperOrientation = "portrait"
    res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


    res@lbLabelBarOn = False   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = global_font              ; make labels smaller
    res@lbLabelStride = 3

    res@mpFillOn   = True;False     ; turn off gray continents
    res@mpGeophysicalLineThicknessF = 3 
    res@mpGeophysicalLineColor      = "black";"white" 
    ;res@mpFillDrawOrder="PostDraw"

    res@mpCenterLonF = 180.
    res@mpMaxLonF  = lonR
    res@mpMinLonF  = lonL

    res@mpMaxLatF  = latN
    res@mpMinLatF  = latS
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
    res@tmYLTickSpacingF = 30
    ; res@tmXBLabelFontAspectF = 1.6
    res@tmXBLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontAspectF = 1.3
    res@tmYLLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontQuality =
   	res@tmXBMajorThicknessF = 3.0
	res@tmYLMajorThicknessF = 3.0
	res@tmXBMinorThicknessF = 3.0
	res@tmYLMinorThicknessF = 3.0
	res@tmBorderThicknessF = 3.0
   ;-----------------------------------------------------------------------------
     
    
    res@tmXBLabelFontHeightF = global_font
    res@tmYLLabelFontHeightF = global_font
    res@gsnStringFontHeightF = global_font
;-------Set for contour plot--------

    resC                  = True       ; use plot options
    resC@cnLinesOn            = True              ; turn off contour lines
    resC@cnLineLabelsOn       = True              ; turn off contour line labels
    resC@cnInfoLabelOn        = False             ; turn off info label
    resC@gsnFrame         = False
    resC@gsnDraw  = False
    resC@gsnMaximize      = True       ; fill up the page
    resC@gsnAddCyclic   = False
    resC@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
   ; resC@cnLevelSelectionMode = "ExplicitLevels"  ; use explicit levels
   ; resC@cnLevels             = fspan(-1.5,2.0,8 )   ; set the contour levels
;-------Set for the vector plot------
    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    vcres@vcRefAnnoOrthogonalPosF = -0.21             ; move ref vector up
    vcres@vcRefMagnitudeF         = 1.0             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.017
    vcres@vcRefAnnoString1  = "1 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.018

    vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector

    ;----------Set res sig-----------
    res_sig                  = True       ; use plot options
    res_sig@cnFillOn         = True       ; Fill contours
    res_sig@cnLinesOn        = False;True      ; turn off contour lines
    res_sig@gsnFrame         = False
    res_sig@gsnDraw  = False
    res_sig@cnLineLabelsOn   = False      ; turn off contour line labels
    res_sig@cnLineThicknessF = 2
    res_sig@cnLineColor      = "black"
    res_sig@cnInfoLabelOn = False
    res_sig@cnMonoFillPattern    = True;False
    res_sig@cnFillPattern = 17
    res_sig@cnMonoFillScale = True
    res_sig@cnFillScaleF = 1.
    res_sig@cnMonoFillColor = True
    res_sig@cnFillColor  =  "red"
    res_sig@cnFillDotSizeF = 0.0035

    res_sig@lbLabelBarOn = False;True   ; turn off the label bar

    ;  res_sig@cnLevelSelectionMode="ExplicitLevels"
    ;  res_sig@cnLevels = (/3000,1000/)
    res_sig@gsnLeftString      = " "
    res_sig@gsnRightString      = " "


;-----Set resource for the whole page----
    
    pres                 =  True 
	pres@gsnPanelLabelBar   = True		;Universial colorbar
	;pres@pmLabelBarWidthF   = 0.5	
	;pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    pres@lbLabelAutoStride    = False
	pres@lbLabelStride       = 4 
	pres@lbTitleString       = "Precipitation Rate (mm/day)"
	pres@lbLabelFontHeightF = 0.018 
	pres@lbTitleFontHeightF = 0.018
	pres@pmLabelBarOrthogonalPosF = -0.03           ; move label bar down




; ==============================================================
; Mission 3. post process the data
; ==============================================================

    nmca = 1 ; how many MCA we need

    season_var2   =   month_to_season(var2,season)
    clim_season_var2    =   dim_avg_n_Wrap(season_var2,0)
    var_season_var2     =  dim_variance_n_Wrap(season_var2,0)


    season_var2_region = season_var2(:,{latS:latN},{lonL:lonR})
    season_var2_region_LLT = season_var2_region(lat|:,lon|:,time|:)
    season_var2_ano = dim_rmvmean_n_Wrap(season_var2_region,0)
    
    var2_region_size = dimsizes(season_var2_ano)
    n_var2_size = var2_region_size(1)*var2_region_size(2)
    homrgt = new((/nmca,n_var2_size/),float)
    hetrgt = new((/nmca,n_var2_size/),float)
    season_var2_ano_line = reshape(season_var2_ano,(/nyears,n_var2_size/))
    season_var2_ano_line!0 = "time" 
    season_var2_ano_line!1 = "pts"

   

   
    do i = 0,3
        
    ;----MCA Here----

        ;----SST Preprocess----
        sst_region_anom = sst_all_anom(:,{latS_IO(i):latN_IO(i)},{lonL_IO:lonR_IO})
        region_size = dimsizes(sst_region_anom)
        n_sst_size = region_size(1)*region_size(2)
        sst_region_anom_line = reshape(sst_region_anom,(/nyears,n_sst_size/))
        sst_region_anom_line!0 = "time"
        sst_region_anom_line!1 = "pts"
        
        homlft = new((/nmca,n_sst_size/),float)
        hetlft = new((/nmca,n_sst_size/),float)


        ;var2
               
        mca_var2 = svdcov(sst_region_anom_line(pts|:,time|:),season_var2_ano_line(pts|:,time|:),nmca,homlft,hetlft,homrgt,hetrgt) 
        var2_ak   = onedtond(mca_var2@ak,(/nmca,nyears/)) ;timeseries
        var2_bk   = onedtond(mca_var2@bk,(/nmca,nyears/)) ;timeseries
        var2_ak!0 = "sv"
        var2_ak!1 = "time"
        var2_bk!0 = "sv"
        var2_bk!1 = "time"
       
        var2_ak_std=dim_standardize_Wrap(var2_ak,1)
        reg_var2 = season_var2_region(0,:,:)
        reg_var2 = (/regCoef(var2_ak_std(0,:), season_var2_region_LLT)/) 

        print("var2 MCA done!") 
        
        res@gsnLeftString = "("+fig_ranks(i)+")"
        ;res@gsnLeftString = ""
        ;res@gsnCenterString =""
        ;res@gsnRightString =""
        res@gsnCenterString = fig_titles(i)

        if (i .eq. 2) then
            reg_var2 = (/-reg_var2/)
        end if
        if (i .eq. 0) then
            reg_var2 = (/-reg_var2/)
            ;res@gsnRightString = sprintf("%4.2f",mca_var2)+"%"
            bio_var2 = reg_var2
        else
            res@gsnRightString ="Rp="+sprintf("%4.2f",pattern_cor(bio_var2({latS:latN},{lonL:lonR}),reg_var2({latS:latN},{lonL:lonR}), 1.0, 0))
        end if
        
        plot_S(i)   =    gsn_csm_contour_map_ce(wks,reg_var2,res) ; create a default plot

        delete([/homlft,hetlft/])
        delete([/sst_region_anom,sst_region_anom_line/])

        ;plot_V(i) = gsn_csm_vector(wks,reg_var3,reg_var4,vcres)

        ;overlay(plot_S(i),plot_V(i))
    end do

    gsn_panel(wks,plot_S,(/2,2/),False)

    draw(plot_S)
    frame(wks)

end
