FUNCTION CALCULATE_THETA, tdry, pres, tk, alt_var
COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT
    theta = !values.f_nan
    ; Potential temperature based on initial pressure of 1000mb
     theta = (tdry + tk) * (1000.0/pres)^0.286
        
     ind_ht = where(alt_var gt max_pbl_ht, nt)    
     if (nt ne 0) then begin
         min_ht = min(ind_ht)
         is_bad = where(finite(theta[0:min_ht-1]) eq 0, nx)
         if (nx gt 0) then begin
             theta[is_bad] = MISSING
         endif
         ;Change all the NaNs to MISSING inany case.
         is_bad = where(finite(theta) eq 0, nx)
         if (nx gt 0) then theta[is_bad] = MISSING
     endif
   
return, theta
END
