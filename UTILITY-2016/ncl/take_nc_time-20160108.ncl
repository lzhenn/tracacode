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
    if (.not. isvar("nc"))  then 
        print("TAKE NC TIME: 'nc' argument has not been assigned, cannot continue!");
        exit
    end if
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
    print("---------------------TAKE NC TIME---------------------")
    print("Processed File: "+nc)
    
    ctrl_in1 = addfile(nc,"r")
    
    time = ctrl_in1->time
    
    yyyymmdd =floor( cd_calendar(time,-2))
    length=dimsizes(yyyymmdd)

    print("Record Start:   "+sprintf("%8.0f",yyyymmdd(0)))

    print("Record End:     "+sprintf("%8.0f",yyyymmdd(length-1)))
    print("Record Length:  "+length)
    print("-------------------L_Zealot Product-------------------")
end
