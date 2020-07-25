;*************************************************************
; Aim: take out essential TC info from wrfout_d$<domain> 
; Output:   trck.$casename.$<domain> e.g. trck.mangkhut.d01
;
; Output style (with headline): 
;   timestamp, lat, lon, minSLP, maxWS, uRadius, vRadius
;
;                       Zhenning Li
;                       Last modified: Apr 06, 2020
;Last Edited:
;   2020-04-06  Created
;*************************************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"

; function to find the tc eyewall radius (km) from u and v data
function tc_eye_radius_from_uv(wind, lat2d, lon2d)
local dis
begin
        dims = dimsizes(wind)
        x1d = ndtooned(wind)      ; convert 2D array to 1D for wsse in maxind
        indmx = ind_resolve(maxind(x1d), dims)    ; convert 1D array back to 2D 
        indmn = ind_resolve(minind(x1d), dims)    ; convert 1D array back to 2D 
        lat_max = lat2d(indmx(0,0),indmx(0,1))   ; insert the latitude index into the lat coordinate variable
        lon_max = lon2d(indmx(0,0),indmx(0,1))   ; insert the longitude index into the lon coordinate variable
        lat_min = lat2d(indmn(0,0),indmn(0,1))   ; insert the latitude index into the lat coordinate variable
        lon_min = lon2d(indmn(0,0),indmn(0,1))   ; insert the longitude index into the lon coordinate variable
        dis=gc_latlon(lat_max,lon_max,lat_min,lon_min,2,4) ; distance in km
        return(dis/2.0)
end 

; ************Main************
begin

; global constants
   g_font=0.02
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                             "Oct","Nov","Dec"/)

; Assign default settings if lack of argument pass
    if (.not. isvar("i_dom")) then 
        i_dom=1
    end if 
    if (.not. isvar("wrfout_path")) then 
        wrfout_path="/users/b145872/project-dir/app/COAWST-sandy-wrf/WRF/run/"
    end if 
    if (.not. isvar("casename")) then 
        casename="mangkhut-wrfonly" 
    end if 

    print(">>STEP00: [DEBUG] i_dom:"+tostring(i_dom)+" wrfout_path:"+wrfout_path+" casename:"+casename)
    print(">>STEP00: Reading map data...")
; get wrf fully coupled nc data
    all_files=systemfunc("ls "+wrfout_path+"/wrfout_d0"+i_dom+"*")
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
       
    ; parser time
    time0 := wrf_user_getvar(ctrl_in,"Times", -1)
    xtime := wrf_times_c( time0, 2 ) 
    lentime=dimsizes(xtime)
    ; parser lat lon
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)

    dxdy=gc_latlon(lat2d(0,0),lon2d(0,0),lat2d(0,1),lon2d(0,1),2,4) ; distance in km

    print(">>STEP00: Reading U10&V10...")
    ctrl_var2  = wrf_user_getvar(ctrl_in,"U10", -1)  
    ctrl_var3  = wrf_user_getvar(ctrl_in,"V10", -1)  
          
    dims:=dimsizes(ctrl_var2)
    dim_y=dims(1)
    dim_x=dims(2)
    lenvar=dim_y*dim_x

; lets find the TC center!
; (0)--timestamp, (1)--lat, (2)--lon, (3)--slp, (4)--maxWind, (5)--uRadius, (6)--vRadius
    rec_tc=new((/2, lentime/), "string")
    
    print(">>STEP00: Output...")
    ;out put
    outf = wrfout_path+"/ws."+casename+".d0"+i_dom
    system("rm -f "+outf)   ; remove any pre-existing file
    write_table(outf, "w", [/"timestamp", "maxWS" /], "%s %s")
   
    print(">>STEP00: Parsing...")
    do tt = 0, lentime-1
        rec_tc(0,tt)=sprintf("%14.0f",xtime(tt))
        
        ;ws
        ws=wind_speed(ctrl_var2(tt,:,:),ctrl_var3(tt,:,:))
        tmp1D      = ndtooned(ws)
        qsort(tmp1D)
        rec_tc(1, tt)=sprintf("%5.2f",(dim_avg(tmp1D(lenvar-3:))))
        ;eye radius
        write_table(outf, "a", [/rec_tc(0,tt),rec_tc(1,tt)/],"%s %s")
    end do    
end
