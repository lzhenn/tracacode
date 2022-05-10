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
    
    ;Guangzhou
    lat0=22.283
    lon0=113.567
    wrf_out = "wrfout_d03_20101101"
	
	ctrl_in      = addfile("../data/wrfout_hpc4/"+wrf_out,"r")
        ;ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	;ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

	ctrl_var1  = wrf_user_getvar(ctrl_in,"U10", -1)  ;var name = U10, timestep = 0
    lat       = ctrl_in->XLAT(0,:,:)
    lon       = ctrl_in->XLONG(0,:,:)

    ctrl_var1@lat2d = wrf_user_getvar(ctrl_in,"XLAT",0)
    ctrl_var1@lon2d = wrf_user_getvar(ctrl_in,"XLONG",0)
	ctrl_var2  = wrf_user_getvar(ctrl_in,"V10", -1)  ;var name = U10, timestep = 0
    ctrl_var2@lat2d = wrf_user_getvar(ctrl_in,"XLAT",0)
    ctrl_var2@lon2d = wrf_user_getvar(ctrl_in,"XLONG",0)
    pos0      =getind_latlon2d(lat,lon,lat0,lon0)
    pos      = pos0(0,:)
    print(lat(pos(0),pos(1))+" "+lon(pos(0),pos(1)))

   ;********************************************************
   ; assign the staggard eta values as a vertical "coordinate array" for U V
   ;********************************************************
  ; znu     = ctrl_in->ZNU(0,:)                 ; znw(bottom_top_stag)
  ; ctrl_var1&bottom_top = znu               
  ; ctrl_var2&bottom_top = znu               
;**********************************************************************************************
;MISSION.2		Post-process
;**********************************************************************************************
    
    ctrl_var1_avg=dim_avg_n_Wrap(ctrl_var1,0)
    ctrl_var2_avg=dim_avg_n_Wrap(ctrl_var2,0)
    var_speed = ctrl_var1
    var_speed = sqrt(ctrl_var1*ctrl_var1+ctrl_var2*ctrl_var2)
    
	print(var_speed(:,pos(0),pos(1)))
;**********************************************************************************************
;MISSION.3		Plot Clim monthly mean to check the result
;**********************************************************************************************

	
	wks = gsn_open_wks("eps","../fig/wrf_10mUV_"+wrf_out)       ; open file to plot 


		hvres                          = True
        hvres@gsnDraw                 = False
        hvres@gsnFrame                = False


		hvres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
		hvres@vcRefAnnoString2On	= False		  ; no 'ref vector' string
		hvres@vcRefMagnitudeF         = 10.0             ; define vector ref mag
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
		hvres@gsnLeftString    = "10m wind vector"
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
        ;hvres@cnFillDrawOrder         = "PreDraw"
         hvres@mpDataBaseVersion       = "MediumRes"
         hvres@mpDataSetName           = "Earth..4"
         hvres@mpAreaMaskingOn         = True
         hvres@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
         hvres@mpLandFillColor         = "white"
         hvres@mpInlandWaterFillColor  = "white"
         hvres@mpOceanFillColor        = "white"
         hvres@mpOutlineBoundarySets   = "NoBoundaries"
		plotV = gsn_csm_vector_map_ce(wks,ctrl_var1_avg,ctrl_var2_avg,hvres) ; dim1 = 0 for lvl = 0
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
