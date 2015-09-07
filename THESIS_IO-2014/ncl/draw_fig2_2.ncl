;*************************************************************
;Aim: draw IO Basin/NIO/SIO/TIO spring EOF, pattern in fig2_1
;     and fig2_2
;     time series in fig2_3
;
;Mission:
;   1. Read data from CAM SSTs
;   2. Post-post process
;       2.1 Rebuild the data
;       2.2 EOF
;       2.3 Detrend, normalize and regress
;   3. Draw timeseries and overlap shading area
;                       Zhenning Li
;                       2014-11-25
;Last Edited:
;   2014-11-25  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin


;================================================
;Variables List:
;   var1--------------CAM used sst
;================================================

;IO region
; BIO NIO SIO TIO
	latS    =   (/-30.,  0.,-30.,-15./)
	latN    =   (/ 30., 30.,  0., 15./)
    lonL    =   50.
    lonR    =   110.

    exp_code    =   (/"BIO","NIO","SIO","TIO"/)
    fig_num     =   (/"(a)","(b)","(c)","(d)"/)
    data_path   =   "../../../data/sst/monthly/"
    fig_name1   =   "../../../fig/IO_paper/fig2_1_sst_EOF_pattern_2"
    fig_name2   =   "../../../fig/IO_paper/fig2_2_sst_EOF_timeseries"
    fig_title   =   "SST annual cycle (30~S~o~N~S-30~S~o~N~N, 50~S~o~N~E-110~S~o~N~E )"
    
    season      =   "MAM"

    global_font = 0.025
    
    need_start  =   1979
    need_end    =   2011 ; ERSST only extended to 2010-12

    var1_start  =   12*(need_start-1850) 
    var1_end  =   12*(need_end-1850)+11 

    neof   = 1        ; number of EOFs
    optEOF = True       
    optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
;;optEOF@jopt = 1   ; **only** if the correlation EOF is desired

    optETS = False



; ==============================================================
; Mission 1. Open the file: Read sst 
; ==============================================================

;CAMSST
    ctrl_file1   = data_path+"sst_HadOIBl_bc_0.9x1.25_1850_2012_c130411.nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    
    TIME   = ctrl_in1->time
    YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
	
    var1_org  = ctrl_in1->SST_cpl(var1_start:var1_end,:,:)			; p for unify the var name
    var1_0    = f2fsh_Wrap(var1_org,(/180,360/)) 
; for land sea mask

    a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
    lsdata = a->LSMASK
    lsm  = landsea_mask(lsdata,var1_0&lat,var1_0&lon)
    var1 = var1_0
    var1 = mask(var1_0,lsm.eq.1,False)

; ==============================================================
; Mission 2. process the ssts, generate seasons mean and EOF 
; ==============================================================

    var1_season   = month_to_season (var1, season)
    var1_org_season = month_to_season (var1_0,season)
    nyrs          = need_end - need_start
    var1_all_anom     = dim_rmvmean_n_Wrap(var1_org_season, 0)                ; (time, lat,lon)

; ==============================================================
; Mission 3. Set the figure parameters
; ==============================================================

    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",fig_name1)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot = new((/4/),graphic)

    gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;  gsn_define_colormap(wks1,"precip4_diff_19lev")
    ;  gsn_define_colormap(wks,"precip_diff_12lev")
    ; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


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
    res@cnMinLevelValF        = -0.4          ; set min contour level
    res@cnMaxLevelValF        =  0.4          ; set max contour level
    res@cnLevelSpacingF       =  0.05          ; set contour interval

    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

    res@gsnSpreadColors      = True               ; use full color map
    ;res@gsnSpreadColorStart  = 2                ; start at color 17
    ;res@gsnSpreadColorEnd    = 14                ; end at color 200

    ;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
    res@gsnRightString = ""

    res@gsnMaximize      = True       ; fill up the page
    res@gsnAddCyclic   = False
    res@gsnPaperOrientation = "portrait"
    res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


    res@lbLabelBarOn = False   ; turn off the label bar
    ;res@lbOrientation          = "vertical"
    ;res@lbLabelFontHeightF  = global_font              ; make labels smaller
    ;res@lbLabelStride = 1

    res@mpFillOn   = True;False     ; turn off gray continents
    res@mpGeophysicalLineThicknessF = 3 
    res@mpGeophysicalLineColor      = "black";"white" 
    res@mpFillDrawOrder="PostDraw"

    res@mpCenterLonF = 180.
    res@mpMaxLonF  = lonR
    res@mpMinLonF  = lonL

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
    res@tmXBTickSpacingF = 20
    res@tmYLTickSpacingF = 10
    ; res@tmXBLabelFontAspectF = 1.6
    res@tmXBLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontAspectF = 1.3
    res@tmYLLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontQuality =
   	
    res@tmXBMajorThicknessF = 3.0
	res@tmYLMajorThicknessF = 3.0
    
    res@tmXBMajorLengthF = 0.01
    res@tmYLMajorLengthF = 0.01
	
    res@tmXBMinorThicknessF = 3.0
	res@tmYLMinorThicknessF = 3.0
	
    res@tmXBMinorLengthF    = 0.005
	res@tmYLMinorLengthF    = 0.005
    
    res@tmBorderThicknessF = 3.0
   ;-----------------------------------------------------------------------------
     
    
    pres                 = True 
	pres@gsnPanelLabelBar   = True		;Universial colorbar
	;pres@pmLabelBarWidthF   = 0.5	
	;pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    pres@lbLabelAutoStride    = False
	pres@lbLabelStride       = 4 
	pres@lbTitleString       = "SST (K)"
	pres@lbLabelFontHeightF = 0.035 
	pres@lbTitleFontHeightF = 0.035
	pres@pmLabelBarOrthogonalPosF = -0.03           ; move label bar down




    
    
    do n_smp = 0,3
        res@tmXBLabelFontHeightF = global_font
        res@tmYLLabelFontHeightF = global_font
        res@gsnStringFontHeightF = global_font
        res@mpMaxLatF  = latN(n_smp)
        res@mpMinLatF  = latS(n_smp)
        res@gsnLeftString = fig_num(n_smp)
        res@gsnCenterString = exp_code(n_smp)
        var1_anom_rg      = var1_all_anom(:,{latS(n_smp):latN(n_smp)},{lonL:lonR})
        var1_season_rg    = var1_season({lat|latS(n_smp):latN(n_smp)},{lon|lonL:lonR},time|:)
        eof    = eofunc_Wrap(var1_season_rg, neof, optEOF)      
        eof_ts = eofunc_ts_Wrap (var1_season_rg, eof, optETS)
        eof_ts = dtrend(eof_ts,False)
        eof_ts = dim_standardize_n(eof_ts, 0, 1)      ; normalize
        ; regress the field
        eof_regres = eof                               ; create an array w meta data

        res@gsnRightString = sprintf("%5.1f", eof@pcvar) +"%"
        do ne=0,neof-1
            eof_regres(ne,:,:) = (/ regCoef(eof_ts(ne,:), var1_anom_rg(lat|:,lon|:,time|:)) /)
        end do

        yyyymm = cd_calendar(eof_ts&time,-2)/100  
    
        plot(n_smp) = gsn_csm_contour_map_ce(wks,eof_regres(0,:,:),res) ; create a default plot
        print(exp_code(n_smp)+"0.7*std="+(/stddev(eof_ts)/) )
        print(eof_ts)
        delete(var1_anom_rg)
        delete(var1_season_rg)
        delete(eof)
        delete(eof_ts)
        delete(eof_regres)
    end do
    gsn_panel(wks,plot(0),(/1,1/),pres)

    draw(plot)
    frame(wks)
end
