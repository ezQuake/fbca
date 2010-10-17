/*
	weapons.qc

	weapon and weapon hit functions

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
*/

void () T_Damage;
void () player_run;
void() T_RadiusDamage;
void() SuperDamageSound;
void() HasteSound;
void() GrenadeAlert;
void() RocketAlert;
float() W_BestWeapon;
void() spike_touch_apply;
void() superspike_touch_apply;
void() DelayUpdateWeapons;

// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");	// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
};

float() crandom =
{
	return 2*(random() - 0.5);
};

/*
================
SpawnBlood
================
*/

void(vector org) SpawnBlood =
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_BLOOD);
	WriteByte (MSG_MULTICAST, 1);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	multicast (org, MULTICAST_PVS);
};

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local	vector org;

	makevectors(self.v_angle);
	src = self.origin + '0 0 16';
	traceline (src, src + v_forward*64, FALSE, self);
	if (trace_fraction != 1)
	{
		org = trace_endpos - v_forward*4;

		if (trace_ent.takedamage)
		{
			SpawnBlood (org);
			axhitme = 1;
			deathtype = "axe";
			inflictor = self;
			attacker = self;
			targ = trace_ent;
			if (deathmatch > 3)
			{
				damage = 75;
				T_Damage ();
			}
			else
			{
				damage = 20;
				T_Damage ();
			}
		}
		else
		{	// hit wall
			msg_entity = self;
			sound (CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
			WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte (MSG_MULTICAST, TE_GUNSHOT);
			WriteByte (MSG_MULTICAST, 3);
			WriteCoord (MSG_MULTICAST, org_x);
			WriteCoord (MSG_MULTICAST, org_y);
			WriteCoord (MSG_MULTICAST, org_z);
			multicast (org, MULTICAST_PVS);
		}
	}
};


//============================================================================


/*
================
spawn_touchblood
================
*/
void() spawn_touchblood =
{
	weapons_vel = (normalize(weapons_vel + v_up*(random()- 0.5) + v_right*(random()- 0.5)) + 2*trace_plane_normal) * 40;
	SpawnBlood (trace_endpos + weapons_vel*0.01);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/


/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector spread) FireBullets =
{
	makevectors(self.v_angle);
	src = self.origin + v_forward*10;
	src_z = self.origin_z + 14.2;
	multi_ent = world;
	multi_damage = 0;
	blood_count = puff_count = 0;
	traceline (src, src + v_forward*2048, FALSE, self);
	puff_org = trace_endpos - v_forward*4;

	while (shotcount > 0)
	{
		direction = v_forward + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
		traceline (src, src + direction * 2048, FALSE, self);
		if (trace_fraction != 1)
		{
			weapons_vel = (normalize(direction + v_up*crandom() + v_right*crandom()) + (2 * trace_plane_normal)) * 200;

			blood_org = trace_endpos - direction * 4;

			if (trace_ent.takedamage)
			{
				blood_count = blood_count + 1;
				if (trace_ent != multi_ent)
				{
					if (multi_ent)
					{
						targ = multi_ent;
						damage = multi_damage;
						T_Damage ();
					}
					multi_damage = 4;
					multi_ent = trace_ent;
				}
				else
					multi_damage = multi_damage + 4;
			}
			else
			{
				puff_count = puff_count + 1;
			}
		}

		shotcount = shotcount - 1;
	}
	if (multi_ent)
	{
		targ = multi_ent;
		damage = multi_damage;
		T_Damage ();
	}
	if (puff_count)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_GUNSHOT);
		WriteByte (MSG_MULTICAST, puff_count);
		WriteCoord (MSG_MULTICAST, puff_org_x);
		WriteCoord (MSG_MULTICAST, puff_org_y);
		WriteCoord (MSG_MULTICAST, puff_org_z);
		multicast (puff_org, MULTICAST_PVS);
	}

	if (blood_count)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_BLOOD);
		WriteByte (MSG_MULTICAST, blood_count);
		WriteCoord (MSG_MULTICAST, blood_org_x);
		WriteCoord (MSG_MULTICAST, blood_org_y);
		WriteCoord (MSG_MULTICAST, blood_org_z);
		multicast (puff_org, MULTICAST_PVS);
	}
	//hit! !STATS!
	if (match_in_progress)
	if (trace_ent.client_)
	{
		if (self.weapon == IT_SHOTGUN) 
			self.s_sg = self.s_sg + 1;
		else if (self.weapon == IT_SUPER_SHOTGUN)
			self.s_ssg = self.s_ssg + 1;
	}
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	msg_entity = self;
	sound (CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	if (self.player)
	{
		msg_entity = self;
		WriteByte (MSG_ONE, SVC_SMALLKICK);
	}
	//!STATS!
	if (match_in_progress)
		self.h_sg = self.h_sg + 1;

	if (use_ammo)
	{
		DelayUpdateWeapons();
		self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	}
	deathtype = "shell";
	inflictor = self;
	attacker = self;
	FireBullets (6, '0.04 0.04 0');
};

/*
==============================================================================

ROCKETS

==============================================================================
*/

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() Missile_Remove =
{
	self.owner = world;
	remove_self();
};

void() T_MissileTouch =
{
	//!STATS!
	if (other.client_)
	if (pre_game || match_in_progress)
		self.owner.h_rl = self.owner.h_rl + 1;

	if (other != self.owner)
	{
		if (pointcontents(self.origin) == CONTENT_SKY)
		{
			remove_self();
		}
		else
		{
			if (other.takedamage)
			{
				damage = 100 + random()*20;
				deathtype = "rocket";
				inflictor = self;
				attacker = self.owner;
				targ = other;
				T_Damage ();
			}

		// don't do radius damage to the other, because all the damage
		// was done in the impact
			deathtype = "rocket";
			inflictor = self;
			attacker = self.owner;
			t_radius_damage = 120;
			ignore = other;
			T_RadiusDamage ();
			self.origin = self.origin - 8 * normalize(self.velocity);
			self.owner = world;
			WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte (MSG_MULTICAST, TE_EXPLOSION);
			WriteCoord (MSG_MULTICAST, self.origin_x);
			WriteCoord (MSG_MULTICAST, self.origin_y);
			WriteCoord (MSG_MULTICAST, self.origin_z);
			multicast (self.origin, MULTICAST_PHS);
			remove_self();
		}
	}
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

void(entity from) LightningHit =
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNINGBLOOD);
	WriteCoord (MSG_MULTICAST, trace_endpos_x);
	WriteCoord (MSG_MULTICAST, trace_endpos_y);
	WriteCoord (MSG_MULTICAST, trace_endpos_z);
	multicast (trace_endpos, MULTICAST_PVS);
	deathtype = "cell";
	inflictor = from;
	attacker = from;
	targ = trace_ent;
	T_Damage ();

	//!STATS!
	if (pre_game || match_in_progress)
		from.s_lg = from.s_lg + 1;
};


/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from) LightningDamage =
{
	vec_ = (p2 - p1);
	normalize (vec_);
	vec__x = 0 - vec__y;
	vec__y = vec__x;
	vec__z = 0;
	vec_ = vec_ * 16;
	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		LightningHit (from);
		if (mapname == "dm6")
		{
			if (self.classname == "player")
			if (trace_ent.classname == "door")
			if (other.classname == "player") 
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	trace_ent1 = trace_ent;
	traceline (p1 + vec_, p2 + vec_, FALSE, self);
	if (trace_ent != trace_ent1 && trace_ent.takedamage)
	{
		LightningHit (from);
	}
	trace_ent2 = trace_ent;
	traceline (p1 - vec_, p2 - vec_, FALSE, self);
	if (trace_ent != trace_ent1 && trace_ent != trace_ent2 && trace_ent.takedamage)
	{
		LightningHit (from);
	}
};

void() W_FireLightning =
{
	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
	}
	else
	{

		// explode if under water
		if ((!pre_game) && (self.waterlevel > 1))
		{
			if (!game_arena)
			if (deathmatch > 3)
			{
				if (random() <= 0.5)
				{
					deathtype = "selfwater";
					inflictor = self;
					attacker = self.owner;
					targ = self;
					damage = 4000;
					T_Damage ();
					return;
				}
			}
			if (!game_arena)
			t_radius_damage = 35 * self.ammo_cells;
			self.ammo_cells = 0;
			W_SetCurrentAmmo ();
			DelayUpdateWeapons();
			if (!game_arena)
			{
			deathtype = "cell";
			inflictor = self;
			attacker = self;
			ignore = world;
			T_RadiusDamage ();
			}
		}
		else
		{
			if (self.t_width < time)
			{
				msg_entity = self;
				sound (CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
				self.t_width = time + 0.6;
			}

			//!STATS!
			if (pre_game || match_in_progress)
				self.h_lg = self.h_lg + 1;

			if (self.player)
			{
				msg_entity = self;
				WriteByte (MSG_ONE, SVC_SMALLKICK);
			}

			if (use_ammo)
			{
				DelayUpdateWeapons();
				self.currentammo = self.ammo_cells = self.ammo_cells - 1;
			}

			org_ = self.origin + '0 0 16';

			makevectors(self.v_angle);
			traceline (org_, org_ + v_forward*600, TRUE, self);
			WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte (MSG_MULTICAST, TE_LIGHTNING2);
			WriteEntity (MSG_MULTICAST, self);
			WriteCoord (MSG_MULTICAST, org__x);
			WriteCoord (MSG_MULTICAST, org__y);
			WriteCoord (MSG_MULTICAST, org__z);
			WriteCoord (MSG_MULTICAST, trace_endpos_x);
			WriteCoord (MSG_MULTICAST, trace_endpos_y);
			WriteCoord (MSG_MULTICAST, trace_endpos_z);
			multicast (org_, MULTICAST_PHS);
			damage = 30;
			LightningDamage (org_, trace_endpos + v_forward*4, self);
		}
	}
};


//=============================================================================

void() GrenadeExplode =
{
	deathtype = "grenade";
	inflictor = self;
	attacker = self.owner;
	t_radius_damage = 120;
	ignore = world;
	T_RadiusDamage ();
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);
	remove_self ();
};

void() GrenadeTouch =
{
	if (other != self.owner)
	{
		if (other.takedamage == DAMAGE_AIM)
		{
			GrenadeExplode();
		}
		else
		{
			msg_entity = self;
			sound (CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
			if (self.velocity == '0 0 0')
				self.avelocity = '0 0 0';
		}
	}
};


//=============================================================================

void() spike_touch;
void() superspike_touch;

/*
===============
launch_spike

===============
*/
void(vector org) launch_spike_apply =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(weapons_vel);
	
	newmis.classname = "missile";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	newmis.velocity = weapons_vel;
};

void(vector org) launch_spike =
{
	launch_spike_apply(org);
	newmis.touch = spike_touch;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);
};

void(vector org) launch_superspike =
{
	launch_spike_apply(org);
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);
};

void(float ox) W_FireSpikes =
{
	if (self.weapon == IT_SUPER_NAILGUN)
	{
		if (self.ammo_nails >= 2)
		{
			msg_entity = self;
			sound (CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
			self.attack_finished = time + 0.2;

			if (use_ammo)
			{
				DelayUpdateWeapons();
				self.currentammo = self.ammo_nails = self.ammo_nails - 2;
			}
			makevectors(self.v_angle);

			if (self.player_flag & ITEM_RUNE3_FLAG)
			{
				HasteSound();
				weapons_vel = v_forward * 2000;
				launch_superspike (self.origin + '0 0 16');
			}
			else
			{
				weapons_vel = v_forward * 1000;
				launch_superspike (self.origin + '0 0 16');
			}

			if (self.player)
			{
				msg_entity = self;
				WriteByte (MSG_ONE, SVC_SMALLKICK);
			}
			return;
		}
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
	}
	else
	{
		msg_entity = self;
		sound (CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
		self.attack_finished = time + 0.2;

		if (use_ammo)
		{
			DelayUpdateWeapons();
			self.currentammo = self.ammo_nails = self.ammo_nails - 1;
		}
		makevectors(self.v_angle);

		if (self.player_flag & ITEM_RUNE3_FLAG)
		{
			HasteSound();
			weapons_vel = v_forward * 2000;
			launch_spike (self.origin + '0 0 16' + v_right*ox);
		}
		else
		{
			weapons_vel = v_forward * 1000;
			launch_spike (self.origin + '0 0 16' + v_right*ox);
		}

		if (self.player)
		{
			msg_entity = self;
			WriteByte (MSG_ONE, SVC_SMALLKICK);
		}
	}
};

void() spike_touch_apply =
{
	if (pointcontents(trace_endpos) != CONTENT_SKY)
	{
	// hit something that bleeds
		if (targ.takedamage)
		{
			damage = 9;
			spawn_touchblood ();
			deathtype = "nail";
			T_Damage ();
		}
		else
		{
			WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte (MSG_MULTICAST, TE_SPIKE);
			WriteCoord (MSG_MULTICAST, trace_endpos_x);
			WriteCoord (MSG_MULTICAST, trace_endpos_y);
			WriteCoord (MSG_MULTICAST, trace_endpos_z);
			multicast (trace_endpos, MULTICAST_PHS);
		}
	}
};

void() spike_touch =
{
	if (other != self.owner)
	{
		if (other.solid != SOLID_TRIGGER)
		{
			trace_endpos = self.origin;
			weapons_vel = normalize (self.velocity);
			inflictor = self;
			attacker = self.owner;
			targ = other;
			spike_touch_apply();
			remove_self();
		}
	}
};

void() superspike_touch_apply =
{
	if (pointcontents(trace_endpos) != CONTENT_SKY)
	{
	// hit something that bleeds
		if (targ.takedamage)
		{
			damage = 18;
			spawn_touchblood ();
			deathtype = "supernail";
			T_Damage ();
		}
		else
		{
			WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
			WriteByte (MSG_MULTICAST, TE_SUPERSPIKE);
			WriteCoord (MSG_MULTICAST, trace_endpos_x);
			WriteCoord (MSG_MULTICAST, trace_endpos_y);
			WriteCoord (MSG_MULTICAST, trace_endpos_z);
			multicast (trace_endpos, MULTICAST_PHS);
		}
	}
};

void() superspike_touch =
{
	if (other != self.owner)
	{
		if (other.solid != SOLID_TRIGGER)
		{
			trace_endpos = self.origin;
			weapons_vel = normalize (self.velocity);
			inflictor = self;
			attacker = self.owner;
			targ = other;
			superspike_touch_apply();
			remove_self();
		}
	}
};

/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	weapon_ = self.weapon;

	player_run ();		// get out of any weapon firing states

	self.items = self.items & IT_NOT_AMMO;

	if (weapon_ == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
	}
	else if (weapon_ == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (weapon_ == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.items = self.items | IT_SHELLS;
	}
	else if (weapon_ == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (weapon_ == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.items = self.items | IT_NAILS;
	}
	else if (weapon_ == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (weapon_ == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else	// if (weapon_ == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.items = self.items | IT_CELLS;
	}
};

float() W_BestWeapon =
{
	items_ = self.items;
	if (best_rl())
		return IT_ROCKET_LAUNCHER;
	if (items_ & IT_LIGHTNING)
		if (self.ammo_cells >= 1)
			if (self.waterlevel <= 1)
				return IT_LIGHTNING;
	if (best_gl())
		return IT_GRENADE_LAUNCHER;
	if (items_ & IT_SUPER_NAILGUN)
		if (self.ammo_nails >= 2)
			return IT_SUPER_NAILGUN;
	if (items_ & IT_SUPER_SHOTGUN)
		if (self.ammo_shells >= 2)
			return IT_SUPER_SHOTGUN;
	if (items_ & IT_NAILGUN)
		if (self.ammo_nails >= 1)
			return IT_NAILGUN;
	if (items_ & IT_SHOTGUN)
		if (self.ammo_shells >= 1)
			return IT_SHOTGUN;
	return IT_AXE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;
void()	player_light1;
void()	player_rocket1;

void() W_Attack =
{
	weapon_ = self.weapon;

	if (self.currentammo <= 0)
	{
		if (self.weapon != IT_AXE)
		{
			self.weapon = W_BestWeapon ();
			W_SetCurrentAmmo ();
			// drop the weapon down
			return;
		}
	}
	if (weapon_ == IT_AXE)
	{
		msg_entity = self;
		sound (CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		rnd = random();
		if (rnd < 0.25)
			player_axe1 ();
		else if (rnd < 0.5)
			player_axeb1 ();
		else if (rnd < 0.75)
			player_axec1 ();
		else
			player_axed1 ();

		// RUNE: rune of hell magic
		if (self.player_flag & ITEM_RUNE3_FLAG)
		{
			self.attack_finished = time + 0.3;
			HasteSound();
		}
		else
			self.attack_finished = time + 0.5;
	}
	else if (weapon_ == IT_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();

		// RUNE: rune of hell magic
		if (self.player_flag & ITEM_RUNE3_FLAG)
		{
			self.attack_finished = time + 0.3;
			HasteSound();
		}
		else
			self.attack_finished = time + 0.5;
	}
	else if (weapon_ == IT_SUPER_SHOTGUN)
	{
		player_shot1 ();

		if (self.currentammo == 1)
		{
			W_FireShotgun ();
		}
		else
		{
			msg_entity = self;
			sound (CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

			if (self.player)
			{
				msg_entity = self;
				WriteByte (MSG_ONE, SVC_BIGKICK);
			}
			//!STATS!
			if (match_in_progress)
				self.h_ssg = self.h_ssg + 1;

			if (use_ammo)
			{
				DelayUpdateWeapons();
				self.currentammo = self.ammo_shells = self.ammo_shells - 2;
			}
			deathtype = "supershell";
			inflictor = self;
			attacker = self;
			FireBullets (14, '0.14 0.08 0');
		}

		// RUNE: rune of hell magic
		if (self.player_flag & ITEM_RUNE3_FLAG)
		{
			self.attack_finished = time + 0.4;
			HasteSound();
		}
		else
			self.attack_finished = time + 0.7;
	}
	else if (weapon_ == IT_NAILGUN)
	{
		player_nail1 ();
	}
	else if (weapon_ == IT_SUPER_NAILGUN)
	{
		player_nail1 ();
	}
	else if (weapon_ == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();

		if (use_ammo)
		{
			DelayUpdateWeapons();
			self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
		}

		msg_entity = self;
		sound (CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

		if (self.player)
		{
			msg_entity = self;
			WriteByte (MSG_ONE, SVC_SMALLKICK);
		}
		newmis = spawn ();
		newmis.owner = self;
		newmis.movetype = MOVETYPE_BOUNCE;
		newmis.solid = SOLID_BBOX;
		newmis.classname = "missile";

	// set newmis speed	

		makevectors(self.v_angle);

		if (self.v_angle_x)
			newmis.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
		else
		{
			newmis.velocity = v_forward * 600;
			newmis.velocity_z = 200;
		}

		newmis.avelocity = '300 300 300';
		newmis.angles = vectoangles(newmis.velocity);
		newmis.touch = GrenadeTouch;
	
	// set newmis duration
		newmis.nextthink = time + 0.05; // New
		newmis.think = GrenadeAlert;
		newmis.frogbot_nextthink = time + 2.5;

		setmodel (newmis, "progs/grenade.mdl");
		setsize (newmis, '0 0 0', '0 0 0');		
		setorigin (newmis, self.origin);

		// RUNE: rune of hell magic
		if (self.player_flag & ITEM_RUNE3_FLAG)
		{
			self.attack_finished = time + 0.3;
			HasteSound();
		}
		else
			self.attack_finished = time + 0.6;
	}
	else if (weapon_ == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();

		if (use_ammo)
		{
			DelayUpdateWeapons();
			self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
		}

		msg_entity = self;
		sound (CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

		if (self.player)
		{
			msg_entity = self;
			WriteByte (MSG_ONE, SVC_SMALLKICK);
		}
		newmis = spawn ();
		newmis.owner = self;
		self.movetarget = newmis;
		newmis.movetype = MOVETYPE_FLYMISSILE;
		newmis.solid = SOLID_BBOX;
		newmis.classname = "missile";
		
	// set newmis speed	

		makevectors(self.v_angle);

		newmis.velocity = v_forward * 1000;
		newmis.angles = vectoangles(newmis.velocity);
		newmis.v_forward_ = v_forward;
		newmis.v_right_ = v_right;
	
		newmis.touch = T_MissileTouch;
	
	// set newmis duration
		newmis.think = RocketAlert;
		newmis.frogbot_nextthink = time + 5;
		newmis.nextthink = 0.001;

		setmodel (newmis, "progs/missile.mdl");
		setsize (newmis, '0 0 0', '0 0 0');		
		setorigin (newmis, self.origin + v_forward*8 + '0 0 16');

		// RUNE: rune of hell magic
		if (self.player_flag & ITEM_RUNE3_FLAG)
		{
			self.attack_finished = time + 0.4;
			HasteSound();
		}
		else
			self.attack_finished = time + 0.8;
	}
	else if (weapon_ == IT_LIGHTNING)
	{
		player_light1();
		self.attack_finished = time + 0.1;
		msg_entity = self;
		sound (CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	am = 0;

	if (impulse_ == 8 && !no_lg)
	{
		weapon_ = IT_LIGHTNING;
		if (self.ammo_cells < 1)
			am = 1;
	}
	else if (impulse_ == 7)
	{
		weapon_ = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (impulse_ == 6)
	{
		weapon_ = IT_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (impulse_ == 5)
	{
		weapon_ = IT_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (impulse_ == 4)
	{
		weapon_ = IT_NAILGUN;
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (impulse_ == 3)
	{
		weapon_ = IT_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			am = 1;
	}
	else if (impulse_ == 2)
	{
		weapon_ = IT_SHOTGUN;
		if (self.ammo_shells < 1)
			am = 1;
	}
	else // if (impulse_ == 1)
	{
		weapon_ = IT_AXE;
	}

	if (self.items & weapon_)
	{
		if (am)
		{	// don't have the ammo
			sprint_fb(self, 2, "not enough ammo.\n");
		}
		else
		{
			// set weapon, set ammo
			self.weapon = weapon_;
			W_SetCurrentAmmo ();
		}
	}
	else
	{	// don't have the weapon or the ammo
		sprint_fb(self, 2, "no weapon.\n");
	}
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	items_ = self.items;
	weapon_ = self.weapon;
	
	while (1)
	{
		am = 1;

		if (weapon_ == IT_LIGHTNING)
		{
			weapon_ = IT_AXE;
		}
		else if (weapon_ == IT_AXE)
		{
			weapon_ = IT_SHOTGUN;
			if (self.ammo_shells < 1)
			am = 0;
		}
		else if (weapon_ == IT_SHOTGUN)
		{
			weapon_ = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 0;
		}		
		else if (weapon_ == IT_SUPER_SHOTGUN)
		{
			weapon_ = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 0;
		}
		else if (weapon_ == IT_NAILGUN)
		{
			weapon_ = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 0;
		}
		else if (weapon_ == IT_SUPER_NAILGUN)
		{
			weapon_ = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 0;
		}
		else if (weapon_ == IT_GRENADE_LAUNCHER)
		{
			weapon_ = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 0;
		}
		else	// if (weapon_ == IT_ROCKET_LAUNCHER)
		{
			weapon_ = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 0;
		}

		if (items_ & weapon_)
		{
			if (am)
			{
				self.weapon = weapon_; 
				W_SetCurrentAmmo ();
				return;
			}
		}
	}
};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	items_ = self.items;
	weapon_ = self.weapon;

	while (1)
	{
		am = 1;

		if (weapon_ == IT_LIGHTNING)
		{
			weapon_ = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 0;
		}
		else if (weapon_ == IT_ROCKET_LAUNCHER)
		{
			weapon_ = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 0;
		}
		else if (weapon_ == IT_GRENADE_LAUNCHER)
		{
			weapon_ = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 0;
		}
		else if (weapon_ == IT_SUPER_NAILGUN)
		{
			weapon_ = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 0;
		}
		else if (weapon_ == IT_NAILGUN)
		{
			weapon_ = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 0;
		}		
		else if (weapon_ == IT_SUPER_SHOTGUN)
		{
			weapon_ = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 0;
		}
		else if (weapon_ == IT_SHOTGUN)
		{
			weapon_ = IT_AXE;
		}
		else if (weapon_ == IT_AXE)
		{
			weapon_ = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 0;
		}

		if (items_ & weapon_)
		{
			if (am)
			{
				self.weapon = weapon_;
				W_SetCurrentAmmo ();
				return;
			}
		}
	}
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (time < self.attack_finished)
		return;

// check for attack
	if (!intermission_running)
	{
		if (counting_down)
		if (self.player)
		{
			not_atf(self);
			return;
		}
		SuperDamageSound ();
		W_Attack ();
	}
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
// RUNE play super damage sound if player has Black Magic, too

	msg_entity = self;

	if (!(self.player_flag & ITEM_RUNE2_FLAG))

	{
		if (self.super_damage_finished <= time)
			return;
	}

	if (self.super_sound < time)
	{
		self.super_sound = time + 1;
		sound (CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
	}
};

/*
========
RegenerationSound

Plays sound if needed
========
*/
void() RegenerationSound =
{
	msg_entity = self;
// RUNE play healing sound if player has Elder Magic
	if (self.regeneration_sound <= time)
	{
		self.regeneration_sound = time + 1;
		sound(CHAN_BODY, "items/r_item1.wav", 1, ATTN_NORM);
	}
};

/*
========
HasteSound

Plays sound if needed
========
*/
void() HasteSound =
{
	msg_entity = self;
// RUNE play haste (Chthon's roar) sound if player has Hell Magic
	if (self.haste_sound <= time)
	{
		self.haste_sound = time + 1;
		sound(CHAN_BODY, "boss1/sight1.wav", 1, ATTN_NORM);
	}
};