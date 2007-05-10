/*   -*-c-*-   (this starts emacs in c-mode) */
program BM13_Energy("E=XXBMA:E, MONO=XXBMA:m17, EXPTAB_Z=XXBMD:m22, YXTAL=XXBMA:MON:, ZXTAL=XXBMA:m14")

/*
 *  implements monitoring, movement, and synchronization of virtual
 *  motor "energy", using monochromator angle and parameters and
 *  table height.
 *
 *  uses PVs defined in 13BM_Energy.db
 *
 *  Feb  7, 2000   Matt Newville
 *  May 10, 2000   MN
 *  June 27, 2000  MLR  Converted from Energy.st, written by Matt Newville
 *                      This version is for the 13BM mono.  It does nothing
 *                      with the undulator
 *  Nov  2, 2000   MN  set defaults to BM -- st.cmd had been loading with 
 *                      'XTAL2=13BMA:MON:'  (ie, XTAL2, not XTAL),
 *                     which meant XTAL was 13IDA:MON:, moving the IDA Mono cage!
 *  Aug.  2, 2001  MLR  Limit second crystal Z moves to the soft limits of the motor
 *                      Previously if the energy was beyond the Z soft limit it 
 *                      tried to move the motor past the soft limit and the motor
 *                      did not move at all.
 *                      Fixed the logic for waiting for motors to get done.
 *                      Previously it was not waiting for mono motor and there was a
 *                      bug in the delay logic causing all moves to take 20 seconds!
 *  Apr.  9, 2002  MLR  Changed second crystal Z to be a simple motor rather than part
 *                      of table record.  Fixed bug in making Z move to soft limits of
 *                      the motor (needed +- tiny so we don't try to move exactly to
 *                      the soft limit).  Made "en" update so that if it is changed by
 *                      SNL (for example, keV to eV) the correct value exists in the PV.
 * Jun 05, 2003, MN     changes in recalculation of width when EXPTAB_Z table tracking is used.
 */
%%#include <math.h>
%%#include <epicsThread.h>

/* Energy PVs (from {EN} and Energy.db) */
double en;        assign en        to "{E}:Energy.VAL";    monitor en;
double en_rbv;    assign en_rbv    to "{E}:E_RBV";
double dspace;    assign dspace    to "{E}:dspace.VAL";    monitor dspace;
double height;    assign height    to "{E}:height.VAL";    monitor height;
double width;     assign width     to "{E}:width.VAL";     monitor width;
int    verbose;   assign verbose   to "{E}:verbose.VAL";   monitor verbose;
int    en_busy;   assign en_busy   to "{E}:Moving.VAL";    monitor en_busy;
int    en_set;    assign en_set    to "{E}:SET.VAL";       monitor en_set;

/* tracking and offsets for y2, z2, and xt:
     y2 : 2nd crystal y (height above 1st crystal)
     z2 : 2nd crystal z (translation along rail)
     xt : experimental table used for non-fixed offset mode
*/
int    y2_track;  assign y2_track  to "{E}:y2_track.VAL";  monitor y2_track;
int    z2_track;  assign z2_track  to "{E}:z2_track.VAL";  monitor z2_track;
int    xt_track;  assign xt_track  to "{E}:xt_track.VAL";  monitor xt_track;

double xt_off;    assign xt_off    to "{E}:xt_off.VAL";    monitor xt_off;
double xt_sign;   assign xt_sign   to "{E}:xt_sign.VAL";   monitor xt_sign;
double xt_mvmin;  assign xt_mvmin  to "{E}:xt_mvmin.VAL";  monitor xt_mvmin;
double xt_ht;     assign xt_ht     to "{EXPTAB_Z}.VAL";    monitor xt_ht;
int    xt_done;   assign xt_done   to "{EXPTAB_Z}.DMOV";   monitor xt_done;

/* 2nd crystal table PVs  (from {TAB} variable for Table) */
double z2;        assign z2        to "{ZXTAL}.VAL";       monitor z2;
double z2lo;      assign z2lo      to "{ZXTAL}.LLM";       monitor z2lo;
double z2hi;      assign z2hi      to "{ZXTAL}.HLM";       monitor z2hi;
int    z2_done;   assign z2_done   to "{ZXTAL}.DMOV";      monitor z2_done;
double y2;        assign y2        to "{YXTAL}t1.Y";       monitor y2;
int    y2_done;   assign y2_done   to "{YXTAL}T1:done.VAL"; monitor y2_done;

/* Mono Angle PV */
double th;        assign th        to "{MONO}";            monitor th;
double th_rbv;    assign th_rbv    to "{MONO}.RBV";        monitor th_rbv;
int    th_set;    assign th_set    to "{MONO}.SET";
int    th_done;   assign th_done   to "{MONO}.DMOV";       monitor th_done;

/* Event Flags */
evflag ef_en;        sync en         ef_en;
evflag ef_y2_track;  sync y2_track   ef_y2_track;
evflag ef_xt_track;  sync xt_track   ef_xt_track;
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
double xt_diff;
double xt_old;
double xt_new;
float  d_time;
double tiny;
int still_busy;
int wait_count;
/*   State Set Energy is the only State in this Sequencer */
ss Energy {
  state init {  /* init */
    when() {
      printf("   Energy > Energy State Set initializing \n");
      en_busy = 1;  pvPut(en_busy);      /* tell EPICS we're busy */
      /* Assume dspace of Si 311 if it currently has an unreasonable value */
      if ((dspace < 0.001) || (dspace > 1000.)) {
        dspace = 1.63749;
        pvPut(dspace);
      }
      r2d     = 57.29577951;   d2r    = 1./r2d;   mil    = 0.001;
      hc      = 12398.61;                 /* in eV*Ang */
      omega   = hc/(2 * dspace);          /* (hc / 2d) in eV */
      en_min  = 4125.000 ;                /* minimum energy  */
      en_max  = 100 * omega ;             /* maximum energy  */
      th_min  = r2d * asin(omega/en_max); /* minimum mono angle in degrees */
      th_max  = r2d * asin(omega/en_min); /* maximum mono angle in degrees */
      tiny    = 1.e-5;

      /* get current mono angle, update energy readback */
      if (th < th_min )  th = th_min;
      en     =  omega / sin(th * d2r);
      if (th_rbv < th_min ) th_rbv = th_min;
      en_rbv =  omega / sin(th_rbv * d2r) ;
      en     = en_rbv;
      pvPut(en);   pvPut(en_rbv);
      if (verbose) { printf("   E(init)> mono angle, energy = %12.6f %12.6f\n", th_rbv,en_rbv); }
      /* initialize Experimental Table offset */
      xt_off    = xt_ht -  xt_sign * 2 * width * cos(th * d2r);
      pvPut(xt_off);

      efClear(ef_en);
      en_busy = 0;  pvPut(en_busy);      /* tell EPICS we're not busy */
      if (verbose) { printf("   E(init)> done initializing\n");}
      efClear(ef_th);
    } state monitor_changes
  }

/*------------------------------------------------------------------*/
  state monitor_changes {
    when(efTestAndClear(ef_en)) {
      /* when energy changes: move mono angle, table Y and L
         strategy:
         -> set "energy busy"
         -> check that energy is a reasonable number, convert if needed
         if "set energy" then:
            -> set new mono angle th based on new energy value
            -> let the ev_th handle the rest
         else (normal energy move) then:
            -> move th
            -> move table y and xtal z
        end if
        -> unset "energy busy"
      */

      en_busy = 1;  pvPut(en_busy);
      /* check that energy is in the allowable range */
      if (en <    0.0)  en = -en;         /* force positive */
      if (en <  500.0)  en =  en * 1000.; /* force units to eV, not KeV */
      if (en < en_min)  en =  en_min;     /* force minimum energy */
      if (en > en_max)  en =  en_max;     /* force maximum energy */
      /* We might have changed en, so set new value - clear event flag so
       * this code does not execute again */
      pvPut(en); efClear(ef_en);
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

        /*move mono angle */
        /* note that we're off by a tiny amount at this point */
        th   =  (asin(omega / en) * r2d) - tiny;
        if (th < th_min) th = th_min;
        if (verbose) { printf("  E(move)>    mono angle -> %12.6f \n", th);}
        pvPut(th);
        /*move 2nd xtal Z to keep beam on the same place on xtal */
        if (z2_track) {
          z2  = height * en / (2 * omega);
          if (z2 < z2lo) z2 = z2lo + tiny;
          if (z2 > z2hi) z2 = z2hi - tiny;
          pvPut(z2);
          if (verbose) { printf("  E(move)>    2nd Xtal Z -> %12.6f\n",z2);}
        }
        /*move 2nd xtal Y to keep beam offset fixed */
        if (y2_track) {
          width  =  height / (2.0 * cos(th * d2r));
          pvPut(width);
          y2  = width;
          pvPut(y2);
          if (verbose) { printf("  E(move)> 2nd XTAL y2,width,height -> %12.6f %12.6f %12.6f\n",y2, width, height);}
        } else {
          /* width  =  height / (2.0 * cos(th * d2r));
	     pvPut(width);
	     if (verbose) { printf("  E(move)>    Channel width -> %12.6f\n",width);}
	  */
        }
        /*move Experimental Table to compensate for _NOT_ tracking y2 */
        if (xt_track) {
          xt_old  = xt_ht;
	  pvGet(width);
          xt_new  = xt_off + 2.00 * xt_sign * width * cos(th * d2r);;
          xt_diff = (xt_old *10000.0  - xt_new * 10000.0 ) / 10000.0 ;
          if (xt_diff < 0.0) xt_diff = - xt_diff;
	  if (verbose) { printf("  E(move)> exptab from %12.6f to %12.6f \n",xt_old,xt_new);}	  
          if (xt_diff > xt_mvmin) {
            xt_ht = xt_new;
            pvPut (xt_ht);
            if (verbose) { printf("  E(move)>    XAS Table Z -> %12.6f\n",xt_ht);}
          }
        }
        /*
          wait for mono, 2nd xtal to finish
          this gets tricky as we're waiting for things that
          may or may not be moving
        */
        d_time = 0.1;
        for (wait_count=0, still_busy=1; (wait_count<256) && still_busy; 
                                                                    wait_count++) {
          epicsThreadSleep(d_time);
          still_busy = ((y2_track && (y2_done == 0)) ||
                        (z2_track && (z2_done == 0)) ||
                        (xt_track && (xt_done == 0)) ||
                        (th_done == 0));
          if (verbose) {
            printf("[%i%i%i%i]", th_done, y2_done, z2_done, xt_done);
            if (!(wait_count % 8)) printf("\n");
          }
        }
        if ((verbose) && (wait_count % 8)) {printf("\n");}
      }
      en_busy = 0;
      pvPut(en_busy);
      efClear(ef_th);
      efClear(ef_width);
      if (verbose) {printf("  E(move)> done, mono theta = %12.6f, E = %12.6f\n",
                           th_rbv,en_rbv); }
    } state monitor_changes

/*-------------------------------------------------------------------*/
/*
   Other Events :
   when table changes itself, do nothing
   when th changes by itself, change energy, and let the table stay where it is
   when th_rbv changes update en_rbv
   
*/
   /* mono angle changed */
    when( efTestAndClear(ef_th) ) {
      if (verbose) {printf("  E(mono)> Mono angle changed: %12.6f\n", th); }
      if (th < th_min)  {
        th = th_min;
      }
      en  = omega / sin(th * d2r) ;
      pvPut(en);
      if (verbose) {printf("  E(mono)> Energy being set to %12.6f %12.6f\n", en, th);}
      /* get current mono angle, update energy readback */
      pvGet(th_rbv);
      if (th_rbv < th_min )  th_rbv = th_min;
      en_rbv =  omega / sin(th_rbv * d2r) ;
      if (verbose) {printf("  E(mono)> Energy rbv = %12.6f %12.6f\n", en_rbv, th_rbv);}
      pvPut(en_rbv);
      efClear(ef_en);
      efClear(ef_th);
    } state monitor_changes

    when( efTestAndClear(ef_th_rbv) ) {
      if (th_rbv < 0.001 )  th_rbv = 0.001;
      en_rbv =  omega / sin(th_rbv * d2r) ;
      pvPut(en_rbv);
    } state monitor_changes

    /*  experimental table tracking : reset offset if switched to on */
    when( efTestAndClear(ef_xt_track) ) {
      if (xt_track) {
        xt_off = xt_ht - 2.00 * width * xt_sign * cos(th * d2r);
        pvPut(xt_off);
        if (verbose) {printf("  E(xt_track)> changed table offset => %12.6f\n",xt_off);}
      }
    } state monitor_changes
        /*  xtal Z tracking : reset offset if switched to on */
        /* when( efTestAndClear(ef_z2_track) ) {
           if (z2_track) {
           if (verbose) {printf("  E(z2_track)> changed 2nd XTAL Z tracking to on\n");}
           }
           } state monitor_changes
        */

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
      if (verbose) {printf("  E> dspace => %12.6f\n",dspace);}
    } state monitor_changes

   /* channel width redefined */
   when( efTestAndClear(ef_width)) {
      if (width < 0.0)  width = -width;       /* force positive */
      if (width >80.0)  width = 80.0;
      if (width < 5. )  width =  5.0;
      pvPut(width);
      if (verbose) {printf("  E> width => %12.6f\n",width);}
    } state monitor_changes
  }
}



