load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCL_SELFLIB/../shp/cnmap/cnmap.ncl"

begin
;  f0=addfile("/ees/users/EMG/chang/wrf/WPS/geo_em.d03.nc","r")
;  lon=f0->XLONG(0,:,:)
;  lat=f0->XLAT(0,:,:)
  f0=addfile("/users/yangsong3/L_Zealot/wrf/WPS/geo_em/no-urb/geo_em.d01.nc","rw")
;   f0=addfile("/ees/users/EMG/zhiyong/wrfchem/3.4.1/WPS2/met_em.d01.2010-06-30_12:00:00.nc","r")
  lon=f0->XLONG_M(0,:,:)
  lat=f0->XLAT_M(0,:,:)
  lu=f0->LANDUSEF
  lui=f0->LU_INDEX
  
  lu(:,11,:,:)=(/lu(:,11,:,:)+lu(:,12,:,:)/)
  lu(:,12,:,:)=0.0
  dim=dimsizes(lu(0,0,:,:))
  do ii=0,dim(0)-1
    do jj=0,dim(1)-1
        lui(0,ii,jj)=maxind(lu(0,:,ii,jj))+1
    end do
  end do

  f0->LANDUSEF=(/lu/)
  f0->LU_INDEX=(/lui/)

  g_font=0.025
 
end
