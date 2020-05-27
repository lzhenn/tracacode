load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
begin
    ; get in wrf tc track data
    ;0-timestamp 1-cat 2-lat 3-lon 4-minSLP 4-maxWS 5-uRadius 6-vRadius
    case_tc = asciiread("/disk/v092.yhuangci/lzhenn/1911-COAWST/cma.trck.mangkhut", (/52,6/),"integer")
    print(case_tc(:,0))
    ; shift to +xxxH to Init
    case_tc(:,0)=case_tc(:,0)-(/case_tc(0,0)/)
    
    fine_time_day=ispan(2018090700,2018091700,100)
    fine_time_hr=ispan(0,24,1)
    fine_time=new(dimsizes(fine_time_day)*dimsizes(fine_time_hr),"integer")
    nn=0
    do ii = 0, dimsizes(fine_time_day)-1
        do jj = 0, dimsizes(fine_time_hr)-1
            fine_time(nn)=fine_time_day(ii)+fine_time_hr(jj)
            nn=nn+1
        end do
    end do
    fine_time:=fine_time(0:dimsizes(fine_time)-13)
    print(fine_time)
    exit
    fine_lat = linint1_Wrap (case_tc(:,0),case_tc(:,2), False, ispan(0,1012,1), 0)
    fine_lon = linint1_Wrap (case_tc(:,0),case_tc(:,3), False, ispan(0,1012,1), 0)
    ;print(fine_lat)


end
