FUNCTION LIU_LANG_CALC, oll_pbl,oll_level1, oll_level2, ss_theta, ss_heightm, ss_wspd, ht0
;*************************************************************
;liu and liang paper
COMMON THRESHOLDS, inv_strength_thres, instab_threshold, overshoot_threshold, regime_type
COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT
ll_height_m =  MISSING

if (n_elements(ss_theta) lt 5 ) then $
  return, MISSING

  htdni=1
  htupi=4

  ;categorize sondes as CBL (convective), SBL (stable) or NRL (neutral)
  if ss_theta(htupi)-ss_theta(htdni) lt (-1 * inv_strength_thres) then begin
    regime_type='CBL'
    allregime_type=2
  endif else begin
    if ss_theta(htupi)-ss_theta(htdni) gt inv_strength_thres then begin
      regime_type='SBL'
      allregime_type=1
    endif else begin
      regime_type='NRL'
      allregime_type=0
    endelse
  endelse

  ll_lev_1_i=!values.f_nan
  ll_lev_1_theta=!values.f_nan
  ll_lev_1_heightm=!values.f_nan
  ll_lev_1_bar_pres=!values.f_nan

  ll_lev_2_i=!values.f_nan
  ll_lev_2_theta=!values.f_nan
  ll_lev_2_heightm=!values.f_nan
 
  ll_lev_jet_nose=!values.f_nan

  ll_heightm=!values.f_nan

  ;calculate theta k
  thetak=( (ss_theta(1:n_elements(ss_theta)-1) $
            -ss_theta(0:n_elements(ss_theta)-2))/((ss_heightm(1:n_elements(ss_heightm)-1) $
            -ss_heightm(0:n_elements(ss_heightm)-2))/1000.) )  ;units = K km-1


  ss_heightm2=(ss_heightm(1:n_elements(ss_heightm)-1)+ $
               ss_heightm(0:n_elements(ss_heightm)-2))/2.


  if regime_type eq 'CBL' or regime_type eq 'NRL' then begin
           ;scan upward to find the lowest level l=k where 
           ;.5K is the theta increment for the min strength of the unstable layer
           ;authors say these two vertical scans start from the data level right above 150m AGL

           level_above_150m_i=where(ss_heightm-ht0 gt 150.0,nlevel_above_150m_i)
           level_above_150m_i=level_above_150m_i(0)
           x=where(ss_theta-ss_theta(0) ge instab_threshold and ss_heightm-ht0 gt 150L,nx)
           if nx gt 0 then begin
             ll_lev_1_i=x(0)
             ll_lev_1_heightm=ss_heightm(ll_lev_1_i)
             ll_height_m=ss_heightm(ll_lev_1_i)
             ;first guess level k is then corrected by another 
             ; upward scan to search for the for first occurrence of theta
             ; k greater than 4.0 K km-1
             xthetak=[thetak,!values.f_nan]
             x=where(ss_theta-ss_theta(0) ge instab_threshold and ss_heightm ge ll_lev_1_heightm and xthetak ge overshoot_threshold,nx)
             if nx gt 0 then begin
                   ll_lev_2_i=x(0)
                   ll_lev_2_heightm=ss_heightm(ll_lev_2_i)
                   ll_height_m=ss_heightm(ll_lev_2_i)
             endif
          endif
  endif

  if regime_type eq 'SBL' then begin
           ;scan upward to find the lowest level at which theta k reaches a minimum
           ll_lev_1_i=-1
           for i = 1, n_elements(thetak)-2 do begin
             if ll_lev_1_i lt 0 then begin

               ;check to see if you are at a minimum
               ;the article does not specifiy starting from just above 150mAGL for
               ;SBL, but I cant imagine why not ;and heightm(i)-heightm[0] gt 150L
               ;if either of these two conditions are met

               if thetak(i) gt thetak(i-1) then begin 
                 if i eq 1 then iminus2=i-1 else iminus2=i-2
                 if thetak(i-1)-thetak(iminus2) lt (-1*overshoot_threshold) or (thetak(i) lt overshoot_threshold and thetak(i+1) lt overshoot_threshold) then begin
                   ll_lev_1_i=i-1  ;then you have found your first level
                   ll_lev_1_heightm=ss_heightm2(ll_lev_1_i)
                 endif else ll_lev_1_i=-1
               endif
             endif
           endfor

           ;now look for the low level jet
           w=ss_wspd(1:n_elements(ss_wspd)-1)-ss_wspd(0:n_elements(ss_wspd)-2)
           x=where(w lt 0,nx)
           if nx gt 0 then begin
             xx=where(ss_wspd(x(0):*)-ss_wspd(x(0)) lt -2,nxx)
             if nxx gt 0 then begin
               ll_lev_2_i=(x(0)-1)
               ll_lev_2_heightm=ss_heightm(ll_lev_2_i) ;ss_heightm2(ll_lev_2_i)
               ll_lev_jet_nose=ll_lev_2_heightm
             endif
           endif
           x=[ll_lev_1_heightm,ll_lev_2_heightm]
           ll_height_m=min(x,/nan)

  endif
  
  oll_level1=ll_lev_1_heightm
  oll_level2=ll_lev_2_heightm
  ; PBL
  oll_pbl = ll_height_m
return, allregime_type

END
