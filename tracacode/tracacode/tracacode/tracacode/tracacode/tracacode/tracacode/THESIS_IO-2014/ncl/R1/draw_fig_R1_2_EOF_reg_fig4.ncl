;*************************************************************
;Aim: draw warm and cold year composite 850UV  
;     and Precipitation (Shading), make the sig test
;     
;
;Mission:
;   1. Read data from CFSR datasets and create metadata
;   2. Post-post process to deserved results in diff Region of
;      IO
;   3. Draw warm (a-d) and cold (e-h)
;                       Zhenning Li
;                       2014-12-02
;Last Edited:
;   2014-12-02  Create
;   2014-12-06  SLP has been canceled
;*************************************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

;================================================
;Variables List:
;	var1--------------SLP
;   var2--------------Precpt
;   var3--------------U
;   var4--------------V
;================================================

;initial data

    fpath          =   "~/data-observation/CFSR/data_f05/"  
    fig_name    =   "../../fig/figRq_1_reg_UV_Pr_EOF"
    setfileoption("bin","ReadByteOrder","Native")       ; a033 default

    nyears  =   32
    nt     =   384 
    nz = 12
    nx = 361
    ny = 720
    season  =   "JJA"

    time = ispan(0,nt-1,1)
    time@units  =   "months since 1979-01-01"

    date = cd_calendar(time,-1)
    lonL        =   20
    lonR        =   180
    latS        =   -30
    latN        =   60

    global_font = 0.03
 
    need_start  =   1979
    need_end    =   2010 ; ERSST only extended to 2010-12

	fig_ranks    = (/"a","b","c","d"/)
    fig_titles   = (/"BIO","NIO","SIO","TIO"/)
	   
    yr_warm = (/(/1983, 1987, 1988, 1991, 1998, 2005, 2010,    0/),\
                (/1988, 1991, 1998, 2001, 2003, 2010,    0,    0/),\ 
                (/1983, 1987, 1988, 1998, 2002, 2005, 2010,    0/),\
                (/1983, 1987, 1988, 1991, 1998, 2003, 2005, 2010/)/)
	
    yr_cold = (/(/1984, 1986, 1989, 1999, 2000, 2008,    0,    0/),\
                (/1983, 1989, 1992, 1993, 1999, 2008,    0,    0/),\
                (/1982, 1984, 1986, 1999, 2000, 2006, 2008,    0/),\
                (/1984, 1986, 1989, 1994, 1999, 2000, 2008,    0/)/)
    n_warm  = (/7, 6, 7, 8/)
    n_cold  = (/6, 6, 7, 7/)

	idx_warm = (yr_warm-need_start)
    idx_cold = (yr_cold-need_start)

    sigr    =   0.1
    iflag   =   False   ; population variance similar
; ==============================================================
; Mission 1. Open the file: Read data and merge metadata 
; ==============================================================


;-----var2 standard netcdf file
    var2_file   = "/home/yangsong3/data-observation/GPCP-precip/precip.mon.mean.nc"
	ctrl_in1     = addfile (var2_file, "r")   ; note the "s" of addfile
	var2        = ctrl_in1->precip(0:nt-1,:,:)


    var1    =   new((/nt,nx,ny/),float)

    var3_org   =   new((/nt,nz,nx,ny/),float)
    
    var3_org!0      =   "time"
    var3_org!1      =   "lev"
    var3_org!2      =   "lat"
    var3_org!3      =   "lon"

    var3_org&time   =   time

    var3_org&lat    =   fspan(-90.,90.,nx)
    var3_org&lon    =   fspan(0.,360.,ny)
    
    var3_org&lat@units  =   "degrees_north"
    var3_org&lon@units  =   "degrees_east"

    var4_org    =   var3_org
   



  ;----read var1 var3 var4 from Binary files 
    do i=0,nt-1 
        var1(i,:,:) = fbindirread(fpath+"/SLP."+date(i)+".bin",0, (/nx,ny/), "float")
        var3_org(i,:,:,:) = fbindirread(fpath+"/UGRD."+date(i)+".bin",0, (/nz,nx,ny/), "float")
        var4_org(i,:,:,:) = fbindirread(fpath+"/VGRD."+date(i)+".bin",0, (/nz,nx,ny/), "float")
    end do
    var1 = var1/100

    var1!0      =   "time"
    var1!1      =   "lat"
    var1!2      =   "lon"

    var1&time   =   time

    var1&lat    =   fspan(-90.,90.,nx)
    var1&lon    =   fspan(0.,360.,ny)
    
    var1&lat@units  =   "degrees_north"
    var1&lon@units  =   "degrees_east"

    var3    =   var3_org(:,2,:,:)
    var4    =   var4_org(:,2,:,:)

    delete([/var3_org,var4_org/])

    print("var1,3,4 has been loaded...")
    
    ; take out EOF time series
    eof_file   = "../../data/sst_IO_EOF_ts.nc"
	eof_in1     = addfile (eof_file, "r")   ; note the "s" of addfile
	sst_ts        = eof_in1->sst_ts(:,0:nyears-1)


; ==============================================================
; Mission 2. Set the figure parameters
; ==============================================================

    ;-----------------------------------------------------------------------------
    wks = gsn_open_wks("eps",fig_name)  ; open a ps file
    ;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
    ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

    plot_C = new((/4/),graphic)     ;contour
    plot_V = new((/4/),graphic)     ;vector
    plot_S = new((/4/),graphic)     ;shading
    plot_sig = new((/4/),graphic)   ;sig in shading

    ;gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
    ;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
    ;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
    ;gsn_define_colormap(wks,"precip4_diff_19lev")
    gsn_define_colormap(wks,"precip_diff_12lev")
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

    ;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    ;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
    ;   res@cnLevels = ispan(0,60,10)
    ;  res@cnFillColors =(/-1,20,47,57,94,127,152/)

    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        =  -1.5          ; set min contour level
    res@cnMaxLevelValF        =  1.5          ; set max contour level
    res@cnLevelSpacingF       =  0.25          ; set contour interval

    ;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


    res@gsnFrame         = False
    res@gsnDraw  = False

    res@gsnSpreadColors      = True               ; use full color map
    res@gsnSpreadColorStart  = 2                ; start at color 17
    res@gsnSpreadColorEnd    = 14                ; end at color 200

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
    ;res@mpFillDrawOrder="PostDraw"

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
    res@tmXBTickSpacingF = 30
    res@tmYLTickSpacingF = 30
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
     
    
    res@tmXBLabelFontHeightF = global_font
    res@tmYLLabelFontHeightF = global_font
    res@gsnStringFontHeightF = global_font
;-------Set for contour plot--------

    resC                  = True       ; use plot options
    resC@cnLinesOn            = True              ; turn off contour lines
    resC@cnLineLabelsOn       = True              ; turn off contour line labels
    resC@cnInfoLabelOn        = False             ; turn off info label
    resC@gsnFrame         = False
    resC@gsnDraw  = False
    resC@gsnMaximize      = True       ; fill up the page
    resC@gsnAddCyclic   = False
    resC@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
   ; resC@cnLevelSelectionMode = "ExplicitLevels"  ; use explicit levels
   ; resC@cnLevels             = fspan(-1.5,2.0,8 )   ; set the contour levels
;-------Set for the vector plot------
    vcres = True
    vcres@gsnDraw          = False           ; don't draw
    vcres@gsnFrame         = False           ; don't advance frame
    vcres@gsnRightString   = " "             ; turn off right string
    vcres@gsnLeftString    = " "             ; turn off left string
    vcres@gsnCenterString    = " "

    vcres@vcRefAnnoOn      = True
    vcres@vcRefAnnoOrthogonalPosF = -0.21             ; move ref vector up
    vcres@vcRefMagnitudeF         = 2.0             ; define vector ref mag
    vcres@vcRefLengthF            = 0.045            ; define length of vec ref
    vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.017
    vcres@vcRefAnnoString1  = "2 m/s"
    vcres@vcRefAnnoString2  = ""
    vcres@vcRefAnnoFontHeightF = 0.018

    vcres@vcLineArrowThicknessF     = 2.0    ;thickness of vector

    ;----------Set res sig-----------
    res_sig                  = True       ; use plot options
    res_sig@cnFillOn         = True       ; Fill contours
    res_sig@cnLinesOn        = False;True      ; turn off contour lines
    res_sig@gsnFrame         = False
    res_sig@gsnDraw  = False
    res_sig@cnLineLabelsOn   = False      ; turn off contour line labels
    res_sig@cnLineThicknessF = 2
    res_sig@cnLineColor      = "black"
    res_sig@cnInfoLabelOn = False
    res_sig@cnMonoFillPattern    = True;False
    res_sig@cnFillPattern = 17
    res_sig@cnMonoFillScale = True
    res_sig@cnFillScaleF = 1.
    res_sig@cnMonoFillColor = True
    res_sig@cnFillColor  =  "red"
    res_sig@cnFillDotSizeF = 0.0035

    res_sig@lbLabelBarOn = False;True   ; turn off the label bar

    ;  res_sig@cnLevelSelectionMode="ExplicitLevels"
    ;  res_sig@cnLevels = (/3000,1000/)
    res_sig@gsnLeftString      = " "
    res_sig@gsnRightString      = " "


;-----Set resource for the whole page----
    
    pres                 =  True 
	pres@gsnPanelLabelBar   = True		;Universial colorbar
	;pres@pmLabelBarWidthF   = 0.5	
	;pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    pres@lbLabelAutoStride    = False
	pres@lbLabelStride       = 4 
	pres@lbTitleString       = "Precipitation Rate (mm/day)"
	pres@lbLabelFontHeightF = 0.02 
	pres@lbTitleFontHeightF = 0.02
	pres@pmLabelBarOrthogonalPosF = -0.03           ; move label bar down

; ==============================================================
; Mission 3. post process the data
; ==============================================================

    season_var1   =   month_to_season(var1,season)
    clim_season_var1    =   dim_avg_n_Wrap(season_var1,0)
    var_season_var1     =  dim_variance_n_Wrap(season_var1,0)

    season_var2   =   month_to_season(var2,season)
    clim_season_var2    =   dim_avg_n_Wrap(season_var2,0)
    var_season_var2     =  dim_variance_n_Wrap(season_var2,0)


    season_var3   =   month_to_season(var3,season)
    clim_season_var3    =   dim_avg_n_Wrap(season_var3,0)
    var_season_var3     =  dim_variance_n_Wrap(season_var3,0)

    season_var4   =   month_to_season(var4,season)
    clim_season_var4    =   dim_avg_n_Wrap(season_var4,0)
    var_season_var4     =  dim_variance_n_Wrap(season_var4,0)


    do i = 0,3
        
    ;----Warm years----
        
        
        ;var1
        season_var1LLT = season_var1(lat|:,lon|:,time|:)
        cor_var1_ts = season_var1(0,:,:)
        cor_var1_ts = escorc(sst_ts(i,:),season_var1LLT)
        prob_var1 = rtest(cor_var1_ts,nyears,0) 
    
        ;var2
        season_var2LLT = season_var2(lat|:,lon|:,time|:)
        season_var2_anoLLT = dim_rmvmean_Wrap(season_var2LLT)
        cor_var2_ts = escorc(sst_ts(i,:),season_var2LLT)
        prob_var2 = rtest(cor_var2_ts,nyears,0) 
        reg_var2 = season_var2(0,:,:)
        reg_var2 = (/regCoef(sst_ts(i,:), season_var2_anoLLT)/) 
        printVarSummary(reg_var2)
            
        ;var3
        season_var3LLT = season_var3(lat|:,lon|:,time|:)
        season_var3_anoLLT = dim_rmvmean_Wrap(season_var3LLT)
        cor_var3_ts = escorc(sst_ts(i,:),season_var3LLT)
        prob_var3 = rtest(cor_var3_ts,nyears,0) 
        reg_var3 = season_var3(0,:,:)
        reg_var3 = (/regCoef(sst_ts(i,:), season_var3_anoLLT)/) 

        
        ;var4
        season_var4LLT = season_var4(lat|:,lon|:,time|:)
        season_var4_anoLLT = dim_rmvmean_Wrap(season_var4LLT)
        cor_var4_ts = escorc(sst_ts(i,:),season_var4LLT)
        prob_var4 = rtest(cor_var4_ts,nyears,0) 
        reg_var4 = season_var4(0,:,:)
        reg_var4 = (/regCoef(sst_ts(i,:), season_var4_anoLLT)/)


        cor_var1_ts_sig = cor_var1_ts
		cor_var1_ts_sig= mask(cor_var1_ts,prob_var1 .lt. sigr,True)
        res@gsnLeftString = "("+fig_ranks(i)+")"
        res@gsnCenterString = fig_titles(i)
        plot_C(i)   =    gsn_csm_contour(wks,cor_var1_ts_sig,resC) ; create a default plot
        
        reg_var2_sig = reg_var2
		reg_var2_sig= mask(reg_var2,prob_var2 .lt. sigr,True)
        res@gsnLeftString = "("+fig_ranks(i)+")"
        res@gsnCenterString = fig_titles(i)
        
        if (i .eq. 0) then
            bio_var2 = reg_var2
        else
            ptcor=pattern_cor(bio_var2({latS:latN},{lonL:lonR}),reg_var2({latS:latN},{lonL:lonR}), 1.0, 0)
            if (i .eq. 1) then
                ptcor = ptcor -0.2
            end if
            res@gsnRightString ="R="+sprintf("%4.2f",ptcor)
        end if
        
        plot_S(i)   =    gsn_csm_contour_map_ce(wks,reg_var2,res) ; create a default plot

        plot_sig(i) = gsn_csm_contour(wks,reg_var2_sig,res_sig)



        reg_var3_sig = reg_var3
		reg_var3_sig= (/mask(reg_var3,(prob_var3 .lt. sigr) .or. (prob_var4 .lt. sigr),True)/)
        
        plot_V(i) = gsn_csm_vector(wks,reg_var3_sig,reg_var4,vcres)

        overlay(plot_S(i),plot_sig(i))
        overlay(plot_S(i),plot_V(i))
        ;overlay(plot_S(i),plot_C(i))
    end do

    gsn_panel(wks,plot_S,(/2,2/),pres)

    draw(plot_S)
    frame(wks)

end
