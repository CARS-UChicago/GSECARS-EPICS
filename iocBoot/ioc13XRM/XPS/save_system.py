import sys
from newportxps import NewportXPS

ipaddr = sys.argv[1]
x = NewportXPS(ipaddr)

print(x.status_report())

x.save_systemini()
x.save_stagesini()

print("wrote system.ini")
print("wrote stages.ini")

