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
        .not. isvar("fdname2d") .or. .not. isvar("frstyear") .or.\
        .not. isvar("lstyear") .or. .not. isvar("case_name")) .or.\
        .not. isvar("out_name") then 
        print("2D EXTRACT: At least one argument has not been assigned, cannot continue!");
        exit
    end if

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================

    print("2D EXTRACT: Preparing...")
    mon_str=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)

    setfileoption("nc","SuppressClose",False) ; don't close too many files
    
    all_files = new(12*(lstyear-frstyear+1),string)
    do i =frstyear,lstyear
        yr_str=sprinti("%0.4i",(i))
        all_files(12*(i-frstyear):12*(i-frstyear)+11) = pre_dir+case_name+".cam.h0."+yr_str+"-"+mon_str+".nc"
    end do
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
   
    do i = 0,dimsizes(fdname2d)-1
        print("2D EXTRACT: "+fdname2d(i)+" Reading...")
        ctrl_var1 = ctrl_in[:]->$fdname2d(i)$

        print("2D EXTRACT: "+fdname2d(i)+" Writing...")
        pdata_fn = pro_dir+case_name+"."+out_name+".cam.h0."+fdname2d(i)+"."+frstyear+"-"+lstyear+".nc"
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
        print("2D EXTRACT: "+fdname2d(i)+" Done!")

    end do
end
