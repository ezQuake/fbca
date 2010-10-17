/*
	triggers.qc

	trigger functions

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
*/

void() HazardTeleport;

float	SPAWNFLAG_NOTOUCH = 1;

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
	if (self.nextthink <= time)
	{
		if (self.noise)
		{
			msg_entity = self;
			sound (CHAN_VOICE, self.noise, 1, ATTN_NORM);
			enemy_ = self.enemy;
			check_sound();
		}

	// don't trigger again until reset
		self.takedamage = DAMAGE_NO;

		activator = self.enemy;
		SUB_UseTargets();
	
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
};

void() multi_killed =
{
	self.enemy = attacker;
	multi_trigger();
};

void() multi_use =
{
	self.enemy = activator;
	multi_trigger();
};

void() multi_touch =
{
	if (other.client_)
	{
	// if the trigger has an angles field, check player's facing direction
		if (self.movedir != '0 0 0')
		{
			makevectors (other.angles);
			if (v_forward * self.movedir < 0)
				return;		// not facing the right way
		}
	
		self.enemy = other;
		multi_trigger ();
	}
};

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger. Must be targeted at one or more entities. If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_multiple_create =
{
	if (self.wait < 0)
	{
		SUB_DelayRemove();
	}
	else
	{
		if (self.sounds == 1)
		{
			precache_sound ("misc/secret.wav");
			self.noise = "misc/secret.wav";
		}
		else if (self.sounds == 2)
		{
			precache_sound ("misc/talk.wav");
			self.noise = "misc/talk.wav";
		}
		else if (self.sounds == 3)
		{
			precache_sound ("misc/trigger1.wav");
			self.noise = "misc/trigger1.wav";
		}
	
		if (!self.wait)
			self.wait = 0.2;
		self.use = multi_use;

		InitTrigger ();

		if (self.health)
		{
			self.max_health = self.health;
			self.th_die = multi_killed;
			Add_takedamage();
			self.solid = SOLID_BBOX;
			setorigin (self, self.origin);	// make sure it links into the world
		}
		else
		{
			if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
				self.touch = multi_touch;
		}
	}
};

void() trigger_multiple =
{
// put on save que
	AddToQue();

	trigger_multiple_create();
};

/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself. You must set the key "target" to the name of another object in the level that has a matching
"targetname". If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle. Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_once =
{
// put on save que
	AddToQue();

	SUB_DelayRemove();
};

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events. It can contain killtargets, targets, delays, and messages.
*/
void() trigger_relay =
{
	SUB_DelayRemove();
};

//=============================================================================

/*QUAKED trigger_secret (.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
void() trigger_secret =
{
// put on save que
	AddToQue();

	SUB_DelayRemove();
};

//=============================================================================


/*QUAKED trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove_self itself.
*/
void() trigger_counter =
{
// put on save que
	AddToQue();

	SUB_DelayRemove();
};


/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

float	SILENT = 2;

void(entity sndspot) play_teleport =
{
	rnd = random() * 5;
	if (rnd < 1)
		str = "misc/r_tele1.wav";
	else if (rnd < 2)
		str = "misc/r_tele2.wav";
	else if (rnd < 3)
		str = "misc/r_tele3.wav";
	else if (rnd < 4)
		str = "misc/r_tele4.wav";
	else
		str = "misc/r_tele5.wav";

	msg_entity = sndspot;
	sound (CHAN_VOICE, str, 1, ATTN_NORM);
	enemy_ = sndspot.enemy;
	check_sound();
};

void(vector org, entity e) spawn_tfog =
{
	tfog = spawn ();
	tfog.enemy = e;
	tfog.origin = org;
	tfog.nextthink = time + 0.2;
	tfog.think = SUB_Remove;
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_TELEPORT);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	multicast (org, MULTICAST_PHS);
};


void() tdeath_touch =
{
	if (other.client_)
	{
		if (other != self.owner)
		{
			if (other.takedamage)
			{
				if (toss_player())
					return;
				inflictor = self;
				attacker = self;
				damage = 50000;

				if (other.invincible_finished > time)
				{
					if (self.invincible_finished > time)
					{
						other.invincible_finished = 0;
						deathtype = "teledeath3";
					}
					else
					{
						deathtype = "teledeath2";
						targ = self.owner;
						T_Damage ();
					}
				}
				else
					deathtype = "teledeath";

				targ = other;
				T_Damage ();
			}
		}
	}
};


void(vector org, entity death_owner) spawn_tdeath =
{
	death = spawn();
	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath_touch;
// changed from 0.2 to 0.1 to fix telefrag bug (what a phuckin stupid idea is 2)
	death.nextthink = time + 0.1;
	death.think = SUB_Remove;
	death.owner = death_owner;
	death.invincible_finished = death_owner.invincible_finished;
};

void() teleport_touch =
{
	local entity othercopy;

	if (other.client_)
	{
		if (other.takedamage)
		{
			if (NoItemTouch())
			{
				other.near_teleport = self;
				if (marker_time)
					HazardTeleport();
				return;
			}

// put a tfog where the player was and play teleporter sound
// For some odd reason (latency?), no matter if the sound was issued to play
// at the spot of the entity before it entered the teleporter, it actually
// plays at the teleporter destination. So we just create a body double of the
// player at the departure side which stands still, plays the sound and lives
// for 1/10 of a second, then is removed. All these efforts were needed to get
// rid of that annoying 2/10 second delay in playing the teleporter sound.

			othercopy = spawn();
			setorigin(othercopy, other.origin);
			othercopy.nextthink = time + 0.1;
			othercopy.think = SUB_Remove;
			othercopy.touch = null;
			play_teleport(othercopy);
			spawn_tfog (other.origin, other);

			t = self.enemy;

// spawn a tfog flash in front of the destination
			makevectors (t.mangle);
			spawn_tfog (t.origin + 32 * v_forward, other);
			spawn_tdeath(t.origin, other);

// move the player
			setorigin (other, t.origin);
			other.oldorigin = other.origin;
			play_teleport(other);
			other.angles = t.mangle;

			if (other.frogbot)
			{
// other.angles holds crosshair position
				other.real_pitch = other.angles_x;
				other.real_yaw = other.angles_y;
			}
			else
				other.fixangle = TRUE;		// turn this way immediately		

			extra_velocity = v_forward * 300;
			other.oldvelocity = extra_velocity;

			other.velocity = extra_velocity;

			other.flags = other.flags & FL_NOT_ONGROUND;

			other.frogbot_nextthink = time;

			if (other.linked_marker == self)
				other.linked_marker = t;

			HazardTeleport();

			set_marker(other, t);
		}
	}
};

void() destination_touch =
{
	if (marker_time)
	{
		if (other.client_)
		{
			check_marker();

			test_enemy = world;
			while (test_enemy = find (test_enemy, target, self.targetname))
			{
				if (test_enemy.arrow_time < time + 0.7)
					test_enemy.arrow_time = time + 0.7;	// avoid telefrag
			}
		}
	}
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter. It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() GetSource =
{
	if (framecount < 2)
	{
		self.nextthink = 0.001;
		return;
	}

	// this does nothing, just serves as a target spot
		self.mangle = self.angles;
		self.angles = '0 0 0';
		self.model = "";
		self.origin = self.origin + '0 0 27';

		self.solid = SOLID_TRIGGER;
		self.touch = destination_touch;
		self.flags = FL_ITEM;
		BecomeMarker(self);
		setsize (self, '-65 -65 -24', '65 65 32');
		self.view_ofs = '80 80 24';
		self.pickup = pickup_true;
		adjust_view_ofs_z();
};

void() info_teleport_destination =
{
// put on save que
	AddToQue();

	self.nextthink = 0.001;
	self.think = GetSource;
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
*/
void() GetDest =
{
	if (framecount < 2)
	{
		self.nextthink = 0.001;
		return;
	}

	self.enemy = find (world, targetname, self.target);
};

void() trigger_teleport =
{
// put on save que
	AddToQue();

	if (self.targetname)
	{
		remove_self();
	}
	else
	{
		InitTrigger ();
		self.touch = teleport_touch;

		self.virtual_mins = self.mins + '-18 -18 -34';
		self.virtual_maxs = self.maxs + '18 18 26';
		setsize(self, self.mins + '-32 -32 0', self.maxs + '32 32 0');

		// find the destination 

		if (!(self.spawnflags & SILENT))
		{
			precache_sound ("ambience/hum1.wav");
			ambientsound ((self.mins + self.maxs) * 0.5, "ambience/hum1.wav",0.5 , ATTN_STATIC);
		}

		first_teleport = AddToList(first_teleport);

		self.view_ofs = 0.5 * (self.absmax - self.absmin);
		adjust_view_ofs_z();
		BecomeMarker(self);

		self.nextthink = 0.001;
		self.think = GetDest;
	}
};

/*
==============================================================================

trigger_setskill

==============================================================================
*/

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill =
{
// put on save que
	AddToQue();

	remove_self();
};


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered =
{
// put on save que
	AddToQue();

	SUB_DelayRemove();
};

//============================================================================

void() hurt_touch =
{
	if (other.takedamage)
	{
		if (time != self.frogbot_nextthink)
			if (time < self.fire_nextthink)
				return;
		deathtype = "";
		inflictor = self;
		attacker = self;
		targ = other;
		damage = self.dmg;
		T_Damage ();
		self.frogbot_nextthink = time;
		self.fire_nextthink = time + 1;
	}
};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
default dmg = 5
*/
void() trigger_hurt =
{
// put on save que
	AddToQue();
	self.netname = self.model;
	InitTrigger ();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 5;
};

//============================================================================

float PUSH_ONCE = 1;

void() trigger_push_touch =
{
	if (other.client_)
	{
		if (other.takedamage)
		{
			other.velocity = other.oldvelocity = self.speed * self.movedir * 10;
			if (other.fly_sound < time)
			{
				other.fly_sound = time + 1.5;
				msg_entity = other;
				sound (CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
			}
		}
	}
	else if (other.touch == GrenadeTouch)
		other.velocity = self.speed * self.movedir * 10;
};


/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE
Pushes the player
*/
void() trigger_push =
{
// put on save que
	AddToQue();

	if (self.spawnflags & PUSH_ONCE)
		remove_self();
	else
	{
		InitTrigger ();
		precache_sound ("ambience/windfly.wav");
		self.touch = trigger_push_touch;
		if (!self.speed)
			self.speed = 1000;
	}
};

//============================================================================

void() trigger_monsterjump = {remove_self();};
