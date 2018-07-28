# Installing Pre-Built EPICS IOCs on Windows

## Overview
EPICS is a client/server system.  The server is often called an IOC (for Input/Output Controller).
It can be run in a real-time OS like vxWorks, or as a standard Linux or Windows application.  
This document describes running an IOC that is a Windows application. 

The server has a database containing EPICS records.
There are records for analog inputs and outputs, binary inputs and outputs, motors, strings, etc.
These can be connected to real hardware, or be "soft" records with no hardware connection.  
Each field in a record is called an EPICS Process Variable (PV).
These PVs are served on the network using a protocol called EPICS Channel Access.  
Channel Access is a layer on top of TCP/IP.
Channel Access clients can write to or read from PVs, and they request that the server send
callback messages (called monitors) when PVs change.

Many different clients can talk to the server.
These include generic GUI clients, Windows or Linux shell commands, and applications written
in nearly any programming language (C, C++, Python, Java, IDL, Matlab, etc.). 

For the generic GUI client this document describes using medm (Motif Editor and Display Module).
It is a simple X11/Motif program that lets you graphically design a screen, with widgets that connect to PVs.  
These can read and/or write to PVs, and for reading it always uses monitors, not polling.

Pre-built binary versions of EPICS applications can be provided for Windows and Linux.
This is very convenient so that it is not necessary to set up a build system to compile the IOC,
which requires significant effort.

The instructions here use the Windows CARSApp.exe application as an example.  CARSApp
is an EPICS application built with support for most of the devices in the 
[EPICS SynApps module](https://www.aps.anl.gov/BCDA/synApps).  This includes
many motors, serial, TCP/IP, and USB devices.  It does not include
support for any [EPICS areaDetector modules](http://cars.uchicago.edu/software/epics/areaDetector.html).
Those are provided as separate pre-built IOC applications.

With some modifications these instructions can be used for other pre-built EPICS IOCs,
or for Linux rather than Windows.

## Install required support libraries
The devices that the CARSApp application can control include Canberra and Amptek multichannel analyzers and
Measurement Computing USB and Ethernet modules.  These require additional support packages 
to be installed, or CARSApp will report missing DLL files when one tries to run it.

### WinPcap
This package provides the libraries needed for the Canberra multichannel analyzers.  
It can be downloaded here: 

https://www.winpcap.org/install/default.htm 

### InstaCal
This package provides the libraries needed for the Measurement Computing devices.
Download and install the InstaCal software from this Web page:

https://www.mccdaq.com/Software-Downloads.aspx 

### libusb-1.0
This library is needed for the Amptek multichannel analyzers. 
It can be downloaded from this Web page:

https://sourceforge.net/projects/libusb/files/libusb-1.0/libusb-1.0.21/libusb-1.0.21.7z/download 

You can use the 7-Zip program to extract the downloaded .7z archive file:

https://www.7-zip.org/download.html 

It unzips into a libusb-1.0.21 directory.  The libusb-1.0.21\lib\liusb-1.0.21\MS64\dll subdirectory must be added to your PATH environment variable.
For example you could put the package in C:\Program Files\libusb-1.0.21 and then add C:\Program Files\\libusb-1.0.21\MS64\dll in your PATH.
That is done with Control Panel/System/Advanced/Environment Variables/Edit, adding it to the existing PATH environment variable.

## Install the pre-built CARS package
The pre-built package can be downloaded here:

http://cars.uchicago.edu/epics/pub/epics_standalone_CARS.zip. 

Create an installation directory for the module.
I typically use C:\EPICS\support.  Unzip the downloaded file into the C:\EPICS\support directory, not into the 
default epics_standalone_CARS directory.

In the CARS/iocBoot directory make a *copy* of one of the existing ioc* directories.  Choose 
a directory that most closely matches the types of devices that you will be using.
Here as an example I assume you have copied ioc13Raman2 to iocTest.
  
By making a copy you will be able to update to later versions of the pre-built module without
losing changes you make in this directory.

cd to the directory you just created, for example iocTest.

Edit st.cmd to change the PV prefix $(PREFIX) to one that is unique to your site. PV prefixes must be unique on the subnet.

Edit the file envPaths to point to the locations of all of the
support modules on your system, e.g. C:\EPICS\support\*.  Normally this step is handled by the EPICS build system, but
when using the prebuilt version this must be manually edited. Typically a global search and replace to change 
`J:/epics/support` to `C:/EPICS/support` is all that is needed.

Do not worry about the path to EPICS_BASE, any other modules in the H:/epics/, or any modules not present
in the C:/EPICS/support directory. They are not used or needed.

Edit the st.cmd file and any .template or .substitutions files to configure them for the devices you will be using in 
your IOC application.  The details of how to do this are device-specific, and are beyond the scope of this
document.

Edit the start_ioc.bat file to contain the following:
```
..\..\bin\windows-x64-static\CARSApp st.cmd
pause
```

Create a shortcut to start_ioc.bat and place it on the desktop or some other convenient location.  Double clicking
the icon for that shortcut will start the IOC application and run the startup script.


## MEDM Display Manager
A display manager is needed to view the EPICS control screens. The EPICS display managers
include MEDM, EDM, CSS, and caQtDM. The CARS control screens are written using MEDM, which is
what I currently recommend and what is covered in this document.   

medm is available for Windows in the
[EPICS Windows Tools MSI installer package](http://www.aps.anl.gov/epics/distributions/win32/index.php).

After installing that package you should add its installation directory (typically C:\Program Files\EPICS Windows Tools)
to your PATH environment variable, following the same method as for the libusb-1.0 directory above.
Adding this directory to your path does two things:
- Allows IOCs and clients to find the caRepeater.exe application which allows clients to be informed when
IOCs are restarted.
- Provides command line tools caget, caput, camonitor, and others which are very useful.


## Configuration

Before running an EPICS IOC application it is usually necessary to configure a number of items.

### EPICS environment variables

There are several environment variables that EPICS uses.

- EPICS_CA_AUTO_ADDR_LIST and EPICS_CA_ADDR_LIST.
  These variables control the IP addresses that EPICS clients use when searching for
  EPICS PVs. The default is EPICS_CA_AUTO_ADDR_LIST=YES and EPICS_CA_ADDR_LIST to be the
  broadcast address of all networks connected to the host. If the computer running the IOC
  and medm has 2 or more network cards, then the default value of these variables must be changed.
  If they are not then EPICS clients (e.g. medm) running on the IOC host computer will generate many errors because each
  EPICS PV will appear to be coming from both networks. The solution is to set these
  variables as follows:

  ```
  EPICS_CA_AUTO_ADDR_LIST=NO
  EPICS_CA_ADDR_LIST=XX.YY.ZZ.255
  ```

  where XX.YY.ZZ.255 should normally be replaced with the broadcast address for the public wired
  network on this computer.

- EPICS_CA_MAX_ARRAY_BYTES.
  This variable controls the maximum array size that EPICS can transmit with Channel
  Access. The default is only 16kB, which is often too small for detector data. This
  value must be set to a large enough value on both the EPICS server computer (e.g. the
  one running the areaDetector IOC) and client computer (e.g. the one running medm,
  Python, ImageJ, IDL, etc.). This should be set to a value that is larger than the largest
  waveform record that will be used.  For example: `EPICS_CA_MAX_ARRAY_BYTES=1000000`.

  Do not simply set EPICS_CA_MAX_ARRAY_BYTES to a very large number like 100MB or 1GB.
  EPICS Channel Access allocates buffers of exactly EPICS_CA_MAX_ARRAY bytes whenever
  the required buffer size exceeds 16 kB, and one does not want unnecessarily large
  buffers to be allocated.
  
- EPICS_DISPLAY_PATH. This variable controls where medm looks for .adl display files.
  If the recommendation below is followed to copy all adl files to a single directory,
  then this environment variable should be defined to point to that directory. For
  example, create a directory C:\EPICS\adls and then set the environment variable
  `EPICS_DISPLAY_PATH=C:\EPICS\adls`.

These environment variables should be created in Control Panel/System/Advanced/Environment Variables.
Added them using the New button in the System environment variables, so they will be available
for all user accounts on the computer.

### medm display files. 
  It is convenient to copy all medm .adl files to a single directory and then point the
  environment variable EPICS_DISPLAY_PATH to this directory. The alternative is to point
  EPICS_DISPLAY_PATH to a long list of directories where the adl files are located in the
  distributions, which is harder to maintain. For example, create a directory C:\EPICS\adls 
  and put all of the adl files there. To simplify copying the adl files to that location use
  the following command.

  ```
  find /drives/c/EPICS/support -name '*.adl' -exec cp -fv {} /drives/c/EPICS/adls \;
  ```

  This command finds all adl files in the EPICS/support tree and copies them to C:\EPICS\adls.
  That directory must be created before running this script.  This command can be run
  in the MobaXterm local terminal Window, or using Cygwin or some other Linux-like
  shell for Windows.

### X11 server
The medm and edm display managers are written for the X11 windows system with Motif.
They thus require an X11 server to be running to display the screens.  On Windows there are
several X11 servers available.

An X11 server that I recommend is [MobaXterm](https://mobaxterm.mobatek.net/).  It is available for
free for personal use, or with reasonable license fees for an enhanced version with support.

[OpenText/Exceed](https://www.opentext.com/what-we-do/products/specialty-technologies/connectivity/exceed/)
is a commercial package that also works well.

### medm fonts
medm needs font aliases in order to display correctly.  The following instructions cover
settings these font aliases for MobaXterm and Exceed.  For other X11 servers the 
procedure will be different.

#### MobaXterm
Get the following zip file: http://cars.uchicago.edu/data/mobaxterm/linux_fonts.zip

Unzip this file and put the directories in C:\Users\[myAccount]\Documents\MobaXterm\slash\usr\share\fonts.
This not only adds the font aliases, but adds standard Linux fonts to MobaXterm that are required for
the aliases.

#### Exceed
- Download this file: https://github.com/epics-extensions/medm/blob/master/medm/fonts.alias.sun
- Click the Raw button in the upper-right and then right-click and save as fonts.sun.ali.
- Start Exceed
- Right-click Exceed in taskbar, go to 'Xconfig'
- Open "Font Management"
- Select Edit
- Select "Import Alias"
- In the From widget click Browse and locate fonts_sun.ali
- In the To widget select "All directories"
- Click "Import" Button
- Click "OK"
- Restart Exceed.

## Create a top-level medm screen
The C:\EPICS\support modules contain complete medm screens for all supported devices.
However, you must create a top-level medm screen for your specific application.
This top-level screen will load the device-specific screens.

You should copy an existing top-level medm .adl file as a starting point.  For example
CARS/CARSApp/op/adl/13Raman2.adl could be copied to iocTest.adl.  Open iocTest.adl
with medm in edit mode, removing unneeded related display entries, and adding new
ones for additional devices.

