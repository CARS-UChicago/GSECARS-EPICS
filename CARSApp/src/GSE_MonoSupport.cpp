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
#include <libxml/parser.h>
#include "splint.h"
#include "GSE_MonoSupport.h"
#include <epicsExport.h>

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
  xmlDocPtr doc;
  xmlNode *Harmonics, *Harmonic, *Measurement;
  int i, j;
  measurementTable_t *pMT;

  doc = xmlReadFile(fileName, NULL, 0);
  if (doc == NULL) {
    fprintf(stderr, "%s: cannot open file %s\n", 
      functionName, fileName);
    return -1;
  }
  Harmonics = xmlDocGetRootElement(doc);
  if (!Harmonics || (!xmlStrEqual(Harmonics->name, (const xmlChar *)"Harmonics"))) {
    fprintf(stderr, "%s: cannot find Harmonics element\n", 
      functionName);
    return -1;
  }
  // Count the number of harmonics in the file
  for (i=0, Harmonic = xmlFirstElementChild(Harmonics); 
       Harmonic; 
       i++, Harmonic = xmlNextElementSibling(Harmonic)) {
  }
  HT.numHarmonics = i;
  HT.harmonics = (int *)calloc(i, sizeof(int *));
  HT.pMT = (measurementTable_t **)calloc(i, sizeof(measurementTable_t *));
  for (i=0, Harmonic = xmlFirstElementChild(Harmonics); 
       Harmonic; 
       i++, Harmonic = xmlNextElementSibling(Harmonic)) {
    pHarmonicNum = (const char *)xmlGetProp(Harmonic, (const xmlChar *)"value");
    if (!pHarmonicNum) {
      fprintf(stderr, "%s: value attribute not found for Harmonic\n", 
        functionName);
      return -1;
    }
    HT.harmonics[i] = atoi(pHarmonicNum);
    HT.pMT[i] = (measurementTable_t *)calloc(1, sizeof(measurementTable_t));
    pMT = HT.pMT[i];
    // Count the number of measurements for this harmonic
    for (j=0, Measurement = xmlFirstElementChild(Harmonic); 
         Measurement; 
         j++, Measurement = xmlNextElementSibling(Measurement)) {
    }
    pMT->numMeasurements = j;
    pMT->energy =            (double *)calloc(j, sizeof(double));
    pMT->gap =               (double *)calloc(j, sizeof(double));
    pMT->energyToGapCoeffs = (double *)calloc(j, sizeof(double));
    pMT->gapToEnergyCoeffs = (double *)calloc(j, sizeof(double));
    for (j=0, Measurement = xmlFirstElementChild(Harmonic); 
         Measurement; 
         j++, Measurement = xmlNextElementSibling(Measurement)) {
      pEnergy= (const char *)xmlGetProp(Measurement, (const xmlChar *)"energy");
      if (!pEnergy) {
        fprintf(stderr, "%s: energy attribute not found for Measurement\n", 
          functionName);
        return -1;
      }
      pGap= (const char *)xmlGetProp(Measurement, (const xmlChar *)"gap");
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
