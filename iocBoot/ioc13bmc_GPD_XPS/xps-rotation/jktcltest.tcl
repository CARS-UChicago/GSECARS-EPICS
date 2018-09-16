# Program to test tcl functions
puts " JHK Test TCL "

set numArgs $tcl_argc
set arg1 $tcl_argc(0)
set arg2 $tcl_argc(1)

puts [format "arguments total %s - %s %s"$numArgs $arg1 $arg2]