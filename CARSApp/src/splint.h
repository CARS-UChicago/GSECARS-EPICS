#ifdef __cplusplus
extern "C" {
#endif

void Spline(double X[], double Y[], int N, double YP1, double YPN, double Y2[]);     
void SplInt(double XA[], double YA[],double Y2A[], int N, double X, double *Y);

#ifdef __cplusplus
}
#endif
