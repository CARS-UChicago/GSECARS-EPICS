#include <math.h>
#include "newport_table_support.h"

/**********************************************************************/ 
/* functions for newport table                                        */
/* T^2 10-25-01                                                       */ 
/*                                                                    */ 
/**********************************************************************/ 


/**********************************************************************/ 
/************************  calc_target_point **************************/
void   calc_target_point(double vR[3], double T_AX, 
                                double T_AY,  double d1, 
                                double d2,    double* vT_ptr)
{

double vT_R[3], vT2_R[3];
double m[3][3];

vT_R[0] = 0,  vT_R[1] = 0,  vT_R[2] = d1;
vT2_R[0] = 0, vT2_R[1] = 0, vT2_R[2] = d2; 

  if (d2 == 0){
       rot_matrix(&m[0][0], T_AX, T_AY, 0);
       matrix_x_vector(m,vT_R,&vT_R[0]);
  } else {
      rot_matrix_2(&m[0][0], T_AX, T_AY, 0);  /* assuming have mirrors in    */
      vT_R[2] = d1 - d2;                      /* and are doing an AX, AY rot */
      matrix_x_vector(m,vT_R,&vT_R[0]);       /* the two mirrors are         */      
      rot_matrix_2(&m[0][0], T_AX, 0, 0);     /* seperated by d2             */
      matrix_x_vector(m,vT2_R,&vT2_R[0]);
      vT_R[0] = vT_R[0] + vT2_R[0];
      vT_R[1] = vT_R[1] + vT2_R[1];
      vT_R[2] = vT_R[2] + vT2_R[2];
  }

     *(vT_ptr + 0) = vR[0] + vT_R[0];
     *(vT_ptr + 1) = vR[1] + vT_R[1];
     *(vT_ptr + 2) = vR[2] + vT_R[2];



}
/**********************************************************************/ 


/**********************************************************************/ 
/************************  calc_target_orient **************************/
void   calc_target_orient(double T_AX,      double T_AY, 
                                 double d1,        double d2, 
                                 double* T_X3_ptr, double* T_Y3_ptr, 
                                 double* T_Z3_ptr)
{
double T_X0[3], T_Y0[3], T_Z0[3];
double m[3][3];
double T_X3[3], T_Y3[3], T_Z3[3];

T_X0[0] = 1; T_X0[1] = 0; T_X0[2] = 0;
T_Y0[0] = 0; T_Y0[1] = 1; T_Y0[2] = 0;
T_Z0[0] = 0; T_Z0[1] = 0; T_Z0[2] = 1;

/* orientation of the ray coord system */
  if (d2 == 0 ) {
     rot_matrix(&m[0][0],T_AX, T_AY, 0);
  }else{
     rot_matrix_2(&m[0][0],T_AX, T_AY, 0);
  }

matrix_x_vector(m,T_X0,&T_X3[0]);
matrix_x_vector(m,T_Y0,&T_Y3[0]);
matrix_x_vector(m,T_Z0,&T_Z3[0]); 

*(T_X3_ptr+0) = T_X3[0]; *(T_X3_ptr+1) = T_X3[1]; *(T_X3_ptr+2) = T_X3[2];
*(T_Y3_ptr+0) = T_Y3[0]; *(T_Y3_ptr+1) = T_Y3[1]; *(T_Y3_ptr+2) = T_Y3[2];
*(T_Z3_ptr+0) = T_Z3[0]; *(T_Z3_ptr+1) = T_Z3[1]; *(T_Z3_ptr+2) = T_Z3[2];


}
/**********************************************************************/ 


/**********************************************************************/ 
/**********************  motor_from_psuedo ****************************/
void   motor_from_psuedo(double lx,         double lz, 
                                double vD0[3],     double vT[3], 
                                double AX,         double AY, 
                                double AZ,         double T_AX, 
                                double T_AY,       double d1, 
                                double d2,         double* mAY_ret, 
                                double* mBY_ret,   double* mCY_ret, 
                                double* mAX_ret,   double* mBZ_ret, 
                                double* vD_ptr,    double* vDel_ptr, 
                                double* del_r_ret, double* del_angle_ret)
{

double vA0[3], vB0[3],vC0[3];
double vA3[3], vB3[3],vC3[3];
double m[3][3];
double vpA3[3], vpB3[3], vpC3[3]; 
double vD3[3], vDel[3];
double X0[3], Y0[3];
double Y3[3], T_X3[3], T_Y3[3], T_Z3[3];
double temp1, temp2;
double mAY, mBY, mCY, dmX, dmY3;

/* initialize pivot vectors (note this is hard wired!!!) */
vA0[0] = 0;    vA0[1] = 0; vA0[2] = 0;
vB0[0] = lx;   vB0[1] = 0; vB0[2] = 0;
vC0[0] = lx/2; vC0[1] = 0; vC0[2] = lz;

/* init some other useful vectors */
X0[0] = 1; X0[1] = 0; X0[2] = 0;
Y0[0] = 0; Y0[1] = 1; Y0[2] = 0;


/* calc transformed vectors for the table */
rot_matrix(&m[0][0],AX, AY, AZ);
matrix_x_vector(m,vA0,&vpA3[0]);
matrix_x_vector(m,vB0,&vpB3[0]);
matrix_x_vector(m,vC0,&vpC3[0]);
matrix_x_vector(m,vD0,&vD3[0]);
matrix_x_vector(m,Y0,&Y3[0]);


/* vectors and jacks for simple rot of the table about pivot A */
 mAY = -vpA3[1] / Y3[1];          /* this is = 0 */
 vA3[0] = vpA3[0] + mAY*Y3[0] ;   /* ie vA3 = vA0 */
vA3[1] = vpA3[1] + mAY*Y3[1] ;   
vA3[2] = vpA3[2] + mAY*Y3[2] ;

mBY = -vpB3[1] / Y3[1];        
vB3[0] = vpB3[0] + mBY*Y3[0] ;
vB3[1] = vpB3[1] + mBY*Y3[1] ;
vB3[2] = vpB3[2] + mBY*Y3[2] ; 

mCY = -vpC3[1] / Y3[1];        
vC3[0] = vpC3[0] + mCY*Y3[0] ;
vC3[1] = vpC3[1] + mCY*Y3[1] ;
vC3[2] = vpC3[2] + mCY*Y3[2] ;


/* calc delta vector */
vDel[0] = vT[0] - vD3[0];
vDel[1] = vT[1] - vD3[1];
vDel[2] = vT[2] - vD3[2];


/* get the orientation of the ray basis vectors */
calc_target_orient(T_AX, T_AY, d1, d2, &T_X3[0], &T_Y3[0], &T_Z3[0]);

/* do X-trans and a Y3-trans to force vDel parrallel to T_Z3 */
temp1 = temp2 = 0.0;
temp1 = dot_product(Y3,T_X3) * dot_product(vDel,T_Y3) - 
        dot_product(vDel,T_X3) * dot_product(Y3,T_Y3);              
temp2 = dot_product(Y3,T_X3) * dot_product(X0,T_Y3) - 
        dot_product(X0,T_X3) * dot_product(Y3,T_Y3);               
dmX = temp1 / temp2;

dmY3= dot_product(vDel,T_Y3) - dmX * dot_product(X0,T_Y3);
dmY3 = dmY3/dot_product(Y3,T_Y3);


/* update vectors */
/* note that the real pivots dont move in Y and the Y3 translation
   calc above doesn't move the pivots since there is no additional 
   change in the table angle*/
vA3[0] = vA3[0] + dmX;  
vB3[0] = vB3[0] + dmX;
vC3[0] = vC3[0] + dmX;

vD3[0] = vD3[0] + dmX + dmY3*Y3[0];
vD3[1] = vD3[1] + dmY3*Y3[1];
vD3[2] = vD3[2] + dmY3*Y3[2];


/* return values */
 *mAY_ret = mAY + dmY3; 
*mBY_ret = mBY + dmY3; 
*mCY_ret = mCY + dmY3; 
*mAX_ret = vA3[0];     
*mBZ_ret = vB3[2];     
*(vD_ptr+0) = vD3[0];
*(vD_ptr+1) = vD3[1];
*(vD_ptr+2) = vD3[2];

/* also calc and return the new delta vector etc..*/
vDel[0] = vT[0] - vD3[0];
vDel[1] = vT[1] - vD3[1];
vDel[2] = vT[2] - vD3[2];
*(vDel_ptr+0) = vDel[0];
*(vDel_ptr+1) = vDel[1];
*(vDel_ptr+2) = vDel[2];

/* mag of vDel */
*del_r_ret = sqrt(dot_product(vDel,vDel)); 

/* angle btwn vDel and T_Z3 (should be 0 or 180). */ 
*del_angle_ret = v_angle(vDel,T_Z3);


}

/**********************************************************************/ 


/**********************************************************************/ 
/**********************  psuedo_from_motor ****************************/
void psuedo_from_motor(double lx,         double lz, 
                              double vD0[3],     double vT[3], 
                              double* AX_ret,    double* AY_ret, 
                              double* AZ_ret,    double T_AX, 
                              double T_AY,       double d1, 
                              double d2,         double mAY, 
                              double mBY,        double mCY, 
                              double mAX,        double mBZ,  
                              double* vD_ptr,    double* vDel_ptr, 
                              double* del_r_ret, double* del_angle_ret)
{

double t, a, b, x, y;
double AX, AY, AZ;
double m[3][3];
double vD3[3], vDel[3];
double Y0[3], Y3[3];
double T_X3[3], T_Y3[3], T_Z3[3];

/* first translate all mY's by amount to make mAY = 0 */
t = mAY;
mAY = mAY - t;
mBY = mBY - t;
mCY = mCY - t;

/* solve for the psudeo angles */
a = lx;
b = lz;

/* note below solutions are specific to forcing 
  vA0 = [0,0,0], vB0 = [lx,0,0], vC0 = [lx/2,0,lz]  */
/* calc AX */
x = y = 0;
x = -1 / sqrt(sqr(mBY) + sqr(a)) * 
     a / ( sqr(mBY) * sqr(a) - 4*sqr(a) * mBY * mCY + 
           4 * sqr(a) * sqr(mCY) + 4 * sqr(b) * sqr(mBY) + 4 * sqr(b) * sqr(a) ) * 
	 sqrt( ( sqr(mBY) * sqr(a) - 4 * sqr(a) * mBY * mCY + 4 * sqr(a) * sqr(mCY) + 
	         4 * sqr(b) * sqr(mBY) + 4 * sqr(b) * sqr(a) ) * (sqr(mBY) + sqr(a)) ) * 
	( -mBY + 2 * mCY );
y = 2 / ( sqr(mBY) * sqr(a) - 4 * sqr(a) * mBY * mCY + 4 * sqr(a) * sqr(mCY) + 
		 4 * sqr(b) * sqr(mBY) + 4 * sqr(b) * sqr(a) ) * 
	sqrt( ( sqr(mBY) * sqr(a) - 4 * sqr(a) * mBY * mCY + 4 * sqr(a) * sqr(mCY) + 
	    4 * sqr(b) * sqr(mBY) + 4 * sqr(b) * sqr(a) ) *( sqr(mBY) + sqr(a) ) ) * b ;
AX =   atan2(x,y);

/* calc AY */
x = y = 0;
x = mBZ/ sqrt( sqr(mBY) + sqr(a) );
y = 1/( sqr(mBY) + sqr(a) ) * sqrt( ( sqr(mBY) + sqr(a)) * 
                                    ( sqr(mBY) + sqr(a) - sqr(mBZ) ) );
AY =   atan2(x,y);

/* calc AZ */
x = y = 0;
x = mBY / sqrt( sqr(mBY) + sqr(a) );
y = -1 / sqrt( sqr(mBY) + sqr(a) ) * a;
AZ =   atan2(x,y);

/* return values (in radians) */
*AX_ret = AX;
*AY_ret = AY;
*AZ_ret = AZ;


/* now recalc the rotation matrix */
rot_matrix(&m[0][0],AX, AY, AZ);

/* recalc the position of D */
matrix_x_vector(m,vD0,&vD3[0]);
Y0[0] = 0; Y0[1] = 1; Y0[2] = 0;
matrix_x_vector(m,Y0,&Y3[0]);

vD3[0] = vD3[0] + mAX + t*Y3[0];
vD3[1] = vD3[1] + t*Y3[1];
vD3[2] = vD3[2] + t*Y3[2];
*(vD_ptr+0) = vD3[0];
*(vD_ptr+1) = vD3[1];
*(vD_ptr+2) = vD3[2];

/* also calc vDel */ 
vDel[0] = vT[0] - vD3[0];
vDel[1] = vT[1] - vD3[1];
vDel[2] = vT[2] - vD3[2];
*(vDel_ptr+0) = vDel[0];
*(vDel_ptr+1) = vDel[1];
*(vDel_ptr+2) = vDel[2];

/* mag of vDel */
*del_r_ret = sqrt(dot_product(vDel,vDel));
 
/* angle btwn vDel and T_Z3 */ 
calc_target_orient(T_AX, T_AY, d1, d2, &T_X3[0], &T_Y3[0], &T_Z3[0]);
*del_angle_ret = v_angle(vDel,T_Z3);

}
/**********************************************************************/ 


/**********************************************************************/ 
/****************************** sqr ***********************************/
double sqr(double x)
{
return x*x;
}

/**********************************************************************/ 


/**********************************************************************/ 
/****************************** dot_product ***************************/
double dot_product(double x[3], double y[3])
{
double a;

a = x[0] * y[0] +  
    x[1] * y[1] + 
    x[2] * y[2];

return a;

}
/**********************************************************************/ 


/**********************************************************************/ 
/************************ matrix_x_vector *****************************/
void   matrix_x_vector(double m[3][3], double x[3], 
                              double *y_ptr)
{

*(y_ptr+0) = (m[0][0])*x[0] + (m[0][1])*x[1] + (m[0][2])*x[2];
*(y_ptr+1) = (m[1][0])*x[0] + (m[1][1])*x[1] + (m[1][2])*x[2];
*(y_ptr+2) = (m[2][0])*x[0] + (m[2][1])*x[1] + (m[2][2])*x[2];

}
/**********************************************************************/ 


/**********************************************************************/ 
/*************************** rot_matrix *******************************/
void   rot_matrix(double *m_ptr, double AX, 
                         double AY,     double AZ)
{

double n[3][3];
double cx, cy, cz, sx, sy, sz;
int row, col, idx;
idx = 0;

cx = cos(AX); sx = sin(AX);
cy = cos(AY); sy = sin(AY);
cz = cos(AZ); sz = sin(AZ);


/* this is the rotation matrix for an: AY, AX, AZ rotation */
n[0][0] =  cz*cy + sz*sx*sy;  n[0][1] =  sz*cx; n[0][2] = -cz*sy + sz*sx*cy;
n[1][0] = -sz*cy + cz*sx*sy;  n[1][1] =  cz*cx; n[1][2] =  sz*sy + cz*sx*cy;
n[2][0] =  cx*sy;             n[2][1] = -sx;    n[2][2] =  cx*cy;


/* return the transpose of the rotation matrix */
	for (row=0; row < 3; row++){
		for (col = 0; col < 3; col++){
		*(m_ptr + idx) = n[col][row];
		idx++;
		}
	}

}
/**********************************************************************/ 


/**********************************************************************/ 
/*************************** rot_matrix_2 *******************************/
void   rot_matrix_2(double *m_ptr, double AX, 
                           double AY,     double AZ)
{

double n[3][3];
double cx, cy, cz, sx, sy, sz;
int row, col, idx;
idx = 0;

cx = cos(AX); sx = sin(AX);
cy = cos(AY); sy = sin(AY);
cz = cos(AZ); sz = sin(AZ);


/* this is the rotation matrix for an: AX, AY, AZ rotation */
n[0][0] =  cz*cy;  n[0][1] =  cx*sz + sy*sx*cz;  n[0][2] = -sy*cx*cz + sx*sz;
n[1][0] = -sz*cy;  n[1][1] = -sy*sx*sz + cx*cz;  n[1][2] =  sx*cz + sy*cx*sz;
n[2][0] =  sy;     n[2][1] = -cy*sx;             n[2][2] =  cy*cx;   


/* return the transpose of the rotation matrix */
	for (row=0; row < 3; row++){
		for (col = 0; col < 3; col++){
		*(m_ptr + idx) = n[col][row];
		idx++;
		}
	}

}
/**********************************************************************/ 


/**********************************************************************/ 
/*************************** v_angle *******************************/
double v_angle(double v1[3], double v2[3])
{
double mag_v1, mag_v2, v12, x;


mag_v1 = sqrt(dot_product(v1,v1));
mag_v2 = sqrt(dot_product(v2,v2));

v12 = dot_product(v1,v2);

x = v12/(mag_v1 * mag_v2);
if ( fabs(x-1) < 1.e-9) x=1.0;
   
 return acos(x);  /* return val in radians */
}
/**********************************************************************/ 


