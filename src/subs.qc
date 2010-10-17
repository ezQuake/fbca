/*
	subs.qc

	sub-functions, mostly movement related

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
*/

void() SUB_Remove = {remove_self();};

void() SUB_DelayRemove =
{
	self.nextthink = time + 0.2;
	self.think = SUB_Remove;
};

/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}	
	self.angles = '0 0 0';
};

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
// trigger angles are used for one-way touches. An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.modelindex = 0;
	self.model = "";
};

/*
============
SUB_CalcMove

============
*/
void(vector tdest, float tspeed) SUB_CalcMove =
{
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
	}
	else
	{
	// set tdest to the vector needed to move
		tdest = tdest - self.origin;
	
	// divide by speed to get time to reach dest
		traveltime = vlen (tdest) / tspeed;

		if (traveltime < 0.1)
		{
			self.velocity = '0 0 0';
			self.nextthink = self.ltime + 0.1;
		}
		else
		{
		// set nextthink to trigger a think when dest is reached
			self.nextthink = self.ltime + traveltime;

		// scale the destdelta vector by the time spent traveling to get velocity
			self.velocity = tdest * (1 / traveltime);	// qcc won't take vec/float	
		}
	}
};

/*
============
After moving, set origin to exact final destination
============
*/
void() SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.think1();
};

//=============================================================================

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove_self();
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void() SUB_UseTargets =
{
	local entity subs_self;
	local entity subs_target;

//
// check for a delay
//
	if (self.delay)
	{
	// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.killtarget = self.killtarget;
		t.target = self.target;
	}

//
// fire targets
//
	else if (self.target)
	{
		subs_self = self;
		subs_target = find (world, targetname, subs_self.target);
		while (subs_target)
		{
			self = subs_target;
			self.use ();
			subs_target = find (subs_target, targetname, subs_self.target);
		}
		self = subs_self;
	}
};
