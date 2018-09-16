############################################
# TCL program : Copy GPIO.DI in GlobalArray#
############################################

set TimeOut 10
set GlobalVar1 "test"
set ConnectorIn "GPIO1.DI"

# open TCP socket
set code [catch "OpenConnection $TimeOut socketID"]
set code [catch "GlobalArraySet $socketID 1 $GlobalVar1"]
TCP_CloseSocket $socketID