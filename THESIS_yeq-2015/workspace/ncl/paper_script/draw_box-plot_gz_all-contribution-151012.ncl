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

	g_font =0.02
	g_species = "PM25"
    g_pm25_species = (/"ASO4J","ASO4I","ANO3J","ANO3I","ANH4J","ANH4I","AALKJ","AXYL1J","AXYL2J","AXYL3J",\
                       "ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J",\
                       "ASQTJ","AORGCJ","AORGPAI","AORGPAJ","AECJ","AECI","A25J","A25I","ANAJ","ACLJ",\
                       "ACLI","ANAI","AISO3J","AOLGAJ","AOLGBJ"/)
    g_filetime = (/"07","10","13","16","19","22","25"/)
    g_filename = (/"sw","gz","fs","sz","gd1","gd2","gd3","gd4","gd5"/)
    g_new_filename = (/"SW","GZ","FS","SZ","ZQS","YX","ZJZ","DH","YD"/)
    g_fig_name = "../../fig/box-plot_gz_contri"
    g_new_hours = 432
; ==============================================================
; Mission1.    Read PM2.5
; ==============================================================

    ;read PM25 CCTM ctrl result
    ctrl_in      = addfiles("../../data/CCTM/base/201011"+g_filetime+"00_3km.ACONC.ncf","r")
    ctrl_var     = ctrl_in[:]->$g_pm25_species(0)$                 ; znw(bottom_top_stag)
    do i=1,dimsizes(g_pm25_species)-1
        ctrl_var     =ctrl_var + ctrl_in[:]->$g_pm25_species(i)$                 ; znw(bottom_top_stag)
    end do

    ctrl_var_so4 = ctrl_in[:]->$g_pm25_species(0)$ 
    ctrl_var_so4 = ctrl_var_so4 + ctrl_in[:]->$g_pm25_species(1)$

    ctrl_var_no3 = ctrl_in[:]->$g_pm25_species(2)$
    ctrl_var_no3 = ctrl_var_no3 + ctrl_in[:]->$g_pm25_species(3)$
    
    ctrl_var_nh4 = ctrl_in[:]->$g_pm25_species(4)$
    ctrl_var_nh4 = ctrl_var_nh4 + ctrl_in[:]->$g_pm25_species(5)$

    ctrl_var_oc = ctrl_in[:]->$g_pm25_species(22)$
    ctrl_var_oc = ctrl_var_oc + ctrl_in[:]->$g_pm25_species(23)$

    ctrl_var_ec = ctrl_in[:]->$g_pm25_species(24)$
    ctrl_var_ec = ctrl_var_ec + ctrl_in[:]->$g_pm25_species(25)$


    dim_ctrl_var = dimsizes(ctrl_var)
    g_hours =dim_ctrl_var(0)
    
    ;read city grid data
    grid0 = asciiread("../../data/CCTM/3km_eve_city_1.txt",(/152,110/),"float")
    grid1 = transpose(grid0)
    grid = conform(ctrl_var(48:479,0,:,:),grid1,(/1,2/))
    
    ;read PM25 CCTM sen result
    sen_var = new((/dimsizes(g_filename),g_hours,1,110,152/),double)  
    do i = 0,dimsizes(g_filename)-1
        sen_in = addfiles("../../data/CCTM/no-"+g_filename(i)+"-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")    
        sen_var(i,:,:,:,:)     = sen_in[:]->$g_pm25_species(0)$                 ; znw(bottom_top_stag)
        do j=1,dimsizes(g_pm25_species)-1
            sen_var(i,:,:,:,:)     =sen_var(i,:,:,:,:)+sen_in[:]->$g_pm25_species(j)$                 ; znw(bottom_top_stag)
        end do
    end do

    sen_var_so4 = new((/dimsizes(g_filename),g_hours,1,110,152/),double)
    do i = 0,dimsizes(g_filename)-1
        sen_in = addfiles("../../data/CCTM/no-"+g_filename(i)+"-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")
        sen_var_so4(i,:,:,:,:)     = sen_in[:]->$g_pm25_species(0)$                 
        sen_var_so4(i,:,:,:,:)     = sen_var_so4(i,:,:,:,:) + sen_in[:]->$g_pm25_species(1)$                
    end do

    sen_var_no3 = new((/dimsizes(g_filename),g_hours,1,110,152/),double)
    do i = 0,dimsizes(g_filename)-1
        sen_in = addfiles("../../data/CCTM/no-"+g_filename(i)+"-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")
        sen_var_no3(i,:,:,:,:)     = sen_in[:]->$g_pm25_species(2)$
        sen_var_no3(i,:,:,:,:)     = sen_var_no3(i,:,:,:,:) + sen_in[:]->$g_pm25_species(3)$
    end do

    sen_var_nh4 = new((/dimsizes(g_filename),g_hours,1,110,152/),double)
    do i = 0,dimsizes(g_filename)-1
        sen_in = addfiles("../../data/CCTM/no-"+g_filename(i)+"-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")
        sen_var_nh4(i,:,:,:,:)     = sen_in[:]->$g_pm25_species(4)$
        sen_var_nh4(i,:,:,:,:)     = sen_var_nh4(i,:,:,:,:) + sen_in[:]->$g_pm25_species(5)$
    end do

    sen_var_oc = new((/dimsizes(g_filename),g_hours,1,110,152/),double)
    do i = 0,dimsizes(g_filename)-1
        sen_in = addfiles("../../data/CCTM/no-"+g_filename(i)+"-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")
        sen_var_oc(i,:,:,:,:)     = sen_in[:]->$g_pm25_species(22)$
        sen_var_oc(i,:,:,:,:)     = sen_var_oc(i,:,:,:,:) + sen_in[:]->$g_pm25_species(23)$
    end do

    sen_var_ec = new((/dimsizes(g_filename),g_hours,1,110,152/),double)
    do i = 0,dimsizes(g_filename)-1
        sen_in = addfiles("../../data/CCTM/no-"+g_filename(i)+"-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")
        sen_var_ec(i,:,:,:,:)     = sen_in[:]->$g_pm25_species(24)$
        sen_var_ec(i,:,:,:,:)     = sen_var_ec(i,:,:,:,:) + sen_in[:]->$g_pm25_species(25)$
    end do
    
    grid_sen = conform(sen_var(:,48:479,0,:,:),grid1,(/2,3/))
;**********************************************************************************************
;MISSION.2.1   Compute GZ PM2.5 diurnal domain contri  
;**********************************************************************************************
    ;pick up the GZ domain
    ctrl_var_gz = new((/g_new_hours,110,152/),double)
    ctrl_var_gz@_FillValue = -999.0
    ctrl_var_gz = where(grid .eq. 1.00, ctrl_var(48:479,0,:,:), ctrl_var_gz@_FillValue)
    
    ctrl_var_gz_so4 = new((/g_new_hours,110,152/),double)
    ctrl_var_gz_so4@_FillValue = -999.0
    ctrl_var_gz_so4 = where(grid .eq. 1.00, ctrl_var_so4(48:479,0,:,:), ctrl_var_gz_so4@_FillValue)

    ctrl_var_gz_no3 = new((/g_new_hours,110,152/),double)
    ctrl_var_gz_no3@_FillValue = -999.0
    ctrl_var_gz_no3 = where(grid .eq. 1.00, ctrl_var_no3(48:479,0,:,:), ctrl_var_gz_no3@_FillValue)

    ctrl_var_gz_nh4 = new((/g_new_hours,110,152/),double)
    ctrl_var_gz_nh4@_FillValue = -999.0
    ctrl_var_gz_nh4 = where(grid .eq. 1.00, ctrl_var_nh4(48:479,0,:,:), ctrl_var_gz_nh4@_FillValue)

    ctrl_var_gz_oc = new((/g_new_hours,110,152/),double)
    ctrl_var_gz_oc@_FillValue = -999.0
    ctrl_var_gz_oc = where(grid .eq. 1.00, ctrl_var_oc(48:479,0,:,:), ctrl_var_gz_oc@_FillValue)

    ctrl_var_gz_ec = new((/g_new_hours,110,152/),double)
    ctrl_var_gz_ec@_FillValue = -999.0
    ctrl_var_gz_ec = where(grid .eq. 1.00, ctrl_var_ec(48:479,0,:,:), ctrl_var_gz_ec@_FillValue)

    sen_var_gz = new((/dimsizes(g_filename),g_new_hours,110,152/),double)
    sen_var_gz@_FillValue = -999.0
    sen_var_gz = where(grid_sen .eq. 1.00, sen_var(:,48:479,0,:,:), sen_var_gz@_FillValue)
    
    sen_var_gz_so4 = new((/dimsizes(g_filename),g_new_hours,110,152/),double)
    sen_var_gz_so4@_FillValue = -999.0
    sen_var_gz_so4 = where(grid_sen .eq. 1.00, sen_var_so4(:,48:479,0,:,:), sen_var_gz_so4@_FillValue)

    sen_var_gz_no3 = new((/dimsizes(g_filename),g_new_hours,110,152/),double)
    sen_var_gz_no3@_FillValue = -999.0
    sen_var_gz_no3 = where(grid_sen .eq. 1.00, sen_var_no3(:,48:479,0,:,:), sen_var_gz_no3@_FillValue)

    sen_var_gz_nh4 = new((/dimsizes(g_filename),g_new_hours,110,152/),double)
    sen_var_gz_nh4@_FillValue = -999.0
    sen_var_gz_nh4 = where(grid_sen .eq. 1.00, sen_var_nh4(:,48:479,0,:,:), sen_var_gz_nh4@_FillValue)

    sen_var_gz_oc = new((/dimsizes(g_filename),g_new_hours,110,152/),double)
    sen_var_gz_oc@_FillValue = -999.0
    sen_var_gz_oc = where(grid_sen .eq. 1.00, sen_var_oc(:,48:479,0,:,:), sen_var_gz_oc@_FillValue)

    sen_var_gz_ec = new((/dimsizes(g_filename),g_new_hours,110,152/),double)
    sen_var_gz_ec@_FillValue = -999.0
    sen_var_gz_ec = where(grid_sen .eq. 1.00, sen_var_ec(:,48:479,0,:,:), sen_var_gz_ec@_FillValue)

    ;sum of ctrl & sen
    ctrl_sum = new((/g_new_hours/),double)
    ctrl_sum_so4 = new((/g_new_hours/),double)
    ctrl_sum_no3 = new((/g_new_hours/),double)
    ctrl_sum_nh4 = new((/g_new_hours/),double)
    ctrl_sum_oc = new((/g_new_hours/),double)
    ctrl_sum_ec = new((/g_new_hours/),double)
    do i = 0,g_new_hours-1
        ctrl_sum(i) = sum(ctrl_var_gz(i,:,:))
        ctrl_sum_so4(i) = sum(ctrl_var_gz_so4(i,:,:))
        ctrl_sum_no3(i) = sum(ctrl_var_gz_no3(i,:,:))
        ctrl_sum_nh4(i) = sum(ctrl_var_gz_nh4(i,:,:))
        ctrl_sum_oc(i) = sum(ctrl_var_gz_oc(i,:,:))
        ctrl_sum_ec(i) = sum(ctrl_var_gz_ec(i,:,:))
    end do 
    sen_sum = new((/dimsizes(g_filename),g_new_hours/),double)
    sen_sum_so4 = new((/dimsizes(g_filename),g_new_hours/),double)
    sen_sum_no3 = new((/dimsizes(g_filename),g_new_hours/),double)
    sen_sum_nh4 = new((/dimsizes(g_filename),g_new_hours/),double)
    sen_sum_oc = new((/dimsizes(g_filename),g_new_hours/),double)
    sen_sum_ec = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        do j = 0,g_new_hours-1
            sen_sum(i,j) = sum(sen_var_gz(i,j,:,:))
            sen_sum_so4(i,j) = sum(sen_var_gz_so4(i,j,:,:))
            sen_sum_no3(i,j) = sum(sen_var_gz_no3(i,j,:,:))
            sen_sum_nh4(i,j) = sum(sen_var_gz_nh4(i,j,:,:))
            sen_sum_oc(i,j) = sum(sen_var_gz_oc(i,j,:,:))
            sen_sum_ec(i,j) = sum(sen_var_gz_ec(i,j,:,:))
        end do
    end do
    
    ;contri
    diff = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        diff(i,:) = sen_sum(i,:)-ctrl_sum
    end do
    diff_sum = new((/g_new_hours/),double)
    do i = 0,g_new_hours-1
        diff_sum(i) = -sum(diff(:,i))
    end do
    contri = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        contri(i,:) = -diff(i,:)/diff_sum
    end do
    
    diff_so4 = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        diff_so4(i,:) = sen_sum_so4(i,:)-ctrl_sum_so4
    end do
    diff_sum_so4 = new((/g_new_hours/),double)
    do i = 0,g_new_hours-1
        diff_sum_so4(i) = -sum(diff_so4(:,i))
    end do
    contri_so4 = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        contri_so4(i,:) = -diff_so4(i,:)/diff_sum_so4
    end do

    diff_no3 = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        diff_no3(i,:) = sen_sum_no3(i,:)-ctrl_sum_no3
    end do
    diff_sum_no3 = new((/g_new_hours/),double)
    do i = 0,g_new_hours-1
        diff_sum_no3(i) = -sum(diff_no3(:,i))
    end do
    contri_no3 = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        contri_no3(i,:) = -diff_no3(i,:)/diff_sum_no3
    end do

    diff_nh4 = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        diff_nh4(i,:) = sen_sum_nh4(i,:)-ctrl_sum_nh4
    end do
    diff_sum_nh4 = new((/g_new_hours/),double)
    do i = 0,g_new_hours-1
        diff_sum_nh4(i) = -sum(diff_nh4(:,i))
    end do
    contri_nh4 = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        contri_nh4(i,:) = -diff_nh4(i,:)/diff_sum_nh4
    end do

    diff_oc = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        diff_oc(i,:) = sen_sum_oc(i,:)-ctrl_sum_oc
    end do
    diff_sum_oc = new((/g_new_hours/),double)
    do i = 0,g_new_hours-1
        diff_sum_oc(i) = -sum(diff_oc(:,i))
    end do
    contri_oc = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        contri_oc(i,:) = -diff_oc(i,:)/diff_sum_oc
    end do

    diff_ec = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        diff_ec(i,:) = sen_sum_ec(i,:)-ctrl_sum_ec
    end do
    diff_sum_ec = new((/g_new_hours/),double)
    do i = 0,g_new_hours-1
        diff_sum_ec(i) = -sum(diff_ec(:,i))
    end do
    contri_ec = new((/dimsizes(g_filename),g_new_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        contri_ec(i,:) = -diff_ec(i,:)/diff_sum_ec
    end do

; ==============================================================
; Mission 3. Prepare the figure data
; ==============================================================

	labels    = g_new_filename	
	x = (/-4.,-3,-2., -1., 0., 1.,2.,3.,4./)
	contri_avg = dim_avg_n_Wrap(contri,1)
    contri_avg_so4 = dim_avg_n_Wrap(contri_so4,1) ;each exp avg
    contri_avg_no3 = dim_avg_n_Wrap(contri_no3,1) ;
    contri_avg_nh4 = dim_avg_n_Wrap(contri_nh4,1) ;
    contri_avg_oc = dim_avg_n_Wrap(contri_oc,1) ;
    contri_avg_ec = dim_avg_n_Wrap(contri_ec,1) ;
    do i = 0,dimsizes(labels)-1
		qsort(contri(i,:))
        qsort(contri_so4(i,:))
        qsort(contri_no3(i,:))	
        qsort(contri_nh4(i,:))
        qsort(contri_oc(i,:))
        qsort(contri_ec(i,:))
    end do
    ; y1_box(a,b) 
    ;   a = number of experiments
    ;   b = 4 Max
    ;   b = 3 Upper 1/4
    ;   b = 2 Medium
    ;   b = 1 Lower 1/4
    ;   b = 0 Min

	y1_box = new((/dimsizes(labels),5/),double)
    quarter=toint(g_new_hours/4)
	y1_box(:,0) = contri(:,0)
	y1_box(:,1) = contri(:,quarter-1)
	y1_box(:,2) = (contri(:,quarter*2)+contri(:,quarter*2-1))/2
	y1_box(:,3) = contri(:,3*quarter-1)
	y1_box(:,4) = contri(:,g_new_hours-1)
	
    y2_box = new((/dimsizes(labels),5/),double)
    quarter=toint(g_new_hours/4)
	y2_box(:,0) = contri_so4(:,0)
	y2_box(:,1) = contri_so4(:,quarter-1)
	y2_box(:,2) = (contri_so4(:,quarter*2)+contri_so4(:,quarter*2-1))/2
	y2_box(:,3) = contri_so4(:,3*quarter-1)
	y2_box(:,4) = contri_so4(:,g_new_hours-1)
	
    y3_box = new((/dimsizes(labels),5/),double)
    quarter=toint(g_new_hours/4)
	y3_box(:,0) = contri_no3(:,0)
	y3_box(:,1) = contri_no3(:,quarter-1)
	y3_box(:,2) = (contri_no3(:,quarter*2)+contri_no3(:,quarter*2-1))/2
	y3_box(:,3) = contri_no3(:,3*quarter-1)
	y3_box(:,4) = contri_no3(:,g_new_hours-1)
	
    y4_box = new((/dimsizes(labels),5/),double)
    quarter=toint(g_new_hours/4)
	y4_box(:,0) = contri_nh4(:,0)
	y4_box(:,1) = contri_nh4(:,quarter-1)
	y4_box(:,2) = (contri_nh4(:,quarter*2)+contri_nh4(:,quarter*2-1))/2
	y4_box(:,3) = contri_nh4(:,3*quarter-1)
	y4_box(:,4) = contri_nh4(:,g_new_hours-1)
	
    y5_box = new((/dimsizes(labels),5/),double)
    quarter=toint(g_new_hours/4)
	y5_box(:,0) = contri_oc(:,0)
	y5_box(:,1) = contri_oc(:,quarter-1)
	y5_box(:,2) = (contri_oc(:,quarter*2)+contri_oc(:,quarter*2-1))/2
	y5_box(:,3) = contri_oc(:,3*quarter-1)
	y5_box(:,4) = contri_oc(:,g_new_hours-1)
	
    y6_box = new((/dimsizes(labels),5/),double)
    quarter=toint(g_new_hours/4)
	y6_box(:,0) = contri_ec(:,0)
	y6_box(:,1) = contri_ec(:,quarter-1)
	y6_box(:,2) = (contri_ec(:,quarter*2)+contri_ec(:,quarter*2-1))/2
	y6_box(:,3) = contri_ec(:,3*quarter-1)
	y6_box(:,4) = contri_ec(:,g_new_hours-1)
	
    ;********************************************************
	; create the plot
	;********************************************************   
    wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
    plot_box = new((/5/),graphic)

	res            = True                         ; plot mods desired
	res@tmXBLabels = labels ; labels for each box
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    res@tiMainFontHeightF    = 0.03
    res@trYMinF = -0.1
    res@trYMaxF = 1.0
    res@tmYROn = True
    res@tmXTOn = True
    res@tmXTBorderOn = True 
    res@tmYRBorderOn = True 
	
    res1            = True                         ; plot mods desired
	res1@tmXBLabels = labels ; labels for each box
    res1@tmXBLabelFontHeightF = g_font
    res1@tmYLLabelFontHeightF = g_font
    res1@tiMainFontHeightF    = 0.03
    res1@trYMinF = -0.1
    res1@trYMaxF = 1.2
    res1@tmYROn = True
    res1@tmXTOn = True
    res1@tmXTBorderOn = True 
    res1@tmYRBorderOn = True 
    
    ;**********************************************
	; resources for polylines that draws the boxes
	;**********************************************  
	llres                   = True			
	llres@gsLineThicknessF  = 2.0                 ; line thickness 
	;**********************************************
	; resources that control color and width of boxes
	;**********************************************  
	opti          = True			
	opti@boxWidth = .5				; Width of box (x units)
	opti@boxColors = (/"black","blue","red","orange","purple","pink","tomato","violet","green"/)  	; Color of box(es)
	;***********************************************
	
	
   ;***********************************************
   ;add polymarker res
   ;***********************************************
   mres               = True                     ; marker mods desired
   mres@gsMarkerIndex = 3                        ; polymarker style
   mres@gsMarkerSizeF = 8.                      ; polymarker size
   mres@gsMarkerColor = "navy blue"                    ; polymarker color
   mres@gsMarkerThicknessF = 0.5

   ;***********************************************
   ;add refline res
   ;***********************************************

;	lnres = True
;	lnres@gsLineThicknessF = 3.0
	
	;siglnres@gsLineThicknessF = 3.0
	;siglnres@gsLineDashPattern = 2
	;siglnres@gsLineColor = "red"
	
	
	;res@tiMainString = "PM2.5"
	;plot_box(0) = boxplot(wks,x,y1_box,opti,res,llres)	; All 3 options used...
    ;dum0 = gsn_add_polymarker(wks,plot_box(0),x,contri_avg,mres) 

    res1@tiMainString = "Sulfate"
    plot_box(0) = boxplot(wks,x,y2_box,opti,res1,llres)	; All 3 options used...
    dum1 = gsn_add_polymarker(wks,plot_box(0),x,contri_avg_so4,mres) 

    res@tiMainString = "Nitrate"
	plot_box(1) = boxplot(wks,x,y3_box,opti,res,llres)	; All 3 options used...
    dum2 = gsn_add_polymarker(wks,plot_box(1),x,contri_avg_no3,mres) 

    res@tiMainString = "Ammonium"
	plot_box(2) = boxplot(wks,x,y4_box,opti,res,llres)	; All 3 options used...
    dum3 = gsn_add_polymarker(wks,plot_box(2),x,contri_avg_nh4,mres) 

    res@tiMainString = "OC"
	plot_box(3) = boxplot(wks,x,y5_box,opti,res,llres)	; All 3 options used...
    dum4 = gsn_add_polymarker(wks,plot_box(3),x,contri_avg_oc,mres) 

    res@tiMainString = "EC"
	plot_box(4) = boxplot(wks,x,y6_box,opti,res,llres)	; All 3 options used...
    dum5 = gsn_add_polymarker(wks,plot_box(4),x,contri_avg_ec,mres) 
    gsn_panel(wks,plot_box,(/1,5/),False)

end
