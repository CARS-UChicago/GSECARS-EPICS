program IDD_LVP_Detector("P=13IDD:,PMT=pm1,PMR=pm2,PMC=pm3,X=m1,Y=m2,Z=m3,TZ=m4,TX=m5")

/*  This sequencer program works with IDD_LVP_Detector.db.  It implements the
 *  Large Volume Press detector system, where the detector has 2 rotation 
 *  stages mounted on an X-Y-Z translation stage, and we want to treat it as a 
 *  2-theta circle centered on the sample.  The pseudomotors are 
 *  2-Theta', and R, where R is the radius of the 2-theta circle.
 *  2-Theta' can have both a vertical and horizontal component when using the
 *  T-cup geometry.
 *
 *  Mark Rivers
 *  April 18, 2000
 *  Modified:
 *      May 12, 2000  MLR + YBW   Changed orientation of "A"
*/

%% #include <math.h>

/* The real motors */
double x_drive;  assign  x_drive  to "{P}{X}.VAL";  monitor x_drive;
double y_drive;  assign  y_drive  to "{P}{Y}.VAL";  monitor y_drive;
double z_drive;  assign  z_drive  to "{P}{Z}.VAL";  monitor z_drive;
double x_rbv;    assign  x_rbv    to "{P}{X}.RBV";  monitor x_rbv;
double y_rbv;    assign  y_rbv    to "{P}{Y}.RBV";  monitor y_rbv;
double z_rbv;    assign  z_rbv    to "{P}{Z}.RBV";  monitor z_rbv;
double tx_drive; assign  tx_drive to "{P}{TX}.VAL"; monitor tx_drive;
double tx_rbv;   assign  tx_rbv   to "{P}{TX}.RBV"; monitor tx_rbv;
double tz_drive; assign  tz_drive to "{P}{TZ}.VAL"; monitor tz_drive;
double tz_rbv;   assign  tz_rbv   to "{P}{TZ}.RBV"; monitor tz_rbv;
evflag x_drive_mon;  sync x_drive  x_drive_mon;
evflag x_rbv_mon;    sync x_rbv    x_rbv_mon;
evflag y_drive_mon;  sync y_drive  y_drive_mon;
evflag y_rbv_mon;    sync y_rbv    y_rbv_mon;
evflag z_drive_mon;  sync z_drive  z_drive_mon;
evflag z_rbv_mon;    sync z_rbv    z_rbv_mon;
evflag tx_drive_mon; sync tx_drive tx_drive_mon;
evflag tx_rbv_mon;   sync tx_rbv   tx_rbv_mon;
evflag tz_drive_mon; sync tz_drive tz_drive_mon;
evflag tz_rbv_mon;   sync tz_rbv   tz_rbv_mon;

/* Pseudomotors */
/* Pseudomotor theta = compound 2-theta */
double pmt_drive; assign pmt_drive  to "{P}{PMT}.VAL";    monitor pmt_drive;
double pmt_move;  assign pmt_move   to "{P}{PMT}Move";    monitor pmt_move;
double pmt_rbv;   assign pmt_rbv    to "{P}{PMT}Readback";
double pmt_set;   assign pmt_set    to "{P}{PMT}.SET";

/* Pseudomotor chi = compound chi */
double pmc_drive; assign pmc_drive  to "{P}{PMC}.VAL";    monitor pmc_drive;
double pmc_move;  assign pmc_move   to "{P}{PMC}Move";    monitor pmc_move;
double pmc_rbv;   assign pmc_rbv    to "{P}{PMC}Readback";
double pmc_set;   assign pmc_set    to "{P}{PMC}.SET";

/* Pseudomotor radius */
double pmr_drive;  assign pmr_drive   to "{P}{PMR}.VAL";    monitor pmr_drive;
double pmr_move;   assign pmr_move    to "{P}{PMR}Move";    monitor pmr_move;
double pmr_rbv;    assign pmr_rbv     to "{P}{PMR}Readback";
double pmr_set;    assign pmr_set     to "{P}{PMR}.SET";
evflag pmt_move_mon; sync pmt_move pmt_move_mon;
evflag pmc_move_mon; sync pmc_move pmc_move_mon;
evflag pmr_move_mon; sync pmr_move pmr_move_mon;

/* Geometry offsets */
double x0;  assign x0  to "{P}{PMR}C1"; monitor x0;
double y0;  assign y0  to "{P}{PMR}C2"; monitor y0;
double z0;  assign z0  to "{P}{PMR}C3"; monitor z0;
double a;   assign a   to "{P}{PMT}C1"; monitor a;
evflag x0_mon;  sync x0  x0_mon;
evflag y0_mon;  sync y0  y0_mon;
evflag z0_mon;  sync z0  z0_mon;
evflag a_mon;   sync a   a_mon;

int synch; assign synch to "{P}{PMR}synch"; monitor synch;
int motors_stopped; assign motors_stopped to "{P}{PMR}Done"; 
                    monitor motors_stopped;
evflag motors_stopped_mon; sync motors_stopped motors_stopped_mon;

double dtor; /* Degrees to radians */
double tz; 
double tx;
double b;
double c;


ss LVPdetector {
    state init {
        when() {
            dtor = 4. * atan(1.) / 180.;
            efSet(tx_rbv_mon);      /* Force calculation first time through */
            efClear(pmt_move_mon); /* Don't move motors on initialization */
            efClear(pmc_move_mon);
            efClear(pmr_move_mon);
        } state monitor_changes
    }

    state monitor_changes {
        when(efTestAndClear(pmt_move_mon) || 
             efTestAndClear(pmc_move_mon) ||
             efTestAndClear(pmr_move_mon)) {
            /* 2-theta', chi' or R been driven, drive real motors */
            tx = pmt_drive*dtor;
            tz = pmc_drive*dtor;
            x_drive =  -pmr_drive*sin(tx)*sin(tz) - a*(1.-cos(tz)) - x0; 
            pvPut(x_drive);
            y_drive =  pmr_drive*sin(tx)*cos(tz) + a*sin(tz) - y0; 
            pvPut(y_drive);
            z_drive =  pmr_drive*cos(tx) - z0;
            pvPut(z_drive);
            tx_drive = tx/dtor; pvPut(tx_drive);
            tz_drive = tz/dtor; pvPut(tz_drive);
        } state monitor_changes

        when((efTestAndClear(motors_stopped_mon) && motors_stopped == 1) ||
             efTestAndClear(x0_mon)      ||
             efTestAndClear(y0_mon)      ||
             efTestAndClear(z0_mon)      || 
             efTestAndClear(a_mon)) {
            /* The X, Y Z or 2-theta motor drive values, or a geometry constant
             * has changed, update the 2-theta', chi' and R drive fields */
            /* Put pseudomotors in "set" mode so we don't actually move 
               anything */
            pmt_set = 1; pvPut(pmt_set);
            pmc_set = 1; pvPut(pmc_set);
            pmr_set = 1; pvPut(pmr_set);
            pmt_drive = tx_drive;
            pvPut(pmt_drive);
            pmc_drive = tz_drive;
            pvPut(pmc_drive);
            tx = pmt_drive*dtor;
            tz = pmc_drive*dtor;
            c = (x_drive + x0) * (x_drive + x0) + 
                (y_drive + y0) * (y_drive + y0) + 
                (z_drive + z0) * (z_drive + z0) -
                2. * a * a * (1. - cos(tz));
            b = 2. * a * sin(tx) * sin(tz);
            pmr_drive = (-b + sqrt(b*b + 4.*c)) / 2.;
            pvPut(pmr_drive);
            /* Put pseudomotors back in "Use" mode */
            pmt_set = 0; pvPut(pmt_set);
            pmc_set = 0; pvPut(pmc_set);
            pmr_set = 0; pvPut(pmr_set);
        } state update_readbacks

        when(efTestAndClear(x_rbv_mon) || 
             efTestAndClear(y_rbv_mon) ||
             efTestAndClear(z_rbv_mon) ||
             efTestAndClear(tx_rbv_mon)|| 
             efTestAndClear(tz_rbv_mon)) {
            /* The motor readbacks have changed, update R, 2-theta' readbacks */
        } state update_readbacks
        
        when(synch == 1) {
            /* Assume that 2-theta, R are correct, and that we are in 
             * the diffraction condition. Compute X0, Y0, Z0 */
            tx = pmt_drive*dtor;
            tz = pmc_drive*dtor;
            x0 = -pmr_drive * sin(tx) * sin(tz) - a * (1. - cos(tz)) - x_drive;
            y0 = pmr_drive * sin(tx) * cos(tx) + a * sin(tz) - y_drive;
            z0 = pmr_drive * cos(tx) - z_drive;
            pvPut(x0);
            pvPut(y0);
            pvPut(z0);
            synch = 0; pvPut(synch);
        } state monitor_changes
    }

    state update_readbacks {
        when () {
            /* Something has changed which requires recomputing readback
             * positions */
            pmt_rbv = tx_rbv;
            pvPut(pmt_rbv);
            pmc_rbv = tz_rbv;
            pvPut(pmc_rbv);
            tx = pmt_rbv*dtor;
            tz = pmc_rbv*dtor;
            c = (x_rbv + x0) * (x_rbv + x0) + 
                (y_rbv + y0) * (y_rbv + y0) + 
                (z_rbv + z0) * (z_rbv + z0) -
                2. * a * a * (1. - cos(tz));
            b = 2. * a * sin(tx) * sin(tz);
            pmr_rbv = (-b + sqrt(b*b + 4.*c)) / 2.;
            pvPut(pmr_rbv);
        } state monitor_changes
    }
}
