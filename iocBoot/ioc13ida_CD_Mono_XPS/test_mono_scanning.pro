; This program tests profile moves of the undulator rotation and height

; Read the computed arrays from the mono

t = caput('13IDA:CDEn:compute_mono_positions', 1)
wait, .5
t = caget('13IDA:CDEn:num_mono_positions', numPoints)
t = caget('13IDA:CDEn:mono_angles', angles, max=numPoints)
t = caget('13IDA:CDEn:mono_heights', heights, max=numPoints)

positions = [[angles], [heights]]
status = profile_move('13IDA:CDProf:', positions, groupName='GROUP1', $
                       maxAxes=2, time=0.01, acceleration=1, npulses=numPoints, $
                       /build,  /execute, /readback, $
                       actual=actual, errors=errors)
                       
end

