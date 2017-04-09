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
load "$NCL_SELFLIB/file_io.ncl"

begin


;======================================================
;Variables List:
;	t2m--------------Air Temperature (K, TLL)
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    
    ;SCS
    ;g_day_rank=(/135,140,150,155,145,140,150,135,160,145,160,140,160,140,150,125,135,130,140,140,150,135,130,135,145,140,150,140,145,125,150,145,130,140/)
    
    ;BOB
    
   
    g_data3_path ="$DATAOBV/ERA-monthly/V-197901-201408.nc"
    g_data2_path ="$DATAOBV/ERA-monthly/U-197901-201408.nc"
    g_data1_path ="$DATAOBV/ERA-monthly/z-197901-201408.nc"
    g_font = 0.02
    
        
    g_latS=0
    g_latN=90
    g_lonW=0
    g_lonE=360
    g_plevel=200
    
    g_fig_name = "../fig/obv/ERA-UV-HGT-May-Apr"
        
    g_fig_rank    = (/"(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(n)","(o)","(p)","(q)","(r)","(s)"/)
    g_fig_title= "Clim May-Apr Hgt UV"
    ;day_rank=ispan(0,g_day_comp_len-1,1)
    ;day_rank=day_rank(::-1)

    ctrl_in1     = addfile (g_data1_path, "r")   ; note the "s" of addfile
    var1  =short2flt( ctrl_in1->z)
    var1:=var1(0:30*12-1,:,:,:)    
    ctrl_in2     = addfile (g_data2_path, "r")   ; note the "s" of addfile
    var2  =short2flt( ctrl_in2->u)
    var2:=var2(0:30*12-1,:,:,:)    
    
    ctrl_in3     = addfile (g_data3_path, "r")   ; note the "s" of addfile
    var3  =short2flt( ctrl_in1->v)
    var3:=var3(0:30*12-1,:,:,:)    

    var1_clim=clmMonTLLL(var1)
    var2_clim=clmMonTLLL(var2)
    var3_clim=clmMonTLLL(var3)

    diff_var1=var1_clim(0,:,:,:)
    diff_var2=var2_clim(0,:,:,:)
    diff_var3=var3_clim(0,:,:,:)
    diff_var1=var1_clim(4,:,:,:)-var1_clim(3,:,:,:)
    diff_var2=var2_clim(4,:,:,:)-var2_clim(3,:,:,:)
    diff_var3=var3_clim(4,:,:,:)-var3_clim(3,:,:,:)


; ==============================================================
; Mission 3. Set plot parameters and plot
; ==============================================================

;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot_sh = new((/g_day_comp_len/),graphic)
  plot_V = new((/g_day_comp_len/),graphic)
  plot_cn_max = new((/g_day_comp_len/),graphic)
  plot_cn_max_pre = new((/g_day_comp_len/),graphic)
;  plot_sh = new((/2/),graphic)
;  plot_V = new((/2/),graphic)
  wks = gsn_open_wks("png",g_fig_name)  ; open a ps file
 
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")


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
 res@cnMinLevelValF        = -250         ; set min contour level
 res@cnMaxLevelValF        = 250          ; set max contour level
 res@cnLevelSpacingF       = 25          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
;  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  ;res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = False
  res@gsnPaperOrientation = "portrait"
  ;res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = False   ; turn off the label bar
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
  res@tmXBTickSpacingF = 30
  res@tmYLTickSpacingF = 15
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
 

  res3                  = True       ; use plot options
  res3@cnFillOn         = False;True       ; Fill contours
  res3@cnLinesOn        = True      ; turn off contour lines
;for tp masking
  res3@gsnFrame         = False
  res3@gsnDraw  = False
  res3@cnLineLabelsOn   = False      ; turn off contour line labels
  res3@cnLineThicknessF = 4 
  res3@cnInfoLabelOn = False
 
 
  res3@cnLevelSelectionMode="ExplicitLevels"
  res3@cnLevels = (/0./)
  res3@cnLineColor      = "Black"
  res3@gsnLeftString      = " "
  res3@gsnRightString      = " "

  res4=res3
  res4@cnLineColor="Grey"

;************************************************
; create panel
;************************************************
  resP                     = True                ; modify the panel plot
                                                 ; new resource added in NCL V6.4.0
; resP@gsnPanelMainString = "A plot with a common label bar"
                                                 ; use this for NCL V6.3.0 and earlier
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  resP@lbLabelFontHeightF  = 0.015               ; make labels smaller 


        plot_V(0) = gsn_csm_vector(wks,diff_var2({g_plevel},:,:),diff_var3({g_plevel},:,:),vcres) 
        plot_sh(0) = gsn_csm_contour_map(wks,diff_var1({g_plevel},:,:), res) 
        overlay(plot_sh(0),plot_V(0))

    gsn_panel(wks,plot_sh,(/1,1/),resP)
exit

do ii=0,g_day_comp_len-1
    if mod(ii,3) .eq. 0
        jj=ii/3
        res@gsnRightString=""
        res@gsnLeftString=g_fig_rank(jj)
        res@gsnCenterString=g_fig_title(jj)
        plot_cn_max(jj) = gsn_csm_contour(wks,var2_cmp(ii,{g_plevel},:,:),res3)

        if jj .gt. 0 then
            plot_cn_max_pre(jj) = gsn_csm_contour(wks,var2_cmp(ii-3,{g_plevel},:,:),res4)
            overlay(plot_sh(jj),plot_cn_max_pre(jj))
        end if
       ; overlay(plot_sh(jj),plot_cn_max(jj))
    end if
  end do
  gsn_panel(wks,plot_sh,(/2,4/),resP)

end

