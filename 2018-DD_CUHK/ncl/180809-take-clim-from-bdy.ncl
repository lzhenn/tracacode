load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    ystrt=2000
    yend=2015
    
    
    workdir="/users/yangsong3/L_Zealot/wrf/WRFV3/run/precon/"
    varlist=(/"U_BXS","U_BXE","U_BYS","U_BYE","U_BTXS","U_BTXE","U_BTYS","U_BTYE","V_BXS","V_BXE","V_BYS","V_BYE","V_BTXS","V_BTXE","V_BTYS","V_BTYE","W_BXS","W_BXE","W_BYS","W_BYE","W_BTXS","W_BTXE","W_BTYS","W_BTYE","PH_BXS","PH_BXE","PH_BYS","PH_BYE","PH_BTXS","PH_BTXE","PH_BTYS","PH_BTYE","T_BXS","T_BXE","T_BYS","T_BYE","T_BTXS","T_BTXE","T_BTYS","T_BTYE","MU_BXS","MU_BXE","MU_BYS","MU_BYE","MU_BTXS","MU_BTXE","MU_BTYS","MU_BTYE","QVAPOR_BXS","QVAPOR_BXE","QVAPOR_BYS","QVAPOR_BYE","QCLOUD_BXS","QCLOUD_BXE","QCLOUD_BYS","QCLOUD_BYE","QRAIN_BXS","QRAIN_BXE","QRAIN_BYS","QRAIN_BYE","QICE_BXS","QICE_BXE","QICE_BYS","QICE_BYE","QSNOW_BXS","QSNOW_BXE","QSNOW_BYS","QSNOW_BYE","QGRAUP_BXS","QGRAUP_BXE","QGRAUP_BYS","QGRAUP_BYE","QVAPOR_BTXS","QVAPOR_BTXE","QVAPOR_BTYS","QVAPOR_BTYE","QCLOUD_BTXS","QCLOUD_BTXE","QCLOUD_BTYS","QCLOUD_BTYE","QRAIN_BTXS","QRAIN_BTXE","QRAIN_BTYS","QRAIN_BTYE","QICE_BTXS","QICE_BTXE","QICE_BTYS","QICE_BTYE","QSNOW_BTXS","QSNOW_BTXE","QSNOW_BTYS","QSNOW_BTYE","QGRAUP_BTXS","QGRAUP_BTXE","QGRAUP_BTYS","QGRAUP_BTYE","HT_SHAD_BXS","HT_SHAD_BXE","HT_SHAD_BYS","HT_SHAD_BYE","HT_SHAD_BTXS","HT_SHAD_BTXE","HT_SHAD_BTYS","HT_SHAD_BTYE","PC_BXS","PC_BXE","PC_BYS","PC_BYE","PC_BTXS","PC_BTXE","PC_BTYS"/)
   
    sample_in=addfile(workdir+"clim/wrfbdy_d01","rw")
    
    do kk=0, dimsizes(varlist)-1
        print("var $"+varlist(kk)+"$ ("+tostring(kk+1)+"/"+dimsizes(varlist)+")")
        var_sample:=sample_in->$varlist(kk)$
        var_sample=(/0.0/)
        do jj=ystrt, yend   ; loop year
            workfile=workdir+tostring(jj)+"/wrfbdy_d01"
            print("woriking on "+jj+"...")
            ctrl_in=addfile(workfile, "r") 
            var:=ctrl_in->$varlist(kk)$
            var_sample=(/var_sample+var/)
        end do
        var_sample=(/var_sample/(yend-ystrt+1)/)
        sample_in->$varlist(kk)$=(/var_sample/)
    end do
end
