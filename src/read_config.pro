PRO READ_CONFIG, conf_path, vapname, site, facility, ds
COMMON THRESHOLDS, inv_strength_thres, instab_threshold, overshoot_threshold
COMMON GLOBAL_VARS, MISSING, MAX_PBL_HT
  conf_file = conf_path  + path_sep() + site + path_sep() + site + vapname + facility
  print, 'The config path is ', conf_path
  filename = conf_file+ path_sep() + site + vapname + facility + '.conf'

  files = file_search(filename, count=count)
  if(count lt 1) then ds.abort, 'No Config file found in this path  ' + filename


  nlines = file_lines(filename)
  if nlines eq 0  then ds.abort, 'Could not find the file with info.'
  buff=strarr(nlines)
  openr,unit,filename,/get_lun
  readf,unit,buff
  free_lun,unit


  parts = strsplit(buff[0], ',', /extract)
  inv_strength_thres  = float(parts[1])
  ;print, inv_strength_thres
  parts = strsplit(buff[1], ',', /extract)
  instab_threshold  = float(parts[1])
  ;print, instab_threshold
  parts = strsplit(buff[2], ',', /extract)
  overshoot_threshold  = float(parts[1])
  ;print, overshoot_threshold

  if (inv_strength_thres eq MISSING) or ( instab_threshold eq MISSING) or $
     (overshoot_threshold eq MISSING) then ds.abort, 'Could not find calib info.'
END
