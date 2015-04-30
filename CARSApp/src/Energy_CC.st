/*   -*-c-*-   (this starts emacs in c-mode) */
program Energy_CC("P=13IDC:,IDXX=ID13:,EN=EN, MONO=m8, TABLE=m6, DIF=DIF:t1.Y")

/*
 *  implements monitoring, movement, and synchronization of virtual
 *  motor "energy", using monochromator angle and parameters and
 *  undulator gap, table height.  For a channel cut monochromator
 *
 *  uses PVs defined in Energy.db
 *
 *  Sept 21, 1998   Matt Newville 
 *  Jan  19, 1999   M N:  changed EnergySet / Start to ScanEnergy
 *  Nov 21, 2000    MLR:  changed PV names to agree with new .db file

*/

%%#include <math.h>

/* double und_e_set;   assign und_e_set  to "{IDXX}ScanEnergy.VAL"; */
double und_e_set;   assign und_e_set   to "{IDXX}ScanEnergy.VAL"; monitor und_e_set;
double und_e_rbv;   assign und_e_rbv   to "{IDXX}Energy.VAL";     monitor und_e_rbv;
int    und_busy;    assign und_busy    to "{IDXX}Busy.VAL";
int    undulator_busy;
double energy;      assign energy      to "{P}{EN}";           monitor energy;
double energy_rbv;  assign energy_rbv  to "{P}{EN}:RBV";       monitor energy_rbv;
double energy_tol;  assign energy_tol  to "{P}{EN}:TOL";       monitor energy_tol;
double und_offset;  assign und_offset  to "{P}{EN}:id_off";    monitor und_offset;
int    energy_busy; assign energy_busy to "{P}{EN}:Busy";      
int    energy_set;  assign energy_set  to "{P}{EN}:set";         monitor energy_set;
int    verbose;     assign verbose     to "{P}{EN}:verbose";     monitor verbose;
int    und_track;   assign und_track   to "{P}{EN}:id_track";   monitor und_track;
int    und_abort;   assign und_abort   to "{P}{EN}:und_abort_mv"; monitor und_abort;

double mono_angle;  assign mono_angle  to "{P}{MONO}";        monitor mono_angle;
double mono_rbv;    assign mono_rbv    to "{P}{MONO}.RBV"; 
int    mono_set;    assign mono_set    to "{P}{MONO}.SET";

double tableh_s;   assign tableh_s    to "{P}{TABLE}";       monitor tableh_s;
double tableh_d;   assign tableh_d    to "{P}{DIF}";         monitor tableh_d;
int    table_s_on; assign table_s_on to "{P}{EN}:table_s_track"; monitor table_s_on;  
int    table_d_on; assign table_d_on to "{P}{EN}:table_d_track"; monitor table_d_on;
double table_s_sign;  assign table_s_sign  to "{P}{EN}:table_s_sign";  monitor table_s_sign;
double table_d_sign;  assign table_d_sign  to "{P}{EN}:table_d_sign";  monitor table_d_sign;
double table_s_offset;  assign table_s_offset  to "{P}{EN}:table_s_offset";  monitor table_s_offset;
double table_d_offset;  assign table_d_offset  to "{P}{EN}:table_d_offset";  monitor table_d_offset;
double table_move_min;  assign table_move_min  to "{P}{EN}:table_move_min";  monitor table_move_min;


/* mono_d = mono plane spacing = a / sqrt (h^2 +k^2+l^2)   */
/* mono_c = mono channel spacing  (~9mm)  */
double mono_c;  assign mono_c to "{P}{EN}:width";   monitor mono_c;
double mono_d;  assign mono_d to "{P}{EN}:dspace";  monitor mono_d;

evflag energy_mon;      sync energy      energy_mon;
evflag und_track_mon;   sync und_track   und_track_mon;
evflag table_s_mon;     sync table_s_on  table_s_mon;
evflag table_d_mon;     sync table_d_on  table_d_mon;
/* evflag table_track_mon; sync table_track table_track_mon;*/
evflag mono_c_mon;      sync mono_c      mono_c_mon;
evflag mono_d_mon;      sync mono_d      mono_d_mon;
evflag energy_tol_mon;  sync energy_tol  energy_tol_mon;
evflag mono_angle_mon;  sync mono_angle  mono_angle_mon;

/* constants */
double deg2rad;      /* degrees to radians   */
double rad2deg;      /* radians to degrees   */
double hc;           /* hc in eV*Angstroms  */
double hc_o_2d;      /* hc/2d  */
double energy_min;
double mono_angle_min;
double table_delta;
double table_old;
double table_new;
double table_diff;
double delay;

/*-------------------------------------------------------------------*/
/*                  INIT                                               */
ss Energy {
  state init {
    when() {
      printf("Energy: initializing \n");
      energy_busy = 1;
      pvPut(energy_busy);
      /*  default to channel cut 220 crystal */
      if (mono_c < 1)   mono_c    = 9.100000;
      if (mono_d < 0.1) mono_d    = 1.920128;
      /* define constants */
      rad2deg        = 57.29577951;
      deg2rad        = 1. / rad2deg;
      hc             = 12398.61;
      hc_o_2d        = hc / (2 * mono_d); /* (hc / 2d) */
      energy_min     = 1/ hc_o_2d ;  /* or else asin(hc_o_2d / energy)  barfs a NaN  */
      mono_angle_min = 0.3;          /* minimum mono angle (in degrees) */

      /* get current mono angle, update energy readback */
      if (mono_angle < 0.001 )  mono_angle = 0.001;
      energy =  hc_o_2d / ( sin(mono_angle) / rad2deg) ;
      pvGet(mono_rbv);
      if (mono_rbv < 0.001 )  mono_rbv = 0.001;
      energy_rbv =  hc_o_2d / sin(mono_rbv * deg2rad) ;
      pvPut(energy_rbv);
      energy = energy_rbv;
      pvPut(energy);
      printf("Energy: mono angle, mono energy = %12.8f %12.8f\n",
	     mono_rbv,energy_rbv);
      /* initialize undulator offset */
      pvGet(und_e_rbv);
      und_offset = und_e_rbv - (energy/1000.0000);
      if (und_offset > 1.)  und_offset = 0.050;
      pvPut(und_offset);
      printf("Energy: und energy, und offset = %12.8f %12.8f\n", 
	     und_e_rbv, und_offset); 
      /* initialize table offsets */
      table_delta    = 2. * mono_c * cos(mono_angle * deg2rad);
      table_s_offset = tableh_s -  table_s_sign * table_delta;
      table_d_offset = tableh_d -  table_d_sign * table_delta;
      pvPut(table_s_offset);
      pvPut(table_d_offset);
      efClear(energy_mon); 
      efClear(und_track_mon); 
      efClear(table_s_mon); 
      efClear(table_d_mon); 
      efClear(mono_c_mon); 
      efClear(mono_d_mon); 
      efClear(energy_tol_mon); 
      energy_busy = 0;
      pvPut(energy_busy);
      printf("Energy: done initializing.\n");
      efSet(mono_angle_mon);
    } state monitor_changes
  }
  /*-------------------------------------------------------------------*/
  state monitor_changes {
  /*                  ENERGY SET or MOVE                               */
    when(efTestAndClear(energy_mon)) {
      /* when energy changes: move mono angle, undulator, and table height:
        strategy:
        0. set "energy busy"
        if "set energy" then:
          1. set new mono angle based on new energy value
	        2. let the mono_angle monitor handle the rest
        else (normal energy move) then:
          1. start move of undulator
          2. move mono
          3. move table
          4. wait for undulator to finish
        end if
        Last. unset "energy_busy"
      */

      energy_busy = 1;
      pvPut(energy_busy);
      if (verbose) {printf("-------\nEnergy: "); }

      /*  ENERGY SET  */
      if (energy_set) {
	      if (verbose) { printf("  ENERGY: reset mono energy to %12.8f\n", energy);}
	      pvPut(energy);
	      /* check that energy is in the correct range */
	      if (energy <        0.)  energy =-energy;         /* force positive */
	      if (energy <      500.0) energy = energy * 1000.; /* force use of  eV */
	      if (energy < energy_min) energy = energy_min;     /* force minimum energy */
	      if (energy >   500000.0) energy = 500000.0 ;      /* force E < .5 MeV */
	      if (verbose) { printf("     energy -> %12.8f", energy );}
	      /* mono angle */
	      mono_angle  = asin(hc_o_2d / energy) * rad2deg;
	      /* now change mono_angle to SET mode and put this value to it */
	      mono_set = 1;
	      pvPut(mono_set);
	      if (verbose) { printf("     mono angle -> %12.8f \n", mono_angle);}
	      pvPut(mono_angle);
	      mono_set = 0;
	      pvPut(mono_set);
	      if (verbose) { printf("  ENERGY done\n");}
      } else {
        /*  ENERGY MOVE  */
	      /* check that energy is in the correct range */
	      if (energy <        0.)  energy =-energy;         /* force positive */
	      if (energy <      500.0) energy = energy * 1000.; /* force use of  eV */
	      if (energy < energy_min) energy = energy_min;     /* force minimum energy */
	      if (energy >   500000.0) energy = 500000.0 ;      /* force E < .5 MeV */
	      /* start undulator move */
	      if (verbose) { printf("  ENERGY: move energy to %12.8f", energy );}
	      if (verbose) { printf("  (und tracking =%3i)\n", und_track);}
	      if (und_track) {
	        und_e_set  = und_offset + (energy / 1000.000) ;
	        if (und_e_set < 0.)    und_e_set  = und_e_rbv;
	        if (und_e_set > 200.)  und_e_set  = und_e_rbv;
	        pvPut(und_e_set);
	        if (verbose) {
	          printf("    und energy: %12.8f -> %12.8f\n", und_e_rbv, und_e_set);
	        }
	      }
	      /* move mono angle */
	      mono_angle   =  asin(hc_o_2d / energy) * rad2deg;
	      if (mono_angle < mono_angle_min) mono_angle = mono_angle_min;
	      if (verbose) { printf("    mono angle -> %12.8f \n", mono_angle);}
	      pvPut(mono_angle);
	      /* move spectroscopy table  */
	      table_delta = 2. * mono_c * cos(mono_angle * deg2rad);
	      if (table_s_on) {
	        table_old  = tableh_s;
	        table_new  = table_s_offset + table_s_sign * table_delta;
	        table_diff =  (table_old *10000.0  - table_new * 10000.0 )/10000.0; 
	        if (table_diff < 0.0) table_diff = - table_diff;
	        if (table_diff > table_move_min) { 
	          tableh_s = table_new;
	          pvPut (tableh_s);  
	          if  (verbose)  { printf("   spect table:  %12.8f -> %12.8f\n",
				          table_old, table_new);  }
	        } else {
	          if  (verbose)  { printf("   spect table:  stay at %12.8f\n",table_old);}
	        }
	      } else {
	        if  (verbose)  { printf("   spect table:  not moving\n");}
	      }
	      /* move diffractometer table */
	      if (table_d_on) {
	        table_old  = tableh_d;
	        table_new  = table_d_offset + table_d_sign * table_delta;
	        table_diff =  (table_old *10000.0  - table_new * 10000.0 )/10000.0; 
	        if (table_diff < 0.0) table_diff = - table_diff;
	        if (table_diff > table_move_min) {
	          tableh_d = table_new;
	          pvPut (tableh_d);  
	          if  (verbose)  { printf("   diffr table:  %12.8f -> %12.8f\n",
				          table_old, table_new);  }
	        } else {
	          if  (verbose)  { printf("   diffr table:  stay at %12.8f\n",table_old);}
	        }
	      } else {
	        if  (verbose)  { printf("   diffr table:  not moving\n");}
	      }
	      /* wait for undulator to finish */
	      if (und_track) {
	        undulator_busy   = 1;
	        delay = 0.1;
          epicsThreadSleep(delay);
	        while (undulator_busy) {
	          if (delay < 0.95) delay += 0.1; 
            epicsThreadSleep(delay);
	          pvGet(und_busy);	
	          pvGet(und_abort);
	          undulator_busy = 0;
	          if (!und_abort) undulator_busy = und_busy ;
	          if (verbose) {printf(". ");}
	        }
          pvGet(und_e_rbv);
	        if (verbose) { printf("    und energy reads %12.8f\n", und_e_rbv); }
	      }
      }
      /* get current mono angle, update energy readback */
      pvGet(mono_rbv);
      if (mono_rbv < 0.001 )  mono_rbv = 0.001;
      energy_rbv =  hc_o_2d / sin(mono_rbv * deg2rad) ;
      if (verbose) { 
	      printf("    mono angle_rbv, energy_rbv = %12.8f  %12.8f\n", mono_rbv, energy_rbv);
      } 
      pvPut(energy_rbv);
      energy_busy = 0;
      pvPut(energy_busy);
      efClear(mono_angle_mon);
      efClear(und_track_mon);
      if (verbose) {printf("  ENERGY move done\n"); }
    } state monitor_changes

    /*-------------------------------------------------------------------*/
    /*                  MONO ANGLE CHANGED                                 */
    /* when table or undulator change by themsleves, do nothing */
    /* when mono_angle changes by itself, change energy, and let*/
    /* the table and undulator stay where they are*/
    when( efTestAndClear(mono_angle_mon) ) {
      if (verbose) {printf("-------\nEnergy: angle changed! "); }
      if (mono_angle < mono_angle_min)  mono_angle = mono_angle_min;
      energy  = hc_o_2d / sin(mono_angle * deg2rad) ;
      pvPut(energy);
      if (verbose) {
	      printf("Energy: mono angle changed\n");
	      printf("        setting energy to %12.8f \n", energy);
      }
      /* get current mono angle, update energy readback */
      pvGet(mono_rbv);
      if (mono_rbv < 0.001 )  mono_rbv = 0.001;
      energy_rbv =  hc_o_2d / sin(mono_rbv * deg2rad) ;
      if (verbose) {printf("        energy rbv = %12.8f \n", energy_rbv);}
      pvPut(energy_rbv);
      efClear(energy_mon);	
      efClear(mono_angle_mon);
    } state monitor_changes
    /*                  MONO D SPACING CHANGED                             */
    when( efTestAndClear(mono_d_mon) ) {
      if (verbose) {printf("-------\nEnergy: mono_d changed! "); }
      if (mono_d < 0.1) mono_d = 1.920128;
      hc_o_2d   = hc / (2 * mono_d);
      energy_min= 1/ hc_o_2d; /* prevent asin(hc_o_2d/energy) from barfing a NaN  */
      if (verbose) {
	      printf("Energy: mono d spacing changed to -> %12.8f \n", mono_d);
      }
    } state monitor_changes
    /*                  MONO C SPACING CHANGED                             */
    when( efTestAndClear(mono_c_mon) ) {
      if (verbose) {printf("-------\nEnergy: mono_c changed! "); }
      if (mono_c < 0.1) mono_c = 9.10901;
      if (verbose) {printf("Energy: mono channel changed to -> %12.8f \n", mono_c);}
    } state monitor_changes
    /*                  UNDULATOR TRACKING CHANGED                         */
    /* reset offset if switched to on */
    when( efTestAndClear(und_track_mon) ) {
      if (verbose) {printf("Energy: saw und_track change: und_track -> %3i \n", und_track);}
      if (und_track) {
	      und_offset = und_e_rbv - (energy / 1000.000);
	      pvPut(und_offset);
	      if (verbose) {
	        printf("    changed undulator offset to %12.8f \n", und_offset);
	      }
      }
      efClear(und_track_mon);
    } state monitor_changes
    /*                  TABLE_S TRACKING CHANGED                           */
    /* reset offset if switched to on */
    when( efTestAndClear(table_s_mon) ) {
      if (verbose) {printf("Energy: saw table_s change --");}
      if (table_s_on) {
	      table_s_offset = tableh_s - 2. * mono_c * table_s_sign * cos(mono_angle * deg2rad);
	      pvPut(table_s_offset);
	      if (verbose) {
	        printf("    table_s offset changed to %12.8f \n", table_s_offset);
	      }
      }
      efClear(table_s_mon);
    } state monitor_changes
    /*                  TABLE_D TRACKING CHANGED                           */
    /* reset offset if switched to on */
    when( efTestAndClear(table_d_mon) ) {
      if (verbose) {printf("Energy: saw table_d change --");}
      if (table_d_on) {
	      table_d_offset = tableh_d - 2. * mono_c * table_d_sign * cos(mono_angle * deg2rad);
	      pvPut(table_d_offset);
	      if (verbose) {
	        printf("    table_d offset changed to %12.8f \n", table_d_offset);
	      }
      }
      efClear(table_d_mon);
    } state monitor_changes
  }
}
