;************************************************************
;Aim: draw IO Basin/NIO/SIO/TIO spring EOF composite results, 
;     and Summer results and pattern correlation. fig3_1 
;
;Mission:
;   1. Read data from CAM SSTs
;   2. Post-post process
;       2.1 Composite MAM and JJA
;   3. Draw patterns and overlap shading area
;                       Zhenning Li
;                       2014-11-30
;Last Edited:
;   2014-11-30  Create
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
	latS    =   -15
	latN    =    15
    lonL    =   120.
    lonR    =   290.

    exp_code    =   (/"BIO","NIO","SIO","TIO"/)
    fig_num     =   (/"(a)","(b)","(c)","(d)"/)
    data_path   =   "/Users/zhenningli/data/THESIS-IO-2014/"
    fig_name   =   "../../fig/figR1_1_sst_comp_JJA_TP"
    fig_title   =   "SST"
    
    season      =   "JJA"

    global_font = 0.02
    
    need_start  =   1979
    need_end    =   2011 ; ERSST only extended to 2010-12

    var1_start  =   12*(need_start-1850) 
    var1_end  =   12*(need_end-1850)+11 
	
    yr_warm = (/(/1983, 1987, 1988, 1991, 1998, 2005, 2010,    0/),\
                (/1989, 1992, 1993, 1999, 2008, 2011,    0,    0/),\
                (/1983, 1987, 1988, 1998, 2002, 2005, 2010,    0/),\
                (/1983, 1987, 1988, 1991, 1998, 2003, 2005, 2010/)/)
	
    yr_cold = (/(/1984, 1986, 1989, 1999, 2000, 2008, 2011,    0/),\
                (/1988, 1991, 1998, 2001, 2003, 2010,    0,    0/),\ 
                (/1982, 1984, 1986, 1999, 2000, 2006, 2008, 2011/),\
                (/1984, 1986, 1989, 1994, 1999, 2000, 2008, 2011/)/)
    n_warm  = (/7, 6, 7, 8/)
    n_cold  = (/7, 6, 8, 8/)

	idx_warm = 12*(yr_warm-need_start)
    idx_cold = 12*(yr_cold-need_start)
; ==============================================================
; Mission 1. Open the file: Read sst 
; ==============================================================

;CAMSST
    ctrl_file1   = data_path+"sst_HadOIBl_bc_1.9x2.5_1850_2011_c130301.nc"
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    
    var1  = ctrl_in1->SST_cpl(var1_start:var1_end,:,:)			; p for unify the var name

; ==============================================================
; Mission 2. process the ssts, generate seasons mean and EOF 
; ==============================================================
    cmp_var1_ano = var1(0,:,:)
	
    cmp_var1_pos = var1(0:11,:,:)
	cmp_var1_pos = cmp_var1_pos - var1(0:11,:,:)

	cmp_var1_neg = var1(0:11,:,:)
	cmp_var1_neg = cmp_var1_neg - var1(0:11,:,:)

; ==============================================================
; Mission 3. Set the figure parameters
; ==============================================================

    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",fig_name)  ; open a ps file
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

   ; res@gsnMaximize      = True       ; fill up the page
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
    res@tmYLTickSpacingF = 10
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
	pres@pmLabelBarWidthF   = 0.7	
	;pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    ;pres@lbLabelAutoStride    = False
	;pres@lbLabelStride       = 4 
	pres@lbTitleString       = "SST (K)"
	pres@lbLabelFontHeightF = 0.02 
	pres@lbTitleFontHeightF = 0.02
	pres@pmLabelBarOrthogonalPosF = -0.03           ; move label bar down

    res@tmXBLabelFontHeightF = global_font
    res@tmYLLabelFontHeightF = global_font
    res@gsnStringFontHeightF = global_font
    

    res@mpMaxLatF  = latN
    res@mpMinLatF  = latS

    do i =0,3
        res@gsnLeftString = fig_num(i)
        res@gsnCenterString = season +" "+ exp_code(i)

        do j = 0,n_warm(i)-1
	        cmp_var1_pos=cmp_var1_pos+var1(idx_warm(i,j):idx_warm(i,j)+11,:,:)
        end do
        cmp_var1_pos = cmp_var1_pos/(n_warm(i)*1.0)
         
        
        warm_var1_ano    = month_to_season (cmp_var1_pos, season)

    ;----Cold year----
        do j = 0,n_cold(i)-1
            cmp_var1_neg=cmp_var1_neg+var1(idx_cold(i,j):idx_cold(i,j)+11,:,:)
        end do
        cmp_var1_neg = cmp_var1_neg/(n_cold(i)*1.0)
        ;printVarSummary(cmp_var1_neg) 
        
        cold_var1_ano    = month_to_season (cmp_var1_neg, season)

    ;----Composite----
        cmp_var1_ano = (warm_var1_ano-cold_var1_ano)
        if (i .eq. 2) then
            nio_var1_ano = cmp_var1_ano
            cmp_var1_ano = -cmp_var1_ano
        else
            if (i .gt. 2) then
                res@gsnRightString ="R="+sprintf("%4.2f",pattern_cor(nio_var1_ano({latS:latN},{lonL:lonR}),cmp_var1_ano({latS:latN},{lonL:lonR}), 1.0, 0))
            end if
        end if
        printVarSummary(cmp_var1_ano)
        
        plot(i) = gsn_csm_contour_map_ce(wks,cmp_var1_ano,res) ; create a default plot

        cmp_var1_pos = 0
        cmp_var1_neg = 0
    end do

    gsn_panel(wks,plot,(/5,1/),pres)

    draw(plot)
    frame(wks)
end
