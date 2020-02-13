load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    all_files=systemfunc("ls "+"*.nc")
    ctrl_in      = addfiles(all_files,"r")
    sst=ctrl_in[:]->SSTK_GDS0_SFC_S123
    out_f=addfile("interim.1x1.sst.1979-2019.nc","c")
    out_f->sst=sst
end 
