PRO COMMON_PBL

  COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT 
   MISSING = -9999.
   MAX_PBL_HT = 4000.
  COMMON VAR_CONST, cpd, rv, rd, g, tk
   cpd = 1005.7	       ; specific heat capacity
   rv = 461.0	       ; gas constant water vapor
   rd = 287.04	       ; gas constant dry air
   g=9.81
   tk = 273.0

  COMMON THRESHOLDS, inv_strength_thres, instab_threshold, overshoot_threshold 
   ;Default set in the globals.  Reset based on the site and facility in pbl.pro
   inv_strength_thres = MISSING ;units K
   instab_threshold = MISSING  ;units K
   overshoot_threshold = MISSING ;units K/km  
   regime_type = 'Missing' 
  ; Globals
  COMMON SUBSAMP, SUBSAMPLE_INTERVAL_MB, gPRES_GRID, gLAPSE_RATE, gSMOOTHED_LAPSE_RATE, gHEIGHT, $ 
                  gTHETA, gPRES, gLAPSE_MASK, gWSPD, gWDIR, gRH, gTDRY, SUBSAMPLED_HEIGHTS

   subsample_interval_mb=5.
   ;subsampled_profile_indices
   gPRES_GRID = 0
   gLAPSE_RATE =1
   gSMOOTHED_LAPSE_RATE =2
   gHEIGHT =3
   gTHETA = 4
   gPRES =5
   gLAPSE_MASK =6
   gWSPD = 7
   gWDIR = 8
   gRH =9
   gTDRY =10
   subsampled_heights = 0 

  COMMON DOD, dod_filename, dod_version , vapname, process_version
   vapname = 'pblhtsonde1mcfarl'
   dod_filename = vapname + '-c1-0.69.dod'
   dod_version  = 0.69
   process_version  = 1.0 
  COMMON PBL_HT, oheftter , obotlayer, otoplayer, omaxlayer, layer_smoothed_lapse, layer_delta_theta
   omaxlayer = 5
   obotlayer=FLTARR(omaxlayer)
   otoplayer=FLTARR(omaxlayer)
   layer_smoothed_lapse = FLTARR(omaxlayer)
   layer_delta_theta = FLTARR(omaxlayer)
   obotlayer[*] = MISSING
   otoplayer[*] = MISSING
   layer_smoothed_lapse[*] = MISSING
   layer_delta_theta[*]= MISSING
END
