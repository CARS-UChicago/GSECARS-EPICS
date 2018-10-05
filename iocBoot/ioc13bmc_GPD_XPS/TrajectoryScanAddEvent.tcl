# Program to add an event to recursivly call its self 
# and send a TTL pulse to trigger the external gathering
# defined in the trajectory.st

#Read in previous element number
#set numArgs $tcl_argc
#set i 0
set elementN $tcl_argv(0)
puts $elementN

#foreach chose [array names tcl_argv] {
#    puts "Array member  $chose = $tcl_argv($chose)"
#    set elementN $tcl_argv($chose)
#}

puts " Running tcl program elem number passed $elementN "

set timeOut 	0.1
set NULL 	0
#set elementNumber 0

# These variables must match the SNL
set GPIOname 	GPIO4.DO
set pulseMask 	63
set taskName 	TrajectoryScan
set positionerName GROUP1.PHI
set groupName 	GROUP1
set tclFile	TrajectoryScanAddEvent.tcl


# open TCP socket
set status [catch "OpenConnection $timeOut socket"]
if {$status != 0} {
    puts {ERROR OpenConnection $timeOut socket }
    return $status }

# Check to see if we are running a trajectory
set status [catch "GroupStatusGet $socket $groupName groupStatus"]
puts " Group Status $groupStatus "
if { $status != 0 } {
    puts "ERROR GroupStatusGet $status"
    return $status }

if { $groupStatus != 45 } {
    puts "ERROR Not running a trajectory group status $groupStatus"
    return $status }
    
# Send a pulse to trigger the 'ExternalGathering' of the motor positions
# as well as the Struck (SIS)
set status [catch "EventAdd $socket $positionerName Immediate $NULL DOPulse $GPIOname $pulseMask $NULL"]
if {$status != 0} {
    puts "ERROR Immediate DOPulse not sent $status"
    return $status }

# Read current trajectory element number and file name
#set status [catch "MultipleAxesPVTParametersGet $socket $groupName trajFile elementN"]
#if {$status != 0} {
#    puts "ERROR MultipleAxesPVTParametersGet $status"
#    return $status }

#puts " trajFile $trajFile elementN $elementN"
# When this script is first called the element number is 0 but the next is 2
#if {$elementN == 0} {
#    puts "First element!"
#    set elementN 1 }

#puts "Running tcl program elem $elementN $tclFile"
set nElementN [expr $elementN + 1]
puts "Next element $nElementN"
# Set the call back event on the next trajectory element
set status [catch "EventAdd $socket $positionerName PVT.ElementNumberStart $nElementN ExecuteTCLScript $tclFile $taskName $nElementN"]
if {$status != 0} {
    puts "ERROR PVT.ElementNumberStart $nextElementNumber ExecuteTCLScript $status"
    return $status }

# Close Socket
set status [catch "TCP_CloseSocket $socket"]

