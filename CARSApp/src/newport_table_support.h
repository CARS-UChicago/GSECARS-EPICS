/******************************* function prototypes ******************************/
void   calc_target_point(double vR[3], double vD0[3],  
                         double T_AX,  double T_AY,   
                         double d1,    double d2,    
                         double* vT_ptr);

void   calc_target_orient(double T_AX,      double T_AY, 
                          double d1,        double d2, 
                          double* T_X3_ptr, double* T_Y3_ptr, 
                          double* T_Z3_ptr);

void   motor_from_pseudo(double lx,         double lz, 
                         double vD0[3],     double vT[3], 
                         double AX,         double AY, 
                         double AZ,         double T_AX, 
                         double T_AY,       double d1, 
                         double d2,         double* mAY_ret, 
                         double* mBY_ret,   double* mCY_ret, 
                         double* mAX_ret,   double* mBZ_ret, 
                         double* vD_ptr,    double* vDel_ptr, 
                         double* del_r_ret, double* del_angle_ret);

void   pseudo_from_motor(double lx,         double lz, 
                         double vD0[3],     double vT[3], 
                         double* AX_ret,    double* AY_ret, 
                         double* AZ_ret,    double T_AX, 
                         double T_AY,       double d1, 
                         double d2,         double mAY, 
                         double mBY,        double mCY, 
                         double mAX,        double mBZ,  
                         double* vD_ptr,    double* vDel_ptr, 
                         double* del_r_ret, double* del_angle_ret);

double sqr(double x);

double dot_product(double x[3], double y[3]);

void   matrix_x_vector(double m[3][3], double x[3], 
                       double *y_ptr);

void   rot_matrix(double *m_ptr, double AX, 
                  double AY,     double AZ);

void   rot_matrix_2(double *m_ptr, double AX, 
                    double AY,     double AZ);

double v_angle(double v1[3], double v2[3]);

