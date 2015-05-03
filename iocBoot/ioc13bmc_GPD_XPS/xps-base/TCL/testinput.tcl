puts " security run ! "
set TimeOut 120
set input1  "GPIO1.DI"
set input3  "GPIO3.DI"
set StatusAxe 0
set axe1 "GROUP1"
set axe2 "GROUP2"
set axe3 "GROUP3"
set axe4 "GROUP4"
set axe5 "GROUP5"
set axe6 "GROUP6"
set axe7 "GROUP7"
set axe8 "GROUP8"
# open TCP socket
set code [catch "OpenConnection $TimeOut socketID"]
if {$code == 0}	{
   set etat_initial_input1 255
   while {1==1} {

		puts  stdout "in while"

		set code [catch "GPIODigitalGet $socketID $input1 etat_lu_input1"]
		set code [catch "GPIODigitalGet $socketID $input3 etat_lu_input3"]
		if {$etat_lu_input1 < $etat_initial_input1} {
		   puts "Security on GPIO1 detected !"
		   puts $etat_lu_input1
		   puts $etat_initial_input1
		   set code [catch "GroupStatusGet $socketID $axe1 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe1"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe1"]
			      set code [catch "GroupMotionDisable $socketID $axe1"]}
		   set code [catch "GroupStatusGet $socketID $axe2 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe2"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe2"]
			      set code [catch "GroupMotionDisable $socketID $axe2"]}
		   set code [catch "GroupStatusGet $socketID $axe3 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe3"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe3"]
			      set code [catch "GroupMotionDisable $socketID $axe3"]}
		   set code [catch "GroupStatusGet $socketID $axe4 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe4"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe4"]
			      set code [catch "GroupMotionDisable $socketID $axe4"]}
		   set code [catch "GroupStatusGet $socketID $axe5 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe5"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe5"]
			      set code [catch "GroupMotionDisable $socketID $axe5"]}
		   set code [catch "GroupStatusGet $socketID $axe6 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe6"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe6"]
			      set code [catch "GroupMotionDisable $socketID $axe6"]}
		   set code [catch "GroupStatusGet $socketID $axe7 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe7"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe7"]
			      set code [catch "GroupMotionDisable $socketID $axe7"]}
		   set code [catch "GroupStatusGet $socketID $axe8 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe8"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe8"]
			      set code [catch "GroupMotionDisable $socketID $axe8"]}
		   }
		if {$etat_lu_input3 == 0} {
		   puts "Emergency STOP on GPIO3 detected ! "
		   puts $etat_lu_input3
		   set code [catch "GroupStatusGet $socketID $axe1 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe1"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe1"]
			      set code [catch "GroupMotionDisable $socketID $axe1"]}
		   set code [catch "GroupStatusGet $socketID $axe2 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe2"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe2"]
			      set code [catch "GroupMotionDisable $socketID $axe2"]}
		   set code [catch "GroupStatusGet $socketID $axe3 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe3"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe3"]
			      set code [catch "GroupMotionDisable $socketID $axe3"]}
		   set code [catch "GroupStatusGet $socketID $axe4 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe4"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe4"]
			      set code [catch "GroupMotionDisable $socketID $axe4"]}
		   set code [catch "GroupStatusGet $socketID $axe5 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe5"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe5"]
			      set code [catch "GroupMotionDisable $socketID $axe5"]}
		   set code [catch "GroupStatusGet $socketID $axe6 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe6"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe6"]
			      set code [catch "GroupMotionDisable $socketID $axe6"]}
		   set code [catch "GroupStatusGet $socketID $axe7 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe7"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe7"]
			      set code [catch "GroupMotionDisable $socketID $axe7"]}
		   set code [catch "GroupStatusGet $socketID $axe8 StatusAxe"]
		   if {$StatusAxe == 43} {set code [catch "GroupKill $socketID $axe8"]
		      } else {set code [catch "GroupMoveAbort $socketID $axe8"]
			      set code [catch "GroupMotionDisable $socketID $axe8"]}
		   }
		after 50
		set etat_initial_input1 $etat_lu_input1
		}
   TCP_CloseSocket $socketID
}
