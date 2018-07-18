PRO PBL_PLOT_BR, ss_theta, ss_height, pbl_br, pbl_br5, brprofile, thetav, date, pngpath, vapname

;COMMON SUBSAMP, SUBSAMPLE_INTERVAL_MB, gPRES_GRID, gLAPSE_RATE, gSMOOTHED_LAPSE_RATE, gHEIGHT, $ 
                 ; gTHETA, gPRES, gLAPSE_MASK, gWSPD, gWDIR, gRH, gTDRY, SUBSAMPLED_HEIGHTS
COMMON PBL_HT, oheftter , obotlayer, otoplayer, omaxlayer, layer_smoothed_lapse
COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT                  
                  
  resolution =[800,800]
  ;set_Plot, 'x'
  set_Plot, 'z'
  @color_syms.include
  
  ;device, decomposed=0 ; only for x
  device,set_resolution=resolution ; only for z
  !p.background = d_white
  !p.charsize = 1.0
  !p.thick = 1.5
  !p.font = 0
  !p.color = d_black 
  !x.margin = [10,4]
  !y.margin = [6,6]
 
 
  

  alt_var0= ss_height[0]
  plot,thetav, ss_height-alt_var0,psym=-2,$
    xtitle='Potential Virtual temperature (K)', ytitle='m AGL', $
    yrange=[0,MAX_PBL_HT],ystyle=1,xrange=[280,330],xstyle=8,xthick=2,ythick=2 
  plot,/noerase,brprofile,ss_height-alt_var0,psym=-2,color=d_red,xrange=[0,5], xstyle=4,$
    yrange=[0,MAX_PBL_HT],ystyle=4
  axis, xaxis=1, color=d_red, xtitle = 'Bulk Richardson Profile' ;+ date
  
  oplot, [0,350],[pbl_br-alt_var0, pbl_br-alt_var0], color=d_green, linestyle=3
  oplot, [0,350],[pbl_br5-alt_var0, pbl_br5-alt_var0], color=d_blue, linestyle=3
       
  xyouts, 0.25, 3500, 'PBL using critical threshold of 0.25 ' + strtrim(string(format='(I5.2)',pbl_br-alt_var0)) + ' m AGL', color=d_green 
  xyouts, 0.25, 3300, 'PBL using critical threshold of 0.5 ' + strtrim(string(format='(I5.2)',pbl_br5-alt_var0)) + ' m AGL', color=d_blue 
  xyouts,1.0, -400, 'Created on '+systime(0), color=d_black
  xyouts,1.0,-550, vapname + ' plot  for ' + date,color=d_black
  ;;Title
  xyouts, 0.5, 5300, 'PBL using Bulk Richardson method for '  + date, color=d_black

  saveimage, pngpath, /quiet
END

