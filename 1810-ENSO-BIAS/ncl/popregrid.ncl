load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"

begin

    do i=1,36,1

        diri="/home/yangsong3/data-observation/SST/OISST_daily/mean/"
        y=1981+i
        print(y+" reading...")
        fin_SST = addfile(diri+"sst.day.mean."+y+".v2.nc", "r")
        SST=fin_SST->sst
        lon=fin_SST->lon
        lat=fin_SST->lat
        lon0=fspan(0.5,359.5,360)
        lat0=fspan(-89.5,89.5,180)
             
        print(y+" poisson filling...")
        guess     = 1                ; use zonal means
        is_cyclic = True             ; cyclic [global]
        nscan     = 1500             ; usually much less than this
        eps       = 1.e-2            ; variable dependent
        relc      = 0.6              ; relaxation coefficient
        opt       = 0                ; not used
        poisson_grid_fill( SST, is_cyclic, guess, nscan, eps, relc, opt) 
        
        print(y+" POP regriding...")
        SST_regrid=linint2_Wrap(lon,lat,SST,True,lon0,lat0,0)
        delete(lon)
        delete(lat)
        delete(SST)
        SST_remap=PopLatLon(SST_regrid,"1x1d","gx1v6","bilin","da","100716")
        delete(SST_regrid)
        print(y+" POP writing...")
        fout_SST=addfile("/home/yangsong3/zwx/sst_pop/sst_POPgrid.day.mean."+y+".v2.nc", "c")
        fout_SST->SST=SST_remap
        delete(SST_remap)

    end do

end
