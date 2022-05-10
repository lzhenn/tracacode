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
    if (.not. isvar("pre_dir") .or. .not. isvar("pro_dir") .or.\
        .not. isvar("fdname2d") .or. .not. isvar("n_esm") .or. .not. isvar("case_name") .or. .not. isvar("esm_name")) then 
        print("2D EXTRACT: At least one argument has not been assigned, cannot continue!");
        exit
    end if

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================

    do jj = 0,n_esm-1
        print("                                                    ")
        print("********ESM:"+(jj+1)+" 2D EXTRACT: Preparing********")
        pre_dir0 = pre_dir + esm_name+(jj+1)

        setfileoption("nc","SuppressClose",False) ; don't close too many files
        
        all_files = systemfunc("ls "+pre_dir0+"/*.nc")  
        
        split_start=str_split(all_files(0),".") ;e.g. xxxx.cam.h1.0006-06-21-00000.nc
        start_day = str_sub_str(str_get_cols(split_start(3),5,9),"-","")

        split_end=str_split(all_files(dimsizes(all_files)-1),".") ;e.g. xxxx.cam.h1.0006-06-21-00000.nc
        end_day = str_sub_str(str_get_cols(split_end(3),5,9),"-","")
        
        ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
        
       
        do i = 0,dimsizes(fdname2d)-1
            print("  2D EXTRACT: "+fdname2d(i)+" Reading...")
            ctrl_var1 = ctrl_in[:]->$fdname2d(i)$

            print("  2D EXTRACT: "+fdname2d(i)+" Writing...")
            pdata_fn = pro_dir+case_name+".cam.h1."+esm_name+(jj+1)+"."+fdname2d(i)+"."+start_day+"-"+end_day+".nc"
        ;Get dimsize
            dims=dimsizes(ctrl_var1)
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
            dimNames    =(/"time","lat","lon"/)
            dimSizes    =(/-1,nlat,nlon/)
            dimUnlim    =(/True,False,False/)
            filedimdef(fout,dimNames,dimSizes,dimUnlim)

        ;Define var, type and dim
            filevardef(fout,"time",typeof(ctrl_var1&time),getvardims(ctrl_var1&time))
            filevardef(fout,"lat",typeof(ctrl_var1&lat),getvardims(ctrl_var1&lat))
            filevardef(fout,"lon",typeof(ctrl_var1&lon),getvardims(ctrl_var1&lon))
            filevardef(fout,fdname2d(i),typeof(ctrl_var1),getvardims(ctrl_var1))

        ;Define Attribute
            filevarattdef(fout,"time",ctrl_var1&time)
            filevarattdef(fout,"lat",ctrl_var1&lat)
            filevarattdef(fout,"lon",ctrl_var1&lon)
            filevarattdef(fout,fdname2d(i),ctrl_var1)

            
            fout->time=(/ctrl_var1&time/)
            fout->lat=(/ctrl_var1&lat/)
            fout->lon=(/ctrl_var1&lon/)
            fout->$fdname2d(i)$=(/ctrl_var1/)
            delete([/ctrl_var1,  fout/])
            delete([/dims, nlat, nlon, fileAtt, dimNames, dimSizes, dimUnlim/])
            print("  2D EXTRACT: "+fdname2d(i)+" Done!")
        end do
        delete([/all_files, split_start, split_end, ctrl_in/])
        print("********ESM:"+(jj+1)+" 2D EXTRACT: Finished!********")
    end do
end
