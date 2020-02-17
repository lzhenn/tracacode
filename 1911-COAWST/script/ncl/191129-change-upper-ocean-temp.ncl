load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
    ; bath file
    bath_in     = addfile("../data/1911-COAWST/joe_tc_ctrl/ocean_avg.nc", "r")
    bath=bath_in->h

    ; init file
    ctrl_in      = addfile("../data/1911-COAWST/joe_tc_sen/joe_tc_ocean_init_org.nc","r")
    temp=ctrl_in->temp
    temp_org=temp
    
    ; five surface layers for all grids
    temp(:,16:20,:,:)=temp(0,16:20,:,:)+2.0
    
    ; all leayers for region water depth lower than 110m
    do ii = 0,15
        temp(0,ii,:,:)=where(bath .lt. 110, temp(0,ii,:,:)+2.0, temp(0,ii,:,:))
    end do
    ;transient layers
    do jj=58,88
        bot_layer_id=round((bath(0,jj)-100)/56.25,3)
        temp(0,bot_layer_id:15,:,jj)=temp(0,bot_layer_id:15,:,jj)+2.0
    end do
    print(temp(0,:,0,:)-temp_org(0,:,0,:))

    out_f=addfile("../data/1911-COAWST/joe_tc_sen/joe_tc_ocean_init.nc","w")
    out_f->temp=temp
end 
