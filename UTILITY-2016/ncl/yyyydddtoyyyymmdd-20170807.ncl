;*************************************************************
;Aim: take 2D field from raw CAM output
;Mission:
;   1. Read data
;   2. Post-post process
;   3. High effeciency output to nc file
;                       Zhenning Li
;         Last modified: 2015-09-21 
;Last Edited:
;   2015-09-21  Create
;*************************************************************




load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    if (.not. isvar("ddd"))  then 
        print("CONVERT TO MMDD: 'ddd' argument has not been assigned, cannot continue!");
        exit
    end if
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
;    ddd_int=stringtointeger(ddd)
    print(ddd+" ---> "+yyyyddd_to_yyyymmdd(ddd))
end
