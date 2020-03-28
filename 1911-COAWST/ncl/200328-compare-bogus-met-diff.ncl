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
    met_em_dir="/users/b145872/project-dir/app/WRF/run/met_em.before_bogus.nc"
    bogus_dir="/users/b145872/project-dir/app/WRF/run/met_em.d01.2018-09-13_12:00:00.nc"
    varname="RH"
    met_in      = addfile (met_em_dir, "r")   ; note the "s" of addfile
    bogus_in      = addfile (bogus_dir, "r")   ; note the "s" of addfile
     
    var_met:=met_in->$varname$
    var_bogus:=bogus_in->$varname$
    var_diff=var_bogus-var_met 
    wks  = gsn_open_wks("x11","zonal")              ; send graphics to PNG file
    res=True
    res@cnFillOn=True
    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
    res@cnLevels =    (/-10,-5,-3,-1,1,3,5,10/)
    res@tiMainString="diff "+varname
    plot=gsn_contour(wks,var_diff(0,0,:,:),res)           ; plot zonal ave

end
