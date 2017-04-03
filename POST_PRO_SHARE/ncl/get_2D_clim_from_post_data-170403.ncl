;*************************************************************
;Aim: take 2D clim field from post CAM output
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
        .not. isvar("fdname2d") .or. .not. isvar("frstyear") .or.\
        .not. isvar("lstyear") .or. .not. isvar("case_name").or. .not. isvar("spinyear")) then 
        print("2D EXTRACT: At least one argument has not been assigned, cannot continue!");
        exit
    end if

; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================

    print("2D EXTRACT: Preparing...")
    do i = 0,dimsizes(fdname2d)-1
        ctrl_file1   = pre_dir+case_name+".cam.h0."+fdname2d(i)+"."+frstyear+"-"+lstyear+".nc"
        ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile

        print("2D EXTRACT: "+fdname2d(i)+" Reading...")
        ctrl_var1 = ctrl_in1->$fdname2d(i)$

        clim_ctrl_var1 = clmMonTLL(ctrl_var1(spinyear*12:,:,:))
        print("2D EXTRACT: "+fdname2d(i)+" Writing...")
        pdata_fn = pro_dir+case_name+".cam.h0."+fdname2d(i)+".clim."+(frstyear+spinyear)+"-"+lstyear+".nc"
    ;Get dimsize
        dims=dimsizes(clim_clim_ctrl_var1)
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
        filevardef(fout,"time",typeof(clim_ctrl_var1&time),getvardims(clim_ctrl_var1&time))
        filevardef(fout,"lat",typeof(clim_ctrl_var1&lat),getvardims(clim_ctrl_var1&lat))
        filevardef(fout,"lon",typeof(clim_ctrl_var1&lon),getvardims(clim_ctrl_var1&lon))
        filevardef(fout,fdname2d(i),typeof(clim_ctrl_var1),getvardims(clim_ctrl_var1))

    ;Define Attribute
        filevarattdef(fout,"time",clim_ctrl_var1&time)
        filevarattdef(fout,"lat",clim_ctrl_var1&lat)
        filevarattdef(fout,"lon",clim_ctrl_var1&lon)
        filevarattdef(fout,fdname2d(i),clim_ctrl_var1)

        
        fout->time=(/clim_ctrl_var1&time/)
        fout->lat=(/clim_ctrl_var1&lat/)
        fout->lon=(/clim_ctrl_var1&lon/)
        fout->$fdname2d(i)$=(/clim_ctrl_var1/)
        delete([/clim_ctrl_var1,  fout/])
        print("2D EXTRACT: "+fdname2d(i)+" Done!")

    end do
end
