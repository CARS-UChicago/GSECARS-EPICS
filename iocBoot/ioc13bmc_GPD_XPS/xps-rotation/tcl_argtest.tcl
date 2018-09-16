# Program to add an event to recursivly call its self 
# and send a TTL pulse to trigger the external gathering
# defined in the trajectory.st

#Read in previous element number
set numArgs $tcl_argc
#set i 0
#set elementN $tcl_argv($i)
#puts "NumArgs $numArgs previous element $element"

#foreach chose [array names tcl_argv] {
#    puts "Array member  $chose = $tcl_argv($chose)"
#    set elementN $tcl_argv($chose)
#}
puts " variable =  $tcl_argv(0)"

set elementN $tcl_argv(0)

puts $elementN
