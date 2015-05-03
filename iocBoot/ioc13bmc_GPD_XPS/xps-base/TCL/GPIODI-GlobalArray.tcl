############################################
# TCL program : Copy GPIO.DI in GlobalArray#
############################################

set TimeOut 10
set GlobalVar1 "test"
set security1 0
set security2 0

# open TCP socket
set code [catch "OpenConnection $TimeOut socketID"]
set code [catch "GPIODigitalGet $socketID GPIO1.DI security1"]
set code [catch "GPIODigitalGet $socketID GPIO2.DI security2"]
if $security1 != 0 {
              if { [ expr { $security1 & 2 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 Y1_EOR_PLUS"]}
              if { [ expr { $security1 & 4 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 Y1_EOR_MINUS"]}
              if { [ expr { $security1 & 8 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 Y2_EOR_PLUS"]}
              if { [ expr { $security1 & 16 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 Y2_EOR_MINUS"]}
              if { [ expr { $security1 & 32 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 Y3_EOR_PLUS"]}
              if { [ expr { $security1 & 64 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 Y3_EOR_MINUS"]}
              if { [ expr { $security1 & 128 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 NU_EOR_PLUS"]}
if $security2 != 0 {
              if { [ expr { $security2 & 1 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 NU_EOR_MINUS"]}
              if { [ expr { $security2 & 2 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 PSI_EOR_PLUS"]}
              if { [ expr { $security2 & 4 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 PSI_EOR_MINUS"]}
              if { [ expr { $security2 & 8 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 2THETA_EOR_PLUS"]}
              if { [ expr { $security2 & 16 } ] !=0 } 
                 {set code [catch "GlobalArraySet $socketID 1 2THETA_EOR_MINUS"]}
                   }

TCP_CloseSocket $socketID