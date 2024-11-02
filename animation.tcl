# -*- Mode: TCL -*-

# animation.tcl

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

# <animation.tcl>


#############################################################################
#
#   Initialize Global Definitions that is Used in Animation 
#
#############################################################################

proc InitializeAnimVars {} {
    global animationArray carAnimationArray refreshRate

    set animationArray(empty) {}
    set carAnimationArray(empty) {}
    set refreshRate 100

}

#############################################################################
#
#   This is the main Calling funciton for Animation Part of this program 
#
#############################################################################

proc CreateAnimation {file} {
    
    InitializeAnimVars 
    LoadAnimationInformation $file
    CreateAnimationCanvas
    
    
}

#############################################################################
#
#    Load information about animation line by line and call PROCESSLINE 
#
#############################################################################

proc LoadAnimationInformation {fileName} {
    
    set f [open $fileName r]
    
    while {[gets $f line] >= 0} {
	processLine $line Anim
    }
    close $f
}

#############################################################################
#
#    Create the background where the animation can occur 
#
#############################################################################

proc CreateAnimationCanvas {} {

    global ZoomIndex roadFeatures

    set w .animation
    set ZoomIndex 1

    if {[winfo exists .animation]} {
	catch {wm deiconify .animation}
	catch {raise .animation}
	return
    }
    toplevel $w -height 500 -width 600

    wm title $w "Animation"
    frame $w.bar -relief raised -bd 2
    frame $w.main
    
    place $w.bar -height 40 -relwidth 1
    place $w.main -height 270 -y 40 -width 500

    bind $w <Configure> "ConfigureCanvas $w"
    menubutton $w.bar.control -text "Control" \
	    -menu $w.bar.control.menu

     menubutton $w.bar.zoom -text "Zoom" \
	    -menu $w.bar.zoom.menu

    set m1 [menu $w.bar.control.menu -tearoff 0]
    set m2 [menu $w.bar.zoom.menu -tearoff 0]

    $m1 add command -label "Play" -command "PlayScenario $w"
    $m1 add command -label "Record" -command "CreateDataFile"
    $m1 add separator
    $m1 add command -label "Close" -command "destroy $w"

    $m2 add command -label "Zoom In" -command "ZoomIn $w"
    $m2 add command -label "Zoom Out" -command "ZoomOut $w"


    place $w.bar.control -width 100 -x 0
    place $w.bar.zoom -width 100 -x 100


    canvas $w.main.c -yscrollcommand "$w.main.yscroll set"\
	    -xscrollcommand "$w.main.xscroll set"\
	    -scrollregion "-15 0 $roadFeatures(length) 250" -bg navajowhite
    scrollbar $w.main.xscroll -orient horizontal \
	    -command "$w.main.c xview"
    scrollbar $w.main.yscroll -command "$w.main.c yview"

    $w.main.c xview moveto 0
    
    place $w.main.c -height 170 -width 475
    place $w.main.xscroll -height 25 -width 475 -y 145 -x 0
    place $w.main.yscroll -height 170 -x 450 -y 0 -width 25
    
        #Create the bindings for the canvas

    createRoadFeatures $w 
    
}

#############################################################################
#
#    Definition for Zooming. 
#
#############################################################################

proc ZoomIn {w} {

    global ZoomIndex
    $w.main.c scale all 0 0 2 2

    set ZoomIndex [expr $ZoomIndex * 2]
}

proc ZoomOut {w} {

    global ZoomIndex
    $w.main.c scale all 0 0 .5 .5

    set ZoomIndex [expr $ZoomIndex * .5]
}

#############################################################################
#
#   This function is called by CREATE_ANIMATION_CANVAS and also CreateNewSnapShot.
#   This draws necessary things inside the canvas that is created by the caller 
#   function 
#
#############################################################################

proc createRoadFeatures {w} {
    
    global ZoomIndex roadFeatures
    
    set counter 0
    
    set numlanes $roadFeatures(num_lanes)
    set roadFeatures(length) [ expr int($roadFeatures(highway_length)*12.5)]
    set length $roadFeatures(length)
    set width $roadFeatures(width)
    
    for {set i 0} {$i < $numlanes} {incr i} {
	
	# road it self 
	$w.main.c create rectangle \
		0 [expr 20 + ($i * $width)] [expr $length * $ZoomIndex] \
		[expr ($i + 1) * $width * $ZoomIndex + 20] -fill grey 
	
	# this is divider for the road 
	set counter 0
	while {$counter < $length} {
	    $w.main.c create line $counter [expr 45 + ($width * $i)] \
		    [expr $counter + 15] [expr 45 + ($width * $i)] 
	    set counter [expr $counter + 50]
	}
    }
    
    incr length
    set counter 0
    while {$counter < $length} {
	$w.main.c create line $counter [expr $numlanes * $width + 20] \
		$counter [expr $numlanes * $width + 30]
	$w.main.c create text $counter [expr $numlanes * $width + 40] \
		-text [expr $counter/ 12.5]
	set counter [expr $counter + 250]
    }
    # if we need a curved road
    if {$roadFeatures(itraj) == 1} {
       set xc [expr $roadFeatures(xcir) * 12.5 * $ZoomIndex]
       set yc1 [expr (1.5 + $roadFeatures(ycir)) * 12.5 * $ZoomIndex]
       set yc2 [expr (3.5 + $roadFeatures(ycir)) * 12.5 * $ZoomIndex]
       set yc3 [expr (5.5 + $roadFeatures(ycir)) * 12.5 * $ZoomIndex]
       set r  [expr $roadFeatures(rwyrad) * 12.5 * $ZoomIndex]
       $w.main.c create arc [expr $xc - $r] [expr $yc1 - $r] \
                            [expr $xc + $r] [expr $yc1 + $r] \
           -start 90  -extent -90 -outline blue -style arc
       # this is the divider for the curved road
       $w.main.c create arc [expr $xc - $r] [expr $yc2 - $r] \
                            [expr $xc + $r] [expr $yc2 + $r] \
           -start 90  -extent -90 -outline red -style arc
       $w.main.c create arc [expr $xc - $r] [expr $yc3 - $r] \
                            [expr $xc + $r] [expr $yc3 + $r] \
           -start 90  -extent -90 -outline blue -style arc
    }
}

#############################################################################
#
#   Animate the Scenario 
#   
#############################################################################

proc PlayScenario {w} {

    global animationArray carAnimationArray Continue ZoomIndex refreshRate
    global timeOfSimulation TagsToSimulateThisRound SimulatedTags EndOfSnapshotTime
    set snap_list $animationArray(-1,snaps)
    
    if {[llength $snap_list] < 2} {
	bell 
	tk_dialog .error Warning "Cannot animate with only one\
		snapshot." "" 0 OK 
	return
    }
    $w.main.c delete Car
    set last [lindex $snap_list 0]
    set snap_list [lrange $snap_list 1 end] 
#    trace variable timeOfSimulation w CheckSimulationTime

    foreach snap_time $snap_list {
	set tags_to_animate $animationArray($last,tags)
	set number_of_tags [llength $tags_to_animate]
	set time_increase [expr $refreshRate * .001]
	set timeOfSimulation $last
	set total_rounds [expr int(double($snap_time - $last)*10)]
	
	set current_round 0
	while {$current_round < $total_rounds} {
#	    puts "Current round: $current_round"	
	    foreach tag $tags_to_animate {

		set car_id [string range $tag 3 end]
		set v_initial $carAnimationArray($last,$car_id,x_speed)
		set v_final $carAnimationArray($snap_time,$car_id,x_speed)
		set x_initial $carAnimationArray($last,$car_id,x)
		set x_final $carAnimationArray($snap_time,$car_id,x)
		set y_initial $carAnimationArray($last,$car_id,y)
		set y_final $carAnimationArray($snap_time,$car_id,y)
		set or_initial $carAnimationArray($last,$car_id,or)
		set or_final $carAnimationArray($snap_time,$car_id,or)
		set middle_time [expr ($snap_time + $last)/2.0]
		set total_time [expr $snap_time - $last]
		set t_initial $last
		set t_final $snap_time
		
		set a1 [find_a1 $x_initial $x_final $t_initial $t_final\
			$v_initial $v_final]
		set a2 [find_a2 $t_initial $t_final $v_initial\
			$v_final $a1] 
		set v_lateral [find_lateral_v $y_initial $y_final\
			$t_initial $t_final]

		#	    puts "A1 = $a1, A2 = $a2, v-lat= $v_lateral and middle time = $middle_time"
		reDisplayTag $v_initial $x_initial $y_initial $or_initial \
			$a1 $a2 $v_lateral $t_initial\
			$t_final $middle_time \
			$tag $time_increase $current_round
		
	    }
	    after 100
	    update idletasks
	    update
	    incr current_round
	    set timeOfSimulation [expr $timeOfSimulation + $time_increase]
	}
	set last $snap_time
    }
}

###############################################################################
#
#
#
#
###############################################################################


proc reDisplayTag {v x y or a1 a2 v_lat ti tf midtime tag time_increase round} {

    global timeOfSimulation ZoomIndex refreshRate Continue 
    global SimulatedTags TagsToSimulateThisRound EndOfSnapshotTime
    global carFeatures 

    if {$timeOfSimulation >= $midtime} {
	set a $a2
    } else {
	set a $a1
    }

    if {$timeOfSimulation >= $midtime} {
	set x [expr $x + $v*($midtime - $ti) + 0.5 * $a1 * \
		pow($midtime - $ti, 2)]
	set v [expr $v + $a1 * ($midtime - $ti)]
	set x [expr $x + $v*($timeOfSimulation - $midtime) + 0.5 * $a2 * \
		pow($timeOfSimulation - $midtime, 2)]
	set v [expr $v + $a2 * ($timeOfSimulation - $midtime)]
	set a $a2
    } else {
	set x [expr $x + $v*($timeOfSimulation - $ti) + 0.5 * $a1 * \
		pow(($timeOfSimulation - $ti), 2)]
	set v [expr $v + $a1 * ($timeOfSimulation - $ti)]
	set a $a1
    }


    .animation.main.c delete $tag
    set y [expr $y + $v_lat * $refreshRate * .001 * $round]
    
    set car_id [string range $tag 3 end]
    set car_color [GetCarColor $car_id]
    set car_length $carFeatures(car_length)
    set car_width $carFeatures(car_width)

    set x1 [expr (cos($or)*-$car_length/2.0) - (sin($or)*-$car_width/2.0)]
    set y1 [expr (sin($or)*-$car_length/2.0) + (cos($or)*-$car_width/2.0)]
    set x2 [expr -(sin($or)*-$car_width/2.0)]
    set y2 [expr (cos($or)*-$car_width/2.0)]
    set x3 [expr (cos($or)*$car_length/2.0) - (sin($or)*-$car_width/2.0)]
    set y3 [expr (sin($or)*$car_length/2.0) + (cos($or)*-$car_width/2.0)]
    set xf [expr (cos($or)*$car_length*.667)]
    set yf [expr (sin($or)*$car_length*.667)]
    set x4 [expr (cos($or)*$car_length/2.0) - (sin($or)*$car_width/2.0)]
    set y4 [expr (sin($or)*$car_length/2.0) + (cos($or)*$car_width/2.0)]
    set x5 [expr -(sin($or)*$car_width/2.0)]
    set y5 [expr (cos($or)*$car_width/2.0)]
    set x6 [expr (cos($or)*-$car_length/2.0) - (sin($or)*$car_width/2.0)]
    set y6 [expr (sin($or)*-$car_length/2.0) + (cos($or)*$car_width/2.0)]
    set x1 [expr $x1 + $x]
    set y1 [expr $y1 + $y]
    set x2 [expr $x2 + $x]
    set y2 [expr $y2 + $y]
    set x3 [expr $x3 + $x]
    set y3 [expr $y3 + $y]
    set xf [expr $xf + $x]
    set yf [expr $yf + $y]
    set x4 [expr $x4 + $x]
    set y4 [expr $y4 + $y]
    set x5 [expr $x5 + $x]
    set y5 [expr $y5 + $y]
    set x6 [expr $x6 + $x]
    set y6 [expr $y6 + $y]
    set px1 [expr 12.5*$x1*$ZoomIndex]
    set py1 [expr 12.5*$y1*$ZoomIndex]
    set px2 [expr 12.5*$x2*$ZoomIndex]
    set py2 [expr 12.5*$y2*$ZoomIndex]
    set px3 [expr 12.5*$x3*$ZoomIndex]
    set py3 [expr 12.5*$y3*$ZoomIndex]
    set pxf [expr 12.5*$xf*$ZoomIndex]
    set pyf [expr 12.5*$yf*$ZoomIndex]
    set px4 [expr 12.5*$x4*$ZoomIndex]
    set py4 [expr 12.5*$y4*$ZoomIndex]
    set px5 [expr 12.5*$x5*$ZoomIndex]
    set py5 [expr 12.5*$y5*$ZoomIndex]
    set px6 [expr 12.5*$x6*$ZoomIndex]
    set py6 [expr 12.5*$y6*$ZoomIndex]
    .animation.main.c create poly \
      $px1 $py1 $px2 $py2 $px3 $py3 $pxf $pyf $px4 $py4 $px5 $py5 $px6 $py6 \
      -tags $tag -fill $car_color
    .animation.main.c addtag Car withtag $tag
    update idletasks
}
 

###############################################################################
#
#This function iterates and call WRITE_FOR_TAG function 
#
#
###############################################################################


proc WriteScenario {dataFileName} {

    global animationArray carAnimationArray Continue 

    set snap_list $animationArray(-1,snaps)
    

    set dataFile [open $dataFileName w]
    if {[llength $snap_list] < 2} {
	bell 
	tk_dialog .error Warning "Cannot animate with only one\
		snapshot." "" 0 OK 
	return
    }
    set last [lindex $snap_list 0]
    set snap_list [lrange $snap_list 1 end]
    foreach snap_time $snap_list {
	set tags_to_animate $animationArray($last,tags)

	set current_time $last
	set iteration 1
	while {$current_time < $snap_time} {
	    
	    foreach tag $tags_to_animate { 
		set car_id [string range $tag 3 end]
		set v_initial $carAnimationArray($last,$car_id,x_speed)
		set v_final $carAnimationArray($snap_time,$car_id,x_speed)
		set x_initial $carAnimationArray($last,$car_id,x)
		set x_final $carAnimationArray($snap_time,$car_id,x)
		set y_initial $carAnimationArray($last,$car_id,y)
		set y_final $carAnimationArray($snap_time,$car_id,y)
		set middle_time [expr ($snap_time + $last)/2.0]
		set total_time [expr $snap_time - $last + 0.0]
		set t_initial $last
		set t_final $snap_time

		set a1 [find_a1 $x_initial $x_final $t_initial $t_final\
			$v_initial $v_final]
		set a2 [find_a2 $t_initial $t_final $v_initial\
			$v_final $a1] 
		set v_lateral [find_lateral_v $y_initial $y_final\
			$t_initial $t_final]

#		puts "A1 = $a1, A2 = $a2, v-lat= $v_lateral and middle time = $middle_time"
		write_for_tag $tag $t_initial\
			$t_final $middle_time $a1 $a2 $v_lateral\
			$v_initial $x_initial $y_initial\
			$current_time $iteration $dataFile
		
		####INCREMENT LAST
		#  after $animation_redisplayTime "reDisplay $tag "
	    }
	    incr iteration
	    set current_time [expr $current_time + 0.05]
	}
	set last $snap_time
    }
    close $dataFile
}

proc write_for_tag {tag t_i t_f midtime a1 a2 v_lat v x y current_time iteration f} {

    global timeOfSimulation
    
    if {$current_time >= $midtime} {
	set x [expr $x + $v*($midtime - $t_i) + 0.5 * $a1 * \
		pow($midtime - $t_i, 2)]
	set v [expr $v + $a1 * ($midtime - $t_i)]
	set x [expr $x + $v*($current_time - $midtime) + 0.5 * $a2 * \
		pow($current_time - $midtime, 2)]
	set v [expr $v + $a2 * ($current_time - $midtime)]
	set a $a2
    } else {
	set x [expr $x + $v*($current_time - $t_i) + 0.5 * $a1 * \
		pow(($current_time - $t_i), 2)]
	set v [expr $v + $a1 * ($current_time - $t_i)]
	set a $a1
    }
    
    set y [expr $y + $v_lat * ($current_time - $t_i)]
    
    set signNum [signum $v_lat]
    if {$v == 0} {
	set h 0
    } else {
	set h [expr double(3.14159/30.0) * sin((2.0*3.14159/8)*($y*1.0-2.0))*$signNum]
    }

    set carID [string range $tag 3 end]
    puts $f [format "%s %s %s %s %s %s %s %s %s %s %s %s %s %s\
	    %s %s %s %s %s %s %s" $current_time $carID $carID 0 $x -$y\
	    0 $h 0 0 0 $v $a\
	    $h 0 0 0 0 0 0 0]

}
proc signum {v_lat} {
    if {$v_lat == 0} {
	set valu 0
    } elseif {$v_lat > 0} {
	set valu -1.0
    } else {
	set valu 1.0
    }
}

proc find_a1 {x_i x_f t_i t_f v_i v_f} {

    set T [expr ($t_f - $t_i) / 2.0]
    set part1 [expr double($x_f - $x_i)/ double(pow($T,2))]
    set part2 [expr double($v_f + 3* $v_i) / double($t_f -$t_i+0.0)]

    set a1 [expr $part1 - $part2]
    return $a1
}

proc find_a2 {t_i t_f v_i v_f a1} {


    set T [expr double($t_f - $t_i) / 2.0]
    set part1 [expr double($v_f -$v_i) / $T]

    set a2 [expr $part1 - $a1]
    return $a2
}

proc find_lateral_v {y_i y_f t_i t_f } {


    set v_lat [expr ($y_f - $y_i)/(($t_f - $t_i)*1.0)]

    return $v_lat
}



