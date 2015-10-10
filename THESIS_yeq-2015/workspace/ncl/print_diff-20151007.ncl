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

	g_species = "PM25"
    g_pm25_species = (/"ASO4J","ASO4I","ANO3J","ANO3I","ANH4J","ANH4I","AALKJ","AXYL1J","AXYL2J","AXYL3J",\
                       "ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J",\
                       "ASQTJ","AORGCJ","AORGPAI","AORGPAJ","AECJ","AECI","A25J","A25I","ANAJ","ACLJ",\
                       "ACLI","ANAI","AISO3J","AOLGAJ","AOLGBJ"/)
    g_filetime = (/"07","10","13","16","19","22","25"/)
    g_filename = (/"sw","gz","fs","sz","gd1","gd2","gd3","gd4","gd5"/)
    g_lat = 45
    g_lon = 73
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

    ;read PM25 CCTM sen result
    sen_var = new((/dimsizes(g_filename),g_hours,1,110,152/),double)  
    do i = 0,dimsizes(g_filename)-1
        sen_in = addfiles("../data/CCTM/no-"+g_filename(i)+"-all/201011"+g_filetime+"00_3km.ACONC.ncf","r")    
        sen_var(i,:,:,:,:)     = sen_in[:]->$g_pm25_species(0)$                 ; znw(bottom_top_stag)
        do j=1,dimsizes(g_pm25_species)-1
            sen_var(i,:,:,:,:)     =sen_var(i,:,:,:,:)+sen_in[:]->$g_pm25_species(j)$                 ; znw(bottom_top_stag)
        end do
    end do
    
    diff = new((/dimsizes(g_filename),433/),double)
    do i = 0,dimsizes(g_filename)-1
        diff(i,:) = sen_var(i,48:480,0,g_lat,g_lon)-ctrl_var(48:480,0,g_lat,g_lon)
    end do

    print(-diff)
end
