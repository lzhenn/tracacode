;***********************************************
; Draw PM2.5 diff between SEN and BASE 
;      from CCTM
;
; jobs:
;   1.Read CCTM data (SEN and BASE)
;   2.Post process the data
;   3.Display the figure
;                       L_Zealot
;                       2015-06-15
; 2015-06-15    Created;
; 2015-08-19    Modified to fit PM2.5 from CCTM
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/cnmap/cnmap.ncl"
begin

	g_font =0.035
	g_species = "PM25"
    g_pm25_species = (/"ASO4J","ASO4I","ANO3J","ANO3I","ANH4J","ANH4I","AALKJ","AXYL1J","AXYL2J","AXYL3J",\
                       "ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J",\
                       "ASQTJ","AORGCJ","AORGPAI","AORGPAJ","AECJ","AECI","A25J","A25I","ANAJ","ACLJ",\
                       "ACLI","ANAI","AISO3J","AOLGAJ","AOLGBJ"/)
    g_filetime = (/"07","10","13","16","19","22","25"/)
    ;g_fig_name =  "../fig/CMAQ_grid_city"
    g_fig_name = "../fig/city_contribution"
    g_sen_number = 4
 

; ==============================================================
; Mission1.    Read PM2.5
; ==============================================================
    ;read city grid data
    grid0 = asciiread("../data/CCTM/3km_eve_city_1.txt",(/152,110/),"float")
    grid = transpose(grid0)

    ;read PM25 CCTM ctrl result
    ctrl_in      = addfiles("../data/CCTM/base/201011"+g_filetime+"00_3km.ACONC.ncf","r")
    ctrl_var     = ctrl_in[:]->$g_pm25_species(0)$                 ; znw(bottom_top_stag)
    do i=1,dimsizes(g_pm25_species)-1
        ctrl_var     =ctrl_var+ctrl_in[:]->$g_pm25_species(i)$                 ; znw(bottom_top_stag)
    end do
    
    ;read PM25 CCTM sen result
    sen_nosw_in      = addfiles("../data/CCTM/no-sw-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")
    sen_var_nosw     = sen_nosw_in[:]->$g_pm25_species(0)$           ; znw(bottom_top_stag)
    do i=1,dimsizes(g_pm25_species)-1
        sen_var_nosw     =sen_var_nosw+sen_nosw_in[:]->$g_pm25_species(i)$                 ; znw(bottom_top_stag)
    end do

    sen_nogz_in      = addfiles("../data/CCTM/no-gz-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")
    sen_var_nogz     = sen_nogz_in[:]->$g_pm25_species(0)$           ; znw(bottom_top_stag)
    do i=1,dimsizes(g_pm25_species)-1
        sen_var_nogz     =sen_var_nogz+sen_nogz_in[:]->$g_pm25_species(i)$                 ; znw(bottom_top_stag)
    end do

    sen_nofs_in      = addfiles("../data/CCTM/no-fs-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")
    sen_var_nofs     = sen_nofs_in[:]->$g_pm25_species(0)$           ; znw(bottom_top_stag)
    do i=1,dimsizes(g_pm25_species)-1
        sen_var_nofs     =sen_var_nofs+sen_nofs_in[:]->$g_pm25_species(i)$                 ; znw(bottom_top_stag)
    end do

    sen_nosz_in      = addfiles("../data/CCTM/no-sz-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")
    sen_var_nosz     = sen_nosz_in[:]->$g_pm25_species(0)$           ; znw(bottom_top_stag)
    do i=1,dimsizes(g_pm25_species)-1
        sen_var_nosz     =sen_var_nosz+sen_nosz_in[:]->$g_pm25_species(i)$                 ; znw(bottom_top_stag)
    end do

;**********************************************************************************************
;MISSION.2   Compute GZ PM2.5 diurnal domain contribution  
;**********************************************************************************************
    ;diurnal average(sen_var_t_avg(9,7,110,152),0 for sw,1 for gz,2 for fs,3 for sz ...)
    ctrl_var_t_avg = new((/21,110,152/),double)
    do i=0,20
        ctrl_var_t_avg(i,:,:) = dim_avg_n_Wrap(ctrl_var(24*i:(23+24*i),0,:,:),0)
    end do
    
    sen_var_t_avg = new((/g_sen_number,21,110,152/),double)
    do i=0,20
        sen_var_t_avg(0,i,:,:) = dim_avg_n_Wrap(sen_var_nosw(24*i:(23+24*i),0,:,:),0)
    end do
   
    do i=0,20
        sen_var_t_avg(1,i,:,:) = dim_avg_n_Wrap(sen_var_nogz(24*i:(23+24*i),0,:,:),0)
    end do
   
    do i=0,20
        sen_var_t_avg(2,i,:,:) = dim_avg_n_Wrap(sen_var_nofs(24*i:(23+24*i),0,:,:),0)
    end do

    do i=0,20
        sen_var_t_avg(3,i,:,:) = dim_avg_n_Wrap(sen_var_nosz(24*i:(23+24*i),0,:,:),0)
    end do
    
    ;pick up the GZ domain
    ctrl_var_t_avg@_FillValue = -999.0
    do i = 0,20
        ctrl_var_t_avg(i,:,:) = where(grid .eq. 1.00, ctrl_var_t_avg(i,:,:), ctrl_var_t_avg@_FillValue)
    end do
    sen_var_t_avg@_FillValue = -999.0
    do i = 0,g_sen_number-1
        do j = 0,20
            sen_var_t_avg(i,j,:,:) = where(grid .eq. 1.00, sen_var_t_avg(i,j,:,:), sen_var_t_avg@_FillValue)
        end do
    end do

    ;sum of ctrl & sen
    ctrl_sum = new((/21/),double)
    do i = 0,20
        ctrl_sum(i) = sum(ctrl_var_t_avg(i,:,:))
    end do 
    sen_sum = new((/g_sen_number,21/),double)
    do i = 0,g_sen_number-1
        do j = 0,20
            sen_sum(i,j) = sum(sen_var_t_avg(i,j,:,:))
        end do
    end do
    
    ;contribution
    diff = new((/g_sen_number,21/),double)
    do i = 0,g_sen_number-1
        diff(i,:) = sen_sum(i,:)-ctrl_sum
    end do
    diff_sum = new((/21/),double)
    do i = 0,20
        diff_sum(i) = -sum(diff(:,i))
    end do
    contri = new((/g_sen_number,21/),double)
    do i = 0,g_sen_number-1
        contri(i,:) = -diff(i,:)/diff_sum
    end do
    print(contri(0,:))
    print(contri(1,:))
    print(contri(2,:))
    print(contri(3,:))
    exit
;**********************************************************************************************
;MISSION.3		Plot Clim monthly mean to check the result
;**********************************************************************************************
	wks = gsn_open_wks("png",g_fig_name)       ; open file to plot 
;-----------------------------------------------------------------------------

plot = new((/1/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"NCV_jaisnd")
; gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
; gsn_define_colormap(wks,"MPL_ocean")
 gsn_define_colormap(wks,"MPL_PuBuGn")

 gsn_reverse_colormap(wks)


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
 ;res@cnMinLevelValF        = -20          ; set min contour level
 ;res@cnMaxLevelValF        = 0          ; set max contour level
 ;res@cnLevelSpacingF       = 0.5          ; set contour interval

;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
;  res@gsnSpreadColorStart  = 2               ; start at color 17
;  res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnLeftString = "(c)"
  res@gsnCenterString = g_species
  res@gsnRightString = ""
  res@gsnStringFontHeightF = g_font
  ;res@gsnMaximize      = True       ; fill up the page
  ;res@gsnAddCyclic   = True;False
  ;res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero
  


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1



  plotV = gsn_csm_contour(wks,sen_var_t_avg(0,0,:,:),res) ; dim1 = 0 for lvl = 0
 
  draw(plotV)
  frame(wks)

end
