/*   -*-c-*-   (starts emacs in c-mode) */
program Analyzer("P=13IDC:,THETA=m43, DETECTOR=m44, ANAL = ANAL")
/*
 *  implements monitoring, movement, and synchronization of virtual
 *  motor "energy", using monochromator angle and parameters and
 *  undulator gap, table height.  For a channel cut monochromator
 *
 *  uses PVs defined in energy.db
 *
 *  April 5, 1998   Matt Newville
*/

%%#include <math.h>

double theta;    assign theta     to "{P}{THETA}";        monitor theta;
double detector; assign detector  to "{P}{DETECTOR}";     monitor detector;
double length;   assign length    to "{P}{ANAL}length";   monitor length;
double kbenergy; assign kbenergy  to "{P}{ANAL}kbenergy"; monitor kbenergy;
double analdsp;  assign analdsp   to "{P}{ANAL}analdsp";  monitor analdsp;
int    track;    assign track     to "{P}{ANAL}track";    monitor track;
int    synchro;  assign synchro   to "{P}{ANAL}sync";     monitor synchro;

evflag theta_ef;       sync theta   theta_ef;
evflag track_ef;       sync track   track_ef;
evflag synchro_ef;     sync synchro synchro_ef;
evflag length_ef;      sync length  length_ef;

double dtor ;     /* degrees to radians   */
double theta_old;
double offset;

ss Analyzer {
  state init {
    when() {
      dtor = atan(1.) / 45. ;
      if (length < 0.1)  {
	length   = 1000.0 ; 
	pvPut(length);
      }
      pvGet(length);
      pvGet(detector);
      pvGet(kbenergy);
      pvGet(analdsp);
      pvGet(theta);
      offset  = detector - length * cos (2. * dtor * theta);
      theta_old = theta;
      printf("\nAnalyzer starting at detector,theta");
      printf("   = %13.8f, %13.8f\n",detector,theta);
      efClear(synchro_ef);
      efClear(length_ef);
      efClear(theta_ef);
    } state monitor_changes
  }
  state monitor_changes {
    /* when theta moves: move detector to new two theta*/
    when(efTestAndClear(theta_ef)) {
      pvGet(track);
      if (track) {
	pvGet(detector);
	pvGet(theta);
	pvGet(length);
      /* calculate new detector position */
	detector  =  offset + length * cos(2 * dtor * theta );
	printf("Analyzer: detector  ->  %13.8f\n",detector);
	pvPut(detector);
	theta_old = theta;
      } 
      efClear(synchro_ef);
      efClear(length_ef);
      efClear(theta_ef);
    } state monitor_changes
    when(efTestAndClear(synchro_ef)||efTestAndClear(length_ef)) {
      pvGet(length);
      pvGet(detector);
      pvGet(theta);
      offset    = detector - length * cos (2. * dtor * theta);
      theta_old = theta;
      printf("Analyzer: offset  ->  %13.8f\n",offset);
      synchro   = 0;
      pvPut(synchro);
      efClear(synchro_ef);
      efClear(length_ef);
      efClear(theta_ef);
    } state monitor_changes
  } 
}




