;*************************************************************
;Aim: take 3D field from raw CAM output
;Mission:
;   1. Read data
;   3. High effeciency output to nc file
;                       Zhenning Li
;                       2015-09-21
;Last Edited:
;   2015-09-21  Create
;*************************************************************



load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    if (.not. isvar("pre_dir") .or. .not. isvar("pro_dir") .or.\
        .not. isvar("fdname3d") .or. .not. isvar("n_esm") .or. .not. isvar("case_name")) then 
        print("At least one argument has not been assigned, cannot continue!");
        exit
    end if
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
    setfileoption("nc","SuppressClose",False) ; don't close too many files
    do jj = 0,n_esm-1
        print("                                                    ")
        print("********ESM:"+(jj+1)+" 3D EXTRACT: Preparing********")
        pre_dir0 = pre_dir + "esm_"+(jj+1)


        all_files = systemfunc("ls "+pre_dir0+"/")  
        
        split_start=str_split(all_files(0),".") ;e.g. xxxx.cam.h1.0006-06-21-00000.nc
        start_day = str_sub_str(str_get_cols(split_start(3),5,9),"-","")

        split_end=str_split(all_files(dimsizes(all_files)-1),".") ;e.g. xxxx.cam.h1.0006-06-21-00000.nc
        end_day = str_sub_str(str_get_cols(split_end(3),5,9),"-","")
        
        ctrl_in      = addfiles (pre_dir0+"/"+all_files, "r")   ; note the "s" of addfile
        ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
  
        do i = 0,dimsizes(fdname3d)-1
            print("3D EXTRACT: "+fdname3d(i)+" Reading...")
            ctrl_var1 = ctrl_in[:]->$fdname3d(i)$


        ;************************************************
        ; Write the file
        ;************************************************

            print("3D EXTRACT: "+fdname3d(i)+" Writing...")
            pdata_fn = pro_dir+case_name+".cam.h1.ESM"+(jj+1)+"."+fdname3d(i)+".hybrid."+start_day+"-"+end_day+".nc"
        ;Get dimsize
            dims=dimsizes(ctrl_var1(0,:,:,:))
            nlvl=dims(0)
            nlat=dims(1)
            nlon=dims(2)
            
        ;Set fileoption    
            system("rm "+pdata_fn+" >& /dev/null")
            fout = addfile(pdata_fn ,"c")  ; open output netCDF file
            setfileoption(fout,"DefineMode",True)

        ;Set All field attribution
            fileAtt     = True
            fileAtt@creation_date=systemfunc("date")
            fileattdef(fout,fileAtt)

        ;Define Coordinate
            dimNames    =(/"time","lev","lat","lon"/)
            dimSizes    =(/-1,nlvl,nlat,nlon/)
            dimUnlim    =(/True,False,False,False/)
            filedimdef(fout,dimNames,dimSizes,dimUnlim)

        ;Define var, type and dim
            filevardef(fout,"time",typeof(ctrl_var1&time),getvardims(ctrl_var1&time))
            filevardef(fout,"lev",typeof(ctrl_var1&lev),getvardims(ctrl_var1&lev))
            filevardef(fout,"lat",typeof(ctrl_var1&lat),getvardims(ctrl_var1&lat))
            filevardef(fout,"lon",typeof(ctrl_var1&lon),getvardims(ctrl_var1&lon))
            filevardef(fout,fdname3d(i),typeof(ctrl_var1),getvardims(ctrl_var1))

        ;Define Attribute
            filevarattdef(fout,"time",ctrl_var1&time)
            filevarattdef(fout,"lev",ctrl_var1&lev)
            filevarattdef(fout,"lat",ctrl_var1&lat)
            filevarattdef(fout,"lon",ctrl_var1&lon)
            filevarattdef(fout,fdname3d(i),ctrl_var1)

            
            fout->time=(/ctrl_var1&time/)
            fout->lev=(/ctrl_var1&lev/)
            fout->lat=(/ctrl_var1&lat/)
            fout->lon=(/ctrl_var1&lon/)
            fout->$fdname3d(i)$=(/ctrl_var1/)
            delete([/ctrl_var1, fout/])
            print("3D EXTRACT: "+fdname3d(i)+" Done!")

        end do
        delete([/all_files, split_start, split_end, ctrl_in/])
        print("********ESM:"+(jj+1)+" 3D EXTRACT: Finished!********")

    end do 
end
