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
    if (.not. isvar("pre_dir") .or. .not. isvar("fdname3d")) then 
        print("3D EXTRACT: At least one argument has not been assigned, cannot continue!");
        exit
    end if

    pro_dir=pre_dir+"/clim/"
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================

    print("3D EXTRACT: Preparing...")
    do i = 0,dimsizes(fdname3d)-1
        
        ;Read
        all_files=systemfunc("ls "+pre_dir+"/*."+fdname3d(i)+".*")
        n_esm=dimsizes(all_files)
        setfileoption("nc","SuppressClose",False) ; close too many files
        ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile            
        ListSetType (ctrl_in, "join")             ; concatenate or "merge" (default)
        print("3D EXTRACT: "+fdname3d(i)+" Reading...")
        print("  ESM 1/"+n_esm+" Reading...")
        ctrl_var1 = ctrl_in[0]->$fdname3d(i)$
        clim_var1=ctrl_var1
        do jj=1,n_esm-1
            print("  ESM "+(jj+1)+"/"+n_esm+" Reading...")
            ctrl_var1 := ctrl_in[jj]->$fdname3d(i)$
            clim_var1=clim_var1+ctrl_var1
        end do

        ;Process
        out_name_ele=str_split(all_files(0),".")
        out_name=out_name_ele(0)+".cam.h1.ESM.clim."+fdname3d(i)+".nc" 
        out_name_ele:=str_split(out_name,"/")
        len=dimsizes(out_name_ele)
        out_name=pro_dir+out_name_ele(len-1)
        clim_var1=clim_var1/n_esm
        
        ;Write
        print("3D EXTRACT: "+fdname3d(i)+" Writing: "+out_name)
        write_TLLL_to_nc(fdname3d(i),clim_var1,out_name)
        delete([/out_name_ele,out_name/])
    end do
end
