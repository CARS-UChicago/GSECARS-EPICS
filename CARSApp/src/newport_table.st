program newport_table("P=13IDC:,T=NewTab1:, M1=m33,M2=m34,M3=m35,M4=m36,M5=m37,PM1=pm1,PM2=pm2,PM3=pm3,PM4=pm4,PM5=pm5,PM6=pm6,PM7=pm7,PM8=pm8") 

/*  Newport 5-motor table sequencer program     */
/*  T^2 10-25-01                                */
/*  T^2 10-29-01:   changed call to calc_target */
/*  T^2 10-30-01:   added D and T PV's          */

%% #include "newport_table_support.h"
%% #include <math.h>

%% int newport_tableDebug = 0;

/*************** The real motors ********************************************/
/* drive values */
double mAY_drive;  assign  mAY_drive  to "{P}{M1}.VAL";  monitor mAY_drive;
double mBY_drive;  assign  mBY_drive  to "{P}{M2}.VAL";  monitor mBY_drive;
double mCY_drive;  assign  mCY_drive  to "{P}{M3}.VAL";  monitor mCY_drive;
double mBZ_drive;  assign  mBZ_drive  to "{P}{M4}.VAL";  monitor mBZ_drive;
double mAX_drive;  assign  mAX_drive  to "{P}{M5}.VAL";  monitor mAX_drive;
/* read back values */
double mAY_rbv;  assign  mAY_rbv  to "{P}{M1}.RBV";  monitor mAY_rbv;
double mBY_rbv;  assign  mBY_rbv  to "{P}{M2}.RBV";  monitor mBY_rbv;
double mCY_rbv;  assign  mCY_rbv  to "{P}{M3}.RBV";  monitor mCY_rbv;
double mBZ_rbv;  assign  mBZ_rbv  to "{P}{M4}.RBV";  monitor mBZ_rbv;
double mAX_rbv;  assign  mAX_rbv  to "{P}{M5}.RBV";  monitor mAX_rbv;
/* event flags */
evflag   mAY_drive_mon;    sync mAY_drive    mAY_drive_mon;
evflag   mBY_drive_mon;    sync mBY_drive    mBY_drive_mon;
evflag   mCY_drive_mon;    sync mCY_drive    mCY_drive_mon;
evflag   mAX_drive_mon;    sync mAX_drive    mAX_drive_mon;
evflag   mBZ_drive_mon;    sync mBZ_drive    mBZ_drive_mon;
evflag   mAY_rbv_mon;      sync mAY_rbv      mAY_rbv_mon;
evflag   mBY_rbv_mon;      sync mBY_rbv      mBY_rbv_mon;
evflag   mCY_rbv_mon;      sync mCY_rbv      mCY_rbv_mon;
evflag   mAX_rbv_mon;      sync mAX_rbv      mAX_rbv_mon;
evflag   mBZ_rbv_mon;      sync mBZ_rbv      mBZ_rbv_mon;


/*********************** Pseudomotors ****************************************/
/******* Table Angles **************/
/* Pseudomotor AX*/
double pmAX_drive; assign pmAX_drive  to "{P}{PM1}:Move";     monitor pmAX_drive;
double pmAX_rbv;   assign pmAX_rbv    to "{P}{PM1}:Readback";
/* Pseudomotor AY*/
double pmAY_drive; assign pmAY_drive  to "{P}{PM2}:Move";     monitor pmAY_drive;
double pmAY_rbv;   assign pmAY_rbv    to "{P}{PM2}:Readback";
/* Pseudomotor AZ*/
double pmAZ_drive; assign pmAZ_drive  to "{P}{PM3}:Move";     monitor pmAZ_drive;
double pmAZ_rbv;   assign pmAZ_rbv    to "{P}{PM3}:Readback";

/******* Rotation Point Translation and Angles *****/
/* Pseudomotor RX*/
double pmRX_drive; assign pmRX_drive  to "{P}{PM4}:Move";     monitor pmRX_drive;
double pmRX_rbv;   assign pmRX_rbv    to "{P}{PM4}:Readback";
/* Pseudomotor RY*/
double pmRY_drive; assign pmRY_drive  to "{P}{PM5}:Move";     monitor pmRY_drive;
double pmRY_rbv;   assign pmRY_rbv    to "{P}{PM5}:Readback";
/* Pseudomotor RZ*/
double pmRZ_drive; assign pmRZ_drive  to "{P}{PM6}:Move";     monitor pmRZ_drive;
double pmRZ_rbv;   assign pmRZ_rbv    to "{P}{PM6}:Readback";
/* Pseudomotor T_AX*/
double pmT_AX_drive; assign pmT_AX_drive  to "{P}{PM7}:Move";     monitor pmT_AX_drive;
double pmT_AX_rbv;   assign pmT_AX_rbv    to "{P}{PM7}:Readback";
/* Pseudomotor T_AY*/
double pmT_AY_drive; assign pmT_AY_drive  to "{P}{PM8}:Move";    monitor pmT_AY_drive;
double pmT_AY_rbv;   assign pmT_AY_rbv    to "{P}{PM8}:Readback";


/* monitors and event flags */
evflag pmAX_drive_mon;    sync pmAX_drive     pmAX_drive_mon;
evflag pmAY_drive_mon;    sync pmAY_drive     pmAY_drive_mon;
evflag pmAZ_drive_mon;    sync pmAZ_drive     pmAZ_drive_mon;
evflag pmRX_drive_mon;    sync pmRX_drive     pmRX_drive_mon;
evflag pmRY_drive_mon;    sync pmRY_drive     pmRY_drive_mon;
evflag pmRZ_drive_mon;    sync pmRZ_drive     pmRZ_drive_mon;
evflag pmT_AX_drive_mon;  sync pmT_AX_drive   pmT_AX_drive_mon;
evflag pmT_AY_drive_mon;  sync pmT_AY_drive   pmT_AY_drive_mon;


/************ flag for update translation *******************************************/
int trans_flag;   assign trans_flag to "{P}{T}F1"; monitor trans_flag;


/************ Motor motion monitors ************************************************/
int      motors_stopped;      assign   motors_stopped to "{P}{T}M_Done";  monitor motors_stopped;
evflag   motors_stopped_mon;  sync     motors_stopped     motors_stopped_mon;


/************************ Constants Defining the table geom and fixed point *************/
double lx;   assign lx   to "{P}{T}lx.VAL"; monitor lx;
double lz;   assign lz   to "{P}{T}lz.VAL"; monitor lz;
double vD0[3];
assign vD0[0]  to "{P}{T}D0x.VAL"; 
assign vD0[1]  to "{P}{T}D0y.VAL";
assign vD0[2]  to "{P}{T}D0z.VAL";
monitor vD0;

evflag lx_mon;   sync lx   lx_mon;
evflag lz_mon;   sync lz   lz_mon;
evflag vD0_mon;  sync vD0  vD0_mon;  

/************************ Constants Defining the target point *******************/
double d1;   assign d1   to "{P}{T}d1.VAL"; monitor d1;
double d2;   assign d2   to "{P}{T}d2.VAL"; monitor d2;
evflag d1_mon;  sync d1  d1_mon;
evflag d2_mon;  sync d2  d2_mon;

/************************ Diagnostics PV's ****************************************/
double DELTA_R;       assign DELTA_R       to "{P}{T}DELTA_R.VAL";     
double DELTA_ANGLE;   assign DELTA_ANGLE   to "{P}{T}DELTA_ANGLE.VAL"; 

double DX;   assign DX   to "{P}{T}DX.VAL"; 
double DY;   assign DY   to "{P}{T}DY.VAL";
double DZ;   assign DZ   to "{P}{T}DZ.VAL";

double TX;   assign TX   to "{P}{T}TX.VAL"; 
double TY;   assign TY   to "{P}{T}TY.VAL";
double TZ;   assign TZ   to "{P}{T}TZ.VAL";

/**************************** additional local variables ****************/
double dtor; /* Degrees to radians */

double AX;
double AY;
double AZ;
double vD[3]; 

double T_AX;
double T_AY; 
double vR[3];
double vT[3];

double vDel[3];
double del_r;
double del_angle;  
double mAY;
double mBY;
double mCY;
double mAX;
double mBZ;


/************************** start snl **********************************/

ss NewportTable {
/*** 1.  initialize ***/
  state init {
        when() {
            dtor = 4. * atan(1.) / 180.;
            efSet(mAY_rbv_mon);         /* Force calculation first time through  */
            efClear(pmAX_drive_mon);     /* ie force #2.3 to be evaluated         */
            efClear(pmAY_drive_mon);     /* + Don't move motors on initialization */
            efClear(pmAZ_drive_mon);
            efClear(pmRX_drive_mon);
            efClear(pmRY_drive_mon);
            efClear(pmRZ_drive_mon);
            efClear(pmT_AX_drive_mon);
            efClear(pmT_AY_drive_mon);
if (newport_tableDebug) printf("state 1, mAY_rbv==%f\n", mAY_rbv);
        } state monitor_changes
  }

/*** 2. monitor changes ***/
  state monitor_changes {
        /*** 2.1. drive a pseudo motor ***/
        when(efTestAndClear(pmAX_drive_mon) || 
             efTestAndClear(pmAY_drive_mon) ||
             efTestAndClear(pmAZ_drive_mon) ||
             efTestAndClear(pmRX_drive_mon) ||
             efTestAndClear(pmRY_drive_mon) ||
             efTestAndClear(pmRZ_drive_mon) ||
             efTestAndClear(pmT_AX_drive_mon) ||
             efTestAndClear(pmT_AY_drive_mon) ) {
            /* do the foreward calc and drive real motors  */
if (newport_tableDebug) printf("state 2.1\n");
            
            /* calc the target point */
            T_AX =  pmT_AX_drive*dtor;
            T_AY =  pmT_AY_drive*dtor;  
            vR[0] = pmRX_drive;
             vR[1] = pmRY_drive;
            vR[2] = pmRZ_drive;       
            calc_target_point(vR, vD0, T_AX, T_AY, d1, d2, &vT[0]);

            /* calc the real motor positions */
            AX = pmAX_drive*dtor;
            AY = pmAY_drive*dtor;
            AZ = pmAZ_drive*dtor;
            motor_from_pseudo(lx, lz, vD0, vT, AX, AY, AZ, T_AX, T_AY,d1,d2,
                              &mAY, &mBY, &mCY, &mAX, &mBZ, &vD[0],
                              &vDel[0],&del_r,&del_angle);

            /* drive the real motors */
            mAY_drive = mAY;   pvPut(mAY_drive);
            mBY_drive = mBY;   pvPut(mBY_drive);
            mCY_drive = mCY;   pvPut(mCY_drive);
            mAX_drive = mAX;   pvPut(mAX_drive);
            mBZ_drive = mBZ;   pvPut(mBZ_drive); 
            
            /* also update these diagnostic pvs' 
               note when calc here these are based on the 
               drive values, not the rbvs !!!! */
            DELTA_R = del_r;               pvPut(DELTA_R);     
            DELTA_ANGLE = del_angle/dtor;  pvPut(DELTA_ANGLE); 
            DX = vD[0]; pvPut(DX);
            DY = vD[1]; pvPut(DY);
            DZ = vD[2]; pvPut(DZ);
            TX = vT[0]; pvPut(TX);
            TY = vT[1]; pvPut(TY);
            TZ = vT[2]; pvPut(TZ);

        } state monitor_changes


        /*** 2.2. Real motors have all stopped moving or a geom parameter has changed ***/
        when((efTestAndClear(motors_stopped_mon) && motors_stopped == 1) || 
             efTestAndClear(lx_mon)      ||
             efTestAndClear(lz_mon)      ||
             efTestAndClear(vD0_mon)     ||
             efTestAndClear(d1_mon)      ||  
             efTestAndClear(d2_mon)) {
if (newport_tableDebug) printf("state 2.2\n");
        } state update_readbacks  /* call #3 to get pseudo-motor rbv's correct */

        /*** 2.3. A real motor readback val has changed ***/
        when(efTestAndClear(mAY_rbv_mon) || 
             efTestAndClear(mBY_rbv_mon) ||
             efTestAndClear(mCY_rbv_mon) ||
             efTestAndClear(mAX_rbv_mon) || 
             efTestAndClear(mBZ_rbv_mon)) {
             /* Update pseudo motor readbacks by calling #3 */
if (newport_tableDebug) printf("state 2.3\n");
        } state update_readbacks
 
        /*** 2.4. Put the table on the ray with no angle changes ***/           
        when(trans_flag == 1) {
if (newport_tableDebug) printf("state 2.4\n");

            /* recalc the target point */
            T_AX =  pmT_AX_drive*dtor;
            T_AY =  pmT_AY_drive*dtor;  
            vR[0] = pmRX_drive;
             vR[1] = pmRY_drive;
            vR[2] = pmRZ_drive;
            calc_target_point(vR, vD0, T_AX, T_AY, d1, d2, &vT[0]);

            /* recalc the real-motor positions */
            AX = pmAX_drive*dtor;
            AY = pmAY_drive*dtor;
            AZ = pmAZ_drive*dtor;
            motor_from_pseudo(lx, lz, vD0, vT, AX, AY, AZ, T_AX, T_AY,d1,d2,
                              &mAY, &mBY, &mCY, &mAX, &mBZ, &vD[0],
                              &vDel[0],&del_r,&del_angle);

            /* drive the real motors */
            mAY_drive = mAY;  pvPut(mAY_drive); 
            mBY_drive = mBY;  pvPut(mBY_drive); 
            mCY_drive = mCY;  pvPut(mCY_drive);
            mAX_drive = mAX;  pvPut(mAX_drive);
            mBZ_drive = mBZ;  pvPut(mBZ_drive);

          /* also update these diagnostic pvs' 
             note when calc here these are based on the 
             drive values, not the rbvs !!!! */
            DELTA_R = del_r;          pvPut(DELTA_R);          
            DELTA_ANGLE = del_angle/dtor;  pvPut(DELTA_ANGLE); 
            DX = vD[0]; pvPut(DX);
            DY = vD[1]; pvPut(DY);
            DZ = vD[2]; pvPut(DZ);
            TX = vT[0]; pvPut(TX);
            TY = vT[1]; pvPut(TY);
            TZ = vT[2]; pvPut(TZ);

            trans_flag = 0; pvPut(trans_flag);

        } state monitor_changes
  }

/*** 3. update readbacks ***/
  state update_readbacks {
        when () {
if (newport_tableDebug) printf("state 3\n");
         /* Something has changed which requires 
            recomputing pseudomotor readback positions */

            /* recalc the target point */
            T_AX  = pmT_AX_drive*dtor;
            T_AY  = pmT_AY_drive*dtor;  
            vR[0] = pmRX_drive;
             vR[1] = pmRY_drive;
            vR[2] = pmRZ_drive; 
            calc_target_point(vR, vD0, T_AX, T_AY, d1, d2, &vT[0]);

            /* recalc the pseudo-motor positions */
            mAY = mAY_rbv;
            mBY = mBY_rbv;
            mCY = mCY_rbv;
            mAX = mAX_rbv;
            mBZ = mBZ_rbv;
            pseudo_from_motor(lx, lz, vD0, vT,&AX, &AY, &AZ, T_AX, T_AY,d1,d2,
                              mAY, mBY, mCY, mAX, mBZ, &vD[0], &vDel[0],
                              &del_r,&del_angle);

            /* update rbvs of table angles */
            pmAX_rbv = AX/dtor;  pvPut(pmAX_rbv);
            pmAY_rbv = AY/dtor;  pvPut(pmAY_rbv);
            pmAZ_rbv = AZ/dtor;  pvPut(pmAZ_rbv);

            /* update rbvs of the ray */
            /* note that these rbv's are same as drive vals */ 
            pmT_AX_rbv = T_AX / dtor;  pvPut(pmT_AX_rbv);
            pmT_AY_rbv = T_AY / dtor;  pvPut(pmT_AY_rbv);
            pmRX_rbv = vR[0];          pvPut(pmRX_rbv);
            pmRY_rbv = vR[1];          pvPut(pmRY_rbv);
            pmRZ_rbv = vR[2];          pvPut(pmRZ_rbv); 
 
            /* also update these diagnostic pvs' 
               note when calc here these are based on the rbvs 
               which is what we want !!!! */
            DELTA_R = del_r;               pvPut(DELTA_R);
            DELTA_ANGLE = del_angle/dtor;  pvPut(DELTA_ANGLE);
            DX = vD[0]; pvPut(DX);
            DY = vD[1]; pvPut(DY);
            DZ = vD[2]; pvPut(DZ);
            TX = vT[0]; pvPut(TX);
            TY = vT[1]; pvPut(TY);
            TZ = vT[2]; pvPut(TZ);

        } state monitor_changes
  }

}

