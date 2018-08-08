load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    ystrt=2000
    yend=2005
    
    varlist=(/"PRES","SM","ST", "GHT","SNOWH","SNOW","SKINTEMP","SOILHGT","SEAICE","ST010200","ST000010","SM010200","SM000010","PSFC","RH","VV","UU","TT","PMSL","OL4","OL3","OL2","OL1","OA4","OA3","OA2","OA1","VAR","CON","SNOALB","SOILTEMP"/)
    
    workdir="/users/yangsong3/L_Zealot/wrf/WPS/met_em"
    infiles=systemfunc("ls "+ workdir+"/clim00-05/")
    lenfile=dimsizes(infiles)
    do ii=0, lenfile-1      ; loop file
        print("woriking on "+str_sub_str(infiles(ii),"2000-","clim.")+"...")
        sample_in=addfile(workdir+"/clim00-05/"+infiles(ii),"rw")
        do kk=0, dimsizes(varlist)-1
            print("var $"+varlist(kk)+"$ ("+tostring(kk+1)+"/"+dimsizes(varlist)+")")
            var_sample:=sample_in->$varlist(kk)$
            var_sample=(/0.0/)
            do jj=ystrt, yend   ; loop year
                workfile=workdir+"/"+jj+"/"+str_sub_str(infiles(ii),"2000",tostring(jj))
                ctrl_in=addfile(workfile, "r") 
                var:=ctrl_in->$varlist(kk)$
                var_sample=(/var_sample+var/)
            end do
            var_sample=(/var_sample/(yend-ystrt+1)/)
            sample_in->$varlist(kk)$=(/var_sample/)
        end do
    end do
end
