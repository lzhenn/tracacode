;*******************************************************
; lcnative_2.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"

begin
;************************************************
; open file and read in data
;************************************************
    met_em_dir="/users/b145872/project-dir/app/WRF/run/met_em.d01.2018-09-13_12:00:00.nc"
    bogus_dir="/users/b145872/project-dir/app/WRF/run/auxinput1_d01_2018-09-13_12:00:00.nc"
    
    varlist=(/"UU","VV","TT","RH","GHT","PMSL"/)
    nVars=dimsizes(varlist)

    ; get data 
    met_in      = addfile (met_em_dir, "w")   ; note the "s" of addfile
    bogus_in      = addfile (bogus_dir, "r")   ; note the "s" of addfile
    
    do ii=0, nVars-1
        var_met:=met_in->$varlist(ii)$
        var_bogus:=bogus_in->$varlist(ii)$
        if .not.(varlist(ii) .eq. "PMSL") then
            var_diff_ly1:=var_bogus(0,1,:,:)-var_met(0,1,:,:)
            var_bogus(0,0,:,:)=(/var_met(0,0,:,:)+var_diff_ly1/)
        end if
        print("write "+varlist(ii))
        met_in->$varlist(ii)$=(/var_bogus/)
    end do
end


