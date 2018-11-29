function replace_nans_with_missing,data,missing
  data1 = data
  index = where(~finite(data1),count)
  if (count ne 0) then data1[index] = missing
  return,data1
end
