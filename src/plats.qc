/*
	plats.qc

	platform functions

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
*/

void() plat_center_touch;
void() plat_go_up;
void() plat_go_down;
void() plat_crush;
float PLAT_LOW_TRIGGER = 1;

void() plat_spawn_inside_trigger =
{
//
// middle trigger
//	
	trigger = spawn();
	trigger.touch = plat_center_touch;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.enemy = self;
	
	tmin = self.mins + '25 25 0';
	tmax = self.maxs - '25 25 -8';
	tmin_z = tmax_z - (self.pos2_z - self.pos1_z + 8);
	if (self.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + 8;
	
	if (self.size_x <= 50)
	{
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50)
	{
		tmin_y = (self.mins_y + self.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}
	
	setsize (trigger, tmin, tmax);
};

void() plat_hit_top =
{
	msg_entity = self;
	sound (CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;
	self.think = plat_go_down;
	self.nextthink = self.ltime + 3;
};

void() plat_hit_bottom =
{
	msg_entity = self;
	sound (CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_BOTTOM;
};

void() plat_go_down =
{
	msg_entity = self;
	sound (CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_DOWN;
	self.think1 = plat_hit_bottom;
	SUB_CalcMove (self.pos1, self.speed);
};

void() plat_go_up =
{
	msg_entity = self;
	sound (CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_UP;
	self.think1 = plat_hit_top;
	SUB_CalcMove (self.pos2, self.speed);
};

void() plat_center_touch =
{
	if (counting_down)
		return;

	if (other.client_)
	{
		self = self.enemy;
		if (self.state == STATE_BOTTOM)
			plat_go_up ();
		else if (self.state == STATE_TOP)
			self.nextthink = self.ltime + 1;	// delay going down
	}
};


void() plat_crush =
{
	deathtype = "squish";
	inflictor = self;
	attacker = self;
	targ = other;
	damage = 1;
	T_Damage ();
	
	if (self.state == STATE_UP)
		plat_go_down ();
	else if (self.state == STATE_DOWN)
		plat_go_up ();
};


/*QUAKED func_plat (0 .5 .8) ? PLAT_LOW_TRIGGER
speed	default 150

Plats are always drawn in the extended position, so they will light correctly.

If the plat is the target of another trigger or button, it will start out disabled in the extended position until it is trigger, when it will lower and become a normal plat.

If the "height" key is set, that will determine the amount the plat moves, instead of being implicitly determined by the model's height.
Set "sounds" to one of the following:
1) base fast
2) chain slow
*/

void() func_plat =
{
// put on save que
	AddToQue();

	self.classname = "door";

	if (!self.t_length)
		self.t_length = 80;
	if (!self.t_width)
		self.t_width = 10;

	if (self.sounds == 0)
		self.sounds = 2;
// FIX THIS TO LOAD A GENERIC PLAT SOUND

	if (self.sounds == 1)
	{
		precache_sound ("plats/plat1.wav");
		precache_sound ("plats/plat2.wav");
		self.noise = "plats/plat1.wav";
		self.noise1 = "plats/plat2.wav";
	}

	if (self.sounds == 2)
	{
		precache_sound ("plats/medplat1.wav");
		precache_sound ("plats/medplat2.wav");
		self.noise = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}

	self.mangle = self.angles;
	self.angles = '0 0 0';

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	setsize (self, self.mins, self.maxs);

	self.touch = door_touch;
	self.blocked = plat_crush;
	if (!self.speed)
		self.speed = 150;

// pos2 is the top position, pos1 is the bottom
	self.pos2 = self.origin;
	self.pos1 = self.origin;
	if (self.height)
		self.pos1_z = self.origin_z - self.height;
	else
		self.pos1_z = self.origin_z - self.size_z + 8;

	plat_spawn_inside_trigger ();	// the "start moving" trigger	

	setorigin (self, self.pos1);
	self.state = STATE_BOTTOM;

	self.oldorigin = self.origin;

	self.targetname = "";

	self.view_ofs = 0.5 * (self.absmax - self.absmin);
	self.view_ofs_z = self.absmax_z - self.absmin_z + 23;
	adjust_view_ofs_z();
	BecomeMarker(self);
};

//============================================================================

void() train_next;
void() func_train_find;

void() train_blocked =
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

void() train_wait =
{
	if (self.wait)
	{
		self.nextthink = self.ltime + self.wait;
		msg_entity = self;
		sound (CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
	else
		self.nextthink = self.ltime + 0.1;

	if (!counting_down) 
		self.think = train_next;
};

void() train_next =
{
	target_ = find (world, targetname, self.target);
	self.target = target_.target;
	self.wait = target_.wait;
	msg_entity = self;
	sound (CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.think1 = train_wait;
	SUB_CalcMove (target_.origin - self.mins, self.speed);
};

void() train_touch =
{
	if (other.client_)
	{
		if (marker_time)
		if (self.fl_marker)
			check_marker();

		if (other.flags & FL_ONGROUND)
			other.fl_ontrain = TRUE;	// used in FrogbotPrePhysics2
	}
};

void() func_train_find =
{
	if (framecount < 2)
	{
		self.nextthink = self.ltime + 0.001;
		return;
	}

	target_ = find(world, targetname, self.target);
	while ((!target_.admin_code) && (target_.wait >= 0))
	{
		target_.admin_code = TRUE;
		target_ = find(world, targetname, target_.target);
	}

	if (target_.wait < 0)
	{
		setorigin(self, target_.origin - self.mins);

		target_ = find(world, targetname, self.target);
		while (target_.admin_code)
		{
			target_.admin_code = FALSE;
			target_ = find(world, targetname, target_.target);
		}
	}
	else
	{
		if (!self.speed)
			self.speed = 100;
		if (!self.dmg)
			self.dmg = 2;

		self.blocked = train_blocked;

		self.touch = train_touch;

		target_ = find (world, targetname, self.target);
		self.target = self.netname = target_.target;
		setorigin (self, target_.origin - self.mins);
		self.oldorigin = self.origin;
		self.nextthink = self.ltime + 0.1;
		self.think = train_next;

		self.view_ofs = 0.5 * (self.absmax - self.absmin);
		self.view_ofs_z = self.absmax_z - self.absmin_z + 23;
		adjust_view_ofs_z();
		BecomeMarker(self);
	}
};

/*QUAKED func_train (0 .5 .8) ?
Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
speed	default 100
dmg		default	2
sounds
1) ratchet metal

*/
void() func_train =
{
// put on save que
	AddToQue();

	self.classname = "door";

	if (self.sounds == 0)
	{
		self.noise = ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = ("misc/null.wav");
		precache_sound ("misc/null.wav");
	}

	if (self.sounds == 1)
	{
		self.noise = ("plats/train2.wav");
		precache_sound ("plats/train2.wav");
		self.noise1 = ("plats/train1.wav");
		precache_sound ("plats/train1.wav");
	}

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.001;
	self.think = func_train_find;

	self.targetname = "";
};
