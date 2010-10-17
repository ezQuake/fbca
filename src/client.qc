/*
	client.qc

	client functions

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
*/

// prototypes
void() W_SetCurrentAmmo;
void() W_WeaponFrame;
void() player_run;
void (vector org, entity death_owner) spawn_tdeath;
void(entity e) UpdateFrags;
void(string s) say;
void() SetScoreboard;
void() UpdateWeapons;
void() InvalidMap;
void() PrintRules;
void() WonTeam;
void (entity sndspot) play_teleport;
float(float remove_name) RemoveBot;
void() RemoveAllBots;
void() ToggleFramerate;
void(float value, string str) ToggleGameMode;
void() RemoveFromAllLists;
void() Add_client;
void() thud_touch;
void() ImpulseCommands;
void() SetAttribs;
void() PrintFramerate;
void() marker_touch;
void(entity client, entity marker) set_marker;
void() PlayerDie;
entity(entity first_in_list) RemoveFromList;
void() LoadPlayer;
void() PlayerPain;
void() set_suicide_frame;
void() adjust_view_ofs_z;
void() ResetGoalEntity;
void() ResetEnemy;
void() PredictSpot;
void(entity client) ClearLookObject;
void() CheckTwoTeams;
void(entity marker) RemoveMarker;
void(entity targ)say_ouchie;
void() FrogTreadWater;
void() FrogWaterMove;
void() BotWaterJumpFix;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw. 'pitch roll yaw'
*/
void() info_intermission = {};

void() SetChangeParms =
{
	parm2 = self.number_bots;
	parm3 = self.bot_skill;
	parm4 = self.teamcolor;
	parm5 = self.color_;
	parm6 = self.admin_code;
	parm7 = self.spawnbit0;
	parm8 = self.spawnbit1;
	parm9 = self.preferences;
	parm10 = self.skin0;
	parm11 = self.skin1;
	parm12 = self.skin2;
//	parm13
	parm15 = self.k_stuff;
};

void() SetNewParms =
{
	parm1 = 0;
	parm2 = -1;			// number_bots
	parm3 = skill;		// default skill
	parm4 = -1;			// initialise teamcolor later
	parm5 = -1;			// initialise color_ later
	parm6 = 0;
	parm7 = 0;			// spawnbit0
	parm8 = 0;			// spawnbit1
	parm9 = PREF_FLASH;			// default preferences PREF_FLASH
	parm10 = 0;			// default skin ""
	parm11 = 0;			//
	parm12 = 0;			//
//	parm13
	parm15 = 0;			// default aliases 0
};

/*
============
ResetItems

============
*/
void() ResetItems =
{
	ResetGoalEntity();
	ResetEnemy();
	DropRune();
	lose_artifact_invulnerability();
	lose_artifact_envirosuit();
	lose_artifact_invisibility();
	lose_artifact_super_damage();
};

void() NewItems =
{
	if (a_newitems())
		return;
	if (pre_game)
	{
		self.invincible_time = 1;
		self.ammo_nails = self.ammo_shells = self.ammo_rockets = self.ammo_cells = 1000;
		self.armorvalue = 1000;
		self.armortype = 0;
		self.items = available_weapons;
		self.invincible_finished = 1000000;
		self.health = 1000;
	}
	else if (deathmatch <= 3)
	{
		self.items = IT_AXE_SHOTGUN;
		self.armorvalue = self.ammo_nails = self.ammo_rockets = self.ammo_cells = self.armortype = 0;
		self.ammo_shells = 25;
		self.health = 100;
	}
	else
	{
		self.invincible_time = 1;
		self.armorvalue = 200;
		self.armortype = 0.8;
		self.items = available_weapons | IT_ARMOR3_INVULNERABILITY;
		self.invincible_finished = time + 3;
		self.effects = self.effects | EF_DIMLIGHT_RED;

		if (deathmatch == 4)
		{
			self.ammo_nails = self.ammo_shells = self.ammo_rockets = self.ammo_cells = 255;
			self.health = 250;
		}
		else if (deathmatch == 5)
		{
			self.ammo_nails = 80;
			self.ammo_shells = 30;
			self.ammo_rockets = 10;
			self.ammo_cells = 30;
			self.health = 200;
		}
		else // (if deathmatch == 6)
		{
			self.ammo_nails = 200;
			self.ammo_shells = 100;
			self.ammo_rockets = 30;
			self.ammo_cells = 50;
			self.health = 100;
		}
	}

	UpdateTotalDamage(self);
	self.weapon_refresh_time = 0;
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
void() FindIntermission =
{
// look for info_intermission first
	spawn_pos = find (world, classname, "info_intermission");
	// pick a random one
	rnd = random() * 4;
	while (rnd > 1)
	{
		spawn_pos = find (spawn_pos, classname, "info_intermission");
		if (!spawn_pos)
			spawn_pos = find (spawn_pos, classname, "info_intermission");
		rnd = rnd - 1;
	}
};

void() GotoNextMap =
{
	local string newmap;
	local float mq;

	// configurable map lists, see if the current map exists as a
	// serverinfo/localinfo var

	mq = stof(infokey(world, "ffa_mapqueue"));
	if (mq) newmap = rndffamap();
	else newmap = infokey(world, mapname); 

	if (newmap != "") changelevel (newmap);
	else changelevel (nextmap);
};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
	if (time < intermission_exittime)
		return;

	if (self.button0_ || self.button1 || self.button2_)
		GotoNextMap();
};

void() execute_changelevel =
{
	intermission_running = 1;

	if (game_not_match && !game_arena)
		intermission_getting_closer = 0;

	if (!game_not_match)
	{
		localcmd("serverinfo status Standby\n");
		lightstyle(0, "g");
	}

	remove(prephysics);
	remove(postphysics);

// enforce a wait time before allowing changelevel
	intermission_exittime = time + 5;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);

	FindIntermission ();

	self = first_client;
	while (self)
	{
		self.takedamage = self.solid = self.movetype = self.nextthink = self.view_ofs_z = 0;
		self.model = "";
		self = self.next;
	}

	WriteByte (MSG_ALL, SVC_INTERMISSION);
	WriteCoord (MSG_ALL, spawn_pos.origin_x);
	WriteCoord (MSG_ALL, spawn_pos.origin_y);
	WriteCoord (MSG_ALL, spawn_pos.origin_z);
	WriteAngle (MSG_ALL, spawn_pos.mangle_x);
	WriteAngle (MSG_ALL, spawn_pos.mangle_y);
	WriteAngle (MSG_ALL, spawn_pos.mangle_z);
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable. Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() check_trigger =
{
	if (framecount < 2)
	{
		self.nextthink = 0.001;
		return;
	}

	targ_centre = (self.absmin + self.absmax) * 0.5;
	SUB_DelayRemove();
	self = first_teleport;
	while (self)
	{
		if (vlen(targ_centre - (self.absmin + self.absmax) * 0.5) <= 128)
		{
			first_teleport = RemoveFromList(first_teleport);
			SUB_DelayRemove();
			RemoveMarker(self);
		}

		self = self.next;
	}
};

void() trigger_changelevel =
{
// put on save que
	AddToQue();

	InitTrigger ();
	self.nextthink = 0.001;
	self.think = check_trigger;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

// called by ClientKill and PlayerDeathThink
void() respawn =
{
	// make a copy of the dead body for appearances sake
	CopyToBodyQue ();

	// respawn		
	PutClientInServer ();
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	if (self.takedamage)
	{
		if ((time < self.suicide_time + 5) && stof(infokey(world, "k_kfp"))) {
			if (self.player)
				sprint_fb(self, 2, "œÓÏ˘ ÔÓÂ ÛıÈ„È‰Â ÈÓ µ ÛÂ„ÔÓ‰Û\n");
			return;
		}
		self.suicide_time = time;
		ResetItems ();
		bprint_fb(1, self.netname);
		bprint_fb(1, " suicides\n");
		if (!pre_game) {
			self.frags = self.frags - 2;	// extra penalty
			UpdateFrags (self);
		}
		set_suicide_frame ();
		respawn ();
	}
};

/*
============
ForceGib

============
*/
void() ForceGib =
{
	if (self.takedamage)
	{
		lose_artifact_invulnerability();

		inflictor = attacker = world;
		targ = self;
		damage = 50000;
		deathtype = "forcegib";
		T_Damage ();
	}

	self.frags = 0;
	UpdateFrags (self);
};

/*
============
ChangeTeam

============
*/
void() ChangeTeam =
{
	if (self.client_)
	{
		if (pre_game)
			return;
		ForceGib();
		bprint_fb(2, self.netname);
		bprint_fb(2, " changed team\n");
		CheckTwoTeams();
	}
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
void() SelectSpawnPoint =
{
	set_a_spawn();
	spots = world;

// choose a info_player_deathmatch point
// ok, find all spots that don't have players nearby

	spawn_pos = world;
	while (spawn_pos = find (spawn_pos, classname, a_spawn))
	{
		if (spawn_pos != previous_spot)
		{
			pcount = FALSE;
			totalspots = totalspots + 1;

			thing = first_client;
			while (thing)
			{
				if (thing.takedamage)
					if (vlen(thing.origin - spawn_pos.origin) <= 84)
						pcount = TRUE;
				thing = thing.next;
			}
			if (!pcount)
			{
				spawn_pos.goalentity = spots;
				spots = spawn_pos;
				numspots = numspots + 1;
			}
		}
	}

	if (numspots)
	{
		numspots = floor(random() * numspots);

		spawn_pos = spots;
		while (numspots > 0)
		{
			spawn_pos = spawn_pos.goalentity;
			numspots = numspots - 1;
		}
	}
	else
	{
		// ack, they are all full, just pick one at random
		totalspots = random() * totalspots;
		totalspots = floor(totalspots);
		spawn_pos = find (world, classname, a_spawn);
		while (totalspots) {
			if (spawn_pos != previous_spot)
				totalspots = totalspots - 1;
			spawn_pos = find (spawn_pos, classname, a_spawn);
		}
	}

	previous_spot = spawn_pos;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() PutClientInServer_apply =
{
	if (putselfinserver())
		return;
	if (self.player)
		self.fixangle = TRUE;		// turn this way immediately

	if (!( invalid_map || markers_loaded ))
	{
		self.health = 1;
		self.nextthink = 0.001;
		return;
	}
	if (!game_qizmo || self.player)
		self.model = "/";
	self.v_angle = self.angles;
	self.flags = 0;

	if (self.player)
	{
		self.movetype = MOVETYPE_WALK;
	}
	else
	{
		self.movetype = MOVETYPE_STEP;
		self.oldwaterlevel = self.oldwatertype = 0;
	}

	if (self.frogbot)
	{
	// self.angles holds crosshair position
		self.real_pitch = self.angles_x;
		self.real_yaw = self.angles_y;
	}

	self.state = 0;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.air_finished = time_12;
	self.dmg = 2;	// initial water damage

	self.weapon = IT_SHOTGUN;

	NewItems();

	W_SetCurrentAmmo ();

	self.th_die = PlayerDie;
	self.th_pain = PlayerPain;
	self.attack_finished = 0;

	set_marker(self, spawn_pos);

	self.arrow = 0;
	ClearLookObject(self);

	self.oldvelocity = self.velocity = '0 0 0';
	self.deadflag = DEAD_NO;
	self.jump_flag = 0;

	makevectors(self.angles);
	play_teleport(self);
	spawn_tfog (self.origin + (v_forward * 20), self);
	spawn_tdeath (self.origin, self);

	self.goal_refresh_time = 0;
	self.allowedMakeNoise = TRUE;	// FIXME: calculate this

	self.spawn_frag_time = time + 1; // New
};

void() PutClientInServer =
{
	SelectSpawnPoint ();
//team
	if (self.player && pre_game && !game_arena && !game_not_match && !self.ready && teamplay && !counting_down)
		self.effects = EF_BLUE;
	else 
		self.effects = 0;

	if (!game_not_match && !game_arena && !counting_down)
		lightstyle(0, "m");
//team

	self.modelindex = modelindex_player;
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	setorigin(self, spawn_pos.origin + '0 0 1');
	self.oldorigin = self.origin;
	self.view_ofs_z = 22;
	self.angles = spawn_pos.angles;
	self.think = PutClientInServer_apply;
	PutClientInServer_apply();
};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
	remove_self();
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
	remove_self();
};

/*
saved out by quaked in region mode
*/
void() testplayerstart = {remove_self();};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
// put on save que
	AddToQue();

	self.solid = SOLID_TRIGGER;
	self.touch = marker_touch;
	self.flags = FL_ITEM;
	BecomeMarker(self);
	setsize (self, '-65 -65 -24', '65 65 32');
	self.view_ofs = '80 80 24';
	self.pickup = pickup_true;
	adjust_view_ofs_z();

	if (game_enable_runes)
	{
		precache_model ("progs/end1.mdl");
		precache_model ("progs/end2.mdl");
		precache_model ("progs/end3.mdl");
		precache_model ("progs/end4.mdl");
		precache_sound("boss1/sight1.wav");
		precache_sound("items/r_item1.wav");
		precache_sound("items/damage3.wav");
		precache_sound("items/protect3.wav");
	}
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
	remove_self();
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/

void() NextLevel =
{
	local entity p;
	local float k_overtime, k_exttime, p1scores, p2scores, plfound;

	if (gameover)
		return;
	if (game_not_match && !game_arena) {
		intermission_getting_closer = 1;
		real_time = 0;
		p = find(world, classname, "timer");
		if(p != world) remove(p);
	} 

	if (duel_mode) {
		p = find(world, stringname, "gamer");
		while(p != world) {
			if (!plfound) {
				p1scores = p.frags;
				plfound = 1;					
			} else {
				p2scores = p.frags;
			}
			p = find(p, stringname, "gamer");
		}
		if (p1scores == p2scores) overtime_begun = 1;
		else overtime_begun = 0;
	}

	if (team_mode) {
		teams_frags_count();
		if (k_scores1 == k_scores2) overtime_begun = 1;
		else overtime_begun = 0;
	}

	k_overtime = stof(infokey(world, "k_overtime"));
	k_exttime = stof(infokey(world, "k_exttime"));

	if (k_overtime && !game_arena && !break_match) {
		if ((timelimit) && (real_time >= timelimit_user)) {
			if (overtime_begun) {
				if (sudden_death) return;
				else bprint_fb(3, "Time over, the game is a draw\n");
				if (duel_mode) {
					overtime_stats = 1;
					p = find(world, stringname, "gamer");
					while(p != world) {
						p.t_health = p.health;
						p.t_armortype = p.armortype;
						p.t_armorvalue = p.armorvalue;
						p = find(p, stringname, "gamer");
					}
				}
				if (k_overtime == 1) {
					// Ok its increase time
					timelimit_user = timelimit_user + k_exttime;
					bprint_fb(2, "ê");
					bprint_g(2, k_exttime);
					bprint_fb(2, "ë minute");
					if (k_exttime != 1) bprint_fb(2, "'s");
					bprint_fb(2, " overtime follows\n");
					return;
				} else {
					bprint_fb(2, "Sudden death ÔˆÂÚÙÈÌÂ ‚ÂÁÈÓÛ\n");
					sudden_death = 1;
					return;
				}
			}
		}
	}

	think_ent = spawn();
	if (!game_not_match && !game_arena) explode_all();
	gameover = TRUE;
	think_ent.think = execute_changelevel;
	think_ent.nextthink = 0.001;
};

//============================================================================

void() PlayerDeathThink =
{
	if (self.frogbot)
	{
		self.button0_ = FALSE;
		if (random() < 0.5)
			self.button2_ = FALSE;
		else
			self.button2_ = TRUE;
	}
	if (self.flags & FL_ONGROUND)
	{
		forward = vlen (self.velocity) - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

	if (time >= self.dead_time)
		respawn();
	else
	{
	// wait for all buttons released
		if (self.deadflag == DEAD_DEAD)
		{
			if (self.button2_ || self.button1 || self.button0_)
				return;
			self.deadflag = DEAD_RESPAWNABLE;
		}
		else
		{
		// wait for any button down
			if (self.button2_ || self.button1 || self.button0_)
				respawn();
		}
	}
};

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink_apply =
{
	if (a_prethink())
		return;

//
// WaterMove
//

	if (self.waterlevel)
	{
		if (k_standby) return;

		if (self.waterlevel != 3)
		{
			BotWaterJumpFix();
			if (self.air_finished < time + 9)
			{
				msg_entity = self;
				if (self.air_finished < time)
					sound (CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
				else
					sound (CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
			}
			self.air_finished = time_12;
			self.dmg = 2;

			if (!self.player)
			if (self.waterlevel == 2)
			{
			//
			// CheckWaterJump
			//
				FrogTreadWater();

			// check for a jump-out-of-water
				makevectors (self.v_angle);
				start = self.origin;
				start_z = start_z + 8; 
				v_forward_z = 0;
				v_forward = normalize(v_forward) * 24;
				end = start + v_forward;
				traceline (start, end, TRUE, self);
				if (trace_fraction < 1)
				{	// solid at waist
					start_z = self.origin_z + self.maxs_z;
					end = start + v_forward;
					self.movedir = trace_plane_normal * -50;
					traceline (start, end, TRUE, self);
					if (trace_fraction == 1)
					{	// open at eye level
						self.flags = (self.flags | FL_WATERJUMP) & FL_NOT_JUMPRELEASED;
						self.velocity_z = 225;
						self.teleport_time = time + 2;	// safety net
					}
				}
			}
		}
		else if (self.air_finished < time)
		{	// drown!
			if (self.pain_finished < time)
			{
				self.pain_finished = time + 1;
				self.dmg = self.dmg + 2;
				if (self.dmg > 15)
					self.dmg = 10;
				deathtype = "";
				inflictor = world;
				attacker = world;
				targ = self;
				damage = self.dmg;
				T_Damage ();
				if (self.deadflag)
					return;
			}
		}
		FrogWaterMove (); 
		if (self.dmgtime < time)
		{
			if (self.watertype == CONTENT_LAVA)
			{	// do damage
				if (self.radsuit_finished <= time)
					self.dmgtime = time + 0.2;
				else
					self.dmgtime = time + 1;

				deathtype = "";
				inflictor = world;
				attacker = world;
				targ = self;
				damage = 10 * self.waterlevel;
				T_Damage ();
				if (self.deadflag)
					return;
			}
			else if (self.watertype == CONTENT_SLIME)
			{	// do damage
				if (self.radsuit_finished <= time)
				{
					self.dmgtime = time + 1;
					deathtype = "";
					inflictor = world;
					attacker = world;
					targ = self;
					damage = 4 * self.waterlevel;
					T_Damage ();
					if (self.deadflag)
						return;
				}
			}
		}

		if (!(self.flags & FL_INWATER))
		{
		// player enter water sound
			msg_entity = self;
			if (self.watertype == CONTENT_WATER)
				sound (CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
			else if (self.watertype == CONTENT_LAVA)
				sound (CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
			else if (self.watertype == CONTENT_SLIME)
				sound (CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

			self.flags = self.flags | FL_INWATER;
			self.dmgtime = 0;
		}

		if (!self.player)
		if (!(self.flags & FL_WATERJUMP))
				self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
	}
	else
	{
		if (self.flags & FL_INWATER)
		{	
			// play leave water sound
			msg_entity = self;
			sound (CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		self.air_finished = time_12;
	}

	if (self.button2_)
	{
	//
	// PlayerJump
	//
		if (!(self.flags & FL_WATERJUMP))
		{
			if (self.waterlevel >= 2)
			{
				if (!self.player)
				{
					if (self.watertype == CONTENT_WATER)
						self.velocity_z = 100;
					else if (self.watertype == CONTENT_SLIME)
						self.velocity_z = 80;
					else
						self.velocity_z = 50;
				}

		// play swiming sound
				if (self.swim_flag < time)
				{
					self.swim_flag = time + 1;
					msg_entity = self;
					if (random() < 0.5)
						sound (CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
					else
						sound (CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
				}
			}
			else
			{
				if (self.flags & FL_ONGROUND)
				{
					if (self.flags & FL_JUMPRELEASED)		// don't pogo stick
					{
						a_jumpfix();
						self.flags = self.flags - FL_JUMPRELEASED;

						if (!self.player)
							self.flags = self.flags - FL_ONGROUND;	// don't stairwalk

					// player jumping sound
						msg_entity = self;
						sound (CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);

						if (!self.player)
							self.velocity_z = self.velocity_z + JUMPSPEED;

					}
				}
			}
		}
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;

	self.oldvelocity = self.velocity;

// clear touch marker
	self.touch_distance = 1000000;
};

void() PlayerPreThink =
{

	self.button0_ = self.button0;
	self.button2_ = self.button2;

	if (a_prethink())
		return;

	if (self.takedamage)
	{
		PlayerPreThink_apply();

		if (self.flags & FL_ONGROUND)
		{
			if (self.velocity_z < 0)
				self.oldvelocity_z = 0;
		}
		else
			self.jump_flag = self.velocity_z;
	}
	else
	{
		if (intermission_running)
			IntermissionThink ();	// otherwise a button could be missed between the think tics
		else if (self.deadflag >= DEAD_DEAD)
			PlayerDeathThink();
	}
};

/*
================
PlayerPostThink

Called every frame after physics are run
================
*/

void() CheckLand =
{
	if (self.jump_flag < -300)
	{
		msg_entity = self;
		if (self.watertype == CONTENT_WATER)
			sound (CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			deathtype = "falling";
			inflictor = world;
			attacker = world;
			targ = self;
			damage = 5;
			T_Damage ();
			sound (CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			if (self.deadflag)
				return;
		}
		else
			sound (CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
	}
	self.jump_flag = 0;
};

void() PlayerPostThink_apply =
{
	if (a_postthink())
		return;

//
// CheckPowerups
//


// RUNE: If player has rune of elder magic (4), regeneration
	if (self.player_flag & ITEM_RUNE4_FLAG)
	{
		if (self.regen_time < time)
		{
			self.regen_time = time;
			if (self.health < 150)
			{
				self.health = self.health + 5;
				if (self.health > 150)
					self.health = 150;
				UpdateTotalDamage(self);
				self.regen_time = self.regen_time + 0.5;
				RegenerationSound();
			}
			if (self.armorvalue < 150)
			{
				if (self.armortype)
				{
					self.armorvalue = self.armorvalue + 5;
					if (self.armorvalue > 150)
						self.armorvalue = 150;
					UpdateTotalDamage(self);
					self.regen_time = self.regen_time + 0.5;
					RegenerationSound();
				}
			}
		}
	}
// RUNE

	if (self.items & IT_POWERUP)
	{
	// invisibility
		if (self.invisible_finished)
		{
	// sound and screen flash when items starts to run out
			if (self.invisible_sound < time)
			{
				msg_entity = self;
				sound (CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
				self.invisible_sound = time + ((random() * 3) + 1);
			}

			if (self.invisible_finished < time + 3)
			{
				if (self.invisible_time < time)
				{
					msg_entity = self;
					if (self.invisible_time == 1)
					{
						sprint_fb(self, 2, "Ring of Shadows magic is fading\n");
						sound (CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
					}
					bf();
					self.invisible_time = time + 1;
				}

				if (self.invisible_finished < time)		// just stopped
				{
					lose_artifact_invisibility();
					W_SetCurrentAmmo();
					teamreport2(self, 16);
				}
			}
		}

	// invincibility
		if (self.invincible_finished)
		{
	// sound and screen flash when items starts to run out
			if (self.invincible_finished < time + 3)
			{
				if (self.invincible_time < time)
				{
					msg_entity = self;
					if (self.invincible_time == 1)
					{
						sprint_fb(self, 2, "Protection is almost burned out\n");
						sound (CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);

					}
					bf();
					self.invincible_time = time + 1;
				}

				if (self.invincible_finished < time) {	// just stopped
					lose_artifact_invulnerability();
					teamreport2(self, 15); 
				}
			}
		}

	// super damage
		if (self.super_damage_finished)
		{
	// sound and screen flash when items starts to run out
			if (self.super_damage_finished < time + 3)
			{
				if (self.super_time < time)
				{
					msg_entity = self;
					if (self.super_time == 1)
					{
						if (quad_factor == 8)
							sprint_fb(self, 2, "OctaPower is wearing off\n");
						else
							sprint_fb(self, 2, "Quad Damage is wearing off\n");
						sound (CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);

					}
					bf();
					self.super_time = time + 1;
				}

				if (self.super_damage_finished < time)	// just stopped
				{
					lose_artifact_super_damage();
					teamreport2(self, 14); 
					if (deathmatch == 4)
					{
						if (self.health > 100) self.health = 100; // rxr
						self.ammo_cells = 255;
						self.armorvalue = 1;
						self.armortype = 0.8;
					}
				}
			}
		}	

	// suit	
		if (self.radsuit_finished)
		{
			self.air_finished = time_12;		// don't drown

	// sound and screen flash when items starts to run out
			if (self.radsuit_finished < time + 3)
			{
				if (self.rad_time < time)
				{
					msg_entity = self;
					if (self.rad_time == 1)
					{
						sprint_fb(self, 2, "Air supply in Biosuit expiring\n");
						sound (CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
					}
					bf();
					self.rad_time = time + 1;
				}

				if (self.radsuit_finished < time)	// just stopped
					lose_artifact_envirosuit();
			}
		}
	}

//
// end CheckPowerups
//


	ThinkTime();

// do weapon stuff

	if (time >= self.attack_finished)
	{
		if (!self.currentammo)
		{
			if (self.weapon != IT_AXE)
			{
				self.weapon = W_BestWeapon ();
				W_SetCurrentAmmo ();
			}
		}

	// impulse commands
		if (self.player)
		if (self.frogbot)
		if (!self.botchose)
			self.impulse = 0;

		if (self.impulse)
		{
			if (!self.spawnflags)
			{
				impulse_ = self.impulse;
				self.impulse = 0;
				if (impulse_ <= 12)
				{
					if (impulse_ <= 9)
						W_ChangeWeapon ();
					else if (impulse_ == 10)
						CycleWeaponCommand ();
					else if (impulse_ == 11)
					{
						ClientKill();
						return;
					}
					else // if (impulse_ == 12)
						CycleWeaponReverseCommand ();
				}
				self.botchose = 0;
			}
		}
	
	// check for attack
		if ((!game_arena) || (arenastate == A_PLAYING))
		if (self.button0_)
		{
			W_WeaponFrame ();
		}
	}

	if (self.frogbot)
	{
	// pitch
		pitchspeed_ = self.pitchspeed + self.pitchaccel * frametime;
		if (pitchspeed_ > 0)
		{
			pitchspeed_ = pitchspeed_ - mouse_friction;
			if (pitchspeed_ < 0)
				pitchspeed_ = 0;
		}
		else
		{
			pitchspeed_ = pitchspeed_ + mouse_friction;
			if (pitchspeed_ > 0)
				pitchspeed_ = 0;
		}

		total_pitchspeed = pitchspeed_ + self.track_pitchspeed;
		if (total_pitchspeed > 450)
		{
			total_pitchspeed = 450;
			if (pitchspeed_ > 450)
				pitchspeed_ = 450;
		}
		else if (total_pitchspeed < -450)
		{
			total_pitchspeed = -450;
			if (pitchspeed_ < -450)
				pitchspeed_ = -450;
		}

		self.pitchspeed = pitchspeed_;

		real_pitch_ = self.real_pitch + total_pitchspeed * frametime;

		if (real_pitch_ > 78.75)
			real_pitch_ = 78.75;
		else if (real_pitch_ < -71.71875)
			real_pitch_ = -71.71875;

		new_pitch = (rint(real_pitch_ / 1.40625)) * 1.40625;
		self.real_pitch = real_pitch_;

		a_rocketjump();

	// yaw
		yawspeed_ = self.yawspeed + self.yawaccel * frametime;
		if (yawspeed_ > 0)
		{
			yawspeed_ = yawspeed_ - mouse_friction;
			if (yawspeed_ < 0)
				yawspeed_ = 0;
		}
		else
		{
			yawspeed_ = yawspeed_ + mouse_friction;
			if (yawspeed_ > 0)
				yawspeed_ = 0;
		}

		total_yawspeed = yawspeed_ + self.track_yawspeed;
		if (fabs(total_yawspeed) > self.stop_turn_speed)
		{
			self.arrow = 0;
			self.arrow_time = time + frametime;
			if (total_yawspeed > 540)
			{
				total_yawspeed = 540;
				if (yawspeed_ > 540)
					yawspeed_ = 540;
			}
			else if (total_yawspeed < -540)
			{
				total_yawspeed = -540;
				if (yawspeed_ < -540)
					yawspeed_ = -540;
			}
		}

		self.yawspeed = yawspeed_;

		real_yaw_ = self.real_yaw + total_yawspeed * frametime;

		if (real_yaw_ >= 180)
			real_yaw_ = real_yaw_ - 360;
		else if (real_yaw_ < -180)
			real_yaw_ = real_yaw_ + 360;
		self.v_angle_y = self.angles_y = (rint(real_yaw_ / 1.40625)) * 1.40625;
		self.real_yaw = real_yaw_;


	// self.angles holds crosshair position
		if (new_pitch < 0)
		{
			if (new_pitch < -2.8125)
				new_pitch = new_pitch + 2.8125;	// crosshair
			else
				new_pitch = 0;
		}

		self.v_angle_x = new_pitch * -1;
		SetViewAngle(self, self.v_angle);
	}
};

void() PlayerPostThink =
{
	ImpulseCommands();

	if (self.player && !self.k_stuff)
		StuffAliases();

	if (pre_game)
	{
		if (self.player && self.kf_speed)
			show_speed(self);
	}

	if (a_postthink())
		return;

	if (self.print_framerate)
		PrintFramerate();

	if (!game_arena)
	if (teamplay)
	{
		self.team = stof(infokey(self, "bottomcolor")) + 1;

		if (self.realteam != self.team)
		{
			self.realteam = self.team;
			ChangeTeam();
			return;
		}
	}
	if (self.takedamage)
	{
	// check to see if player landed and play landing sound
		if (self.jump_flag)
		if (self.flags & FL_ONGROUND)
			CheckLand();

		PlayerPostThink_apply();
	}
};

/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() LoadPlayer_apply =
{
	self.nextthink = time + 0.1;
	if (self.wait == framecount)
		return;
	self.wait = framecount;
	other = self;
	self = self.owner;

	if ((other.state * SPAWN_SIZE) < maxplayers)
	{
		SetScoreboard();
		other.state = other.state + 1;
	}
	else
	{
		if (game_show_rules)
		{
			msg_entity = self;
			if (invalid_map)
				InvalidMap();
		}
		remove(other);
	}
};

void() LoadPlayer =
{
	local entity print_entity;

	print_entity = spawn();
	print_entity.nextthink = 0.001;
	print_entity.think = LoadPlayer_apply;
	print_entity.owner = self;
	print_entity.wait = framecount;
	print_entity.enemy = first_frogbot;
};

void() goal_client =
{
	if (time < virtual_enemy.invisible_finished)
	enemy_desire = 0;	// can't see so how chase?
	else if (time < virtual_enemy.invincible_finished)
	enemy_desire = 0;	// invincible
	else if (enemy_ == look_object_)
	enemy_desire = ((self.total_damage + 100) * self.firepower - virtual_enemy.total_damage * virtual_enemy.firepower) * 0.01;
	else if (enemy_defenceless())
	enemy_desire = ((self.total_damage + 120) * self.firepower - virtual_enemy.total_damage * virtual_enemy.firepower) * 0.01;
	else
	enemy_desire = (self.total_damage * self.firepower - virtual_enemy.total_damage * virtual_enemy.firepower) * 0.01;
};

void() goal_client6 =
{
	if (game_arena)
		a_goal_client6();
	else
	{
	if (time < virtual_enemy.invisible_finished)
		enemy_desire = 0;	// can't see so how chase?
	else if (time < virtual_enemy.invincible_finished)
		enemy_desire = 0;	// invincible
	else
		enemy_desire = (300 - virtual_enemy.total_damage);
	}
};

void() ClientConnect_apply =
{
	bprint_fb(2, self.netname);
	bprint_fb(2, " entered the game\n");

	Add_client();

	if (deathmatch <= 3)
		self.desire = goal_client;
	else
		self.desire = goal_client6;

	self.T = UNREACHABLE;	// don't jump onto/at other clients

// a client connecting during an intermission can cause problems
	if (intermission_running)
		GotoNextMap();

	if (!game_not_match)
		MatchMode();
};

void() ClientConnect =
{
	if (scoreboardsize >= maxplayers)
		RemoveBot(FALSE);

	self.classname = "player";
	self.stringname = "gamer";
	scoreboardsize = scoreboardsize + 1;
	numberofplayers = numberofplayers + 1;
	self.team = stof(infokey(self, "bottomcolor")) + 1;
	self.flags = parm1;
	self.player = TRUE;
	self.number_bots = parm2;
	self.bot_skill = parm3;

	if (parm4 >= 0)
		self.teamcolor = parm4;
	else
		self.teamcolor = (self.team - 1) * 17;

	if (parm5 >= 0)
		self.color_ = parm5;
	else
		self.color_ = (self.team - 1) * 17;

	if (self == nextent(world))
		self.admin_code = dropper.admin_code;
	else
		self.admin_code = parm6;

	self.spawnbit0 = parm7;
	self.spawnbit1 = parm8;
	self.preferences = parm9;
	self.skin0 = parm10;
	self.skin1 = parm11;
	self.skin2 = parm12;
	self.k_stuff = parm15; 

	if ((!game_not_match) && (match_in_progress || counting_down) && (lock))
	{
		sprint_fb(self, 2, "Õ·Ù„Ë in progress, server locked.\n");
		sprint_fb(self, 2, "Please reconnect as spectator.\n");
		self.kick = 1;
		stuffcmd_apply(self, "wait;wait;wait;wait;wait\n");
		stuffcmd_apply(self, "disconnect\n");
		remove(self);
		return;
	}

	self.kick = 0;

// ParboiL
	if (!game_arena) 
		MakeMOTD();

	if (!self.k_stuff)
		AliasesTime();
// ParboiL

	ClientConnect_apply();
	self.lookahead_time = 30;
	self.prediction_error = 0;

	LoadPlayer();
};

/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	if (self.player)
	{
		scoreboardsize = scoreboardsize - 1;
		numberofplayers = numberofplayers - 1;
	}
	if (self.kick == 0)
	{
		if (!gameover)
		{
			if (self.client_)
			{
				ResetItems();
				bprint_fb(2, self.netname);
				bprint_fb(2, " left the game with ");
				bprint_ftos(2, self.frags);
				bprint_fb(2, " frags\n");
				msg_entity = self;
				sound (CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
				set_suicide_frame ();
				// make a copy of the dead body for appearances sake
				CopyToBodyQue ();
			}
			else
			{
				bprint_fb(2, self.netname);
				bprint_fb(2, " left the game\n");
			}
		}

		RemoveFromAllLists();
		selfdisconnect();
	}

	self.classname = "";
	self.stringname = "";

	if (!game_not_match)
		MatchMode();
};

/*
===========
ClientObituary

called when a player dies
============
*/
void() ClientObituary =
{
	rnd = random();

	if (self.client_)
	{
		if (deathtype == "selfwater")
		{
			bprint_fb(1, self.netname);
			bprint_fb(1, " electrocutes himself.\n");
			self.frags = self.frags - 1;
			UpdateFrags (self);
		}
		else if (deathtype == "teledeath")
		{
			if (attacker.owner.realteam == self.realteam) 
			{
				bprint_fb(1, self.netname);
				bprint_fb(1, " was telefragged by his teammate\n");
				self.deaths = self.deaths + 1; // New
				if (!game_disable_botchat)
					say_ouchie(targ);
			}
			else
			{
				bprint_fb(1, self.netname);
				bprint_fb(1, " was telefragged by ");
				bprint_fb(1, attacker.owner.netname);
				bprint_fb(1, "\n");
				attacker.owner.frags = attacker.owner.frags + 1;
				self.deaths = self.deaths + 1; // New
			}
			UpdateFrags (attacker.owner);
		}
		else if (deathtype == "teledeath2")
		{
			bprint_fb(1, "Satan's power deflects ");
			bprint_fb(1, self.netname);
			bprint_fb(1, "'s telefrag\n");
			self.frags = self.frags - 1;
			UpdateFrags (self);
		}
		else if (deathtype == "teledeath3") 
		{
			bprint_fb(1, self.netname);
			bprint_fb(1, " was telefragged by ");
			bprint_fb(1, attacker.owner.netname);
			bprint_fb(1, "'s Satan's power\n");			
			self.frags = self.frags - 1;
			UpdateFrags (self);
		}
		else if (deathtype == "squish")
		{
			if (self.realteam == attacker.realteam && teamplay && self != attacker)
			{
				attacker.frags = attacker.frags - 1;
				attacker.friendly = attacker.friendly + 1;
				UpdateFrags (attacker);
				bprint_fb(1, attacker.netname);
				bprint_fb(1, " squished a teammate\n");
				if (!game_disable_botchat)
					say_ouchie(targ);
			}
			else if ((attacker.client_) && attacker != self)
			{

				bprint_fb(1, attacker.netname);
				bprint_fb(1, " squishes ");
				bprint_fb(1, self.netname);
				bprint_fb(1, "\n");
				attacker.frags = attacker.frags + 1;
				self.deaths = self.deaths + 1;	// New
				UpdateFrags (attacker);
			}
			else
			{
				self.frags = self.frags - 1;	// killed self
				UpdateFrags (self);
				bprint_fb(1, self.netname);
				bprint_fb(1, " was squished\n");
			}
		}
		else if (attacker.client_)
		{
			if (self == attacker)
			{
				// killed self
				attacker.frags = attacker.frags - 1; 
				UpdateFrags (self);
				bprint_fb(1, self.netname);
				if (deathtype == "grenade")
					bprint_fb(1, " tries to put the pin back in\n");
				else if (deathtype == "rocket")
					bprint_fb(1, " becomes bored with life\n");
				else if (self.weapon == 64 && self.waterlevel > 1)
				{
					if (self.watertype == CONTENT_SLIME)
						bprint_fb(1, " discharges into the slime\n");
					else if (self.watertype == CONTENT_LAVA)
						bprint_fb(1, " discharges into the lava\n");
					else
						bprint_fb(1, " discharges into the water.\n");
				}
				else
					bprint_fb(1, " becomes bored with life\n");
			}
			else if ((healthplay == TEAM_FRAG_PENALTY) && (self.realteam == attacker.realteam) &&
				(teamplay))
			{
				if (rnd < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnd < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnd < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint_fb(1, attacker.netname);
				bprint_fb(1, deathstring);
				attacker.frags = attacker.frags - 1;
				attacker.friendly = attacker.friendly + 1;
				UpdateFrags (attacker);
				if (!game_disable_botchat)
					say_ouchie(targ);
			}
			else
			{
				if (!game_damage)
				{
					attacker.frags = attacker.frags + 1;
					self.deaths = self.deaths + 1; // New
					if (self.spawn_frag_time > time) 
						attacker.s_frags = attacker.s_frags + 1; // New
					UpdateFrags (attacker);
				}
				if (deathtype == "shell")
				{
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}
				else if (deathtype == "rocket")
				{
					if (attacker.super_damage_finished > 0 && self.health < -40)
					{
						if (rnd < 0.3)
							deathstring = " was brutalized by ";
						else if (rnd < 0.6)
							deathstring = " was smeared by ";
						else
						{
							bprint_fb(1, attacker.netname);
							bprint_fb(1, " rips ");
							bprint_fb(1, self.netname);
							bprint_fb(1, " a new one\n");
							return;
						}
						if (quad_factor == 4)
							deathstring2 = "'s quad rocket\n";
						else
							deathstring2 = "'s octa rocket\n";
					}
					else
					{
						deathstring = " rides ";
						deathstring2 = "'s rocket\n";
						if (self.health < -40)
						{
							deathstring = " was gibbed by ";
							deathstring2 = "'s rocket\n" ;
						}
					}
				}
				else if (deathtype == "cell")
				{
					deathstring = " accepts ";
					if (attacker.waterlevel > 1)
						deathstring2 = "'s discharge\n";
					else
						deathstring2 = "'s shaft\n";
				}
				else if (deathtype == "grenade")
				{
					deathstring = " eats ";
					deathstring2 = "'s pineapple\n";
					if (self.health < -40)
					{
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}
				else if (deathtype == "supershell")
				{
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}
				else
				{
					if (deathtype == "supernail")
						deathstring = " was punctured by ";
					else if (deathtype == "nail")
						deathstring = " was nailed by ";
					else if (deathtype == "axe")
						deathstring = " was ax-murdered by ";
					deathstring2 = "\n";
				}
				bprint_fb(1, self.netname);
				bprint_fb(1, deathstring);
				bprint_fb(1, attacker.netname);
				bprint_fb(1, deathstring2);
			}
		}
		else
		{
			if (deathtype != "forcegib")
			{
				self.frags = self.frags - 1;	// killed self
				UpdateFrags (self);
				bprint_fb(1, self.netname);
				if (self.watertype == -3)
				{
					if (random() < 0.5)
						bprint_fb(1, " sleeps with the fishes\n");
					else
						bprint_fb(1, " sucks it down\n");
				}
				else if (self.watertype == -4)
				{
					if (random() < 0.5)
						bprint_fb(1, " gulped a load of slime\n");
					else
						bprint_fb(1, " can't exist on slime alone\n");
				}
				else if (self.watertype == -5)
				{
					if (self.health < -15)
						bprint_fb(1, " burst into flames\n");
					else
					{
						if (random() < 0.5)
							bprint_fb(1, " turned into hot slag\n");
						else
							bprint_fb(1, " visits the Volcano God\n");
					}
					if (!game_disable_botchat)
						say_ouchie(targ);
				}
				else if (deathtype == "falling")
					bprint_fb(1, " fell to his death\n");
				else if (deathtype == "nail" || deathtype == "supernail")
					bprint_fb(1, " was spiked\n");
				else if (deathtype == "laser")
					bprint_fb(1, " was zapped\n");
				else if (deathtype == "fireball")
					bprint_fb(1, " ate a lavaball\n");
				else
					bprint_fb(1, " died\n");
			}
		}
	}
};