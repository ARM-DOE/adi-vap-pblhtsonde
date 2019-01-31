FUNCTION detect_bad_sonde, itdry_var, alt_var, ipres_var, to_var, oqc, ds
bad_sonde =0
qc = qc_bits_pbl()
 oqc       = make_array(1, /INTEGER, VALUE = 0)
   if (n_elements(itdry_var) le 1) then begin
       bad_sonde = 1
       oqc= oqc or qc[1].value

   endif

   if (max(alt_var) lt 1000) then begin 
       bad_sonde =  1
       oqc= oqc or qc[2].value
   endif
   if (max(ipres_var) le 200) then begin
       bad_sonde = 1
       oqc= oqc or qc[3].value
   endif
   ;Checking to make sure that the sonde has taken off and there are 
   ; finite temperature values
   x=where(to_var le 10L and finite(itdry_var) eq 1L,ncount)
   if (ncount ge 2) then begin
    if itdry_var(min(x))-itdry_var(max(x)) gt 30L then begin
      bad_sonde=1
      oqc = oqc or qc[4].value
      if ds.debug gt 0 then print,'Failed temp checks. Change of 30 degress in 10seconds of sounding'
    endif
   endif
   if max(itdry_var,/nan) gt 50L or min(itdry_var,/nan) lt -90L then begin
    bad_sonde=1
    oqc = oqc or qc[5].value
    if ds.debug gt 0 then print,'Failed min (<-90C) / max (>50C) temp checks.'
   endif
   if (n_elements(ipres_var) gt 2) then begin
     x1 = where(ipres_var[1] lt 0 or finite(ipres_var[1]) eq 0, ncount)
     if (ncount gt 0) then begin
      bad_sonde=1
      oqc = oqc or qc[6].value
      if ds.debug gt 0 then print,'The pressure value is not valid to do the subsampling."
     endif
   endif
return, bad_sonde
END
