;;*************************************************************
;aim: draw sen - con (a2) pr and 850uv, do the significant test
;     (bio_a1, nio_a2, sio_a2, nio_a2+sio_a2)
;mission:
;   1. read data from experiments data
;   2. post-post process
;     2.1 climatology 
;     2.2 difference
;     2.3 sig test
;   3. draw the response map
;                       zhenning li
;                       2014-12-22
;last edited:
;   2014-12-22  create
;*************************************************************

load "$ncarg_root/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$ncarg_root/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$ncarg_root/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; ==============================================================
; user defined parameters that specify region of globe and
; ==============================================================


;================================================
;variables list:
;	var1--------------u
;	var2--------------v
;	var3--------------pr
;================================================


;global variables

   g_data_path    = "../data/"
   g_fig_name    = "../fig/fig11_a2_jja_uv_pr"

	g_lats        = -30.
	g_latn        = 60. 
	g_lonl        = 20.
	g_lonr        = 180.
	g_pnew         = (/ 850.0 /) ;for sigma-p to p lvl    
	g_p0	   = 1000   ;for sigma-p to p lvl
	
   g_season       = "jja"  
   
   g_fig_titles   = (/"bio","nio","sio","nio+sio"/)

   g_exp_group    = (/"a1","a2","a2","a2"/)
   g_exp_names    = (/"bio","nio","sio","nio+sio"/)
	g_fig_ranks    = (/"a","b","c","d"/)

   g_font         = 0.03

   g_nsmp         = 28   
; ==============================================================
; mission 1. open the file: read data and merge metadata 
; ==============================================================

	all_files = systemfunc ("ls "+g_data_path+"ctrl/*h0.000[5-9]*.nc  "+g_data_path+"ctrl/*h0.00[1-3]*.nc")
	
	setfileoption("nc","suppressclose",false) ; close too many files

	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	listsettype (ctrl_in, "cat")             ; concatenate or "merge" (default)

;------------------below to change the variable---------------------	
	ctrl_var1  = ctrl_in[:]->u 
	ctrl_var2  = ctrl_in[:]->v
	ctrl_var3  = ctrl_in[:]->precl			; p for unify the var name
	ctrl_var4  = ctrl_in[:]->precc
	ctrl_var3 = (ctrl_var3+ctrl_var4)*86400*1000 		;precipt rate mm/day


;--------below is for coordinate alternation-------------
	hbcofa	   = ctrl_in[:]->hyam(0:25)
	hbcofb	   = ctrl_in[:]->hybm(0:25)
	ctrl_psfc	   = ctrl_in[:]->ps


	


	
; ==============================================================
; mission 2. set the figure parameters
; ==============================================================


   ;-----------------------------------------------------------------------------
   wks = gsn_open_wks("eps",g_fig_name)  ; open a ps file
   ;  wks = gsn_open_wks("pdf","up_t_surface_cte_mean_250-400hpa")  ; open a ps file
   ;  wks = gsn_open_wks("x11","diabatic_heat_250-500hpa")  ; open a ps file

   plot_v = new((/4/),graphic)     ;vector
   plot_s = new((/4/),graphic)     ;shading
   plot_sig = new((/4/),graphic)   ;sig in shading

   ;gsn_define_colormap(wks,"blaqgryeorrevi200") ; choose a colormap 
   ;   gsn_define_colormap(wks,"rainbow") ; choose a colormap
   ;   gsn_define_colormap(wks,"blgryeorrevi200") ; choose a colormap
   ;gsn_define_colormap(wks,"precip4_diff_19lev")
   gsn_define_colormap(wks,"precip_diff_12lev")
   ; gsn_define_colormap(wks,"bkblaqgryeorreviwh200")
   ;gsn_define_colormap(wks,"viblgrwhyeorre")


   ;-----------------------------------------------------------------------------
   res                  = true       ; use plot options

   res@cnfillon             = true               ; turn on color for contours
   res@cnlineson            = false              ; turn off contour lines
   res@cnlinelabelson       = false              ; turn off contour line labels



   i = nhlnewcolor(wks,0.341,0.,0.533)              ; add gray to colormap
   j = nhlnewcolor(wks,1,0.,0.)
   ;  res@mplandfillcolor       = "gray"            ; set land to be gray

   ;  res@cnlevelselectionmode = "explicitlevels"   ; set manual contour levels
   ;  res@cnlevels = (/-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5/)
   ;   res@cnlevels = ispan(0,60,10)
   ;  res@cnfillcolors =(/-1,20,47,57,94,127,152/)

   res@cnlevelselectionmode  = "manuallevels" ; set manual contour levels
   res@cnminlevelvalf        =  -3.0          ; set min contour level
   res@cnmaxlevelvalf        =  3.0          ; set max contour level
   res@cnlevelspacingf       =  0.25          ; set contour interval

   ;  res@cnfillcolors =(/2,4,7,8,8,9,11,13/)


   res@gsnframe         = false
   res@gsndraw  = false

   res@gsnspreadcolors      = true               ; use full color map
   res@gsnspreadcolorstart  = 2                ; start at color 17
   res@gsnspreadcolorend    = 14                ; end at color 200

   ;  res@gsnpanellabelbar    = true   ;turn on panel labelbar
   res@gsnrightstring = ""

   res@gsnmaximize      = true       ; fill up the page
   res@gsnaddcyclic   = false
   res@gsnpaperorientation = "portrait"
   res@gsncontourzerolinethicknessf = 2.  ;set thickness of zero


   res@lblabelbaron = false   ; turn off the label bar
   res@lborientation          = "vertical"
   res@lblabelfontheightf  = g_font              ; make labels smaller
   res@lblabelstride = 1

   res@mpfillon   = true;false     ; turn off gray continents
   res@mpgeophysicallinethicknessf = 3 
   res@mpgeophysicallinecolor      = "black";"white" 
   ;res@mpfilldraworder="postdraw"

   res@mpcenterlonf = 180.
   res@mpmaxlonf  = g_lonr
   res@mpminlonf  = g_lonl

   res@mpmaxlatf  = g_latn
   res@mpminlatf  = g_lats
   ;  res@mpshapemode = "freeaspect" 

   ;  res@vpwidthf = 0.8
   ;  res@vpheightf = 0.6

   ;  res@tmxbmajoroutwardlengthf = -0.
   ;  res@tmylmajoroutwardlengthf = -0.
   ;  res@tmyrmajoroutwardlengthf = -0.

   ;  res@tmxbminoroutwardlengthf = -0.
   ;  res@tmylminoroutwardlengthf = -0.
   ;  res@tmyrminoroutwardlengthf = -0.

   ; now change the size of the tickmark labels
   res@tmxbtickspacingf = 30
   res@tmyltickspacingf = 30
   ; res@tmxblabelfontaspectf = 1.6
   res@tmxblabelfontthicknessf = 2.0
   ; res@tmyllabelfontaspectf = 1.3
   res@tmyllabelfontthicknessf = 2.0
   ; res@tmyllabelfontquality =
   res@tmxbmajorthicknessf = 3.0
   res@tmylmajorthicknessf = 3.0
   res@tmxbminorthicknessf = 3.0
   res@tmylminorthicknessf = 3.0
   res@tmborderthicknessf = 3.0
   ;-----------------------------------------------------------------------------


   res@tmxblabelfontheightf = g_font
   res@tmyllabelfontheightf = g_font
   res@gsnstringfontheightf = g_font
   res@gsnleftstring = ""
   res@gsncenterstring = ""
   ;-------set for contour plot--------

   ;-------set for the vector plot------
   vcres = true
   vcres@gsndraw          = false           ; don't draw
   vcres@gsnframe         = false           ; don't advance frame
   vcres@gsnrightstring   = " "             ; turn off right string
   vcres@gsnleftstring    = " "             ; turn off left string
   vcres@gsncenterstring    = " "

   vcres@vcrefannoon      = true
   vcres@vcrefannoorthogonalposf = -0.21             ; move ref vector up
   vcres@vcrefmagnitudef         = 3.0             ; define vector ref mag
   vcres@vcreflengthf            = 0.045            ; define length of vec ref
   vcres@vcglyphstyle            = "curlyvector"    ; turn on curly vectors
   vcres@vcmindistancef          = 0.017
   vcres@vcrefannostring1  = "3 m/s"
   vcres@vcrefannostring2  = ""
   vcres@vcrefannofontheightf = 0.018

   vcres@vclinearrowthicknessf     = 2.0    ;thickness of vector

   ;----------set res sig-----------
   res_sig                  = true       ; use plot options
   res_sig@cnfillon         = true       ; fill contours
   res_sig@cnlineson        = false;true      ; turn off contour lines
   res_sig@gsnframe         = false
   res_sig@gsndraw  = false
   res_sig@cnlinelabelson   = false      ; turn off contour line labels
   res_sig@cnlinethicknessf = 2
   res_sig@cnlinecolor      = "black"
   res_sig@cninfolabelon = false
   res_sig@cnmonofillpattern    = true;false
   res_sig@cnfillpattern = 17
   res_sig@cnmonofillscale = true
   res_sig@cnfillscalef = 1.
   res_sig@cnmonofillcolor = true
   res_sig@cnfillcolor  =  "red"
   res_sig@cnfilldotsizef = 0.0035

   res_sig@lblabelbaron = false;true   ; turn off the label bar

   ;  res_sig@cnlevelselectionmode="explicitlevels"
   ;  res_sig@cnlevels = (/3000,1000/)
   res_sig@gsnleftstring      = " "
   res_sig@gsnrightstring      = " "


   ;-----set resource for the whole page----

   pres                 =  true 
   pres@gsnpanellabelbar   = true		;universial colorbar
   ;pres@pmlabelbarwidthf   = 0.5	
   ;pres@gsnpanelrowspec = true                   ; tell panel what order to plt
   pres@lblabelautostride    = false
   pres@lblabelstride       = 4 
   pres@lbtitlestring       = "precipitation rate (mm/day)"
   pres@lblabelfontheightf = 0.02 
   pres@lbtitlefontheightf = 0.02
   pres@pmlabelbarorthogonalposf = -0.03           ; move label bar down

; ==============================================================
; mission 3. post process the data
; ==============================================================

	ctrl_var1_season = month_to_season (ctrl_var1, g_season)
	ctrl_var2_season = month_to_season (ctrl_var2, g_season)
	ctrl_var3_season = month_to_season (ctrl_var3, g_season)
	ctrl_psfc_season = month_to_season (ctrl_psfc, g_season)	


;************************************************
; define other arguments required by vinth2p
;************************************************
; type of interpolation: 1 = linear, 2 = log, 3 = loglog
	interp = 2 

; is extrapolation desired if data is outside the range of ps
	extrap = false

      
;************************************************
; calculate t on pressure levels
;************************************************
; note, the 7th argument is not used, and so is set to 1.
;************************************************
	ctrl_var1p_season = vinth2p(ctrl_var1_season,hbcofa,hbcofb,g_pnew,ctrl_psfc_season,interp,g_p0,1,extrap)
	ctrl_var2p_season = vinth2p(ctrl_var2_season,hbcofa,hbcofb,g_pnew,ctrl_psfc_season,interp,g_p0,1,extrap)
	;ctrl_var3p_season = vinth2p(ctrl_var3_season,hbcofa,hbcofb,pnew2,ctrl_psfc_season,interp,p0,1,extrap)

	ctrl_var1p = dim_avg_n_wrap(ctrl_var1p_season,0)
	ctrl_var2p = dim_avg_n_wrap(ctrl_var2p_season,0)
	ctrl_var3p = dim_avg_n_wrap(ctrl_var3_season,0)

	ctrl_var1p_var = dim_variance_n(ctrl_var1p_season,0)
	ctrl_var2p_var = dim_variance_n(ctrl_var2p_season,0)
	ctrl_var3p_var = dim_variance_n(ctrl_var3_season,0)


      
   print("ctrl processed done!")
   
   
   do i = 0,dimsizes(g_exp_names)-2
      if (i .eq. 0) then
         all_files2 = systemfunc ("ls "+g_data_path+g_exp_group(i)+"_"+g_exp_names(i)+"/*h0.000[5-9]*.nc  "+g_data_path+g_exp_group(i)+"_"+g_exp_names(i)+"/*h0.00[1-3]*.nc")
      else
         all_files2 = systemfunc ("ls "+g_data_path+g_exp_group(i)+"_"+g_exp_names(i)+"/data/*h0.000[6-9]*.nc  "+g_data_path+g_exp_group(i)+"_"+g_exp_names(i)+"/data/*h0.00[1-3]*.nc")
      end if 

		setfileoption("nc","suppressclose",false)

		exp_in      = addfiles (all_files2, "r")   ; note the "s" of addfile

		listsettype (exp_in, "cat")             ; concatenate or "merge" (default)

;------------------below to post process the data---------------------
		exp_var1  = exp_in[:]->u
		exp_var2  = exp_in[:]->v
		exp_var3  = exp_in[:]->precl 
		exp_var4  = exp_in[:]->precc
		exp_var3 = (exp_var3+exp_var4)*86400*1000 		;precipt rate mm/day

		exp_psfc  = exp_in[:]->ps

		exp_var1_season = month_to_season (exp_var1, g_season)
		exp_var2_season = month_to_season (exp_var2, g_season)
		exp_var3_season = month_to_season (exp_var3, g_season)
		exp_psfc_season = month_to_season (exp_psfc, g_season)
		


		exp_var1p_season = vinth2p(exp_var1_season,hbcofa,hbcofb,g_pnew,exp_psfc_season,interp,g_p0,1,extrap)
		exp_var2p_season = vinth2p(exp_var2_season,hbcofa,hbcofb,g_pnew,exp_psfc_season,interp,g_p0,1,extrap)
		;exp_var3p_season = vinth2p(exp_var3_season,hbcofa,hbcofb,pnew2,exp_psfc_season,interp,g_p0,1,extrap)
		
		exp_var1p=dim_avg_n_wrap(exp_var1p_season,0)	;averages, will be 3 dims ([1]x[lat]x[lon]) for lev_p be the first 
		exp_var2p=dim_avg_n_wrap(exp_var2p_season,0)
		exp_var3p=dim_avg_n_wrap(exp_var3_season,0)

		exp_var1p_var = dim_variance_n(exp_var1p_season,0)	;variances
		exp_var2p_var = dim_variance_n(exp_var2p_season,0)
		exp_var3p_var = dim_variance_n(exp_var3_season,0)

		diff_var1 = exp_var1p
		diff_var2 = exp_var2p
		diff_var3 = exp_var3p	

		diff_var1 = (exp_var1p-ctrl_var1p)
		diff_var2 = (exp_var2p-ctrl_var2p)
		diff_var3 = (exp_var3p-ctrl_var3p)		
		diff_var3_sig = diff_var3

      res@gsnleftstring = "("+g_fig_ranks(i)+")"
      res@gsncenterstring = g_fig_titles(i)
           
		if (i .eq. 0) then
			bio_var3 = diff_var3
		else
         res@gsnrightstring ="r="+sprintf("%4.2f",pattern_cor(bio_var3({g_lats:g_latn},{g_lonl:g_lonr}), diff_var3({g_lats:g_latn},{g_lonl:g_lonr}), 1.0, 0))
		end if 
		;============================================================
		;sig test
		;============================================================

		sigr = 0.05                        ; critical sig lvl for r

		iflag= false                        ; population variance similar
		prob1 = ttest(ctrl_var1p,ctrl_var1p_var,g_nsmp, exp_var1p,exp_var1p_var,g_nsmp, iflag, false) 
		prob2 = ttest(ctrl_var2p,ctrl_var2p_var,g_nsmp, exp_var2p,exp_var2p_var,g_nsmp, iflag, false)
		prob3 = ttest(ctrl_var3p,ctrl_var3p_var,g_nsmp, exp_var3p,exp_var3p_var,g_nsmp, iflag, false)
		
		diff_var1(0,:,:)=mask(diff_var1(0,:,:),(prob1(0,:,:) .lt. sigr) .or. (prob2(0,:,:) .lt. sigr),true)
		diff_var3_sig(:,:)=mask(diff_var3(:,:),prob3(:,:) .lt. sigr,true)
		
      
      ;archive nio_a2
      if (i .eq. 1) then
         nio_diff_var1 = diff_var1
         nio_diff_var2 = diff_var2
         nio_diff_var3 = diff_var3
         
         nio_var1p_season = exp_var1p_season
         nio_var2p_season = exp_var2p_season
         nio_var3_season = exp_var3_season
      end if
      ;============================================================
		; plots
		;============================================================
		
		plot_v(i) = gsn_csm_vector(wks,diff_var1(0,:,:),diff_var2(0,:,:),vcres) ; dim1 = 0 for lvl = 0


		plot_s(i) = gsn_csm_contour_map(wks,diff_var3,res)	

		plot_sig(i) = gsn_csm_contour(wks,diff_var3_sig,res_sig)  ; create shaded contours

		;---overlay will transform plot_shade into data space of plot_fill

		overlay(plot_s(i),plot_sig(i))
		overlay(plot_s(i),plot_v(i))
      print(g_exp_names(i)+" done!")
	   if (i .eq. 2) then
      
         res@gsnleftstring = "("+g_fig_ranks(i+1)+")"
         res@gsncenterstring = g_fig_titles(i+1)

         exp_var1p_season = (/exp_var1p_season + nio_var1p_season/)*0.5
		   exp_var2p_season = (/exp_var2p_season + nio_var2p_season/)*0.5
		   exp_var3_season = (/exp_var3_season + nio_var3_season/)*0.5	
         
         exp_var1p=dim_avg_n_wrap(exp_var1p_season,0)	;averages, will be 3 dims ([1]x[lat]x[lon]) for lev_p be the first 
         exp_var2p=dim_avg_n_wrap(exp_var2p_season,0)
         exp_var3p=dim_avg_n_wrap(exp_var3_season,0)

         exp_var1p_var = dim_variance_n(exp_var1p_season,0)	;variances
         exp_var2p_var = dim_variance_n(exp_var2p_season,0)
         exp_var3p_var = dim_variance_n(exp_var3_season,0)


      
         diff_var1(0,:,:) = diff_var1(0,:,:)+nio_diff_var1(0,:,:)
         diff_var2(0,:,:) = diff_var2(0,:,:)+nio_diff_var2(0,:,:)
         diff_var3 = diff_var3+nio_diff_var3
         exp_var1p = ctrl_var1p+diff_var1
         exp_var2p = ctrl_var2p+diff_var2
         exp_var3p = ctrl_var3p+diff_var3
         exp_var1p_var = dim_variance_n(exp_var1p_season,0)	;variances
		   exp_var2p_var = dim_variance_n(exp_var2p_season,0)
		   exp_var3p_var = dim_variance_n(exp_var3_season,0)


         prob1 = ttest(ctrl_var1p,ctrl_var1p_var,g_nsmp, exp_var1p,exp_var1p_var,g_nsmp, iflag, False) 
		   prob2 = ttest(ctrl_var2p,ctrl_var2p_var,g_nsmp, exp_var2p,exp_var2p_var,g_nsmp, iflag, False)
		   prob3 = ttest(ctrl_var3p,ctrl_var3p_var,g_nsmp, exp_var3p,exp_var3p_var,g_nsmp, iflag, False)
		
		   diff_var1(0,:,:)=mask(diff_var1(0,:,:),(prob1(0,:,:) .lt. sigr) .or. (prob2(0,:,:) .lt. sigr),True)
		   diff_var3_sig(:,:)=mask(diff_var3(:,:),prob3(:,:) .lt. sigr,True)
		
         plot_V(i+1) = gsn_csm_vector(wks,diff_var1(0,:,:),diff_var2(0,:,:),vcres) ; dim1 = 0 for lvl = 0

         res@gsnRightString ="R="+sprintf("%4.2f",pattern_cor(bio_var3({g_latS:g_latN},{g_lonL:g_lonR}), diff_var3({g_latS:g_latN},{g_lonL:g_lonR}), 1.0, 0))

		   plot_S(i+1) = gsn_csm_contour_map(wks,diff_var3,res)	

		   plot_sig(i+1) = gsn_csm_contour(wks,diff_var3_sig,res_sig)  ; Create shaded contours

		   ;---Overlay will transform plot_shade into data space of plot_fill

		   overlay(plot_S(i+1),plot_sig(i+1))
		   overlay(plot_S(i+1),plot_V(i+1))
         print(g_exp_names(i+1)+" done!")
  
      end if
   
   end do
;==============================================
; create panel
;=============================================

  	gsn_panel(wks,plot_S,(/2,2/),pres)

end




