# -*- Mode: TCL -*-

# file.tcl

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

# <file.tcl> 

###################################################################
# This file contains information about the file related functions 
# of Carmma project. 
###################################################################

###################################################################
#
#   Openfile and process the file by lines using PROCESS_LINE, and 
#   load the file information into the window by using 
#   LOAD_FILE_INFORMATION  
#
###################################################################

proc OpenFile {} {
    
    global highwayFile got_num_lanes got_highway_length data_version 
    
    set types {
	{{Highway Files}       {.hwy}        }
	{{All Files}           *           }
    }
    
    set file [tk_getOpenFile -filetypes $types]
    if {$file == ""} {
	return
    }
    
    set got_num_lanes 0 
    set got_highway_length 0 
    set data_version -1 

    set f [open $file r]
    set highwayFile $file
    while {[gets $f line] >= 0} {
	processLine $line Application
    }
    close $f

    # this is for previous version which does not have 
    # information about the number of lanes 

    if {!$got_num_lanes || !$got_highway_length} {
	InquireAboutRoadFeatures LoadFileInformation
    } else {
	LoadFileInformation
    }
}
 
###################################################################
#
#   After loading information from the file, put up the snapshot 
#   information into the list. 
#
###################################################################

proc LoadFileInformation {} {
    
    global carInformationArray 
    global itemselect

    set snaps $carInformationArray(-1,snaps)
    .main.info.list delete 0 end

    
    set itemselect(totalEntries) [llength $snaps]
    foreach i $snaps {
	set label [list "Snapshot" $i]
	.main.info.list insert end $label
    }
    .main.info.new configure -state normal
    .main.info.new configure -state normal
}

###################################################################
#
#   Createfiles pop up a window, and ask you for the name of the 
#   of the file to save the snapshot information.   The default is 
#   highway.hwy 
#
###################################################################


proc CreateFile {} {

    global highwayFile totalCars

    set w .new_file

    if {[winfo exists $w]} {
	catch {wm deiconify $w}
	catch {raise $w}
	return
    }

    toplevel .new_file -height 150 -width 300 -bg ivory1
    catch {raise $w}
    frame .new_file.middle -relief raised -bd 2
    frame .new_file.bottom

    label .new_file.middle.fileName_lab -text "Name: "
    entry .new_file.middle.fileName
    .new_file.middle.fileName insert 0 "highway.hwy"

    button .new_file.bottom.ok -text OK -command {

	set highwayFile [.new_file.middle.fileName get]
	if {[file exists $highwayFile]} {
	    bell 
	    tk_dialog .error Warning "File \"$highwayFile\" already \
	    exists. It will be overwritten next time you save." "" 0 OK 
	}
	.main.bar.file.menu entryconfigure 0 -state disabled 
	.main.bar.file.menu entryconfigure 1 -state disabled 
	.main.info.new configure -state normal
	destroy .new_file
    }

    button .new_file.bottom.cancel -text "Cancel"\
	    -command {destroy .new_file}
    
    place .new_file.middle -relwidth 1 -height 100
    place .new_file.bottom -relwidth 1 -height 50 -y 100
    
    place .new_file.middle.fileName_lab -relx .05 -rely 0.35
    place .new_file.middle.fileName -relwidth .6 -relx .3 -rely 0.35
    
    place .new_file.bottom.ok -relwidth .3 -relx .1 -relheight .6\
	    -rely .15
    place .new_file.bottom.cancel -relwidth .3 -relx .6 -relheight .6\
	    -rely .15
	
}

###################################################################
#
#   Called by SnapMainControl.  Save the information into a file
#
###################################################################

proc SaveCurrentFile {} { 

    global highwayFile carInformationArray carArray roadFeatures 
    global data_version 

    set f [open $highwayFile w]
     
    puts $f [format "# #### This is a Carmma highway scenario\
	    specification file"]
    puts $f "\n"
    set snaps $carInformationArray(-1,snaps)
    puts $f [format "All-Snapshots $snaps"]
    puts $f [format "NumLanes $roadFeatures(num_lanes)"]
    puts $f [format "Data-Version $data_version"]
    puts $f [format "HighwayLength $roadFeatures(highway_length)"]
    puts $f [format "Trajectory $roadFeatures(itraj) $roadFeatures(xcir) $roadFeatures(ycir) $roadFeatures(rwyrad)" ]
    foreach i $snaps {
	set all_tags $carInformationArray($i,tags)
	puts $f [format "Snapshot $i "]
	puts $f [format "SnapTags  \{$all_tags\}"]
	puts $f [format "\n# Individial tag information"]
	foreach j $all_tags {
	    set r_tag rect_$j
	    set rect_coords $carInformationArray($i,$r_tag)
	    puts $f [format "CarPosition $j $rect_coords"]
	    set car_id [string range $j 3 end]
            set carArray($i,$car_id,or)  0.0
	    puts $f [format "CarInformation $j %s" \
		    [list $carArray($i,$car_id,x)\
		    $carArray($i,$car_id,y)\
		    $carArray($i,$car_id,x_speed)\
		    $carArray($i,$car_id,or) ]]
	    puts $f [format "# End of information on tag $j"]
	}
	puts $f [format "# End on information on snapshot $i"]
    }
    close $f
}


###################################################################
#
#   PROCESS_LINE read the file and process line by line, meaning 
#   filling in the data structure from the file.  When called by 
#   OpenFile the type is "Application", when called by 
#   LOAD_ANIMATION_INFORMATION the type is "Anim"  
#
###################################################################

proc processLine {line type} {

    global currentSnapshotIndex roadFeatures got_num_lanes got_highway_length 
    global got_trajectory
    global data_version 
    set l [string length $line]
    if {$l < 1} {
	return
    } 
    set line_title [lindex $line 0]
    if {$line_title == "All-Snapshots"} {
	getSnapshots $line $type
    } elseif {$line_title == "Data-Version"} {
	set data_version [lindex $line 1]
    } elseif {$line_title == "NumLanes"} {
	set roadFeatures(num_lanes) [lindex $line 1]
	set got_num_lanes 1
    } elseif {$line_title == "HighwayLength"} {
	set roadFeatures(highway_length) [lindex $line 1]
	set got_highway_length 1
    } elseif {$line_title == "Trajectory"} {
	set roadFeatures(itraj) [lindex $line 1]
        set roadFeatures(xcir) [lindex $line 2]
        set roadFeatures(ycir) [lindex $line 3]
        set roadFeatures(rwyrad) [lindex $line 4]
	set got_trajectory 1
    } elseif {$line_title == "Snapshot"} {
	set currentSnapshotIndex [lindex $line 1]
    } elseif {$line_title == "SnapTags"} {
	getSnapshotTags $currentSnapshotIndex $line $type
    } elseif {$line_title == "CarPosition"} {
	getCarPosition $currentSnapshotIndex $line $type
    } elseif {$line_title == "CarInformation"} {
	getCarInformation $currentSnapshotIndex $line $type
    }
}

###################################################################
#
#   These functions are called by processLine record information about 
#   the snapshots.  When called by Openfile it will record information 
#   into CarInformationArray instead of Animation Array.  I am not sure 
#   why there is a distinction between the CarInformationArray and 
#   CarArray 
#
###################################################################

proc getSnapshots {line type} {
    
    global animationArray carArray carInformationArray
    
    if {$type == "Anim"} {
	set animationArray(-1,snaps) [lrange $line 1 end]
    } else {
	set carInformationArray(-1,snaps) [lrange $line 1 end]
    }
}

proc getSnapshotTags {snap line type} {

    global animationArray carArray carInformationArray totalCars 
    
    if {$type == "Anim"} {
	set animationArray($snap,tags) [lindex $line 1]
    } else {
	set carInformationArray($snap,tags) [lindex $line 1]
	
	foreach car $carInformationArray($snap,tags) {
	    set car_id [string range $car 3 end]
	    if {$car_id > $totalCars} {
		set totalCars $car_id
	    }
	}
    }
}

proc getCarPosition {snap line type} {

    global animationArray carArray carInformationArray
    
    if {$type == "Anim"} {
	#Do nothing, will use the x and y position from the
	#user provided info
	#set animationArray($snap,tags) [lindex $line 1]
    } else {
	set tag [lindex $line 1]
	set coords [lrange $line 2 end]
	set x_pos1 [lindex $coords 0]
	set x_pos2 [lindex $coords 2]
	set y_pos1 [lindex $coords 1]
	set y_pos2 [lindex $coords 3]
	set rect_tag rect_$tag
	set carInformationArray($snap,$rect_tag) $coords
	set text_tag text_$tag
	set text_x [expr $x_pos1 + 20]
	set text_y [expr $y_pos1 + 15]
	set carInformationArray($snap,$text_tag) [list $text_x $text_y]

	#

    }
}

proc getCarInformation {snap line type} {

    global animationArray carArray carInformationArray
    global carAnimationArray 

    if {$type == "Anim"} {
	set tag [lindex $line 1]
	set car_id [string range $tag 3 end]
	set carAnimationArray($snap,$car_id,x) [lindex $line 2]  
	set carAnimationArray($snap,$car_id,y) [lindex $line 3]  
	set carAnimationArray($snap,$car_id,x_speed) [lindex $line 4] 
	set carAnimationArray($snap,$car_id,or) [lindex $line 5] 
    } else {
	set tag [lindex $line 1]
	set car_id [string range $tag 3 end]
	set carArray($snap,$car_id,x) [lindex $line 2]  
	set carArray($snap,$car_id,y) [lindex $line 3]  
	set carArray($snap,$car_id,x_speed) [lindex $line 4] 
	set carArray($snap,$car_id,or) [lindex $line 5] 
    }
}

#######################################################################
#
#   Called by CreateAnimationCanvas 
#
#######################################################################


proc CreateDataFile {} {

    global dataFile

    set w .new_file
    if {[winfo exists $w]} {
	catch {wm deiconify $w}
	catch {raise $w}
	return
    }

    toplevel .new_file -height 150 -width 300 -bg ivory1
    catch {raise $w}
    frame .new_file.middle -relief raised -bd 2
    frame .new_file.bottom

    label .new_file.middle.fileName_lab -text "Name: "
    entry .new_file.middle.fileName
    .new_file.middle.fileName insert 0 "highway.hwd"

    button .new_file.bottom.ok -text OK -command {

	set dataFileName [.new_file.middle.fileName get]
	WriteScenario $dataFileName
	destroy .new_file

    }

    button .new_file.bottom.cancel -text "Cancel"\
	    -command {destroy .new_file}
    
    place .new_file.middle -relwidth 1 -height 100
    place .new_file.bottom -relwidth 1 -height 50 -y 100
    
    place .new_file.middle.fileName_lab -relx .05 -rely 0.35
    place .new_file.middle.fileName -relwidth .6 -relx .3 -rely 0.35
    
    place .new_file.bottom.ok -relwidth .3 -relx .1 -relheight .6\
	    -rely .15
    place .new_file.bottom.cancel -relwidth .3 -relx .6 -relheight .6\
	    -rely .15
	
}

