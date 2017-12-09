; 
;      File IO NCL, for different kinds of data sets, must use
;  absolute directory!
;                                           A L_Zealot Product
;                                               Feb 20 2017
; Format Instructions:
;       YDLLL   -- Year Day Lev Lat Lon format (3D Field)
;       YDLL    -- Year Day Lat Lon format (2D Field)
;


;**************************READ******************************
; -------------- added Feb 20 2017
; read_doe_daily_2Din3D(varname, level, filedir)

; -------------- added Feb 20 2017
; read_doe_daily_3D(varname,  lev_top, lev_bot, latS, latN, lonW, lonE, filedir)

; -------------- added Feb 21 2017
; read_era_daily_3D(varname, lev_top, lev_bot, latS, latN, lonW, lonE, filedir)

; -------------- added Feb 22 2017
; read_oisst_daily(latS, latN, lonW, lonE, filedir)

; -------------- added Feb 22 2017
; read_era_daily_2Din3D(varname, lev, latS, latN, lonW, lonE, filedir)

; -------------- added Apr 05 2017
; read_noaa_olr_daily_2D(strtday, endday, latS, latN, lonW, lonE, filedir)

; -------------- added Apr 08 2017
; read_ncep_ncar_daily_3D(varname, lev_top, lev_bot, latS, latN, lonW, lonE, filedir)

; -------------- added Apr 10 2017
; read_ncep_ncar_daily_3D_UV(varname, lev_top, lev_bot, latS, latN, lonW, lonE, filedir)

; -------------- modified Sep 07 2017  **THIS IS THE TEMPLATE**
; read_doe_daily_2D(varname, index_start, index_end, filedir)

; -------------- added Jun 12 2017
; read_large_daily_batch_return_mean(varname, filedir)

; -------------- added Dec 08 2017
; read_large_daily_batch_return_batch(varname:string, filedir:string, strt_year, end_year, lev_top, lev_bot, latS, latN, lonW, lonE)

;**************************WRITE******************************
; -------------- added Apr 25 2017
; write_TLLL_to_nc(varname, var, filedir)

; -------------- added Jun 12 2017
; write_TLL_to_nc(varname, var, filedir)

; -------------- added Jun 12 2017
; write_YDLLL_to_nc(varname, var, filedir)

; -------------- added Jun 12 2017
; write_YDLL_to_nc(varname, var, filedir)




; ------------------------------    read_doe_daily_2Din3D   ------------------------------------
; *****************************************************************
; L_Zealot
; Read NCEP-DOE daily 2D data, in YDLL format
; Must start from 1979
;

undef ("read_doe_daily_2Din3D")
function read_doe_daily_2Din3D(varname:string, level, latS, latN, lonW, lonE, idx_s, idx_e, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_366, var_dim, var_dim365, var_data
begin
    in_files = systemfunc("ls "+filedir)
    
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in      = addfiles(in_files, "r")   ; note the "s" of addfile            
    n_esm=ListCount(ctrl_in)
    ListSetType (ctrl_in, "join")             ; concatenate or "merge" (default)
    print("3D EXTRACT: "+varname+" Reading...")
    print("  ESM 1/"+n_esm+" Reading...")
    var1 = short2flt(ctrl_in[0]->$varname$(idx_s:idx_e,{level},{latS:latN},{lonW:lonE}))
    ;Build ctrl_var1
    dim_var1=dimsizes(var1)
    ctrl_var1:=conform_dims((/n_esm,dim_var1(0),dim_var1(1),dim_var1(2)/),var1,(/1,2,3/))
    ctrl_var1!0="esm"
    ctrl_var1&esm=ispan(1,n_esm,1)
    ctrl_var1&esm@units="ensemble member"
    ctrl_var1!1="day"
    ctrl_var1&day=ispan(idx_s+1,idx_e+1,1)
    ctrl_var1&day@long_name="Julian Day of the year"
    ctrl_var1!2=var1!1
    ctrl_var1&lat=var1&lat
    ctrl_var1!3=var1!2
    ctrl_var1&lon=var1&lon
    copy_VarAtts(var1,ctrl_var1) 
    ctrl_var1(0,:,:,:)=(/var1/)
    do ii=1,n_esm-1
        print("  ESM "+(ii+1)+"/"+n_esm+" Reading...")
        var1 := short2flt(ctrl_in[ii]->$varname$)
        var1 := var1(idx_s:idx_e,{level},{latS:latN},{lonW:lonE})
        ctrl_var1(ii,:,:,:)=(/var1(idx_s:idx_e,{latS:latN},{lonW:lonE})/)
    end do
    return(ctrl_var1)
end
; ------------------------------    read_doe_daily_2Din3D   ------------------------------------

; ------------------------------    read_doe_daily_3D   ---------------------------------------
; *****************************************************************
; L_Zealot
; Read NCEP-DOE daily 3D data, in YDLLL format, bottom and top
; level should be assigned.
; Must start from 1979
;
function read_doe_daily_3D(varname:string, idx_s, idx_e,lev_top, lev_bot, latS, latN, lonW, lonE, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_dim, var_dim365, var_data
begin
    in_files = systemfunc("ls "+filedir)
    
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in      = addfiles(in_files, "r")   ; note the "s" of addfile            
    n_esm=ListCount(ctrl_in)
    ListSetType (ctrl_in, "join")             ; concatenate or "merge" (default)
    print("3D EXTRACT: "+varname+" Reading...")
    print("  ESM 1/"+n_esm+" Reading...")
    var1 = short2flt(ctrl_in[0]->$varname$(idx_s:idx_e, {lev_top:lev_bot},{latS:latN},{lonW:lonE}))
    ;Build ctrl_var1
    dim_var1=dimsizes(var1)
    ctrl_var1:=conform_dims((/n_esm,dim_var1(0),dim_var1(1),dim_var1(2),dim_var1(3)/),var1,(/1,2,3,4/))
    ctrl_var1!0="esm"
    ctrl_var1&esm=ispan(1,n_esm,1)
    ctrl_var1&esm@units="ensemble member"
    ctrl_var1!1="day"
    ctrl_var1&day=ispan(idx_s+1,idx_e+1,1)
    ctrl_var1&day@long_name="Julian Day of the year"
    ctrl_var1!2=var1!1
    ctrl_var1&level=var1&level
    ctrl_var1!3=var1!2
    ctrl_var1&lat=var1&lat
    ctrl_var1!4=var1!3
    ctrl_var1&lon=var1&lon
    copy_VarAtts(var1,ctrl_var1) 
    ctrl_var1(0,:,:,:,:)=(/var1/)
    do ii=1,n_esm-1
        print("  ESM "+(ii+1)+"/"+n_esm+" Reading...")
        var1 := short2flt(ctrl_in[ii]->$varname$)
        var1 := var1(idx_s:idx_e,{lev_bot:lev_top},{latS:latN},{lonW:lonE})
        ctrl_var1(ii,:,:,:,:)=(/var1/)
    end do
    return(ctrl_var1)
end
; ------------------------------    read_doe_daily_3D   ---------------------------------------




; ------------------------------    read_OISST_daily   ---------------------------------------
; *****************************************************************
; L_Zealot
; Read OISST daily data, in YLLL format. Must start from 1982
;
function read_oisst_daily(latS, latN, lonW, lonE, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_366, var_dim, var_dim365, var_data
begin
    in_files = systemfunc("ls "+filedir)
    setfileoption("nc","SuppressClose",False) ; close too many files
    inlist     = addfiles (in_files, "r")   ; note the "s" of addfile
    ListSetType (inlist, "join")
    var  =inlist[:]->sst(:,:,{latS:latN},{lonW:lonE})
    var_366  =inlist[1::4]->sst(:,:,{latS:latN},{lonW:lonE})
    var_dim = dimsizes(var_366)
    var_dim365 = dimsizes(var)
    len_yr= var_dim(0)+var_dim365(0)
    var_data = new((/len_yr, var_dim(1), var_dim(2), var_dim(3)/),"float")
    copy_VarMeta(var_366,var_data)
    ; Merge normal and leap years 
    sp = 0
    do ii=0,len_yr-1
        if (mod((ii-2),4) .eq. 0) then
            ; Data from 1982 (ii=0), 1984 (ii=2) is leap year
            var_data(ii,:,:,:) = var_366((ii-1)/4,:,:,:)
            sp=sp+1
        else
            var_data(ii,0:364,:,:) = var(ii-sp,:,:,:)
        end if
    end do
    return(var_data)
end
; ------------------------------    read_OISST_daily   ---------------------------------------


; ------------------------------    read_ERA_daily_2Din3D   ---------------------------------------
; *****************************************************************
; L_Zealot
; Read ERA-Interim daily 3D data, in YDLLL format, bottom and top
; level should be assigned.
; Must start from 1979
;
function read_era_daily_2Din3D(varname:string, lev, latS, latN, lonW, lonE, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_366, var_dim, var_dim365, var_data
begin
    in_files = systemfunc("ls "+filedir)
    setfileoption("nc","SuppressClose",False) ; close too many files
    inlist     = addfiles (in_files, "r")   ; note the "s" of addfile
    ListSetType (inlist, "join")
    var  =inlist[::-1]->$varname$(:,:,{lev},{latS:latN},{lonW:lonE})
    printVarSummary(var)
    var_366  =inlist[1::4]->$varname$(:,:,{lev},{latS:latN},{lonW:lonE})
    var_dim = dimsizes(var_366)
    var_dim365 = dimsizes(var)
    len_yr= var_dim(0)+var_dim365(0)
    var_data = new((/len_yr, var_dim(1), var_dim(2), var_dim(3)/),"float")
    copy_VarMeta(var_366,var_data)
    
    ; Merge normal and leap years 
    sp = 0
    do ii=0,len_yr-1
        if (mod((ii-1),4) .eq. 0) then
            var_data(ii,:,:,:) = var_366((ii-1)/4,:,:,:)
            sp=sp+1
        else
            var_data(ii,0:364,:,:) = var(ii-sp,:,:,:)
        end if
    end do
    return(var_data)
end
; ------------------------------    read_ERA_daily_2Din3D   ---------------------------------------

; ------------------------------    read_ERA_daily_3D   ---------------------------------------
; *****************************************************************
; L_Zealot
; Read ERA-Interim daily 3D data, in YDLLL format, bottom and top
; level should be assigned.
; Must start from 1979
;
function read_era_daily_3D(varname:string, lev_top, lev_bot, latS, latN, lonW, lonE, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_366, var_dim, var_dim365, var_data
begin
    in_files = systemfunc("ls "+filedir)
    setfileoption("nc","SuppressClose",False) ; close too many files
    inlist     = addfiles (in_files, "r")   ; note the "s" of addfile
    ListSetType (inlist, "join")
    var  =inlist[:]->$varname$(:,:,{lev_top:lev_bot},{latS:latN},{lonW:lonE})
    var_366  =inlist[1::4]->$varname$(:,:,{lev_top:lev_bot},{latS:latN},{lonW:lonE})
    var_dim = dimsizes(var_366)
    var_dim365 = dimsizes(var)
    len_yr= var_dim(0)+var_dim365(0)
    var_data = new((/len_yr, var_dim(1), var_dim(2), var_dim(3), var_dim(4)/),"float")
    copy_VarMeta(var_366,var_data)
    
    ; Merge normal and leap years 
    sp = 0
    do ii=0,len_yr-1
        if (mod((ii-1),4) .eq. 0) then
            var_data(ii,:,:,:,:) = var_366((ii-1)/4,:,:,:,:)
            sp=sp+1
        else
            var_data(ii,0:364,:,:,:) = var(ii-sp,:,:,:,:)
        end if
    end do
    return(var_data)
end
; ------------------------------    read_ERA_daily_3D   ---------------------------------------


; ------------------------------    read_noaa_olr_daily_2D   ---------------------------------------
function read_noaa_olr_daily_2D(strtday, endday, latS, latN, lonW, lonE, filedir:string)
begin
    g_strt_yr=1979
    g_lst_yr=2012
    in_file = addfile(filedir, "r")
    var1  = short2flt(in_file->olr(:,{latS:latN},{lonW:lonE}))
    var1_slice = var1(0:endday-strtday,:,:)
    time_hist    = in_file->time
    yyyymmdd  = cd_calendar(time_hist,-2)
    dim_time=dimsizes(yyyymmdd)
    yr_diff = g_lst_yr-g_strt_yr 
    
    slice_dim = dimsizes(var1_slice)
    var1_slice := conform_dims((/yr_diff+1,slice_dim(0),slice_dim(1),slice_dim(2)/),var1_slice,(/1,2,3/))
    copy_VarAtts(var1,var1_slice)
    var1_slice!0="year"
    var1_slice!1="time"
    var1_slice!2=var1!1
    var1_slice!3=var1!2
    var1_slice&lon=var1&lon
    var1_slice&lat=var1&lat
    var1_slice&time=ispan(strtday,endday,1)
    
    do ii=g_strt_yr,g_strt_yr+yr_diff
        g_strt_yyyyddd=1000*ii+strtday+1
        g_lst_yyyyddd=1000*ii+endday+1
        g_strt_yyyymmdd=yyyyddd_to_yyyymmdd(g_strt_yyyyddd)
        g_lst_yyyymmdd=yyyyddd_to_yyyymmdd(g_lst_yyyyddd)
        istrt   = ind(yyyymmdd .eq. g_strt_yyyymmdd)
        ilast   = ind(yyyymmdd .eq. g_lst_yyyymmdd)
        var1_slice(ii-g_strt_yr,:,:,:)=(/var1(istrt:ilast,:,:)/)
    end do 
    return(var1_slice)
end 
; ------------------------------    read_noaa_olr_daily_2D   ---------------------------------------


; ------------------------------    read_NCEP_NCAR_daily_3D   ---------------------------------------
; *****************************************************************
; L_Zealot
; Read NCEP-NCAR daily 3D data, in YDLLL format, bottom and top
; level should be assigned.
; Must start from 1948
;
function read_ncep_ncar_daily_3D(varname:string, lev_top, lev_bot, latS, latN, lonW, lonE, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_366, var_dim, var_dim365, var_data
begin
    in_files = systemfunc("ls "+filedir+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    inlist     = addfiles (in_files, "r")   ; note the "s" of addfile
    ListSetType (inlist, "join")
    var  =short2flt(inlist[0:30]->$varname$(:,:,{lev_top:lev_bot},{latS:latN},{lonW:lonE}))
    var1  =short2flt(inlist[31:]->$varname$(:,:,{lev_top:lev_bot},{latS:latN},{lonW:lonE}))
    var:=array_append_record(var,var1,0)
    var_366  =short2flt(inlist[0:30:4]->$varname$(:,:,{lev_top:lev_bot},{latS:latN},{lonW:lonE}))
    var_366_2  =inlist[32::4]->$varname$(:,:,{lev_top:lev_bot},{latS:latN},{lonW:lonE})
    var_366:=array_append_record(var_366,var_366_2,0)
    var_dim = dimsizes(var_366)
    var_dim365 = dimsizes(var)
    len_yr= var_dim(0)+var_dim365(0)
    var_data = new((/len_yr, var_dim(1), var_dim(2), var_dim(3), var_dim(4)/),"float")
    copy_VarMeta(var_366,var_data)
    
    ; Merge normal and leap years 
    sp = 0
    do ii=0,len_yr-1
        if (mod(ii,4) .eq. 0) then
            var_data(ii,:,:,:,:) = var_366(ii/4,:,:,:,:)
            sp=sp+1
        else
            var_data(ii,0:364,:,:,:) = var(ii-sp,:,:,:,:)
        end if
    end do
    return(var_data)
end
; ------------------------------    read_NCEP_NCAR_daily_3D   ---------------------------------------



; ------------------------------    read_NCEP_NCAR_daily_3D_UV   ---------------------------------------
; *****************************************************************
; L_Zealot
; Read NCEP-NCAR daily 3D data, in YDLLL format, bottom and top
; level should be assigned.
; Must start from 1948
;
function read_ncep_ncar_daily_3D_uv(varname:string, lev_top, lev_bot, latS, latN, lonW, lonE, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_366, var_dim, var_dim365, var_data
begin
    in_files = filedir+varname+"."+ispan(1948,1978,1)+".nc"
    setfileoption("nc","SuppressClose",False) ; close too many files
    inlist     = addfiles (in_files, "r")   ; note the "s" of addfile
    ListSetType (inlist, "join")
    var  =short2flt(inlist[:]->$varname$(:,:,{lev_top:lev_bot},{latS:latN},{lonW:lonE}))
    var_366  =short2flt(inlist[0::4]->$varname$(:,:,{lev_top:lev_bot},{latS:latN},{lonW:lonE}))

    in_files2 = filedir+varname+"."+ispan(1979,2015,1)+".nc"
    inlist2     = addfiles (in_files2, "r")   ; note the "s" of addfile
    ListSetType (inlist2, "join")
    var_2  =short2flt(inlist2[:]->$varname$(:,:,{lev_top:lev_bot},{latS:latN},{lonW:lonE}))
    var_366_2  =short2flt(inlist2[1::4]->$varname$(:,:,{lev_top:lev_bot},{latS:latN},{lonW:lonE}))



    var_dim = dimsizes(var_366)
    var_dim365 = dimsizes(var)
    var_dim2 = dimsizes(var_366_2)
    var_dim365_2 = dimsizes(var_2)
    len_yr= var_dim(0)+var_dim365(0)
    len_yr2=var_dim2(0)+var_dim365_2(0)
    var_data = new((/len_yr+len_yr2, var_dim(1), var_dim(2), var_dim(3), var_dim(4)/),"float")
    copy_VarMeta(var_366,var_data)
    
    ; Merge normal and leap years 
    sp = 0
    do ii=0,len_yr-1
        if (mod(ii,4) .eq. 0) then
            var_data(ii,:,:,:,:) = var_366(ii/4,:,:,:,:)
            sp=sp+1
        else
            var_data(ii,0:364,:,:,:) = var(ii-sp,:,:,:,:)
        end if
    end do

    sp = 0
    do ii=0,len_yr2-1
        if (mod((ii-1),4) .eq. 1) then
            var_data(ii,:,:,:,:) = var_366_2((ii-1)/4,:,:,:,:)
            sp=sp+1
        else
            var_data(ii,0:364,:,:,:) = var_2(ii-sp,:,:,:,:)
        end if
    end do
    return(var_data)
end
; ------------------------------    read_NCEP_NCAR_daily_uv   ---------------------------------------



; ------------------------------    write_TLLL_to_nc   ---------------------------------------
; *****************************************************************
; L_Zealot
; Write TLLL-formated var list to the prescribed nc file
; Var coordiantes will be treated automatically.
;
procedure write_TLLL_to_nc(varname, var, filedir)
local dims, ntime, p_lvl, nlat, nlon, fout, fileAtt, ii
begin
   
;Set fileoption    
    system("rm "+filedir)
    fout = addfile(filedir,"c")  ; open output netCDF file
    setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =getvardims(var)
    dimSizes    =dimsizes(var)
    dimUnlim    =(/True,False,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    do ii=0,3
        filevardef(fout,dimNames(ii),typeof(var&$dimNames(ii)$),getvardims(var&$dimNames(ii)$))
    end do    
    filevardef(fout,varname,typeof(var),getvardims(var))

;Define Attribute
    do ii=0,3
        filevarattdef(fout,dimNames(ii),var&$dimNames(ii)$)
    end do    
    filevarattdef(fout,varname,var)
;Output var values
    do ii=0,3    
        fout->$dimNames(ii)$=(/var&$dimNames(ii)$/)
    end do    
    fout->$varname$=(/var/)
end
; ------------------------------    write_TLLL_to_nc   ---------------------------------------



; ------------------------------    read_doe_daily_2D   ------------------------------------
; *****************************************************************
; L_Zealot
; Read NCEP-DOE daily 2D data, in YDLL format
; Must start from 1979
;

undef ("read_doe_daily_2D")
function read_doe_daily_2D(varname:string, idx_s, idx_e, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_366, var_dim, var_dim365, var_data
begin
    in_files = systemfunc("ls "+filedir)
    
    setfileoption("nc","SuppressClose",False) ; close too many files
    ctrl_in      = addfiles(in_files, "r")   ; note the "s" of addfile            
    n_esm=ListCount(ctrl_in)
    ListSetType (ctrl_in, "join")             ; concatenate or "merge" (default)
    print("3D EXTRACT: "+varname+" Reading...")
    print("  ESM 1/"+n_esm+" Reading...")
    var1 = short2flt(ctrl_in[0]->$varname$(idx_s:idx_e,:,:))
    ;Build ctrl_var1
    dim_var1=dimsizes(var1)
    ctrl_var1:=conform_dims((/n_esm,dim_var1(0),dim_var1(1),dim_var1(2)/),var1,(/1,2,3/))
    ctrl_var1!0="esm"
    ctrl_var1&esm=ispan(1,n_esm,1)
    ctrl_var1&esm@units="ensemble member"
    ctrl_var1!1="day"
    ctrl_var1&day=ispan(idx_s+1,idx_e+1,1)
    ctrl_var1&day@long_name="Julian Day of the year"
    ctrl_var1!2=var1!1
    ctrl_var1&lat=var1&lat
    ctrl_var1!3=var1!2
    ctrl_var1&lon=var1&lon
    copy_VarAtts(var1,ctrl_var1) 
    ctrl_var1(0,:,:,:)=(/var1/)
    do ii=1,n_esm-1
        print("  ESM "+(ii+1)+"/"+n_esm+" Reading...")
        var1 := short2flt(ctrl_in[ii]->$varname$)
        var1 := var1(idx_s:idx_e,:,:)
        ctrl_var1(ii,:,:,:)=(/var1(idx_s:idx_e,:,:)/)
    end do
    return(ctrl_var1)
end
; ------------------------------    read_doe_daily_2D   ------------------------------------



; ------------------------------    write_TLL_to_nc   ---------------------------------------
; *****************************************************************
; L_Zealot
; Write TLLL-formated var list to the prescribed nc file
; Var coordiantes will be treated automatically.
;
procedure write_TLL_to_nc(varname, var, filedir)
local dims, ntime, nlat, nlon, fout, fileAtt, ii
begin
   
;Set fileoption    
    system("rm "+filedir)
    fout = addfile(filedir,"c")  ; open output netCDF file
    setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =getvardims(var)
    dimSizes    =dimsizes(var)
    dimUnlim    =(/True,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    do ii=0,2
        filevardef(fout,dimNames(ii),typeof(var&$dimNames(ii)$),getvardims(var&$dimNames(ii)$))
    end do    
    filevardef(fout,varname,typeof(var),getvardims(var))

;Define Attribute
    do ii=0,2
        filevarattdef(fout,dimNames(ii),var&$dimNames(ii)$)
    end do    
    filevarattdef(fout,varname,var)
;Output var values
    do ii=0,2    
        fout->$dimNames(ii)$=(/var&$dimNames(ii)$/)
    end do    
    fout->$varname$=(/var/)
end
; ------------------------------    write_TLL_to_nc   ---------------------------------------


; ------------------------------    write_YDLLL_to_nc   ---------------------------------------
; *****************************************************************
; L_Zealot
; Write YDLLL-formated var list to the prescribed nc file
; Var coordiantes will be treated automatically.
;
procedure write_YDLLL_to_nc(varname, var, filedir)
local dims, ntime, p_lvl, nlat, nlon, fout, fileAtt, ii
begin
   
;Set fileoption    
    system("rm "+filedir)
    fout = addfile(filedir,"c")  ; open output netCDF file
    setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =getvardims(var)
    dimSizes    =dimsizes(var)
    dimUnlim    =(/True,False,False,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    do ii=0,4
        filevardef(fout,dimNames(ii),typeof(var&$dimNames(ii)$),getvardims(var&$dimNames(ii)$))
    end do    
    filevardef(fout,varname,typeof(var),getvardims(var))

;Define Attribute
    do ii=0,4
        filevarattdef(fout,dimNames(ii),var&$dimNames(ii)$)
    end do    
    filevarattdef(fout,varname,var)
;Output var values
    do ii=0,4    
        fout->$dimNames(ii)$=(/var&$dimNames(ii)$/)
    end do    
    fout->$varname$=(/var/)
end
; ------------------------------    write_YDLLL_to_nc   ---------------------------------------



; ------------------------------    write_YDLL_to_nc   ---------------------------------------
; *****************************************************************
; L_Zealot
; Write YDLL-formated var list to the prescribed nc file
; Var coordiantes will be treated automatically.
;
procedure write_YDLL_to_nc(varname, var, filedir)
local dims, fout, fileAtt, ii
begin
   
;Set fileoption    
    system("rm "+filedir)
    fout = addfile(filedir,"c")  ; open output netCDF file
    setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =getvardims(var)
    dimSizes    =dimsizes(var)
    dimUnlim    =(/True,False,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)

;Define var, type and dim
    do ii=0,3
        filevardef(fout,dimNames(ii),typeof(var&$dimNames(ii)$),getvardims(var&$dimNames(ii)$))
    end do    
    filevardef(fout,varname,typeof(var),getvardims(var))

;Define Attribute
    do ii=0,3
        filevarattdef(fout,dimNames(ii),var&$dimNames(ii)$)
    end do    
    filevarattdef(fout,varname,var)
;Output var values
    do ii=0,3    
        fout->$dimNames(ii)$=(/var&$dimNames(ii)$/)
    end do    
    fout->$varname$=(/var/)
end
; ------------------------------    write_YDLL_to_nc   ---------------------------------------

; ------------------------------    read_large_daily_batch_return_batch   ---------------------------------------
; *****************************************************************
; L_Zealot
; Read Large Daily batch files, and return batch
;
function read_large_daily_batch_return_batch(varname:string, filedir:string, strt_year, end_year, lev_top, lev_bot, latS, latN, lonW, lonE)
local nsmp,var_batch, ii, len_yr, in_files, inlist, var, loop_year
begin
    nsmp=end_year-strt_year+1
    loop_year=strt_year
    print("FILE IO: prepare...")
    in_file_str = systemfunc("ls "+filedir+"/*"+strt_year+"*")
    infile     = addfile (in_file_str, "r")   ; note the "s" of addfile
    print("FILE IO: initial read...")
    if (getfilevartypes (infile,varname).eq."short") then
        var  = short2flt(infile->$varname$)
    else
        var  = infile->$varname$
    end if
    dimvar=dimsizes(var)
    dims=dimsizes(dimvar)
    if (dimvar(0) .eq. 366) then
        print("leap year")
        leap_flag=True
    else
        print("normal year")
        leap_flag=False
        ;extend the array
        if (dims .eq. 3) then ; TLL
            var := array_append_record (var, var(0:0,:,:), 0)
            var:=var(:,{latS:latN},{lonW:lonE})
            var(365,:,:)=0
        else ; TLLL
            var:= array_append_record (var, var(0:0,:,:,:), 0)
            var:=var(:,{lev_top:lev_bot},{latS:latN},{lonW:lonE})
            ; clean the last record
            var(365,:,:,:)=0
        end if
    end if
    dimvar:=dimsizes(var)
    print("PROCESS: make batch var...")
    ;Build ctrl_var1
    if (dims .eq. 3) then ; TLL
        var_batch=conform_dims((/nsmp, dimvar(0), dimvar(1), dimvar(2)/), var, (/1,2,3/))
    else    ; TLLL
        var_batch=conform_dims((/nsmp, dimvar(0), dimvar(1), dimvar(2), dimvar(3)/), var, (/1,2,3,4/))
        var_batch!4=var!3
    end if

    var_batch!0="year"
    var_batch&year=ispan(strt_year,end_year,1)
    var_batch&year@units="year"
    var_batch!1="day"
    var_batch&day=ispan(1,366,1)
    var_batch&day@long_name="Julian Day of the year"
    var_batch!2=var!1
    var_batch!3=var!2
    if (dims .eq. 4) then
        var_batch&level=var&level
    end if
    var_batch&lat=var&lat
    var_batch&lon=var&lon
    copy_VarAtts(var,var_batch) 
    printVarSummary(var_batch)    
    print("FILE IO: batch read...")
    do ii=1, nsmp-1
        loop_year=loop_year+1

        in_file_str := systemfunc("ls "+filedir+"/*"+loop_year+"*")
        print("FILE IO: read "+in_file_str)
        infile     := addfile (in_file_str, "r")   ; note the "s" of addfile
        if (getfilevartypes (infile,varname).eq."short") then
            if (dims .eq. 3) then ; TLL
                var  := short2flt(infile->$varname$(:,{latS:latN},{lonW:lonE}))
            else
                var  := short2flt(infile->$varname$(:,{lev_top:lev_bot},{latS:latN},{lonW:lonE}))
            end if
        else
            if (dims .eq. 3) then ; TLL
                var  := infile->$varname$(:,{latS:latN},{lonW:lonE})
            else
                var  := infile->$varname$(:,{lev_top:lev_bot},{latS:latN},{lonW:lonE})
            end if
        end if
 

        printVarSummary(var)
        dimvar=dimsizes(var)
        vardim0=dimvar(0)
        if (vardim0 .lt. 366) then
            print("normal year")
            if (dims .eq. 3) then ; TLL
                var_batch(ii,0:364,:,:)=(/var/)
            else
                var_batch(ii,0:364,:,:,:)=(/var/)
            end if
        else
            print("leap year")
            if (dims .eq. 3) then ; TLLL
                var_batch(ii,:,:,:)=(/var/)
            else
                var_batch(ii,:,:,:,:)=(/var/)
            end if

        end if
    end do

    return(var_batch)
end
; ------------------------------    read_large_daily_batch_return_mean   ---------------------------------------




; ------------------------------    read_large_daily_batch_return_mean   ---------------------------------------
; *****************************************************************
; L_Zealot
; Read Large Daily batch files, and return mean
;
function read_large_daily_batch_return_mean(varname:string, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_366, var_dim, var_dim365, var_data
begin
    print("FILE IO: prepare...")
    in_files = systemfunc("ls "+filedir+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    inlist     = addfiles (in_files, "r")   ; note the "s" of addfile
    n_smp=dimsizes(in_files)
    ListSetType (inlist, "join")

    print("FILE IO: initial read...")
    var  = short2flt(inlist[0]->$varname$)
    dimvar=dimsizes(var)
    leap_flag=False

    n_norm=0
    n_leap=0
    
    print("FILE IO: batch read...")
    do ii=1, n_smp-1
        print("FILE IO: read "+in_files(ii))
        var  := short2flt(inlist[ii]->$varname$)
        dimvar=dimsizes(var)
        vardim0=dimvar(0)
        if (vardim0 .lt. 366) then
            print("normal year")
            if (n_norm .eq. 0) then
                var_mean0=var
            else
                var_mean0=var_mean0+var
            end if
            n_norm=n_norm+1
        else
            print("leap year")
            if (n_leap .eq. 0) then
                var_mean1=var
            else
                var_mean1=var_mean1+var
            end if
            n_leap=n_leap+1
        end if
    end do

    print("FILE IO: calculate mean...")
    if (n_leap .gt. 0) then
        var_mean=var_mean1
        if (dimsizes(dimvar) .eq. 3) then
            var_mean(0:364,:,:)=(var_mean1(0:364,:,:)+var_mean0)/(n_leap+n_norm)
            var_mean(365,:,:)=var_mean1(365,:,:)/n_leap
        else
            var_mean(0:364,:,:,:)=(var_mean1(0:364,:,:,:)+var_mean0)/(n_leap+n_norm)
            var_mean(365,:,:,:)=var_mean1(365,:,:,:)/n_leap
        end if
    else
        var_mean=var_mean0
        var_mean=var_mean0/n_norm
    end if
    return(var_mean)
end
; ------------------------------    read_large_daily_batch_return_mean   ---------------------------------------



