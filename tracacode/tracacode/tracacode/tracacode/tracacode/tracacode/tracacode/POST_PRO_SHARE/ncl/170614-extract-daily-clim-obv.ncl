;*************************************************************
;Aim: take 3D clim field from post CAM output
;Mission:
;   1. Read post processed data
;   2. Calculate climatology
;   3. High effeciency output to nc file
;                       Zhenning Li
;         Last modified: 2017-04-01 
;Last Edited:
;   2015-09-21  Create
;   2017-04-03  Modify to fit clim output
;*************************************************************




load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"
begin
    if (.not. isvar("pre_dir") .or. .not. isvar("fdname") .or. .not. isvar("pro_dir")) then 
        print(" At least one argument has not been assigned, cannot continue!");
        exit
    end if

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
    
    clim_var1=read_large_daily_batch_return_mean(fdname, pre_dir)
    
    ;Write
    pro_dir=pro_dir+fdname+".mean.nc"
    print(fdname+" Writing: "+pro_dir)
    ndim=dimsizes(dimsizes(clim_var1))
    if ndim .eq. 4 then
        write_TLLL_to_nc(fdname,clim_var1,pro_dir)
    else
        write_TLL_to_nc(fdname,clim_var1,pro_dir)
    end if
end
