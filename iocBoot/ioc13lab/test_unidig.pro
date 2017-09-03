while 1 do begin
  t = caput('13LAB:UnidigBo0', 1)
  wait, .001
  t = caput('13LAB:UnidigBo0', 0)
  wait, .001
endwhile
end

