program coordTrans2D("P=13LAB:,PMX=pm1,PMY=pm2,MX=m1,MY=m2")

/*  This sequencer program works with pseudoMotors.db.  It implements a
 *  coordinate transformation, X,Y -> X',Y', where the X',Y' coordinate system
 *  is translated and rotated relative to the X,Y coordinate system.
 *
 *  Mark Rivers
 *  March 31, 1998
 *
 *  8-Jul-2003  Renamed variable "y0" to "yzero" to avoid conflict with Bessel function in math.h
 *              Did same for x0 for consistency
*/

%% #include <math.h>

double x_drive; assign  x_drive to "{P}{MX}.VAL"; monitor x_drive;
double x_rbv;   assign  x_rbv   to "{P}{MX}.RBV"; monitor x_rbv;
double y_drive; assign  y_drive to "{P}{MY}.VAL"; monitor y_drive;
double y_rbv;   assign  y_rbv   to "{P}{MY}.RBV"; monitor y_rbv;
evflag x_drive_mon; sync x_drive x_drive_mon;
evflag x_rbv_mon;   sync x_rbv   x_rbv_mon;
evflag y_drive_mon; sync y_drive y_drive_mon;
evflag y_rbv_mon;   sync y_rbv   y_rbv_mon;

double xp_drive; assign  xp_drive to "{P}{PMX}.VAL"; monitor xp_drive;
double xp_rbv;   assign  xp_rbv   to "{P}{PMX}.RBV"; monitor xp_rbv;
double yp_drive; assign  yp_drive to "{P}{PMY}.VAL"; monitor yp_drive;
double yp_rbv;   assign  yp_rbv   to "{P}{PMY}.RBV"; monitor yp_rbv;
evflag xp_drive_mon; sync xp_drive xp_drive_mon;
evflag yp_drive_mon; sync yp_drive yp_drive_mon;

double xzero;    assign xzero    to "{P}{PMX}C1";  monitor xzero;
int synch;    assign synch to "{P}{PMX}set"; monitor synch;
double yzero;    assign yzero    to "{P}{PMY}C1";  monitor yzero;
double theta; assign theta to "{P}{PMY}C2";  monitor theta;
evflag xzero_mon;    sync xzero xzero_mon;
evflag theta_mon; sync theta theta_mon;
evflag yzero_mon;    sync yzero yzero_mon;

double dtor;  /* Degrees to radians */

ss coordTrans2D {
    state init {
        when() {
            dtor = 4. * atan(1.) / 180.;
            efSet(theta_mon);      /* Force calculation first time through */
            efClear(xp_drive_mon); /* Don't drive motors on initialization */
            efClear(yp_drive_mon);
        } state monitor_changes
    }

    state monitor_changes {
        when(efTestAndClear(xp_drive_mon) || efTestAndClear(yp_drive_mon)) {
            /* Drive fields in new coordinate system have changed, 
             * move motors */
            x_drive = xzero + xp_drive*cos(theta*dtor)
                         - yp_drive*sin(theta*dtor);
            pvPut(x_drive);
            y_drive = yzero + xp_drive*sin(theta*dtor)
                         + yp_drive*cos(theta*dtor);
            pvPut(y_drive);
        } state monitor_changes

        when(efTestAndClear(xzero_mon) || efTestAndClear(yzero_mon) ||
             efTestAndClear(theta_mon)) {
            /* Geometry parameters have changed, update readbacks*/
        } state update_readbacks

        when(efTestAndClear(x_rbv_mon) || efTestAndClear(y_rbv_mon)) {
            /* The motor readbacks in old coordinate system have changed,
               update readbacks in new coordinate system */
        } state update_readbacks

        when(synch == 1) {
            /* Set the origin of the new coordinate system to be the current
             * position of the motors */
            xzero = x_drive; pvPut(xzero);
            yzero = y_drive; pvPut(yzero);
            synch = 0;    pvPut(synch);
        } state monitor_changes
    }

    state update_readbacks {
        when () {
            /* Something has changed which requires recomputing readback
             * positions in new coordinate system */
            xp_rbv = (y_rbv - yzero)*sin(theta*dtor) +
                     (x_rbv - xzero)*cos(theta*dtor);
            pvPut(xp_rbv);
            yp_rbv = (y_rbv - yzero)*cos(theta*dtor) -
                     (x_rbv - xzero)*sin(theta*dtor);
            pvPut(yp_rbv);
        } state monitor_changes
    }
}
