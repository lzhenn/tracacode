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

    print("Stage2.0: >> [DEBUG] i_dom:"+tostring(i_dom)+" wrfout_path:"+wrfout_path+" casename:"+casename)
    print("Stage2.1: >> Reading map data...")
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
; get partent domain tc info if child domain
    if (i_dom .gt. 1) then
        ncol=7
        parent_tc_file = wrfout_path+"/trck."+casename+".d0"+tostring(toint(i_dom)-1)
        parent_tc = readAsciiTable(parent_tc_file,ncol,"double", 1) ; note the transpose of "new" function
    end if
; get slp
    print("Stage2.2: >> Reading slp...")
    ctrl_var1  := wrf_user_getvar(ctrl_in,"slp", -1)  
           
    dims:=dimsizes(ctrl_var1)
    dim_y=dims(1)
    dim_x=dims(2)

    print("Stage2.3: >> Reading U10&V10...")
    ctrl_var2  = wrf_user_getvar(ctrl_in,"U10", -1)  
    ctrl_var3  = wrf_user_getvar(ctrl_in,"V10", -1)  

; lets find the TC center!
; (0)--timestamp, (1)--lat, (2)--lon, (3)--slp, (4)--maxWind, (5)--uRadius, (6)--vRadius
    rec_tc=new((/7,lentime/), "string")
    
    print("Stage2.4: >> Parsing...")
    do tt = 0, lentime-1
        tmp1D      = ndtooned(ctrl_var1(tt,:,:))
        indices  = ind_resolve(minind(tmp1D),(/dim_y,dim_x/))
        id_y=indices(0,0)
        id_x=indices(0,1)

        rec_tc(0,tt)=sprintf("%14.0f",xtime(tt))
        rec_tc(1,tt)=sprintf("%7.3f",lat2d(id_y,id_x))
        rec_tc(2,tt)=sprintf("%7.3f",(lon2d(id_y,id_x)))
        
        nofound=False ; default found slp center in d01
        if (i_dom .gt. 1) then 
            nofound = True
            
            ; get the most close grid in the child domain to the TC center obtained by parent domain data
            parent_lat=parent_tc(tt,1)
            parent_lon=parent_tc(tt,2)
            
            closePoint=getind_latlon2d(lat2d, lon2d, parent_lat, parent_lon)
            
            xPos=closePoint(0,0)
            yPos=closePoint(0,1)

            dis=gc_latlon(parent_lat,parent_lon,lat2d(xPos,yPos),lon2d(xPos,yPos),2,4) ; distance in km
            if (dis .lt. 2*dxdy) then
                nofound= False
            end if
        end if   
       
        if ((min(tmp1D) .gt. 999) .or. (nofound)) then
            rec_tc(3,tt)=sprintf("%6.1f",0.0)
            rec_tc(4,tt)=sprintf("%5.2f",0.0)
            rec_tc(5,tt)=sprintf("%5.2f",0.0)
            rec_tc(6,tt)=sprintf("%5.2f",0.0)
            continue
        end if
        rec_tc(3,tt)=sprintf("%6.1f",min(tmp1D))
        ;ws
        ws=wind_speed(ctrl_var2(tt,:,:),ctrl_var3(tt,:,:))
        tmp1D      = ndtooned(ws)
        rec_tc(4,tt)=sprintf("%5.2f",(max(tmp1D)))
        ;eye radius
        rec_tc(5,tt)=sprintf("%5.2f", tc_eye_radius_from_uv(ctrl_var2(tt,:,:),lat2d,lon2d))
        rec_tc(6,tt)=sprintf("%5.2f", tc_eye_radius_from_uv(ctrl_var3(tt,:,:),lat2d,lon2d))
    end do

    ;out put
    outf = wrfout_path+"/trck."+casename+".d0"+i_dom
    system("rm -f "+outf)   ; remove any pre-existing file
    write_table(outf, "w", [/"timestamp", "lat", "lon", "minSLP", "maxWS", "uRadius", "vRadius"/], "%s %s %s %s %s %s %s")
    do tt = 0, lentime-1
        list_rec:= NewList("fifo")
        do ii=0, 6
            ListAppend(list_rec,rec_tc(ii,tt))
        end do
        write_table(outf, "a", [/rec_tc(0,tt),rec_tc(1,tt),rec_tc(2,tt),rec_tc(3,tt),rec_tc(4,tt),rec_tc(5,tt),rec_tc(6,tt)/],"%s %s %s %s %s %s %s")
    end do    
end
