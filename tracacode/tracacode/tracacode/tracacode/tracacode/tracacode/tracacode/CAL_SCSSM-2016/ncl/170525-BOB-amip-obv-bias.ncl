;*************************************************************
;Aim: Cal MAM detrended T2m standard deviation
;
;Mission:
;   1. Read data from NCEP-DOE data
;   2. Post-post process
;   3. Output to yearly files
;                       Zhenning Li
;                       2015-05-05
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN 
;   2015-04-18  Change to caculate Q1
;   2015-04-18  Change to caculate daily Q1 in NCEP-DOE
;   2015-12-01  Change to fit T2M
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCL_SELFLIB/file_io.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin

;======================================================
;Variables List:
;======================================================

;global variables
    ;Define parameters

    ;for directory 
    g_var_name = "FLUT"
    g_data3_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/ctrl"
    g_data3_nudg_path ="/Users/zhenningli/data/CAL_SCSSM-2016/ensemble/amip"
    g_day_rank=(/125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119,123/)-1
    
    g_font = 0.025
    
    ;Andaman Sea convection
    g_latS=5.
    g_latN=20.
    g_lonW=87.5
    g_lonE=100.

    ; create an array of desired pressure levels:
    g_fig_name = "../fig/obv/amip-obv-timeseries-onset"
    g_fig_title= "Onset Days in Obv and AMIP"    
    npos_year = 0
    nneg_year = 0

;Prepare the variables
     
    nudg_in_files = systemfunc("ls "+g_data3_nudg_path+"/*"+g_var_name+"*")
    setfileoption("nc","SuppressClose",False) ; close too many files
    nudg_in     = addfiles (nudg_in_files, "r")   ; note the "s" of addfile
    ListSetType (nudg_in, "join")
    var_nudg  =nudg_in[:]->$g_var_name$(:,0:181,:,:)
    var_nudg_areamean=wgt_areaave_Wrap(var_nudg(:,1:,{g_latS:g_latN},{g_lonW:g_lonE}),1.0,1.0,0)
    var_nudg_mean=dim_avg_n_Wrap(var_nudg_areamean,0)  
    var_nudg_onset=var_nudg_areamean
    day_strt=80
    var_nudg_onset_M2J=var_nudg_onset(:,day_strt:)
    var_nudg_onset_M2J=where(var_nudg_onset_M2J .lt. 236, 1, 0)
    var_nudg_onset_M2J=dim_acumrun_n(var_nudg_onset_M2J,6,1,1)
   
    dim_nudg=dimsizes(var_nudg_onset)
    onset_nudg=var_nudg_onset(:,0)

    do jj=0, dim_nudg(0)-1
        idate= get1Dindex(var_nudg_onset_M2J(jj,:), 6)
        onset_nudg(jj)=(day_strt+idate-5+1)
    end do

    onset_all=new((/2,27/),"float")
    onset_all(0,:)=g_day_rank(0:26)
    onset_all(1,:)=onset_nudg

    ;********************************************************
	; create the plot
	;********************************************************   
                                   ; these for you
    wks1   = gsn_open_wks ("png",g_fig_name)                 ; open workstation

    res               = True                    ; plot mods desired

    res@gsnDraw            = False                   ; don't draw   
    res@gsnFrame           = False                   ; don't advance frame
             
    res@vpXF     = 0.15

    res@vpWidthF = 0.7
    res@vpHeightF= 0.4


    res@trYMinF            = 80                 ; Y axis limits
    res@trYMaxF            = 165

    res@trXMinF  = 1979                   ; min value on x-axis
    res@trXMaxF  = 2005                 ; max value on x-axis
    res@tmXBMode      = "Explicit" ; Define own tick mark labels.

    
    res@tmXBValues = ispan(1979,2005,5)
    res@tmXBLabels = ispan(1979,2005,5)
    res@xyMonoLineColor    = False             ; want colored lines
    res@xyLineColors       = (/"red","blue","green4","black"/) ; colors chosen
    res@xyLineThicknesses    = (/4.,4.,4.,6/)      ; line thicknesses
    res@xyDashPatterns   = (/0.,0.,0.,0./)      ; make all lines solid
    res@tmXBMajorThicknessF = 5.0
    res@tmYLMajorThicknessF = 5.0
    res@tmXBMinorThicknessF = 4.0
    res@tmYLMinorThicknessF = 4.0
    res@tmBorderThicknessF = 4.0
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    res@gsnStringFontHeightF = g_font
    res@gsnCenterString = g_fig_title
    res@tiYAxisString="Onset Day"
    r=escorc(onset_all(0,:),onset_all(1,:))
    res@gsnRightString="R="+sprintf("%4.2f",r)
    top_plot  = gsn_csm_xy (wks1,ispan(1979,2005,1),onset_all,res)   ; create plot



        n    = dimsizes(onset_all(0,:))                ; n=11
        df   = n-2
                                          ; Fischer z-transformation
        z    = 0.5*log((1+r)/(1-r))  ; z-statistic
        se   = 1.0/sqrt(n-3)                       ; standard error of z-statistic

                                          ; low  and hi z values
        zlow = z - 1.96*se                ; 95%  (2.58 for 99%)
        zhi  = z + 1.96*se                 
                                          ; inverse z-transform; return to r space (-1 to +1)
        rlow = (exp(2*zlow)-1)/(exp(2*zlow)+1)
        rhi  = (exp(2*zhi )-1)/(exp(2*zhi )+1)

        print("r="+r)                     ;  r=0.559956                
        print("z="+z+"  se="+se)          ;  z=0.63277  se=0.353553 
        print("zlow="+zlow+"  zhi="+zhi)  ;  zlow=-0.0601951  zhi=1.32573
        print("rlow="+rlow+"  rhi="+rhi)  ;  rlow=-0.0601225  rhi=0.868203


   
   
   ;*****************************************************   
	; Manually create and attach legend
	;***************************************************** 
	res_text                    = True                  ; text mods desired
	res_text@txFontHeightF      = 0.02                 ; change text size
	res_text@txJust             = "CenterLeft"          ; text justification

	res_lines                   = True                  ; polyline mods desired
	res_lines@gsLineDashPattern = 0.                    ; solid line
	res_lines@gsLineThicknessF  = 4.                    ; line thicker
	res_lines@gsLineColor       = "red"                 ; line color
	
    xx = (/1985,1988/) 
	yy = (/160,160/)
	dum1 = gsn_add_polyline(wks1,top_plot,xx,yy,res_lines)              ; add polyline
	dum2 = gsn_add_text(wks1,top_plot,"Observation",xx(1)+1,yy(0),res_text); add text



	res_lines@gsLineColor       = "blue"                                 ; change to blue
	yy = yy -10
    dum3 = gsn_add_polyline(wks1,top_plot,xx,yy,res_lines)                ; add polyline
	dum4 = gsn_add_text(wks1,top_plot,"AMIP",xx(1)+1,yy(0),res_text)       ; add text
   
    draw(top_plot)
    frame(wks1)


end
