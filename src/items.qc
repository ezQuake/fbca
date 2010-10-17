/*
	items.qc

	item functions

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
*/

/*
GENERAL ITEM NOTES

1) goal_respawn_time holds time of respawn (including in past)
2) nextthink == 0 for item sitting there
3) nextthink > 0 && think == SUB_regen for item soon to respawn
4) nextthink < 0 for nontouch items
5) nextthink > 0 && think != SUB_regen for item doing some other activity (eg. megahealth rot)

*/
void() W_SetCurrentAmmo;
void() check_marker;
void() AddToQue;
void() UpdateGoalEntity;
entity(vector org) LocateMarker;
void() AssignVirtualGoal;
void() marker_touch;
void() LocateDynamicItem;
void(entity marker) BecomeMarker;

/*
============
bf

============
*/
void() bf_apply =
{
	if (msg_entity.preferences & PREF_FLASH)
		stuffcmd("bf\n");
};

void() bf =
{
	firstperson = msg_entity;
	if (msg_entity.player)
		bf_apply();
	while (msg_entity = msg_entity.clink)
	{
		if (msg_entity.pflags & PF_FIRSTPERSON)
			bf_apply();

	}
	msg_entity = firstperson;
};

/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */

void() SUB_regen =
{
	self.model = "/";		// restore original model
	msg_entity = self;
	sound (CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	AssignVirtualGoal();
};

void() goal_NULL =
{
	goal_desire = 0;
};

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void() StartItem =
{
	if (a_item())
		return;
// put on save que
	AddToQue();
	self.view_ofs = '80 80 24';
	first_item = AddToList(first_item);
	self.solid = SOLID_TRIGGER;
	self.flags = FL_ITEM;
	BecomeMarker(self);
};

void() StartItems =
{
	marker_ = first_item;
	while (marker_)
	{
		if (marker_.touch)
		{
			marker_.think = SUB_regen;
			if (pre_game)
				marker_.nextthink = -1;
		}
		else
		{
			marker_.touch = marker_touch;
			marker_.nextthink = -1;
		}
		marker_ = marker_.next;
	}
};

/*
============
NoItemTouch

============
*/
float() NoItemTouch =
{
	testplace = other.origin;
	test_enemy_maxs = self.virtual_maxs;
	if (testplace_x <= test_enemy_maxs_x)
	if (testplace_y <= test_enemy_maxs_y)
	if (testplace_z <= test_enemy_maxs_z)
	{
		test_enemy_mins = self.virtual_mins;
		if (testplace_x >= test_enemy_mins_x)
		if (testplace_y >= test_enemy_mins_y)
		if (testplace_z >= test_enemy_mins_z)
		{
			if (other.goalentity == self)
				other.goal_refresh_time = 0;
			return FALSE;
		}
	}
	return TRUE;
};

/*
=========================================================================

HEALTH BOX

=========================================================================
*/

/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

float	H_ROTTEN = 1;
float	H_MEGA = 2;
void() health_touch;
void() item_megahealth_rot;

void() goal_health0 =
{
	goal_desire = self.desire_health0;
};

void() goal_health2 =
{
	goal_desire = self.desire_health2;
};

float() pickup_health0 =
{
	return (self.health < 100);
};

float() pickup_health2 =
{
	return (self.health < 250);
};

void() item_health =
{
	if (deathmatch <= 5)
	if (deathmatch != 2)
	{
		if (self.spawnflags & H_MEGA)
		{
			if (deathmatch != 4)
			{
				self.touch = health_touch;
				setmodel(self, "maps/b_bh100.bsp");
				self.noise = "items/r_item2.wav";
				self.healamount = 100;
				self.healtype = 2;
				self.desire = goal_health2;
				self.pickup = pickup_health2;
			}
		}
		else
		{
			self.touch = health_touch;
			if (self.spawnflags & H_ROTTEN)
			{
				setmodel(self, "maps/b_bh10.bsp");
				self.noise = "items/r_item1.wav";
				self.healamount = 15;
				self.healtype = 0;
			}
			else
			{
				setmodel(self, "maps/b_bh25.bsp");
				self.noise = "items/health1.wav";
				self.healamount = 25;
				self.healtype = 1;
			}
			self.desire = goal_health0;
			self.pickup = pickup_health0;
		}
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

void() health_touch =
{
	if (other.client_)
	{
		if (marker_time)
			check_marker();
		if (self.nextthink)
			return;
		if (other.takedamage)
		{
			// Megahealth = rot down the player's super health
			if (self.healtype == 2) // Megahealth
			{
				if (other.health >= 250)
					return;
				if (NoItemTouch())
					return;
				if (other.health < 150)
					other.health = other.health + 100;
				else
					other.health = 250;

				self.nextthink = time + 5;
				self.think = item_megahealth_rot;
				self.owner = other;
				other.items = other.items | 65536;
				teamreport2(other, 4);
			}
			else
			{
				if (other.health >= 100)
					return;
				if (NoItemTouch())
					return;
				other.health = other.health + self.healamount;
				if (other.health > 100)
					other.health = 100;

				self.nextthink = self.goal_respawn_time = time + 20;
			}
			AssignVirtualGoal();

			msg_entity = other;

			sprint_fb(other, 0, "You receive ");
			sprint_ftos(other, 0, self.healamount);
			sprint_fb(other, 0, " health\n");
	
		// health touch sound
			sound(CHAN_ITEM, self.noise, 1, ATTN_NORM);

			bf();

			self.model = "";

			UpdateTotalDamage(other);
			UpdateGoalEntity();
		}
	}
};	

void() item_megahealth_rot =
{
	other = self.owner;
	
	if (other.health > 100)
	//ZOID: player doesn't rot if they have Elder Magic rune
		if (!(other.player_flag & ITEM_RUNE4_FLAG))
		{
			other.health = other.health - 1;
			self.nextthink = time + 1;
			UpdateTotalDamage(other);
			return;
		}
	other.items = other.items - (other.items & 65536);
	self.nextthink = self.goal_respawn_time = time + 20;
	self.think = SUB_regen;
	AssignVirtualGoal();
};

/*
===============================================================================

ARMOR

===============================================================================
*/

void() armor_touch =
{
	if (other.client_)
	{
		if (marker_time)
			check_marker();
		if (self.nextthink)
			return;
		if (other.takedamage)
		{
			if (other.total_armor >= self.total_armor)
			{
				if (marker_time)
				if (other.goalentity == self)
				if (!other.look_object.client_)
				if (other.movetarget.owner != other)	// no rocket active
				if (!other.button0_)
				{
					other.state = other.state | HURT_SELF;
					other.linked_marker = self;
					other.path_state = 0;
					other.linked_marker_time = time + 0.5;
					other.goal_refresh_time = time + 2 + random();
				}
				return;
			}

			if (NoItemTouch())
				return;
			other.armortype = self.armortype;
			other.armorvalue = self.armorvalue;
			other.items = (other.items & IT_NOT_ARMOR) + self.items;

			self.model = "";
			self.nextthink = self.goal_respawn_time = time + 20;
			AssignVirtualGoal();

			if (self.armorvalue == 100) {
				other.s_GA = other.s_GA + 1;
				teamreport2(other, 1);
			} 
			if (self.armorvalue == 150) {
				other.s_YA = other.s_YA + 1;
				teamreport2(other, 2);
			} 
			if (self.armorvalue == 200) {
				other.s_RA = other.s_RA + 1;
				teamreport2(other, 3);
			}

			msg_entity = other;

			sprint_fb(other, 0, "You got armor\n");

		// armor touch sound
			sound(CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);

			bf();

			UpdateTotalDamage(other);
			UpdateGoalEntity();
		}
	}
};


/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void() goal_armor1 =
{
	goal_desire = self.desire_armor1;
};

float() pickup_armor1 =
{
	return (self.total_armor < 30);
};

void() item_armor1 =
{
	if (deathmatch <= 5)
	if (deathmatch != 2)
	{
		self.touch = armor_touch;
		setmodel (self, "progs/armor.mdl");
//		self.skin = 0;
		self.armortype = 0.3;
		self.armorvalue = 100;
		self.total_armor = 30;
		self.items = IT_ARMOR1;
		self.desire = goal_armor1;
		self.pickup = pickup_armor1;
	}
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void() goal_armor2 =
{
	if (self.desire_armor2)
		goal_desire = (self.desire_armor2 + virtual_enemy.desire_armor2);	
	else
	{
		if (self.total_armor <= 100)
		if (items_ & IT_ROCKET_LAUNCHER)
		if (self.ammo_rockets)
		if (self.health >= 50)
		if (self.super_damage_finished <= time)
		{
			goal_desire = virtual_enemy.desire_armor2;
			return;
		}
		goal_desire = 0;
	}
};

float() pickup_armor2 =
{
	return (self.total_armor < 90);
};

void() item_armor2 =
{
	if (deathmatch <= 5)
	if (deathmatch != 2)
	{
		self.touch = armor_touch;
		setmodel (self, "progs/armor.mdl");
		self.skin = 1;
		self.armortype = 0.6;
		self.armorvalue = 150;
		self.total_armor = 90;
		self.items = IT_ARMOR2;
		self.desire = goal_armor2;
		self.pickup = pickup_armor2;
	}
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void() goal_armorInv =
{
	if (self.desire_armorInv)
		goal_desire = (self.desire_armorInv + virtual_enemy.desire_armorInv);
	else
	{
		if (items_ & IT_ROCKET_LAUNCHER)
		if (self.ammo_rockets)
		if (self.health >= 50)
		if (self.super_damage_finished <= time)
		{
			goal_desire = virtual_enemy.desire_armorInv;
			return;
		}
		goal_desire = 0;
	}
};

float() pickup_armorInv =
{
	return (self.total_armor < 160);
};

void() item_armorInv =
{
	if (deathmatch <= 5)
	if (deathmatch != 2)
	{
		self.touch = armor_touch;
		setmodel (self, "progs/armor.mdl");
		self.skin = 2;
		self.armortype = 0.8;
		self.armorvalue = 200;
		self.total_armor = 160;
		self.items = IT_ARMOR3;
		self.desire = goal_armorInv;
		self.pickup = pickup_armorInv;
	}
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*
===============================================================================

WEAPONS

===============================================================================
*/

void() bound_ammo =
{
	if (other.ammo_shells > 100)
		other.ammo_shells = 100;
	if (other.ammo_nails > 200)
		other.ammo_nails = 200;
	if (other.ammo_rockets > 100)
		other.ammo_rockets = 100;		
	if (other.ammo_cells > 100)
		other.ammo_cells = 100;		
};


float(float w) RankForWeapon =
{
	if (w == IT_LIGHTNING)
		return 1;
	if (w == IT_ROCKET_LAUNCHER)
		return 2;
	if (w == IT_SUPER_NAILGUN)
		return 3;
	if (w == IT_GRENADE_LAUNCHER)
		return 4;
	if (w == IT_SUPER_SHOTGUN)
		return 5;
	if (w == IT_NAILGUN)
		return 6;
	return 7;
};

float (float w) WeaponCode =
{
	if (w == IT_SUPER_SHOTGUN)
		return 3;
	if (w == IT_NAILGUN)
		return 4;
	if (w == IT_SUPER_NAILGUN)
		return 5;
	if (w == IT_GRENADE_LAUNCHER)
		return 6;
	if (w == IT_ROCKET_LAUNCHER)
		return 7;
	if (w == IT_LIGHTNING)
		return 8;
	return 1;
};

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon
=============
*/
void(float new) Deathmatch_Weapon =
{
		if (other.flags & FL_INWATER)
		{
			if (new == IT_LIGHTNING)
				return;
		}

// change other.weapon if desired
	or = RankForWeapon (other.weapon);
	nr = RankForWeapon (new);
	if ( nr < or )
		other.weapon = new;
};

/*
=============
weapon_touch

=============
*/
void() weapon_touch =
{
	if (other.client_)
	{
		if (marker_time)
			check_marker();
		if (self.nextthink)
			return;
		if (other.takedamage)
		{
			if (leave)
			{
				if (other.items & self.weapon)
					return;
			}

			if (NoItemTouch())
				return;
			if (self.weapon == IT_NAILGUN)
				other.ammo_nails = other.ammo_nails + 30;
			else if (self.weapon == IT_SUPER_NAILGUN)
				other.ammo_nails = other.ammo_nails + 30;
			else if (self.weapon == IT_SUPER_SHOTGUN)
				other.ammo_shells = other.ammo_shells + 5;
			else if (self.weapon == IT_ROCKET_LAUNCHER) {
				other.ammo_rockets = other.ammo_rockets + 5;
			teamreport2(other, 6);
			} 
			else if (self.weapon == IT_GRENADE_LAUNCHER) {
				other.ammo_rockets = other.ammo_rockets + 5;
				teamreport2(other, 5);
			}
			else if (self.weapon == IT_LIGHTNING) {
				other.ammo_cells = other.ammo_cells + 15;
				teamreport2(other, 7);
			}

			other.weapon_refresh_time = 0;

			msg_entity = other;

			sprint_fb(other, 0, "You got the ");
			sprint_fb(other, 0, self.netname);
			sprint_fb(other, 0, "\n");

		// weapon touch sound
			sound (CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);

			bf();

			bound_ammo ();

		// change to the weapon
			other.items = other.items | self.weapon;
			w_switch = stof(infokey(other,"w_switch"));
			if (!w_switch)
				w_switch = 8;

			if ( WeaponCode(self.weapon) <= w_switch )
			{
			Deathmatch_Weapon (self.weapon);
			}
			if (!leave)
			{
				UpdateGoalEntity();

			// setup for respawning
				self.model = "";

				self.nextthink = self.goal_respawn_time = time + 30;
				AssignVirtualGoal();
			}

			self = other;
			W_SetCurrentAmmo();
		}
	}
};

float() pickup_true =
{
	return TRUE;
};


/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() goal_supershotgun1 =
{
	goal_desire = (self.desire_supershotgun + (virtual_enemy.desire_supershotgun * 0.5));
};

void() goal_supershotgun2 =
{
	if (items_ & IT_SUPER_SHOTGUN)
		goal_desire = 0;
	else
		goal_desire = (self.desire_supershotgun + (virtual_enemy.desire_supershotgun * 0.5));
};

float() pickup_supershotgun2 =
{
	return !(self.items & IT_SUPER_SHOTGUN);
};

void() weapon_supershotgun =
{
	G21(self);

	if (deathmatch <= 3)
	{
		self.touch = weapon_touch;
		available_weapons = available_weapons | IT_SUPER_SHOTGUN;
		setmodel (self, "progs/g_shot.mdl");
		self.weapon = IT_SUPER_SHOTGUN;
		self.netname = "Double-barrelled Shotgun";
		if (deathmatch == 1)
		{
			self.desire = goal_supershotgun1;
			self.pickup = pickup_true;
		}
		else
		{
			self.desire = goal_supershotgun2;
			self.pickup = pickup_supershotgun2;
		}
	}
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() goal_nailgun1 =
{
	goal_desire = (self.desire_nailgun + (virtual_enemy.desire_nailgun * 0.5));
};

void() goal_nailgun2 =
{
	if (items_ & IT_NAILGUN)
		goal_desire = 0;
	else
		goal_desire = (self.desire_nailgun + (virtual_enemy.desire_nailgun * 0.5));
};

float() pickup_nailgun2 =
{
	return !(self.items & IT_NAILGUN);
};

void() weapon_nailgun =
{
	G22(self);

	if (deathmatch <= 3)
	{
		self.touch = weapon_touch;
		available_weapons = available_weapons | IT_NAILGUN;
		setmodel (self, "progs/g_nail.mdl");
		self.weapon = IT_NAILGUN;
		self.netname = "nailgun";
		if (deathmatch == 1)
		{
			self.desire = goal_nailgun1;
			self.pickup = pickup_true;
		}
		else
		{
			self.desire = goal_nailgun2;
			self.pickup = pickup_nailgun2;
		}
	}
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() goal_supernailgun1 =
{
	goal_desire = (self.desire_supernailgun + (virtual_enemy.desire_supernailgun * 0.5));
};

void() goal_supernailgun2 =
{
	if (items_ & IT_SUPER_NAILGUN)
		goal_desire = 0;
	else
		goal_desire = (self.desire_supernailgun + (virtual_enemy.desire_supernailgun * 0.5));
};

float() pickup_supernailgun2 =
{
	return !(self.items & IT_SUPER_NAILGUN);
};

void() weapon_supernailgun =
{
	G20(self);

	if (deathmatch <= 3)
	{
		self.touch = weapon_touch;
		available_weapons = available_weapons | IT_SUPER_NAILGUN;
		setmodel (self, "progs/g_nail2.mdl");
		self.weapon = IT_SUPER_NAILGUN;
		self.netname = "Super Nailgun";
		if (deathmatch == 1)
		{
			self.desire = goal_supernailgun1;
			self.pickup = pickup_true;
		}
		else
		{
			self.desire = goal_supernailgun2;
			self.pickup = pickup_supernailgun2;
		}
	}
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() goal_grenadelauncher1 =
{
	goal_desire = (self.desire_grenadelauncher + virtual_enemy.desire_grenadelauncher);
};

void() goal_grenadelauncher2 =
{
	if (items_ & IT_GRENADE_LAUNCHER)
		goal_desire = 0;
	else
		goal_desire = (self.desire_grenadelauncher + virtual_enemy.desire_grenadelauncher);
};

float() pickup_grenadelauncher2 =
{
	return !(self.items & IT_GRENADE_LAUNCHER);
};

void() weapon_grenadelauncher =
{
	if (deathmatch <= 3)
	{
		self.touch = weapon_touch;
		available_weapons = available_weapons | IT_GRENADE_LAUNCHER;
		setmodel (self, "progs/g_rock.mdl");
		self.weapon = IT_GRENADE_LAUNCHER;
		self.netname = "Grenade Launcher";
		if (deathmatch == 1)
		{
			self.desire = goal_grenadelauncher1;
			self.pickup = pickup_true;
		}
		else
		{
			self.desire = goal_grenadelauncher2;
			self.pickup = pickup_grenadelauncher2;
		}
	}
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() goal_rocketlauncher1 =
{
	goal_desire = (self.desire_rocketlauncher + virtual_enemy.desire_rocketlauncher);
};

void() goal_rocketlauncher2 =
{
	if (items_ & IT_ROCKET_LAUNCHER)
		goal_desire = 0;
	else
		goal_desire = (self.desire_rocketlauncher + virtual_enemy.desire_rocketlauncher);
};

float() pickup_rocketlauncher2 =
{
	return !(self.items & IT_ROCKET_LAUNCHER);
};

void() weapon_rocketlauncher =
{
	if (deathmatch <= 3)
	{
		self.touch = weapon_touch;
		available_weapons = available_weapons | IT_ROCKET_LAUNCHER;
		setmodel (self, "progs/g_rock2.mdl");
		self.weapon = IT_ROCKET_LAUNCHER;
		self.netname = "Rocket Launcher";
		if (deathmatch == 1)
		{
			self.desire = goal_rocketlauncher1;
			self.pickup = pickup_true;
		}
		else
		{
			self.desire = goal_rocketlauncher2;
			self.pickup = pickup_rocketlauncher2;
		}
	}
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() goal_lightning1 =
{
	goal_desire = (self.desire_lightning + (virtual_enemy.desire_lightning * 0.5));
};

void() goal_lightning2 =
{
	if (items_ & IT_LIGHTNING)
		goal_desire = 0;
	else
		goal_desire = (self.desire_lightning + (virtual_enemy.desire_lightning * 0.5));
};

float() pickup_lightning2 =
{
	return !(self.items & IT_LIGHTNING);
};

void() weapon_lightning =
{
	if (deathmatch <= 3)
	{
		self.touch = weapon_touch;
		available_weapons = available_weapons | IT_LIGHTNING;
		setmodel (self, "progs/g_light.mdl");
		self.weapon = IT_LIGHTNING;
		self.netname = "Thunderbolt";
		if (deathmatch == 1)
		{
			self.desire = goal_lightning1;
			self.pickup = pickup_true;
		}
		else
		{
			self.desire = goal_lightning2;
			self.pickup = pickup_lightning2;
		}
	}
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*
===============================================================================

AMMO

===============================================================================
*/

void() ammo_touch =
{
	if (other.client_)
	{
		if (marker_time)
			check_marker();
		if (self.nextthink)
			return;
		if (other.takedamage)
		{
		// shotgun
			if (self.weapon == 1)
			{
				if (other.ammo_shells >= 100)
					return;
				if (NoItemTouch())
					return;
				other.ammo_shells = other.ammo_shells + self.aflag;
			}

		// spikes
			else if (self.weapon == 2)
			{
				if (other.ammo_nails >= 200)
					return;
				if (NoItemTouch())
					return;
				other.ammo_nails = other.ammo_nails + self.aflag;
			}

		// rockets
			else if (self.weapon == 3)
			{
				if (other.ammo_rockets >= 100)
					return;
				if (NoItemTouch())
					return;
				other.ammo_rockets = other.ammo_rockets + self.aflag;
			}

		//	cells
			else if (self.weapon == 4)
			{
				if (other.ammo_cells >= 100)
					return;
				if (NoItemTouch())
					return;
				other.ammo_cells = other.ammo_cells + self.aflag;
			}

			other.weapon_refresh_time = 0;

			bound_ammo ();

			msg_entity = other;

			sprint_fb(other, 0, "You got the ");
			sprint_fb(other, 0, self.netname);
			sprint_fb(other, 0, "\n");	

		// ammo touch sound
			sound (CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);

			bf();

			UpdateGoalEntity();

		// setup for respawning
			self.model = "";

			if (deathmatch == 3 || deathmatch == 5)
				self.nextthink = self.goal_respawn_time = time + 15;
			else
				self.nextthink = self.goal_respawn_time = time + 30;

			AssignVirtualGoal();

			self = other;
			W_SetCurrentAmmo();
		}
	}
};

float WEAPON_BIG2 = 1;

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() goal_shells =
{
	if (self.ammo_shells < 100)
		goal_desire = self.desire_shells;
	else
		goal_desire = 0;
};

float() pickup_shells =
{
	return (self.ammo_shells < 100);
};

void() item_shells =
{
	G24(self);

	if (deathmatch != 2)
	if (deathmatch != 4)
	if (deathmatch != 6)
	{
		self.touch = ammo_touch;

		if (self.spawnflags & WEAPON_BIG2)
		{
			setmodel (self, "maps/b_shell1.bsp");
			self.aflag = 40;
		}
		else
		{
			setmodel (self, "maps/b_shell0.bsp");
			self.aflag = 20;
		}

		self.weapon = 1;
		self.netname = "shells";
		self.desire = goal_shells;
		self.pickup = pickup_shells;
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() goal_spikes =
{
	if (self.ammo_nails < 200)
		goal_desire = self.desire_nails;
	else
		goal_desire = 0;
};

float() pickup_spikes =
{
	return (self.ammo_nails < 200);
};

void() item_spikes =
{
	G23(self);

	if (deathmatch != 2)
	if (deathmatch != 4)
	if (deathmatch != 6)
	{
		self.touch = ammo_touch;

		if (self.spawnflags & WEAPON_BIG2)
		{
			setmodel (self, "maps/b_nail1.bsp");
			self.aflag = 50;
		}
		else
		{
			setmodel (self, "maps/b_nail0.bsp");
			self.aflag = 25;
		}

		self.weapon = 2;
		self.netname = "nails";
		self.desire = goal_spikes;
		self.pickup = pickup_spikes;
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() goal_rockets =
{
	if (self.ammo_rockets < 100)
		goal_desire = (self.desire_rockets + virtual_enemy.desire_rockets);
	else
		goal_desire = 0;

};

float() pickup_rockets =
{
	return (self.ammo_rockets < 100);
};

void() item_rockets =
{
	if (deathmatch != 2)
	if (deathmatch != 4)
	if (deathmatch != 6)
	{
		self.touch = ammo_touch;

		if (self.spawnflags & WEAPON_BIG2)
		{
			setmodel (self, "maps/b_rock1.bsp");
			self.aflag = 10;
		}
		else
		{
			setmodel (self, "maps/b_rock0.bsp");
			self.aflag = 5;
		}

		self.weapon = 3;
		self.netname = "rockets";
		self.desire = goal_rockets;
		self.pickup = pickup_rockets;
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() goal_cells =
{
	if (self.ammo_cells < 100)
		goal_desire = (self.desire_cells + (virtual_enemy.desire_cells * 0.5));
	else
		goal_desire = 0;
};

float() pickup_cells =
{
	return (self.ammo_cells < 100);
};

void() item_cells =
{
	G19(self);

	if (deathmatch != 2)
	if (deathmatch != 4)
	if (deathmatch != 6)
	{
		self.touch = ammo_touch;

		if (self.spawnflags & WEAPON_BIG2)
		{
			setmodel (self, "maps/b_batt1.bsp");
			self.aflag = 12;
		}
		else
		{
			setmodel (self, "maps/b_batt0.bsp");
			self.aflag = 6;
		}

		self.weapon = 4;
		self.netname = "cells";
		self.desire = goal_cells;
		self.pickup = pickup_cells;
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
DO NOT USE THIS!!!! IT WILL BE REMOVED!
*/

float WEAPON_SHOTGUN = 1;
float WEAPON_ROCKET = 2;
float WEAPON_SPIKES = 4;
float WEAPON_BIG = 8;

void() item_weapon =
{
	if (deathmatch != 2)
	if (deathmatch != 4)
	if (deathmatch != 6)
	{
		self.touch = ammo_touch;

		if (self.spawnflags & WEAPON_SHOTGUN)
		{
			self.classname = "item_shells";
			G24(self);

			if (self.spawnflags & WEAPON_BIG)
			{
				setmodel (self, "maps/b_shell1.bsp");
				self.aflag = 40;
			}
			else
			{
				setmodel (self, "maps/b_shell0.bsp");
				self.aflag = 20;
			}

			self.weapon = 1;
			self.netname = "shells";
			self.desire = goal_shells;
			self.pickup = pickup_shells;
		}
		else if (self.spawnflags & WEAPON_SPIKES)
		{
			self.classname = "item_spikes";
			G23(self);

			if (self.spawnflags & WEAPON_BIG)
			{
				setmodel (self, "maps/b_nail1.bsp");
				self.aflag = 40;
			}
			else
			{
				setmodel (self, "maps/b_nail0.bsp");
				self.aflag = 20;
			}

			self.weapon = 2;
			self.netname = "spikes";
			self.desire = goal_spikes;
			self.pickup = pickup_spikes;
		}
		else if (self.spawnflags & WEAPON_ROCKET)
		{
			self.classname = "item_rockets";

			if (self.spawnflags & WEAPON_BIG)
			{
				setmodel (self, "maps/b_rock1.bsp");
				self.aflag = 10;
			}
			else
			{
				setmodel (self, "maps/b_rock0.bsp");
				self.aflag = 5;
			}

			self.weapon = 3;
			self.netname = "rockets";
			self.desire = goal_rockets;
			self.pickup = pickup_rockets;
		}
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*
===============================================================================

KEYS

===============================================================================
*/
void() item_key1 = {remove_self();};

void() item_key2 = {remove_self();};

/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/
void() item_sigil = {remove_self();};

/*
===============================================================================

POWERUPS

===============================================================================
*/

/*
============
DropItem

============
*/
void() DropItem =
{
	item = spawn();
	item.classname = "dynamic_item";

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);

	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;

	item.view_ofs = '31 31 25';
};

void() powerup_touch_apply =
{
	msg_entity = other;

	sound (CHAN_VOICE, self.noise, 1, ATTN_NORM);

	bf();

	self.model = "";

	items_ = self.items;

// do the apropriate action
	if (items_ == IT_INVISIBILITY)
	{
	// use the eyes

		other.modelindex = modelindex_eyes;
		teamreport2(other, 13);
		other.s_RING = other.s_RING + 1;
		other.invisible_time = 1;
		other.invisible_finished = self.frogbot_nextthink;
	}
	else if (items_ == IT_SUIT)
	{
		other.rad_time = 1;
		other.radsuit_finished = self.frogbot_nextthink;
	}
	else if (items_ == IT_INVULNERABILITY)
	{
		teamreport2(other, 12);
		other.s_PENT = other.s_PENT + 1;
		other.invincible_time = 1;
		other.invincible_finished = self.frogbot_nextthink;
		other.effects = other.effects | EF_DIMLIGHT_RED;
	}
	else if (items_ == IT_QUAD)
	{
		teamreport2(other, 11);
		other.s_QUAD = other.s_QUAD + 1;
		other.super_time = 1;
		other.super_damage_finished = self.frogbot_nextthink;
		other.effects = other.effects | EF_DIMLIGHT_BLUE;
	}

	other.items = other.items | items_;

	UpdateGoalEntity();
};

void() powerup_touch =
{
	if (other.client_)
	{
		if (marker_time)
			check_marker();
		if (self.nextthink)
			return;
		if (other.takedamage)
		{
			if (NoItemTouch())
				return;
			self.nextthink = self.goal_respawn_time = time + self.aflag;
			AssignVirtualGoal();

			self.frogbot_nextthink = time + 30;

			powerup_touch_apply();

			msg_entity = other;

			sprint_fb(other, 0, "You got the ");
			sprint_fb(other, 0, self.netname);
			sprint_fb(other, 0, "\n");
		}
	}
};

void() dynamic_powerup_touch =
{
	if (other.client_)
	{
		if (other.takedamage)
		{
			if (other.goalentity == self)
				other.goal_refresh_time = 0;

			powerup_touch_apply();

			seconds = ceil(self.frogbot_nextthink - time);

			bprint_fb(0, other.netname);
			bprint_fb(0, " recovered a ");
			bprint_fb(0, self.netname);
			bprint_fb(0, " with ");
			bprint_ftos(0, seconds);
			bprint_fb(0, " seconds remaining!\n");

			remove_self();
		}
	}
	else if (!other)
		LocateDynamicItem();
};

/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds
*/

void() goal_artifact_invulnerability =
{
	goal_desire = 200 + self.total_damage;
};

void() item_artifact_invulnerability =
{
	if (!game_disable_powerups)
	{
		self.touch = powerup_touch;
		self.noise = "items/protect.wav";
		setmodel (self, "progs/invulner.mdl");
		self.netname = "Pentagram of Protection";
		self.effects = self.effects | EF_RED;
		self.items = IT_INVULNERABILITY;
		self.aflag = 300;
		self.desire = goal_artifact_invulnerability;
		self.pickup = pickup_true;
	}
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

void() lose_artifact_invulnerability =
{
	self.items = self.items & IT_NOT_INVULNERABILITY;
	self.invincible_time = 0;
	self.invincible_finished = 0;
	if (!self.super_damage_finished)
//	if (!(self.player_flag & ITEM_ENEMY_FLAG))
	{
		self.effects = self.effects & NOT_EF_DIMLIGHT;
	}
	self.effects = self.effects & NOT_EF_RED;
};

/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds
*/
void() item_artifact_envirosuit =
{
	self.touch = powerup_touch;
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	self.aflag = 60;
	self.desire = goal_NULL;
	self.pickup = pickup_true;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

void() lose_artifact_envirosuit =
{
	self.items = self.items & IT_NOT_SUIT;
	self.rad_time = 0;
	self.radsuit_finished = 0;
};

/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds
*/

void() goal_artifact_invisibility =
{
	goal_desire = 200 + self.total_damage;
};

void() item_artifact_invisibility_apply =
{
	item.desire = goal_artifact_invisibility;
	setmodel (item, "progs/invisibl.mdl");
	item.netname = "Ring of Shadows";
	item.noise = "items/inv1.wav";
	item.items = IT_INVISIBILITY;	
};

void() item_artifact_invisibility =
{
	item = self;
	if (!game_disable_powerups)
	{
		item.touch = powerup_touch;
		item_artifact_invisibility_apply();
		item.aflag = 300;
		item.pickup = pickup_true;
	}
	setsize (item, '-16 -16 -24', '16 16 32');
	StartItem ();
};

void() drop_artifact_invisibility =
{
	DropItem();

	item.origin = self.origin;
	item.goal_respawn_time = time;

	item_artifact_invisibility_apply();
	setsize (item, '-16 -16 -24', '16 16 32');

	item.touch = dynamic_powerup_touch;

	seconds = ceil(self.invisible_finished - time);

	item.nextthink = item.frogbot_nextthink = self.invisible_finished;
	item.think = SUB_Remove;

	bprint_fb(0, self.netname);
	bprint_fb(0, " lost a ring with ");
	bprint_ftos(0, seconds);
	bprint_fb(0, " seconds remaining\n");
};

void() lose_artifact_invisibility =
{
	if (teamplay && !game_disable_autoreport)
	{
		if (self.invisible_finished > time)
		teamreport2(self, 18);
	}
	self.items = self.items & IT_NOT_INVISIBILITY;
	self.invisible_finished = 0;
	self.invisible_time = 0;
	self.modelindex = modelindex_player;
};

/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage
*/

void() goal_artifact_super_damage =
{
	goal_desire = 200 + self.total_damage;
};

void() item_artifact_super_damage_apply =
{
	item.desire = goal_artifact_super_damage;
	setmodel (item, "progs/quaddama.mdl");
	if (quad_factor == 4)
	item.netname = "Quad Damage";
	else
	item.netname = "OctaPower";
	item.noise = "items/damage.wav";
	item.items = IT_QUAD;	
};

void() item_artifact_super_damage =
{
	item = self;
	if (!game_disable_powerups)
	{
		item.touch = powerup_touch;
		item_artifact_super_damage_apply();
		item.effects = item.effects | EF_BLUE;
		item.aflag = 60;
		item.pickup = pickup_true;
	}
	setsize (item, '-16 -16 -24', '16 16 32');
	StartItem ();
};

void() drop_artifact_super_damage =
{
	DropItem();

	item.origin = self.origin;
	item.goal_respawn_time = time;
	item.effects = item.effects | EF_BLUE;
	item_artifact_super_damage_apply();
	setsize (item, '-16 -16 -24', '16 16 32');

	item.touch = dynamic_powerup_touch;

	seconds = ceil(self.super_damage_finished - time);

	item.nextthink = item.frogbot_nextthink = self.super_damage_finished;
	item.think = SUB_Remove;

	bprint_fb(0, self.netname);
	if (quad_factor == 4) bprint_fb(0, " lost a quad with ");
	else bprint_fb(0, " lost an OctaPower with ");
	bprint_ftos(0, seconds);
	bprint_fb(0, " seconds remaining\n");
};

void() lose_artifact_super_damage =
{
	if (teamplay && !game_disable_autoreport)
	{
		if (self.super_damage_finished > time)
			teamreport2(self, 17);
	}
	self.items = self.items & IT_NOT_QUAD;
	self.super_damage_finished = 0;
	self.super_time = 0;
	if (!self.invincible_finished)
//	if (!(self.player_flag & ITEM_ENEMY_FLAG))
	{
		self.effects = self.effects & NOT_EF_DIMLIGHT;
	}
	self.effects = self.effects & NOT_EF_BLUE;
};

/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

void() RuneRespawn;

/*
============
LocateDynamicItem

============
*/
void() LocateDynamicItem =
{
	if (self.classname == "dynamic_item")
	{
		content = pointcontents(self.origin);

		self.touch_marker = LocateMarker(self.absmin + self.view_ofs);
		if ((self.touch_marker.T & UNREACHABLE) || (content == CONTENT_LAVA))
			self.touch_marker = world;

		if (self.touch_marker)
			self.Z_ = self.touch_marker.Z_;
		else
			self.classname = "";	// can't locate so don't put in goal list
	}
};

/*
============
G_is_connected

============
*/
float() G_is_connected =
{
	return TRUE;
};

void() goal_health_backpack =
{
	if (self.invincible_time)
		goal_desire = 0;
	else
		goal_desire = 20;
};

void() backpack_touch =
{
	local float acount;

	if (other.client_)
	{
		if (other.takedamage)
		{
			if (other.goalentity == self)
				other.goal_refresh_time = 0;

			msg_entity = other;

			if (deathmatch == 4)
			{
				if (other.invincible_time)
					return;

				sprint_fb(other, 0, "You get 10 additional health\n");

				other.health = other.health + 10;
				msg_entity = other;
				if ((other.health > 250) && (other.health < 300))
					sound (CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
				else
					sound (CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
				bf();
				remove_self();

				if (other.health > 299)
				{
					if (other.invincible_time != 1)
					{
						other.invincible_time =	other.super_time = 1;
						other.invincible_finished = other.super_damage_finished = time + 30;
						other.items = other.items | IT_INVULNERABILITY_QUAD;
						other.ammo_cells = 0; // rxr
						msg_entity = other;
						sound (CHAN_VOICE, "boss1/sight1.wav", 1, ATTN_NORM);
						bf();
						bprint_fb(2, other.netname);
						bprint_fb(2, " attains bonus powers!!!\n");
						other.effects = other.effects | EF_DIMLIGHT_RED;
					}
				}
			}
			else
			{

				sprint_fb(other, 0, "You get ");

			// change weapons
				other.ammo_shells = other.ammo_shells + self.ammo_shells;
				other.ammo_nails = other.ammo_nails + self.ammo_nails;
				other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
				other.ammo_cells = other.ammo_cells + self.ammo_cells;
				bound_ammo ();

				if (self.items)
				{
					if (!(other.items & self.items))
					{
						acount = 1;
						sprint_fb(other, 0, "the ");
						sprint_fb(other, 0, self.netname);
						other.items = other.items | self.items;
					}

					b_switch = stof(infokey(other,"b_switch"));
					if (!b_switch)
						b_switch = 8;

					if ( WeaponCode(self.items) <= b_switch )
					{
					Deathmatch_Weapon (self.items);
					}
				}

				if (self.ammo_shells)
				{
					if (acount)
						sprint_fb(other, 0, ", ");
					acount = 1;
					sprint_ftos(other, 0, self.ammo_shells);
					sprint_fb(other, 0, " shells");
				}
				if (self.ammo_nails)
				{
					if (acount)
						sprint_fb(other, 0, ", ");
					acount = 1;
					sprint_ftos(other, 0, self.ammo_nails);
					sprint_fb(other, 0, " nails");
				}
				if (self.ammo_rockets)
				{
					if (acount)
						sprint_fb(other, 0, ", ");
					acount = 1;
					sprint_ftos(other, 0, self.ammo_rockets);
					sprint_fb(other, 0, " rockets");
				}
				if (self.ammo_cells)
				{
					if (acount)
						sprint_fb(other, 0, ", ");
					acount = 1;
					sprint_ftos(other, 0, self.ammo_cells);
					sprint_fb(other, 0, " cells");
				}

				sprint_fb(other, 0, "\n");
	
			// backpack touch sound
				sound (CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);

				bf();

				if (self.items == IT_GRENADE_LAUNCHER)
					teamreport2(other, 8);
				if (self.items == IT_ROCKET_LAUNCHER)
					teamreport2(other, 9);
				if (self.items == IT_LIGHTNING)
					teamreport2(other, 10);

				other.weapon_refresh_time = 0;

				UpdateGoalEntity();
				other.old_linked_marker = world;
				other.linked_marker = LocateMarker(other.origin);
				other.linked_marker_time = time + 5;

				remove_self();

				self = other;
				W_SetCurrentAmmo ();

				if (self.frogbot) teamreport(self);
			}
		}
	}
	else if (!other)
		LocateDynamicItem();
};

/*
===============
DropBackpack

===============
*/
void() DropBackpack =
{
	DropItem();

	item.origin = self.origin - '0 0 24';
	item.goal_respawn_time = time;

	items_ = self.weapon;

	if (self.weapon != IT_AXE)
		item.items = items_;
	
	item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;

	if (items_ == IT_SUPER_SHOTGUN)
	{
		if (deathmatch != 4)
		{
			item.netname = "Double-barrelled Shotgun";
			item.desire = goal_supershotgun1;
		}
		if (!game_disable_dropweap)
			setmodel (item, "progs/g_shot.mdl");
	}
	else if (items_ == IT_NAILGUN)
	{
		if (deathmatch != 4)
		{
			item.netname = "Nailgun";
			item.desire = goal_nailgun1;
		}
		if (!game_disable_dropweap)
			setmodel (item, "progs/g_nail.mdl");
	}
	else if (items_ == IT_SUPER_NAILGUN)
	{
		if (deathmatch != 4)
		{
			item.netname = "Super Nailgun";
			item.desire = goal_supernailgun1;
		}
		if (!game_disable_dropweap)
			setmodel (item, "progs/g_nail2.mdl");
	}
	else if (items_ == IT_GRENADE_LAUNCHER)
	{
		if (deathmatch != 4)
		{
			item.netname = "Grenade Launcher";
			item.desire = goal_grenadelauncher1;
		}
		if (!game_disable_dropweap)
			setmodel (item, "progs/g_rock.mdl");
	}
	else if (items_ == IT_ROCKET_LAUNCHER)
	{
		if (deathmatch != 4)
		{
			item.netname = "Rocket Launcher";
			item.desire = goal_rocketlauncher1;
		}
		if (!game_disable_dropweap)
			setmodel (item, "progs/g_rock2.mdl");
	}
	else if (items_ == IT_LIGHTNING)
	{
		if (deathmatch != 4)
		{
			item.netname = "Thunderbolt";
			item.desire = goal_lightning1;
		}
		if (!game_disable_dropweap)
			setmodel (item, "progs/g_light.mdl");
	}
	else
	{
		if (deathmatch != 4)
		{
			if (item.ammo_cells > (item.ammo_rockets * 5))
				item.desire = goal_cells;
			else if (item.ammo_rockets)
				item.desire = goal_rockets;
			else if (item.ammo_nails >= 50)
				item.desire = goal_spikes;
			else
				item.classname = "";
		}
		if (!game_disable_dropweap)
			setmodel (item, "progs/backpack.mdl");
	}
	if (deathmatch == 4)
		item.desire = goal_health_backpack;
	if (game_disable_dropweap)
		setmodel (item, "progs/backpack.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = backpack_touch;
	item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;
};

/*----------------------------------------------------------------------
The Rune Game modes

Rune 1 - Earth Magic
	resistance
Rune 2 - Black Magic
	strength
Rune 3 - Hell Magic
	haste
Rune 4 - Elder Magic
regeneration

----------------------------------------------------------------------*/

void() goal_rune =
{
	if (self.player_flag & ITEM_RUNE_MASK)
		goal_desire = 0;
	else
		goal_desire = 200;
};

void() SelectRuneSpawnPoint =
{
	runespawn = find(runespawn, classname, "info_player_deathmatch");
	if (!runespawn)
		runespawn = find (runespawn, classname, "info_player_deathmatch");
	self = runespawn;
};

void() RuneTouch =
{
	if (other.client_)
	{
		if (other.player_flag & ITEM_RUNE_MASK)
			return; // one per customer
		if (other.takedamage)
		{
			if (other.goalentity == self)
				other.goal_refresh_time = 0;

			other.player_flag = other.player_flag | self.player_flag;

			msg_entity = other;

			sprint_fb(other, 0, "You got the ");
			sprint_fb(other, 0, self.netname);
			sprint_fb(other, 0, " rune\n");

			if (other.player_flag & ITEM_RUNE1_FLAG)
				other.total_damage = other.total_damage * 2;	// early update
			else if (other.player_flag & ITEM_RUNE2_FLAG)
				other.firepower = other.firepower * 2;	// early update

			// backpack touch sound
			msg_entity = other;
			sound (CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
			bf();

			UpdateGoalEntity();
			other.old_linked_marker = world;
			other.linked_marker = LocateMarker(other.origin);
			other.linked_marker_time = time + 5;

			remove_self();
		}
	}
	else if (!other)
		LocateDynamicItem();
};

void (float flag) Do_DropRune;

void() RuneRespawn =
{
	rune_self = self;

	// choose random starting points
	SelectRuneSpawnPoint();
	Do_DropRune(rune_self.player_flag);

	self = rune_self;
	remove_self();
};

void (float flag) Do_DropRune = 
{
	DropItem();

	item.origin = self.origin - '0 0 24';
	item.goal_respawn_time = time;

	item.player_flag = flag;

	if (flag & ITEM_RUNE1_FLAG)
	{
		setmodel (item, "progs/end1.mdl");
		item.netname = "Òåóéóôáîãå";
	}
	else if (flag & ITEM_RUNE2_FLAG)
	{
		setmodel (item, "progs/end2.mdl");
		item.netname = "Óôòåîçôè";
	}
	else if (flag & ITEM_RUNE3_FLAG)
	{
		setmodel (item, "progs/end3.mdl");
		item.netname = "Èáóôå";
	}
	else if (flag & ITEM_RUNE4_FLAG)
	{
		setmodel (item, "progs/end4.mdl");
		item.netname = "Òåçåîåòáôéïî";
	}
	setsize (item, '-16 -16 0', '16 16 56');

	if (pre_game)
	{
		item.classname = "";
		self = item;
		first_item = AddToList(first_item);
	}
	else
	{
		item.desire = goal_rune;
		item.touch = RuneTouch;

		item.nextthink = time + 120;	/* if no one touches it in two minutes,
			respawn it somewhere else, so inaccessible ones will come 'back' */
	}

	item.think = RuneRespawn;
};

/*
===============
Droprune
self is player
===============
*/
void() DropRune =
{
	if (self.player_flag & ITEM_RUNE1_FLAG)
		Do_DropRune(ITEM_RUNE1_FLAG);
	if (self.player_flag & ITEM_RUNE2_FLAG)
		Do_DropRune(ITEM_RUNE2_FLAG);
	if (self.player_flag & ITEM_RUNE3_FLAG)
		Do_DropRune(ITEM_RUNE3_FLAG);
	if (self.player_flag & ITEM_RUNE4_FLAG)
		Do_DropRune(ITEM_RUNE4_FLAG);
	self.player_flag = self.player_flag - (self.player_flag & ITEM_RUNE_MASK);
};

/*
================
SpawnRunes
spawn all the runes
self is the entity that was created for us, we remove it
================
*/
void() SpawnRunes =
{
	if (game_enable_runes)
	{
		if (pre_game)
			return;
		game_enable_runes = FALSE;

		// choose random starting points
		rnd = random() * 10;
		while (rnd > 0)
		{
			SelectRuneSpawnPoint();
			rnd = rnd - 1;
		}

		SelectRuneSpawnPoint();
		Do_DropRune(ITEM_RUNE1_FLAG);
		SelectRuneSpawnPoint();
		Do_DropRune(ITEM_RUNE2_FLAG);
		SelectRuneSpawnPoint();
		Do_DropRune(ITEM_RUNE3_FLAG);
		SelectRuneSpawnPoint();
		Do_DropRune(ITEM_RUNE4_FLAG);
	}
};