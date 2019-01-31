;+
;********************************************************************************
;
;  Author:
;     name:  
;     phone: 
;     email: 
;
;*******************************************************************************
;
;  REPOSITORY INFORMATION:
;    $Revision: 1.11 $
;    $Author: sivaraman $
;    $Date: 2013-08-01 19:52:55 $
;    $State: Exp $
;
;*******************************************************************************
;
;  NOTE: DOXYGEN is used to generate documentation for this file.
;
;******************************************************************************
;   @file pblhtsonde_vap_hooks.pro
;   pblhtsonde VAP Hook Functions.
;
; A single object is used to handle all hooks in this example.
; Execution starts below the class definition function.
; Calling syntax:
;  IDL> .run test_hook_obj

;*  Initialize the process.
;*
;* This function is used to do any up front process initialization that
;* is specific to this process, and to create the UserData structure that
;* will be passed to all hook functions.
;*
;* If an error occurs in this function it will be appended to the log and
;* error mail messages, and the process status will be set appropriately.
;*
;*
;*
; *Init hook
;* @param ds {in}{required}{type=dsproc}
;*         Object reference to the dsproc system.
;* @returns
;*         1 to continue, 0 to abort further processing
;-
 
function pblhtsonde_hooks::init_process_hook, ds
    compile_opt idl2, logical_predicate

    if ds.debug gt 0 then print, '==== Inside init hook ===='

    ; Declare and populate user data structure wtih initial values
    userdata = {mydata, $
        bbss_dsid_a1:0L, $
        bbss_dsid_b1:0L, $
        pblht_dsid:0L $
    }
    
    ; Get Id of input datastream
    dsid_in = ds.get_input_datastream_id(dsc_name='sondewnpn',dsc_level='b1')
    if ds.debug gt 0 then print, 'dsid_in: ',dsid_in
    
    if dsid_in lt 0 then return, 0
    userdata.bbss_dsid_b1 = dsid_in
    
    dsid_in = ds.get_input_datastream_id(dsc_name='sondewnpn', dsc_leve='a1')
    if ds.debug gt 0 then print, 'dsid_in: ', dsid_in
    
    if dsid_in lt 0 then return, 0
    userdata.bbss_dsid_a1 = dsid_in
    
    ;if dsid_in le 0 then begin
        ;dsid_in = ds.get_input_datastream_id(dsc_name='sondewnpn',dsc_level='a1')
        ;if ds.debug gt 0 then print, 'dsid_in: ',dsid_in
        ;userdata.bbss_dsid_a1 = dsid_in
        ; Sonde data is stored as one file or launch per 'observation'
        ; We want to load all complete observations that begin within
        ; the current processing interval.
        ;ds.set_datastream_flags, userdata.bbss_dsid_a1, ds_preserve_obs = 'DS_PRESERVE_OBS'
    ;endif else begin
        ;userdata.bbss_dsid_b1 = dsid_in
        ; Sonde data is stored as one file or launch per 'observation'
        ; We want to load all complete observations that begin within
        ; the current processing interval.
        ;ds.set_datastream_flags, userdata.bbss_dsid_b1, ds_preserve_obs = 'DS_PRESERVE_OBS'
    ;endelse
    
    ;if dsid_in le 0 then return, 0 
    
    ds.set_datastream_flags, userdata.bbss_dsid_b1, ds_preserve_obs = 'DS_PRESERVE_OBS'
    ds.set_datastream_flags, userdata.bbss_dsid_a1, ds_preserve_obs = 'DS_PRESERVE_OBS'

    ; Get the ID of the output datastream
    userdata.pblht_dsid = ds.get_output_datastream_id(dsc_name='pblhtsonde1mcfarl',$
            dsc_level='c1')
    if userdata.pblht_dsid lt 0 then return, 0
    dsid = userdata.pblht_dsid

    
    ; make user data globally available 
    ds.userdata = userdata

    
    ; 1=continue, 0=abort.
    return, 1

end

;+
;*  Finish the process.
; 
;*  This function frees all memory used by the UserData structure.
;*  @param ds {in}{required}{type=dsproc}
;*          Object reference to the dsproc system.
;*  @returns
;*          The return value is ignored by the caller
;*
;-
function pblhtsonde_hooks::finish_process_hook, ds
    compile_opt idl2, logical_predicate

    if ds.debug gt 0 then begin
        print, '==== Inside finish hook ===='
        print, 'Userdata: ',ds.userdata
    endif

    ; Insert finish process code here

    return, 1
end

;+
;*  Hook function called just after data is retrieved.
;*
;*  This function will be called once per processing interval just after data
;*  retrieval, but before the retrieved observations are merged and QC is applied.
;*
;   @param ds {in}{required}{type=dsproc}
;           Object reference to the dsproc system.
;   @param interval {in}{required}{type=long64}
;           An array of long64 integers on the form: [ begin_time, end_time ]
;           Times are seconds since 1-Jan-1970.
;   @param ret_data {in}{required}{type=CDSGroup}
;           Object reference to the CDSGroup retrieved data.
;   @returns
;*          1 to continue, 
;*          -1 to abort further processing,
;*          0 to continue to next processing interval
;-
function pblhtsonde_hooks::post_retrieval_hook, ds, interval, ret_data
    compile_opt idl2, logical_predicate

    if ds.debug gt 0 then begin
        print, '==== Inside post-retrieval hook ===='
        print, 'Site: ',ds.site
        print, 'Facility: ',ds.facility
        print, 'Userdata: ',ds.userdata
        print, 'Begin time: ', systime(0, interval[0])
        print, 'End time: ', systime(0, interval[0])
        help, ret_data
    endif

    
    obs_index = 0 
    use_a1 = 0
    while obs_index ge 0 do begin
        
        ; Get the next BBSS dataset
        bbss = ds.get_retrieved_dataset(ds.userdata.bbss_dsid_b1, $
               obs_index)
               
        if ((use_a1 eq 1) or (obs_index eq 0 and ~obj_valid(bbss))) then begin
            use_a1 = 1
            bbss = ds.get_retrieved_dataset(ds.userdata.bbss_dsid_a1, $
                   obs_index)
                   
            if ~bbss then begin
                if ds.debug gt 0 then begin
                    print, 'breaking with obs = ', obs_index+1
                endif
                break ; no more observations found
            endif
        endif else begin
            if ~bbss then begin
                if ds.debug gt 0 then begin
                    print, 'breaking with obs = ', obs_index+1
                endif

                break ; no more observations found
            endif
        endelse
               
        obs_index=obs_index+1

        if ds.debug gt 0 then begin
            print, '---------- PROCESSING OBSERVATION #', $
            obs_index + 1, bbss.name
        endif

        ; Get the sample times for this observation
        nbbss_ntimes = 0
        bbss_times = bbss.get_sample_times(0,count=bbss_ntimes,double=1)
        if ~bbss_ntimes then return, -1

        if ds.debug gt 0 then begin
            print,  'number of times= ', bbss_ntimes
            print,  'time of first sample= ', long64(bbss_times[0])
            print,  'time of last sample= ', long64(bbss_times[bbss_ntimes-1])
            print, 'base_time  bbss =', bbss.base_time
        endif

        ; Create the output dataset
        ; Set location is set to zero so that the user can enter lat/lon
        ; they see fit.
        pblht = ds.create_output_dataset(ds.userdata.pblht_dsid,$
                bbss_times[0], set_location = 1)

        ; Map data from input datset to the output dataset

        ds.set_map_time_range,bbss_times[0],bbss_times[bbss_ntimes-1]+1
        
        status = ds.map_datasets(bbss, pblht, 0);
        if status eq 0 then return, -1
        
        ; ---------------------------------------------- 
        ; ------Start algorithm------------------------
        ; ----------------------------------------------

        ; Your code here
        COMMON_PBL
        COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT
        COMMON VAR_CONST, cpd, rv, rd, g, tk
        COMMON SUBSAMP, SUBSAMPLE_INTERVAL_MB, gPRES_GRID, gLAPSE_RATE, gSMOOTHED_LAPSE_RATE, gHEIGHT, $ 
                      gTHETA, gPRES, gLAPSE_MASK, gWSPD, gWDIR, gRH, gTDRY, SUBSAMPLED_HEIGHTS
        COMMON THRESHOLDS, inv_strength_thres, instab_threshold, overshoot_threshold, regime_type
        COMMON PBL_HT, oheftter , obotlayer, otoplayer, omaxlayer, layer_smoothed_lapse, layer_delta_theta
         
        conf_data_home = getenv("CONF_DATA")
        if(n_elements(conf_data_home) eq 0) then begin
          if ds.debug gt 0 then print, '      *** CONF_DATA is not defined - quitting ABNORMALLY'
          ds.abort, 'No conf_data environment variable set.'
        endif
        ;Need to talk to Krista to see if we should not hard code this vapname
        read_config, conf_data_home, 'pblhtsonde1mcfarl', ds.site, ds.facility, ds
        
        ;Should the observation be increased.
        irh= bbss.get_var('rh')
        ipres = bbss.get_var('pres')
        idp = bbss.get_var('dp')
        itdry = bbss.get_var('tdry')
        iwspd = bbss.get_var('wspd')
        iwdir = bbss.get_var('deg')
        ialt = bbss.get_var('alt')
       
        
        irh_var = irh.data
        ipres_var = ipres.data
        idp_var = idp.data
        itdry_var = itdry.data
        iwspd_var = iwspd.data
        iwdir_var = iwdir.data
        ialt_var = ialt.data
      
      
        
        nsamples = irh.sample_count
        nvars_out = n_elements(self->output_fields('pblhtsonde1mcfarl_c1'))
        if ds.debug gt 0 then print, nvars_out, 'Number of vars in output', obs_index, nsamples
       
    
        pres_grid_index    = self->output_fields('pblhtsonde1mcfarl_c1', 'pressure_gridded')
        lapse_ss_index    = self->output_fields('pblhtsonde1mcfarl_c1', 'lapserate_theta_ss')
        smoothed_lapse_ss_index    = self->output_fields('pblhtsonde1mcfarl_c1', 'lapserate_theta_smoothed')
        bar_pres_ss_index    = self->output_fields('pblhtsonde1mcfarl_c1', 'atm_pres_ss')
        theta_ss_index    = self->output_fields('pblhtsonde1mcfarl_c1', 'theta_ss')
        ;heightm_ss_index    = self->output_fields('pblhtsonde1mcfarl_c1', 'height_ss')
        wspd_ss_index    = self->output_fields('pblhtsonde1mcfarl_c1', 'wspd_ss')
        br_profile_index    = self->output_fields('pblhtsonde1mcfarl_c1', 'richardson_number')
        thetav_index    = self->output_fields('pblhtsonde1mcfarl_c1', 'virtual_theta_ss')
        layer_delta_theta_index    = self->output_fields('pblhtsonde1mcfarl_c1', 'delta_theta_max')
       
        opres      = pblht.get_var("atm_pres")
        otdry      = pblht.get_var("air_temp")
        owspd      = pblht.get_var("wspd")
        orh        = pblht.get_var("rh")
        oheffter   = pblht.get_var("pbl_height_heffter")
        oregime    = pblht.get_var("pbl_regime_type_liu_liang")
        oll_pbl    = pblht.get_var("pbl_height_liu_liang")
        obr_pt25   = pblht.get_var("pbl_height_bulk_richardson_pt25")
        obr_pt5    = pblht.get_var("pbl_height_bulk_richardson_pt5")
        oobotlayer = pblht.get_var("bottom_inversion")
        ootoplayer = pblht.get_var("top_inversion")
        olayer_smoothed_lapse = pblht.get_var("lapserate_max")
        oll_level1 = pblht.get_var("level_1_liu_liang")
        oll_level2 = pblht.get_var("level_2_liu_liang")
        oheightm_ss = pblht.get_var("height_ss")
        ;oheightm_smoothed = pblht.get_var("height_smoothed")
        
        opres_grid = pblht.get_var(self->output_fields('pblhtsonde1mcfarl_c1', pres_grid_index))
        olapse_ss = pblht.get_var(self->output_fields('pblhtsonde1mcfarl_c1', lapse_ss_index))
        osmoothed_lapse_ss = pblht.get_var(self->output_fields('pblhtsonde1mcfarl_c1', smoothed_lapse_ss_index))
        obar_pres_ss = pblht.get_var(self->output_fields('pblhtsonde1mcfarl_c1', bar_pres_ss_index))
        otheta_ss = pblht.get_var(self->output_fields('pblhtsonde1mcfarl_c1', theta_ss_index))
        owspd_ss = pblht.get_var(self->output_fields('pblhtsonde1mcfarl_c1', wspd_ss_index))
        obr_profile = pblht.get_var(self->output_fields('pblhtsonde1mcfarl_c1', br_profile_index))
        othetav = pblht.get_var(self->output_fields('pblhtsonde1mcfarl_c1', thetav_index))
        olayer_delta_theta = pblht.get_var(self->output_fields('pblhtsonde1mcfarl_c1', layer_delta_theta_index))         
        olayer  = pblht.get_dim("layer")
        
      
                
        ; Creates values with zero
        orh_var = make_array(nsamples, type=irh.type)
        otdry_var = make_array(nsamples, type=itdry.type)
        opres_var = make_array(nsamples, type=ipres.type)
        owspd_var = make_array(nsamples, type=iwspd.type)
        odp_var   = make_array(nsamples, type= idp.type)
        owspd_var = make_array(nsamples, type=iwdir.type)
        
        pres_grid = make_array(1,  /FLOAT, VALUE = MISSING)
        lapse_ss = make_array(1,  /FLOAT, VALUE = MISSING)
        smoothed_lapse_ss = make_array(1,  /FLOAT, VALUE = MISSING)
        bar_pres_ss = make_array(1,  /FLOAT, VALUE = MISSING)
        theta_ss = make_array(1,  /FLOAT, VALUE = MISSING)
        heightm_ss = make_array(1,  /FLOAT, VALUE = MISSING)
        wspd_ss = make_array(1,  /FLOAT, VALUE = MISSING)
        br_profile = make_array(1,  /FLOAT, VALUE = MISSING)
        thetav = make_array(1,  /FLOAT, VALUE = MISSING)
        obotlayer = make_array(5,  /FLOAT, VALUE = MISSING)
        otoplayer = make_array(5,  /FLOAT, VALUE = MISSING)
        layer_smoothed_lapse = make_array(5,  /FLOAT, VALUE = MISSING)
        layer_delta_theta = make_array(5,  /FLOAT, VALUE = MISSING)
        opblh_alt = make_array(1,  /FLOAT, VALUE = MISSING)
      
        
    
        ;--Apply qc and do not do any calculations.
        bad_sonde = 0
        ;Need get_time_var for detect bad sonde to work
        to_var = make_array(nsamples, /DOUBLE, VALUE = 0)
        to_var = irh.time_var.data
    
        MAX_PBL_HT = MAX_PBL_HT + ialt_var[0]
        if ds.debug gt 0 then print, 'The maximum pbl height is set to ', max_pbl_ht
        ;This is site specific
        status = oheffter.set_att('valid_max',max_pbl_ht)
        if status eq 0 then return, -1
        status = oll_pbl.set_att('valid_max',max_pbl_ht)
        if status eq 0 then return, -1
        status = obr_pt25.set_att('valid_max',max_pbl_ht)
        if status eq 0 then return, -1
        status = obr_pt5.set_att('valid_max',max_pbl_ht)
        if status eq 0 then return, -1
        
        status = oheffter.set_att('valid_min',ialt_var[0])
        if status eq 0 then return, -1
        status = oll_pbl.set_att('valid_min',ialt_var[0])
        if status eq 0 then return, -1
        status = obr_pt25.set_att('valid_min',ialt_var[0])
        if status eq 0 then return, -1
        status = obr_pt5.set_att('valid_min',ialt_var[0])
        if status eq 0 then return, -1
        
        
        
        ; Test for bad sonde is 20040420
        ; testing on the input values.
        bad_sonde = detect_bad_sonde(itdry_var, ialt_var, ipres_var, to_var, oqc, ds)
        
        if (bad_sonde) then begin
            ;Perhaps we should not write this out at all.
            goto, write_output
            ;nstored = ds.store_dataset(0, newfile = TRUE)
            ;continue ; To next observation
        endif
       
        
         ;The .a1 dataset does not have qc for input variables.
        iqc_rh_var = make_array(nsamples, /INTEGER, VALUE = 0)
        iqc_dp_var = make_array(nsamples, /INTEGER, VALUE = 0)
        iqc_pres_var = make_array(nsamples, /INTEGER, VALUE = 0)
        iqc_wspd_var = make_array(nsamples, /INTEGER, VALUE = 0)
        iqc_wdir_var = make_array(nsamples, /INTEGER, VALUE = 0)
        iqc_tdry_var = make_array(nsamples, /INTEGER, VALUE = 0)
        
        ;For .b1 data where there are qc's available
        if (irh.qc_var) then begin
            iqc_rh_var = irh.qc_var.data
            iqc_dp_var = idp.qc_var.data
            iqc_pres_var = ipres.qc_var.data
            iqc_wspd_var = iwspd.qc_var.data
            iqc_wdir_var = iwdir.qc_var.data
            iqc_tdry_var = itdry.qc_var.data
            
            orh_var = apply_qc(irh_var, iqc_rh_var, MISSING)
            odp_var   = apply_qc(idp_var, iqc_dp_var, MISSING)
            opres_var = apply_qc(ipres_var, iqc_pres_var, MISSING)
            owspd_var = apply_qc(iwspd_var, iqc_wspd_var, MISSING)
            owdir_var = apply_qc(iwdir_var, iqc_wdir_var, MISSING)
            otdry_var = apply_qc(itdry_var, iqc_tdry_var, MISSING)
            
        endif else begin
            ;filter values that do not meet min and max values  for a1 data
            ;CHITRA Need to check if this happens
            apply_min_max_sonde, ipres_var, irh_var, idp_var, itdry_var, iwspd_var
            orh_var   = irh_var
            odp_var   = idp_var
            opres_var = ipres_var
            owspd_var = iwspd_var
            owdir_var = iwdir_var
            otdry_var = itdry_var
        endelse
        
      
        ;Apply QC 
        qc = qc_bits_pbl()
        
        
        ;Do another check to make sure that the surface pressure is accurate.
        ;There could be some qc's that change the value to -9999
        ;Case of 20040420 at SGP C1
        x1 = where(opres_var[1] lt 0, ncount)
        if (ncount gt 0) then begin
            oqc = oqc or qc[6].value
            if ds.debug gt 0 then print,'The pressure value is not valid to do the subsampling. Found a bad sonde. ', opres_var[1]
            bad_sonde=1
            goto, write_output
        endif
        
        ;This is not a bad sonde but just filtering out bad windspeed data
        ; very close to the surface. Not setting the quality check yet.
        ; May 01, 2013 Elaine
        alt50 = where(ialt_var lt ialt_var[0]+50., count)
        if (count ne 0) then begin
            index = where (owspd_var[0:count-1] gt 33.5, ncount)
            if (ncount ne 0) then begin
                owspd_var[index] = MISSING
                ;Not setting the qc value because it could be an artifact of the sonde launch
            endif
        endif
        
        ;All input values have been filtered for bad data.
        ; Calculate potential temperature
        theta = calculate_theta(otdry_var, opres_var, tk, ialt_var)
        ;Converting to kelvin temperature
        odpk_var = odp_var + tk
        otdryk_var = otdry_var + tk ; This is t in Tami's code
        
        ;Calculate the subsampled profile of height, theta and wspd.
        subsampled_profile = sub_sampling(opres_var, ialt_var, theta, owspd_var, owdir_var, $
                                         orh_var, otdryk_var)
      
        num = n_elements(reform(subsampled_profile[0,*]))
        pres_grid   = subsampled_profile[gPRES_GRID, *] ;0
        heightm_ss  = subsampled_profile[gHEIGHT,*] ;3
        theta_ss    = subsampled_profile[gTHETA,*]  
        bar_pres_ss = subsampled_profile[gPRES,*]
        wspd_ss     = subsampled_profile[gWSPD,*]
        wdir_ss     = subsampled_profile[gWDIR,*]
        rh_ss       = subsampled_profile[gRH,*]
        tdryk_ss    = subsampled_profile[gTDRY,*]
        
        ;Calculate the profile of lapse rate and smoothed lapse rate
        subsampled_profile = smooth_profile(subsampled_profile,lapse_ss, $
                                        theta_ss, heightm_ss, bar_pres_ss)
        lapse_ss = subsampled_profile[gLAPSE_RATE,*] ;1
        smoothed_lapse_ss = subsampled_profile[gSMOOTHED_LAPSE_RATE,*] ;2
    
        index = where(lapse_ss lt -0.5 or lapse_ss gt 0.5, count)
        if (count ne 0) then begin
            lapse_ss[index] = MISSING
        endif
        index = where(smoothed_lapse_ss lt -0.5 or smoothed_lapse_ss gt 0.5, count)
        if (count ne 0) then begin
            smoothed_lapse_ss[index] = MISSING
        endif
        
        pres_grid = reform(pres_grid[0,*])
        lapse_ss  = reform(lapse_ss[0,*])
        smoothed_lapse_ss = reform(smoothed_lapse_ss[0,*])
        theta_ss = reform(theta_ss[0,*])
        bar_pres_ss = reform(bar_pres_ss[0,*])
        wspd_ss = reform(wspd_ss[0,*])
        wdir_ss = reform(wdir_ss[0,*])
        rh_ss   = reform(rh_ss[0,*])
        tdryk_ss = reform(tdryk_ss[0,*])
    
        
        ;Calculate the lapse rate mask inside heffter routine   
        lapse_rate_mask = make_array(SUBSAMPLED_HEIGHTS, /FLOAT, VALUE = 0)
     
        
        ;Calculate heffter PBL
        oheffter_var = heffter(lapse_rate_mask,smoothed_lapse_ss,heightm_ss,theta_ss, opblh_alt)
        subsampled_profile[gLAPSE_MASK,*] = lapse_rate_mask
        
        nht = SUBSAMPLED_HEIGHTS
        ; Initialized the ll_level1 and ll_level 2 in liu_liang method.
        oregime_var = liu_lang_calc(oll_pbl_var, ll_level1, ll_level2, theta_ss, heightm_ss,wspd_ss, ialt_var[0])
        
        obr_pt25_var = bulk_richardson(heightm_ss, bar_pres_ss, wdir_ss, wspd_ss, $
                              rh_ss,tdryk_ss, obr_pt5_var, br_profile, thetav)
        
         ;--Apply extra_qc
        oqc_regime  = oqc
        oqc_oll_pbl = oqc
        oqc_heffter = oqc
        oqc_br_pt25 = oqc
        oqc_br_pt5 =  oqc
        ;Case of 20110805.117270 where the regime type is NRL but the 
        ; ss_heightm-ht0 not greater than 150 in liu liang calculation.
        ;if (oll_pbl_var eq MISSING) then begin
            ;oqc_oll_pbl = oqc_oll_pbl or qc[10].value
        ;endif
        
        oqc_oll_pbl = extra_qc(oll_pbl_var,oqc_oll_pbl)
        oqc_heffter = extra_qc(oheffter_var,oqc_heffter)
        
        
       
        
        ; If both criteras are not met for heffter, set the pbl to alternate when only
        ; one criteria is met.
        ; We dont want to set the QC because on 20110928, the heffter height is above the maximum
        ; which sets the oqc_heffter to bad and then we set the pbl to alternate which sets the 
        ; oqc_heffter to indeterminate which is bit 7
        ; On October 11, 2010: 172900, the heffter routine returns -9999, so we need to set the alternate
        ; pblh_alt instead. changing the if statement to or instead of and.
        
        bit7 = oqc_heffter and qc[7].value
        if ((oheffter_var eq MISSING) or (bit7 eq qc[7].value)) then begin
            oheffter_var = opblh_alt
            if (oheffter_var gt max_pbl_ht) then begin      
                ;Cases where pblh_alt exceeds valid maximum pbl height.
                oqc_heffter = extra_qc(oheffter_var, oqc_heffter)
            endif else begin
                oqc_heffter = qc[9].value
            endelse
            
            ;Need to reform so it is an array
            oqc_heffter = reform(oqc_heffter)
        endif

        
        
        oqc_br_pt25 = extra_qc(obr_pt25_var,oqc_br_pt25)
        oqc_br_pt5 = extra_qc(obr_pt5_var,oqc_br_pt5)
        
        
        br_profile           = replace_nans_with_missing(reform(br_profile), missing)
        thetav               = replace_nans_with_missing(thetav, missing)
        pres_grid            = replace_nans_with_missing(pres_grid, missing)
        lapse_ss             = replace_nans_with_missing(lapse_ss,missing) 
        smoothed_lapse_ss    = replace_nans_with_missing(smoothed_lapse_ss,missing) 
        theta_ss             = replace_nans_with_missing(theta_ss,missing) 
        bar_pres_ss          = replace_nans_with_missing(bar_pres_ss,missing)
        wspd_ss              = replace_nans_with_missing(wspd_ss, missing)
        wdir_ss              = replace_nans_with_missing(wdir_ss, missing)
        rh_ss                = replace_nans_with_missing(rh_ss, missing)
        tdryk_ss             = replace_nans_with_missing(tdryk_ss, missing)
        heightm_ss           = replace_nans_with_missing(heightm_ss[0,*], missing)
        ;heightm_smoothed    = replace_nans_with_missing(heightm_smoothed[0,*], missing)
        layer_smoothed_lapse = replace_nans_with_missing(layer_smoothed_lapse, missing)
        layer_delta_theta    = replace_nans_with_missing(layer_delta_theta,missing)
        ll_level1            = replace_nans_with_missing(ll_level1, missing)
        ll_level2            = replace_nans_with_missing(ll_level2, missing)
        oheffter_var         = replace_nans_with_missing(oheffter_var, missing)
        oll_pbl_var          = replace_nans_with_missing(oll_pbl_var, missing)
        obr_pt25_var         = replace_nans_with_missing(obr_pt25_var, missing)
        obr_pt5_var          = replace_nans_with_missing(obr_pt5_var, missing)
        oregime_var          = replace_nans_with_missing(oregime_var, missing)
        
        ;Checking to make sure that the pbl's are not missing and the qc is not set
        ; Catch it all QC. pbl_liu_liang for 20110805.172700.
        
        if (oheffter_var eq MISSING) and (oqc_heffter eq 0) then begin
            oqc_heffter = oqc_heffter or qc[8].value
        endif
        
  
        if (oll_pbl_var eq MISSING) and (oqc_oll_pbl eq 0) then begin
            oqc_oll_pbl = oqc_oll_pbl or qc[8].value
        endif
        
        if (obr_pt25_var eq MISSING) and (oqc_br_pt25 eq 0) then begin
            oqc_br_pt25 = oqc_br_pt25 or qc[8].value
        endif
        
        if (obr_pt5_var eq MISSING) and (oqc_br_pt5 eq 0) then begin
            oqc_br_pt5 = oqc_br_pt5 or qc[8].value
        endif
        
        if (oregime_var eq MISSING) and (oqc_regime eq 0) then begin
            oqc_regime = oqc_regime or qc[8].value
        endif
        
        
        ; ---------------------------------------------- 
        ; ------End algorithm------------------------
        ; ----------------------------------------------
        
        ;Plot the data
        
        if (bad_sonde eq 0 ) then begin
        
            datadir = getenv("DATASTREAM_DATA")
            qldir =  getenv("QUICKLOOK_DATA")
            obs_time= long64(bbss_times[0])
            caldat,julday(1,1,1970,0,0,obs_time), mm, dd, yy, hh, min, ss
            date = string(yy,mm,dd,format='(I4.4,2I2.2)') + '.' + $
                string (hh,min, ss, format='(I2.2, 2I2.2)') 
            if ds.debug gt 0 then print, datadir, qldir, date
           ;--Plot the PBL
            out_datastream = pblht.name
            pngpath = qldir+path_sep()+ds.site+path_sep()+out_datastream+path_sep() + $
                string(yy,mm,dd,format='(I4.4,"/",I2.2,"/",I2.2)')

            
            pngfile = STRJOIN([out_datastream,date,'heffter_pbl','png'],'.')
            pngpath_file = pngpath + path_sep() + pngfile
            if (~file_test(pngpath,/directory)) then file_mkdir,pngpath
            
            pbl_plot_heft, pres_grid, lapse_ss, smoothed_lapse_ss, heightm_ss, theta_ss, $
                     oheffter_var, otoplayer, obotlayer , date, pngpath_file, out_datastream
        
            pngfile = STRJOIN([out_datastream,date,'ll_pbl','png'],'.')
            pngpath_file = pngpath + path_sep() + pngfile
            pbl_plot_ll, theta_ss, heightm_ss, wspd_ss, ll_level1, ll_level2, oll_pbl_var,regime_type, date, pngpath_file, out_datastream

            pngfile = STRJOIN([out_datastream,date,'ll_pbl_lapse','png'],'.')
            pngpath_file = pngpath + path_sep() + pngfile
            
            pbl_plot_ll_lapse, theta_ss, heightm_ss, smoothed_lapse_ss, ll_level1, ll_level2, $
                              oll_pbl_var,regime_type, date, pngpath_file, out_datastream
            
            pngfile = STRJOIN([out_datastream,date,'br_pbl','png'],'.')
            pngpath_file = pngpath + path_sep() + pngfile
            pbl_plot_br, theta_ss, heightm_ss, obr_pt25_var, obr_pt5_var,  br_profile, thetav,date, pngpath_file, out_datastream

            pngfile = STRJOIN([out_datastream,date,'all_pbl','png'],'.')
            pngpath_file = pngpath + path_sep() + pngfile
            pbl_plot, pres_grid, lapse_ss, smoothed_lapse_ss, heightm_ss, theta_ss, $
                     oheffter_var, oll_pbl_var, obr_pt25_var , date, pngpath_file, out_datastream
        endif
        
        write_output:
        
        ;This is being set so when the vap bails out due to bad sonde, the variables are
        ;set to -9999.
        
        ; Verify length was set correctly.  
        height_dim = pblht.get_dim('height_ss')
        if ~obj_valid(height_dim) then return, -1
        
        if (bad_sonde) then begin
            status = pblht.set_dim_length('height_ss', 1)
            if status eq 0 then return, -1
            ;status = pblht.set_dim_length('height_smoothed', 1)
            ;if status eq 0 then return, -1
            heightm_ss  = fltarr(1)
            heightm_ss[0]   = MISSING
            ;heightm_smoothed = fltarr(1)
            ;heightm_smoothed[0] = MISSING
            oheffter_var = MISSING
            oll_pbl_var = MISSING
            obr_pt25_var = MISSING
            obr_pt5_var  = MISSING
            oregime_var  = MISSING 
            ll_level1 = MISSING
            ll_level2 = MISSING
            oqc_heffter = oqc
            oqc_br_pt25 = oqc
            oqc_br_pt5  = oqc
            oqc_oll_pbl = oqc
            oqc_regime  = oqc
            
        endif else begin
            status = pblht.set_dim_length('height_ss', num)
            if status eq 0 then return, -1
            ;status = pblht.set_dim_length('height_smoothed', num)
            ;if status eq 0 then return, -1
        endelse
        
        
        status = pblht.set_att("inversion_strength_threshold", inv_strength_thres)
        if status eq 0 then return, -1
        status = pblht.set_att("instability_threshold", instab_threshold)
        if status eq 0 then return, -1
        status = pblht.set_att("overshoot_threshold", overshoot_threshold)
        if status eq 0 then return, -1
    
        olayer = pblht.get_var('layer')
        olayer_var = [1,2,3,4,5]
        olayer.data = olayer_var
        
        ;Reforming the variables since the CDSVar only accepts arrays
        oheffter_var = reform(oheffter_var)
        oll_pbl_var = reform(oll_pbl_var)
        obr_pt25_var = reform(obr_pt25_var)
        oregime_var = reform(oregime_var)
        ll_level1 = reform(ll_level1)
        ll_level2 = reform(ll_level2)
        oheightm_ss.data   = heightm_ss
        ;oheightm_smoothed.data = heightm_smoothed
        oheffter.data = oheffter_var
        oheffter.qc_var.data = reform(oqc_heffter)
        oll_pbl.data  = oll_pbl_var
        oll_pbl.qc_var.data = reform(oqc_oll_pbl)
        obr_pt25.data = obr_pt25_var
        obr_pt25.qc_var.data = reform(oqc_br_pt25)
        obr_pt5_var = reform(obr_pt5_var)
        obr_pt5.data  = obr_pt5_var
        obr_pt5.qc_var.data = reform(oqc_br_pt5)
        
        oregime.data  = oregime_var
        oregime.qc_var.data = oqc_regime  
        opres_grid.data = pres_grid
        olapse_ss.data  = lapse_ss
        
        osmoothed_lapse_ss.data   = smoothed_lapse_ss
        obar_pres_ss.data   = bar_pres_ss
        otheta_ss.data   = theta_ss
        
        owspd_ss.data   = wspd_ss
        obr_profile.data   = br_profile
        othetav.data  = thetav
        oobotlayer.data   = heightm_ss[obotlayer]
        ootoplayer.data   = heightm_ss[otoplayer]
        
        count = n_elements(layer_smoothed_lapse)
        ;Case 20110805.172700 when n_elements of lsl is lt than 5
        if (count lt 5) then begin
            temp_lsl = layer_smoothed_lapse
            temp_ldt = layer_delta_theta
            layer_smoothed_lapse = make_array(5,  /FLOAT, VALUE = MISSING)
            layer_delta_theta = make_array(5,  /FLOAT, VALUE = MISSING)
            for i =0, count-1 do begin 
                layer_smoothed_lapse[i] = temp_lsl[i]
                layer_delta_theta[i] = temp_ldt[i]
            endfor
        endif
        olayer_smoothed_lapse.data   = layer_smoothed_lapse
        olayer_delta_theta.data   = layer_delta_theta
        oll_level1.data   = ll_level1
        oll_level2.data   = ll_level2
        
       
        

        ;output to text file if debug is > 1
        if ds.debug gt 1 then begin
            void = dsproc_dump_output_datasets( $
                './debug_dumps', 'post_retrieval.debug', 0)
        endif

        ; Store the output dataset(s) 

        nstored = ds.store_dataset(0, newfile = TRUE)
        if(nstored eq 0)  then begin
            ds.debug, 2, 'store dataset has zero samples'
        endif
        if(nstored lt 0)  then begin
            ds.debug, 2, 'store dataset failed'
        endif
        if(nstored gt 0)  then begin
            ds.debug, 2, 'dataset successfully stored'
        endif

    ; Insert post-retrieval code here

    endwhile
    ; 1=continue, 0=abort.
    return, 0
end



;+
;*  Main data processing function.
;*
;*  This function will be called once per processing interval just after the
;*  output datasets are created, but before they are stored to disk.
;*
;*  @param ds {in}{required}{type=dsproc}
;*          Object reference to the dsproc system.
;*  @param interval {in}{required}{type=long64}
;*          An array of long64 integers on the form: [ begin_time, end_time ]
;*          Times are seconds since 1-Jan-1970.
;*  @param input_data {in}{required}{type=CDSGroup}
;*          Object reference to the CDSGroup input data.
;*  @returns
;*          1 to continue, 
;*          -1 to abort further processing,
;*          0 to continue to next processing interval
;-
function pblhtsonde_hooks::process_data_hook, ds, interval, input_data
    compile_opt idl2, logical_predicate

    if ds.debug gt 0 then begin
        print, '==== Inside process data hook ===='
        print, 'Userdata: ',ds.userdata
        print, 'Begin time: ', systime(0, interval[0])
        print, 'End time: ', systime(0, interval[0])
    endif

    ; Insert process data code here

    ; output to text file if debug is > 1
    if ds.debug gt 1 then begin
        void = dsproc_dump_output_datasets( $
            './debug_dumps', 'process_data.debug', 0)
    endif

    ; 1=continue, 0=abort.
    return, 1
end

;+
; Class definition
;
; User defined member variables can be defined below
;-
pro pblhtsonde_hooks__define
  compile_opt idl2, logical_predicate
  s={ pblhtsonde_hooks $
    , Inherits IDL_Object $
    }
end
