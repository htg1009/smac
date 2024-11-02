# -*- Mode: TCL -*-

# snap.tcl

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

# <snap.tcl>  

#############################################################################
#
#   Global Definition that is used in Snap Shot 
#
#############################################################################

proc InitializeSnapVars {} {
    global totalCars numberOfSnapShots itemselect carInformationArray carArray 
    global highwayFile editing_over ZoomIndex temp_carArray data_version
    
    set totalCars 0
    set numberOfSnapShots 0
    set itemselect(totalEntries) 0
    set editing_over 0
    set ZoomIndex 1
    set data_version 1
    
    set carInformationArray(0,tobedestroyed) 0
    set carArray(0,tobedestroyed) 0
    set highwayFile ""
    set temp_carArray(empty) {}
    
    unset carInformationArray
    unset carArray
}


#############################################################################
#
#   This procedure pops up a window and ask you for the number of the lanes in 
#   the freeway.  when okay button is pressed you execute next_command 
#
#############################################################################

proc InquireAboutRoadFeature {next_command} {
    
    global roadFeatures 
    
    set w .inquiry
    
    if {[winfo exists $w]} {
	catch {wm deiconify $w}
	catch {raise $w}
	return
    }
    
    toplevel $w -height 150 -width 250
    catch {raise $w}
    
    frame $w.bottom
    frame $w.main -relief raised -bd 2
    
    place  $w.main -height 100 -relwidth 1
    place  $w.bottom -height 50 -relwidth 1 -rely .66
    
    button $w.bottom.ok -text "OK" -command "RoadFeatureOkayNowCreateFile $w $next_command"
    button $w.bottom.cancel -text "Cancel" -command "destroy $w"
    
    label $w.main.width_lab -text "Number of Lane: "
    entry $w.main.width
    $w.main.width insert 0 5
    place $w.main.width_lab -x 10 -rely .1
    place $w.main.width -relx 0.6 -rely .1 -relwidth .25

    label $w.main.length_lab -text "Length of Lane: "
    entry $w.main.length
    $w.main.length insert 0 2000 
    place $w.main.length_lab -x 10 -rely .6
    place $w.main.length -relx 0.6 -rely .6 -relwidth .25
    
    place $w.bottom.ok -relheight .6 -relwidth .3 -relx .1\
	    -rely .2
    place $w.bottom.cancel -relheight .6 -relwidth .3 -relx .6\
	    -rely .2

    

}

#############################################################################
#
#   This is a helper function for InquireAboutRoadFeature.  
#   When okay button is pressed, you are to examine the input and verify that 
#   it is valid 
#
#############################################################################

proc RoadFeatureOkayNowCreateFile {w next_command} { 
    global roadFeatures 

    set roadFeatures(num_lanes) [$w.main.width get] 
    set roadFeatures(highway_length) [$w.main.length get]

    if {($roadFeatures(num_lanes) == "") || ($roadFeatures(highway_length)) == ""} {
	bell
	tk_dialog .error Error \
		"You need to enter the roadFeatures" "" 0 OK
	return 
    }

    set er_lanes [catch {set a [expr $roadFeatures(num_lanes) + 0]}]
    set er_length [catch {set a [expr $roadFeatures(highway_length) + 0]}]
    if {($er_lanes == 1) || ($er_length == 1)} {
	bell
	tk_dialog .error Error \
		"You need to enter numbers" "" 0 OK
	return 
    }

    set er_lanes [string first "." $roadFeatures(num_lanes)]
    set er_length [string first "." $roadFeatures(highway_length)]
    if {($er_lanes > -1) || ($er_length > -1)} {
	bell
	tk_dialog .error Error \
		"You need to enter integers " "" 0 OK
	return
    }

    eval $next_command 
    destroy $w
}

#############################################################################
#
#   Main Window for the Snap Main control 
#
#############################################################################

proc SnapMainControl {} {
    global carsInCanvas roadFeatures 
    set w .main
    
    InitializeSnapVars 
    
    if {[winfo exists $w]} {
	catch {wm deiconify $w}
	catch {raise $w}
	return
    }

    toplevel $w -height 370 -width 250
    wm title $w "Snapshot Manager"
    catch {raise $w}

    frame $w.bar -relief raised -bd 2
    frame $w.info

    place $w.bar -height 40 -relwidth 1
    place $w.info -height 270 -y 40 -width 250 -height 330
    
    menubutton $w.bar.file -text "File" -menu $w.bar.file.menu
    
    set m [menu $w.bar.file.menu -tearoff 0]

    $m add command -label "New" -command "InitializeSnapVars ;	.main.info.list delete 0 end ; InquireAboutRoadFeature CreateFile"
    
    $m add command -label "Open" -command {
	InitializeSnapVars 
	.main.info.list delete 0 end 
	OpenFile
    }
    $m add command -label "Save" -command "SaveCurrentFile"
    $m add command -label "Close" -command "destroy $w"
    $m add separator
    $m add command -label "Exit" -command "destroy $w"
    
    place $w.bar.file -width 70 
    
    set lb [listbox $w.info.list \
	    -yscrollcommand [list $w.info.scroll set]]
    scrollbar $w.info.scroll -command [list $lb yview]

    bind $lb <Double-Button-1> {itemselectClick %W %y}

    label $w.info.snap_lab -text "File: "
    label $w.info.snap -textvariable highwayFile

    button $w.info.new -text "New Snapshot" -relief raised -bd 2 \
	    -command CreateNewSnapShot -state disabled
 
    place $w.info.snap_lab -relx 0.05 -y 20
    place $w.info.snap -relx .3 -y 20 -relwidth .6
    place $w.info.new -relx .1 -y 55 -relwidth .8
    place $w.info.list -width 175 -x 25 -height 200 -y 100
    place $w.info.scroll -width 25 -x 200 -height 200 -y 100 
}

##########################################################################
#
#   Called by SnapMainControl.  Creates New SnapShot 
#
##########################################################################

proc CreateNewSnapShot {} {
    
    global itemselect smallFont 

    set id $itemselect(totalEntries)
    
    set w .new_snap
    
    if {[winfo exists $w]} {
	catch {wm deiconify $w}
	catch {raise $w}
	return
    }
    
    toplevel .new_snap -height 200 -width 250
    catch {raise $w}

    wm title $w TimeInput 

    frame .new_snap.bottom
    frame .new_snap.main -relief raised -bd 2
    
    place  .new_snap.main -height 150 -relwidth 1
    place  .new_snap.bottom -height 50 -relwidth 1 -y 150
    
    button .new_snap.bottom.ok -text "OK" -command\
	    "ProcessNewSnapInfo $id .new_snap"

    button .new_snap.bottom.cancel -text "Cancel" -command\
	    "destroy .new_snap"

    tkwait visibility .new_snap
    grab set .new_snap
    
    label .new_snap.main.id_lab -text "Snapshot ID: "
    label .new_snap.main.time_lab -text "Time: "
    label .new_snap.main.time_lab2 -text "s" -font $smallFont
    label .new_snap.main.id -text "$id" -bd 2
    entry .new_snap.main.time

    place .new_snap.main.id_lab -x 10 -rely .3
    place .new_snap.main.time_lab -x 10 -rely .7 

    place .new_snap.main.id -relx 0.6 -rely .3 -relwidth .2
    place .new_snap.main.time -relx 0.6 -rely .7 -relwidth .25
    place .new_snap.main.time_lab2 -relx 0.86 -rely .74


    place .new_snap.bottom.ok -relheight .6 -relwidth .3 -relx .1\
	    -rely .2
    place .new_snap.bottom.cancel -relheight .6 -relwidth .3 -relx .6\
	    -rely .2 

}

##########################################################################
#
#   Creates Snaps shots, here default of last is -1 which means that this 
#   is the first snap shots. 
#
##########################################################################

proc CreateSnapshot {time last_index {last -1}} {

    global carsInCanvas roadFeatures ZoomIndex
    
    set w .canvas

    # we only want one canvas at a time 

    if {[winfo exists $w]} {
	destroy $w
    }

    toplevel $w -height 400 -width 800
    catch {raise $w}
    wm title $w "Road Snapshot at time $time"
    frame $w.bar -relief raised -bd 2
    frame $w.main
    
    place $w.bar -height 40 -relwidth 1
    place $w.main -height 270 -y 40 -width 500

    bind $w <Configure> "ConfigureCanvas $w"
    menubutton $w.bar.control -text "Snapshot" \
	    -menu $w.bar.control.menu

    set m1 [menu $w.bar.control.menu -tearoff 0]

    $m1 add command -label "Commit Snapshot" \
	    -command  "SaveSnapShot $time $last_index $w"
    $m1 add command -label "Close" -command  "DiscardSnapshot $w"

    bind $w <Destroy> ".main.info.new configure -state normal"
    place $w.bar.control -width 100 -x 0
 
    set roadSize $roadFeatures(length)
    canvas $w.main.c -yscrollcommand "$w.main.yscroll set"\
	    -xscrollcommand "$w.main.xscroll set"\
	    -scrollregion "-15 0 $roadFeatures(length) 250" -bg navajowhite
    scrollbar $w.main.xscroll -orient horizontal \
	    -command "$w.main.c xview"
    scrollbar $w.main.yscroll -command "$w.main.c yview"

    place $w.main.c -height 170 -width 475
    place $w.main.xscroll -height 25 -width 475 -y 145 -x 0
    place $w.main.yscroll -height 170 -x 450 -y 0 -width 25
    

    #Create the bindings for the canvas
    setBindings $w $time

    # This is a fix so that we can share createRoadFeature with Animation 
    # part of this project 
    set tempIndex $ZoomIndex 
    set ZoomIndex 1
    createRoadFeatures $w 
    set ZoomIndex $tempIndex 
    
    if {$last != -1} {
	tkwait visibility $w
	loadLastCanvasSettings $w $last $time
    }
}

#########################################################################
#
#   Destroy Snapshot
#
#########################################################################

proc DiscardSnapshot {w} {

    .main.info.new configure -state normal
    destroy $w

}

#########################################################################
#
#   This function lets you CreateSnapShot by clicking on a item in the 
#   list box 
#
########################################################################

proc itemselectClick { lb y} {
    # Take the item the user clicked on
    global itemselect ListComponents messageQueue editing_over 
    global carInformationArray

    set itemselect(type) [$lb get [$lb nearest $y]]
    set itemselect(location) [$lb nearest $y]
    set itemselect(current_snap) [lindex [$lb get [$lb nearest $y]] 1]

    set sorted_snap $carInformationArray(-1,snaps)
    set editing_over 1
    set sorted_snap [lsort -real $sorted_snap]
    set index $itemselect(location)
    set time [lindex $sorted_snap $index]

    CreateSnapshot $time $index $time  

}

##########################################################################
#
#   Collect all the cars in the Canvas and record information about them
#   after Commit button is pressed 
#
##########################################################################

proc SaveSnapShot {time last_index w} {
    
    global itemselect carInformationArray carArray editing_over temp_carArray 
    
#    set c .canvas_$time.main.c
    set c .canvas.main.c
    set data [$c find withtag Car]
    
    if {[llength $data] > 0} {
	foreach i $data {
	    set tags [$c gettags $i]
	    foreach j $tags {
		if {$j != "Car" && $j != "current"} {
		    set tag $j
		}
	    }
	    set coords [$c coords $i]
	    
	    set car_id [string range $tag 3 end]
	    set carArray($time,$car_id,x_speed) \
		    $temp_carArray($time,$car_id,x_speed)
	    set carArray($time,$car_id,x) $temp_carArray($time,$car_id,x)
	    set carArray($time,$car_id,y) $temp_carArray($time,$car_id,y)
            set temp_carArray($time,$car_id,or) 0
	    set carArray($time,$car_id,or) $temp_carArray($time,$car_id,or)

	    set type [$c type $i]
	    if {$type == "text"} {

		if {[lsearch $carInformationArray($time,tags) $tag] == -1} {
		    lappend carInformationArray($time,tags) $tag
		}
		set t_tag text_$tag
		set carInformationArray($time,$t_tag) $coords
	    } else {
		set r_tag rect_$tag
		set carInformationArray($time,$r_tag) $coords
	    }   
	}
    }
    
#    .canvas_$time.bar.control.menu entryconfigure 0 -state disabled
    .canvas.bar.control.menu entryconfigure 0 -state disabled
    if {$editing_over != 1} {
	lappend carInformationArray(-1,snaps) $time
    }    

    # Modification to Include Edit 
    # Now the below will look very complicated but the main concept is to 
    # carry the newly created vehicle to the future, since you cannot make 
    # car disappear in our simulation 

    set carInformationArray(-1,snaps) [lsort -real $carInformationArray(-1,snaps)]

    foreach future_time $carInformationArray(-1,snaps) {
	if {$future_time > $time} {
	    if {[llength $data] > 0} {
		foreach i $data {
		    # so i is an object 
		    set tags [$c gettags $i]

		    # tags are tags associated with an object 
		    foreach j $tags {
			if {$j != "Car" && $j != "current"} {
			    set tag $j
			}
		    }

		    # now "tag" is the tag that says "Car#" 
		    # if at the future time, they have the object then 
		    # shouldn't copy

		    if {[lsearch $carInformationArray($future_time,tags) $tag] == -1} {
			set coords [$c coords $i]
		    
			set car_id [string range $tag 3 end]
			set carArray($future_time,$car_id,x_speed) \
				$carArray($time,$car_id,x_speed)
			set carArray($future_time,$car_id,x) $carArray($time,$car_id,x)
			set carArray($future_time,$car_id,y) $carArray($time,$car_id,y)
                        set or 0.0
			set carArray($future_time,$car_id,or) $carArray($time,$car_id,or)

			set type [$c type $i]
			if {$type == "text"} {
			    lappend carInformationArray($future_time,tags) $tag
			    set t_tag text_$tag
			    set carInformationArray($future_time,$t_tag) $coords
			} else {
			    set r_tag rect_$tag
			    set carInformationArray($future_time,$r_tag) $coords
			}   
		    }
		}
	    }
	    
	}   
    }

    set entry [list "Snapshot" $time]

#    puts stdout $last_index 
    if {$editing_over != 1} {
	.main.info.list insert [expr $last_index + 1] $entry
	.main.info.new configure -state normal
	incr itemselect(totalEntries)
    }

    destroy .canvas
#    destroy .canvas_$time
}


#########################################################################
#
#   load all the cars from last time setting, and update data structure
#   And also draw it in canvas.    
#
#########################################################################

proc loadLastCanvasSettings {w last curr_time} {

    global itemselect carInformationArray carArray temp_carArray data_version 
    global carFeatures 

    set all_tags $carInformationArray($last,tags)

    foreach i $all_tags {
	set r_tag rect_$i
	set t_tag text_$i

	set car_id [string range $i 3 end]

	set carArray($curr_time,$car_id,x_speed) $carArray($last,$car_id,x_speed)
	set carArray($curr_time,$car_id,x) $carArray($last,$car_id,x)
	set carArray($curr_time,$car_id,y) $carArray($last,$car_id,y)
	set temp_carArray($curr_time,$car_id,x_speed) $carArray($last,$car_id,x_speed)
	set temp_carArray($curr_time,$car_id,x) $carArray($last,$car_id,x)
	set temp_carArray($curr_time,$car_id,y) $carArray($last,$car_id,y)

	if {$data_version == -1} {
	    set x $carArray($curr_time,$car_id,x) 
	    set y $carArray($curr_time,$car_id,y) 
	    set car_length $carFeatures(car_length)
	    set car_width $carFeatures(car_width) 
	    
	    set carInformationArray($last,$r_tag) [list \
		    [expr $x * 12.5 - ($car_length / 2)] \
		    [expr $y * 12.5 - ($car_width / 2) + 20] \
		    [expr $x * 12.5 + ($car_length / 2)] \
		    [expr $y * 12.5 + ($car_width / 2) + 20]]

	    set carInformationArray($last,$t_tag) [list \
		    [expr $x * 12.5] \
		    [expr $y * 12.5 + 20]]
	}

	set rect_coords $carInformationArray($last,$r_tag)
	set text_coords $carInformationArray($last,$t_tag)
	set t1 [lindex $text_coords 0]
	set t2 [lindex $text_coords 1]


	set car_color [GetCarColor $car_id]

	$w.main.c create rectangle [lindex $rect_coords 0]\
		[lindex	$rect_coords 1] [lindex $rect_coords 2]\
		[lindex $rect_coords 3] -fill $car_color -tag $i
	$w.main.c create text [lindex $text_coords 0]\
		[lindex $text_coords 1] -tags $i -text $i

	$w.main.c addtag Car withtag $i


    }
}


#############################################################################
#
#   I am not really sure if this is good idea, the cars kind of looked ugly 
#   with colors 
#
#############################################################################

proc GetCarColor {car_id} {

    set id $car_id 

    set id [expr $id % 5]
    
    if {$id == 1} {
	set car_color red 
	return $car_color  
    } elseif {$id == 2} {
	set car_color green 
	return $car_color  
    } elseif {$id == 3} {
	set car_color yellow
	return $car_color  
    } elseif {$id == 4} {
	set car_color white 
	return $car_color  
    } elseif {$id == 0} {
	set car_color blue
	return $car_color  
    } 
}

##########################################################################
#
#   Invoked with <Configure> function of the window manager
#
##########################################################################

proc ConfigureCanvas {w} {

    set height [winfo height $w]
    set width [winfo width $w]
    set canv_width [expr $width]
    set canv_height [expr $height -40]

    place $w.bar -height 40 -relwidth 1
    place $w.main -height $canv_height -y 40 -width $canv_width

    place $w.main.c -height $canv_height -width [expr $canv_width - 25]
    place $w.main.xscroll -height 25 -width [expr $canv_width -25]\
	    -y [expr $canv_height -25] -x 0
    place $w.main.yscroll -height $canv_height \
	    -x [expr $canv_width -25] -y 0 -width 25    
}

##########################################################################
#
#   Definition for Mouse Binding
#
##########################################################################


proc setBindings {w time} {
    
    global newWindow

    set newWindow $w

    bind $w.main.c <1> "BindCreateCar %W %x %y $time"

    $w.main.c bind Car <3> "BindDeleteCar %W %x %y $time"

    $w.main.c bind Car <1> "BindStartMoveCar %W %x %y $time"

    $w.main.c bind Car <B1-Motion> "BindMoveCar %W %x %y $time"

    $w.main.c bind Car <Double-1> "BindShowCar %W %x %y $time"

}


##########################################################################
#
#   Double Click on Button 1 will Invoke this function, finds the tag of 
#   the car in question and call SHOW_CAR_INFORMATION to display the 
#   information about the car 
#
##########################################################################


proc BindShowCar {w x y time} {

    set tag 0
    set tags [$w gettags current]
    foreach i $tags {
	if {$i != "Car" && $i != "current"} {
	    set tag $i
	}
    }
    ShowCarInformation $tag $time
}


##########################################################################
#
#   Click on button 1 will Invoke this funciton.  Basically this function 
#   is needed to set up variable such as discrete_starty for BindMoveCar. 
#   discrete_starty indicates the position of the vehicle    
#
##########################################################################


proc BindStartMoveCar {w x y time} {

    global temp_carArray roadFeatures 

    set tag 0
    set tags [$w gettags current]
    foreach i $tags {
	if {$i != "Car" && $i != "current"} {
	    set tag $i
	}
    }
    
    set half_width [expr $roadFeatures(width) / 2]
    set id [string range $tag 3 end]
    set y [expr $temp_carArray($time,$id,y) / 2 * $half_width + 20]
    
    set real_x [$w canvasx $x]
    puts stdout $real_x 
    puts stdout [expr $temp_carArray($time,$id,x) * 12.5]
    
    $w move $tag [expr $real_x - $temp_carArray($time,$id,x) * 12.5] 0 
    
    set temp_carArray($time,$id,x) [expr $real_x / 12.5]
    startdrag $x $y

}


##########################################################################
#
#   Move the car with the drag of the mouse, also update carArray 
#
##########################################################################


proc BindMoveCar {w x y time} {

    global temp_carArray roadFeatures discrete_starty

    set tag 0
    set tags [$w gettags current]
    foreach i $tags {
	if {$i != "Car" && $i != "current"} {
	    set tag $i
	}
    }
    set id [string range $tag 3 end]

    movedrag $x $y $tag $w
    set real_x [$w canvasx $x]
    set temp_carArray($time,$id,x) [expr $real_x / 12.5]

    set half_width [expr $roadFeatures(width) / 2]
    set temp_carArray($time,$id,y) [expr round(($discrete_starty - 20) \
	    / $half_width)*2] 
}


##########################################################################
#
#   Bind the mouse to be able to delete the car
#
##########################################################################


proc BindDeleteCar {w x y time} {

    global totalCars newWindow 

    set tag 0
    set tags [$w gettags current]
    foreach i $tags {
	if {$i != "Car" && $i != "current"} {
	    set tag $i
	}
    }
    $w delete $tag
}


##########################################################################
#
#   With the click <1> button on empty space, we are creating and 
#   placing the vehicle on the canvas.  The vehicle can take any 
#   x-coordinates, but y-coordinates should be limited to either on the 
#   middle of the lane or between lanes. 
#
##########################################################################


proc BindCreateCar {w x y time} {

    global totalCars newWindow carsInCanvas roadFeatures carInformationArray
    global carFeatures 

    set a [$w gettags current]
    foreach i $a {
	if {$i == "Car"} {
	    return
	}
    }
    set canvas_x_pos [$w canvasx $x]
    set real_x $canvas_x_pos
    set numlanes $roadFeatures(num_lanes)
    set half_width [expr $roadFeatures(width) / 2]
    
    set car_length $carFeatures(car_length)
    set car_width $carFeatures(car_width)

    # this is included because I want the arithmatic calculation 
    # to be a little more forgiving. 
    set y [expr $y + 0.1]

    if {$y < (12.5 + 20) || $y > ($numlanes * 50 + 20 - 12.5)} {
	#it is out of the bound
	return 
    } else {
	incr totalCars
	set car_color [GetCarColor $totalCars]
	set tag2 Car$totalCars

	$w create rectangle [expr $real_x - ($car_length / 2)]\
		[expr round(($y - 20) / $half_width)*25 - ($car_width / 2) + 20] \
		[expr $real_x + ($car_length / 2)] \
		[expr round(($y - 20) / $half_width)*25 + ($car_width / 2) + 20] \
		-fill $car_color -tags $tag2
	$w create text $real_x \
		[expr round(($y - 20) / $half_width)*25 + 20] \
		-tags $tag2 -text $tag2
	$w addtag Car withtag $tag2
	SetVehicleParameters $real_x \
		[expr round(($y - 20) / $half_width)*2] \
		$totalCars $time
    }	    
}


##########################################################################
#
#   The function initialize variable (mainly starty, startx, discrete_starty)
#   that is need to drag the mouse.  
#
##########################################################################


proc startdrag {x y} {
    global startx starty discrete_starty 
    global roadFeatures
    set startx $x
    set starty $y

    set numlanes $roadFeatures(num_lanes)
    set width $roadFeatures(width)
    set half_width [expr $roadFeatures(width) / 2]
    set upper_limit [expr $numlanes * $width - $half_width + 20]

    set discrete_starty [expr (round(($starty - 20) / \
	    $half_width) * $half_width) + 20]

    if {$discrete_starty  > $upper_limit} {
	set discrete_starty $upper_limit 
    } elseif {$discrete_starty < ($half_width + 20)} {
	set discrete_starty [expr $half_width + 20]
    }
}


##########################################################################
#
#   This function actually calculates and update the position of the vehicle 
#   as the mouse move across the Canvas.  One thing to keep in mind of is that 
#   we have to limit the movement of the y-coordinates to either middle of the 
#   lane and between the lanes.  
#
##########################################################################


proc movedrag {x y tag w} {
    global startx starty discrete_starty
    global carsInCanvas
    global roadFeatures

    set dx [expr $x - $startx]
    
    set numlanes $roadFeatures(num_lanes)
    set width $roadFeatures(width)
    set half_width [expr $roadFeatures(width) / 2]
    set upper_limit [expr $numlanes * $width - $half_width + 20]

    if {(($y - $discrete_starty) < $half_width) && \
	    (($y - $discrete_starty) > - $half_width)} {
	set discrete_y $discrete_starty
    } else {
	set discrete_y [expr (round(($y - 20) / \
		$half_width) * $half_width) + 20]
    }

    if {$discrete_y  > $upper_limit} {
	set discrete_y $upper_limit 
    } elseif {$discrete_y < ($half_width + 20)} {
	set discrete_y [expr $half_width + 20]
    }

    set dy [expr $discrete_y - $discrete_starty]

    $w move $tag $dx $dy
    set startx $x
    if {$dy != 0} {
	set discrete_starty $discrete_y
    }
}


##########################################################################
#
#   This function pops up a window that sets the vehicle parameters.  
#   Many of them are preset and read from the position of the mouse, but 
#   the speed has to be specified, as you will see in SAVE_INFO function. 
#
##########################################################################


proc SetVehicleParameters {x y id time} {

    global smallFont

    set w .params

    toplevel $w -height 250 -width 300

    frame $w.bottom
    frame $w.main -relief raised -bd 2

    place  $w.main -height 200 -relwidth 1
    place  $w.bottom -height 50 -relwidth 1 -y 200

    button $w.bottom.ok -text "OK" -command\
	    "SaveInfo $id $w $time; "

    tkwait visibility $w
    grab set $w
    
    label $w.main.id_lab -text "Vehicle ID: "
    label $w.main.x_position -text "X Position: "
    label $w.main.y_position -text "Y Position: "
    label $w.main.x_speed_lab -text "Longitudinal Speed: "
    
    label $w.main.x_pos_lab2 -text "m" -font $smallFont
    label $w.main.y_pos_lab2 -text "m" -font $smallFont
    label $w.main.x_speed_lab2 -text "m/s" -font $smallFont
    
    label $w.main.id -text "$id"
    entry $w.main.x_pos -relief sunken
    $w.main.x_pos insert 0 [expr $x / 12.5]
    label $w.main.y_pos -text "$y"
    
    entry $w.main.x_speed
    
    place $w.main.id_lab -x 0.05 -y 30
    place $w.main.x_position -x 0.05 -y 90
    place $w.main.y_position -x 0.05 -y 60
    place $w.main.x_speed_lab -x 0.05 -y 120
    
    place $w.main.id -relx 0.65 -y 30 -relwidth .25
    place $w.main.x_pos -relx 0.65 -y 90 -relwidth .25
    place $w.main.y_pos -relx 0.65 -y 60 -relwidth .25
    place $w.main.x_speed -relx 0.65 -y 120 -relwidth .25
    
    place $w.main.x_pos_lab2 -relx 0.9 -y 93
    place $w.main.x_speed_lab2 -relx 0.9 -y 123
    place $w.bottom.ok -relheight .6 -relwidth .4 -relx .3 -rely .2
    
    wm protocol $w WM_DELETE_WINDOW {return}
}


##########################################################################
#
#   When OK button is pressed in SET_VEHICLE_PARAMETERS function, we will 
#   try to save the information that is supplied.  However, when the the 
#   variable speed is not supplied we will give an error (I am not sure why 
#   this is yet) 
#
##########################################################################


proc CheckVehicleParameters {w} {
    if  {[$w.main.x_speed get] == ""} {
	bell
	tk_dialog .error Error "You must enter an x speed\
		for the vehicle" "" 0 OK 
	return 0
    }
    
    if  {[$w.main.x_pos get] == ""} {
	bell
	tk_dialog .error Error "You must enter an x position\
		for the vehicle" "" 0 OK 
	return 0
    }
    
    set x_pos_test [$w.main.x_pos get]
    set x_speed_test [$w.main.x_speed get]

    set er [catch {set a [expr $x_pos_test + 0]}]
    if {$er == 1} {
	bell
	tk_dialog .error Error \
		"You need to enter number for x position" "" 0 OK
	return 0
    }
    
    set er [catch {set a [expr $x_speed_test + 0]}]
    if {$er == 1} {
	bell
	tk_dialog .error Error \
		"You need to enter number for speed " "" 0 OK
	return 0
    }
}    


proc SaveInfo {id w time} {

    global temp_carArray totalCars carFeatures roadFeatures 

    # check for the validity of the parameters 
    if {[CheckVehicleParameters $w]== 0} {
	return
    }

    set x_pos [expr [$w.main.x_pos get] * 12.5]
    set y_pos [lindex [$w.main.y_pos configure -text] 4]
    set temp_carArray($time,$id,x) [$w.main.x_pos get]
    set temp_carArray($time,$id,y) [lindex [$w.main.y_pos configure -text] 4]
    set temp_carArray($time,$id,x_speed) [$w.main.x_speed get]
    
    #    set c .canvas_$time.main.c
    set c .canvas.main.c
    
    
    set carTag Car$id
    $c delete $carTag

    set car_length $carFeatures(car_length) 
    set car_width $carFeatures(car_width)
    set half_width [expr $roadFeatures(width) / 2]
    
    set car_color [GetCarColor $id]
    
    $c create rectangle [expr $x_pos - ($car_length / 2)]\
	    [expr $y_pos * 12.5 - ($car_width / 2) + 20]\
	    [expr $x_pos + ($car_length / 2)] \
	    [expr $y_pos * 12.5 + ($car_width / 2) + 20] \
	    -fill $car_color -tags $carTag
    $c create text $x_pos \
	    [expr $y_pos * 12.5 + 20] -tags $carTag -text $carTag
    $c addtag Car withtag $carTag

    destroy $w
    grab release $w
}


##########################################################################
#
#   When the you double click on the vehicle this window pops up and you 
#   can edit the parameters that is set on the car.   You will see a lot of 
#   parallellism with SetVehicleParameter (maybe this can be combined with 
#   that very function later)
#
##########################################################################

proc ShowCarInformation {tag time} {

    global temp_carArray

    set id [string range $tag 3 end]

    toplevel .show -height 250 -width 300

    frame .show.bottom
    frame .show.main -relief raised -bd 2

    place  .show.main -height 200 -relwidth 1
    place  .show.bottom -height 50 -relwidth 1 -y 200

    button .show.bottom.ok -text "OK" -command\
	    "SaveInfo $id .show $time"

    tkwait visibility .show
    grab set .show
    
    label .show.main.id_lab -text "Vehicle ID: "
    label .show.main.x_position -text "X Position: "
    label .show.main.y_position -text "Y Position: "
    label .show.main.x_speed_lab -text "Longitudinal Speed: "

    label .show.main.id -relief raised -text $id
    entry .show.main.x_pos
    .show.main.x_pos insert 0 $temp_carArray($time,$id,x)
    label .show.main.y_pos -relief raised -text $temp_carArray($time,$id,y)

    entry .show.main.x_speed

    .show.main.x_speed insert 0 $temp_carArray($time,$id,x_speed)
    
    place .show.main.id_lab -x 0.05 -y 30
    place .show.main.y_position -x 0.05 -y 60
    place .show.main.x_position -x 0.05 -y 90
    place .show.main.x_speed_lab -x 0.05 -y 120

    place .show.main.id -relx 0.65 -y 30 -relwidth .25
    place .show.main.y_pos -relx 0.65 -y 60 -relwidth .25
    place .show.main.x_pos -relx 0.65 -y 90 -relwidth .25
    place .show.main.x_speed -relx 0.65 -y 120 -relwidth .25
    place .show.bottom.ok -relheight .6 -relwidth .4 -relx .3 -rely .2


}


##########################################################################
#
#   I am not sure what these two functions supposed to do 
#
##########################################################################

proc SetSnapTime {w} {
}


proc InheritOtherCanvasState {} {
}

##########################################################################
#
#   From CreateNewSpap Dialogue you have to process the Information that is 
#   supplied and determine if you have all the information that you need. 
#   Also this function is guarding against entering a time that is smaller 
#   then the time simulated so far, this will be fixed later. 
#
##########################################################################

proc ProcessNewSnapInfo {id w} {

    global itemselect carInformationArray editing_over 
    
    set time [$w.main.time get]
    if {$time == ""} {
	bell 
	tk_dialog .error Error \
		"You need to enter a time for the snapshot" "" 0 OK
	return
    }

    set er [catch {set a [expr $time + 0]}]
    if {$er == 1} {
	bell
	tk_dialog .error Error \
		"You need to enter a number for the snapshot time." "" 0 OK
	return
    }


    # Modification for Edit 
    
    set last_index [.main.info.list index end]
    if {$last_index > 0} {
	# this means that there are already some snap shots 
	set sorted_snap $carInformationArray(-1,snaps)
	
	if {[lindex $sorted_snap 0] <= $time} {
	    if {[lsearch $sorted_snap $time] != -1} {
		# this means that we are editing existing snapshot 
		set editing_over 1
		set sorted_snap [lsort -real $sorted_snap]
		set last_index [lsearch $sorted_snap $time]
		set last_time [lindex $sorted_snap $last_index]
	    } else {
		set editing_over 0
		
		#initializing some variables 
		set carInformationArray($time,tags) {}
		
		lappend sorted_snap $time
		set sorted_snap [lsort -real $sorted_snap]
		set last_index [expr [lsearch $sorted_snap $time] -1]
		set last_time [lindex $sorted_snap $last_index]
	    }
	    CreateSnapshot $time $last_index $last_time  
	} else {
	    set editing_over 0
	    #initializing some variables 
	    set carInformationArray($time,tags) {}
	    CreateSnapshot $time -1
	}
    } else {
	set editing_over 0
	#initializing some variables 
	set carInformationArray($time,tags) {}
	CreateSnapshot $time $last_index 
    }
    
    .main.info.new configure -state disabled
    destroy .new_snap
}
