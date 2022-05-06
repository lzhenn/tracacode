load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
;load "$NCL_SELFLIB/cnmap-zhenning/cnmap.ncl"
begin
    g_font=0.015
   
    org_in      = addfile ("/home/lzhenn/array74/workspace/calypso_pipeline/domaindb/swant1t2/new_roms_d02.nc", "w")
    
    h=org_in->h

    h=where(h .lt. 3, 3, h)
    org_in->h=h
  end
