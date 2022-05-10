load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"    
;************************************************************
begin
                            ; time window : include enough buffer
  casename="F_AMIP"
  twStrt  = 19950101        ; 4 years: winter 96-97 MJO gold standard
  twLast  = 19981231

  thStrt  = 19960101        ; Hov start time
  thLast  = 19971231        ; Hov last  time

  spd     = 1               ; sample per day
  bpf     = (/20,100,201/)

  diri    = "../data/model/pro/"+casename+"/"
 ;vName   = "olr"            ; name of variable on the file
 ;fili    = "olr.day.mean.nc"
 ;vName   = "U_anom"      ; name of variable on the file
 ;fili    = "uwnd.day.850.anomalies.1980-2005.nc"
    vName  = "FLUT"        ; name of variable on precipitation file
    dirp   = "../data/model/pro/"+casename+"/"
    all_files = systemfunc("ls "+dirp+"*199[5-8]*FLUT*") 
    setfileoption("nc","SuppressClose",False) ; close too many files
    f      = addfiles(all_files, "r")  
    ListSetType(f,"cat")

  latS    =  -5.            ; arbitrary
  latN    =   5.
  lonL    =  60.
  lonR    = 280.

  pltDir  = "../fig/"                     ; plot directory
  pltType = "eps"                    ; x11, ps, eps, pdf, png
  pltName = "mjo-hov-filtered-"+casename                   ; plot file name

;************************************************************
; time indices corresponding to the desired time window
;************************************************************

  date  = cd_calendar(f[:]->time, -2)   ; entire file
  iStrt = ind(date.eq.twStrt)        ; desired dates
  iLast = ind(date.eq.twLast)
  delete(date)

;************************************************************
; Read user specified period
;************************************************************

      X = f[:]->$vName$(iStrt:iLast,:,:) 
 ;printVarSummary( X )
 ;printMinMax(X, True)

  x       = X(:,{latS:latN},{lonL:lonR})  
 ;printVarSummary( x )
 ;printMinMax(x, True)

  wgty    = latRegWgt(x&lat, "double", 0)

  optHov  = False
  hov     = band_pass_hovmueller (x, spd, bpf, wgty, optHov) 
  printVarSummary(hov)               ; (time,lon)
  printMinMax(hov, True)

;************************************************
; Create generic Hovmueller plot using the
; output from band_pass_hovmueller.
; This is for the specific time period of interest 
;************************************************
  date  = cd_calendar(x&time , -2 )  ; yyyymmdd

  hStrt = ind(date.eq.thStrt)        ; desired Hov plot dates
  hLast = ind(date.eq.thLast)
            
  optHovP = False
  band_pass_hovmueller_plot(hov(hStrt:hLast,:) \
                           ,pltDir, pltType, pltName, optHovP)  

 ;optHovP     = True                     ; test option
 ;optHovP@yearFraction         = True
 ;optHovP@yearFractionSpacingF = 0.25    ; default = 0.25
 ;band_pass_hovmueller_plot(hov(hStrt:hLast,:) \
 ;                         ,pltDir, pltType, pltName, optHovP)  
end
