
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"
begin
    
   
    sta_num="59287"
    slat=23.167
    slon=113.33

    
    ; *** ERA5 in ***
    raw_data="/home/yhuangci/lee/workspace/spellcaster-local/data/era5/2T_GDS0_SFC.1979-2018.mon.mean.nc"
    raw_in=addfile(raw_data, "r")
    var=raw_in->2T_GDS0_SFC(:,{slat-0.5:slat+0.5},{slon-0.5:slon+0.5})
    
    ; *** Clim in ***
    clim_data=addfile("/home/yhuangci/lee/workspace/spellcaster-local/data/clim/T2m.clim.REA5.1981-2010.nc","r")
    var_clim=clim_data->T2_CLIM(:,{slat-0.5:slat+0.5},{slon-0.5:slon+0.5})
   
    var:=wgt_areaave(var,1.0,1.0,0)
    var_clim:=wgt_areaave(var_clim,1.0,1.0,0)
    do ii = 0,11
        var(ii::12) = (/var(ii::12)-var_clim(ii)/)
    end do
    print(var)
end
