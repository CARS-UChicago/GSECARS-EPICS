/* CARSRegister.c */

#include "epicsExport.h"
#include "seqCom.h"
extern struct seqProgram Energy;
extern struct seqProgram Energy_CC;
extern struct seqProgram BM13_Energy;
extern struct seqProgram IDD_LVP_Detector;
extern struct seqProgram BMD_LVP_Detector;
extern struct seqProgram trajectoryScan;
extern struct seqProgram newport_table;
extern struct seqProgram seq_test;
void CARSRegister(void)
{
    seqRegisterSequencerProgram(&Energy);
    seqRegisterSequencerProgram(&Energy_CC);
    seqRegisterSequencerProgram(&BM13_Energy);
    seqRegisterSequencerProgram(&IDD_LVP_Detector);
    seqRegisterSequencerProgram(&BMD_LVP_Detector);
    seqRegisterSequencerProgram(&trajectoryScan);
    seqRegisterSequencerProgram(&newport_table);
    seqRegisterSequencerProgram(&seq_test);
    seqRegisterSequencerCommands();
}

epicsExportRegistrar(CARSRegister);
