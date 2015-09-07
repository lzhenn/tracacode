;************************************************************
;Aim: Do bias correction to ESM Mean of rcp4.5 run in  CCSM4, 
; output the forcing data for driving CAM
;
;Mission:
;   1. Read data from HadOIbl and ESM Mean of historical and
;      rcp4.5
;   2. Post process
;       2.1 Caculate climatological 1976-2005 in Had and hist
;       2.2 Caculate 10-yr mean 2026-2035 in rcp4.5
;       2.3 Do bias correction
;   3. Draw patterns 
;   4. Output forcing field
;                       Zhenning Li
;                       2015-01-21
;Last Edited:
;   2015-01-21  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin


;================================================
;Variables List:
;   var1--------------CAM used SST
;   rcp_var1----------CCSM4 out SST 4 5 6 member
;   hist_mean---------CCSM4 out mean SST
;================================================

;IO region
; BIO NIO SIO TIO
	latS    =   -90 
	latN    =   90
    lonL    =   0.
    lonR    =   360.

    
    fcase            =  "historical"
    data_path            =  "../data/"
    ncdf_name           = "sst_HadOIBl_bc_0.9x1.25_1976_1995_clim_rcp45_2026-35plus.nc"
    fcase1          = "rcp45"
    fig_num     =   (/"(a)","(b)"/)
    fig_name   =   "../fig/rcp45_BC_SST"

    global_font = 0.038
    
    ; 10 yr time period
    ymstrt  =   202601
    ymlast  =   203512 ; ERSST only extended to 2010-12
    
    yrstrt  = floor(ymstrt/100)
    yrlast  = floor(ymlast/100)

    ; climatological time period
    clm_ymstrt  =   197601
    clm_ymlast  =   200512 ; ERSST only extended to 2010-12
    

; ==============================================================
; Mission 1. Open the file: Read sst 
; ==============================================================

;CAMSST
    ctrl_file1   = data_path+"sst_HadOIBl_bc_0.9x1.25_1850_2012_c130411.nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    
    time    = ctrl_in1->time
    yyyymm  = cd_calendar(time,-1)
    istrt   = ind(yyyymm .eq. clm_ymstrt)
    ilast   = ind(yyyymm .eq. clm_ymlast)
    
    t       = time(istrt:istrt+11) 

    var1  = ctrl_in1->SST_cpl(istrt:ilast,:,:)			; p for unify the var name

    var1_pre=ctrl_in1->SST_cpl_prediddle(istrt:ilast,:,:)
	ice=ctrl_in1->ice_cov(istrt:ilast,:,:)
	ice_pre=ctrl_in1->ice_cov_prediddle(istrt:ilast,:,:)


;ESM Mean SST
    ctrl_file2   = data_path+"/"+fcase1+"/ts_Amon_CCSM4_"+fcase1+"_esm_mean_200601-210012.nc"
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
    
    time2    = ctrl_in2->time
    yyyymm2  = cd_calendar(time2,-1)
    istrt2   = ind(yyyymm2 .eq. ymstrt)
    ilast2   = ind(yyyymm2 .eq. ymlast)
  
    rcp_var1  = ctrl_in2->ts(istrt2:ilast2,:,:)			; p for unify the var name

    print(rcp_var1(5,{0},{110:120}))


;ESM Mean SST
    ctrl_file3   = data_path+"/"+fcase+"/ts_Amon_CCSM4_"+fcase+"_esm_mean_185001-200512.nc"
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile

    hist_var1  = ctrl_in3->ts(istrt:ilast,:,:)			; p for unify the var name
    print(hist_var1(5,{0},{110:120}))
; ==============================================================
; Mission 2. process the ssts, generate clim and bias correction 
; ==============================================================

;CLIM
    clim_var1           = clmMonTLL(var1)
    clim_var1_pre           = clmMonTLL(var1_pre)
    clim_ice           = clmMonTLL(ice)
    clim_ice_pre           = clmMonTLL(ice_pre)
   
   
   clim_hist_var1  = clmMonTLL(hist_var1)
    clim_rcp_var1   = clmMonTLL(rcp_var1)

;Bias Correction
    bc_rcp_var1 = clim_var1
    bc_rcp_var1 = clim_rcp_var1-clim_hist_var1 + clim_var1
    print(bc_rcp_var1(5,{0},{110:120}))
    print(clim_var1(5,{0},{110:120}))
; ==============================================================
; Mission 3. Set the figure parameters
; ==============================================================

    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot = new((/2/),graphic)

    ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
       gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;  gsn_define_colormap(wks1,"precip4_diff_19lev")
    ;  gsn_define_colormap(wks,"precip_diff_12lev")
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

    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ; res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
    ;res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)
    ; res@cnLevels = ispan(0,60,10)
    ;  res@cnFillColors =(/-1,20,47,57,94,127,152/)

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = 0.0          ; set min contour level
    res@cnMaxLevelValF        = 33.0          ; set max contour level
    res@cnLevelSpacingF       = 3.0          ; set contour interval



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


    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = global_font              ; make labels smaller
    res@lbLabelStride = 1

    res@mpFillOn   = True;False     ; turn off gray continents
    res@mpGeophysicalLineThicknessF = 3 
    res@mpGeophysicalLineColor      = "black";"white" 
    res@mpFillDrawOrder="PostDraw"

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
    res@tmXBTickSpacingF = 90
    res@tmYLTickSpacingF = 60
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
     
    
;Set resource for the whole page    
    
    pres                 = True 
	pres@gsnPanelLabelBar   = True		;Universial colorbar
	;pres@pmLabelBarWidthF   = 0.5	
	;pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    pres@lbLabelAutoStride    = False
	pres@lbLabelStride       = 4 
	pres@lbTitleString       = "SST (K)"
	pres@lbLabelFontHeightF = 0.04 
	pres@lbTitleFontHeightF = 0.04
	pres@pmLabelBarOrthogonalPosF = -0.03           ; move label bar down

    res@tmXBLabelFontHeightF = global_font
    res@tmYLLabelFontHeightF = global_font
    res@gsnStringFontHeightF = global_font

    res@gsnCenterString ="June SST (2026-35 minus 1976-95)"
    res@gsnLeftString =""

    anom_rcp_hist_var1 = clim_hist_var1
    anom_rcp_hist_var1 = clim_rcp_var1-clim_hist_var1
    print(anom_rcp_hist_var1(5,{0},{110:120}))
    plot(0) = gsn_csm_contour_map_ce(wks,bc_rcp_var1(5,:,:),res) ; create a default plot
    ;pres@gsnMaximize=True
    ;pres@gsnPaperMargin=0.2
    gsn_panel(wks,plot(0),(/1,1/),False)

    ;draw(plot())
    frame(wks)

    system("rm "+data_path+ncdf_name)
	ncdf     = addfile(data_path+ncdf_name ,"c")  ; open output netCDF file

	; make time and UNLIMITED dimension      ; recommended  for most applications
	filedimdef(ncdf,"time",-1,True) 

	; output variables directly
	ncdf->SST_cpl=bc_rcp_var1
	ncdf->SST_cpl_prediddle=clim_var1_pre
	ncdf->ice_cov=clim_ice
	ncdf->ice_cov_prediddle=clim_ice_pre
	ncdf->time=t



end
