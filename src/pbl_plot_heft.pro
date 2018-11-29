PRO PBL_PLOT_HEFT, pres_grid, lapse_ss, smoothed_lapse_ss, heightm_ss,theta_ss, $
              pblh_mamsl,ptl_criticalitop, ptl_criticalibot, date, pngpath, vapname


COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT
COMMON SUBSAMP, SUBSAMPLE_INTERVAL_MB, gPRES_GRID, gLAPSE_RATE, gSMOOTHED_LAPSE_RATE, gHEIGHT, $ 
                  gTHETA, gPRES, gLAPSE_MASK, gWSPD, gWDIR, gRH, gTDRY, SUBSAMPLED_HEIGHTS
                  
COMMON PBL_HT, oheftter , obotlayer, otoplayer, omaxlayer
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

  
  alt0 = heightm_ss[0,0]
  plot,theta_ss,heightm_ss[0,*]-alt0,psym=-2,$
    xtitle='Potential temperature (K)', ytitle='m AGL', $
    yrange=[0,MAX_PBL_HT],ystyle=1,xrange=[280,330],xstyle=8,xthick=2,ythick=2
  ;oplot,theta_ss,heightm_ss[0,*]-alt0,linestyle=1,color=d_red
  plot,/noerase,smoothed_lapse_ss,heightm_ss[0,*]-alt0,psym=2,color=d_red,xrange=[-.04,.04],xstyle=4,$
    yrange=[0,MAX_PBL_HT],ystyle=4
  axis, xaxis=1, color=d_red, xtitle = 'Potential temperature lapse rate (K/m) ' ;+ date
  oplot,lapse_ss, heightm_ss[0,*]-alt0,linestyle=1,color=d_blue
  x=smoothed_lapse_ss    
  x(*)=.005
  oplot,x,heightm_ss[0,*]-alt0,linestyle=1
  y=x
  if (pblh_mamsl ne MISSING) then begin 
    pbl=pblh_mamsl-alt0
  endif else begin
    pbl=pblh_mamsl
  endelse
  ;oplot,profile(2,*),pbl,thick=5, color=d_green , linestyle=4  
  oplot, [0.00 ,0.04], [pbl, pbl], color=d_green, thick=4
  FOR i=0, omaxlayer-1 do begin
   bot=heightm_ss(0,obotlayer)-alt0
   oplot, [0.00 ,0.04], [bot[i], bot[i]], color=d_orange, thick=3 
   top=heightm_ss(0,otoplayer)-alt0
   oplot, [0.00 ,0.04], [top[i], top[i]], color=d_blue, thick=3 , linestyle=4
  ENDFOR

  xyouts, -.035, 3800, 'Smoothed potential temperature lapse rate', color=d_red
  xyouts, -.035, 3600, 'Smoothed data potential temperature', color=d_black
  xyouts, -.035, 3400, 'Potential temperature lapse rate', color=d_blue
  xyouts, -.035, 3200, 'PBL using Heffter = ' + strtrim(string(format='(F8.2)',pbl)) + ' m AGL', color=d_green 
  xyouts, -.035, 3000, 'Bottom of inversion layer', color=d_orange
  xyouts, -.035, 2800, 'Top of inversion layer', color=d_blue
  xyouts, -.035, 2600, 'Subsampled Interval = ' + strtrim(string(format='(I1.0)',subsample_interval_mb)) + ' mb', color=d_black
  xyouts,-0.01, -400, 'Created on '+systime(0), color=d_black
  xyouts,-.01,-550, vapname + ' plot  for ' + date,color=d_black
  ;Title
  xyouts, -0.03, 5300, 'Potential temperature profile and PBL using Heffter method for ' + date, color=d_black

  saveimage, pngpath, /quiet
END

