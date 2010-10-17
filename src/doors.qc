/*
	doors.qc

	door functions

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
*/

void() Add_takedamage;
float DOOR_START_OPEN = 1;
float DOOR_DONT_LINK = 4;
float DOOR_SILVER_GOLD_KEY = 24;
float DOOR_TOGGLE = 32;

/*

Doors are similar to buttons, but can spawn a fat trigger field around them
to open without a touch, and they link together to form simultanious
double/quad doors.
 
Door.owner is the master door. If there is only one door, it points to itself.
If multiple doors, all will point to a single one.

Door.enemy chains from the master door through all doors linked in the chain.

*/

/*
=============================================================================

THINK FUNCTIONS

=============================================================================
*/

void() door_go_down;
void() door_go_up;

void() door_blocked =
{
	if (other.client_)
	{
		deathtype = "squish";
		inflictor = self;
		attacker = self.goalentity;
		targ = other;
		damage = self.dmg;
		T_Damage ();
		if (self.state == STATE_DOWN)
			door_go_up ();
		else
			door_go_down ();
	}
};


void() door_hit_top =
{
	msg_entity = self;
	sound (CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;
	if (self.spawnflags & DOOR_TOGGLE)
		return;		// don't come down automatically
	self.think = door_go_down;
	self.nextthink = self.ltime + self.wait;
};

void() door_hit_bottom =
{
	msg_entity = self;
	sound (CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_BOTTOM;
};

void() door_go_down =
{
	msg_entity = self;
	sound (CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	if (self.max_health)
	{
		self.takedamage = DAMAGE_YES;
		self.health = self.max_health;
	}
	
	self.state = STATE_DOWN;
	self.think1 = door_hit_bottom;
	SUB_CalcMove (self.pos1, self.speed);
};

void() door_go_up =
{
	if (self.state != STATE_UP)
	{
		if (self.state == STATE_TOP)
		{	// reset top wait time
			self.nextthink = self.ltime + self.wait;
		}
		else
		{
			msg_entity = self;
			sound (CHAN_VOICE, self.noise2, 1, ATTN_NORM);
			self.state = STATE_UP;
			self.think1 = door_hit_top;
			SUB_CalcMove (self.pos2, self.speed);
			SUB_UseTargets();
		}
	}
};

float() door_target =
{
	if (self.health)
		return TRUE;
	if (self.targetname)
		return (find(world, target, self.targetname) != world);
	return TRUE;
};

void() check_door_open =
{
	if (framecount < 2)
	{
		self.nextthink = self.ltime + 0.001;
		return;
	}

	if (door_target())
	{
		setorigin (self, self.pos2);
		self.state = STATE_TOP;
	}
	self.targetname = "";
};

/*
=============================================================================

ACTIVATION FUNCTIONS

=============================================================================
*/
void() door_use =
{
	self = self.owner;
	if (self.spawnflags & DOOR_TOGGLE)
	{
		if (self.state == STATE_UP || self.state == STATE_TOP)
		{
			door_enemy = self;
			do
			{
				door_go_down ();
				self = self.enemy;
			} while ( (self != door_enemy) && (self != world) );
			return;
		}
	}
	
// trigger all paired doors
	door_enemy = self;
	do
	{
		self.goalentity = activator;		// Who fired us
		door_go_up ();
		self = self.enemy;
	} while ( (self != door_enemy) && (self != world) );
};

void() door_trigger_touch =
{
	if (counting_down)
		return;

	if (other.client_)
	{
		if (time >= self.attack_finished)
		{
			self.attack_finished = time + 1;
			activator = other;
			self = self.owner;
			door_use ();
		}
	}
};

/*
================
door_touch

================
*/
void() door_touch =
{
	if (counting_down)
		return;

	if (marker_time)
	{
		if (other.client_)
		{
			if (self.fl_marker)
				check_marker();
		}
	}
};

void() door_killed =
{
	if (counting_down)
		return;

	self = self.owner;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// wil be reset upon return
	door_use ();
};

/*
=============================================================================

SPAWNING FUNCTIONS

=============================================================================
*/

float (entity e1, entity e2) EntitiesTouching =
{
	if (e1.mins_x > e2.maxs_x)
		return FALSE;
	if (e1.mins_y > e2.maxs_y)
		return FALSE;
	if (e1.mins_z > e2.maxs_z)
		return FALSE;
	if (e1.maxs_x < e2.mins_x)
		return FALSE;
	if (e1.maxs_y < e2.mins_y)
		return FALSE;
	if (e1.maxs_z < e2.mins_z)
		return FALSE;
	return TRUE;
};


/*
=============
LinkDoors


=============
*/
void() LinkDoors =
{
	if (framecount < 2)
	{
		self.nextthink = self.ltime + 0.001;
		return;
	}

	if (self.enemy)
		return;		// already linked by another door
	if (self.spawnflags & 4)
	{
		self.owner = self.enemy = self;
		// don't want to link this door
	}
	else
	{
		cmins = self.mins;
		cmaxs = self.maxs;
	
		door_enemy = self;
		t = self;
	
		while (TRUE)
		{
			self.owner = door_enemy;			// master door

			if (self.health)
				door_enemy.health = self.health;
			if (self.targetname)
				door_enemy.targetname = self.targetname;

			t = find (t, classname, "door");	
			if (!t)
			{
				self.enemy = door_enemy;		// make the chain a loop

			// shootable, or fired doors just needed the owner/enemy links,
			// they don't spawn a field
	
				self = self.owner;

				if (self.health)
					return;
				if (self.targetname)
					return;

				trigger = spawn();
				trigger.movetype = MOVETYPE_NONE;
				trigger.solid = SOLID_TRIGGER;
				trigger.owner = self;
				trigger.touch = door_trigger_touch;
				setsize (trigger, cmins - '60 60 8', cmaxs + '60 60 8');
				return;
			}

			if (EntitiesTouching(self, t))
			{
				self.enemy = t;
				self = t;

				if (t.mins_x < cmins_x)
					cmins_x = t.mins_x;
				if (t.mins_y < cmins_y)
					cmins_y = t.mins_y;
				if (t.mins_z < cmins_z)
					cmins_z = t.mins_z;
				if (t.maxs_x > cmaxs_x)
					cmaxs_x = t.maxs_x;
				if (t.maxs_y > cmaxs_y)
					cmaxs_y = t.maxs_y;
				if (t.maxs_z > cmaxs_z)
					cmaxs_z = t.maxs_z;
			}
		}
	}
};

/*QUAKED func_door (0 .5 .8) ? START_OPEN x DOOR_DONT_LINK GOLD_KEY SILVER_KEY TOGGLE
if two doors touch, they are assumed to be connected and operate as a unit.

TOGGLE causes the door to wait in both the start and end states for a trigger event.

START_OPEN causes the door to move to its posination when spawned, and operate in reverse. It is used to temporarily or permanently close off an area when triggered (not usefull for touch or takedamage doors).

Key doors are allways wait -1.

"message"	is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"		determines the opening direction
"targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"	if set, door must be shot open
"speed"		movement speed (100 default)
"wait"		wait before returning (3 default, -1 = never return)
"lip"		lip remaining at end of move (8 default)
"dmg"		damage to inflict when blocked (2 default)
"sounds"
0)	no sound
1)	stone
2)	base
3)	stone chain
4)	screechy metal
*/
void() func_door =
{
// put on save que
	AddToQue();

	self.classname = "door";

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);

	if (!self.lip)
		self.lip = 8;

	SetMovedir ();

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);

// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
// but spawn in the open position
	if (self.spawnflags & DOOR_START_OPEN)
	{
		setorigin (self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}

	self.nextthink = self.ltime + 0.001;

	if (self.wait < 0)
	{
		self.think = check_door_open;
	}
	else
	{
		if (world.worldtype == 0)
		{
			precache_sound ("doors/medtry.wav");
			precache_sound ("doors/meduse.wav");
			self.noise3 = "doors/medtry.wav";
			self.noise4 = "doors/meduse.wav";
		}
		else if (world.worldtype == 1)
		{
			precache_sound ("doors/runetry.wav");
			precache_sound ("doors/runeuse.wav");
			self.noise3 = "doors/runetry.wav";
			self.noise4 = "doors/runeuse.wav";
		}
		else if (world.worldtype == 2)
		{
			precache_sound ("doors/basetry.wav");
			precache_sound ("doors/baseuse.wav");
			self.noise3 = "doors/basetry.wav";
			self.noise4 = "doors/baseuse.wav";
		}
		if (self.sounds == 0)
		{
			precache_sound ("misc/null.wav");
			precache_sound ("misc/null.wav");
			self.noise1 = "misc/null.wav";
			self.noise2 = "misc/null.wav";
		}
		else if (self.sounds == 1)
		{
			precache_sound ("doors/drclos4.wav");
			precache_sound ("doors/doormv1.wav");
			self.noise1 = "doors/drclos4.wav";
			self.noise2 = "doors/doormv1.wav";
		}
		else if (self.sounds == 2)
		{
			precache_sound ("doors/hydro1.wav");
			precache_sound ("doors/hydro2.wav");
			self.noise2 = "doors/hydro1.wav";
			self.noise1 = "doors/hydro2.wav";
		}
		else if (self.sounds == 3)
		{
			precache_sound ("doors/stndr1.wav");
			precache_sound ("doors/stndr2.wav");
			self.noise2 = "doors/stndr1.wav";
			self.noise1 = "doors/stndr2.wav";
		}
		else if (self.sounds == 4)
		{
			precache_sound ("doors/ddoor1.wav");
			precache_sound ("doors/ddoor2.wav");
			self.noise1 = "doors/ddoor2.wav";
			self.noise2 = "doors/ddoor1.wav";
		}

		self.max_health = self.health;

		self.touch = door_touch;
		self.blocked = door_blocked;
		self.use = door_use;

		if (!self.speed)
			self.speed = 100;
		if (!self.wait)
			self.wait = 3;
		if (!self.dmg)
			self.dmg = 2;

		self.state = STATE_BOTTOM;

		if (self.health)
		{
			self.th_die = door_killed;
			Add_takedamage();
		}
	
		self.oldorigin = self.origin;

	// LinkDoors can't be done until all of the doors have been spawned, so
	// the sizes can be detected properly.
		self.think = LinkDoors;

		self.view_ofs = 0.5 * (self.absmax - self.absmin);
		self.view_ofs_z = self.absmax_z - self.absmin_z + 23;
		adjust_view_ofs_z();
		BecomeMarker(self);
	}
};

/*
=============================================================================

SECRET DOORS

=============================================================================
*/

void() fd_secret_move1;
void() fd_secret_move2;
void() fd_secret_move3;
void() fd_secret_move4;
void() fd_secret_move5;
void() fd_secret_move6;
void() fd_secret_done;

float SECRET_OPEN_ONCE = 1;		// stays open
float SECRET_1ST_LEFT = 2;		// 1st move is left of arrow
float SECRET_1ST_DOWN = 4;		// 1st move is down from arrow
float SECRET_NO_SHOOT = 8;		// only opened by trigger
float SECRET_YES_SHOOT = 16;	// shootable even if targeted


void () fd_secret_use =
{
	if (pre_game)
		return;

	self.health = 10000;

	// exit if still moving around...
	if (self.origin == self.oldorigin)
	{
		SUB_UseTargets();
		if (!(self.spawnflags & SECRET_NO_SHOOT))
		{
			self.th_pain = dropper.th_pain;	// NULL
			self.takedamage = DAMAGE_NO;
		}
		self.velocity = '0 0 0';

		// Make a sound, wait a little...

		msg_entity = self;
		sound(CHAN_VOICE, self.noise1, 1, ATTN_NORM);
		self.nextthink = self.ltime + 0.1;

		self.think1 = fd_secret_move1;
		SUB_CalcMove(self.pos1, self.speed);
		msg_entity = self;
		sound(CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	}
};

// Wait after first movement...
void () fd_secret_move1 = 
{
	self.nextthink = self.ltime + 1;
	self.think = fd_secret_move2;
	msg_entity = self;
	sound(CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

// Start moving sideways w/sound...
void () fd_secret_move2 =
{
	msg_entity = self;
	sound(CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	self.think1 = fd_secret_move3;
	SUB_CalcMove(self.pos2, self.speed);
};

// Wait here until time to go back...
void () fd_secret_move3 =
{
	msg_entity = self;
	sound(CHAN_VOICE, self.noise3, 1, ATTN_NORM);
	self.nextthink = self.ltime + self.wait;
	self.think = fd_secret_move4;
};

// Move backward...
void () fd_secret_move4 =
{
	msg_entity = self;
	sound(CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	self.think1 = fd_secret_move5;
	SUB_CalcMove(self.pos1, self.speed);
};

// Wait 1 second...
void () fd_secret_move5 = 
{
	self.nextthink = self.ltime + 1;
	self.think = fd_secret_move6;
	msg_entity = self;
	sound(CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () fd_secret_move6 =
{
	msg_entity = self;
	sound(CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	self.think1 = fd_secret_done;
	SUB_CalcMove(self.oldorigin, self.speed);
};

void () fd_secret_done =
{
	if (self.max_health)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		self.th_pain = fd_secret_use;	
	}
	msg_entity = self;
	sound(CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () secret_blocked =
{
	if (other.client_)
	{
		if (time >= self.attack_finished)
		{
			self.attack_finished = time + 0.5;
			deathtype = "squish";
			inflictor = self;
			attacker = self;
			targ = other;
			damage = self.dmg;
			T_Damage ();
		}
	}
};

/*
================
secret_touch

================
*/
void() secret_touch =
{
	if (counting_down)
		return;

	if (other.client_)
	{
		if (marker_time)
		if (self.fl_marker)
			check_marker();

		if (self.attack_finished <= time)
			self.attack_finished = time + 2;
	}
};

float() secret_target =
{
	if (self.spawnflags & SECRET_YES_SHOOT)
		return TRUE;
	if (self.targetname)
		return (find(world, target, self.targetname) != world);
	return TRUE;
};

void() check_secret_open =
{
	if (secret_target())
		setorigin (self, self.pos2);
	self.targetname = "";
};


/*QUAKED func_door_secret (0 .5 .8) ? open_once 1st_left 1st_down no_shoot always_shoot
Basic secret door. Slides back, then to the side. Angle determines direction.
wait = # of seconds before coming back
1st_left = 1st move is left of arrow
1st_down = 1st move is down from arrow
always_shoot = even if targeted, keep shootable
t_width = override WIDTH to move back (or height if going down)
t_length = override LENGTH to move sideways
"dmg"		damage to inflict when blocked (2 default)

If a secret door has a targetname, it will only be opened by it's botton or trigger, not by damage.
"sounds"
1) medieval
2) metal
3) base
*/

void () func_door_secret =
{
// put on save que
	AddToQue();

	self.classname = "door";

	// Magic formula...
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.model);
	setorigin (self, self.origin);

	makevectors(self.mangle);
	
	if (!self.t_width)
	{
		if (self.spawnflags & SECRET_1ST_DOWN)
			self.t_width = fabs(v_up * self.size);
		else
			self.t_width = fabs(v_right * self.size);
	}
		
	if (!self.t_length)
		self.t_length = fabs(v_forward * self.size);

	if (self.spawnflags & SECRET_1ST_DOWN)
		self.pos1 = self.origin - v_up * self.t_width;
	else
		self.pos1 = self.origin + v_right * (self.t_width * (1 - (self.spawnflags & SECRET_1ST_LEFT)));
		
	self.pos2 = self.pos1 + v_forward * self.t_length;

	if (self.spawnflags & SECRET_OPEN_ONCE)
	{
		self.nextthink = self.ltime + 0.001;
		self.think = check_secret_open;
	}
	else
	{
		if (self.sounds == 0)
			self.sounds = 3;
		if (self.sounds == 1)
		{
			precache_sound ("doors/latch2.wav");
			precache_sound ("doors/winch2.wav");
			precache_sound ("doors/drclos4.wav");
			self.noise1 = "doors/latch2.wav";
			self.noise2 = "doors/winch2.wav";
			self.noise3 = "doors/drclos4.wav";
		}
		if (self.sounds == 2)
		{
			precache_sound ("doors/airdoor1.wav");
			precache_sound ("doors/airdoor2.wav");
			self.noise2 = "doors/airdoor1.wav";
			self.noise1 = "doors/airdoor2.wav";
			self.noise3 = "doors/airdoor2.wav";
		}
		if (self.sounds == 3)
		{
			precache_sound ("doors/basesec1.wav");
			precache_sound ("doors/basesec2.wav");
			self.noise2 = "doors/basesec1.wav";
			self.noise1 = "doors/basesec2.wav";
			self.noise3 = "doors/basesec2.wav";
		}

		if (!self.dmg)
			self.dmg = 2;
		
		self.touch = secret_touch;
		self.blocked = secret_blocked;
		self.speed = 50;
		self.use = fd_secret_use;

		if ((!self.targetname) || (self.spawnflags & SECRET_YES_SHOOT))
		{
			self.max_health = self.health = 10000;
			self.th_pain = fd_secret_use;
			self.th_die = fd_secret_use;
			Add_takedamage();
		}
		self.oldorigin = self.origin;
		if (!self.wait)
			self.wait = 5;		// 5 seconds before closing

		self.view_ofs = 0.5 * (self.absmax - self.absmin);
		self.view_ofs_z = self.absmax_z - self.absmin_z + 23;
		adjust_view_ofs_z();
		BecomeMarker(self);
	}
};