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

begin
    if (.not. isvar("pre_dir") .or. .not. isvar("pro_dir") .or.\
        .not. isvar("fdname3d") .or.\
        .not. isvar("frstyear") .or. .not. isvar("lstyear") .or.\
        .not. isvar("case_name") .or.  .not. isvar("spinyear")) then 
        print("At least one argument has not been assigned, cannot continue!");
        exit
    end if
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================

    print("3D EXTRACT: Preparing...")
  
    do i = 0,dimsizes(fdname3d)-1

        ctrl_file1   = pre_dir+case_name+".cam.h0."+fdname3d(i)+"."+frstyear+"-"+lstyear+".nc"
        ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile

        print("3D EXTRACT: "+fdname3d(i)+" Reading...")
        ctrl_var1 = ctrl_in[:]->$fdname3d(i)$
        ctrl_ctrl_var1p = clmMonTLLL(ctrl_var1(spinyear*12,:,:,:))
        print("3D EXTRACT: "+fdname3d(i)+" interpolating...")

    ;************************************************
    ; Write the file
    ;************************************************

        print("3D EXTRACT: "+fdname3d(i)+" Writing...")
        pdata_fn = pro_dir+case_name+".cam.h0."+fdname3d(i)+".clim."+(frstyear+spinyear)+"-"+lstyear+".nc"
    ;Get dimsize
        dims=dimsizes(clim_ctrl_var1p(0,:,:,:))
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
        filevardef(fout,"time",typeof(clim_ctrl_var1p&time),getvardims(clim_ctrl_var1p&time))
        filevardef(fout,"level",typeof(clim_ctrl_var1p&level),getvardims(clim_ctrl_var1p&level))
        filevardef(fout,"lat",typeof(clim_ctrl_var1p&lat),getvardims(clim_ctrl_var1p&lat))
        filevardef(fout,"lon",typeof(clim_ctrl_var1p&lon),getvardims(clim_ctrl_var1p&lon))
        filevardef(fout,fdname3d(i),typeof(clim_ctrl_var1p),getvardims(clim_ctrl_var1p))

    ;Define Attribute
        filevarattdef(fout,"time",clim_ctrl_var1p&time)
        filevarattdef(fout,"level",clim_ctrl_var1p&level)
        filevarattdef(fout,"lat",clim_ctrl_var1p&lat)
        filevarattdef(fout,"lon",clim_ctrl_var1p&lon)
        filevarattdef(fout,fdname3d(i),clim_ctrl_var1)

        
        fout->time=(/clim_ctrl_var1p&time/)
        fout->level=(/clim_ctrl_var1p&level/)
        fout->lat=(/clim_ctrl_var1p&lat/)
        fout->lon=(/clim_ctrl_var1p&lon/)
        fout->$fdname3d(i)$=(/clim_ctrl_var1p/)
        delete([/clim_ctrl_var1, clim_ctrl_var1p, fout/])
        print("3D EXTRACT: "+fdname3d(i)+" Done!")

    end do
end
