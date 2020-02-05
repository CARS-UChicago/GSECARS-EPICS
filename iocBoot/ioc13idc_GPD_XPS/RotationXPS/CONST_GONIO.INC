#CONST_GONIO.TCL  4 december 2008
# Constants declaration for "GONIO.TCL" script

# set "Debug" flag
set Debug 0

# Number of Groups in XPS
set NB_GROUP  6

# Group Names
set GROUP(1) "GROUP1"
set GROUP(2) "GROUP1"
set GROUP(3) "GROUP1"
set GROUP(4) "GROUP1"
set GROUP(5) "GROUP1"
set GROUP(6) "GROUP1"


# Positioners names
set POSITIONER(1) "GROUP1.KPHI"
set POSITIONER(2) "GROUP1.KAPPA"
set POSITIONER(3) "GROUP1.KETA"
set POSITIONER(4) "GROUP1.MU"
set POSITIONER(5) "GROUP1.DEL"
set POSITIONER(6) "GROUP1.NU"


# Input security numbers
set NB_SECURITY 7

# Offset from current position to software limit
set OFFSET 0.01

# 1st security parameters:

# Group name where security is connected
set GROUP_SECURITY(1) "GPIO4.DI"       ;# GPIO ou la sécurité 1 est connectée
# Input used number
set INPUT_SECURITY(1) 1                ;# Numero de l'entrée ou la sécurité 1 est connectée
# Input sense for security   (1 or 0)
set SENSE_SECURITY(1) 1                ;# la sécurité 1 est active sur un niveau 1
# Axes number for this security
set NB_AXES_SECURITY(1) 6              ;# La securité 1 limite la course de  6 axes
# Axes index for this security
set AXES_SECURED(1,1) 1                ;# l'axe dont la course est limitée par la sécurité 1 est l'axe 2
set AXES_SECURED(1,2) 2
set AXES_SECURED(1,3) 3
set AXES_SECURED(1,4) 4
set AXES_SECURED(1,5) 5
set AXES_SECURED(1,6) 6

# Sense limit ( 1:+ ; -1:-; 0: +&-)
set SENSE_SECURED(1,1)  0               ;# L'axe est limitée en sens plus..
set SENSE_SECURED(1,2)  0
set SENSE_SECURED(1,3)  0
set SENSE_SECURED(1,4)  1
set SENSE_SECURED(1,5) -1
set SENSE_SECURED(1,6) -1






# 2nd security parameters

# Group name where security is connected
set GROUP_SECURITY(2) "GPIO4.DI"
# Input used number
set INPUT_SECURITY(2) 2
# Input sense for security   (1 or 0)
set SENSE_SECURITY(2) 1
# Axes number for this security
set NB_AXES_SECURITY(2) 6
#Axes index for this security
set AXES_SECURED(2,1) 1                ;# l'axe dont la course est limitée par la sécurité 1 est l'axe 2
set AXES_SECURED(2,2) 2
set AXES_SECURED(2,3) 3
set AXES_SECURED(2,4) 4
set AXES_SECURED(2,5) 5
set AXES_SECURED(2,6) 6




# Sense limit ( 1:+ ; -1:-; 0: +&-)
set SENSE_SECURED(2,1)  0              ;# L'axe est limitée en sens plus..
set SENSE_SECURED(2,2)  0
set SENSE_SECURED(2,3)  0
set SENSE_SECURED(2,4) -1
set SENSE_SECURED(2,5)  1
set SENSE_SECURED(2,6)  1




# 3nd security parameters
# Group name where security is connected
set GROUP_SECURITY(3) "GPIO4.DI"
# Input used number
set INPUT_SECURITY(3) 3
# Input sense for security   (1 or 0)
set SENSE_SECURITY(3) 1
# Axes number for this security
set NB_AXES_SECURITY(3) 6
# Axes index for this security
set AXES_SECURED(3,1) 1                ;# l'axe dont la course est limitée par la sécurité 1 est l'axe 2
set AXES_SECURED(3,2) 2
set AXES_SECURED(3,3) 3
set AXES_SECURED(3,4) 4
set AXES_SECURED(3,5) 5
set AXES_SECURED(3,6) 6




# Sense limit ( 1:+ ; -1:-; 0: +&-)
set SENSE_SECURED(3,1)   0               ;# L'axe est limitée en sens plus..
set SENSE_SECURED(3,2)   0
set SENSE_SECURED(3,3)   0
set SENSE_SECURED(3,4)  -1
set SENSE_SECURED(3,5)   0
set SENSE_SECURED(3,6)  -1

# 4nd security parameters
# Group name where security is connected
set GROUP_SECURITY(4) "GPIO4.DI"
# Input used number
set INPUT_SECURITY(4) 4
# Input sense for security   (1 or 0)
set SENSE_SECURITY(4) 1
# Axes number for this security
set NB_AXES_SECURITY(4) 6
# Axes index for this security
set AXES_SECURED(4,1) 1                ;# l'axe dont la course est limitée par la sécurité 1 est l'axe 2
set AXES_SECURED(4,2) 2
set AXES_SECURED(4,3) 3
set AXES_SECURED(4,4) 4
set AXES_SECURED(4,5) 5
set AXES_SECURED(4,6) 6




# Sense limit ( 1:+ ; -1:-; 0: +&-)
set SENSE_SECURED(4,1)  0               ;# L'axe est limitée en sens plus..
set SENSE_SECURED(4,2)  0
set SENSE_SECURED(4,3)  0
set SENSE_SECURED(4,4)  1
set SENSE_SECURED(4,5)  0
set SENSE_SECURED(4,6)  1



# 5nd security parameters
# Group name where security is connected
set GROUP_SECURITY(5) "GPIO4.DI"
# Input used number
set INPUT_SECURITY(5) 5
# Input sense for security   (1 or 0)
set SENSE_SECURITY(5) 1
# Axes number for this security
set NB_AXES_SECURITY(5) 6
# Axes index for this security
set AXES_SECURED(5,1) 1                ;# l'axe dont la course est limitée par la sécurité 1 est l'axe 2
set AXES_SECURED(5,2) 2
set AXES_SECURED(5,3) 3
set AXES_SECURED(5,4) 4
set AXES_SECURED(5,5) 5
set AXES_SECURED(5,6) 6




# Sense limit ( 1:+ ; -1:-; 0: +&-)
set SENSE_SECURED(5,1)  0               ;# L'axe est limitée en sens plus..
set SENSE_SECURED(5,2)  0
set SENSE_SECURED(5,3)  0
set SENSE_SECURED(5,4) -1
set SENSE_SECURED(5,5) +1
set SENSE_SECURED(5,6) +1


# 6th security parameters
# Group name where security is connected
set GROUP_SECURITY(6) "GPIO4.DI"
# Input used number
set INPUT_SECURITY(6) 6
# Input sense for security   (1 or 0)
set SENSE_SECURITY(6) 1
# Axes number for this security
set NB_AXES_SECURITY(6) 6
# Axes index for this security
set AXES_SECURED(6,1) 1                ;# l'axe dont la course est limitée par la sécurité 1 est l'axe 2
set AXES_SECURED(6,2) 2
set AXES_SECURED(6,3) 3
set AXES_SECURED(6,4) 4
set AXES_SECURED(6,5) 5
set AXES_SECURED(6,6) 6




# Sense limit ( 1:+ ; -1:-; 0: +&-)
set SENSE_SECURED(6,1)  0               ;# L'axe est limitée en sens plus..
set SENSE_SECURED(6,2)  0
set SENSE_SECURED(6,3)  0
set SENSE_SECURED(6,4)  1
set SENSE_SECURED(6,5) -1
set SENSE_SECURED(6,6) -1



# 7th security parameters
# Group name where security is connected
set GROUP_SECURITY(7) "GPIO4.DI"
# Input used number
set INPUT_SECURITY(7) 7
# Input sense for security   (1 or 0)
set SENSE_SECURITY(7) 1
# Axes number for this security
set NB_AXES_SECURITY(7) 6
# Axes index for this security
set AXES_SECURED(7,1) 1                ;# l'axe dont la course est limitée par la sécurité 1 est l'axe 2
set AXES_SECURED(7,2) 2
set AXES_SECURED(7,3) 3
set AXES_SECURED(7,4) 4
set AXES_SECURED(7,5) 5
set AXES_SECURED(7,6) 6




# Sense limit ( 1:+ ; -1:-; 0: +&-)
set SENSE_SECURED(7,1)  0               ;# L'axe est limitée en sens plus..
set SENSE_SECURED(7,2)  0
set SENSE_SECURED(7,3)  0
set SENSE_SECURED(7,4)  0
set SENSE_SECURED(7,5)  0
set SENSE_SECURED(7,6)  0







