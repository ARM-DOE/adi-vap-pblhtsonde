PRO PBL_PLOT_LL, ss_theta, ss_height, ss_wspd, level1, level2, pbl_ll, regime_type, date, pngpath, vapname
COMMON SUBSAMP, SUBSAMPLE_INTERVAL_MB, gPRES_GRID, gLAPSE_RATE, gSMOOTHED_LAPSE_RATE, gHEIGHT, $ 
                  gTHETA, gPRES, gLAPSE_MASK, gWSPD, gWDIR, gRH, gTDRY, SUBSAMPLED_HEIGHTS
COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT
                  
  resolution =[800,800]
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
 
 
  level1lbl=  ''
  level2lbl=  ''
  if (regime_type eq 'CBL') or (regime_type eq'NRL') then begin
     level1lbl= 'Bottom of unstable layer'
     level2lbl=  'Lapse rate exceeds gradient threshold'
  endif
  if (regime_type eq 'SBL') then begin
     level1lbl= 'Local potential temperature mimimum'
     level2lbl=  'Nose of low level jet'
  endif
  

  alt_var0= ss_height[0]
  plot,ss_theta, ss_height-alt_var0,psym=-2,$
    xtitle='Potential temperature (K)', ytitle='m AGL', $
    yrange=[0,MAX_PBL_HT],ystyle=1,xrange=[280,330],xstyle=8,xthick=2,ythick=2 
  plot,/noerase,ss_wspd,ss_height-alt_var0,psym=-2,color=d_red,xrange=[0,40], xstyle=4,$
    yrange=[0,MAX_PBL_HT],ystyle=4
  axis, xaxis=1, color=d_red, xtitle = 'Windspeed (m/s)' ;+ date

  oplot, [0,350],[level1-alt_var0, level1-alt_var0], color=d_blue
  oplot, [0,350],[level2-alt_var0, level2-alt_var0], color=d_black
  oplot, [0,350],[pbl_ll-alt_var0, pbl_ll-alt_var0], color=d_green, linestyle=4
  xyouts, 2, 3800, 'PBL = ' + strtrim(string(format='(I5.2)',pbl_ll-alt_var0)) + ' m AGL', color=d_green 
  xyouts, 2, 3600, level1lbl, color=d_blue 
  xyouts, 2, 3400, level2lbl, color=d_black 
  xyouts,7, -400, 'Created on '+systime(0), color=d_black
  xyouts,7,-550, vapname + ' plot  for ' + date,color=d_black
  ;;Title
  xyouts, 4, 5300, 'PBL using Liu and Liang method for regime type ' + regime_type + ' for '  + date, color=d_black

  saveimage, pngpath, /quiet
END

