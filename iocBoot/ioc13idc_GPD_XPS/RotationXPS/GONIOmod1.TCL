# script GONIO.TCL
# 4 Décembre 2008

# Display error and close procedure
proc DisplayErrorAndClose {SocketID code APIName}\
    {
    global tcl_argv
    global Debug
    if {$code != -2}\
        {
        set code2 [catch "ErrorStringGet $SocketID $code strError"]
        if {$code2 != 0}\
            {
            if {$Debug==1} {puts "$APIName ERROR => $code - ErrorStringGet ERROR => $code2" }
            }\
        else \
            {
            if {$Debug==1} {puts stdout "$APIName ERROR => $code : $strError"}
            }
        }\
    else \
        {
        if {$Debug==1} {puts stdout "$APIName ERROR => $code : TCP timeout"}
        }
    }

#  Procedure to stop displacements

proc  Stop {SocketID Axis}\
    {
    global Debug
    set Status 0
    set code [catch " GroupStatusGet $SocketID $Axis Status"]
    if {$code != 0} {DisplayErrorAndClose  $SocketID  $code  "GroupStatusGet (in stop $Axis)" }
    if  {$Status==44} \
        {
        set code [catch " GroupMoveAbort $SocketID $Axis"]
        if {$code != 0} {DisplayErrorAndClose  $SocketID  $code  "GroupMoveAbort" }
        if { $Debug==1 }  {puts  stdout "Abort Move  $Axis"}
        after 200
        }
    if  {$Status==45} \
        {
        set code [catch " GroupMoveAbort $SocketID $Axis"]
        if {$code != 0} {DisplayErrorAndClose  $SocketID  $code  "GroupMoveAbort" }
        if { $Debug==1 }  {puts  stdout "Abort Trajectory  $Axis"}
        after 200
        }
    if  {$Status==46} \
        {
        set code [catch " SingleAxisSlaveModeDisable  $SocketID $Axis"]
        if {$code != 0} {DisplayErrorAndClose  $SocketID  $code  "SingleAxisSlaveModeDisable" }
        if { $Debug==1 }  {puts  stdout "Abort  Slave Move  $Axis"}
        after 200
        }
    if  {$Status==47} \
        {
        set Velocity 1
        set Acceleration 1
        set code [catch " GroupJogParametersGet $SocketID $Axis Velocity Acceleration"]
        if {$code != 0} {DisplayErrorAndClose  $SocketID  $code  "GroupJogParametersGet" }
        set Velocity 0
        set code [catch " GroupJogParametersSet $SocketID $Axis $Velocity $Acceleration"]
        if {$code != 0} {DisplayErrorAndClose  $SocketID  $code  "GroupJogParametersSet" }
        if { $Debug==1 }  {puts  stdout "Stop  JOG $Axis"}
        after 200
        }
    return
    }

# procedure  to "disable"   an axis
proc  Disable {SocketID Axis}\
    {
    global Debug
    set Status 0
    set code [catch " GroupStatusGet $SocketID $Axis Status"]
    if {$code != 0} {DisplayErrorAndClose  $SocketID  $code  "GroupStatusGet (in disable $Axis)" }
    if {($Status<20) || ($Status>38)} \
        {
        set ErrorCode [catch " GroupMotionDisable $SocketID $Axis "]
        if {$ErrorCode != 0} {DisplayErrorAndClose $SocketID $ErrorCode  "GroupMotionDisable $Axis " }
        if { $Debug==1 }  {puts  stdout "Disable  $Axis"}
        }
    }


# Program constant setup

source /Admin/public/scripts/CONST_GONIO.INC

##########################################
#     Begin main program                 #
##########################################

# calculate security masks and sense masks
# initialize variables
for {set i 1} {$i<=$NB_SECURITY} {incr i}\
    {
    set Mask_Secur($i)  [expr 1 << [ expr $INPUT_SECURITY($i) -1]]
    set Sense_Secur($i)  [expr $SENSE_SECURITY($i) << [ expr $INPUT_SECURITY($i) -1]]
    set Secur_active($i) 0
    }


# Open com.
set TimeOut 300
set ErrorCode [catch "OpenConnection $TimeOut SocketID"]
if {$ErrorCode != 0} {DisplayErrorAndClose $SocketID $ErrorCode  "OpenConnection"}

# variables declarations
set MinTarget 0
set MaxTarget 0
set CurrentPosition 0

#  Read current software limits
for {set i 1} {$i<=$NB_GROUP} {incr i}\
    {
    set ErrorCode [catch "PositionerUserTravelLimitsGet $SocketID $POSITIONER($i) MinTarget MaxTarget"]
    if {$Debug==1 }  {puts "PositionerUserTravelLimitsGet $SocketID $POSITIONER($i) MinTarget MaxTarget" }
    set Min_Limit($i) $MinTarget
    set Max_Limit($i) $MaxTarget
    }

#  Infinite loop for program
while {1==1} \
    {
    set DigitalValue 0
    # Input security tests.
    for {set i 1} {$i<=$NB_SECURITY} {incr i}\
        {
        # read Input IO group
        set ErrorCode [catch "GPIODigitalGet $SocketID $GROUP_SECURITY($i) DigitalValue"]
        if {$ErrorCode != 0} {DisplayErrorAndClose $SocketID $ErrorCode  "GPIODigitalGet $GROUP_SECURITY($i)"}
        # mask and test input
        if {[expr $DigitalValue & $Mask_Secur($i) ] != $Sense_Secur($i)} \
            {
            # secutity active
            if {$Secur_active($i)==0}\
                {
                # security begin to be active
                if {$Debug==1 }  {puts "Security Nb $i actived"}
                #stop move  and disable all axes
                for {set Axis 1} {$Axis<=$NB_GROUP} {incr Axis}\
                    {
                    Stop $SocketID $GROUP($Axis)
                    Disable  $SocketID $GROUP($Axis)
                    }
                # set software limits on axes concerned.
                for {set Axis 1} {$Axis<=$NB_AXES_SECURITY($i)} {incr Axis}\
                    {
                    # Read current position
                    set ErrorCode [catch " GroupPositionCurrentGet $SocketID $POSITIONER($AXES_SECURED($i,$Axis)) CurrentPosition"]
                    if {$ErrorCode != 0}  {DisplayErrorAndClose $SocketID $ErrorCode "GroupPositionCurrentGet $POSITIONER($AXES_SECURED($i,$Axis))"}
                    if {$SENSE_SECURED($i,$Axis)==1}\
                        {
                        set MinTarget $Min_Limit($AXES_SECURED($i,$Axis))
                        set MaxTarget [ expr $CurrentPosition + $OFFSET]
                        }
                    if {$SENSE_SECURED($i,$Axis)==-1}\
                        {
                        set MinTarget [ expr $CurrentPosition - $OFFSET]
                        set MaxTarget $Max_Limit($AXES_SECURED($i,$Axis))
                        }
                    if {$SENSE_SECURED($i,$Axis)==0}\
                        {
                        set MinTarget [ expr $CurrentPosition - $OFFSET]
                        set MaxTarget [ expr $CurrentPosition + $OFFSET]
                        }
                    set ErrorCode [catch "PositionerUserTravelLimitsSet $SocketID $POSITIONER($AXES_SECURED($i,$Axis)) $MinTarget $MaxTarget"]
                    if {$Debug==1 }  {puts "PositionerUserTravelLimitsSet $SocketID $POSITIONER($AXES_SECURED($i,$Axis)) $MinTarget $MaxTarget" }
                    if {$ErrorCode != 0} {DisplayErrorAndClose $SocketID $ErrorCode  "PositionerUserTravelLimitsSet $POSITIONER($AXES_SECURED($i,$Axis))"}
                    set Secur_active($i) 1
                    }
                }
            }\
        else\
            {
            # security not active
            if {$Secur_active($i)==1}\
                {
                # security begin to be unactive
                if {$Debug==1 }  {puts "Security Nb $i unactived"}
                for {set Axis 1} {$Axis<=$NB_AXES_SECURITY($i)} {incr Axis}\
                    {
                    # Read current position
                    set ErrorCode [catch " GroupPositionCurrentGet $SocketID $POSITIONER($AXES_SECURED($i,$Axis)) CurrentPosition"]
                    if {$ErrorCode != 0}  {DisplayErrorAndClose $SocketID $ErrorCode "GroupPositionCurrentGet $POSITIONER($AXES_SECURED($i,$Axis))"}
                    set MinTarget $Min_Limit($AXES_SECURED($i,$Axis))
                    set MaxTarget $Max_Limit($AXES_SECURED($i,$Axis))
                    set ErrorCode [catch "PositionerUserTravelLimitsSet $SocketID $POSITIONER($AXES_SECURED($i,$Axis)) $MinTarget $MaxTarget"]
                    if {$Debug==1 }  {puts "PositionerUserTravelLimitsSet $SocketID $POSITIONER($AXES_SECURED($i,$Axis)) $MinTarget $MaxTarget" }
                    if {$ErrorCode != 0} {DisplayErrorAndClose $SocketID $ErrorCode  "PositionerUserTravelLimitsSet $POSITIONER($AXES_SECURED($i,$Axis))"}
                    set Secur_active($i) 0
                    }
                }
            }
        }
    if { $Debug==1 }  {after 200}
    }
set ErrorCode [catch "TCP_CloseSocket $SocketID"]

