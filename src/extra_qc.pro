FUNCTION extra_qc, pbl_var, oqc_pbl_var 
COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT
qc = qc_bits_pbl()
if (pbl_var gt max_pbl_ht) then begin
    pbl_var = MISSING
    oqc_pbl_var= oqc_pbl_var or qc[7].value 
    ;print, 'I am here with max hit the threshold'
endif
RETURN, oqc_pbl_var
END
