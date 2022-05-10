;***********************************************
; Draw UV 10m from wrfout_01
;
; jobs:
;   1.Read wrfout03 U10 V10 var
;   2.Display the Result
;                       L_Zealot
;                       2015-06-15
; 2015-06-15    Created;
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"
begin
; ==============================================================
; Mission1.    Read UV10
; ==============================================================

	;all_files = systemfunc ("ls ../data/*h0.000[3-9]*.nc ../data/*h0.001*.nc")
	
	;setfileoption("nc","SuppressClose",False) ; close too many files

	
	ctrl_in      = addfile("../data/wrfout_d03_201203/wrf01","r")

    ctrl_var1 = wrf_user_getvar (ctrl_in, "ua", 23)
    ctrl_var2 = wrf_user_getvar (ctrl_in, "va", 23)
	;ctrl_var1@lat2d = ctrl_in->XLAT(0,:,:)
    ;ctrl_var1@lon2d = ctrl_in->XLONG(0,:,:)
    ;ctrl_var2@lat2d = ctrl_in->XLAT(0,:,:)
    ;ctrl_var2@lon2d = ctrl_in->XLONG(0,:,:)
    printVarSummary(ctrl_var1)
	printVarSummary(ctrl_var2)
    ;********************************************************
   ; assign the staggard eta values as a vertical "coordinate array" for U V
   ;********************************************************
  ; znu     = ctrl_in->ZNU(0,:)                 ; znw(bottom_top_stag)
  ; ctrl_var1&bottom_top = znu               
  ; ctrl_var2&bottom_top = znu               

;**********************************************************************************************
;MISSION.4		Plot Clim monthly mean to check the result
;**********************************************************************************************

	
	wks = gsn_open_wks("eps","../fig/wrf03_wind850_test")       ; open file to plot 


		hvres                          = True
        hvres@gsnDraw                 = False
        hvres@gsnFrame                = False


		hvres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
		hvres@vcRefAnnoString2On	= False		  ; no 'ref vector' string
		hvres@vcRefMagnitudeF         = 20.0             ; define vector ref mag
		hvres@vcRefAnnoFontHeightF    = 0.03		 ; define ref vector string font size

		hvres@vcRefLengthF            = 0.05            ; define length of vec ref
		hvres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
		hvres@vcLineArrowHeadMaxSizeF = 0.006
        ;hvres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
		;hvres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
		hvres@vcLineArrowThicknessF   = 2.0		  ; arrow thickness		
		hvres@vcMinDistanceF          = 0.035		  ; arrow distance between each other

		

		;hvres@tiMainString             = season+" WIND850 & PRECIPT "+exp_names(i)+"-CTRL"
		hvres@gsnAddCyclic         = False        ; plotted data are not cyclic
		;hvres@mpFillOn             = False        ; turn off map fill
		hvres@gsnLeftString    = " wind vector"
		hvres@gsnRightString   = "m/s" 


		;hvres@mpMinLatF            = 22       ; zoom in on map
		;hvres@mpMaxLatF            = 23
		;hvres@mpMinLonF            = 113
		;hvres@mpMaxLonF            = 114
 

		hvres@mpMinLatF            = min(ctrl_var1@lat2d)        ; zoom in on map
		hvres@mpMaxLatF            = max(ctrl_var1@lat2d)
		hvres@mpMinLonF            = min(ctrl_var1@lon2d)
		hvres@mpMaxLonF            = max(ctrl_var1@lon2d)
		hvres@mpGeophysicalLineThicknessF = 4.0	;costal line thick
        hvres@tmXBTickSpacingF = 1
        hvres@tmYLTickSpacingF = 1




		hvres@tmXBLabelFontHeightF =0.022
		hvres@tmYLLabelFontHeightF = 0.022
		hvres@gsnStringFontHeightF = 0.022
		hvres@tiMainFontHeightF= 0.025
		;hvres@lbLabelFontHeightF = 0.02
		;res@pmLabelBarOrthogonalPosF = .12           ; move label bar down
		hvres@tmXBMajorThicknessF = 5.0
		hvres@tmYLMajorThicknessF = 5.0
		hvres@tmXBMinorThicknessF = 4.0
		hvres@tmYLMinorThicknessF = 4.0
		hvres@tmBorderThicknessF = 4.0

         hvres@mpFillOn                = True
         hvres@mpOutlineOn             = False  ; Use outlines from shapefile
        hvres@cnFillDrawOrder         = "PreDraw"
         hvres@mpDataBaseVersion       = "MediumRes"
         hvres@mpDataSetName           = "Earth..4"
         hvres@mpAreaMaskingOn         = True
         hvres@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
         hvres@mpLandFillColor         = "white"
         hvres@mpInlandWaterFillColor  = "white"
         hvres@mpOceanFillColor        = "white"
         hvres@mpOutlineBoundarySets   = "NoBoundaries"
		plotV = gsn_csm_vector(wks,ctrl_var1(17,:,:),ctrl_var2(17,:,:),hvres) ; dim1 = 0 for lvl = 0
        ;>============================================================<
        ;                      add China map
        ;>------------------------------------------------------------<
         cnres           = True
         cnres@china     = False       ;draw china map or not
         cnres@river     = False       ;draw changjiang&huanghe or not
         cnres@province  = True       ;draw province boundary or not
         cnres@nanhai    = False       ;draw nanhai or not 
         cnres@diqu      = True       ; draw diqujie or not

         chinamap = add_china_map(wks,plotV,cnres)
        ;>============================================================<

        draw(plotV)
        frame(wks)

end
