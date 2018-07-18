PRO apply_min_max_sonde, ipres, irh, idp, itdry, iwspd
;This routine applies the min and max for sonde a1 levels    
; since they do not have qc variables.
COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT
index = where (ipres lt 0 or ipres gt 1100, count) 
if (count ne 0) then $
    ipres[index] = MISSING
index = where(irh lt 0 or irh gt 100, count) 
if (count ne 0) then $
    irh[index] = MISSING
index= where(idp lt -110 or idp gt 50, count) 
if (count ne 0) then $
    idp[index] = MISSING
;Min used to be -80 in 2004 and then changed to -90
index = where (itdry lt -90L or itdry gt 50, count) 
if (count ne 0) then $
    itdry[index] = MISSING
index = where (iwspd lt 0 or iwspd gt 100, count) 
if (count ne 0) then $
    iwspd[index] = MISSING

END

