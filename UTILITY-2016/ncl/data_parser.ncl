; 
;      Data Parser NCL, for post-process the read-in data
;
;                                           A L_Zealot Product
;                                               Aug 30 2017
;

;**************************PROCESS******************************
; -------------- added Aug 30 2017
; daily_to_pentad_YDLL(var)

;**************************PROCESS******************************


; ------------------------------   daily_to_pentad_DLL_366    ------------------------------------
; *****************************************************************
; L_Zealot
; Convert daily data to pentad data, in YDLL format
; *** Merge every 5 days, except for day 361-366 (6 days)

undef ("daily_to_pentad_DLL")
function daily_to_pentad_DLL(var)
local var, var_pt, day_len, pentad_len
begin
   ; Merge normal and leap years 
    day_len = dimsizes(var)
    day_len := day_len(0)
    pentad_len:= day_len/5
    var_pt = var(0:pentad_len-1,:,:)
    do ii=0,pentad_len-1
        var_pt(ii,:,:)=dim_avg_n_Wrap(var(ii*5:ii*5+4,:,:),0)
    end do
    if (day_len .gt. 365) then
        var_pt(72,:,:)=dim_avg_n_Wrap(var(360:365,:,:),0)
    end if
    return(var_pt)
end
; ------------------------------    read_doe_daily_2Din3D   ------------------------------------


