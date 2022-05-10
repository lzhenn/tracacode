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

begin
    if (.not. isvar("pre_dir") .or. .not. isvar("pro_dir") .or.\
        .not. isvar("fdname3d") .or. .not. isvar("layers") .or. .not. isvar("esm_name") .or.\
        .not. isvar("case_name") .or. .not. isvar("n_esm") .or. .not. isvar("plev")) then 
        print("At least one argument has not been assigned, cannot continue!");
        exit
    end if
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
    setfileoption("nc","SuppressClose",False) ; don't close too many files
    print("                                                    ")
    print("********ESM:"+n_esm+" 3D EXTRACT: Preparing********")


    all_files = systemfunc("ls "+pre_dir+"/*h1*.nc")  
    
    split_start=str_split(all_files(0),".") ;e.g. xxxx.cam.h1.0006-06-21-00000.nc
    start_day = str_sub_str(str_get_cols(split_start(3),5,9),"-","")

    split_end=str_split(all_files(dimsizes(all_files)-1),".") ;e.g. xxxx.cam.h1.0006-06-21-00000.nc
    end_day = str_sub_str(str_get_cols(split_end(3),5,9),"-","")
    
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
    ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
   
    do i = 0,dimsizes(fdname3d)-1
        print("3D EXTRACT: "+fdname3d(i)+" Reading...")
        ctrl_var1 = ctrl_in[:]->$fdname3d(i)$

        hbcofa	    =   ctrl_in[:]->hyam(0:layers-1)
        hbcofb	    =   ctrl_in[:]->hybm(0:layers-1)
        ctrl_psfc   =   ctrl_in[:]->PS
        p0	        =   1000

        print("3D EXTRACT: "+fdname3d(i)+" interpolating...")
    ;************************************************
    ; define other arguments required by vinth2p
    ;************************************************
    ; type of interpolation: 1 = linear, 2 = log, 3 = loglog
        interp = 2 

    ; is extrapolation desired if data is outside the range of PS
        extrap = False

          
    ;************************************************
    ; calculate T on pressure levels
    ;************************************************
    ; note, the 7th argument is not used, and so is set to 1.
    ;************************************************
        ctrl_var1p = vinth2p(ctrl_var1,hbcofa,hbcofb,plev,ctrl_psfc,interp,p0,1,extrap)
        ctrl_var1p!1 = "level"
        ctrl_var1p&level@long_name="Level"
        ctrl_var1p&level@units="millibar"
        ctrl_var1p&level@GRIB_id="100s"
        ctrl_var1p&level@GRIB_name="hPa"
        ctrl_var1p&level@axis="Z"
        ctrl_var1p&level@coordinate_defines = "point"
    ;************************************************
    ; Write the file
    ;************************************************

        print("3D EXTRACT: "+fdname3d(i)+" Writing...")
        pdata_fn = pro_dir+case_name+".cam.h1."+esm_name+sprinti("%0.3i",n_esm)+"."+fdname3d(i)+"."+start_day+"-"+end_day+".nc"
    ;Get dimsize
        dims=dimsizes(ctrl_var1p(0,:,:,:))
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
        dimNames    =(/"time","level","lat","lon"/)
        dimSizes    =(/-1,nlvl,nlat,nlon/)
        dimUnlim    =(/True,False,False,False/)
        filedimdef(fout,dimNames,dimSizes,dimUnlim)

    ;Define var, type and dim
        filevardef(fout,"time",typeof(ctrl_var1p&time),getvardims(ctrl_var1p&time))
        filevardef(fout,"level",typeof(ctrl_var1p&level),getvardims(ctrl_var1p&level))
        filevardef(fout,"lat",typeof(ctrl_var1p&lat),getvardims(ctrl_var1p&lat))
        filevardef(fout,"lon",typeof(ctrl_var1p&lon),getvardims(ctrl_var1p&lon))
        filevardef(fout,fdname3d(i),typeof(ctrl_var1p),getvardims(ctrl_var1p))

    ;Define Attribute
        filevarattdef(fout,"time",ctrl_var1p&time)
        filevarattdef(fout,"level",ctrl_var1p&level)
        filevarattdef(fout,"lat",ctrl_var1p&lat)
        filevarattdef(fout,"lon",ctrl_var1p&lon)
        filevarattdef(fout,fdname3d(i),ctrl_var1)

        
        fout->time=(/ctrl_var1p&time/)
        fout->level=(/ctrl_var1p&level/)
        fout->lat=(/ctrl_var1p&lat/)
        fout->lon=(/ctrl_var1p&lon/)
        fout->$fdname3d(i)$=(/ctrl_var1p/)
        delete([/ctrl_var1, ctrl_var1p, fout/])
        print("3D EXTRACT: "+fdname3d(i)+" Done!")

    end do
    delete([/all_files, split_start, split_end, ctrl_in/])
    print("********ESM:"+n_esm+" 3D EXTRACT: Finished!********")
end
