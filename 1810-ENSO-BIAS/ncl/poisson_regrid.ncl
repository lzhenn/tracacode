load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"

begin
     diri="~/zwx/GODAS.temperature10ano.global.1p1.2015spring.nc"
     fin_SST = addfile(diri,"r")
     sst=fin_SST->TEM
     sst@_FillValue=-999
     printVarSummary(sst)
     replace_ieeenan(sst,sst@_FillValue,0) 
     print(" poisson filling...")
     guess     = 1                ; use zonal means
     is_cyclic = True             ; cyclic [global]
     nscan     = 1500             ; usually much less than this
     eps       = 1.e-2            ; variable dependent
     relc      = 0.6              ; relaxation coefficient
     opt       = 0                ; not used
     poisson_grid_fill( sst, is_cyclic, guess, nscan, eps, relc, opt) 
     
     print(" POP writing...")
     fout_SST=addfile("/home/yangsong3/zwx/GODAS.temperature10ano.global.1p1.2015spring.replacenan.nc", "c")
     fout_SST->TEM=sst

end
