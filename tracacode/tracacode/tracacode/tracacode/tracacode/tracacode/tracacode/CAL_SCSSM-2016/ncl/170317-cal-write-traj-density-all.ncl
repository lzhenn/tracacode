;********************************************************
; annotate_4.ncl
;
; Concepts illustrated:
;   - Plotting trajectories
;   - Attaching a custom legend to a map
;   - Attaching markers, text, and polylines to a map
;   - Changing the width and height of a legend
;   - Drawing filled dots on a map
;
; This script was contributed by Yongzuo Li from
; the University of Oklahoma.
; 
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;**************************************************
begin
; Set resources


; Backtrac time file
n_pts=450

g_strt_year=1979

; Integration timestep
int_step=1 

; Total integration period in an individual case
total_int_hrs=96 

; Individual record length 
rec_len=total_int_hrs/int_step


;Plvl
plvl_list=(/1000, 925, 850, 700, 600, 500, 200/)
onset_day=(/125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119/)
total_year=dimsizes(onset_day)
left_shift_day=-10
right_shift_day=6


latS=-10
latN=30
lonW=70
lonE=120
fig_dir="../fig/obv/traj/every-year/"

; lat lon data
data_dir="/Users/zhenningli/data/obv/ERA-daily/uvw/ei.oper.an.pl.regn128uv.2012050900.nc"

latlon_in   =  addfile(data_dir,"r")
lat1d = latlon_in->g4_lat_1
lon1d = latlon_in->g4_lon_2
    


; New the indlat
var1=new((/total_year, right_shift_day-left_shift_day+1, total_int_hrs, n_pts/), integer)  ; just get the gridsystem, resident time
var1@long_name="air parcel lat index"
var1!0="year"
var1!1="day"
var1!2="back_hrs"
var1!3="npt"
var1&year=ispan(g_strt_year,g_strt_year+dimsizes(onset_day)-1,1)
var1&day=ispan(left_shift_day,right_shift_day,1)

var2=var1
var2@long_name="air parcel lon index"

do jj=0,dimsizes(plvl_list)-1
    plvl=plvl_list(jj)
    do curr_year= g_strt_year, g_strt_year+dimsizes(onset_day)-1
        do i_day=left_shift_day, right_shift_day
            curr_day_stamp=yyyyddd_to_yyyymmdd(curr_year*1000+onset_day(curr_year-g_strt_year)+i_day)
            print("processing "+curr_day_stamp+"@"+plvl+"hPa")
            data_file_name1="/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/every-year/"+curr_day_stamp+"00-"+plvl+"hPa.txt"
            pt_record  =   asciiread(data_file_name1,(/n_pts*rec_len,5/),"float") ; get the first file's lat lon and value
            ;pt_record [0]--pt idx [1]--timestamp [2]--lat [3]--lon [4]--plevel
            do pos=0,n_pts*rec_len-1
                idx=pt_record(pos,0)
                hrx=floattoint(pt_record(pos,1))
                pt_pos=mod(pos, n_pts)
                latind=closest_val(pt_record(pos,2),lat1d)
                lonind=closest_val(pt_record(pos,3),lon1d)
                var1({curr_year}, {i_day}, hrx, pt_pos)=latind
                var2({curr_year}, {i_day}, hrx, pt_pos)=lonind
            end do
        end do
    end do
    ;************************************************
    ; High Efficiency to Write the file
    ;************************************************
    pdata_fn="/Users/zhenningli/data/CAL_SCSSM-2016/back_traj/every-year/pcl-latind-lonind-"+plvl+"hPa.nc"
    ;Get dimsize
        nyear=total_year
        ndays=right_shift_day-left_shift_day+1
        nhrs=total_int_hrs
        npts=n_pts
        
    ;Set fileoption    
        system("rm "+pdata_fn)
        fout = addfile(pdata_fn ,"c")  ; open output netCDF file
        setfileoption(fout,"DefineMode",True)

    ;Set All field attribution
        fileAtt     = True
        fileAtt@creation_date=systemfunc("date")
        fileattdef(fout,fileAtt)

    ;Define Coordinate
        dimNames    =(/"year","day","back_hrs","npt"/)
        dimSizes    =(/-1,ndays,nhrs,npts/)
        dimUnlim    =(/True,False,False,False/)
        filedimdef(fout,dimNames,dimSizes,dimUnlim)

    ;Define var, type and dim
        filevardef(fout,"year",typeof(var1&year),getvardims(var1&year))
        filevardef(fout,"day",typeof(var1&day),getvardims(var1&day))
        filevardef(fout,"latind",typeof(var1),getvardims(var1))
        filevardef(fout,"lonind",typeof(var2),getvardims(var2))

    ;Define Attribute
        filevarattdef(fout,"latind",var1)
        filevarattdef(fout,"lonind",var2)
        filevarattdef(fout,"year",var1&year)
        filevarattdef(fout,"day",var1&day)
        
        fout->year=(/var1&year/)
        fout->day=(/var1&day/)
        fout->latind=(/var1/)    
        fout->lonind=(/var2/)    
        var1=0
        var2=0
end do
end
