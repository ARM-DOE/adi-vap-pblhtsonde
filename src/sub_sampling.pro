FUNCTION sub_sampling, bar_pres, heightm, theta, wspd , wdir, rh, tdry


COMMON SUBSAMP, SUBSAMPLE_INTERVAL_MB, gPRES_GRID, gLAPSE_RATE, gSMOOTHED_LAPSE_RATE, gHEIGHT, $ 
                  gTHETA, gPRES, gLAPSE_MASK, gWSPD, gWDIR, gRH, gTDRY, SUBSAMPLED_HEIGHTS

;Need to subtract the number of intervals so the for loop works.
q=(fix(bar_pres(1)/subsample_interval_mb)-(subsample_interval_mb+1))
qbar_pres=(fix(bar_pres(1)/subsample_interval_mb)*subsample_interval_mb)+subsample_interval_mb

subsampled_profile=fltarr(11,q)
subsampled_profile(*)=!values.f_nan

for i = 0, q-1 do begin
  ; pressure at the lowest subsample interval
  subsampled_profile(gPRES_GRID,i)=qbar_pres-(i*subsample_interval_mb)
  if i eq 0 then begin
    subsampled_profile(gPRES,i)   = bar_pres(0)
    subsampled_profile(gHEIGHT,i) = heightm(0)
    subsampled_profile(gTHETA,i)  = theta(0)
    subsampled_profile(gWSPD,i)   = wspd(0)
    subsampled_profile(gWDIR,i)   = wdir(0)
    subsampled_profile(gRH,i)     = rh(0)
    subsampled_profile(gTDRY,i)   = tdry(0)
    qq1=0
  endif else begin
    qq=where(bar_pres ge subsampled_profile(0,i) and $
            bar_pres lt subsampled_profile(0,i)+subsample_interval_mb,nqq)
    if nqq gt 0  then begin
        qq1=qq
        subsampled_profile(gPRES,i)  = bar_pres(max(qq))
        subsampled_profile(gHEIGHT,i)= heightm(max(qq))
        subsampled_profile(gTHETA,i) = theta(max(qq))
        subsampled_profile(gWSPD,i) =  wspd(max(qq))
        subsampled_profile(gWDIR,i) =  wdir(max(qq))
        subsampled_profile(gRH,i)   =  rh(max(qq))
        subsampled_profile(gTDRY,i) =  tdry(max(qq))
    endif
  endelse
  lastqq=max(qq1)
endfor
RETURN, subsampled_profile
END

