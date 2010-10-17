Title        : Frogbot test version (does not replace older frogbot versions)
Filename     : frogbot013.zip
Date         : 26 April 1999
Author       : Robert Field
Email        : frog@powerup.com.au
Download     : http://www.telefragged.com/metro/


This file is for extra stuff not in readme012c.txt of the v0.12c Frogbot.


Installation instructions
=========================

Extract frogbot013.zip into a "runaway" subdirectory of your Quake directory. I advise against overwriting previous frogbot installations. Extract bots.zip and src.zip into a bots and src subdirectory respectively of this "runaway" directory.


Important Notes
===============

* The bots will only do prediction (rl/gl) shots with rl_pref enabled.
* I recommend using deathmatch 6 setting without powerups. The code may be in a broken/disabled state with other settings.
* The skill setting goes from 0 to 20 (equivalent to skill 0 to 200 in v0.12c).
* Though I'm not generally concerned with bug reports for this release, I would be interested to know if the crash bugs of v0.12c are still present.


Why release this "version"?
===========================

Interest has been expressed in the demos of frogbot_demo.zip dated 1/9/99. This is the build of the source, warts and all, that produced those demos. I would not suggest replacing current frogbot versions on your hard disk with this version. Though there are some things in this version that may be of interest to people.
This release could be viewed as a technology demo, displaying certain bot abilities which have yet to be integrated into a coherent whole.


Bonus Maze game
===============
!!WARNING!! - will only work with resolution 512 x 384 or above.

Please note the above warning.
While not that polished, included is a maze game. It is only for the Quake version, but it has multiplayer capabilty.
To play the maze game, type "arcade" at the console, then restart a map.
Each time you start a map a maze will be randomly created. A feature of the maze algorithm that I have worked out is that it produces no direct dead ends and no isolated (ie. single dot) walls. This is to maximize playabilty.
Movement is achieved by the same keys/buttons you use for Quake movement.

For those interested in recompiling the source:
Note that the constants BADDIE_NUMBER, MAZE_ROWS, and MAZE_COLUMNS may be changed. The current maximum BADDIE_NUMBER is 199. I have had it working at 400, but I have somehow screwed some aspect of my "memory allocation" method. You can use a maze up to 95 x 95. A row or column can exceed 95 if the other coordinate is reduced. Row and column sizes must be odd numbers.

The maze game demonstrates my array implementation. If you read the code you will see that sometimes I have split the implementation of a 1-dimensional array into 2 dimensions. This is for speed reasons, since in this case I have a double binary search (the arrays are implemented by a linked list of binary searches - it is desirable to keep the linked list sizes small for fast array lookup).

Some ideas of other games are (by me or someone else, using my array implementation in array.qc):
1) A snake game.
2) A Tetris style game.
3) A Frogger style game.


Creepcam support
================

Included is a version of Creepcam that I have hacked into the code. You must seek the permission of the authors of Creepcam before using any of the included Creepcam code. Please see the DiMeBoX Creepcam site http://members.xoom.com/DBmandrake/.
Creepcam may be toggled by typing "creepcam" at the console. Fire switches type of view. Jump switches player.


Test Console
============
!!WARNING!! - will only work with resolution 512 x 384 or above.
!!WARNING!! - will stuff up your config.cfg if you quit Quake while this mode is active.

Please note the above warnings.
Included is a test console. It only works for the Quake version. To toggle this mode type "console" at the console. Do not use when you are playing the maze game. The alt key toggles colored letters. The shift key toggles upper/lower case. It is worth noting that this console currently has no functionality.


Miscellaneous features
======================

If you are willing to recompile the mod then there are some extra features available to you. I haven't implemented them as command options yet. The selection of these options can be found in defs.qc after the comment "miscellaneous features".
1) game_multiwep toggles multiweapon support. Extra .mdl files are needed for this option.
2) game_dropquad toggles if the quad is dropped.
3) game_dropring toggles if the ring is dropped.
4) game_fastnail toggles if nails are instantaneous (at a range of distance travelled in 1 second).

By default I have enabled 2 physics cycles per bot per server frame in QW. This can be set to 1 physics cycle by setting the "double_botphysics" constant in defs.qc to 0.


Instructions on compiling the source
====================================

I have compiled the source with MrElusive's (of Omicron and Gladiator bot fame) QuakeC compiler v1.2, Dec 10 1998 21:15:11.
There may be difficulties using other compilers. I am not aware of any advantage in using another compiler (so bite me :).
Extract the src.zip file into a directory c:\quake\runaway\src (assuming c:\quake is your Quake directory). Place meqcc.exe in this directory (this file is not included). At the dos prompt "C:\QUAKE\runaway\src>" type "meqcc".
Compile directives may be found in settings.h. An option is selected by deciding to comment a line out or not. To select Quake or QW, you must set the "#define QUAKE" of settings.h and the first line of progs.src.


Compile alternatives
====================

The source included is that used for the 3 demos of the file frogbot_demo.zip dated 1/9/99.
The compilation of the code was slightly different for each demo.

* runaway.dem:
The source as is.

* runambush.dem:
Before the line:
"	if (self.state & WAIT)"
in botpath.qc add the statement:
"	self.state = self.state | WAIT;"

* height.dem:
The first line of botgoals.qc should be:
"//#define _runaway_".
The line before "#ifdef HEIGHT" in botpath.qc should be:
"#define HEIGHT".

* There may be success in compiling without these options but I cannot remember if things are disabled/broken in this build of the source.


Thanks
======

* Wrecker for his cool Frogbot's Modifications site http://www.botepidemic.com/fmods/.
* All the map/mod makers who have invested considerable time enhancing the Frogbot (rather than listing the people here I recommend going to the Frogbot's Modifications site).
* Shelob for pointing out that my code (v0.12c) was not compliant with the 50ms QW "rocket prediction" hack. The changes are included.
* Simon Byrnand (aka Mandrake) for allowing me to use his Creepcam code, and helping me out with difficulties.


Apologies
=========

* To all the people that have sent me an email but haven't received a reply. I have been slack.
