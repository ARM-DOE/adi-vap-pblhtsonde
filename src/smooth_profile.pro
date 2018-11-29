FUNCTION smooth_profile,subsampled_profile, lapse, theta, heightm, bar_pres


COMMON SUBSAMP, SUBSAMPLE_INTERVAL_MB, gPRES_GRID, gLAPSE_RATE, gSMOOTHED_LAPSE_RATE, gHEIGHT, $ 
                  gTHETA, gPRES, gLAPSE_MASK, gWSPD, gWDIR, gRH, gTDRY, SUBSAMPLED_HEIGHTS
                  
                  
theta_offset=theta(1:*)
theta_offset=[theta_offset,!values.f_nan]
heightm_offset=heightm(1:*)
heightm_offset=[heightm_offset,!values.f_nan]
SUBSAMPLED_HEIGHTS = n_elements(heightm)
heightm_smooth = heightm
; What should the gLAPSE_RATE be at the surface
; Calculate lapse rate.
subsampled_profile(gLAPSE_RATE,1:*) = (theta_offset-theta(0:SUBSAMPLED_HEIGHTS-2)) $
                                    /(heightm_offset-heightm(0:SUBSAMPLED_HEIGHTS-2))
;smooth the lapse rate 
for i = 0, SUBSAMPLED_HEIGHTS-1 do begin
  if i eq 0 then begin
    subsampled_profile(gSMOOTHED_LAPSE_RATE,i)=mean(subsampled_profile(gLAPSE_RATE,i:i+2),/nan)
  endif else begin
    if i eq SUBSAMPLED_HEIGHTS-1 then begin
      subsampled_profile(gSMOOTHED_LAPSE_RATE,i)=mean(subsampled_profile(gLAPSE_RATE,i-1:i),/nan)
    endif else begin
      subsampled_profile(gSMOOTHED_LAPSE_RATE,i)=mean(subsampled_profile(gLAPSE_RATE,i-1:i+1),/nan)
    endelse
  endelse
endfor
RETURN, subsampled_profile
END

