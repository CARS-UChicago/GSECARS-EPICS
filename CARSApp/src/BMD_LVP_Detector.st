program BMD_LVP_Detector("P=13LAB:,PMT=pm1,PMR=pm2,X=m1,Y=m2,Z=m3,TV=m4,TH=m5")

/*  This sequencer program works with BMD_LVP_Detector.db.  It implements the
 *  Large Volume Press detector system, where the detector has 2 rotation 
 *  stages mounted on an X-Z translation stage, and we want to treat it as a 
 *  2-theta circle centered on the sample.  The pseudomotors are 
 *  2-Theta', and R, where R is the radius of the 2-theta circle.
 *  2-Theta' can have both a vertical and horizontal component when using the
 *  T-cup geometry.
 *
 *  Mark Rivers
 *  March 31, 1998
 *  Converted to soft motor records 1/23/2000
*/

%% #include <math.h>

/* The real motors */
double x_drive;  assign  x_drive  to "{P}{X}.VAL";  monitor x_drive;
double y_drive;  assign  y_drive  to "{P}{Y}.VAL";  monitor y_drive;
double z_drive;  assign  z_drive  to "{P}{Z}.VAL";  monitor z_drive;
double x_rbv;    assign  x_rbv    to "{P}{X}.RBV";  monitor x_rbv;
double y_rbv;    assign  y_rbv    to "{P}{Y}.RBV";  monitor y_rbv;
double z_rbv;    assign  z_rbv    to "{P}{Z}.RBV";  monitor z_rbv;
double tv_drive; assign  tv_drive to "{P}{TV}.VAL"; monitor tv_drive;
double tv_rbv;   assign  tv_rbv   to "{P}{TV}.RBV"; monitor tv_rbv;
double th_drive; assign  th_drive to "{P}{TH}.VAL"; monitor th_drive;
double th_rbv;   assign  th_rbv   to "{P}{TH}.RBV"; monitor th_rbv;
evflag x_drive_mon;  sync x_drive  x_drive_mon;
evflag x_rbv_mon;    sync x_rbv    x_rbv_mon;
evflag y_drive_mon;  sync y_drive  y_drive_mon;
evflag y_rbv_mon;    sync y_rbv    y_rbv_mon;
evflag z_drive_mon;  sync z_drive  z_drive_mon;
evflag z_rbv_mon;    sync z_rbv    z_rbv_mon;
evflag tv_drive_mon; sync tv_drive tv_drive_mon;
evflag tv_rbv_mon;   sync tv_rbv   tv_rbv_mon;
evflag th_drive_mon; sync th_drive th_drive_mon;
evflag th_rbv_mon;   sync th_rbv   th_rbv_mon;

/* Pseudomotors */
double tp_drive; assign tp_drive  to "{P}{PMT}.VAL";    monitor tp_drive;
double tp_move;  assign tp_move   to "{P}{PMT}Move";    monitor tp_move;
double tp_rbv;   assign tp_rbv    to "{P}{PMT}Readback";
double tp_set;   assign tp_set    to "{P}{PMT}.SET";

double r_drive;  assign r_drive   to "{P}{PMR}.VAL";    monitor r_drive;
double r_move;   assign r_move    to "{P}{PMR}Move";    monitor r_move;
double r_rbv;    assign r_rbv     to "{P}{PMR}Readback";
double r_set;    assign r_set     to "{P}{PMR}.SET";
evflag tp_move_mon; sync tp_move tp_move_mon;
evflag r_move_mon;  sync r_move  r_move_mon;

/* Geometry offsets */
double x0;  assign x0  to "{P}{PMR}C1"; monitor x0;
double y0;  assign y0  to "{P}{PMR}C2"; monitor y0;
double z0;  assign z0  to "{P}{PMR}C3"; monitor z0;
double b;   assign b   to "{P}{PMT}C1"; monitor b;
double c;   assign c   to "{P}{PMT}C2"; monitor c;
double chi; assign chi to "{P}{PMT}C3"; monitor chi;
evflag x0_mon;  sync x0  x0_mon;
evflag y0_mon;  sync y0  y0_mon;
evflag z0_mon;  sync z0  z0_mon;
evflag b_mon;   sync b   b_mon;
evflag c_mon;   sync c   c_mon;
evflag chi_mon; sync chi chi_mon;

int synch; assign synch to "{P}{PMR}synch"; monitor synch;
int motors_stopped; assign motors_stopped to "{P}{PMR}Done"; 
                    monitor motors_stopped;
evflag motors_stopped_mon; sync motors_stopped motors_stopped_mon;

double dtor; /* Degrees to radians */
double th; /* Horizontal component of 2-theta, in rads */
double tv; /* Vertical component of 2-theta, in rads */
double tempv;
double temph;


ss LVPdetector {
    state init {
        when() {
            dtor = 4. * atan(1.) / 180.;
            efSet(tv_rbv_mon);      /* Force calculation first time through */
            efClear(tp_move_mon); /* Don't move motors on initialization */
            efClear(r_move_mon);
        } state monitor_changes
    }

    state monitor_changes {
        when(efTestAndClear(tp_move_mon) || 
             efTestAndClear(r_move_mon)) {
            /* 2-theta' or R been driven, drive real motors */
            tv = asin( sin(tp_drive*dtor) * cos(chi*dtor) );
            th = asin( sin(tp_drive*dtor) * sin(chi*dtor) );
            printf("tv = %f, th=%f\n", tv, th);
            x_drive = -r_drive*sin(th) + b*(1-cos(th)) - x0; pvPut(x_drive);
            y_drive =  r_drive*sin(tv) + c*(1-cos(tv)) - y0; pvPut(y_drive);
            z_drive =  r_drive*(cos(tv) * cos(th)) + c*sin(tv) - b*sin(th) 
                          - z0; pvPut(z_drive);
            tv_drive = tv/dtor; pvPut(tv_drive);
            th_drive = th/dtor; pvPut(th_drive);
            printf("x_drive = %f\n", x_drive);
            printf("y_drive = %f\n", y_drive);
            printf("z_drive = %f\n", z_drive);
            printf("tv_drive = %f\n", tv_drive);
            printf("th_drive = %f\n", th_drive);
        } state monitor_changes

        when((efTestAndClear(motors_stopped_mon) && motors_stopped == 1) ||
             efTestAndClear(x0_mon)      ||
             efTestAndClear(y0_mon)      ||
             efTestAndClear(z0_mon)      || 
             efTestAndClear(b_mon)       || 
             efTestAndClear(c_mon)       || 
             efTestAndClear(chi_mon)) {
            /* The X, Y Z or 2-theta motor drive values, or a geometry constant
             * has changed, update the 2-theta' and R drive fields */
            tv = atan2((y_drive + y0), (z_drive + z0));
            /* Put pseudomotors in "set" mode so we don't actually move 
               anything */
            tp_set = 1;
            pvPut(tp_set);
            r_set = 1;
            pvPut(r_set);
            tp_drive = (sin(tv) / cos(chi*dtor)) / dtor;
            pvPut(tp_drive);
            tv = asin( sin(tp_drive*dtor) * cos(chi*dtor) );
            th = asin( sin(tp_drive*dtor) * sin(chi*dtor) );
            /* Note - the following fails at angles=90 */
            r_drive = (z_drive - c*sin(tv) + b*sin(th) + z0) /
                        (cos(tv) * cos(th));
            pvPut(r_drive);
            /* Put pseudomotors back in "Use" mode */
            tp_set = 0;
            pvPut(tp_set);
            r_set = 0;
            pvPut(r_set);
        } state update_readbacks

        when(efTestAndClear(x_rbv_mon) || 
             efTestAndClear(y_rbv_mon) ||
             efTestAndClear(z_rbv_mon) ||
             efTestAndClear(tv_rbv_mon)|| 
             efTestAndClear(th_rbv_mon)) {
            /* The motor readbacks have changed, update R, 2-theta' readbacks */
        } state update_readbacks
        
        when(synch == 1) {
            /* Assume that 2-theta, X0, and Y0 are correct, and that we are in 
             * the diffraction condition. Compute Z0 */
            z0 = (y_drive+y0)/tan(tv_drive*dtor) - z_drive;
            pvPut(z0);
            synch = 0;    pvPut(synch);
        } state monitor_changes
    }

    state update_readbacks {
        when () {
            /* Something has changed which requires recomputing readback
             * positions */
            tempv = atan2((y_rbv + y0), (z_rbv + z0));
            tp_rbv = (sin(tempv) / cos(chi*dtor)) / dtor;
            pvPut(tp_rbv);
            tempv = asin( sin(tp_rbv*dtor) * cos(chi*dtor) );
            temph = asin( sin(tp_rbv*dtor) * sin(chi*dtor) );
            /* Note - the following fails at angles=90 */
            r_rbv = (z_rbv - c*sin(tempv) + b*sin(temph) + z0) /
                        (cos(tempv) * cos(temph));
            pvPut(r_rbv);
        } state monitor_changes
    }
}
