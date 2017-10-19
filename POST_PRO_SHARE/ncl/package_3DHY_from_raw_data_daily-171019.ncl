;*************************************************************
;Aim: take 3D field from raw CAM output
;Mission:
;   1. Read data
;   2. Post-post process
;   3. High effeciency output to nc file
;                       Zhenning Li
;                       2015-09-21
;Last Edited:
;   2015-09-21  Create
;*************************************************************



load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"
begin
    if (.not. isvar("pre_dir") .or. .not. isvar("pro_dir") .or.\
        .not. isvar("fdname3d") .or. .not. isvar("layers") .or. .not. isvar("lstyear") .or.\
        .not. isvar("case_name") .or. .not. isvar("frstyear")) then 
        print("3D EXTRACT: At least one argument has not been assigned, cannot continue!")
        exit
    end if
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
    setfileoption("nc","SuppressClose",False) ; don't close too many files
    n_esm = lstyear-frstyear+1
    do jj = 0,n_esm-1
        full_year=sprinti("%0.4i",(frstyear+jj))
        print("                                                    ")
        print("********Year: "+full_year+" 3D EXTRACT: Preparing********")

        all_files = systemfunc("ls "+pre_dir+"*cam.h1."+full_year+"*")  
        ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
        
       
        do i = 0,dimsizes(fdname3d)-1
            print("3D EXTRACT: "+fdname3d(i)+" Reading...")
            ctrl_var1 = ctrl_in[:]->$fdname3d(i)$

            print("3D EXTRACT: "+fdname3d(i)+" Writing...")
            pdata_fn = pro_dir+case_name+".cam.h1.YEAR."+full_year+".daily."+fdname3d(i)+".nc"
            write_TLLL_to_nc(fdname3d(i), ctrl_var1, pdata_fn)  
            print("3D EXTRACT: "+fdname3d(i)+" Done!")
        end do
        delete([/all_files, ctrl_in/])
        print("********Year:"+full_year+" 3D EXTRACT: Finished!********")
    end do
end
