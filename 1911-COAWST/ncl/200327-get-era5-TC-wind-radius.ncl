;*******************************************************
; lcnative_2.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"

function tc_eye_radius_from_uv(wind)
local dis
begin
        dims = dimsizes(wind)
        x1d = ndtooned(wind)      ; convert 2D array to 1D for wsse in maxind
        indmx = ind_resolve(maxind(x1d), dims)    ; convert 1D array back to 2D 
        indmn = ind_resolve(minind(x1d), dims)    ; convert 1D array back to 2D 
        lat_max = wind&g0_lat_1(indmx(0,0))   ; insert the latitude index into the lat coordinate variable
        lon_max = wind&g0_lon_2(indmx(0,1))   ; insert the longitude index into the lon coordinate variable
        lat_min = wind&g0_lat_1(indmn(0,0))   ; insert the latitude index into the lat coordinate variable
        lon_min = wind&g0_lon_2(indmn(0,1))   ; insert the longitude index into the lon coordinate variable
        dis=gc_latlon(lat_max,lon_max,lat_min,lon_min,2,4) ; distance in km
        return(dis/2.0)
end 



begin
;************************************************
; open file and read in data
;************************************************
    data_in="/users/b145872/project-dir/data/reana/ERA5/hourly/20180913-sl.nc"
        
    
    ; get wrf fully coupled nc data
    ctrl_in      = addfile (data_in, "r")   ; note the "s" of addfile

    tf=ctrl_in->initial_time0 
    u=ctrl_in->10U_GDS0_SFC
    v=ctrl_in->10V_GDS0_SFC
    lentime=dimsizes(tf)
    lentime:=lentime(0)
    do ii=0,lentime-1
        ;---X is a two dimensional array dimensioned lat x lon
        disu=tc_eye_radius_from_uv(u(ii,:,:))
        disv=tc_eye_radius_from_uv(v(ii,:,:))
        print(tf(ii,:)+": r(u)="+disu+" km;"+" r(v)="+disv+" km.")
    end do
end


