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
        .not. isvar("fdname2d") .or. .not. isvar("frstyear") .or. .not. isvar("lstyear") .or. .not. isvar("case_name")) then 
        print("2D EXTRACT: At least one argument has not been assigned, cannot continue!");
        exit
    end if

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================

    n_esm = lstyear-frstyear+1
    do jj = 0,n_esm-1
        full_year=sprinti("%0.4i",(frstyear+jj))
        print("                                                    ")
        print("********Year: "+full_year+" 2D EXTRACT: Preparing********")

        setfileoption("nc","SuppressClose",False) ; don't close too many files
        all_files = systemfunc("ls "+pre_dir+"*cam.h1."+full_year+"*")  
        ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
        
       
        do i = 0,dimsizes(fdname2d)-1
            print("  2D EXTRACT: "+fdname2d(i)+" Reading...")
            ctrl_var1 = ctrl_in[:]->$fdname2d(i)$

            print("  2D EXTRACT: "+fdname2d(i)+" Writing...")
            pdata_fn = pro_dir+case_name+".cam.h1.YEAR."+full_year+".daily."+fdname2d(i)+".nc"
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
        delete([/all_files, ctrl_in/])
        print("********Year: "+full_year+" 2D EXTRACT: Finished********")
    end do
end
