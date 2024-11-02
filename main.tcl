# -*- Mode: TCL -*-

# Carmma.tcl

# Copyright (c) 1996, 1997 Regents of the University of California.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the University of
#      California, Berkeley and the California PATH Program.
# 4. Neither the name of the University nor of the California PATH
#    Program may be used to endorse or promote products derived from
#    this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

# Written by Daniel Wiesmann, Duke Lee 

#############################################################################
#
#   Global Definition that is used throughout the program 
#
#############################################################################

# Length of the road in meters - let us make this variable also 
set roadFeatures(highway_length) 500

## This parameter is actually the (length * 12.5) (12.5 is the initial zoom)
set roadFeatures(length) [expr int($roadFeatures(highway_length) * 12.5)]
set roadFeatures(width) 50

# Now this is a parameter that is asked from user - default is 5 
set roadFeatures(num_lanes) 5
# Make sure that trajectory data is defined when defining snapshots
set roadFeatures(itraj) 0
set roadFeatures(xcir) 0
set roadFeatures(ycir) 0
set roadFeatures(rwyrad) 0

set ZoomIndex 1
## This parameter is actually the (length * 12.5) (12.5 is the initial zoom)
# set car length/width to actual l/w
set carFeatures(car_length) 5
set carFeatures(car_width)  2

set carmmaFont -adobe-helvetica-bold-r-*-*-17-*-*-*-*-*-*-*
set smallFont -adobe-helvetica-bold-r-*-*-12-*-*-*-*-*-*-*
set font_list [list carmmaFont smallFont]
foreach font $font_list {
    set err [catch {eval label .a$font -text "Test" -font $font}]
    if {$err == 1} {
	set font fixed
    }
}

option add Carmma*font $carmmaFont


#############################################################################
#
#   Helper Functions for CreateMainWindow 
#
#############################################################################

proc ShowHelp {} {
    
    tk_dialog .help Help "The complete documentation for this program can\
	    be found at http://www.path.berkeley.edu/\n        smart-ahs/carmma.html" "" 0 OK 
    
}
proc CreateSnap {} {
    
    global numberOfSnapShots
    
    if {[winfo exists .canvas]} {
	catch {wm deiconify .canvas}
	catch {raise .canvas}
    } else {
	SnapMainControl
    }
}


proc ViewSnap {} {
    
    set types {
	{{Highway Files}       {.hwy}        }
	{{All Files}            *            }
    }

    set file_to_view [tk_getOpenFile -filetypes $types]
    if {$file_to_view == ""} {
	return
    }
    CreateAnimation $file_to_view
    
}

#############################################################################
#
#   Creates the Main Window 
#
#############################################################################

proc CreateMainWindow {} {
    
    
    . configure -height 80 -width 300 
    frame .buttons
    
    #wm iconbitmap . @road2.xbm
    set snapImage [image create photo -file "./images/snap.gif"]
    set helpImage [image create photo -file "./images/help.gif"]
    set viewImage [image create photo -file "./images/view.gif"]
    set exitImage [image create photo -file "./images/exit.gif"]
    
    button .buttons.snap -bg grey -command CreateSnap
    button .buttons.view -image $viewImage -bg grey -command ViewSnap
    button .buttons.help -image $helpImage -bg grey -command {ShowHelp}
    button .buttons.exit -image $exitImage -bg grey -command {destroy .}
    
    .buttons.snap configure -image $snapImage
    
    place .buttons -relwidth 1 -relheight 1
    
    place .buttons.snap -relwidth .25 -relheight 1
    place .buttons.view -relwidth .25 -relheight 1 -relx .25
    place .buttons.help -relwidth .25 -relheight 1 -relx .5
    place .buttons.exit -relwidth .25 -relheight 1 -relx .75
    
}






