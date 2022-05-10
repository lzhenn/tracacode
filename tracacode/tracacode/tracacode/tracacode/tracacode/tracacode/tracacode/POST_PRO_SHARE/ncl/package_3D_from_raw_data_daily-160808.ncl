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
        .not. isvar("fdname3d") .or. .not. isvar("layers") .or. .not. isvar("lstyear") .or.\
        .not. isvar("case_name") .or. .not. isvar("frstyear") .or. .not. isvar("plev")) then 
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
            pdata_fn = pro_dir+case_name+".cam.h1.YEAR."+full_year+".daily."+fdname3d(i)+".nc"
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
        delete([/all_files, ctrl_in/])
        print("********Year:"+full_year+" 3D EXTRACT: Finished!********")
    end do
end
