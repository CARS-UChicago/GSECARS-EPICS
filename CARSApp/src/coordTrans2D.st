program coordTrans2D("P=13LAB:,PMX=pm1,PMY=pm2,MX=m1,MY=m2")

/*  This sequencer program works with pseudoMotors.db.  It implements a
 *  coordinate transformation, X,Y -> X',Y', where the X',Y' coordinate system
 *  is translated and rotated relative to the X,Y coordinate system.
 *
 *  Mark Rivers
 *  March 31, 1998
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
double xp_set;   assign  xp_set   to "{P}{PMX}.SET";
double yp_drive; assign  yp_drive to "{P}{PMY}.VAL"; monitor yp_drive;
double yp_rbv;   assign  yp_rbv   to "{P}{PMY}.RBV"; monitor yp_rbv;
double yp_set;   assign  yp_set   to "{P}{PMY}.SET";
evflag xp_drive_mon; sync xp_drive xp_drive_mon;
evflag yp_drive_mon; sync yp_drive yp_drive_mon;

double x0;    assign x0    to "{P}{PMX}C1";  monitor x0;
int synch;    assign synch to "{P}{PMX}set"; monitor synch;
double y0;    assign y0    to "{P}{PMY}C1";  monitor y0;
double theta; assign theta to "{P}{PMY}C2";  monitor theta;
evflag x0_mon;    sync x0 x0_mon;
evflag theta_mon; sync theta theta_mon;
evflag y0_mon;    sync y0 y0_mon;

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
            x_drive = x0 + xp_drive*cos(theta*dtor)
                         - yp_drive*sin(theta*dtor);
            pvPut(x_drive);
            y_drive = y0 + xp_drive*sin(theta*dtor)
                         + yp_drive*cos(theta*dtor);
            pvPut(y_drive);
        } state monitor_changes

        when(efTestAndClear(x_drive_mon) || efTestAndClear(y_drive_mon) ||
             efTestAndClear(x0_mon)      || efTestAndClear(y0_mon) ||
             efTestAndClear(theta_mon)) {
            /* Drive values in old coordinate system, or geometry parameters
             * have changed, update drive values in new coordinate system */
            xp_drive = (y_drive - y0)*sin(theta*dtor) +
                       (x_drive - x0)*cos(theta*dtor);
            xp_set=1;
            pvPut(xp_set);
            pvPut(xp_drive);
            xp_set=0;
            pvPut(xp_set);
            yp_drive = (y_drive - y0)*cos(theta*dtor) -
                       (x_drive - x0)*sin(theta*dtor);
            yp_set=1;
            pvPut(yp_set);
            pvPut(yp_drive);
            yp_set=0;
            pvPut(yp_set);
            /* We have changed the drive fields, but don't want to move
             * anything, so clear the event flags */
            efClear(xp_drive_mon);
            efClear(yp_drive_mon);
        } state update_readbacks

        when(efTestAndClear(x_rbv_mon) || efTestAndClear(y_rbv_mon)) {
            /* The motor readbacks in old coordinate system have changed,
               update readbacks in new coordinate system */
        } state update_readbacks

        when(synch == 1) {
            /* Set the origin of the new coordinate system to be the current
             * position of the motors */
            x0 = x_drive; pvPut(x0);
            y0 = y_drive; pvPut(y0);
            synch = 0;    pvPut(synch);
        } state monitor_changes
    }

    state update_readbacks {
        when () {
            /* Something has changed which requires recomputing readback
             * positions in new coordinate system */
            xp_rbv = (y_rbv - y0)*sin(theta*dtor) +
                     (x_rbv - x0)*cos(theta*dtor);
            pvPut(xp_rbv);
            yp_rbv = (y_rbv - y0)*cos(theta*dtor) -
                     (x_rbv - x0)*sin(theta*dtor);
            pvPut(yp_rbv);
        } state monitor_changes
    }
}
