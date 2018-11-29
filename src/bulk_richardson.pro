FUNCTION BULK_RICHARDSON, heightm, bar_pres, wdir, wspd, rh, t, br_pt_5, brprofile, thetav

COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT
COMMON PBL_HT, oheftter , obotlayer, otoplayer, omaxlayer, layer_smoothed_lapse, layer_delta_theta

g=9.81
es=6.11*exp((2.5*10.0^6/461.0)*((1./273.15)-(1./(t))))   ; saturation vapor pressure
ws=(0.622/(bar_pres))*(es)                               ; saturation mixing ratio
w=((rh)/100.0)*(ws)                                      ; mixing ratio
e=((rh)/100.0)*(es)                                      ; vapor pressure

tv=(t)/(1.0-((e)/(bar_pres))*(1.0-0.622))                ; virtual temperature
thetav=(tv)*(1000.0/(bar_pres))^0.286                    ; potential virtual temperature based on init pres of 1000mb
wdir1 = wdir
badwdir = where(wdir1 eq MISSING)                        ;To avoid any negative brprofiles
wdir1(badwdir) = !values.f_nan
deg_rad=2.0*!pi*float(wdir1)/360.0;                       ;
uwind=float(wspd)*sin(float(deg_rad))                    ;
vwind=float(wspd)*cos(float(deg_rad))                    ;

;calculate bulk richardson number
hbr_pt25 = MISSING 
hbr_pt5 =  MISSING
x=((uwind)^2 + (vwind)^2)^.5

heightm_agl=heightm-heightm[0]
thetav_diff = thetav-thetav[0]
difft = where(thetav_diff lt 0)
thetav_diff[difft] = !values.f_nan

brprofile= ((g*heightm_agl)*(thetav_diff)) / (thetav(0)*(uwind^2+vwind^2)) 
 ;sorenson, 1998 Mesoscal Influence on Long
 ; -Range Transport - Evidence from ETEX Modelling and Obs
  upvali=MISSING;!values.f_nan
  dnvali=MISSING;!values.f_nan
  diff=brprofile-.25
  posvals=where(diff gt 0,nposvals)
  negvals=where(diff lt 0,nnegvals)
  if nposvals gt 0 and nnegvals gt 0 then begin
     upval=min(diff(posvals))
     dnval=max(diff(negvals))
     upvali=where(diff eq upval)
     dnvali=where(diff eq dnval)
  endif
  if ((upvali gt MISSING) and (dnvali gt MISSING)) then begin
    hbr_pt25=interpol([heightm(dnvali),heightm(upvali)],[brprofile(dnvali),brprofile(upvali)],.25)
  
  endif
  upvali=MISSING;!values.f_nan
  dnvali=MISSING;!values.f_nan
  diff=brprofile-.5
  posvals=where(diff gt 0,nposvals)
  negvals=where(diff lt 0,nnegvals)
  if nposvals gt 0 and nnegvals gt 0 then begin
     upval=min(diff(posvals))
     dnval=max(diff(negvals))
     upvali=where(diff eq upval)
     dnvali=where(diff eq dnval)
  endif

  if ((upvali gt MISSING) and (dnvali gt MISSING)) then $
    hbr_pt5=interpol([heightm(dnvali),heightm(upvali)],$
          [brprofile(dnvali),brprofile(upvali)],.5)

  all_hbr_pt25=hbr_pt25
  all_hbr_pt5=hbr_pt5
  br_pt_5 = all_hbr_pt5
;print, hbr_pt5, hbr_pt25
return, all_hbr_pt25
END

