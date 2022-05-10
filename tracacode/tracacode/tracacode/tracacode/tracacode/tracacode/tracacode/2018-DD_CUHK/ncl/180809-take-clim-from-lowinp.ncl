load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    ystrt=2000
    yend=2015
    
    
    workdir="/users/yangsong3/L_Zealot/wrf/WRFV3/run/precon/"
    domainlist=(/"d01","d02","d03"/)
    
    varlist=(/"SEAICE","VEGFRA","UOCE","VOCE","LAI","ALBBCK","SST"/)
    do ii=0,dimsizes(domainlist)-1
        sample_in=addfile(workdir+"clim/wrflowinp_"+domainlist(ii),"rw")
        do kk=0, dimsizes(varlist)-1
            print("var $"+varlist(kk)+"$ @ "+domainlist(ii)+" ("+tostring(kk+1)+"/"+dimsizes(varlist)+")")
            var_sample:=sample_in->$varlist(kk)$
            var_sample=(/0.0/)
            do jj=ystrt, yend   ; loop year
                workfile=workdir+tostring(jj)+"/wrflowinp_"+domainlist(ii)
                ctrl_in=addfile(workfile, "r") 
                var:=ctrl_in->$varlist(kk)$
                var_sample=(/var_sample+var/)
            end do
            var_sample=(/var_sample/(yend-ystrt+1)/)
            sample_in->$varlist(kk)$=(/var_sample/)
        end do
    end do
end
