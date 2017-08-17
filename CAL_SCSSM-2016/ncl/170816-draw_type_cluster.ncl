;*******************************************************
; unique_5.ncl
;
; Concepts illustrated:
;   - Drawing multiple bar charts on a page
;   - Drawing three custom legends outside a bar chart
;   - Using bar charts to draw standard deviations for four time series
;   - Drawing a time series plot
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
     print("timestart:" + systemfunc("date"))
     stdarr = new((/3,3,3/),"float") ;(0)--time (1)--case (2)--traj type
     stdarr(0,:,0) = (/24,14,33/)
     stdarr(0,:,1) = (/41,18,59/)
     stdarr(0,:,2) = (/35,68,8/)
     
     stdarr(1,:,0) = (/12,11,35/)
     stdarr(1,:,1) = (/56,26,47/)
     stdarr(1,:,2) = (/33,63,18/)
     
     stdarr(2,:,0) = (/9,12,13/)
     stdarr(2,:,1) = (/40,41,26/)
     stdarr(2,:,2) = (/51,47,61/)

    type_id=2
;====================================================================================== 
     wks = gsn_open_wks("png","../fig/unique-typeIII")          ; send graphics to PNG file

     sres = True
     sres@vpWidthF = 0.7
     sres@vpHeightF = 0.5
     sres@vpXF = .15
     sres@trXMinF = 0
     sres@trXMaxF = 4
     sres@trYMinF = 0
     sres@trYMaxF = 70 
     sres@gsnDraw = True
     sres@gsnFrame = False
     sres@gsnXYBarChart = True
     sres@gsnXYBarChartBarWidth = 0.15           ; change bar widths
     sres@tmXBMode          = "Explicit"         ; explicit labels
     sres@tmXBValues        = (/1,2,3/)
     sres@tmXBLabels = (/"-2 Day","0 Day","+2 Day"/)
     sres@tmXBLabelFontHeightF = 0.0205
     sres@tmXTLabelFontHeightF = 0.0205
     sres@tmYLLabelFontHeightF = 0.0225
     sres@tiMainFontHeightF = 0.025
;     sres@tiMainFont = "helvetica"
     sres@tiMainString = "Type III Trajectory Evolution"
     sres@gsnRightString = ""
     sres@tiYAxisString = "%"
        
     sres@gsnXYBarChartColors = (/"red"/)   
     plot1 = gsn_csm_xy(wks,fspan(.775,11.775,12),stdarr(:,1,type_id),sres)     ; Early
     sres@gsnXYBarChartColors = (/"darkgreen"/)                 ; seperately, not
     plot2 = gsn_csm_xy(wks,fspan(.925,11.925,12),stdarr(:,0,type_id),sres)     ; Clim
     sres@gsnXYBarChartColors = (/"blue"/)                  ; but tweaking where
     plot3 = gsn_csm_xy(wks,fspan(1.075,12.075,12),stdarr(:,2,type_id),sres)        ; Late

   
     frame(wks)      
end
