load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    
    indir="/users/yangsong3/L_Zealot/wrf/WRFV3/run/precon/"
    outdir="/users/yangsong3/L_Zealot/wrf/WRFV3/run/caserun/"
    domainlist=(/"d01","d02","d03"/)
    
    varlist=(/"TSK", "TMN","TSLB","SMOIS","SH2O","SMCREL"/)
    
    do ii=0,dimsizes(domainlist)-1
        sample_in=addfile(indir+"2018/wrfrst_"+domainlist(ii)+"_2018-06-06_00:00:00","r")
        sample_out=addfile(outdir+"hwspin/wrfinput_"+domainlist(ii),"w")
        do kk=0, dimsizes(varlist)-1
            print("var $"+varlist(kk)+"$ @ "+domainlist(ii)+" ("+tostring(kk+1)+"/"+dimsizes(varlist)+")")
            var_sample:=sample_in->$varlist(kk)$
            sample_out->$varlist(kk)$=(/var_sample/)
        end do
    end do

end
