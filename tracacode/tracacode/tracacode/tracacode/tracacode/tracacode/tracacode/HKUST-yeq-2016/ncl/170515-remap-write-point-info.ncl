;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;================================================
;Variables List:
;	var1--------------CO2
;	var2--------------CH4
;	var3--------------N2O
;	var4--------------f11
;	var5--------------f12
;================================================



begin
    
    ;grid file
    grid_fn="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/gridsys/GRIDCRO2D_3km"


    ;point info file
    data_file_name1="/home/yangsong3/L_Zealot/data-mirror/data-model/L_Zealot/HKUST_yeq-2016/resident-time_output/data/hysplit/prd/points-3km-all"
    
    ;Number of points
    n_pts=16720
;---------------Read data-------------------

    pt_record  =   asciiread(data_file_name1,(/n_pts,7/),"float") ; get the points' lat and lon info
    ; pt_record(0)--num
    ; pt_record(1)--cor_x  (will operate)
    ; pt_record(2)--cor_y  (will operate)
    ; pt_record(4)--lat
    ; pt_record(5)--lon

;---------------Read lat-lon config-------------------
    latlon_in   =  addfile(grid_fn,"r")
    lat2d = latlon_in->LAT(0,0,:,:)
    lon2d = latlon_in->LON(0,0,:,:)
    grid_dim=dimsizes(lat2d) 
   
    ; Get point coordinate and regrid 
    do ii = 0, n_pts-1
        lat0=pt_record(ii,4)
        lon0=pt_record(ii,5)
        point=getind_latlon2d(lat2d,lon2d,lat0,lon0)
        cor_x=point(0,0)
        cor_y=point(0,1)
        pt_record(ii,0)=ii+1
        pt_record(ii,1)=cor_x
        pt_record(ii,2)=cor_y
        if (mod(ii,1000) .eq. 0) then
            print("Remap "+ii)
        end if
    end do
    ; output the remaped points
    col1=floattointeger(pt_record(:,0))
    col2=floattointeger(pt_record(:,1))
    col3=floattointeger(pt_record(:,2))
    col4=pt_record(:,4)
    col5=pt_record(:,5)
    col_all=[/col1, col2, col3, col4, col5/]
    write_table("list.txt", "w", col_all, "%8d %4d %4d %8.3f %8.3f")
end 
