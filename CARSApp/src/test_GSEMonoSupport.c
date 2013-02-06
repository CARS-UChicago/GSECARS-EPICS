#include <stdio.h>
#include "GSE_MonoSupport.h"

#define NUM_POINTS 16

int main(int argc, char *argv[])
{
  double energyPred, gapPred;
  int status;
  int i;
  int harmonic[NUM_POINTS]  = {   1,  1,   1,    3,  3,    3,    5,  5,    5,    7,  7,    7,    9,    9,  9,  11};
  double energy[NUM_POINTS] = {   5,  6, 9.1,   14, 16, 20.1,   20, 25, 30.1,   40, 45, 50.1,   50, 60.1, 90, 100};
  double gap[NUM_POINTS]    = {11.1, 12,  18, 11.1, 12,   18, 11.1, 12,   18, 11.1, 12,   18, 11.1,   12, 18, 100};
  
  GSE_MonoReadCalibration("/home/epics/support/CARS/iocBoot/ioc13ida/CD_Mono_XPS/13ID_DS_UndCalibration.xml");
  for (i=0; i<NUM_POINTS; i++) {
    status = GSE_MonoEnergyToGap(harmonic[i], energy[i]*1000., &gapPred);
    printf("Energy to gap, status=%d, harmonic=%d, energy=%f, gap=%f\n", 
      status, harmonic[i], energy[i]*1000., gapPred);
  }
  for (i=0; i<NUM_POINTS; i++) {
    status = GSE_MonoGapToEnergy(harmonic[i], gap[i], &energyPred);
    printf("Energy to gap, status=%d, harmonic=%d, gap=%f, energy=%f\n", 
      status, harmonic[i], gap[i], energyPred/1000.);
  }
  return 0;
}
  
