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

;SCS-PhS region
    

	latS    =   -90.0
	latN    =   90.0
    lonL    =   0
    lonR    =   360.
   
    data_file_in   =   "/users/yangsong3/CESM/input/lnd/clm2/surfdata/surfdata_1.9x2.5_bare_ground_simyr2000_c091005.nc"
    data_file_out   =   "/users/yangsong3/CESM/input/lnd/clm2/surfdata/surfdata_1.9x2.5_bare_ground_simyr2000_c091005.nc"
    
    
    fig_name   =   "../fig/insert_ssta"

    global_font = 0.025
    


;------------------Read clim sst-------------------------------
    ctrl_file1   = data_file_in
    ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
    var1  = ctrl_in1->SOIL_COLOR			; p for unify the var name
    var1!0="lat"
    var1&lat=fspan(-90,90,96)
    var1&lat@units="degrees_north"
    var1!1="lon"
    var1&lon=fspan(0,357.5,144)
    var1&lon@units="degrees_east"
    var1_new=var1

;------------Operation--------------------

    var1_new=where(var1_new .gt. 0, 15,0)

; ==============================================================
; Mission 3. Set the figure parameters
; ==============================================================

    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("x11",fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot = new((/3/),graphic)

    ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;  gsn_define_colormap(wks1,"precip4_diff_19lev")
    ;  gsn_define_colormap(wks,"precip_diff_12lev")
    ; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    ;gsn_define_colormap(wks,"ViBlGrWhYeOrRe")


    ;-----------------------------------------------------------------------------
    res                  = True       ; use plot options
    res@cnFillPalette        = "BlAqGrYeOrReVi200"
    res@cnFillOn             = True               ; turn on color for contours
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off contour line labels



;    i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
;    j = NhlNewColor(wks,1,0.,0.)
    ;  res@mpLandFillColor       = "gray"            ; set land to be gray

    ;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
    ;   res@cnLevels = ispan(0,60,10)
    ;  res@cnFillColors =(/-1,20,47,57,94,127,152/)

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = 25.          ; set min contour level
    res@cnMaxLevelValF        = 31.          ; set max contour level
    res@cnLevelSpacingF       = 0.25          ; set contour interval

    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

 ;   res@gsnSpreadColors      = True               ; use full color map
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
    ;res@mpFillDrawOrder="PostDraw"

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
    res@tmXBTickSpacingF = 60
    res@tmYLTickSpacingF = 30
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
    
    res@tmXBLabelFontHeightF = global_font
    res@tmYLLabelFontHeightF = global_font
    res@gsnStringFontHeightF = global_font
     
    res@mpMaxLatF  = latN
    res@mpMinLatF  = latS
; ==============================================================
; Mission 3. Draw patterns
; ==============================================================



   
    res@cnFillPalette        = "radar_1"
    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = 0          ; set min contour level
    res@cnMaxLevelValF        = 20         ; set max contour level
    res@cnLevelSpacingF       = 1          ; set contour interval
    res@cnFillMode            = "CellFill"
    res@gsnLeftString = "original soil color"


    plot(0) = gsn_csm_contour_map_ce(wks,var1,res) ; create a default plot
    res@gsnLeftString = "changed soil color"
    plot(1) = gsn_csm_contour_map_ce(wks,var1_new,res) ; create a default plot

    gsn_panel(wks,plot,(/2,1/),False)
exit
; ==============================================================
; Mission 4. Output sst forcing file
; ==============================================================
    
    
    print("*************")
    print("*************")
    print("*************")
    print("*************")
    print("*************")


	ncdf     = addfile(data_file_out ,"w")  ; open output netCDF file
	ncdf->PCT_PFT=var1_new
end
