load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"

begin

    diri="/home/yangsong3/data-model/CESM_CTRL/B2000_F19G16_CAM4_CTRL/pre/"
;    all_files=systemfunc("ls "+diri+"/*pop.h.02[5]*")
    all_files=systemfunc("ls "+diri+"/*pop.h.02[5-9]*")

    fin_SST = addfiles(all_files, "r")
    sst=fin_SST[:]->TEMP(:,{500},:,:)
    clim_sst=clmMonTLL(sst)
    printVarSummary(clim_sst)
    fout_SST=addfile("/home/yangsong3/data-model/CESM_CTRL/B2000_F19G16_CAM4_CTRL/spun-up-pro/B20f19-spun-up.pop.h.SST.250-299.nc", "c")
    fout_SST->SST=clim_sst

end
