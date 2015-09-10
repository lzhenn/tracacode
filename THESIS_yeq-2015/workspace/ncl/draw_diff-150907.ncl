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
    ;g_filename = (/"sw","gz","fs","sz","gd1","gd2","gd3","gd4","gd5"/)
    g_filename = (/"sw","gz","gd1","gd4","gd5"/)
    ;g_fig_name =  "../fig/CMAQ_grid_city"
    g_fig_name = "../fig/plot_diff"

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
    gz_grid_sum = sum(where(grid0 .eq. 1,1,0)) 


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
    
    diff = new((/dimsizes(g_filename),g_hours/),double)
    do i = 0,dimsizes(g_filename)-1
        diff(i,:) = sen_sum(i,:)-ctrl_sum
    end do
    diff_sum = new((/g_hours/),double)
    do i = 0,g_hours-1
        diff_sum(i) = -sum(diff(:,i))
    end do
    
;**********************************************************************************************
;MISSION.3		Plot Clim monthly mean to check the result
;**********************************************************************************************
	wks = gsn_open_wks("eps",g_fig_name)       ; open file to plot 
;-----------------------------------------------------------------------------
    plot = new((/1/),graphic)
 
    res                  = True       ; use plot options
    
    res@xyLineColors      = (/"blue","red","green","orange","purple"/)          ; change line color

    res@trXMinF  = 1                   ; min value on x-axis
    res@trXMaxF  = g_hours                   ; max value on x-axis
    res@trYMinF  = -30
    res@trYMaxF  = 1
    res@xyLineThicknesses    = (/4.0,4.0,4.0,4.0,4.0/) 
    res@xyDashPattern = (/0,0,0,0,0/)               ; Make curves all solid
    ;res@xyMarkLineMode = "MarkLines"    ; Markers *and* lines
    ;res@xyMarkers      = (/6,11,16/)    ; 3 different markers
    ;res@xyMarkerColors = (/"blue","red","green","orange","purple"/)  ; 3 different colors

    ;res@tiMainString      = "Mulitple XY plot with markers"      ; add title

    plot  = gsn_csm_xy (wks,ispan(1,g_hours,1),diff/gz_grid_sum,res) ; create plot
 
 
 



end
