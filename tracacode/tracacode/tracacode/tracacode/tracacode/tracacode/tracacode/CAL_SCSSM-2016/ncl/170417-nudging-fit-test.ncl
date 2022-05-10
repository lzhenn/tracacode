;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = (/"U","V"/)
    g_data3_path ="/users/yangsong3/L_Zealot/F/DATA_Nudging/test_2mon_nudg_10day/"
    g_data_org="/users/yangsong3/L_Zealot/F/DATA_Nudging/Nudging_UV.nc"
    g_case="10day"
    g_font = 0.025
    g_lvl=850
  
    g_latN=60
    g_latS=-60
    g_lonE=360
    g_lonW=0


    all_files = systemfunc ("ls "+g_data3_path); ../"+case_name+"/"+exedir+"/*cam.h0.002[0-4]*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in      = addfiles (g_data3_path+all_files, "r")   ; note the "s" of addfile

    var1  =ctrl_in[:]->U
    var2  =ctrl_in[:]->V
  
    ctrl_in1     = addfile (g_data_org, "r")
    var1_org=ctrl_in1->U
    var2_org=ctrl_in1->V
    printVarSummary(var1_org)
    var1_diff= var1_org
    var2_diff= var2_org
    ws_org=wind_speed(var1_org,var2_org)
    ws_diff=ws_org
    ws=wind_speed(var1,var2)
    dimvar=dimsizes(var1)
    time0=dimvar(0)
    print(ws&lev)
; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")


;-----------------------------------------------------------------------------
    res                  = True       ; use plot options

    res@cnFillOn             = True               ; turn on color for contours
    res@cnLinesOn            = False              ; turn off contour lines
    res@cnLineLabelsOn       = False              ; turn off contour line labels



    ;  res@mpLandFillColor       = "gray"            ; set land to be gray

    ;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
    ;   res@cnLevels = ispan(0,60,10)
    ;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
    ;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
    ;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        = -10         ; set min contour level
    res@cnMaxLevelValF        = 10          ; set max contour level
    res@cnLevelSpacingF       = 1          ; set contour interval

    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

    ;  res@gsnSpreadColors      = True               ; use full color map
    ;  res@gsnSpreadColorStart  = 2               ; start at color 17
    ;  res@gsnSpreadColorEnd    = 14                ; end at color 200

    ;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
    res@gsnStringFontHeightF = g_font

    res@gsnMaximize      = True       ; fill up the page
    ;res@gsnAddCyclic   = False
    res@gsnPaperOrientation = "portrait"
    ;res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


    res@lbLabelBarOn = True   ; turn off the label bar
    res@lbOrientation          = "vertical"
    res@lbLabelFontHeightF  = g_font              ; make labels smaller
    res@lbLabelStride = 2 


    res@mpFillOn   = False     ; turn off gray continents
    res@mpGeophysicalLineThicknessF = 2
    res@mpGeophysicalLineColor      = "black";"white" 
    res@mpFillDrawOrder="PostDraw"
    res@mpMaxLatF  = g_latN
    res@mpMinLatF  = g_latS
    res@mpMaxLonF  = g_lonE
    res@mpMinLonF  = g_lonW

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
    res@tmXBLabelFontHeightF = g_font
    ; res@tmXBLabelFontAspectF = 1.6
    res@tmXBLabelFontThicknessF = 2.0
    res@tmYLLabelFontHeightF = g_font
    ; res@tmYLLabelFontAspectF = 1.3
    res@tmYLLabelFontThicknessF = 2.0
    ; res@tmYLLabelFontQuality =
    ;-----------------------------------------------------------------------------
     
    res@gsnLeftString = ""
    res@gsnRightString = ""
       
    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    vcres@vcRefAnnoOrthogonalPosF = -1.0             ; move ref vector up
    vcres@vcRefMagnitudeF         = 5.0             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.03
    vcres@vcRefAnnoString1  = "5 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.02

    vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector
    vcres@vcLineArrowHeadMinSizeF   = 0.01
    vcres@vcLineArrowHeadMaxSizeF   = 0.01


    do ii =0,time0-1 
        g_fig_name="../fig/nudging/diff-"+g_case+g_lvl+"-"+sprinti("%0.3i", ii)
        wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
        gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
        res@gsnLeftString="UV "+g_lvl+"hPa Day"+ sprinti("%0.3i",ii)   

        var1_diff=var1(ii,:,:,:)-var1_org(:,:,:)
        var2_diff=var2(ii,:,:,:)-var2_org(:,:,:)
        ws_diff=ws(ii,:,:,:)-ws_org(:,:,:)

        plot_sh= gsn_csm_contour_map(wks,ws_diff({g_lvl},:,:),res) ; create a default plot
        plot_V = gsn_csm_vector(wks,var1_diff({g_lvl},:,:),var2_diff({g_lvl},:,:),vcres) 
        overlay(plot_sh,plot_V)
        draw(plot_sh)
        frame(wks)
    end do




    
end
