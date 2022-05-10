
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin



; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
	all_files = systemfunc ("ls ../testsrc/exe/*cam.h0.0001-01-0[2-6]*")
	
	setfileoption("nc","SuppressClose",False) ; close too many files

	
	ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

;------------------Below to change the variable---------------------	
	ctrl_var  = ctrl_in[:]->PTENDT 
        avg_var = dim_avg_n_Wrap(ctrl_var,0)
        printVarSummary(avg_var)
        wks = gsn_open_wks("pdf","../fig/color")                 ; open a ps file
        gsn_define_colormap(wks,"BlWhRe")                ; choose colormap

        res                      = True                  ; plot mods desired
        res@cnFillOn             = True                  ; turn on color fill

       ;---This resource not needed in NCL V6.1.0
        res@gsnSpreadColors      = True                  ; use full range of colors

        res@cnLinesOn            = False


	do i = 0,25
      
          res@tiMainString = "test"+i+1+"level"
          plot = gsn_csm_contour_map_ce(wks,avg_var(i,:,:),res)        ; create plot
	end do


end




