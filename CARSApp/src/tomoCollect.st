program tomoCollect("P=13LAB:,R=TC:, MCS=13LAB:SIS3820:, BEAM_READY=13LAB:m3.DMOV,"
                    "CAMERA=13IDAPS1:cam1:, FILE=13IDAPS1:netCDF1:,"
                    "ROTATION=13LAB:m1, HORIZONTAL=13LAB:m6, VERTICAL=13LAB:m5,"
                    "OPEN_SHUTTER=13LAB:UnidigBo2, OPEN_VALUE=0, CLOSE_SHUTTER=13LAB:UnidigBo2, CLOSE_VALUE=1")

/*  This sequencer program works with TomoCollect.template.  
 *  It is an on-the-fly tomography data collection server
 *
 *  Mark Rivers
 *  February 22, 2016
 *
*/

%%#include <epicsTime.h>

int flatFieldHorizontal=0;
int flatFieldVertical  =1;
int flatFieldBoth      =2;

int cameraTypeRoper     =0;
int cameraTypeProsilica =1;
int cameraTypePointGrey =2;

/* Motor PVs */
double  rotationMotorPosition;    assign rotationMotorPosition    to "{ROTATION}.VAL";              monitor rotationMotorPosition;
double  rotationMotorRBV;         assign rotationMotorRBV         to "{ROTATION}.RBV";              monitor rotationMotorRBV;
double  rotationMotorVelocity;    assign rotationMotorVelocity    to "{ROTATION}.VELO";             monitor rotationMotorVelocity;
double  rotationMotorVMax;        assign rotationMotorVMax        to "{ROTATION}.VMAX";             monitor rotationMotorVMax;
double  rotationMotorResolution;  assign rotationMotorResolution  to "{ROTATION}.MRES";             monitor rotationMotorResolution;
int     rotationMotorDone;        assign rotationMotorDone        to "{ROTATION.DMOV";              monitor rotationMotorDone;
double  horizontalMotorPosition;  assign horizontalMotorPosition  to "{HORIZONTAL}.VAL";            monitor horizontalMotorPosition;
int     horizontalMotorDone;      assign horizontalMotorDone      to "{HORIZONTAL}.DMOV";           monitor horizontalMotorDone;
double  verticalMotorPosition;    assign verticalMotorPosition    to "{VERTICAL}.VAL";              monitor verticalMotorPosition;
int     verticalMotorDone;        assign verticalMotorDone        to "{VERTICAL}.DMOV";             monitor verticalMotorDone;

/* SIS3820 PVs */
int     mcsEraseStart;            assign mcsEraseStart            to "{MCS}EraseStart";             monitor mcsEraseStart;
int     mcsPrescale;              assign mcsPrescale              to "{MCS}Prescale";               monitor mcsPrescale;
int     mcsStopAll;               assign mcsStopAll               to "{MCS}StopAll";                monitor mcsStopAll;
int     mcsMaxChannels;           assign mcsMaxChannels           to "{MCS}MaxChannels";            monitor mcsMaxChannels;
int     mcsNuseAll;               assign mcsNuseAll               to "{MCS}NuseAll";                monitor mcsNuseAll;
string  mcsChannelAdvance;        assign mcsChannelAdvance        to "{MCS}ChannelAdvance";         monitor mcsChannelAdvance;
double  mcsDwell;                 assign mcsDwell                 to "{MCS}Dwell";                  monitor mcsDwell;
double  mcsLNEOutputWidth;        assign mcsLNEOutputWidth        to "{MCS}LNEOutputWidth";         monitor mcsLNEOutputWidth;

/* Camera PVs */
string  cameraManufacturer;       assign cameraManufacturer       to "{CAMERA}Manufacturer_RBV";    monitor cameraManufacturer;
int     cameraAcquire;            assign cameraAcquire            to "{CAMERA}Acquire";             monitor cameraAcquire;
int     cameraAcquireRBV;         assign cameraAcquireRBV         to "{CAMERA}Acquire_RBV";         monitor cameraAcquireRBV;
int     cameraBinX;               assign cameraBinX               to "{CAMERA}BinX";                monitor cameraBinX;
int     cameraBinY;               assign cameraBinY               to "{CAMERA}BinY";                monitor cameraBinY;
int     cameraState;              assign cameraState              to "{CAMERA}DetectorState_RBV";   monitor cameraState;            
int     cameraArraySizeRBV;       assign cameraArraySizeRBV       to "{CAMERA}ArraySize_RBV";       monitor cameraArraySizeRBV;
double  cameraAcquireTime;        assign cameraAcquireTime        to "{CAMERA}AcquireTime";         monitor cameraAcquireTime;
int     cameraNumImages;          assign cameraNumImages          to "{CAMERA}NumImages";           monitor cameraNumImages;
int     cameraImageMode;          assign cameraImageMode          to "{CAMERA}ImageMode";           monitor cameraImageMode;
int     cameraTriggerMode;        assign cameraTriggerMode        to "{CAMERA}TriggerMode";         monitor cameraTriggerMode;

/* File plugin PVs */
char    filePath[256];            assign filePath                 to "{FILE}FilePath";              monitor filePath;
char    fileName[256];            assign fileName                 to "{FILE}FileName";              monitor fileName;
int     fileNumber;               assign fileNumber               to "{FILE}FileNumber";            monitor fileNumber;
int     fileEnableCallbacks;      assign fileEnableCallbacks      to "{FILE}EnableCallbacks";       monitor fileEnableCallbacks;
int     fileAutoSave;             assign fileAutoSave             to "{FILE}AutoSave";              monitor fileAutoSave;
int     fileAutoIncrement;        assign fileAutoIncrement        to "{FILE}AutoIncrement";         monitor fileAutoIncrement;
int     fileCapture;              assign fileCapture              to "{FILE}Capture";               monitor fileCapture;
int     fileNumCapture;           assign fileNumCapture           to "{FILE}NumCapture";            monitor fileNumCapture;
int     fileNumCapturedRBV;       assign fileNumCapturedRBV       to "{FILE}NumCaptured_RBV";       monitor fileNumCapturedRBV;
int     fileWriteFile;            assign fileWriteFile            to "{FILE}WriteFile";             monitor fileWriteFile;
int     fileWriteFileRBV;         assign fileWriteFileRBV         to "{FILE}WriteFile_RBV";         monitor fileWriteFileRBV;
string  fileWriteMode;            assign fileWriteMode            to "{FILE}FileWriteMode";         monitor fileWriteMode;

/* Tomography PVs */
double  rotationStart;            assign rotationStart            to "{P}{R}RotationStart";         monitor rotationStart;
double  rotationStop;             assign rotationStop             to "{P}{R}RotationStop";          monitor rotationStop;
double  rotationStep;             assign rotationStep             to "{P}{R}RotationStep";          monitor rotationStep;
double  rotationSpeed;            assign rotationSpeed            to "{P}{R}RotationMotorSpeed";    monitor rotationSpeed;
int     numAngles;                assign numAngles                to "{P}{R}NumAngles";             monitor numAngles;
int     returnToStart;            assign returnToStart            to "{P}{R}LeaveRotationMotor";    monitor returnToStart;
double  horizontalSampleIn;       assign horizontalSampleIn       to "{P}{R}HorizontalSampleIn";    monitor horizontalSampleIn;
double  horizontalSampleOut;      assign horizontalSampleOut      to "{P}{R}HorizontalSampleOut";   monitor horizontalSampleOut;
double  verticalSampleIn;         assign verticalSampleIn         to "{P}{R}VerticalSampleIn";      monitor verticalSampleIn;
double  verticalSampleOut;        assign verticalSampleOut        to "{P}{R}VerticalSampleOut";     monitor verticalSampleOut;
int     flatFieldAxis;            assign flatFieldAxis            to "{P}{R}FlatFieldAxis";         monitor flatFieldAxis;
int     anglesBetweenFlats;       assign anglesBetweenFlats       to "{P}{R}AnglesBetweenFlats";    monitor anglesBetweenFlats;
int     numFlatFields;            assign numFlatFields            to "{P}{R}NumFlatFields";         monitor numFlatFields;
int     numDarkCurrents;          assign numDarkCurrents          to "{P}{R}NumDarkCurrents";       monitor numDarkCurrents;
int     collectDarkCurrent;       assign collectDarkCurrent       to "{P}{R}CollectDarkCurrent";    monitor collectDarkCurrent;
evflag  collectDarkCurrent_EF;      sync collectDarkCurrent                 collectDarkCurrent_EF;
int     moveSampleIn;             assign moveSampleIn             to "{P}{R}MoveSampleIn";          monitor moveSampleIn;
evflag  moveSampleIn_EF;            sync moveSampleIn                       moveSampleIn_EF;
int     moveSampleOut;            assign moveSampleOut            to "{P}{R}MoveSampleOut";         monitor moveSampleOut;
evflag  moveSampleOut_EF;           sync moveSampleOut                      moveSampleOut_EF;
char    tomoFilePath[256];        assign tomoFilePath             to "{P}{R}FilePath";              monitor tomoFilePath;
char    tomoFileName[256];        assign tomoFileName             to "{P}{R}FileName";              monitor tomoFileName;
double  exposureTime;             assign exposureTime             to "{P}{R}ExposureTime";          monitor exposureTime;
int     startScan;                assign startScan                to "{P}{R}StartScan";             monitor startScan;
int     abortScan;                assign abortScan                to "{P}{R}AbortScan";             monitor abortScan;
int     scanReady;                assign scanReady                to "{P}{R}ScanReady";
char    scanStatus[256];          assign scanStatus               to "{P}{R}ScanStatus";
string  scanPoint;                assign scanPoint                to "{P}{R}ScanPoint";
string  elapsedTime;              assign elapsedTime              to "{P}{R}ElapsedTime";
string  remainingTime;            assign remainingTime            to "{P}{R}RemainingTime";
string  sampleName;               assign sampleName               to "{P}{R}SampleName";            monitor sampleName;
string  title;                    assign title                    to "{P}{R}Title";                 monitor title;
string  operator;                 assign operator                 to "{P}{R}Operator";              monitor operator;
string  camera;                   assign camera                   to "{P}{R}Camera";                monitor camera;
double  XPixelSize;               assign XPixelSize               to "{P}{R}XPixelSize";            monitor XPixelSize;
double  YPixelSize;               assign YPixelSize               to "{P}{R}YPixelSize";            monitor YPixelSize;
double  energy;                   assign energy                   to "{P}{R}Energy";                monitor energy;
double  darkCurrent;              assign darkCurrent              to "{P}{R}DarkCurrent";           monitor darkCurrent;

int cameraType;

%%epicsTimeStamp currentTime, startTime;

ss tomoCollect {

    state init {
        entry {
            if (strcmp(cameraManufacturer, "Roper Scientific") == 0)
                cameraType = cameraTypeRoper;
            else if (strcmp(cameraManufacturer, "Prosilica") == 0)
                cameraType = cameraTypeProsilica;
            else if (strcmp(cameraManufacturer, "Point Grey Research") == 0)
                cameraType = cameraTypePointGrey;
            else 
                printf("Unknown camera type\n");
            
            if (cameraType == cameraTypePointGrey) {
                fileEnableCallbacks = 1;
                pvPut(fileEnableCallbacks);
                fileCapture = 0;
                pvPut(fileCapture);
                fileNumCapture = 1;
                pvPut(fileNumCapture);
                strcpy(fileWriteMode, "Stream"); 
                pvPut(fileWriteMode);
                fileAutoSave = 0;
                pvPut(fileAutoSave);
            }
        }
        
        when() {
        } state monitor_changes
    }

    state monitor_changes {
        entry {
            printf("state monitor_changes entry\n");
        }
        
        when(moveSampleIn) {
            moveSampleIn = 0;
            pvPut(moveSampleIn);
        } state moveSampleIn

        when(moveSampleOut) {
            moveSampleOut = 0;
            pvPut(moveSampleOut);
        } state moveSampleOut

        when(startScan) {
            startScan = 0;
            pvPut(startScan);
        } state startScan
    }

    state moveSampleIn {
        entry {
            printf("state moveSampleIn entry\n");
            if ((flatFieldAxis == flatFieldHorizontal) ||
                (flatFieldAxis == flatFieldBoth)) {
                horizontalMotorPosition = horizontalSampleIn;
                pvPut(horizontalMotorPosition);
            }
            if ((flatFieldAxis == flatFieldVertical) ||
                (flatFieldAxis == flatFieldBoth)) {
                verticalMotorPosition = verticalSampleIn;
                pvPut(verticalMotorPosition);
            }
        }
        
        when(horizontalMotorDone && verticalMotorDone) {
        } state monitor_changes      
    }

    state moveSampleOut {
        entry {
            printf("state moveSampleOut entry\n");
            if ((flatFieldAxis == flatFieldHorizontal) ||
                (flatFieldAxis == flatFieldBoth)) {
                horizontalMotorPosition = horizontalSampleOut;
                pvPut(horizontalMotorPosition);
            }
            if ((flatFieldAxis == flatFieldVertical) ||
                (flatFieldAxis == flatFieldBoth)) {
                verticalMotorPosition = verticalSampleOut;
                pvPut(verticalMotorPosition);
            }
        }
        
        when(horizontalMotorDone && verticalMotorDone) {
        } state monitor_changes      
    }

    state startScan {
        entry {
            printf("state startScan entry\n");
            /* Get the current system time */
            epicsTimeGetCurrent(&currentTime);
            
            /* Stop the camera from acquiring */
            cameraAcquire=0; 
            pvPut(cameraAcquire);
            
            /* Wait for the camera to stop acquiring */
        }

        when() {
        } state monitor_changes
    }
}
