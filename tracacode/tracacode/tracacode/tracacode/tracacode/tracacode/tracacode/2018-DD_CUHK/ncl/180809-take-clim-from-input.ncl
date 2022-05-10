load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    ystrt=2000
    yend=2015
    
    
    workdir="/users/yangsong3/L_Zealot/wrf/WRFV3/run/precon/"
    domainlist=(/"d01","d02","d03"/)
    

varlist=(/"ZNU","ZNW","U","V","W","PH","PHB","T","T_INIT","MU","MUB","P","PB","FNM","FNP","RDNW","RDN","DNW","DN","T_BASE","CFN","CFN1","P_HYD","Q2","T2","TH2","PSFC","U10","V10","ZETATOP","CF1","CF2","CF3","QVAPOR","QCLOUD","QRAIN","QICE","QSNOW","QGRAUP","FCX","GCX","TSLB","SMOIS","SH2O","SMCREL","SEAICE","VEGFRA","SNOW","SNOWH","CANWAT","UOCE","VOCE","LAI","O3RAD","TSK","U_BASE","V_BASE","QV_BASE","Z_BASE","U_FRAME","V_FRAME","P_TOP","T00","P00","TLP","TISO","TLP_STRAT","P_STRAT","ALBBCK","TMN","SR","BF","C1H","C2H","BH","C1F","C2F","C3H","C4H","C3F","C4F","PCB","PC","SST"/)
    do ii=0,dimsizes(domainlist)-1
        sample_in=addfile(workdir+"clim/wrfinput_"+domainlist(ii),"rw")
        do kk=0, dimsizes(varlist)-1
            print("var $"+varlist(kk)+"$ @ "+domainlist(ii)+" ("+tostring(kk+1)+"/"+dimsizes(varlist)+")")
            var_sample:=sample_in->$varlist(kk)$
            var_sample=(/0.0/)
            do jj=ystrt, yend   ; loop year
                workfile=workdir+tostring(jj)+"/wrfinput_"+domainlist(ii)
                ctrl_in=addfile(workfile, "r") 
                var:=ctrl_in->$varlist(kk)$
                var_sample=(/var_sample+var/)
            end do
            var_sample=(/var_sample/(yend-ystrt+1)/)
            sample_in->$varlist(kk)$=(/var_sample/)
        end do
    end do
end
