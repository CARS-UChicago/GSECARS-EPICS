/*
  File: SplInt.c
  Author: K.R. Sloan
  Last Modified: 14 November 1989
  Purpose: cubic spline interpolation
  References: Numerical Recipes, pp.86-89

  Note: the variable names (and typography) have been kept close
        to the original FORTRASH, to make it easy to compare with the
        original. 
   
  BUT: vectors are 0-BASED, rather than 1-based. Beware!
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define NATURAL 1.0e30

/*
  Given arrays X and Y of length N containing a tabulted function, i.e.
  Y[I] = f(X[I]), with X[0]<X[1]<...<X[N-1], and given values YP1 and YPN,
  for the first derivative o the interpolating function at points 0 and N-1,
  respectively, this routine returns an array Y2 of length N which contains
  the second derivatives of the inerpolting function at the tabulated points
  X[I].  If YP1 and/or YPN are equal to 1x10^30 or larger, the routine is
  signalled to set the corresponding boundary condition for a natural spline,
  with zero second derivative on that boundary.
 */

void Spline(X, Y, N, YP1, YPN, Y2)     
 double X[];
 double Y[];
 int N;
 double YP1, YPN;
 double Y2[];
 {
  double *U;
  double SIG, P, UN, QN;
  int I, K;

  U = (double *)malloc(sizeof (double) * N);
  if ((double *)0 == U)
   { fprintf(stderr,"Spline: malloc failed\n"); return;}

  if (YP1 >= NATURAL) { Y2[0] = 0.0; U[0] = 0.0;}
  else 
   {
    Y2[0] = -0.5;
    U[0] = (3.0/(X[1]-X[0]))*((Y[1]-Y[0])/(X[1]-X[0])-YP1);
   }

  if (YPN >= NATURAL) { QN = 0.0; UN = 0.0;}
  else 
   {
    QN = 0.5;
    UN = (3.0/(X[N-1]-X[N-2]))*(YPN-(Y[N-1]-Y[N-2])/(X[N-1]-X[N-2]));
   }
   
  /*
    The decomposition loop of the tridiagonal algorithm.  Y2 and U
    are used to store the decomposed factors.
   */
  for (I=1;I < (N-1); I++)
   {
    SIG = (X[I]-X[I-1])/(X[I+1]-X[I-1]);
    P = SIG*Y2[I-1] + 2.0;
    Y2[I] = (SIG-1.0)/P;
    U[I] =  (6.0*( (Y[I+1]-Y[I])/(X[I+1]-X[I])
                  -(Y[I]-Y[I-1])/(X[I]-X[I-1]))
                /(X[I+1]-X[I-1])
            - SIG*U[I-1])/P; 
   }
  
  Y2[N-1] = (UN-QN*U[N-2])/(QN*Y2[N-2]+1.0);

  /*
    backsubstitution loop of the tridiagonal algorithm 
   */
  for (K=N-2; K>=0; K--)
   {
    Y2[K] = Y2[K]*Y2[K+1] + U[K];
   }  

  free(U);
 }

/*
  Given the arrays XA and YA of length N, which tabulate a function
  (with the XA's in increasing order), and given the array Y2A, which 
  is the output fro Spline above, and given a value of X,
  this routine returns a cubic-spline interpolated value Y.
 */
void SplInt(XA, YA, Y2A, N, X, Y)
 double XA[];
 double YA[]; 
 double Y2A[];
 int N;
 double X;
 double *Y;
 {
  int KLO, KHI, K;
  double H, A, B;

  /* use bisection to find the right interval */
  for(KLO=0,KHI=N-1; (KHI-KLO)>1; )
   {
    K = (KHI+KLO)/2;
    if (XA[K]>X) KHI = K; else KLO = K;
   } 
  H = XA[KHI]-XA[KLO];
  if (0.0 == H) {fprintf(stderr,"SplInt: bad XA\n"); return;}
  A = (XA[KHI]-X)/H;
  B = (X-XA[KLO])/H;
  *Y = A*YA[KLO] + B*YA[KHI]
      +((A*A*A-A)*Y2A[KLO] + (B*B*B-B)*Y2A[KHI])*(H*H)/6.0;
 }
