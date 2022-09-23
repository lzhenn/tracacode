begin

  ;grid file
  nc_in="/disk/hq247/yhuangci/analy/BrC/cmaq_check/data/NBB_NFB/COMBINE_CONC_12km_20150301.nc"
  bin_out="/home/lzhenn/temp/test.bin"

  ncdf     = addfile(nc_in, "r")  ; open output netCDF file
  data = ncdf->AOMIJ
  printVarSummary(data)
  print(data(1,1,100,200))
  fbinrecwrite (bin_out, -1, data)
end

