/**
 * GSE_MonoEnergySupport.cpp
 *
 * Support routines for GSE_MonoEnergy.st
 *
 * Author: Mark Rivers
 *
 * Created Feb. 5, 2013
 */

#include <stdio.h>
#include "tinyxml.h"
#include "splint.h"
#include "GSE_MonoSupport.h"

typedef struct measurementTable {
  int numMeasurements;
  double *energy;
  double *gap;
  double *energyToGapCoeffs;
  double *gapToEnergyCoeffs;
} measurementTable_t;

typedef struct harmonicTable {
  int numHarmonics;
  int *harmonics;
  measurementTable_t **pMT;
} harmonicTable_t;

static harmonicTable_t HT;

int GSE_MonoReadCalibration(const char *fileName)
{
  static const char *functionName = "GSE_MonoReadCalibration";

  const char *pHarmonicNum, *pEnergy, *pGap;
  TiXmlDocument doc(fileName);
  TiXmlElement *Harmonics, *Harmonic, *Measurement;
  int i, j;
  measurementTable_t *pMT;

  if (!doc.LoadFile()) {
    fprintf(stderr, "%s: cannot open file %s error=%s\n", 
      functionName, fileName, doc.ErrorDesc());
    return -1;
  }
  Harmonics = doc.FirstChildElement("Harmonics");
  if (!Harmonics) {
    fprintf(stderr, "%s: cannot find Harmonics element\n", 
      functionName);
    return -1;
  }
  // Count the number of harmonics in the file
  for (i=0, Harmonic = Harmonics->FirstChildElement(); 
       Harmonic; 
       i++, Harmonic = Harmonic->NextSiblingElement()) {
  }
  HT.numHarmonics = i;
  HT.harmonics = (int *)calloc(i, sizeof(int *));
  HT.pMT = (measurementTable_t **)calloc(i, sizeof(measurementTable_t *));
  for (i=0, Harmonic = Harmonics->FirstChildElement(); 
       Harmonic; 
       i++, Harmonic = Harmonic->NextSiblingElement()) {
    pHarmonicNum = Harmonic->Attribute("value");
    if (!pHarmonicNum) {
      fprintf(stderr, "%s: value attribute not found for Harmonic\n", 
        functionName);
      return -1;
    }
    HT.harmonics[i] = atoi(pHarmonicNum);
    HT.pMT[i] = (measurementTable_t *)calloc(1, sizeof(measurementTable_t));
    pMT = HT.pMT[i];
    // Count the number of measurements for this harmonic
    for (j=0, Measurement = Harmonic->FirstChildElement(); 
         Measurement; 
         j++, Measurement = Measurement->NextSiblingElement()) {
    }
    pMT->numMeasurements = j;
    pMT->energy =            (double *)calloc(j, sizeof(double));
    pMT->gap =               (double *)calloc(j, sizeof(double));
    pMT->energyToGapCoeffs = (double *)calloc(j, sizeof(double));
    pMT->gapToEnergyCoeffs = (double *)calloc(j, sizeof(double));
    for (j=0, Measurement = Harmonic->FirstChildElement(); 
         Measurement; 
         j++, Measurement = Measurement->NextSiblingElement()) {
      pEnergy = Measurement->Attribute("energy");
      if (!pEnergy) {
        fprintf(stderr, "%s: energy attribute not found for Measurement\n", 
          functionName);
        return -1;
      }
      pGap = Measurement->Attribute("gap");
      if (!pGap) {
        fprintf(stderr, "%s: gap attribute not found for Measurement\n", 
          functionName);
        return -1;
      }
      pMT->energy[j] = atof(pEnergy);
      pMT->gap[j]    = atof(pGap);
      //printf("Harmonic=%s, energy=%s, gap=%s\n", pHarmonicNum, pEnergy, pGap);
    }
    Spline(pMT->gap, pMT->energy, pMT->numMeasurements, 1e35, 1e35, pMT->gapToEnergyCoeffs);
    Spline(pMT->energy, pMT->gap, pMT->numMeasurements, 1e35, 1e35, pMT->energyToGapCoeffs);    
  }
  return 0;
}

int GSE_MonoEnergyToGap(int harmonic, double energy, double *gap)
{
  int i;
  measurementTable_t *pMT;
  
  *gap = 0;
  // Find this harmonic
  for (i=0; i<HT.numHarmonics; i++) {
    if (harmonic == HT.harmonics[i]) break;
  }
  if (i == HT.numHarmonics) return -1;
  pMT = HT.pMT[i];
  if (energy < pMT->energy[0]) return -1;
  if (energy > pMT->energy[pMT->numMeasurements-1]) return -1;
  SplInt(pMT->energy, pMT->gap, pMT->energyToGapCoeffs, pMT->numMeasurements, energy, gap);
  return 0;
}

int GSE_MonoGapToEnergy(int harmonic, double gap, double *energy)
{
  int i;
  measurementTable_t *pMT;
  
  *energy = 0;
  // Find this harmonic
  for (i=0; i<HT.numHarmonics; i++) {
    if (harmonic == HT.harmonics[i]) break;
  }
  if (i == HT.numHarmonics) return -1;
  pMT = HT.pMT[i];
  if (gap < pMT->gap[0]) return -1;
  if (gap > pMT->gap[pMT->numMeasurements-1]) return -1;
  SplInt(pMT->gap, pMT->energy, pMT->gapToEnergyCoeffs, pMT->numMeasurements, gap, energy);
  return 0;
}
