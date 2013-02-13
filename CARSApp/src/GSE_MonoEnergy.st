/*   -*-c-*-   (this starts emacs in c-mode) */
program GSE_MonoEnergy("MONO=13IDE:En, ID=ID13us:, MTH=13IDA:m65, MY=13IDA:m66, FB=13IDA:mono_pid2," 
                       "CAL=13ID_DS_UndCalibration.xml")

/*
 *  implements monitoring, movement, and synchronization of virtual
 *  motor "energy", using monochromator angle and parameters and
 *  undulator gap, table height.  Rewritten for VG monochromator
 *
 *  uses PVs defined in GSE_MonoEnergy.db
 *
 *  Feb  7, 2000   Matt Newville
 *  May 10, 2000   MN
 *  Jul  5, 2000   MN: add shutter_pv to check shutter status 
 *                     before undulator move
 *  Oct  7, 2002   MN: altered arg list to use PRE for main prefix,
 *                     converted from XTAL table to true motors
 *                     for 2nd crystal motions.
 *  Feb 17, 2008   MN: add check for 'undulator busy' before trying to 
 *                     move the undulator: if it is busy, poke {ID}Stop.VAL 
 *                     before trying to move again
 *  Jan 18, 2011   MN: removed EXPTAB tracking -- never used, relied on IDC crate
 *
 *  Jun  4, 2012  MLR: Removed Z2 for new mono
 *  Jun 29, 2012  MN:  updated hc, d spacing for Si 111
 *  Oct 18, 2012  MN:  added args for MONO, MTH, MY to generalize for C/D and E mono 
 *                     changed name from Energy to GSE_MonoEnergy
 *  Oct 22, 2012  MN:  add "Set ID Offset" (now!) variable
 *  Oct 28, 2012  MN:  fixed use of busy record (fix is to GSE_MonoEnergy.db) so that put-wait works
 *
 */
%%#include <math.h>
%%#include <epicsThread.h>
%%#include "GSE_MonoSupport.h"

#define MAX_POSITIONS 10000
#define ID_CONTROL_MODE_ENERGY 0
#define ID_CONTROL_MODE_GAP    1

/* These are from the enums for motor .SPMG" */
#define MOTOR_STOP 0
#define MOTOR_GO   3

char *calibrationFile;

/* 2nd crystal table PVs  */
double y2;        assign y2        to "{MY}.VAL";             monitor y2;
int    y2_done;   assign y2_done   to "{MY}.DMOV";            monitor y2_done;
int    y2_stop;   assign y2_stop   to "{MY}.SPMG";
double y2_mvmin;  assign y2_mvmin  to "{MONO}:y2_mvmin.VAL";  monitor y2_mvmin;

/* Mono Angle PV */        
double th;        assign th        to "{MTH}.VAL";   monitor th;
double th_rbv;    assign th_rbv    to "{MTH}.RBV";   monitor th_rbv;
int    th_set;    assign th_set    to "{MTH}.SET";
int    th_done;   assign th_done   to "{MTH}.DMOV";  monitor th_done;
int    th_stop;   assign th_stop   to "{MTH}.SPMG";

/* undulator PVs  (from {ID}) */
double id_val;        assign id_val       to "{ID}ScanEnergy.VAL";    monitor id_val;
double id_rbv;        assign id_rbv       to "{ID}Energy.VAL";        monitor id_rbv;
double id_gap;        assign id_gap       to "{ID}ScanGap.VAL";       monitor id_gap;
double id_gap_rbv;    assign id_gap_rbv   to "{ID}Gap.VAL";           monitor id_gap_rbv;
int    id_harmonic;   assign id_harmonic  to "{ID}HarmonicValue.VAL"; monitor id_harmonic;
int    id_busy;       assign id_busy      to "{ID}Busy.VAL";          monitor id_busy;
int    id_stop;       assign id_stop      to "{ID}Stop.VAL";
double id_start_gap;  assign id_start_gap to "{ID}SSStartGap.VAL";    monitor id_start_gap;
double id_end_gap;    assign id_end_gap   to "{ID}SSEndGap.VAL";      monitor id_end_gap;

/* Energy PVs (from , {MONO}, and GSE_MonoEnergy.db) */
double en;        assign en        to "{MONO}:Energy.VAL";    monitor en;
double en_rbv;    assign en_rbv    to "{MONO}:E_RBV";     
double dspace;    assign dspace    to "{MONO}:dspace.VAL";    monitor dspace;
double height;    assign height    to "{MONO}:height.VAL";    monitor height;
double width;     assign width     to "{MONO}:width.VAL";     monitor width;
int    verbose;   assign verbose   to "{MONO}:verbose.VAL";   monitor verbose;
int    en_abort;  assign en_abort  to "{MONO}:en_abort.VAL";  

double en_timeout; assign en_timeout to "{MONO}:timeout.VAL";    
int    en_busy;    assign en_busy    to "{MONO}:Moving.VAL";    monitor en_busy;
int    en_set;     assign en_set     to "{MONO}:SET.VAL";       monitor en_set;

/* feedback wait */
int    fb_use;      assign fb_use    to "{MONO}:use_feedback.VAL";  monitor fb_use; 
int    fb_is_on;    assign fb_is_on  to "{FB}.FBON";                monitor fb_is_on;
int    fb_locked;   assign fb_locked to "{FB}Locked";               monitor fb_locked;

/* undulator tracking and offset */
int    id_track;        assign id_track        to "{MONO}:id_track.VAL";        monitor id_track;
int    theta_track;     assign theta_track     to "{MONO}:theta_track.VAL";     monitor theta_track;
int    id_wait;         assign id_wait         to "{MONO}:id_wait.VAL";         monitor id_wait;
double id_offset;       assign id_offset       to "{MONO}:id_off.VAL";          monitor id_offset;
int    id_set_off;      assign id_set_off      to "{MONO}:id_set_off.VAL";      monitor id_set_off;
int    id_harm_num;     assign id_harm_num     to "{MONO}:id_harmonic.VAL";     monitor id_harm_num;
int    id_control_mode; assign id_control_mode to "{MONO}:id_control_mode.VAL"; monitor id_control_mode;

/* mono position arrays for trajectory scans */
int    num_mono_positions;          assign num_mono_positions     to "{MONO}:num_mono_positions.VAL";     monitor num_mono_positions;
int    compute_mono_positions;      assign compute_mono_positions to "{MONO}:compute_mono_positions.VAL"; monitor compute_mono_positions;
double mono_angles[MAX_POSITIONS];  assign mono_angles            to "{MONO}:mono_angles.VAL";
double mono_heights[MAX_POSITIONS]; assign mono_heights           to "{MONO}:mono_heights.VAL";

/* tracking and offsets for y2
   y2 : 2nd crystal y (height above 1st crystal)
*/
int    y2_track;  assign y2_track  to "{MONO}:y2_track.VAL";  monitor y2_track;
double y2_off;    assign y2_off    to "{MONO}:y2_off.VAL";    monitor y2_off;


/* Event Flags */
evflag ef_en;                     sync en                       ef_en;
evflag ef_id_set_off;             sync id_set_off               ef_id_set_off;
evflag ef_y2_track;               sync y2_track                 ef_y2_track;
evflag ef_width;                  sync width                    ef_width;
evflag ef_dspace;                 sync dspace                   ef_dspace;
evflag ef_th;                     sync th                       ef_th;
evflag ef_th_rbv;                 sync th_rbv                   ef_th_rbv;
evflag ef_busy;                   sync en_busy                  ef_busy;
evflag ef_id_harmonic;            sync id_harmonic              ef_id_harmonic;
evflag ef_compute_mono_positions; sync compute_mono_positions   ef_compute_mono_positions;

/* constants */
double d2r;     /* deg->rad */
double r2d;     /* rad->deg */
double mil;     /* 0.001    */
double hc;      /* hc in eV*Ang */
double omega;   /* hc/2d    */
double en_rbv_new;
int    en_moving;  /*  internal flag to mean a move is in progress here*/

double en_min;
double en_max;
double th_min;
double th_max;
double tiny;
double y2_diff; double y2_old; 
int move_busy;
int wait_count;
int timeout_ticks;
int i;
int status;
double energy;
double gap;
double gap_step;

/*   State Set Energy is the only State in this Sequencer */

ss GSE_MonoEnergy {
  state init {  /* init */
    when() {
      printf("  GSE MonoEnergy > Energy State Set initializing \n");
      en_busy = 1; 
      pvPut(en_busy);      /* tell EPICS we're busy */
      if ((dspace < 0.001) || (dspace > 1000.)) {
        dspace  = 3.135485;                /* Si (111)  d spacing*/
        pvPut(dspace);
      }
      r2d     = 57.29577951308;   d2r    = 1./r2d;   mil    = 0.001;
      hc      = 12398.42;                 /* in eV*Ang */
      omega   = hc/(2 * dspace);          /* (hc / 2d) in eV */
      en_min  =   2200.00 ;               /* minimum energy  */
      en_max  = 150000.00 ;               /* maximum energy  */
      th_min  = r2d * asin(omega/en_max); /* minimum mono angle in degrees */
      th_max  = r2d * asin(omega/en_min); /* maximum mono angle in degrees */
      tiny    = 2.e-6;

      /* get current mono angle, update energy readback */
      if (th < th_min )  th = th_min;
      en     =  omega / sin(th * d2r);
      if (th_rbv < th_min ) th_rbv = th_min;
      en_rbv =  omega / sin(th_rbv * d2r) ;
      en     = en_rbv;
      pvPut(en);   pvPut(en_rbv);
      if (verbose) { printf("  En(init)> mono angle, energy = %12.6f %12.6f\n", th_rbv,en_rbv); }

      /* initialize undulator offset */
      id_offset = id_val - (en * mil);
      if (id_offset > 5000.)  id_offset = 50.0;
      pvPut(id_offset);
      if (verbose) { printf("   En(init)> ID energy, offset = %12.6f %12.6f\n", id_rbv, id_offset); }
      efClear(ef_id_set_off);
      
      /* Read energy/gap calibration file */
      calibrationFile = macValueGet("CAL");
      GSE_MonoReadCalibration(calibrationFile);

      efClear(ef_en);    
      en_busy = 0;  
      pvPut(en_busy);      /* tell EPICS we're not busy */
      if (verbose) { printf("   En(init)> done initializing\n");}
      efClear(ef_th);
      efClear(ef_busy); 
    } state monitor_changes
  }

/*------------------------------------------------------------------*/
  state monitor_changes {
    when(efTestAndClear(ef_en)) {
      /* when energy changes: move mono angle, undulator, table Y and L
      strategy:
      -> set "energy busy"
      -> check that energy is a reasonable number, convert if needed
      if "set energy" then:
            -> set new mono angle th based on new energy value
            -> let the ev_th handle the rest
         else (normal energy move) then:
            -> start move of undulator
            -> move th
        -> move table y and l
        -> wait for undulator to finish
        end if
        -> unset "energy busy"
      */

      en_moving = 1;
      /*  en_busy = 1;  pvPut(en_busy); */
      /* check that energy is in the allowable range */
      if (en <    0.0)  en = -en;         /* force positive */
      if (en <  500.0)  en =  en * 1000.; /* force units to eV, not KeV */
      if (en < en_min)  en =  en_min;     /* force minimum energy */
      if (en > en_max)  en =  en_max;     /* force maximum energy */
      if (en_set) {      /*  ENERGY SET  */
        if (verbose) { printf("   En(set)> mono energy-> %12.6f\n", en);}
        pvPut(en);
        th     = asin(omega / en) * r2d;  /* mono angle */
        th_set = 1;  pvPut(th_set);       /* change mono to SET mode */
        pvPut(th);                        /* put  the new value */
        th_set = 0;  pvPut(th_set);       /* change mono to USE mode */
        if (verbose) { printf("   En(set)> mono angle -> %12.6f\n", th);}
      } 
      else {           /*  ENERGY MOVE  */
        if (verbose) { printf("  En(move)> monoE->%12.6f", en);}

        /* start undulator move */
        if (id_track) {
          if (id_control_mode == ID_CONTROL_MODE_ENERGY) {
            id_val  = (id_offset + en * mil) ;  
            if ((id_val < 0.)||(id_val > 5000.)) id_val = id_rbv;
            /* Copy the ID harmonic from the mono database to the undulator */
            id_harmonic = id_harm_num;
            pvPut(id_harmonic);

            /* if the undulator is still busy (from a previous move?? stuck??), 
               stop the undulator now */        
            if (id_busy) {
              if (verbose) { printf(" clear id_busy");}
              id_stop = 1; 
              pvPut(id_stop);
            }
            /* put id value*/
            pvPut(id_val);
            if (verbose) { printf(", id_energy->%12.6f",id_val);}
          }
          else {
            /* if the undulator is still busy (from a previous move?? stuck??), 
               stop the undulator now */        
            if (id_busy) {
              if (verbose) { printf(" clear id_busy");}
              id_stop = 1; 
              pvPut(id_stop);
            }
            status = GSE_MonoEnergyToGap(id_harm_num, en, &gap);
            if (status == 0) {
              id_gap = id_offset + gap;
              pvPut(id_gap);
              if (verbose) { printf(", id_gap->%12.6f",id_gap);}
            } else {
              printf("Error calling GSE_monoEnergyToGap for harmonic=%d energy=%f\n", id_harm_num, en);
            }
          }
        }

        /* move mono angle note that we're off by a tiny amount at this point */
        th   =  (asin(omega / en) * r2d) - tiny;
        if (th < th_min) th = th_min;
        if (verbose) { printf(",  mono_angle->%12.6f\n", th);}
        pvPut(th);

        /* move 2nd xtal Y to keep beam offset fixed */
        if (y2_track) {
          width  =  height / (2 * cos(th * d2r));
          pvPut(width);
          y2_old = y2;
          y2  = y2_off + width;
          if (fabs(y2 - y2_old) > y2_mvmin) { 
          pvPut(y2);  
        }
        if (verbose) { 
          printf("  En(move)> 2nd XTAL y2->%12.6f, height->%12.6f\n", y2, height);}
        } 
      }
    } state wait_done
    
/*-------------------------------------------------------------------*/
/* 
    Other Events :
    when undulator changes  by itself:  do nothing 
    when theta changes by itself anf theta_track=1, change energy, and track y2 and undulator */
    /* mono angle changed */
    when( efTestAndClear(ef_th) && (theta_track != 0)) { 
      if (verbose) {printf("  En(mono)> Mono angle changed: %12.6f\n", th); }
      if (th < th_min)  {
        th = th_min;
      }
      en  = omega / sin(th * d2r) ;

      en_moving = 1;
      if (verbose) { printf("theta event:  en_busy is %d \n", en_busy); }
      /* en_busy = 1;    pvPut(en_busy);*/

      pvPut(en);
      /* get current mono angle, update energy readback */
      if (th_rbv < th_min )  th_rbv = th_min;
      en_rbv =  omega / sin(th_rbv * d2r) ;
      pvPut(en_rbv);
      efClear(ef_en); 
      efClear(ef_th);

      /* move 2nd xtal Y to keep beam offset fixed */
      if (y2_track) {
        width  =  height / (2 * cos(th * d2r));
        pvPut(width);
        y2_old = y2;
        y2 = y2_off + width;
        y2_diff = fabs(y2 - y2_old);
        if (y2_diff > y2_mvmin) {  pvPut(y2);  }
        if (verbose) { printf("  En(move)> 2nd XTAL y2,width,height -> %12.6f %12.6f %12.6f\n",
                      y2, width, height);}
      } 

      /* track undulator    */
      if (id_track) {
        if (id_control_mode == ID_CONTROL_MODE_ENERGY) {
          /* Copy the ID harmonic from the mono database to the undulator */
          id_harmonic = id_harm_num;
          pvPut(id_harmonic);
          id_val  = (id_offset + en * mil) ;  
          if ((id_val < 0.)||(id_val > 5000.)) id_val = id_rbv;
          pvPut(id_val);
          if (verbose) { printf("  En(mono)> ID energy -> %12.6f\n",id_val);}
        }
        else {
          status = GSE_MonoEnergyToGap(id_harm_num, en, &gap);
          if (status == 0) {
            id_gap = id_offset + gap;
            pvPut(id_gap);
            if (verbose) { printf(", id_gap->%12.6f",id_gap);}
          } else {
            printf("Error calling GSE_monoEnergyToGap for harmonic=%d energy=%f\n", id_harm_num, en);
          }
        }
      }
    } state wait_done

    /* ef_busy: en_busy got set to 1 ... did the mono really move? */
    when(efTestAndClear(ef_busy) ) { 
      if (en_moving == 0) { 
        en_busy = 0;
        pvPut(en_busy);
      }
    } state monitor_changes

    /* mono angle readback changed: update energy appropriately */
    when( efTestAndClear(ef_th_rbv) ) { 
      if (th_rbv < th_min )  th_rbv = th_min;
      en_rbv_new =  omega / sin(th_rbv * d2r);
      if (fabs(en_rbv_new - en_rbv) > tiny) {
        en_rbv = en_rbv_new;
        pvPut(en_rbv);
        if (verbose && (fabs(en_rbv_new - en_rbv) > 1.e-1)) { 
          printf("  En(th_rbv)> Readback angle, energy set to %12.6f %12.6f\n", 
            th_rbv, en_rbv);
        }
      }      
      efClear(ef_en); 
      efClear(ef_th);
    } state monitor_changes

    /* undulator tracking : reset offset if switched to on */
    when( efTestAndClear(ef_id_set_off)) {
      if (id_set_off == 1) {
        id_offset = id_val - en * mil;
        pvPut(id_offset);
        if (verbose) {printf("  En(id_track)> changed ID off => %12.6f\n",id_offset);}
      }
      id_set_off = 0;
      pvPut(id_set_off);
      efClear(ef_id_set_off); 
    } state monitor_changes


    /* d spacing redefined */
    when( efTestAndClear(ef_dspace)) {
      if (dspace < 0.0)   dspace = -dspace;       /* force positive */
      if (dspace > 100.0) dspace = dspace / 1000.; 
      if (dspace < 0.01 ) dspace = dspace * 1000.;
      omega   = hc/(2 * dspace);          /* (hc / 2d) in eV */
      en_min  = 2200.000 ;                /* minimum energy  */
      en_max  = 150000.00 ;               /* maximum energy  */
      th_min  = r2d * asin(omega/en_max); /* minimum mono angle in degrees */
      th_max  = r2d * asin(omega/en_min); /* maximum mono angle in degrees */
      pvPut(dspace);
      if (verbose) {printf("  En(dspace) => %12.6f\n",dspace);}
    } state monitor_changes

    /* channel width redefined */
    when( efTestAndClear(ef_width)) {
      if (width < 0.0)  width = -width;       /* force positive */
      if (width >80.0)  width = 80.0; 
      if (width < 5. )  width =  5.0;
      pvPut(width);
      if (verbose) {printf("  En(width) => %12.6f\n",width);}
    } state monitor_changes

    /* Request to compute mono positions for trajectory scan */
    when( efTestAndClear(ef_compute_mono_positions) && (compute_mono_positions == 1)) {
      if (num_mono_positions > MAX_POSITIONS) {
        num_mono_positions = MAX_POSITIONS;
        pvPut(num_mono_positions);
      }
      gap_step = (id_end_gap - id_start_gap)/(num_mono_positions-1);
      if (verbose) {printf("  En(compute_mono_positions) gap_start=%f, gap_stop=%f, gap_step=%f\n", id_start_gap, id_end_gap, gap_step);}
      for (i=0; i<MAX_POSITIONS; i++) {
        mono_angles[i] = 0;
        mono_heights[i] = 0;
      }
      for (i=0; i<num_mono_positions; i++) {
        gap = id_start_gap + gap_step*i;
        status = GSE_MonoGapToEnergy(id_harmonic, gap, &energy);
        if (status) {
          printf(" En(compute_mono_positions), error converting gap=%f to energy for harmonic %d\n", gap, id_harmonic);
          energy = 0;
        } 
        if (verbose) {printf("  En(compute_mono_positions) i=%d, gap=%f, energy=%f\n", i, gap, energy);}
        mono_angles[i] = (asin(omega / energy) * r2d);
        if (y2_track) {
          mono_heights[i]  = y2_off + height / (2 * cos(mono_angles[i] * d2r));
        } else {
          mono_heights[i] = y2;
        }
      }
      pvPut(mono_angles);
      pvPut(mono_heights);
      compute_mono_positions = 0;
      pvPut(compute_mono_positions);
    } state monitor_changes
  }
  
  state wait_done {
    /* We are relying on the fact that +e and +x are the default options
     * so the entry and exit blocks are not executed when wait_done transitions to itself */
    entry {
      move_busy = 1;
      timeout_ticks = (1000.0*en_timeout)+0.5;
      wait_count = 0;
    }
    
    when (en_abort) {
      id_stop = 1;
      pvPut(id_stop);
      th_stop = MOTOR_STOP;
      pvPut(th_stop, SYNC);
      th_stop = MOTOR_GO;
      pvPut(th_stop);
      y2_stop = MOTOR_STOP;
      pvPut(y2_stop, SYNC);
      y2_stop = MOTOR_GO;
      pvPut(y2_stop);
      en_abort = 0;
      pvPut(en_abort);      
    } state monitor_changes

    when( delay(0.001) ) {
      /* Wait for undulator, mono, 2nd xtal to finish 
         this gets tricky as we're waiting for things that 
         may or may not be moving */
      move_busy = ((y2_track) && (y2_done == 0)) || (th_done == 0) || (id_busy && id_wait);
      if (fb_is_on && fb_use && (fb_locked == 0)) move_busy = 1;
      if (wait_count > timeout_ticks) move_busy = 0;
      if (verbose && (wait_count%100 == 0)) {
        printf("  En(wait): count/timeout=%4.4d/%4.4d", wait_count, timeout_ticks);
        printf(", busy=%d, id_done=%d, th_done=%d, y2_done=%d", move_busy, !(id_busy && id_wait),
          th_done, y2_done);
        if (fb_is_on) {
          printf(", feedback is on, locked=%d", fb_locked);
        }
        printf("\n");
      }
    } state wait_done
    
    when (move_busy == 0) {
    } state monitor_changes
    
    exit {
      /* Add force rbv update based on th_rbv */
      en_rbv =  omega / sin(th_rbv * d2r) ;
      pvPut(en_rbv);
      efClear(ef_th);
      efClear(ef_th_rbv);
      efClear(ef_width);
      efClear(ef_busy);
      en_moving = 0;
      if (verbose) {printf("  En(move)> done\n");}
      en_busy = 0; pvPut(en_busy);
      efClear(ef_busy);
    }
  }
}
