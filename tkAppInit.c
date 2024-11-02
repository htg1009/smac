/* -*- Mode: C -*- */

/* tkAppInit.c -- */

/*
 * Copyright (c) 1996, 1997 Regents of the University of California.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by the University of
 *      California, Berkeley and the California PATH Program.
 * 4. Neither the name of the University nor of the California PATH
 *    Program may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
/* 
 * tkAppInit.c --
 *
 *	Provides a default version of the Tcl_AppInit procedure for
 *	use in wish and similar Tk-based applications.
 *
 * Copyright (c) 1993 The Regents of the University of California.
 * Copyright (c) 1994 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 */

#ifndef lint
static char sccsid[] = "@(#) tkAppInit.c 1.15 95/06/28 13:14:28";
#endif /* not lint */

#include <stdlib.h>
#include "tk.h"
EXTERN int		Itcl_Init _ANSI_ARGS_((Tcl_Interp *interp));
EXTERN int		Itk_Init _ANSI_ARGS_((Tcl_Interp *interp));

/*
 * The following variable is a special hack that is needed in order for
 * Sun shared libraries to be used for Tcl.
 */

extern int matherr();
static int (*dummyMathPtr)() = matherr;


/*
 *----------------------------------------------------------------------
 *
 * main --
 *
 *	This is the main program for the application.
 *
 * Results:
 *	None: Tk_Main never returns here, so this procedure never
 *	returns either.
 *
 * Side effects:
 *	Whatever the application does.
 *
 *----------------------------------------------------------------------
 */

void
main(int argc, char** argv)
     /* argc -- Number of command-line arguments. */
     /* argv -- Values of command-line arguments. */
{
    Tk_Main(argc, argv, Tcl_AppInit);
}



/*
 *----------------------------------------------------------------------
 *
 * Tcl_AppInit --
 *
 *	This procedure performs application-specific initialization.
 *	Most applications, especially those that incorporate additional
 *	packages, will have their own version of this procedure.
 *
 * Results:
 *	Returns a standard Tcl completion code, and leaves an error
 *	message in interp->result if an error occurs.
 *
 * Side effects:
 *	Depends on the startup script.
 *
 *----------------------------------------------------------------------
 */

static const char * shift_tk_dirname = "SHIFT_TKDIR";

int
Tcl_AppInit(Tcl_Interp* interp)
     /* interp -- Interpreter for application. */
{
  char buffer[250];
  char *g;

  if (Tcl_Init(interp) == TCL_ERROR) {
    return TCL_ERROR;
  }
  if (Tk_Init(interp) == TCL_ERROR) {
    return TCL_ERROR;
  }

  /*
   * Call the init procedures for included packages.  Each call should
   * look like this:
   *
   * if (Mod_Init(interp) == TCL_ERROR) {
   *     return TCL_ERROR;
   * }
   *
   * where "Mod" is the name of the module.
   */


  /*
   * Call Tcl_CreateCommand for application-specific commands, if
   * they weren't already created by the init procedures called above.
   */

  /*
   * Specify a user-specific startup file to invoke if the application
   * is run interactively.  Typically the startup file is "~/.apprc"
   * where "app" is the name of the application.  If this line is deleted
   * then no user-specific startup file will be run under any conditions.
   */

/*
  g = getenv(shift_tk_dirname);
  if (g == NULL) {
    fprintf(stderr,
	    "There is no %s environment variable set.\n",
	    shift_tk_dirname);
    fprintf(stderr, "Exiting...\n");
    exit(0);
  }
*/
  strcpy(buffer, "source initialize.tcl");

/*
	strcat(buffer, g);
  strcat(buffer, "/initialize.tcl\0");
      */	
  Tcl_Eval(interp, buffer);
  Tcl_Eval(interp, "CreateMainWindow");
  return TCL_OK;
}

/* end of file -- tkAppInit.c -- */
