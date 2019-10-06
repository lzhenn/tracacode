load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"

begin

    ;forcing in
    forc_dir="~/zwx/GODAS.temperature10ano.global.1p1.2015spring.replacenan.nc"
    forc_SST = addfile(forc_dir, "r")
    sst_time=forc_SST->TEM
    sst_time!0="time"
    sst_time!1="lat"
    printVarSummary(sst_time)
    lon0=fspan(0.5,359.5,360)
    lat0=fspan(-89.5,89.5,180)
    sst_time&lat = (/lat0/)
    sst_time!2="lon"
    sst_time&lon = lon0
 
    sst_regrid=linint2_Wrap(sst_time&lon,sst_time&lat,sst_time,True,lon0,lat0,0)
    
    sst_remap=PopLatLon(sst_regrid,"1x1d","gx1v6","bilin","da","100716")
    printVarSummary(sst_remap)

    ; clim in
    clim_file=addfile("/home/yangsong3/data-model/CESM_CTRL/B2000_F19G16_CAM4_CTRL/spun-up-pro/B20f19-spun-up.pop.h.SST.250-299.nc", "r")
    clim_sst=clim_file->SST
    ; template in 
    temp_file=addfile("/home/yangsong3/zwx/nudging_TEMP.nc","r")
    temp_long=temp_file->TLONG
    temp_lat=temp_file->TLAT
   
    temp_wgt=clim_sst
    temp_wgt = 0.0
    do ii = 2,4
        clim_sst(ii,:,:)=clim_sst(ii,:,:)+dble2flt(sst_remap(0,:,:))
        temp_wgt(ii,:,:)=where(temp_long .gt. 180 .and. temp_long .lt. 280 .and. temp_lat .gt. 0 .and. temp_lat .lt. 20, 1.0, 0.0)
    end do
    guess     = 1                ; use zonal means
    is_cyclic = True             ; cyclic [global]
    nscan     = 1500             ; usually much less than this
    eps       = 1.e-2            ; variable dependent
    relc      = 0.6              ; relaxation coefficient
    opt       = 0                ; not used
    poisson_grid_fill( clim_sst, is_cyclic, guess, nscan, eps, relc, opt) 
    delete(temp_wgt@_FillValue)
    temp_wgt=where(temp_wgt .eq. clim_sst@_FillValue, 0.0,temp_wgt)

    printVarSummary(clim_sst)
        
    ; file out
    a=systemfunc("rm ~/zwx/decouple_2015spring_sst.nc")
    out_file=addfile("~/zwx/decouple_2015spring_sst.nc","c")
    out_file->TEMP_12=clim_sst
    out_file->WGT_12=temp_wgt
    out_file->TLONG=temp_long
    out_file->TLAT=temp_lat

end
