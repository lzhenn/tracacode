;***********************************************
; Draw PM2.5 diff between SEN and BASE 
;      from CCTM
;
; jobs:
;   1.Read CCTM 9km data (BASE)
;   2.Post process the data
;   3.Display the figure
;                       L_Zealot
;                       2015-06-15
; 2015-06-15    Created;
; 2015-08-23   Modified to fit PM2.5 from CCTM
; 2015-08-24   Modified to overlap wind from WRF
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"
begin

	g_font =0.022
	g_species = "PM25"
    g_pm25_species = (/"ASO4J","ASO4I","ANO3J","ANO3I","ANH4J","ANH4I","AALKJ","AXYL1J","AXYL2J","AXYL3J",\
                       "ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J",\
                       "ASQTJ","AORGCJ","AORGPAI","AORGPAJ","AECJ","AECI","A25J","A25I","ANAJ","ACLJ",\
                       "ACLI","ANAI","AISO3J","AOLGAJ","AOLGBJ"/)
    g_filetime = (/"07","10","13","16","19","22","25"/) 

; ==============================================================
; Mission1.    Read Wind & PM2.5 & CMAQ_9km lat, lon
; ==============================================================
;do m = 0,dimsizes(g_filetime)-1
    ;wind
;    print("Deal with:"+g_filetime(m))
    
    ;wrf_in      = addfile("/home/yangsong3/data/model/L_Zealot/THESIS_yeq-2015/wrf/wrfout_d02_20101107","r")
	;wrf_var1  = wrf_user_getvar(wrf_in,"U10",-1)  ;var name = U10, timestep = 0
    ;wrf_var1@lat2d = wrf_user_getvar(wrf_in,"XLAT",0)
    ;wrf_var1@lon2d = wrf_user_getvar(wrf_in,"XLONG",0)
	;wrf_var2  = wrf_user_getvar(wrf_in,"V10", -1)  ;var name = U10, timestep = 0
    ;wrf_var2@lat2d = wrf_user_getvar(wrf_in,"XLAT",0)
    ;wrf_var2@lon2d = wrf_user_getvar(wrf_in,"XLONG",0)
    
    ctrl_in      = addfiles("/home/yangsong3/data/model/L_Zealot/THESIS_yeq-2015/cctm/base/201011"+g_filetime+"00_9km.ACONC.ncf","r")
    ctrl_var     = ctrl_in[:]->$g_pm25_species(0)$                 ; znw(bottom_top_stag)
    do i=1,dimsizes(g_pm25_species)-1
        ctrl_var     =ctrl_var+ctrl_in[:]->$g_pm25_species(i)$                 ; znw(bottom_top_stag)
    end do

   ; printVarSummary(ctrl_var)

    latlon_in   =  addfile("/home/yangsong3/data/model/L_Zealot/THESIS_yeq-2015/mcip/GRIDCRO2D_9km","r")
    ctrl_var@lat2d     = latlon_in->LAT(0,0,:,:)                ; znw(bottom_top_stag)
    ctrl_var@lon2d     = latlon_in->LON(0,0,:,:)                ; znw(bottom_top_stag)

   ; ctrl_1111 = new((/74,98/),double)
    ctrl_1111 =  dim_avg_n_Wrap(ctrl_var(437:461,0,:,:),0)
    printVarSummary(ctrl_1111)
;**********************************************************************************************
;MISSION.2		
;**********************************************************************************************


;************************`**********************************************************************
;MISSION.3		Plot Clim monthly mean to check the result
;**********************************************************************************************
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



;  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
;  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

 res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
 res@cnMinLevelValF        = 0          ; set min contour level
 res@cnMaxLevelValF        = 150          ; set max contour level
 res@cnLevelSpacingF       = 2          ; set contour interval

  ;res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnLeftString = ""
;  res@gsnCenterString = "PM2.5 and UV10m" 
  res@gsnRightString = ""
  res@gsnStringFontHeightF = g_font
  res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelStride          = 10
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  
  res@mpMinLatF            = 20       ; zoom in on map
  res@mpMaxLatF            = 25.62
  res@mpMinLonF            = 109.1
  res@mpMaxLonF            = 117.2

  res@mpGeophysicalLineThicknessF = 2.0	;costal line thick
  res@tmXBTickSpacingF = 2
  res@tmYLTickSpacingF = 2

res@tmXBLabelFontHeightF =g_font
res@tmYLLabelFontHeightF = g_font
res@gsnStringFontHeightF = g_font
res@tiMainFontHeightF= g_font
;res@lbLabelFontHeightF = 0.02
;res@pmLabelBarOrthogonalPosF = .12           ; move label bar down
res@tmXBMajorThicknessF = 2.0
res@tmYLMajorThicknessF = 2.0
res@tmXBMinorThicknessF = 2.0
res@tmYLMinorThicknessF = 2.0
res@tmBorderThicknessF = 2.0
res@tmYLMajorLengthF = 0.002


res@mpFillOn                = True
res@mpOutlineOn             = False  ; Use outlines from shapefile
res@cnFillDrawOrder         = "PreDraw"
res@mpDataBaseVersion       = "MediumRes"
res@mpDataSetName           = "Earth..4"
res@mpAreaMaskingOn         = True
res@mpMaskAreaSpecifiers    = (/"China","Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
res@mpLandFillColor         = "white"
res@mpInlandWaterFillColor  = "white"
;res@mpOceanFillColor        = "white"
;res@mpOutlineBoundarySets   = "NoBoundaries"


;set vector resourses
hvres                          = True
hvres@gsnDraw                 = False
hvres@gsnFrame                = False


hvres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
hvres@vcRefAnnoString2On	= False		  ; no 'ref vector' string
hvres@vcRefMagnitudeF         = 10.0             ; define vector ref mag
hvres@vcRefAnnoFontHeightF    = 0.02		 ; define ref vector string font size

hvres@vcRefLengthF            = 0.05            ; define length of vec ref
hvres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
hvres@vcLineArrowHeadMaxSizeF = 0.006
;hvres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
;hvres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
hvres@vcLineArrowThicknessF   = 2.0		  ; arrow thickness		
hvres@vcMinDistanceF          = 0.025		  ; arrow distance between each other



;hvres@tiMainString             = season+" WIND850 & PRECIPT "+exp_names(i)+"-CTRL"
hvres@gsnAddCyclic         = False        ; plotted data are not cyclic
;hvres@mpFillOn             = False        ; turn off map fill
hvres@gsnCenterString = ""
hvres@gsnRightString = ""
 ; do j = 0,71
	
    g_fig_name =  "../../fig/CMAQ_PM25_20101125"
	wks = gsn_open_wks("png",g_fig_name)       ; open file to plot 
    ;-----------------------------------------------------------------------------

    ;plot = new((/1/),graphic)

    ;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;  gsn_define_colormap(wks,"precip4_diff_19lev")
    ;  gsn_define_colormap(wks,"precip_diff_12lev")
    ; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    ; gsn_define_colormap(wks,"NCV_jaisnd")
    ; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
    ; gsn_define_colormap(wks,"MPL_ocean")
     gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

     ;gsn_reverse_colormap(wks)
     ; hvres@gsnLeftString = "201011"+g_filetime(m)+" +"+j+"h"
     ; print(j+"h")
     ; plotV = gsn_csm_vector(wks,wrf_var1(j,:,:),wrf_var2(j,:,:),hvres) ; dim1 = 0 for lvl = 0
      plot = gsn_csm_contour_map(wks,ctrl_1111,res) ; dim1 = 0 for lvl = 0
     ; overlay(plot,plotV)
     ;>============================================================<
            ;                      add China map
            ;>------------------------------------------------------------<
             cnres           = True
             cnres@china     = False       ;draw china map or not
             cnres@river     = False       ;draw changjiang&huanghe or not
             cnres@province  = True       ;draw province boundary or not
             cnres@nanhai    = False       ;draw nanhai or not 
             cnres@diqu      = True       ; draw diqujie or not

             chinamap = add_china_map(wks,plot,cnres)
     ;>============================================================<
      draw(plot)
      frame(wks)
     ; delete([/wks,plotV,plot,chinamap/])
;    end do

 ;   delete([/wrf_var1,wrf_var2,ctrl_var/])
;  end do
end
