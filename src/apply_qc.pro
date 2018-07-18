FUNCTION APPLY_QC, $
         variable, $
         qc_variable, $
         MISSING
  if n_elements(variable) gt 1 then begin
    index = where(qc_variable ne 0L, count)
    if (count ne 0) then variable[index] = MISSING
    ;variable *= ([1,!VALUES.F_NAN])[qc_variable ne 0L]
  endif
  
  return, variable
END

