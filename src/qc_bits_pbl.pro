function  qc_bits_pbl
  return,[{bit:1l, value:1l, description:'Data value not available in input file, data value set to -9999 in output file.',         assessment:'Bad'},$
          {bit:2l, value:2l, description:'Data does not have enough temperature values.', assessment:'Bad'},$
          {bit:3l, value:4l, description:'Sonde does not reach mimimum height of 1000 m', assessment:'Bad'},$
          {bit:4l, value:8l, description:'The pressure values are not greater than 200 hPa', assessment:'Bad'},$
          {bit:5l, value:16l, description:'Data failed temperature checks. There is a change of 30 degress in 10 seconds of sounding.',aassessment: 'Bad'},$
          {bit:6l, value:32l, description:'Failed min (<-90C) / max (>50C) temp checks', assessment:'Bad'},$
          {bit:7l, value:64l, description:'Failed the pressure value. Unable to do subsampling', assessment:'Bad'}, $
          {bit:8l, value:128l, description:'Planetary boundary layer greater than maximum height', assessment:'Bad'}, $
          {bit:9l, value:256l, description:'The 2k criteria is not met in calculating the heffer PBL', assessment:'Indeterminate'}, $
          {bit:10l, value:512l, description:'One of the input values were not finite.', assessment:'Indeterminate'}, $
          {bit:11l, value:1024l, description:'Algorithm failed; data value set to missing_value in output file.', assessment:'Bad'}]
end

