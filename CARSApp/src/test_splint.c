#include <stdio.h>
#include "splint.h"

#define NUM_POINTS 6
#define INTERP_STEP 0.1

int main(int argc, char *argv[])
{
  double x[NUM_POINTS] = {0, 1, 2, 3, 4, 5};
  double y[NUM_POINTS] = {0, 1, 4, 9, 16, 25};
  double y2[NUM_POINTS];
  double x_interp, y_interp;
  
  Spline(x, y, NUM_POINTS, 1e35, 1e35, y2);
  x_interp = 0.;
  while (1) {
    SplInt(x, y, y2, NUM_POINTS, x_interp, &y_interp);
    printf("X=%f, Y=%f\n", x_interp, y_interp);
    x_interp += 0.1;
    if (x_interp > 5) break;
  }
    
  return 0;
}
  
