program Newport_Table("P=13IDC:,mAY=m33,mBY=m34,mCY=m35,mAX=m37,mBZ=m36,AX=pm1,AY=pm2,AZ=pm3,VX=pm4,VY=pm5,VZ=pm6,V_AX=pm7,V_AY=pm8") 

/*  Newport 5-motor table */

%% #include "newport_table_support.h"
%% #include <math.h>

/*************** The real motors ********************************************/
/* drive values */
double mAY_drive;  assign  mAY_drive  to "{P}{mAY}.VAL";  monitor mAY_drive;
double mBY_drive;  assign  mBY_drive  to "{P}{mBY}.VAL";  monitor mBY_drive;
double mCY_drive;  assign  mCY_drive  to "{P}{mCY}.VAL";  monitor mCY_drive;
double mAX_drive;  assign  mAX_drive  to "{P}{mAX}.VAL";  monitor mAX_drive;
double mBZ_drive;  assign  mBZ_drive  to "{P}{mBZ}.VAL";  monitor mBZ_drive;
/* read back values */
double mAY_rbv;  assign  mAY_rbv  to "{P}{mAY}.RBV";  monitor mAY_rbv;
double mBY_rbv;  assign  mBY_rbv  to "{P}{mBY}.RBV";  monitor mBY_rbv;
double mCY_rbv;  assign  mCY_rbv  to "{P}{mCY}.RBV";  monitor mCY_rbv;
double mAX_rbv;  assign  mAX_rbv  to "{P}{mAX}.RBV";  monitor mAX_rbv;
double mBZ_rbv;  assign  mBZ_rbv  to "{P}{mBZ}.RBV";  monitor mBZ_rbv;
/* event flags */
evflag mAY_drive_mon;  sync mAY_drive  mAY_drive_mon;
evflag mBY_drive_mon;  sync mBY_drive  mBY_drive_mon;
evflag mCY_drive_mon;  sync mCY_drive  mCY_drive_mon;
evflag mAX_drive_mon;  sync mAX_drive  mAX_drive_mon;
evflag mBZ_drive_mon;  sync mBZ_drive  mBZ_drive_mon;
evflag mAY_rbv_mon;  sync mAY_rbv  mAY_rbv_mon;
evflag mBY_rbv_mon;  sync mBY_rbv  mBY_rbv_mon;
evflag mCY_rbv_mon;  sync mCY_rbv  mCY_rbv_mon;
evflag mAX_rbv_mon;  sync mAX_rbv  mAX_rbv_mon;
evflag mBZ_rbv_mon;  sync mBZ_rbv  mBZ_rbv_mon;


/*********************** Pseudomotors ****************************************/

/******* Table Angles **************/
/* Pseudomotor AX*/
double pmAX_drive; assign pmAX_drive  to "{P}{AX}.VAL";    monitor pmAX_drive;
double pmAX_move;  assign pmAX_move   to "{P}{AX}Move";    monitor pmAX_move;
double pmAX_rbv;   assign pmAX_rbv    to "{P}{AX}Readback";
double pmAX_set;   assign pmAX_set    to "{P}{AX}.SET";
/* Pseudomotor AY*/
double pmAY_drive; assign pmAY_drive  to "{P}{AY}.VAL";    monitor pmAY_drive;
double pmAY_move;  assign pmAY_move   to "{P}{AY}Move";    monitor pmAY_move;
double pmAY_rbv;   assign pmAY_rbv    to "{P}{AY}Readback";
double pmAY_set;   assign pmAY_set    to "{P}{AY}.SET";
/* Pseudomotor AZ*/
double pmAZ_drive; assign pmAZ_drive  to "{P}{AZ}.VAL";    monitor pmAZ_drive;
double pmAZ_move;  assign pmAZ_move   to "{P}{AZ}Move";    monitor pmAZ_move;
double pmAZ_rbv;   assign pmAZ_rbv    to "{P}{AZ}Readback";
double pmAZ_set;   assign pmAZ_set    to "{P}{AZ}.SET";

/******* Rotation Point Translation and Angles *****/
/* Pseudomotor RX*/
double pmRX_drive; assign pmRX_drive  to "{P}{VX}.VAL";    monitor pmRX_drive;
double pmRX_move;  assign pmRX_move   to "{P}{VX}Move";    monitor pmRX_move;
double pmRX_rbv;   assign pmRX_rbv    to "{P}{VX}Readback";
double pmRX_set;   assign pmRX_set    to "{P}{VX}.SET";
/* Pseudomotor RY*/
double pmRY_drive; assign pmRY_drive  to "{P}{VY}.VAL";    monitor pmRY_drive;
double pmRY_move;  assign pmRY_move   to "{P}{VY}Move";    monitor pmRY_move;
double pmRY_rbv;   assign pmRY_rbv    to "{P}{VY}Readback";
double pmRY_set;   assign pmRY_set    to "{P}{VY}.SET";
/* Pseudomotor RZ*/
double pmRZ_drive; assign pmRZ_drive  to "{P}{VZ}.VAL";    monitor pmRZ_drive;
double pmRZ_move;  assign pmRZ_move   to "{P}{VZ}Move";    monitor pmRZ_move;
double pmRZ_rbv;   assign pmRZ_rbv    to "{P}{VZ}Readback";
double pmRZ_set;   assign pmRZ_set    to "{P}{VZ}.SET";
/* Pseudomotor T_AX*/
double pmT_AX_drive; assign pmT_AX_drive  to "{P}{V_AX}.VAL";    monitor pmT_AX_drive;
double pmT_AX_move;  assign pmT_AX_move   to "{P}{V_AX}Move";    monitor pmT_AX_move;
double pmT_AX_rbv;   assign pmT_AX_rbv    to "{P}{V_AX}Readback";
double pmT_AX_set;   assign pmT_AX_set    to "{P}{V_AX}.SET";
/* Pseudomotor T_AY*/
double pmT_AY_drive; assign pmT_AY_drive  to "{P}{V_AY}.VAL";    monitor pmT_AY_drive;
double pmT_AY_move;  assign pmT_AY_move   to "{P}{V_AY}Move";    monitor pmT_AY_move;
double pmT_AY_rbv;   assign pmT_AY_rbv    to "{P}{V_AY}Readback";
double pmT_AY_set;   assign pmT_AY_set    to "{P}{V_AY}.SET";


/* event flags */
evflag pmAX_move_mon; sync pmAX_move pmAX_move_mon;
evflag pmAY_move_mon; sync pmAY_move pmAY_move_mon;
evflag pmAZ_move_mon; sync pmAZ_move pmAZ_move_mon;

evflag pmRX_move_mon;   sync pmRX_move   pmRX_move_mon;
evflag pmRY_move_mon;   sync pmRY_move   pmRY_move_mon;
evflag pmRZ_move_mon;   sync pmRZ_move   pmRZ_move_mon;
evflag pmT_AX_move_mon; sync pmT_AX_move pmT_AX_move_mon;
evflag pmT_AY_move_mon; sync pmT_AY_move pmT_AY_move_mon;


/************ flags for doing particular calcs **************************************/
int trans_flag;   assign trans_flag to "{P}{VX}C3"; monitor trans_flag;


/************ Motor motion monitors ************************************************/
/******  ? which one should be used, can I use them all ? *******/
int    motors_stopped;     assign motors_stopped to "{P}{AZ}Done";  monitor motors_stopped;
evflag motors_stopped_mon;  sync  motors_stopped   motors_stopped_mon;


/************************ Constants Defining the table geom and fixed point *************/
double lx;   assign lx   to "{P}{AX}C1"; monitor lx;
double lz;   assign lz   to "{P}{AX}C2"; monitor lz;
double vD0[3];
assign vD0[0]  to "{P}{AX}C3"; 
assign vD0[1]  to "{P}{AX}C4";
assign vD0[2]  to "{P}{AX}C5";
monitor vD0;
evflag lx_mon;  sync lx  lx_mon;
evflag lz_mon;  sync lz  lz_mon;
evflag vD0_mon;   sync vD0  vD0_mon;  /* do I have to do this for each array element ??? */

/************************ Constants Defining the target point *******************/
double d1;   assign d1   to "{P}{VX}C1"; monitor d1;
double d2;   assign d2   to "{P}{VX}C2"; monitor d2;
evflag d1_mon;  sync d1  d1_mon;
evflag d2_mon;  sync d2  d2_mon;


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
double del_angle;  //would like these to be read only pv's ???
double mAY;
double mBY;
double mCY;
double mAX;
double mBZ;


/************************** start snl **********************************/

ss NewportTable {

    state init {
        when() {
            dtor = 4. * atan(1.) / 180.;
            efSet(mAX_drive_mon);       /* Force calculation first time through ???? */
            efClear(pmAX_move_mon);     /* Don't move motors on initialization */
            efClear(pmAY_move_mon);
            efClear(pmAZ_move_mon);
            efClear(pmRX_move_mon);
            efClear(pmRY_move_mon);
            efClear(pmRZ_move_mon);
            efClear(pmT_AX_move_mon);
            efClear(pmT_AY_move_mon);
        } state monitor_changes
    }

    state monitor_changes {
        when(efTestAndClear(pmAX_move_mon) || 
             efTestAndClear(pmAY_move_mon) ||
             efTestAndClear(pmAZ_move_mon) ||
             efTestAndClear(pmRX_move_mon) ||
		     efTestAndClear(pmRY_move_mon) ||
		     efTestAndClear(pmRZ_move_mon) ||
		     efTestAndClear(pmT_AX_move_mon) ||
		     efTestAndClear(pmT_AY_move_mon) ) {
            /* -  psuedo-motors AX, AY, AZ, RX, RY, RZ, T_AX, T_AY  have been driven,
             * -  do the foreward calc and drive real motors  */
            
            AX = pmAX_drive*dtor;
            AY = pmAY_drive*dtor;
            AZ = pmAZ_drive*dtor;
            T_AX = pmT_AX_drive*dtor;
            T_AY = pmT_AY_drive*dtor;  
		    vR[0] = pmRX_drive;
 		    vR[1] = pmRY_drive;
		    vR[2] = pmRZ_drive;       

            // do foreward calcs
            calc_target_point(vR, T_AX, T_AY, d1, d2, &vT[0]);
            motor_from_psuedo(lx, lz, vD0, vT, AX, AY, AZ, T_AX, T_AY,d1,d2,
				              &mAY, &mBY, &mCY, &mAX, &mBZ, &vD[0],
				              &vDel[0],&del_r,&del_angle);

            mAY_drive = mAY;
		    mBY_drive = mBY;
		    mCY_drive = mCY;
		    mAX_drive = mAX;
		    mBZ_drive = mBZ;

            pvPut(mAY_drive);
            pvPut(mBY_drive);
            pvPut(mCY_drive);
            pvPut(mAX_drive);
            pvPut(mBZ_drive);
            
            //also like to update these diagnostic pvs'
            //pvPut(vDel);
            //pvPut(del_r);
            //pvPut(del_angle);

        } state monitor_changes

        when((efTestAndClear(motors_stopped_mon) && motors_stopped == 1) ||  /*????*/
             efTestAndClear(lx_mon)      ||
             efTestAndClear(lz_mon)      ||
             efTestAndClear(vD0_mon)      ||
             efTestAndClear(d1_mon)      ||  
             efTestAndClear(d2_mon)) {
            /* The ??? motor drive values, or a geometry constant
             * has changed, update the psuedo motor drive fields */

            /* Put pseudomotors in "set" mode so we don't actually move anything */
            pmAX_set = 1; pvPut(pmAX_set);
            pmAY_set = 1; pvPut(pmAY_set);
            pmAZ_set = 1; pvPut(pmAZ_set);
            pmRX_set = 1; pvPut(pmRX_set);
            pmRY_set = 1; pvPut(pmRY_set);
            pmRZ_set = 1; pvPut(pmRZ_set);
            pmT_AX_set = 1; pvPut(pmT_AX_set);
            pmT_AY_set = 1; pvPut(pmT_AX_set);


            T_AX = pmT_AX_drive*dtor;
            T_AY = pmT_AY_drive*dtor;  
		    vR[0] = pmRX_drive;
 		    vR[1] = pmRY_drive;
		    vR[2] = pmRZ_drive; 
            calc_target_point(vR, T_AX, T_AY, d1, d2, &vT[0]);

            mAY = mAY_drive;
		    mBY = mBY_drive;
		    mCY = mCY_drive;
		    mAX = mAX_drive;
		    mBZ = mBZ_drive;
		    psuedo_from_motor(lx, lz, vD0, vT,&AX, &AY, &AZ, T_AX, T_AY,d1,d2,
				              mAY, mBY, mCY, mAX, mBZ, &vD[0], &vDel[0],
				              &del_r,&del_angle);

		    pmAX_drive = AX/dtor;  pvPut(pmAX_drive);
 		    pmAY_drive = AY/dtor;  pvPut(pmAY_drive);
		    pmAZ_drive = AZ/dtor;  pvPut(pmAZ_drive);

            
            //also like to update these diagnostic pvs'
            //pvPut(vDel);
            //pvPut(del_r);
            //pvPut(del_angle);

            /* Put pseudomotors back in "Use" mode */
            pmAX_set = 0;   pvPut(pmAX_set);
            pmAY_set = 0;   pvPut(pmAY_set);
            pmAZ_set = 0;   pvPut(pmAZ_set);
            pmRX_set = 0;   pvPut(pmRX_set);
            pmRY_set = 0;   pvPut(pmRY_set);
            pmRZ_set = 0;   pvPut(pmRZ_set);
            pmT_AX_set = 0; pvPut(pmT_AX_set);
            pmT_AY_set = 0; pvPut(pmT_AX_set);

        } state update_readbacks  /* ??? why call update readbacks ???*/


        when(efTestAndClear(mAY_rbv_mon) || 
             efTestAndClear(mBY_rbv_mon) ||
             efTestAndClear(mCY_rbv_mon) ||
             efTestAndClear(mAX_rbv_mon) || 
             efTestAndClear(mBZ_rbv_mon)) {
             /* The motor readbacks have changed, 
                update psuedo motor readbacks by calling 
                update_readbacks*/
        } state update_readbacks
 
            
        when(trans_flag == 1) {
            /* translate table to get on the target ray */

            AX = pmAX_drive*dtor;
            AY = pmAY_drive*dtor;
            AZ = pmAZ_drive*dtor;
            T_AX = pmT_AX_drive*dtor;
            T_AY = pmT_AY_drive*dtor;  
		    vR[0] = pmRX_drive;
 		    vR[1] = pmRY_drive;
		    vR[2] = pmRZ_drive;

            calc_target_point(vR, T_AX, T_AY, d1, d2, &vT[0]);
            motor_from_psuedo(lx, lz, vD0, vT, AX, AY, AZ, T_AX, T_AY,d1,d2,
				              &mAY, &mBY, &mCY, &mAX, &mBZ, &vD[0],
				              &vDel[0],&del_r,&del_angle);

            mAY_drive = mAY;  pvPut(mAY_drive);
		    mBY_drive = mBY;  pvPut(mBY_drive);
		    mCY_drive = mCY;  pvPut(mCY_drive);
		    mAX_drive = mAX;  pvPut(mAX_drive);
		    mBZ_drive = mBZ;  pvPut(mBZ_drive);

            //also like to update these diagnostic pvs'
            //pvPut(vDel);
            //pvPut(del_r);
            //pvPut(del_angle);

            trans_flag = 0; pvPut(trans_flag);
        } state monitor_changes
    }


    state update_readbacks {
        when () {
         /* Something has changed which requires 
            recomputing psuedomotor readback positions */
            mAY = mAY_rbv;
		    mBY = mBY_rbv;
		    mCY = mCY_rbv;
		    mAX = mAX_rbv;
		    mBZ = mBZ_rbv;

		    psuedo_from_motor(lx, lz, vD0, vT,&AX, &AY, &AZ, T_AX, T_AY,d1,d2,
				              mAY, mBY, mCY, mAX, mBZ, &vD[0], &vDel[0],
				              &del_r,&del_angle);

		    pmAX_rbv = AX/dtor;
 		    pmAY_rbv = AY/dtor;
		    pmAZ_rbv = AZ/dtor;

            pvPut(pmAX_rbv);
            pvPut(pmAY_rbv);
            pvPut(pmAZ_rbv);

            //also like to update these diagnostic pvs'
            //pvPut(vDel);
            //pvPut(del_r);
            //pvPut(del_angle);

        } state monitor_changes
    }
}

