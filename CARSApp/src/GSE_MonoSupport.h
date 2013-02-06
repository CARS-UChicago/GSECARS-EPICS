/**
 * GSE_MonoEnergySupport.cpp
 *
 * Support routines for GSE_MonoEnergy.st
 *
 * Author: Mark Rivers
 *
 * Created Feb. 5, 2013
 */

#ifdef __cplusplus
extern "C" {
#endif

int GSE_MonoReadCalibration(const char *fileName);
int GSE_MonoEnergyToGap(int harmonic, double energy, double *gap);
int GSE_MonoGapToEnergy(int harmonic, double gap, double *energy);

#ifdef __cplusplus
}
#endif
