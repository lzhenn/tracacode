;*************************************************************
;Aim: draw OLR annually ltm trend 
;Mission:
;   1. Read data
;   2. Post-post process
;     2.1 take the trend 
;   4. Draw and overlap
;                       Zhenning Li
;                       2015-05-03
;Last Edited:
;   2015-03-01  Create
;   2015-03-03  Change to fit HEAT Experiment
;   2015-04-05  Change to fit Team Server
;   2015-04-08  Change to fit ECMWF MONLTM MEAN
;   2015-05-03  Change to caculate season trend 
;   2015-07-09  Change to caculate OLR
;   2015-07-09  Change to fit composite
;*************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin


;================================================
;Variables List:
;	var1--------------U
;	var2--------------V
;================================================
;global variables
    ;Define parameters
    g_data_path1 = "/Users/zhenningli/data/obv/NCEP-DOE/monthly/uwnd.10m.mon.mean.nc"
    g_data_path2 = "/Users/zhenningli/data/obv/NCEP-DOE/monthly/vwnd.10m.mon.mean.nc"
    g_latS=-45.
    g_latN=45.
    g_lonW=30.
    g_lonE=220.
    
    ;Smaller Region
    g_latS=-45.
    g_latN=45.
    g_lonW=100.
    g_lonE=270.
    
    ; create an array of desired pressure levels:

        
    g_font = 0.03

    g_strt_mon = 197901 
    g_lst_mon = 201512
    ; long events larger than 10 months, develop
    g_sp_events = (/198201,198601,199101,199701/)
    ; short events with 10 months, develop
    g_su_events = (/197901,199401,200201,200401,200601,200901/)

    ; long events larger than 10 months, decay
    ;g_sp_events = (/198301,198701,199201,199801/)
    ; short events with 10 months, decay
    ;g_su_events = (/198001,199501,200301,200501,200701,201001/)
    n_sp_events= dimsizes(g_sp_events)
    n_su_events= dimsizes(g_su_events)
    g_fig_name    =   "../fig/FIG1b_"+g_strt_mon+"-"+g_lst_mon+"_10mUV_sverdrup_LE-SE-cmp2"
    g_fig_rank    =   (/"(a)","(a)","(c)","(d)","(e)","(f)","(g)","(h)","(i)","(j)","(k)","(l)","(m)","(n)"/)
    
    g_fig_title     = "Sverdrup Transport"

;*************************For F_Compset Ctrl***********************************

; ==============================================================
; Mission 1. Open the file: Read only the user specified period
; ==============================================================

	ctrl_file1   = g_data_path1
	ctrl_in1     = addfile (ctrl_file1, "r")   ; note the "s" of addfile
	time_hist    = ctrl_in1->time
    yyyymm  = cd_calendar(time_hist,-1)
    istrt   = ind(yyyymm .eq. g_strt_mon)
    ilast   = ind(yyyymm .eq. g_lst_mon)
	var1  =short2flt(ctrl_in1->uwnd(istrt:ilast,0,:,:))			; p for unify the var name

    ctrl_file2   = g_data_path2
	ctrl_in2     = addfile (ctrl_file2, "r")   ; note the "s" of addfile
	var2  =short2flt(ctrl_in2->vwnd(istrt:ilast,0,:,:))			; p for unify the var name

; ==============================================================
; Mission 2. post-post process data to deserved results
; ==============================================================

    var1=month_to_season12(var1)
    var2=month_to_season12(var2)

    g_lon=var1&lon
    g_lat=var1&lat

    smp_sp_var1 = var1(0:12*n_sp_events-1,:,:)
    do ii=0,n_sp_events-1
        i_evstrt= ind(yyyymm .eq. g_sp_events(ii)) - istrt
        print(i_evstrt)
        smp_sp_var1(ii*12:ii*12+11,:,:) = var1(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_sp_var1_avg = clmMonTLL(smp_sp_var1)

    smp_su_var1 = var1(0:12*n_su_events-1,:,:)
    do ii=0,n_su_events-1
        i_evstrt= ind(yyyymm .eq. g_su_events(ii)) - istrt
        print(i_evstrt)
        smp_su_var1(ii*12:ii*12+11,:,:) = var1(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_su_var1_avg = clmMonTLL(smp_su_var1)
 
    smp_sp_var2 = var2(0:12*n_sp_events-1,:,:)
    do ii=0,n_sp_events-1
        i_evstrt= ind(yyyymm .eq. g_sp_events(ii)) - istrt
        print(i_evstrt)
        smp_sp_var2(ii*12:ii*12+11,:,:) = var2(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_sp_var2_avg = clmMonTLL(smp_sp_var2)

    smp_su_var2 = var2(0:12*n_su_events-1,:,:)
    do ii=0,n_su_events-1
        i_evstrt= ind(yyyymm .eq. g_su_events(ii)) - istrt
        print(i_evstrt)
        smp_su_var2(ii*12:ii*12+11,:,:) = var2(i_evstrt:i_evstrt+11,:,:)
    end do
    cmp_su_var2_avg = clmMonTLL(smp_su_var2)

    printVarSummary(cmp_sp_var2_avg)

    ; Calculate the Sverdrup Transport
    ; Vs=(1/beta)*curl(tao)
    ;   tao=ruo*Cd*U
    ;   ruo*Cd=2kg/m3
    ;   beta=partial(f)/(a*partial(fai))
    ;   f=2*om*sin(fai)

    Rcd=2 ; 2kg/m3
    a=6378388 ; R of the earth
    om=7.29e-5
    d2r=0.0174533 ; convert to radians

    tao_x_sp=cmp_sp_var1_avg 
    tao_y_sp=cmp_sp_var1_avg 
    
    tao_x_su=cmp_sp_var1_avg 
    tao_y_su=cmp_sp_var1_avg 

    tao_x_sp=Rcd*abs(cmp_sp_var1_avg)*cmp_sp_var1_avg
    tao_y_sp=Rcd*abs(cmp_sp_var2_avg)*cmp_sp_var2_avg

    tao_x_su=Rcd*cmp_su_var1_avg
    tao_y_su=Rcd*cmp_su_var2_avg
    
    curl_sp=uv2vrF_Wrap(tao_x_sp,tao_y_sp)
    curl_su=uv2vrF_Wrap(tao_x_su,tao_y_su)


    ;***********TERM [2], this is a little tricky*******

    f = curl_sp(0,:,:) 
    dfdy = f

    dlat = (g_lat(2)-g_lat(1))*d2r ; convert to radians
    dy = a*dlat 
    do i=0,dimsizes(g_lat)-1                      ; loop over each latitude
        f(i,:) = 2*om*sin(d2r*g_lat(i))
    end do
    
    dfdy = center_finite_diff_n (f, dy , False, 0, 0) ; be careful with the dimison downscale
    
    sv_sp = curl_sp
    sv_su = curl_su
      
    sv_sp = sv_sp/conform(sv_sp,dfdy,(/1,2/))
    sv_su = sv_su/conform(sv_sp,dfdy,(/1,2/))

    ;--------------------------------
    ;--------Sig Test----------------
    ;--------------------------------


  wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
;  wks = gsn_open_wks("pdf","up_T_surface_cte_mean_250-400hPa")  ; open a ps file
;  wks = gsn_open_wks("x11","diabatic_heat_250-500hPa")  ; open a ps file

  plot = new((/6/),graphic)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; choose a colormap 
;   gsn_define_colormap(wks,"Rainbow") ; choose a colormap
;   gsn_define_colormap(wks,"BlGrYeOrReVi200") ; choose a colormap
;  gsn_define_colormap(wks,"precip4_diff_19lev")
;  gsn_define_colormap(wks,"precip_diff_12lev")
; gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
; gsn_define_colormap(wks,"MPL_bwr")
;-----------------------------------------------------------------------------
  res                  = True       ; use plot options

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels



;  i = NhlNewColor(wks,0.341,0.,0.533)              ; add gray to colormap
;  j = NhlNewColor(wks,1,0.,0.)
;  res@mpLandFillColor       = "gray"            ; set land to be gray

;  res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;  res@cnLevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
;   res@cnLevels = ispan(0,60,10)
;  res@cnFillColors =(/-1,20,47,57,94,127,152/)
;    res@cnLevelSelectionMode = "ExplicitLevels"   ; set manual contour levels
;    res@cnLevels =    (/-0.8,-0.4,-0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0/)
;    res@cnFillColors =(/   2,  18,  34,  52,  61,  68,  77,  82,  87,  91,  95,  99, 100, 102/)
    res@cnLevelSelectionMode  = "ManualLevels" ; set manual contour levels
    res@cnMinLevelValF        =  -1e6          ; set min contour level
    res@cnMaxLevelValF        =  1e6          ; set max contour level
    res@cnLevelSpacingF       =  1e5          ; set contour interval
;  res@cnFillColors =(/2,4,7,8,8,9,11,13/)


  res@gsnFrame         = False
  res@gsnDraw  = False
  
  res@gsnSpreadColors      = True               ; use full color map
  ;res@gsnSpreadColorStart  = 2               ; start at color 17
  ;res@gsnSpreadColorEnd    = 14                ; end at color 200

;  res@gsnPanelLabelBar    = True   ;Turn on panel labelbar
  res@gsnStringFontHeightF = g_font

  res@gsnMaximize      = True       ; fill up the page
  res@gsnAddCyclic   = True;False
  res@gsnPaperOrientation = "portrait"
  res@gsnContourZeroLineThicknessF = 2.  ;set thickness of zero


  res@lbLabelBarOn = True   ; turn off the label bar
  res@lbOrientation          = "vertical"
  res@lbLabelFontHeightF  = g_font              ; make labels smaller
  ;res@lbLabelStride = 1

  res@mpFillOn   = True     ; turn off gray continents
  res@mpGeophysicalLineThicknessF = 2
  res@mpGeophysicalLineColor      = "black";"white" 
  res@mpFillDrawOrder="PostDraw"
  res@mpCenterLonF = 180.
  res@mpMaxLatF  = g_latN
  res@mpMinLatF  = g_latS
  res@mpMaxLonF  = g_lonE
  res@mpMinLonF  = g_lonW

;  res@mpShapeMode = "FreeAspect" 

;  res@vpWidthF = 0.8
;  res@vpHeightF = 0.6

;  res@tmXBMajorOutwardLengthF = -0.
;  res@tmYLMajorOutwardLengthF = -0.
;  res@tmYRMajorOutwardLengthF = -0.
  
;  res@tmXBMinorOutwardLengthF = -0.
;  res@tmYLMinorOutwardLengthF = -0.
;  res@tmYRMinorOutwardLengthF = -0.
    
     ; now change the size of the tickmark labels
  res@tmXBTickSpacingF = 30
  res@tmYLTickSpacingF = 15
  res@tmXBLabelFontHeightF = g_font
; res@tmXBLabelFontAspectF = 1.6
  res@tmXBLabelFontThicknessF = 2.0
  res@tmYLLabelFontHeightF = g_font
; res@tmYLLabelFontAspectF = 1.3
  res@tmYLLabelFontThicknessF = 2.0
; res@tmYLLabelFontQuality =

    res@gsnCenterString = g_fig_title
    res@gsnRightString = ""

    plot(0) = gsn_csm_contour_map_ce(wks,sv_sp(1,:,:),res)
    res@gsnLeftString = g_fig_rank(1)
    plot(1) = gsn_csm_contour_map_ce(wks,sv_su(1,:,:),res)

    gsn_panel(wks,plot(0:1),(/2,1/),False)
end 
