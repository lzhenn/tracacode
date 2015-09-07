;************************************************************
;Aim: Do bias correction to ESM Member 1 2 3 and memeber mean 
; of historical run in CCSM4, draw 4x2 fig to test if the 
; bias correction behaves good
;
;Mission:
;   1. Read data from HadOIbl and ESM 1 2 3 and member mean
;   2. Post process
;       2.1 Caculate climatological 1976-2005
;       2.2 Caculate 10-yr mean 1996-2005
;       2.3 Caculate difference and do bias correction
;   3. Draw patterns 
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
;   esm_var1----------CCSM4 out SST 4 5 6 member
;   esm_var1_mean-----CCSM4 out mean SST
;================================================

;IO region
; BIO NIO SIO TIO
	latS    =   -90 
	latN    =   90
    lonL    =   0.
    lonR    =   360.

    
    fcase            =  "historical"
    data_path            =  "../data/"

    fig_num     =   (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)"/)
    fig_name   =   "../fig/hist_NB_BC_cmp"

    global_font = 0.038
    
    ; 10 yr time period
    ymstrt  =   199601
    ymlast  =   200512 ; ERSST only extended to 2010-12
    
    yrstrt  = floor(ymstrt/100)
    yrlast  = floor(ymlast/100)

    ; climatological time period
    clm_ymstrt  =   197601
    clm_ymlast  =   200512 ; ERSST only extended to 2010-12
    
    clm_yrstrt  = floor(clm_ymstrt/100)
    clm_yrlast  = floor(clm_ymlast/100)

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
   

    var1  = ctrl_in1->SST_cpl(istrt:ilast,:,:)			; p for unify the var name

;ESM 4 5 6 SST
    all_files2 = systemfunc ("ls "+data_path+"/"+fcase+"/ts_Amon_CCSM4_"+fcase+"_r[4-6]i1p1*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in2      = addfiles (all_files2, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in2, "join")             ; concatenate or "merge" (default)

    time_esm    = ctrl_in2[:]->time
    yyyymm2  = cd_calendar(time_esm(0,:),-1)
    istrt   = ind(yyyymm2 .eq. clm_ymstrt)
    ilast   = ind(yyyymm2 .eq. clm_ymlast)
 
    esm_var1   = ctrl_in2[:]->ts(:,istrt:ilast,:,:)



;ESM Mean SST
    ctrl_file3   = data_path+"/"+fcase+"/ts_Amon_CCSM4_"+fcase+"_esm_mean_185001-200512.nc"
	ctrl_in3     = addfile (ctrl_file3, "r")   ; note the "s" of addfile

    esm_var1_mean  = ctrl_in3->ts(istrt:ilast,:,:)			; p for unify the var name
    print(esm_var1_mean(3,{0},{110:120}))

; ==============================================================
; Mission 2. process the ssts, generate clim and bias correction 
; ==============================================================

;CLIM
    clim_var1           = clmMonTLL(var1)
    
    clim_esm_var1       = esm_var1(:,0:11,:,:)
    clim_esm_var1!1     = "month"
    do i = 0,2
        clim_esm_var1(i,:,:,:) = clmMonTLL(esm_var1(i,:,:,:))
    end do
    clim_esm_var1_mean  = clmMonTLL(esm_var1_mean)

;10-yr mean with no BC
    istrt   = 240 
    ilast   = 359
    slice_var1           = clmMonTLL(var1(istrt:ilast,:,:))
    
    slice_esm_var1       = esm_var1(:,0:11,:,:)
    slice_esm_var1!1     = "month"
    do i = 0,2
        slice_esm_var1(i,:,:,:) = clmMonTLL(esm_var1(i,istrt:ilast,:,:))
        slice_esm_var1(i,:,:,:) = slice_esm_var1(i,:,:,:) - slice_var1 
    end do
    slice_esm_var1_mean  = clmMonTLL(esm_var1_mean(istrt:ilast,:,:))
    slice_esm_var1_mean  = slice_esm_var1_mean - slice_var1

;Bias Correction
    bc_slice_esm_var1 = slice_esm_var1
    bc_slice_esm_var1_mean = slice_esm_var1_mean
    bc_slice_esm_var1 = bc_slice_esm_var1 - clim_esm_var1
    do i = 0,2
        bc_slice_esm_var1(i,:,:,:) = bc_slice_esm_var1(i,:,:,:)+clim_var1
    end do
    bc_slice_esm_var1_mean = bc_slice_esm_var1_mean - clim_esm_var1_mean + clim_var1
; ==============================================================
; Mission 3. Set the figure parameters
; ==============================================================

    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot = new((/8/),graphic)

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
    res@cnMinLevelValF        = -4.0          ; set min contour level
    res@cnMaxLevelValF        =  4.0          ; set max contour level
    res@cnLevelSpacingF       =  0.5          ; set contour interval

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
	pres@lbLabelFontHeightF = 0.02 
	pres@lbTitleFontHeightF = 0.02
	pres@pmLabelBarOrthogonalPosF = -0.03           ; move label bar down

    res@tmXBLabelFontHeightF = global_font
    res@tmYLLabelFontHeightF = global_font
    res@gsnStringFontHeightF = global_font

    slice_esm_var1 = slice_esm_var1 - 273.15
    slice_esm_var1_mean = slice_esm_var1_mean - 273.15
    do i =0,3
        res@gsnCenterString ="June SST NB ESM"+i
        res@gsnLeftString = fig_num(2*i)
        if (i .eq. 3) then
            res@gsnCenterString ="June SST NB ESM Mean" 
            res@gsnLeftString = fig_num(2*i)
            plot(2*i) = gsn_csm_contour_map_ce(wks,slice_esm_var1_mean(5,:,:),res) ; create a default plot
            res@gsnCenterString ="June SST BC ESM Mean"
            res@gsnLeftString = fig_num(2*i+1)
            plot(2*i+1) = gsn_csm_contour_map_ce(wks,bc_slice_esm_var1_mean(5,:,:),res) ; create a default plot
        else
            plot(2*i) = gsn_csm_contour_map_ce(wks,slice_esm_var1(i,5,:,:),res) ; create a default plot
            res@gsnCenterString ="June SST BC ESM"+i
            res@gsnLeftString = fig_num(2*i+1)
            plot(2*i+1) = gsn_csm_contour_map_ce(wks,bc_slice_esm_var1(i,5,:,:),res) ; create a default plot
        end if
    end do

    ;pres@gsnMaximize=True
    ;pres@gsnPaperMargin=0.2
    gsn_panel(wks,plot,(/4,2/),pres)

    draw(plot)
    frame(wks)
end
