This directory contains the source code for the SMAC(Simulation Model
for Automobile Collisions) and Carmma(simulation animation) programs.
There are additional functions to aid the user in defining the input 
parameters and in preparing the necessary data for animation purposes.
The files are contained in the archive file SMAC_Project.tar.gz.
A brief description of each function follows.

SMAC - Simulation Model for Automobile Collisions 

The SMAC simulator determines the distance/velocity profiles of two vehicles
using input parameters including initial lateral and longitudinal positions
and velocities.  The simulation continues after the vehicles collide until
both vehicles are at rest.  The input parameters are defined in file INPUT.DAT
and the output files are OUTPUT.DAT, VEH1.DAT and VEH2.DAT.  
The simulation is run by typing the name of the executable(edsmac).
SMAC is described in detail in the SMAC User's Manual, which is located
at the PATH web site: http://www.path.berkeley.edu(UCB-ITS-PWP-98-16).

Posvel - Set vehicle positions and velocities in file INPUT.DAT

This function is not necessary if the user wishes to set all data in INPUT.DAT 
directly using an editor.
The Posvel function prompts the user for the positions and velocities of
the vehicles in meters and meters/sec.  It leaves the other parameters
in file INPUT.DAT at the original values.  This function must be run before
before SMAC is run.  The program is run by typing the name of the
executable(Posvel).

Hwydata - Set vehicle scenario data for Carmma program animation

The Hwydata function uses the vehicle position and velocity data provided by
SMAC in VEH1.DAT and VEH2.DAT to create the highway scenario file.  This file
contains the simulation data in a format usable by Carmma.  Carmma is
a program which animates the simulation data.  Hwydata uses the vehicle
simulation profile information in VEH1.DAT and VEH2.DAT and also the
vehicle trajectory parameters from INPUT.DAT.  The trajectory parameters
determine the type of trajectory, either a curved or straight road.
The program is run by typing "Hwydata filename.hwy".  The file name should
be different for each SMAC simulation case, i.e. different versions of
files VEH1.DAT and VEH2.DAT.  The highway scenario file for Carmma must have
the suffix "hwy".

Carmma - Vehicle simulation animation program

Carmma is an animation program with a menu-driven user interface.  It is
used to animate simulations that have data defined in the highway scenario
format.  Carmma is executed by typing in the command "Carmma".
Carmma is described in detail in the Carmma User's Manual, which is located
at the PATH web site: http://www.path.berkeley.edu(SmartAHSProject).
 
Source Code for SMAC, Posvel, Hwydata and Carmma

The source code for SMAC is in FORTRAN 77.  Posvel and Hwydata source code is
written in the C language.  Carmma source code is written in Tcl/Tk.
For the UNIX operating system the makefiles can be used to create
the executables for SMAC, Posvel, Hwydata and Carmma.  makefile1 can be  
used to compile SMAC, Posvel and Hwydata source code.  makefile2 can be
used to compile the Carmma source code.
