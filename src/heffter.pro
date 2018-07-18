FUNCTION HEFFTER, lapse_rate_mask_h,  smoothed_lapse_ss_h, heightm_h, theta_ss_h, opblh_alt
  COMMON SUBSAMP, SUBSAMPLE_INTERVAL_MB, gPRES_GRID, gLAPSE_RATE, gSMOOTHED_LAPSE_RATE, gHEIGHT, $ 
                  gTHETA, gPRES, gLAPSE_MASK, gWSPD, gWDIR, gRH, gTDRY, SUBSAMPLED_HEIGHTS
                  
  COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT
  COMMON PBL_HT, oheftter , obotlayer, otoplayer, omaxlayer, layer_smoothed_lapse, layer_delta_theta

  pblh = MISSING
    ;=====================================================================================================================
    ;identify layers
    ;a layer starts where reform(profile(6,0:subsampled_heights-1))-[0,reform(profile(6,0:subsampled_heights-2))] eq 1
    ;and it ends at subsampled_heights-1 or where that same expression eq -1, minus one index!
    ;the last "layer" always seems to be from like 12 or 13 km to the end, so I'm not going to include i
    ;First criteria Δθ/Δz ≥ .005 K/m
    ;=====================================================================================================================
    
    first_criteria = where(smoothed_lapse_ss_h ge .005, nx)
    
    if nx gt 0 then lapse_rate_mask_h(first_criteria)=1
    bottom_of_layer_i=where(lapse_rate_mask_h(0:subsampled_heights-1)-[0,lapse_rate_mask_h(0:subsampled_heights-2)] eq 1L,numlayers)
    top_of_layer_i= where(lapse_rate_mask_h(0:subsampled_heights-1) - [0, lapse_rate_mask_h(0:subsampled_heights-2)] eq -1L,ntops)
    
    if (numlayers lt omaxlayer) then omaxlayer = numlayers
    if (ntops lt omaxlayer) then omaxlayer = ntops
    ;This is the lapse rate in the inversion 
    layer_smoothed_lapse = smoothed_lapse_ss_h[bottom_of_layer_i[0:omaxlayer-1]]- smoothed_lapse_ss_h[top_of_layer_i[0:omaxlayer-1]]
    ;This is the hieght at which the first criteria is met.
    ;layer_smoothed_lapse = heightm_h(top_of_layer_i[0:omaxlayer-1]) - heightm_h(bottom_of_layer_i[0:omaxlayer-1])
    ; This is when the first criteria is met and where the alternate pbl is calcualted
    max_smoothed_lapse = max(layer_smoothed_lapse,i)
    ;print, bottom_of_layer_i[i]
    opblh_alt = heightm_h(bottom_of_layer_i[i])
    
    if numlayers gt 0 then begin
        bottom_index=0
         ml_index=1
         top_index=2
         ;determine layer information
         layer_info=fltarr(3,numlayers)
         ;need to keep it nan so we can check for finite values
         layer_info(*)=!values.f_nan
    
         for i = 0, numlayers-1 do begin
           layer_info(bottom_index,i)=bottom_of_layer_i(i)
           if ntops eq numlayers or (ntops ne numlayers and i lt numlayers-1 ) then begin
                layer_info(top_index,i)=top_of_layer_i(i)-1
           endif else begin
                layer_info(top_index,i)=subsampled_heights-1
           endelse
           ;second criteria when θtop – θbase ≥ 2K
           x1=where(theta_ss_h(layer_info(bottom_index,i):layer_info(top_index,i))-(theta_ss_h(layer_info(bottom_index,i))) ge 2.,nxtt)
           if nxtt gt 0 then layer_info(ml_index,i)=layer_info(bottom_index,i)+x1(0)
         endfor
        
         ;print, layer_info
         ;assign the heights to the layers
         layer_info_heights=layer_info
         
         for i = 0, 2 do begin
            x2=where(finite(layer_info(i,*)) eq 1,nx)
            if nx gt 0 then layer_info_heights(i,x2)=heightm_h(layer_info(i,x2))
         endfor
         
         layer_delta_theta = theta_ss_h(top_of_layer_i[0:omaxlayer-1])-theta_ss_h(bottom_of_layer_i[0:omaxlayer-1])
         ;print, layer_info_heights 
    endif else begin
        print, 'There are no layers'
        omaxlayer = 1 ; set everything to missing
        return, pblh
    endelse
    
    ;===================================================================================================================
    ; Return the best pblh which is the lowest that meets both the criteria.  If the middle layer
    ; is -9999.0, it does not meet the 2k temp criteria.
    ;===============================================================================================
    
    x3=where(finite(layer_info_heights) eq 0,nx)
    if nx gt 0 then layer_info_heights(x3)=MISSING
    
    x4=where(layer_info_heights(ml_index,*) ne MISSING,nx)
    
    if nx gt 0 then begin
      pblh=layer_info_heights(ml_index,x4(0))
    endif
    
    ;Resetting omaxlayer based on numlayers so we do not need these lines.
    ;if (numlayers lt omaxlayer) then begin 
    ;     all_layer_heights = layer_info_heights(*,0:numlayers-1)
    ;     otoplayer[0:numlayers-1] = layer_info(top_index, 0:numlayers-1)
    ;     obotlayer[0:numlayers-1]  = layer_info(bottom_index, 0:numlayers-1)
    ;endif else begin
         all_layer_heights = layer_info_heights(*,0:numlayers-1)
         otoplayer[0:omaxlayer-1] = layer_info(top_index, 0:omaxlayer-1)
         obotlayer[0:omaxlayer-1]  = layer_info(bottom_index, 0:omaxlayer-1)
    ;endelse 
return, pblh
END
