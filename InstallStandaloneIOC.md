# Installing Pre-Built EPICS IOCs on Windows

Pre-built binary versions of EPICS applications can be provided for Windows.
This is very convenient so that it is not necessary to
set up a build system to compile the IOC, which required significant effort.

The instructions here use the CARSApp application as an example.  CARSApp
is an EPICS application built with support for most of the devices in the 
[EPICS SynApps module](https://www.aps.anl.gov/BCDA/synApps).  This includes
many motors, serial, TCP/IP, and USB devices.It does not include
support for any EPICS areaDetector modules.  Those are provided as separate pre-built
IOC applications.

With some modifications these instructions can be used for other pre-built EPICS
IOCs.

## Install required support libraries
The CARSApp application can control devices include Canberra and Amptek multichannel analyzers,
Measurement Computing USB and Ethernet modules.  These require additional support packages 
to be installed, or CARSApp will not be able to be run.

### WinPcap
This package provides the libraries needed for the Canberra Multichannel Analyzers.  It can be downloaded
here: https://www.winpcap.org/install/default.htm 

### InstaCal
This package provides the libraries needed for the Measurement Computing devices.
Download and install the InstaCal software from this Web page:
https://www.mccdaq.com/Software-Downloads.aspx 

### libusb-1.0
This library is needed for the Amptek Multichannel Analyzers. It can be downloaded from this Web page:
https://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-1.0.21/libusb-1.0.21.7z/download 
You can use the 7-Zip program to extract the downloaded .7z archive file: https://www.7-zip.org/download.html 
It unzips into a libusb-1.0.21 directory.  The libusb-1.0.21\lib\liusb-1.0.21\MS64\dll subdirectory must be added to your PATH environment variable: 
For example you could put the package in C:\Program Files\libusb-1.0.21 and then add C:\Program Files\\libusb-1.0.21\MS64\dll in your PATH.
That is done with Control Panel/System/Advanced/Environment Variables/Edit and add it to the existing PATH environment variable.

## Download
The pre-built package can be found on the 
[CARS Web site](http://cars.uchicago.edu/epics/pub/epics_standalone_CARS.zip). 


The pre-built binaries contain executables for one or more of the following
architectures:
- linux-x86 (32-bit Linux built on Centos7, gcc 4.8.5, libc 2.17)
- linux-x86_64 (64-bit Linux built on Centos7, gcc 4.8.5, libc 2.17)
- linux-x86_rhel6 (32-bit Linux build on RHEL6, gcc 4.4.7, libc 2.12)
- linux-x86_64-gcc42 (64-bit Linux built on SUSE, gcc 4.2.1, libc 2.6.1)
- darwin-x86 (64-bit Mac OS X built on Darwin 11.4.2,  ??, clang 4.2)
- win32-x86-static (32-bit Windows, VS2010 compiler, statically linked)
- win32-x86 (32-bit Windows, VX2010 compiler, dyanamically linked)
- windows-x64-static (64-bit Windows, VS2010 compiler, statically linked)
- windows-x64 (64-bit Windows, VX2010 compiler, dyanamically linked)

Note that the linux-x86 and linux-x86_64 builds are done a relatively new Linux system
and will not run on RHEL 6, for example.  The linux-x86-rhel6 build will run on RHEL 6. 
The linux-x86_64-gcc42 build uses a very old version of libc and should run on most Linux 
systems.

Follow these steps to use the prebuilt version.  

* Create an installation directory for the module. On Windows I typically use C:\EPICS\support.
  On Linux I typically use /home/ACCOUNT/epics/support, where ACCOUNT is the name
  of the account that is normally used to run the detector software, e.g. marccd on
  a marCCD detector, mar345 on a mar345 detector, det on a Pilatus detector, etc.

* Place the distribution file in this directory. Then issue the commands (Unix style)

    <code>tar xvzf ADPilatus_RX-Y.tgz</code>
    
  On Windows it is more convenient to download the zip file and extract it using
  Windows Explorer.
  
    
* In the ADPilatus/iocs/pilatusIOC/iocBoot/ directory make a *copy* of the example 
  iocPilatus directory and give it a new local name, e.g. ioc13Pilatus1. By doing this you
  will be able to update to later versions of areaDetector without overwriting modifications
  you make in the ioc13Pilatus1 directory.

* In the new io13Pilatus1 directory you just created edit st.cmd to change the PV prefix
  $(PREFIX) to one that is unique to your site. PV prefixes must be unique on the subnet, and
  if you use the default prefix there could be a conflict with other detectors of the same
  type.

* In the same ioc13Pilatus1 directory edit the file envPaths to point to the locations of all of the
  support modules on your system. Normally this is handled by the EPICS build system, but
  when using the prebuilt version this must be manually edited. Do not worry about the path
  to EPICS_BASE, it is not required.


Display Managers
================    
A display manager is needed to view the areaDetector control screens. Control screens are
provided for the following display managers: MEDM, EDM, CSS, and caQtDM. The native screens
are created manually using MEDM.  The EDM, CSS and caQtDM screens are converted from the MEDM
screens using conversion utilities. These are discussed in a later section.   

In order to control the detectors and the plugins you should install one or more of
MEDM, EDM, CSS, caQtDM.

### MEDM

The source code for medm can be downloaded from:
[medm](http://www.aps.anl.gov/epics/extensions/medm/index.php)

This requires [Motif](http://motif.ics.com/).  medm can be built from source on Linux if the Motif library is
available (which it is not for some new releases, such as Fedora 20). 

It is available for Windows as via an
[EPICS Windows Tools MSI installer 
package](http://www.aps.anl.gov/epics/distributions/win32/index.php).


### EDM
This can be downloaded through links on the 
[EDM home page](http://ics-web.sns.ornl.gov/edm).

### CSS
This can be downloaded through links on the 
[CSS home page](http://controlsystemstudio.org).

### caQtDM
This can be downloaded through links on the 
[caQtDM home page](http://epics.web.psi.ch/software/caqtdm).


Configuration
=============
Before running an areaDetector application it is usually necessary to configure
    a number of items.

* EPICS environment variables. There are several environment variables that EPICS
  uses. I suggest setting these in the .cshrc (or .bashrc) file for the account that
  will be used to run the detector.

    - EPICS_CA_AUTO_ADDR_LIST and EPICS_CA_ADDR_LIST.
      These variables control the IP addresses that EPICS clients use when searching for
      EPICS PVs. The default is EPICS_CA_AUTO_ADDR_LIST=YES and EPICS_CA_ADDR_LIST to be the
      broadcast address of all networks connected to the host. Some detectors, for example
      the marCCD and mar345, come with 2 network cards, which are on 2 different subnets,
      typically a private one connected to the detector and a public one connected to the
      local LAN. If the default value of these variables is used then EPICS clients (e.g.
      medm) running on the detector host computer will generate many errors because each
      EPICS PV will appear to be coming from both networks. The solution is to set these
      variables as follows:

      <code>setenv EPICS_CA_AUTO_ADDR_LIST NO</code>
      
      <code>setenv EPICS_CA_ADDR_LIST localhost:XX.YY.ZZ.255</code>

      where XX.YY.ZZ.255 should be replaced with the broadcast address for the public
      network on this computer.

    - EPICS_CA_MAX_ARRAY_BYTES.
      This variable controls the maximum array size that EPICS can transmit with Channel
      Access. The default is only 16kB, which is much too small for most detector data. This
      value must be set to a large enough value on both the EPICS server computer (e.g. the
      one running the areaDetector IOC) and client computer (e.g. the one running medm,
      ImageJ, IDL, etc.). This should be set to a value that is larger than the largest
      waveform record that will be used for the detector.  For example if using a detector
      with 1024x1024 pixels and 4-bytes per pixel (waveform record FTVL=LONG) then
      EPICS_CA_MAX_ARRAY_BYTES would need to be at least 1024 * 1024 * 4 = 4153344.  
      In practice it should be set at least 100 bytes larger than this because there 
      is some overhead.  For example:

      <code>setenv EPICS_CA_MAX_ARRAY_BYTES 4154000</code>

      Do not simply set EPICS_CA_MAX_ARRAY_BYTES to a very large number like 100MB or 1GB.
      EPICS Channel Access allocates buffers of exactly EPICS_CA_MAX_ARRAY bytes whenever
      the required buffer size exceeds 16 kB, and one does not want unnecessarily large
      buffers to be allocated.
      
    - EPICS_DISPLAY_PATH. This variable controls where medm looks for .adl display files.
      If the recommendation below is followed to copy all adl files to a single directory,
      then this environment variable should be defined to point to that directory. For
      example:

      <code>setenv EPICS_DISPLAY_PATH /home/det/epics/adls</code>


* medm display files. 
  It is convenient to copy all medm .adl files to a single directory and then point the
  environment variable EPICS_DISPLAY_PATH to this directory. The alternative is to point
  EPICS_DISPLAY_PATH to a long list of directories where the adl files are located in the
  distributions, which is harder to maintain. On the Pilatus, for example, create a
  directory called /home/det/epics/adls, and put all of the adl files there. To simplify
  copying the adl files to that location use the following one-line script, which can be
  placed in /home/det/bin/sync_adls.

  <code>find /home/det/epics/support -name '*.adl' -exec cp -fv {} /home/det/epics/adls \;</code>

  This script finds all adl files in the epics/support tree and copies them to /home/det/epics/adls.
  That directory must be created before running this script. Similar scripts can be
  used for other Linux detectors (marCCD, mar345, etc.) and can be used on Windows
  as well if Cygwin is installed. Each time a new release of areaDetector is installed
  remove the old versions of each support module (areaDetector, asyn, autosave, etc.)
  and then run this script to install the latest medm files.


Running the IOC Application
===========================

Each example IOC directory comes with a Linux script (start_epics) or a Windows
batch file (start_epics.bat) or both depending on the architectures that the detector
runs on. These scripts provide simple examples of how to start medm and the EPICS
IOC. For example, for the mar345 iocBoot/iocMAR345/start_epics contains the following:

    medm -x -macro "P=13MAR345_1:, R=cam1:" mar345.adl &
    ../../bin/linux-x86/mar345App st.cmd

This script starts medm in execute mode with the appropriate medm display file and
macro parameters, running it in the background. It then runs the IOC application.
This script assumes that iocBoot/iocMAR345 is the default directory when it is run,
which could be added to the command or set in the configuration if this script is
set as the target of a desktop shortcut, etc. The script assumes that EPICS_DISPLAY_PATH
has been defined to be a location where the mar345.adl and related displays that
it loads can be found. You will need to edit the script in your copy of the iocXXX
directory to change the prefix (P) from 13MAR345_1: to whatever prefix you chose
for your IOC. The start_epics script could also be copied to a location in your
PATH (e.g. /home/mar345/bin/start_epics). Add a command like 

    cd /home/mar345/epics/support/areaDetector-2-0/ADmar345/iocs/mar345IOC/iocBoot/iocMAR345
   
at the beginning of the script and then type

    start_epics
    
from any directory to start the EPICS IOC.




# Installing a pre-built version of EPICS on Windows
(5/16/18 PJE)

1.	EPICS Standalone
a.	Download:
i.	http://cars.uchicago.edu/epics/pub/epics_standalone_CARS.zip
b.	Make a directory:
i.	C:\epics\support
c.	Unzip epics_standalone_CARS.zip in the “support” directory.  Note windows extraction will want to put the file into a directory “epics_standalone_CARS”  make sure it unzips to “support”
d.	Change the name of the directory “CARS-1-6beta” to “CARS”
2.	Install DLL’s that are not part of the “epics_standalone_CARS.zip”
a.	libusb-1.0.dll
i.	Under “C:\epics\support\mca-7-6” add the path:
ii.	“..\ bin\windows-x64-static”
iii.	The final path should look like this:
1.	C:\epics\support\mca-7-6\Bin\windows-x64-static
iv.	To this directory copy libusb-1.0.dll.  A copy of this DLL can be found in “libusb” located off of this setup instructions directory.
b.	Measurement Computing
i.	Under “C:\epics\support\measComp-1-3-1” add the path:
ii.	“..\ bin\windows-x64-static”
iii.	The final path should look like this:
1.	C:\epics\support\measComp-1-3-1\bin\windows-x64-static
iv.	To this directory copy cbw64.dll.  A copy of this DLL can be found in “Measurement Computing” located off of this setup instructions directory.
v.	As an alternative you can download the full install package from: 
1.	https://www.mccdaq.com/daq-software/universal-library.aspx
2.	Run installer file is: mccdaq.exe
3.	This will eliminate the need for steps i.  iv. above.
c.	WinPcap
i.	Download and install WinPcap installer it will install the wpcap.dll needed to run a windows IOC.  
ii.	Download it from here: https://www.winpcap.org/install/bin/WinPcap_4_1_3.exe
iii.	The installer file is: WinPcap_4_1_3.exe
3.	Example iocBoot Directory
a.	There is an example iocBoot directory included here.  It’s setup to run the small KB mirror bender using the Newport XPS.
i.	Copy this directory to: C:\epics\support\CARS\iocBoot
ii.	There is a batch file in this directory “start_epics.bat” here is what it contains:
1.	ECHO OFF
2.	call dllPath.bat
3.	..\..\bin\windows-x64-static\CARSApp st.cmd
4.	Pause
b.	Rename this directory for you project and then edit envPaths
i.	envPaths
1.	You need to edit “envPaths” and set “IOC” to the name of the directory off of “ioc_Boot” directory where the ioc is run from for example:
a.	epicsEnvSet("IOC"," ioc13xps_smkb_win64")
c.	Make changes for motors.template and st.cmd as needed.  
4.	Configure Exceed to use MEDM fonts:
a.	Start Exceed
b.	Right-click program in taskbar, go to 'Xconfig'
c.	Select "Screen", uncheck "Close Warning on Exit"
d.	Open "Font Management"
e.	Select on Edit
f.	Select "Import Alias" and locate " s:\win32app\exceed71_xdk\fonts\medm\fonts_sun.ali”
g.	Click "Import" Button
h.	Click "OK"
i.	Close all windows and shutdown Exceed.

