;************************************************************
;Aim: Regression SST anomaly from TCP_index, and insert these 
;     anomalies to clim SST
;     
;
;Mission:
;   1. Read index data from ascii file, read sst data
;   2. Post process
;       2.1 Regression NINO3
;       2.2 Departure NINO3 signal from Anomaly pattern
;       2.3 Detrend
;       2.4 Regression TCP
;
;   3. Draw patterns 
;   4. Output SST forcing field
;                       Zhenning Li
;                       2015-01-18
;Last Edited:
;   2015-01-18  Create
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin


;================================================
;Variables List:
;   var1--------------CAM used sst
;   index1------------TCP index
;   index2------------NINO3 index
;================================================

;IO region
    

	latS    =   -30.
	latN    =   30
    lonL    =   110.
    lonR    =   290.

    fig_code    =   (/"Jan","Jul"/)
    fig_num     =   (/"(a)","(b)"/)
    data_path   =   "/users/yangsong3/CESM/input/atm/cam/sst/"
    fig_name   =   "fig/reg_sst_TCP_no_ENSO"
    fig_title   =   "SST annual cycle (30~S~o~N~S-30~S~o~N~N, 50~S~o~N~E-110~S~o~N~E )"
    
	ncdf_name    =   "sst_HadOIBl_bc_1.9x2.5_reg_no_ENSO_TCP_1979_2013_clim.nc"

    global_font = 0.025
    
    ymstrt  =   197901
    ymlast  =   201312 ; ERSST only extended to 2010-12

; ==============================================================
; Mission 1. Read index data from ascii file, read sst data
; ==============================================================
   

;-------------------Read index file---------------------
    index1   =   asciiread("TCP_index_79-13.txt",(/35,12/),"float")
    index2   =   asciiread("NINO3_index_79-13.txt",(/35,12/),"float")
    


;------------------Read clim sst-------------------------------
    ctrl_file1   = data_path+"sst_HadOIBl_bc_1.9x2.5_1979_2013_clim_c150401.nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    
    clim_var1  = ctrl_in1->SST_cpl			; p for unify the var name

;    print(clim_var1&lon)
;    exit
;------------------Read clim sst-------------------------------
    ctrl_file2   = data_path+"sst_HadOIBl_bc_1.9x2.5_1850_2013_c140701.nc"
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
   ; time processing
    time    = ctrl_in2->time
    yyyymm  = cd_calendar(time,-1)
    istrt   = ind(yyyymm .eq. ymstrt)
    ilast   = ind(yyyymm .eq. ymlast)
    
    var1    = ctrl_in2->SST_cpl(istrt:ilast,:,:)			; p for unify the var name


; ==============================================================
; Mission 2. process the ssts 
; ==============================================================
        
;------------dtrend & regression--------------------
    dt_var1           = var1  ;copy metadata
    reg_var1          = var1(0:11,:,:)
    anom_var1         = calcMonAnomTLL(var1,clmMonTLL(var1))
    no_nino3_anom_var1=anom_var1
    dt_no_nino_var1 = var1
    do i = 0,11
        dt_mid_var1 =dt_var1(i::12,:,:) ;midvar, used for reg
        reg_var1(i,:,:) = (/regCoef(index2(:,i), dt_mid_var1(lat|:,lon|:,time|:))/)

        ;confirm the data in order to caculate
        reg_var1_nino3_cfm=conform_dims(dimsizes(dt_mid_var1),reg_var1(i,:,:),(/1,2/))
        mid_var_idx_cfm = conform_dims(dimsizes(dt_mid_var1),index2(:,i),(/0/))
        no_nino3_anom_var1(i::12,:,:)=anom_var1(i::12,:,:)-reg_var1_nino3_cfm*mid_var_idx_cfm

        dt_no_nino_var1(i::12,:,:)=dtrend_leftdim(no_nino3_anom_var1(i::12,:,:),False)
        
        dt_mid_no_nino_var1 =dt_no_nino_var1(i::12,:,:) ;midvar, used for reg
        
        reg_var1(i,:,:) = (/regCoef(index1(:,i), dt_mid_no_nino_var1(lat|:,lon|:,time|:))/)
    end do
;    reg_var1 = reg_var1*2
    printVarSummary(reg_var1)


; ==============================================================
; Mission 3. Set the figure parameters
; ==============================================================

    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot = new((/2/),graphic)

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
    res@cnMinLevelValF        = -1.0          ; set min contour level
    res@cnMaxLevelValF        =  1.0          ; set max contour level
    res@cnLevelSpacingF       =  0.1          ; set contour interval

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
     
    
;Set resource for the whole page    
    
    pres                 = True 
	pres@gsnPanelLabelBar   = True		;Universial colorbar
	;pres@pmLabelBarWidthF   = 0.5	
	;pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    pres@lbLabelAutoStride    = False
	pres@lbLabelStride       = 4 
	pres@lbTitleString       = "SST (K)"
	pres@lbLabelFontHeightF = 0.02 
	pres@lbTitleFontHeightF = 0.02
	pres@pmLabelBarOrthogonalPosF = -0.03           ; move label bar down

    res@tmXBLabelFontHeightF = global_font
    res@tmYLLabelFontHeightF = global_font
    res@gsnStringFontHeightF = global_font
     
    res@mpMaxLatF  = latN
    res@mpMinLatF  = latS
; ==============================================================
; Mission 3. Draw patterns
; ==============================================================



    mon_idx = (/0,6/)
    do i = 0,1

        res@gsnLeftString = fig_num(i)
        res@gsnCenterString = fig_code(i)

        plot(i) = gsn_csm_contour_map_ce(wks,reg_var1(mon_idx(i),:,:),res) ; create a default plot

    end do

    gsn_panel(wks,plot,(/2,1/),False)

    draw(plot)
    frame(wks)

; ==============================================================
; Mission 4. Output sst forcing file
; ==============================================================
    
    cmp_var1_clim = clim_var1

    print(cmp_var1_clim(6,{-10:10},{175:180}))
	
    cmp_var1_clim(:,{latS:latN},{lonL:lonR}) = cmp_var1_clim(:,{latS:latN},{lonL:lonR})+reg_var1(:,{latS:latN},{lonL:lonR})
    
    print("*************")
    print("*************")
    print("*************")
    print("*************")
    print("*************")
    print(cmp_var1_clim(6,{-10:10},{175:180}))


	system("rm "+data_path+ncdf_name)
	ncdf     = addfile(data_path+ncdf_name ,"c")  ; open output netCDF file

	; make time and UNLIMITED dimension      ; recommended  for most applications
	filedimdef(ncdf,"time",-1,True) 

	SST2=ctrl_in1->SST_cpl_prediddle
	ice=ctrl_in1->ice_cov
	ice2=ctrl_in1->ice_cov_prediddle
	t=ctrl_in1->time

	; output variables directly
	ncdf->SST_cpl=cmp_var1_clim
	ncdf->SST_cpl_prediddle=SST2
	ncdf->ice_cov=ice
	ncdf->ice_cov_prediddle=ice2
	ncdf->time=t
end
