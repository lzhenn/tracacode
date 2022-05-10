
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    
   pver = 30
   ;Define parameters
   filename="../data/model_post/CAM5_PTENDT_DIFF_mon.bin"

   ; ==============================================================
   ; Open the file: Read only the user specified period
   ; ==============================================================
   all_files = systemfunc ("ls ../bwcam5_2000/ncar_mon/*cam.h0.000[6-9]*.nc ../bwcam5_2000/ncar_mon/*cam.h0.00[1-3]*.nc")
   ;all_files = systemfunc ("ls ../HEATCTRL/ctrl_mon/*cam.h0.000[6-7]*.nc")
   setfileoption("nc","SuppressClose",False) ; close too many files

   ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile

   ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)



   all_files2 = systemfunc ("ls ../awcam5_2000/ncar_mon/*cam.h0.000[6-9]*.nc ../awcam5_2000/ncar_mon/*cam.h0.00[1-3]*.nc")
   ;all_files2 = systemfunc ("ls ../HEATSEN/sen_mon/*cam.h0.000[6-7]*.nc")
   setfileoption("nc","SuppressClose",False)

   exp_in      = addfiles (all_files2, "r")   ; note the "s" of addfile

   ListSetType (exp_in, "cat")             ; concatenate or "merge" (default)


   ;------------------Below to change the variable---------------------    
   ctrl_var  = ctrl_in[:]->PTENDT
   exp_var   = exp_in[:]->PTENDT

   avg_ctrl = clmMonTLLL(ctrl_var)
   avg_exp  = clmMonTLLL(exp_var)
   diff_avg_o = avg_ctrl(:,:,{0:30},{110:150})
   diff_avg_o = (avg_exp(:,:,{0:30},{110:150}) - avg_ctrl(:,:,{0:30},{110:150}))
   diff_avg = diff_avg_o(month|:,lon|:,lat|:,lev|:)
   diff_avg = where(diff_avg<0,0,diff_avg)
   system("rm -f "+filename)
   setfileoption("bin","WriteByteOrder","BigEndian")
   fbinrecwrite(filename,-1,diff_avg&lat)
   fbinrecwrite(filename,-1,diff_avg&lon)
   fbinrecwrite(filename,-1,diff_avg)
   print(diff_avg(:,:,:,pver-1))
   print(diff_avg)
end




