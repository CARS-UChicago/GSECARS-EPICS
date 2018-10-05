############################################ 
# 
# TCL generation of history
# 
############################################ 

# Display error and close procedure 
proc DisplayErrorAndClose {socketID code APIName} { 
	if {$code != -2} { 
		set code2 [catch "ErrorStringGet $socketID $code strError"] 
		if {$code2 != 0} { 
			puts stdout "$APIName ERROR => $code / ErrorStringGet ERROR => $code2" 
		} else { 
			puts stdout "$APIName ERROR => $code : $strError" 
		}
	} else { 
			puts stdout "$APIName ERROR => $code : TCP timeout" 
	} 
	set code2 [catch "TCP_CloseSocket $socketID"] 
	return 
} 

# Main process 
set TimeOut 20 
set code 0 

# Open TCP socket 
set code [catch "OpenConnection $TimeOut socketID"] 
if {$code != 0} { 
	puts stdout "OpenConnection failed => $code" 
} else { 
	set code [catch "FirmwareVersionGet $socketID arg1"] 
	if {$code != 0} { 
		DisplayErrorAndClose $socketID $code "FirmwareVersionGet" 
		return 
	} 
	set code [catch "MultipleAxesPVTParametersGet $socketID GROUP1 arg1 arg2"] 
	if {$code != 0} { 
		DisplayErrorAndClose $socketID $code "MultipleAxesPVTParametersGet" 
		return 
	} 

	puts "arg1 $arg1 arg2 $arg2"
	
	# Close TCP socket 
	set code [catch "TCP_CloseSocket $socketID"] 
} 
