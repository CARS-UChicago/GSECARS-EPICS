; This program uses trajectory_scan.pro to build and execute a trajectory.

nelements = 21
; nelements output pulses during the trajectory
npulses = nelements
naxes = 2
trajRecord = '13BMC:traj1'

element_time = 1.0
;  seconds total time to execute the trajectory
time = element_time * nelements

; 1 second acceleration time
accel = 1.

; The M1 trajectory is linear from 1.0 to 2.0
t1 = 1.0 + findgen(nelements)/(nelements-1) * 1.0

; The M2 trajectory is linear from 52 to 50

t2 = 52 - findgen(nelements)/(nelements-1) * 2.0

traj = dblarr(nelements, naxes)
traj[0,0] = t1
traj[0,1] = t2

status = trajectory_scan(trajRecord, traj, accel=accel, time=time, /read, actual=actual, errors=errors)

end

