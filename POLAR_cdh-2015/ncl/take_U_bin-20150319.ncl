;***************************************************************
;Aim: read Z3 from monthly data output of CESM, output 
; into a binary file for Fortran or GrADS use
;Mission:
;   1. Read read PRECC+PRECL data
;   2. Post-post process
;   3. Output Pr field
;                       Zhenning Li
;                       2015-03-19
;Last Edited:
;   2015-03-19  Create
;****************************************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
   g_pver = 26

   g_plev        =   (/200.0/)
;Define parameters
   g_out_fn="../data/SEN_TCP_U_200mb_0001-0070_mon.bin"
   g_in_files="/users/yangsong3/cdh/cam4/TCP/exe/*cam.h0.0*"


; ==============================================================
   ; Open the file: Read only the user specified period
   ; ==============================================================
   all_files = systemfunc ("ls "+g_in_files)
   ;all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-7]*.nc")
   setfileoption("nc","SuppressClose",False) ; close too many files

   ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile

   ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

   ;------------------Below to change the variable---------------------    
   ctrl_var  = ctrl_in[:]->U
    
    print("Read specific variable done")
    printVarSummary(ctrl_var)
	hbcofa	    =   ctrl_in[:]->hyam(0:g_pver-1)
	hbcofb	    =   ctrl_in[:]->hybm(0:g_pver-1)
	ctrl_psfc   =   ctrl_in[:]->PS
	p0	        =   1000

    print("Read convert variable done")
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
	ctrl_varp = vinth2p(ctrl_var,hbcofa,hbcofb,g_plev,ctrl_psfc,interp,p0,1,extrap)
    ;ctrl_varp_conv = ctrl_varp(lev_p|:,time|:,lat|:,lon|:)

    print("Convert variable done")
    printVarSummary(ctrl_varp)
; Write Binary File
   system("rm -f "+g_out_fn)
   setfileoption("bin","WriteByteOrder","LittleEndian")
;  fbinrecwrite(filename,-1,diff_avg&lat)
;  fbinrecwrite(filename,-1,diff_avg&lon)
   fbinrecwrite(g_out_fn,-1,ctrl_varp)

end








