; This program sets the 1000 ton LVP geometry constants in case they are
; lost

; Distances from press center to 2 Z actuators
dist = 1087.5
t = caput('13IDD:pm3C1.VAL', dist)
t = caput('13IDD:pm3C2.VAL', dist)

; Conversion from radians to degrees
t = caput('13IDD:pm4C1.VAL', 1./(2.*dist)/!dtor)
end
