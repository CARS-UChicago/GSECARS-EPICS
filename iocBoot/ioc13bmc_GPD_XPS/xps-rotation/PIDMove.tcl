# Program to run a pid loop using tcl

set numArgs $tcl_argc
set i 0
set target $tcl_argv($i)
#set target 60.0
set TimeOut 0.5
set errorVal 0
set avPosition 0
set deadBand 0.01
set positionerName GROUP1.PHI
set groupName GROUP1
set cVel 0
set cAccel 0
set cPosition 0
set rVel 0
set rAccel 0
# The max vel and acc are 16 in the stages.ini file for Phi
set maxAccel 16
set runningAccel 16
set maxVel 5
set minVel 0.1
set loop 1
set groupStatus -999999
set loopCount 0
# Max number of PID loops
set loopMax 100000
set loopPrint 0
set loopPrintMax 1000
set trimChars -
set maxTarget 180
set minTarget -180

# check that we only have 1 or 2 args if not exit!
#if {$numArgs <= 3 } {
#    error $numArgs}

# This removes the minus sign if there is one so that we can
# test to see if the target is a number

#puts "target before trim : $target trimed sign : $trimChars "
set testTarget [string trim $target $trimChars]
#puts "target after trim : $target "

# This checks to see if the target is a number
if { [string is digit $testTarget] != 1 } {
    puts {ERROR target position not number : $target [$target]}
    return -1}

# Is the target within the motion range. 
if { $target < $minTarget || $target > $maxTarget } {
    puts {ERROR target position out of range}
    return -1}


puts stdout [format "arguments total %s target position %s " $numArgs $target ]

# open TCP socket
set status [catch "OpenConnection $TimeOut socket"]
if {$status != 0} {
    puts {ERROR OpenConnection $TimeOut socket}
    return $status }

puts " Talking on socket $socket "

# If there is a group status problem exit
set status [catch "GroupStatusGet $socket $groupName groupStatus"]
puts " Group Status $groupStatus "
if { $status != 0 || [ expr $groupStatus < 10  ||  $groupStatus > 17 ] } {
    puts {ERROR GroupStatus not ready to move}
    return $status }

if {$status == 0 && $errorVal == 0} {

    #Zero the jog parameters to insure the motors don't move when jog mode enabled
    set status [catch "GroupJogParametersSet $socket $groupName $cVel $cAccel"]

    if {$status == 0 } {
        set errorVal $status }

    # Start jog mode
    set status [catch "GroupJogModeEnable $socket $groupName"]

    if {$status == 0 } {
        set errorVal $status }

    set cAccel $runningAccel
  
    # While we have not reached our target yet loop
    while {$loop == 1 && $errorVal == 0 && $loopCount < $loopMax} {
    
    	# Check to make sure another program or person has not disabled jog mode
	set status [catch "GroupStatusGet $socket $groupName groupStatus"]
	if { $status != 0 || $groupStatus != 47 } {
        puts {ERROR Jogging has been disabled}
    	return $status }

    
	# Read current position
        set status [catch "GroupPositionCurrentGet $socket $positionerName cPosition"]

	# For now we don't have other encoders to average
	set avPosition $cPosition
		
        #Have we entered the dead band? Then stop or continue
	if {$target <= [expr $avPosition - $deadBand] || \
		$target >= [expr $avPosition + $deadBand] } {
	    set loop 1
	} else {
            set loop 0
	    set cVel 0
	    set cAccel $maxAccel
	    set status [catch "GroupJogParametersSet $socket $positionerName $cVel $cAccel"]

	    puts " Within Dead Band "
	    continue	    
	}	
	# Calculate the jog velocity 
	# jog sits at max until 1deg/mm from target
	# it then reduces linearly to minVel until
	# it reaches the dead band

	set diff [expr $target - $cPosition ]
	
	if {$diff > [expr 1 + $minVel] } {
	    set cVel $maxVel 
	} elseif {$diff < [expr -1 - $minVel] } {
	    set cVel [expr $maxVel * -1] 
	} elseif {$diff > 0} {
	    set cVel [expr {$diff * $maxVel} + $minVel ]
        } elseif {$diff <= 0} {
	    set cVel [expr {$diff * $maxVel} - $minVel ]
	} else {
	    puts " Error setting cVel "
	}
	
#	if {$target > $cPosition} {
#	    set cVel $maxVel 
#	} else {
#	    set cVel [expr -1 * $maxVel] }

        # Set the new jog parms
	set status [catch "GroupJogParametersSet $socket $positionerName $cVel $cAccel"]
        if {$status == 0 } {
            set errorVal $status 
	}

	incr loopCount
	incr loopPrint
	# Only print the position every $loopPrintMax
	if { $loopPrint >= $loopPrintMax } {
	    set status [catch "GroupJogParametersGet $socket $positionerName rVel rAccel"]
 	    puts "Readback Vel $rVel ReadBack Accel $rAccel"
	
	    puts " avPosition $avPosition cVel $cVel cAccel $cAccel "
	    set loopPrint 0
	}

    }
    
    set status [catch "GroupJogModeDisable $socket $groupName"]
    # Readback final values
    set status [catch "GroupJogParametersGet $socket $positionerName rVel rAccel"]
    puts "Final Readback Vel $rVel ReadBack Accel $rAccel"
    puts "Final avPosition $avPosition cVel $cVel cAccel $cAccel "

}
    set status [catch "TCP_CloseSocket $socket"]
    
