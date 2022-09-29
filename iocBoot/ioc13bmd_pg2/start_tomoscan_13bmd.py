# This script creates an object of type TomoScan13BM for doing tomography scans at APS beamline 13-BM-D
# To run this script type the following:
#     python -i start_tomoscan_13bmd.py
# The -i is needed to keep Python running, otherwise it will create the object and exit
from tomoscan.tomoscan_13bm import TomoScan13BM
ts = TomoScan13BM(["J:/epics/support/tomoscan/db/tomoScan_settings.req","J:/epics/support/tomoscan/db/tomoScan_13BM_settings.req"], {"$(P)":"13BMDPG2:", "$(R)":"TS:"})
