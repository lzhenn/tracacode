; 
;      File IO NCL, for different kinds of data sets
;
;
; -------------- added Feb 20 2017
; read_doe_daily_2Din3D

; -------------- added Feb 20 2017
; read_ERA_daily_3D


; *****************************************************************
; L_Zealot
; Read NCEP-DOE daily 2D data, in YTLL format
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

; *****************************************************************
; L_Zealot
; Read ERA-Interim daily 3D data, in YTLLL format, bottom and top
; level should be assigned.
; Must start from 1979
;
function read_era_daily_3D(varname:string, lev_bot, lev_top, filedir:string)
local sp, ii, len_yr, in_files, inlist, var, var_366, var_dim, var_dim365, var_data
begin
    in_files = systemfunc("ls "+filedir)
    setfileoption("nc","SuppressClose",False) ; close too many files
    inlist     = addfiles (in_files, "r")   ; note the "s" of addfile
    ListSetType (inlist, "join")
    var  =inlist[:]->$varname$
    var_366  =inlist[1::4]->$varname$
    var_dim = dimsizes(var_366)
    var_dim365 = dimsizes(var)
    len_yr= var_dim(0)+var_dim365(0)
    var_data = new((/len_yr, var_dim(1), var_dim(2), var_dim(3), var_dim(4)/),"float")
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

