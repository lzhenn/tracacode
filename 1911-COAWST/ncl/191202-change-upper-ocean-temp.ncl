load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "./ROMS_utils.ncl"
begin
    ; bath file

    fhis    = "../data/1911-COAWST/joe_tc_ctrl/ocean_joe_tcs_his.nc"
    his   =  addfile (fhis,"r") 
    depth   = roms_get_depth(his)
    
    ; init file
    ctrl_in      = addfile("../data/1911-COAWST/joe_tc_sen/joe_tc_ocean_init_org.nc","r")
    temp=ctrl_in->temp
    temp_org=temp
    temp(0,:,:,:)=where(depth .gt. -100, temp(0,:,:,:)+2.0, temp(0,:,:,:))
    printVarSummary(depth)
    printVarSummary(temp)
    print(temp(0,:,0,:)-temp_org(0,:,0,:))

    out_f=addfile("../data/1911-COAWST/joe_tc_sen/joe_tc_ocean_init.nc","w")
    out_f->temp=temp
end 
