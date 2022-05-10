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
    g_pm25_species = (/"ANH4J","ANH4I"/);NH4 in pm25
    ;g_pm25_species = (/"ASO4J","ASO4I","ANO3J","ANO3I","ANH4J","ANH4I","AALKJ","AXYL1J","AXYL2J","AXYL3J",\
    ;                   "ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J",\
    ;                   "ASQTJ","AORGCJ","AORGPAI","AORGPAJ","AECJ","AECI","A25J","A25I","ANAJ","ACLJ",\
    ;                   "ACLI","ANAI","AISO3J","AOLGAJ","AOLGBJ"/)
    g_filetime = (/"07","10","13","16","19","22","25"/)
    ;g_filename = (/"sw","gz","fs","sz","gd1","gd2","gd3","gd4","gd5"/)
    g_filename = (/"sw","gz","gd1","gd4","gd5"/)
    ;g_fig_name =  "../fig/CMAQ_grid_city"
    g_fig_name = "../fig/box-plot_city_NH4_contribution"

; ==============================================================
; Mission1.    Read PM2.5
; ==============================================================

    ;read PM25 CCTM ctrl result
    ctrl_in      = addfiles("../data/CCTM/base/201011"+g_filetime+"00_3km.ACONC.ncf","r")
    ctrl_var     = ctrl_in[:]->$g_pm25_species(0)$                 ; znw(bottom_top_stag)
    do i=1,dimsizes(g_pm25_species)-1
        ctrl_var     =ctrl_var+ctrl_in[:]->$g_pm25_species(i)$                 ; znw(bottom_top_stag)
    end do
    dim_ctrl_var = dimsizes(ctrl_var)
    g_hours =dim_ctrl_var(0)
    ;read city grid data
    grid0 = asciiread("../data/CCTM/3km_eve_city_1.txt",(/152,110/),"float")
    grid1 = transpose(grid0)
    grid = conform(ctrl_var(:,0,:,:),grid1,(/1,2/))
    
    ;read PM25 CCTM sen result
    sen_var = new((/dimsizes(g_filename),g_hours,1,110,152/),double)  
    do i = 0,dimsizes(g_filename)-1
        sen_in = addfiles("../data/CCTM/no-"+g_filename(i)+"-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")    
        sen_var(i,:,:,:,:)     = sen_in[:]->$g_pm25_species(0)$                 ; znw(bottom_top_stag)
        do j=1,dimsizes(g_pm25_species)-1
            sen_var(i,:,:,:,:)     =sen_var(i,:,:,:,:)+sen_in[:]->$g_pm25_species(j)$                 ; znw(bottom_top_stag)
        end do
        ;delete(sen_in)
    end do

    grid_sen = conform(sen_var(:,:,0,:,:),grid1,(/2,3/))
;**********************************************************************************************
;MISSION.2   Compute GZ PM2.5 diurnal domain contribution  
;**********************************************************************************************
    ;pick up the GZ domain
    ctrl_var_gz = new((/g_hours,110,152/),double)
    ctrl_var_gz@_FillValue = -999.0
    ctrl_var_gz = where(grid .eq. 1.00, ctrl_var(:,0,:,:), ctrl_var_gz@_FillValue)
    
    sen_var_gz = new((/dimsizes(g_filename),g_hours,110,152/),double)
    sen_var_gz@_FillValue = -999.0
    sen_var_gz = where(grid_sen .eq. 1.00, sen_var(:,:,0,:,:), sen_var_gz@_FillValue)
    
    ;sum of ctrl & sen
    ctrl_sum = new((/g_hours/),double)
    do i = 0,g_hours-1
        ctrl_sum(i) = sum(ctrl_var_gz(i,:,:))
    end do 
    sen_sum = new((/dimsizes(g_filename),g_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        do j = 0,g_hours-1
            sen_sum(i,j) = sum(sen_var_gz(i,j,:,:))
        end do
    end do
    
    ;contribution
    diff = new((/dimsizes(g_filename),g_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        diff(i,:) = sen_sum(i,:)-ctrl_sum
    end do
    diff_sum = new((/g_hours/),double)
    do i = 0,g_hours-1
        diff_sum(i) = -sum(diff(:,i))
    end do
    contri = new((/dimsizes(g_filename),g_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        contri(i,:) = -diff(i,:)/diff_sum
        ;contri(i,:) = -diff(i,:)
    end do
    printVarSummary(contri)
    contri_no_day1 = contri(:,48:457)
; ==============================================================
; Mission 3. Prepare the figure data
; ==============================================================

	labels    = g_filename	
	x = (/-2., -1., 0., 1., 2./)
	contri_avg = dim_avg_n_Wrap(contri_no_day1,1) ;each exp avg
	do i = 0,dimsizes(labels)-1
		qsort(contri_no_day1(i,:))
	end do

    ; y1_box(a,b) 
    ;   a = number of experiments
    ;   b = 4 Max
    ;   b = 3 Upper 1/4
    ;   b = 2 Medium
    ;   b = 1 Lower 1/4
    ;   b = 0 Min

    noday1_size = dimsizes(contri_no_day1)
    hours_noday1 = noday1_size(1)

	y1_box = new((/dimsizes(labels),5/),"double")
    quarter=toint(hours_noday1/4)
	y1_box(:,0) = contri_no_day1(:,0)
	y1_box(:,1) = contri_no_day1(:,quarter-1)
	y1_box(:,2) = (contri_no_day1(:,quarter*2)+contri_no_day1(:,quarter*2-1))/2
	y1_box(:,3) = contri_no_day1(:,3*quarter-1)
	y1_box(:,4) = contri_no_day1(:,hours_noday1-1)


	;********************************************************
	; create the plot
	;********************************************************   
   wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
   ;plot_box = new((/4/),graphic)


	res            = True                         ; plot mods desired
	res@tmXBLabels = labels ; labels for each box
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    res@tiMainFontHeightF    = g_font
    res@trYMinF = -0.1
    res@trYMaxF = 1.0
    res@tmYROn = True
    res@tmXTOn = True
    res@tmXTBorderOn = True 
    res@tmYRBorderOn = True 
	;**********************************************
	; resources for polylines that draws the boxes
	;**********************************************  
	llres                   = True			
	llres@gsLineThicknessF  = 3.0                 ; line thickness 
	;**********************************************
	; resources that control color and width of boxes
	;**********************************************  
	opti          = True			
	opti@boxWidth = .5				; Width of box (x units)
	opti@boxColors = (/"black","blue","red","orange","purple"/)  	; Color of box(es)
	;***********************************************
	
	
   ;***********************************************
   ;add polymarker res
   ;***********************************************
   mres               = True                     ; marker mods desired
   mres@gsMarkerIndex = 3                        ; polymarker style
   mres@gsMarkerSizeF = 20.                      ; polymarker size
   mres@gsMarkerColor = "navy blue"                    ; polymarker color
   mres@gsMarkerThicknessF = 2.0

   ;***********************************************
   ;add refline res
   ;***********************************************

;	lnres = True
;	lnres@gsLineThicknessF = 3.0
	
	;siglnres@gsLineThicknessF = 3.0
	;siglnres@gsLineDashPattern = 2
	;siglnres@gsLineColor = "red"
	
	
	res@tiMainString = "Ammonium"
	plot_box = boxplot(wks,x,y1_box,opti,res,llres)	; All 3 options used...
;	dum1 = gsn_add_polyline(wks,plot_box,(/-3.,3./),(/0,0/),lnres)	
    dum2 = gsn_add_polymarker(wks,plot_box,x,contri_avg,mres) 

   gsn_panel(wks,plot_box,(/1,1/),False)

end
