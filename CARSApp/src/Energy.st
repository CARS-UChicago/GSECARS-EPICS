/*   -*-c-*-   (this starts emacs in c-mode) */
program Energy("PRE=XXIDA:, ID=IDXX:,  SH=eps_mbbi4, FB=mono_pid1")

/*
 *  implements monitoring, movement, and synchronization of virtual
 *  motor "energy", using monochromator angle and parameters and
 *  undulator gap, table height.  Rewritten for VG monochromator
 *
 *  uses PVs defined in Energy.db
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
 *
 */
%%#include <math.h>
%%#include <epicsThread.h>

/* 2nd crystal table PVs  */
double y2;        assign y2        to "{PRE}m58.VAL";         monitor y2;
double y2_mvmin;  assign y2_mvmin  to "{PRE}E:y2_mvmin.VAL";  monitor y2_mvmin;
int    y2_done;   assign y2_done   to "{PRE}m58.DMOV";        monitor y2_done;

/* Mono Angle PV */        
double th;        assign th        to "{PRE}m57";            monitor th;
double th_rbv;    assign th_rbv    to "{PRE}m57.RBV";        monitor th_rbv;
int    th_set;    assign th_set    to "{PRE}m57.SET";
int    th_done;   assign th_done   to "{PRE}m57.DMOV";       monitor th_done;

/* undulator PVs  (from {ID}) */
double id_val;    assign id_val    to "{ID}ScanEnergy.VAL"; monitor id_val;
double id_rbv;    assign id_rbv    to "{ID}Energy.VAL";   
double id_harm;   assign id_harm   to "{ID}HarmonicValue.VAL";   
int    id_busy;   assign id_busy   to "{ID}Busy.VAL";      monitor id_busy;
int    id_stop;   assign id_stop   to "{ID}Stop.VAL";

int    shutter_pv;  assign shutter_pv to "{PRE}{SH}";

/* Energy PVs (from {EN} and Energy.db) */
int    use_id;    assign use_id    to "{PRE}E:use_id.VAL";    monitor use_id;
double en;        assign en        to "{PRE}E:Energy.VAL";    monitor en;
double en_rbv;    assign en_rbv    to "{PRE}E:E_RBV";     
double dspace;    assign dspace    to "{PRE}E:dspace.VAL";    monitor dspace;
double height;    assign height    to "{PRE}E:height.VAL";    monitor height;
double width;     assign width     to "{PRE}E:width.VAL";     monitor width;
int    verbose;   assign verbose   to "{PRE}E:verbose.VAL";   monitor verbose;
int    id_abort;  assign id_abort  to "{PRE}E:id_abort.VAL";  
/* int    id_factor; assign id_factor to "{PRE}E:id_factor.VAL";  */
int    id_factor; 
int    en_busy;   assign en_busy   to "{PRE}E:Moving.VAL";    monitor en_busy;
int    en_set;    assign en_set    to "{PRE}E:SET.VAL";       monitor en_set;

/* feedback wait */
int    fb_use;      assign fb_use    to "{PRE}E:use_feedback.VAL";  monitor fb_use; 
int    fb_is_on;    assign fb_is_on  to "{PRE}{FB}.FBON";     monitor fb_is_on;
int    fb_locked;   assign fb_locked to "{PRE}{FB}Locked";    monitor fb_locked;

/* undulator tracking and offset */
int    id_track;   assign id_track  to "{PRE}E:id_track.VAL"; monitor id_track;
double id_offset;  assign id_offset to "{PRE}E:id_off.VAL";monitor id_offset;

/* tracking and offsets for y2
     y2 : 2nd crystal y (height above 1st crystal)
*/
int    y2_track;  assign y2_track  to "{PRE}E:y2_track.VAL";  monitor y2_track;
double y2_off;    assign y2_off    to "{PRE}E:y2_off.VAL";    monitor y2_off;


/* Event Flags */
evflag ef_en;        sync en         ef_en;
evflag ef_id_track;  sync id_track   ef_id_track;
evflag ef_y2_track;  sync y2_track   ef_y2_track;
evflag ef_width;     sync width      ef_width;
evflag ef_dspace;    sync dspace     ef_dspace;
evflag ef_th;        sync th         ef_th;
evflag ef_th_rbv;    sync th_rbv     ef_th_rbv;

/* constants */
double d2r;     /* deg->rad */
double r2d;     /* rad->deg */
double mil;     /* 0.001    */
double hc;      /* hc in eV*Ang */
double omega;   /* hc/2d    */
double en_min;
double en_max;
double th_min;
double th_max;
float  d_time;
double tiny;
double y2_diff; double y2_old; 
int still_busy;
int wait_count;
/*   State Set Energy is the only State in this Sequencer */

ss Energy {
  state init {  /* init */
    when() {
      printf("   Energy > Energy State Set initializing \n");
      en_busy = 1;  pvPut(en_busy);      /* tell EPICS we're busy */
      if ((dspace < 0.001) || (dspace > 1000.)) {
        dspace  = 3.13555;                  /* Si (111)  d spacing*/
        pvPut(dspace);
      }
      r2d     = 57.29577951;   d2r    = 1./r2d;   mil    = 0.001;
      hc      = 12398.61;                 /* in eV*Ang */
      omega   = hc/(2 * dspace);          /* (hc / 2d) in eV */
      en_min  = 3000.000 ;                /* minimum energy  */
      en_max  = 100 * omega ;             /* maximum energy  */
      th_min  = r2d * asin(omega/en_max); /* minimum mono angle in degrees */
      th_max  = r2d * asin(omega/en_min); /* maximum mono angle in degrees */
      tiny    = 2.e-6;

      /* set up undulator info (if using undulator, that is!)*/
      id_busy = 0; id_val = 0. ; id_rbv=0.;
      id_track = 0;     id_offset = 0; fb_use=0;
      id_factor = 1;
      if (use_id) {
        printf( "   Energy with undulator\n");
      } else {
        printf( "   Energy without undulator\n");
      }

      /* get current mono angle, update energy readback */
      if (th < th_min )  th = th_min;
      en     =  omega / sin(th * d2r);
      pvGet(th_rbv);
      if (th_rbv < th_min ) th_rbv = th_min;
      en_rbv =  omega / sin(th_rbv * d2r) ;
      en     = en_rbv;
      pvPut(en);   pvPut(en_rbv);
      if (verbose) { printf("   E(init)> mono angle, energy = %12.6f %12.6f\n", th_rbv,en_rbv); }

      /* initialize Experimental Table offset */

      /* initialize undulator offset */
      if (use_id) {
        pvGet(id_rbv);
        /*pvGet(id_harm);*/
        /*pvGet(id_factor);*/
        id_offset = id_rbv - (en * mil * id_factor);
        if (id_offset > 5000.)  id_offset = 50.0;
        pvPut(id_offset);
        if (verbose) { printf("   E(init)> ID energy, offset = %12.6f %12.6f\n", id_rbv, id_offset); }
        efClear(ef_id_track);
      }
      efClear(ef_en);    
      en_busy = 0;  pvPut(en_busy);      /* tell EPICS we're not busy */
      if (verbose) { printf("   E(init)> done initializing\n");}
      efClear(ef_th);
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

      if (verbose) { printf("energy event: put en_busy to 1\n"); }
      en_busy = 1;  pvPut(en_busy);
      /* check that energy is in the allowable range */
      if (en <    0.0)  en = -en;         /* force positive */
      if (en <  500.0)  en =  en * 1000.; /* force units to eV, not KeV */
      if (en < en_min)  en =  en_min;     /* force minimum energy */
      if (en > en_max)  en =  en_max;     /* force maximum energy */
      if (en_set) {      /*  ENERGY SET  */
        if (verbose) { printf("   E(set)> mono energy -> %12.6f\n", en);}
        pvPut(en);
        th     = asin(omega / en) * r2d;  /* mono angle */
        th_set = 1;  pvPut(th_set);       /* change mono to SET mode */
        pvPut(th);                        /* put  the new value */
        th_set = 0;  pvPut(th_set);       /* change mono to USE mode */
        if (verbose) { printf("   E(set)> mono angle  -> %12.6f\n", th);}
      } else {           /*  ENERGY MOVE  */
        if (verbose) { printf("  E(move)> mono energy -> %12.6f\n", en);}
        /* start undulator move */
        if (use_id && id_track) {
          /* pvGet(id_harm);*/
          /*pvGet(id_factor);*/
          pvGet(shutter_pv);
          if (shutter_pv == 1) { /* only move undulator if shutter is open */
            /*id_val  = (id_offset + en * mil * id_factor)*id_harm; */
            id_val  = (id_offset + en * mil * id_factor) ;  
            if ((id_val < 0.)||(id_val > 5000.)) id_val = id_rbv;

            /* if the undulator is still busy (from a previous move?? stuck??), stop the undulator now */        
            if (id_busy) {
              if (verbose) { printf("  E(move)> clear busy ID!\n");}
              id_stop = 1; 
              pvPut(id_stop);
            }
            /* put id value*/
            pvPut(id_val);
            if (verbose) { printf("  E(move)> ID energy -> %12.6f\n",id_val);}
          } else {
            if (verbose) { printf("  E(move) cancelled: shutter closed\n");}
          }
        }
        /*move mono angle */
        /* note that we're off by a tiny amount at this point */
        th   =  (asin(omega / en) * r2d) - tiny;
        if (th < th_min) th = th_min;
        if (verbose) { printf("  E(move)> mono angle -> %12.6f \n", th);}
        pvPut(th);
        /*move 2nd xtal Y to keep beam offset fixed */
        if (y2_track) {
          width  =  height / (2 * cos(th * d2r));
          pvPut(width);
          pvGet(y2); y2_old = y2;
          y2  = y2_off + width;
          y2_diff = fabs(y2 - y2_old);
          if (verbose) { printf("  E(y2track: old, width, new, diff  %12.6f  %12.6f  %12.6f %12.6f\n",
                    y2_old, width, y2, y2_diff);}

          if (y2_diff > y2_mvmin) {  pvPut(y2);  }

          if (verbose) { printf("  E(move)> 2nd XTAL y2,width,height -> %12.6f %12.6f %12.6f\n",
                    y2, width, height);}
        } else {
          /* 
             width  =  height / (2 * cos(th * d2r));
             pvPut(width);
             if (verbose) { printf("  E(move)> Channel width -> %12.6f\n",width);}
          */
        }

        /* wait for undulator, mono, 2nd xtal to finish 
          this gets tricky as we're waiting for things that 
          may or may not be moving */
        d_time = 0.03; 
        /* tweak mono theta and wait */
        for (wait_count=0, still_busy=1; (wait_count<128) && still_busy; wait_count++) {
          epicsThreadSleep(d_time);
          still_busy = ((y2_track) && (y2_done == 0)) ||
                        (th_done == 0) || id_busy;
          if (verbose) { printf("  E feedback? > %i %i %i\n", wait_count, fb_use, fb_locked);}
          if (fb_is_on && fb_use) {
            still_busy = still_busy || (fb_locked == 0);
          }
          if (verbose) {
            printf("[%i%i%i]", id_busy, th_done, y2_done);
            if (!(wait_count % 8)) printf("\n");
          }
        }
        if ((verbose) && (wait_count % 8)) {printf("\n");}
      }
      if (verbose) { printf("end of energy event: put en_busy to 0\n"); }
      en_busy = 0; pvPut(en_busy);
      efClear(ef_th);
      efClear(ef_width);
      pvGet(id_rbv);
      pvGet(th_rbv);

      /* add force rbv update based on th_rbv */
      en_rbv =  omega / sin(th_rbv * d2r) ;
      pvPut(en_rbv);
      efClear(ef_th_rbv);

      if (use_id){ efClear(ef_id_track);}
      if (verbose) {printf("  E(move)> done ID = %12.6f, mono theta = %12.6f, E = %12.6f\n",
               id_rbv, th_rbv,en_rbv); }
    } state monitor_changes
    
/*-------------------------------------------------------------------*/
/* 
     Other Events :
     when table or undulator change by themsleves, do nothing 
     when th changes by itself, change energy, and let
     the table and undulator stay where they are
*/
   /* mono angle changed */
    when( efTestAndClear(ef_th) ) { 
      if (verbose) {printf("  E(mono)> Mono angle changed: %12.6f\n", th); }
      if (th < th_min)  {
        th = th_min;
      }
      en  = omega / sin(th * d2r) ;

      if (verbose) { printf("theta event: put en_busy to 1\n"); }
      en_busy = 1;  pvPut(en_busy);

      pvPut(en);
      if (verbose) {printf("  E(mono)> Energy being set to %12.6f %12.6f\n", en, th);}
      /* get current mono angle, update energy readback */
      pvGet(th_rbv);
      if (th_rbv < th_min )  th_rbv = th_min;
      en_rbv =  omega / sin(th_rbv * d2r) ;
      pvPut(en_rbv);
      efClear(ef_en); 
      efClear(ef_th);

      /*move 2nd xtal Y to keep beam offset fixed */
      if (y2_track) {
        width  =  height / (2 * cos(th * d2r));
        pvPut(width);
        pvGet(y2); y2_old = y2;
        y2  = y2_off + width;
        y2_diff = fabs(y2 - y2_old);
        if (verbose) { printf("  E(y2track: old, width, new, diff  %12.6f  %12.6f  %12.6f %12.6f\n",
                      y2_old, width, y2, y2_diff);}

        if (y2_diff > y2_mvmin) {  pvPut(y2);  }
        if (verbose) { printf("  E(move)> 2nd XTAL y2,width,height -> %12.6f %12.6f %12.6f\n",
                      y2, width, height);}
      } 

      /* track undulator    */
      if (use_id && id_track) {
        pvGet(shutter_pv);
        if (shutter_pv == 1) { /* only move undulator if shutter is open */
          id_val  = (id_offset + en * mil * id_factor) ;  
          if ((id_val < 0.)||(id_val > 5000.)) id_val = id_rbv;
          pvPut(id_val);
          if (verbose) { printf("  E(mono)> ID energy -> %12.6f\n",id_val);}
        } else {
          if (verbose) { printf("  E(mono) cancelled: shutter closed\n");}
        }
        /* wait for undulator */
        d_time = 0.03; 
        /* tweak mono theta and wait */
        for (wait_count=0, still_busy=1; (wait_count<128) && still_busy; wait_count++) {
          epicsThreadSleep(d_time);
          still_busy = ((th_done == 0) || id_busy);
          if (fb_is_on && fb_use) {  still_busy = still_busy || (fb_locked == 0); }
          if (verbose) {
            printf("E(mono) [%i%i%i]", id_busy, th_done, wait_count);
            if (!(wait_count % 8)) printf("\n");
          }
        }
        if ((verbose) && (wait_count % 8)) {printf("\n");}
      }

      efClear(ef_th_rbv); 

      if (verbose) { printf("end of theta event: put en_busy to 0\n"); }
      en_busy = 0;   pvPut(en_busy);
      if (use_id){ efClear(ef_id_track);}

    } state monitor_changes

    /* mono angle readback changed: update energy appropriately */
    when( efTestAndClear(ef_th_rbv) ) { 
      if (th_rbv < th_min )  th_rbv = th_min;
      en_rbv =  omega / sin(th_rbv * d2r);
      pvPut(en_rbv);
      if (verbose) {printf("  E(th_rbv)> Readback angle, energy set to %12.6f %12.6f\n", 
               th_rbv, en_rbv);}
      efClear(ef_en); 
      efClear(ef_th);
    } state monitor_changes

    /* undulator tracking : reset offset if switched to on */
    when( efTestAndClear(ef_id_track)) {
      if (id_track) {
        /* pvGet(id_harm); */
        /*pvGet(id_factor);*/
        /* id_offset = (id_rbv/id_harm) - en * mil * id_factor; */
        id_offset = id_rbv - en * mil * id_factor;
        pvPut(id_offset);
        if (verbose) {printf("  E(id_track)> changed ID off => %12.6f\n",id_offset);}
      }
    } state monitor_changes


   /* d spacing redefined */
   when( efTestAndClear(ef_dspace)) {
      if (dspace < 0.0)   dspace = -dspace;       /* force positive */
      if (dspace > 100.0) dspace = dspace / 1000.; 
      if (dspace < 0.01 ) dspace = dspace * 1000.;
      omega   = hc/(2 * dspace);          /* (hc / 2d) in eV */
      en_min  = 3000.000 ;                /* minimum energy  */
      en_max  = 100 * omega ;             /* maximum energy  */
      th_min  = r2d * asin(omega/en_max); /* minimum mono angle in degrees */
      th_max  = r2d * asin(omega/en_min); /* maximum mono angle in degrees */
      pvPut(dspace);
      if (verbose) {printf("  E(dspace) => %12.6f\n",dspace);}
    } state monitor_changes

    /* channel width redefined */
    when( efTestAndClear(ef_width)) {
      if (width < 0.0)  width = -width;       /* force positive */
      if (width >80.0)  width = 80.0; 
      if (width < 5. )  width =  5.0;
      pvPut(width);
      if (verbose) {printf("  E(width) => %12.6f\n",width);}
    } state monitor_changes
  }
}
