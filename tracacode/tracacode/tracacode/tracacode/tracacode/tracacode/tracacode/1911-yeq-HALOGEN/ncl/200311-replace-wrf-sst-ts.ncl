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
    source_path="/disk/v092.yhuangci/coawst/cpl"
    out_path="/disk/v092.yhuangci/coawst/wrf-with-hfsst"
    multi_in=True
    
    casename="cpl" 
    wrfout_path="/disk/v092.yhuangci/coawst/"+casename
    g_font=0.02
    
    mask_in      = addfile (out_path+"/wrfout_d01_2016-10-16_12:00:00", "r")   ; note the "s" of addfile
  	lsmask  = wrf_user_getvar(mask_in,"LANDMASK", -1)
    if multi_in then
        all_files=systemfunc("ls "+source_path+"/wrfout_d01*")
        len_file=dimsizes(all_files)
        do ii = 0, len_file-1
            fn_array=str_split(all_files(ii),"/")
            fn_array=fn_array(::-1)
            print(all_files(ii)+"  "+fn_array(0))
            tgt_file=systemfunc("ls "+out_path+"/"+fn_array(0))
            if strlen(tgt_file) .gt. 0 then
                ctrl_in      = addfile (all_files(ii), "r")   ; note the "s" of addfile
  	            ctrl_var1  = wrf_user_getvar(ctrl_in,"SST", -1)
  	            ctrl_var2  = wrf_user_getvar(ctrl_in,"TMN", -1)
  	            ctrl_var3  = wrf_user_getvar(ctrl_in,"TSK", -1)

                out_in      = addfile(tgt_file, "w")
  	            out_var1  = wrf_user_getvar(out_in,"SST", -1)
  	            out_var2  = wrf_user_getvar(out_in,"TMN", -1)
  	            out_var3  = wrf_user_getvar(out_in,"TSK", -1)
                out_var1=where(lsmask .eq. 0, ctrl_var1, out_var1)
                out_var2=where(lsmask .eq. 0, ctrl_var2, out_var2)
                out_var3=where(lsmask .eq. 0, ctrl_var3, out_var3)
                out_in->SST=out_var1
                out_in->TMN=out_var2
                out_in->TSK=out_var3
            end if

        end do
    else
        ctrl_in      = addfile (wrfout_path, "r")   ; note the "s" of addfile
    end if

end
