; 
;      File IO NCL, for different kinds of data sets, must use
;  absolute directory!
;                                           A L_Zealot Product
;                                               Feb 20 2017
; Format Instructions:
;       YDLLL   -- Year Day Lev Lat Lon format (3D Field)
;       YDLL    -- year Day Lat Lon format (2D Field)
;
; -------------- added Feb 20 2017
; read_doe_daily_2Din3D(varname, level, filedir)

; -------------- added Feb 21 2017
; read_era_daily_3D(varname, lev_top, lev_bot, latS, latN, lonW, lonE, filedir)

; -------------- added Feb 22 2017
; read_oisst_daily(latS, latN, lonW, lonE, filedir)

; -------------- added Feb 22 2017
; read_era_daily_2Din3D(varname, lev, latS, latN, lonW, lonE, filedir)

; -------------- added Apr 05 2017
; read_noaa_olr_daily_2D(strtday, endday, latS, latN, lonW, lonE, filedir)


; ------------------------------    read_doe_daily_2Din3D   ------------------------------------
; *****************************************************************
; L_Zealot
; Read NCEP-DOE daily 2D data, in YDLL format
; Must start from 1979
;

undef ("read_doe_daily_2Din3D")
function read_doe_daily_2Din3D(varname:string, level, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_366, var_dim, var_dim365, var_data
begin
    in_files = systemfunc("ls "+filedir)
    setfileoption("nc","SuppressClose",False) ; close too many files
    inlist     = addfiles (in_files, "r")   ; note the "s" of addfile
    ListSetType (inlist, "join")
    var  =short2flt(inlist[:]->$varname$(:,:,{level},:,:))
    var_366  =short2flt(inlist[1::4]->$varname$(:,:,{level},:,:))
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
; ------------------------------    read_doe_daily_2Din3D   ------------------------------------




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
    var  =inlist[:]->$varname$(:,:,{lev},{latS:latN},{lonW:lonE})
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
