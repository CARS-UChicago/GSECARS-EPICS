/*   -*-c-*-   (this starts emacs in c-mode) */
program Energy("E=XXIDA:E, ID=IDXX:, MONO=XXIDA:m17, EXPTAB_Z=XXIDC:m6, EXPTAB2=XXIDC:m7, XTAL=XXIDA:MON:, SHUTTER=XXIDA:eps_mbbi4")

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
 */
%%#include <math.h>
%%#include <sysLib.h>
%%#include <taskLib.h>

/* undulator PVs  (from {ID}) */
double id_val;    assign id_val    to "{ID}ScanEnergy.VAL"; monitor id_val;
double id_rbv;    assign id_rbv    to "{ID}Energy.VAL";   
double id_harm;   assign id_harm   to "{ID}HarmonicValue.VAL";   
int    id_busy;   assign id_busy   to "{ID}Busy.VAL";      monitor id_busy;

int    shutter_pv;  assign shutter_pv to "{SHUTTER}";

/* Energy PVs (from {EN} and Energy.db) */
int    use_id;    assign use_id    to "{E}:use_id.VAL";    monitor use_id;
double en;        assign en        to "{E}:Energy.VAL";    monitor en;
double en_rbv;    assign en_rbv    to "{E}:E_RBV";     
double dspace;    assign dspace    to "{E}:dspace.VAL";    monitor dspace;
double height;    assign height    to "{E}:height.VAL";    monitor height;
double width;     assign width     to "{E}:width.VAL";     monitor width;
int    verbose;   assign verbose   to "{E}:verbose.VAL";   monitor verbose;
int    id_abort;  assign id_abort  to "{E}:id_abort.VAL";  
/* int    id_factor; assign id_factor to "{E}:id_factor.VAL";  */
int    id_factor; 
int    en_busy;   assign en_busy   to "{E}:Moving.VAL";    monitor en_busy;
int    en_set;    assign en_set    to "{E}:SET.VAL";       monitor en_set;

/* undulator tracking and offset */
int    id_track;   assign id_track  to "{E}:id_track.VAL"; monitor id_track;
double id_offset;  assign id_offset to "{E}:id_off.VAL";monitor id_offset;

/* tracking and offsets for y2, z2, and xt:
     y2 : 2nd crystal y (height above 1st crystal)
     z2 : 2nd crystal z (translation along rail)
     xt : experimental table used for non-fixed offset mode
*/
int    y2_track;  assign y2_track  to "{E}:y2_track.VAL";  monitor y2_track;
int    z2_track;  assign z2_track  to "{E}:z2_track.VAL";  monitor z2_track;
int    xt_track;  assign xt_track  to "{E}:xt_track.VAL";  monitor xt_track;
int    xt2_track; assign xt2_track to "{E}:xt2_track.VAL"; monitor xt2_track;
double y2_off;    assign y2_off    to "{E}:y2_off.VAL";    monitor y2_off;

double xt_off;    assign xt_off    to "{E}:xt_off.VAL";    monitor xt_off;
double xt_sign;   assign xt_sign   to "{E}:xt_sign.VAL";   monitor xt_sign;
double xt_mvmin;  assign xt_mvmin  to "{E}:xt_mvmin.VAL";  monitor xt_mvmin;
double xt_ht;     assign xt_ht     to "{EXPTAB_Z}";        monitor xt_ht;
int    xt_done;   assign xt_done   to "{EXPTAB_Z}.DMOV";   monitor xt_done;

/* second table for large kb mirror */
double xt2_off;    assign xt2_off    to "{E}:xt2_off.VAL";    monitor xt2_off;
double xt2_sign;   assign xt2_sign   to "{E}:xt2_sign.VAL";   monitor xt2_sign;
double xt2_mvmin;  assign xt2_mvmin  to "{E}:xt2_mvmin.VAL";  monitor xt2_mvmin;
double xt2_ht;     assign xt2_ht     to "{EXPTAB2}";          monitor xt2_ht;
int    xt2_done;   assign xt2_done   to "{EXPTAB2}.DMOV";     monitor xt2_done;

/* 2nd crystal table PVs  (from {TAB} variable for Table) */
double z2;        assign z2        to "{XTAL}t1.Z";        monitor z2;
double y2;        assign y2        to "{XTAL}t1.Y";        monitor y2;
int    x2_done;   assign x2_done   to "{XTAL}T1:done.VAL"; monitor x2_done;

/* Mono Angle PV */		
double th;        assign th        to "{MONO}";            monitor th;
double th_rbv;    assign th_rbv    to "{MONO}.RBV";        monitor th_rbv;
int    th_set;    assign th_set    to "{MONO}.SET";
int    th_done;   assign th_done   to "{MONO}.DMOV";       monitor th_done;

/* Event Flags */
evflag ef_en;        sync en         ef_en;
evflag ef_id_track;  sync id_track   ef_id_track;
evflag ef_y2_track;  sync y2_track   ef_y2_track;
evflag ef_xt_track;  sync xt_track   ef_xt_track;
evflag ef_xt2_track; sync xt2_track  ef_xt2_track;
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
double xt2_diff;
double xt2_old;
double xt2_new;
float  d_time;
double tiny;
double z2_sign;
int i;
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
      z2_sign = -1;  /* note: xtal2 table record is at 180 degrees */      
      tiny    = 1.e-5;

      /* set up undulator info (if using undulator, that is!)*/
      id_busy = 0; id_val = 0. ; id_rbv=0.;
      id_track = 0;     id_offset = 0;
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
      xt_off    = xt_ht -  xt_sign * 2 * width * cos(th * d2r);
      pvPut(xt_off);

      xt2_off    = xt2_ht -  xt2_sign * 2 * width * cos(th * d2r);
      pvPut(xt2_off);

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
	/*move 2nd xtal Z to keep beam on the same place on xtal */
	if (z2_track) {
	  z2  = z2_sign * height * en / (2 * omega);
	  pvPut(z2);
	  if (verbose) { printf("  E(move)> 2nd Xtal Z -> %12.6f\n",z2);}
	}
	/*move 2nd xtal Y to keep beam offset fixed */
	if (y2_track) {
	  width  =  height / (2 * cos(th * d2r));
	  pvPut(width);
	  y2  = y2_off + width;
	  pvPut(y2);
	  width  =  height / (2 * cos(th * d2r));
	  pvPut(width);
	  if (verbose) { printf("  E(move)> 2nd XTAL y2,width,height -> %12.6f %12.6f %12.6f\n",
				y2, width, height);}
	} else {
	  /* 
	     width  =  height / (2 * cos(th * d2r));
	     pvPut(width);
	     if (verbose) { printf("  E(move)> Channel width -> %12.6f\n",width);}
	  */
	}
	/*move Experimental Table to compensate for _NOT_ tracking y2 */
	if (xt_track) {
	  xt_old  = xt_ht; 
	  pvGet(width);
	  xt_new  = xt_off + 2 * xt_sign * width * cos(th * d2r);;
	  xt_diff = (xt_old *10000.0  - xt_new * 10000.0 ) / 10000.0 ;
	  if (xt_diff < 0.0) xt_diff = - xt_diff;
	  if (verbose) {
	    printf("  E(move)> exptab: from %12.6f to %12.6f \n", xt_old, xt_new);
	  }
 	  if (xt_diff > xt_mvmin) { 
	    xt_ht = xt_new;
	    pvPut (xt_ht);  
	    if (verbose) { printf("  E(move)> XAS Table Z -> %12.6f\n",xt_ht);}
	  }
	} 
	if (xt2_track) {
	  xt2_old  = xt2_ht; 
	  pvGet(width);
	  xt2_new  = xt2_off + 2 * xt2_sign * width * cos(th * d2r);;
	  xt2_diff = (xt2_old *10000.0  - xt2_new * 10000.0 ) / 10000.0 ;
	  if (xt2_diff < 0.0) xt2_diff = - xt2_diff;
	  if (verbose) {
	    printf("  E(move)> exptab2: from %12.6f to %12.6f \n", xt2_old, xt2_new);
	  }
 	  if (xt2_diff > xt2_mvmin) { 
	    xt2_ht = xt2_new;
	    pvPut (xt2_ht);  
	    if (verbose) { printf("  E(move)> EXP Table2 -> %12.6f\n",xt2_ht);}
	  }
	} 


	/*
	  wait for undulator, mono, 2nd xtal to finish 
	  this gets tricky as we're waiting for things that 
	  may or may not be moving
	*/
	d_time = 0.1; 
	/* tweak mono theta and wait */
        for (wait_count=0, still_busy=1; (wait_count<256) && still_busy; wait_count++) {
          taskDelay(d_time*sysClkRateGet());
          still_busy = ((y2_track||z2_track) && (x2_done == 0)) ||
                        (xt_track  && (xt_done == 0)) ||
                        (xt2_track && (xt2_done == 0)) ||
                        (th_done == 0) || id_busy;
          if (verbose) {
            printf("[%i%i%i%i]", id_busy, th_done, x2_done, xt_done);
            if (!(wait_count % 8)) printf("\n");
          }
        }
        if ((verbose) && (wait_count % 8)) {printf("\n");}
      }
      en_busy = 0;
      pvPut(en_busy);
      efClear(ef_th);
      efClear(ef_width);
      pvGet(id_rbv);
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
      pvPut(en);
      if (verbose) {printf("  E(mono)> Energy being set to %12.6f %12.6f\n", en, th);}
      /* get current mono angle, update energy readback */
      pvGet(th_rbv);
      if (th_rbv < th_min )  th_rbv = th_min;
      en_rbv =  omega / sin(th_rbv * d2r) ;
      pvPut(en_rbv);
      efClear(ef_en); 
      efClear(ef_th);

      /*move Experimental Table to compensate for _NOT_ tracking y2 */
      if (xt_track) {
	xt_old  = xt_ht; 
	pvGet(width);
	xt_new  = xt_off + 2 * xt_sign * width * cos(th * d2r);;
	xt_diff = (xt_old *10000.0  - xt_new * 10000.0 ) / 10000.0 ;
	if (xt_diff < 0.0) xt_diff = - xt_diff;
	if (verbose) {
	  printf("  E(move)> exptab: from %12.6f to %12.6f \n", xt_old, xt_new);
	}
	if (xt_diff > xt_mvmin) { 
	  xt_ht = xt_new;
	  pvPut (xt_ht);  
	  if (verbose) { printf("  E(move)> XAS Table Z -> %12.6f\n",xt_ht);}
	}
      } 
      
      if (xt2_track) {
	xt2_old  = xt2_ht; 
	pvGet(width);
	xt2_new  = xt2_off + 2 * xt2_sign * width * cos(th * d2r);;
	xt2_diff = (xt2_old *10000.0  - xt2_new * 10000.0 ) / 10000.0 ;
	if (xt2_diff < 0.0) xt2_diff = - xt2_diff;
	if (verbose) {
	  printf("  E(move)> exptab2: from %12.6f to %12.6f \n", xt2_old, xt2_new);
	}
	if (xt2_diff > xt2_mvmin) { 
	  xt2_ht = xt2_new;
	  pvPut (xt2_ht);  
	  if (verbose) { printf("  E(move)> EXP Table2 -> %12.6f\n",xt2_ht);}
	  }
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
	d_time = 0.1; 
	/* tweak mono theta and wait */
        for (wait_count=0, still_busy=1; (wait_count<256) && still_busy; wait_count++) {
          taskDelay(d_time*sysClkRateGet());
	  still_busy = ((xt_track  && (xt_done == 0)) || 
			(xt2_track && (xt2_done == 0)) ||
			(th_done == 0) || id_busy);
          if (verbose) {
            printf("[%i%i%i]", id_busy, th_done, xt_done);
            if (!(wait_count % 8)) printf("\n");
          }
        }
        if ((verbose) && (wait_count % 8)) {printf("\n");}
      }

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
    /*  experimental table tracking : reset offset if switched to on */
    when( efTestAndClear(ef_xt_track) ) {
      if (xt_track) {
	xt_off = xt_ht - 2 * width * xt_sign * cos(th * d2r);
	pvPut(xt_off);
	if (verbose) {printf("  E(xt_track)> changed table offset => %12.6f\n",xt_off);}
      }
    } state monitor_changes
	/*  xtal Z tracking : reset offset if switched to on */
	/* when( efTestAndClear(ef_z2_track) ) {
	   if (z2_track) {
	   if (verbose) {printf("  E(z2_track)> changed 2nd XTAL Z offset to off\n");}
	   }
	   } state monitor_changes
	*/
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
