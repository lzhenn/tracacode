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
        .not. isvar("fdname3d") .or. .not. isvar("layers") .or.\
        .not. isvar("frstyear") .or. .not. isvar("lstyear") .or.\
        .not. isvar("case_name") .or. .not. isvar("plev")) .or.\
        .not. isvar("out_name") then 
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
        yr_str=sprinti("%0.4i",(i))
        all_files(12*(i-frstyear):12*(i-frstyear)+11) = pre_dir+case_name+".cam.h0."+yr_str+"-"+mon_str+".nc"
    end do
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
        ctrl_var1p&lev_p@long_name="Uer specified pressure level"
        ctrl_var1p&lev_p@units="hPa"
    ;************************************************
    ; Write the file
    ;************************************************

        print("3D EXTRACT: "+fdname3d(i)+" Writing...")
        pdata_fn = pro_dir+case_name+"."+out_name+".cam.h0."+fdname3d(i)+"."+frstyear+"-"+lstyear+".nc"
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
        dimNames    =(/"time","lev_p","lat","lon"/)
        dimSizes    =(/-1,nlvl,nlat,nlon/)
        dimUnlim    =(/True,False,False,False/)
        filedimdef(fout,dimNames,dimSizes,dimUnlim)

    ;Define var, type and dim
        filevardef(fout,"time",typeof(ctrl_var1p&time),getvardims(ctrl_var1p&time))
        filevardef(fout,"lev_p",typeof(ctrl_var1p&lev_p),getvardims(ctrl_var1p&lev_p))
        filevardef(fout,"lat",typeof(ctrl_var1p&lat),getvardims(ctrl_var1p&lat))
        filevardef(fout,"lon",typeof(ctrl_var1p&lon),getvardims(ctrl_var1p&lon))
        filevardef(fout,fdname3d(i),typeof(ctrl_var1p),getvardims(ctrl_var1p))

    ;Define Attribute
        filevarattdef(fout,"time",ctrl_var1p&time)
        filevarattdef(fout,"lev_p",ctrl_var1p&lev_p)
        filevarattdef(fout,"lat",ctrl_var1p&lat)
        filevarattdef(fout,"lon",ctrl_var1p&lon)
        filevarattdef(fout,fdname3d(i),ctrl_var1)

        
        fout->time=(/ctrl_var1p&time/)
        fout->lev_p=(/ctrl_var1p&lev_p/)
        fout->lat=(/ctrl_var1p&lat/)
        fout->lon=(/ctrl_var1p&lon/)
        fout->$fdname3d(i)$=(/ctrl_var1p/)
        delete([/ctrl_var1, ctrl_var1p, fout/])
        print("3D EXTRACT: "+fdname3d(i)+" Done!")

    end do
end
