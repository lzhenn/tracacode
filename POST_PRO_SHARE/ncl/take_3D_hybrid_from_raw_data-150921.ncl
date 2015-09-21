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
        .not. isvar("fdname3d") .or. .not. isvar("frstyear") .or. \
        .not. isvar("lstyear") .or. .not. isvar("case_name")) then 
        print("At least one argument has not been assigned, cannot continue!");
        exit
    end if
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================

    print("3D EXTRACT: Preparing...")
    mon_str=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)

    setfileoption("nc","SuppressClose",False) ; don't close too many files
    
    all_files = new(12*(lstyear-frstyear+1),string)
    do i =frstyear,lstyear
        if (i .lt. 10) then
            yr_str="000"+i
        else if (i .lt. 100) then
            yr_str="00"+i
        else
            yr_str="0"+i
        end if
        end if
        all_files(12*(i-frstyear):12*(i-frstyear)+11) = pre_dir+case_name+".cam.h0."+yr_str+"-"+mon_str+".nc"
    end do
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
   
    do i = 0,dimsizes(fdname3d)-1
        print("3D EXTRACT: "+fdname3d(i)+" Reading...")
        ctrl_var1 = ctrl_in[:]->$fdname3d(i)$


    ;************************************************
    ; Write the file
    ;************************************************

        print("3D EXTRACT: "+fdname3d(i)+" Writing...")
        pdata_fn = pro_dir+case_name+".cam.h0."+fdname3d(i)+".hybrid."+frstyear+"-"+lstyear+".nc"
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
end
