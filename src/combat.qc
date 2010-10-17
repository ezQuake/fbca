/*
	combat.qc

	damage, obit, etc related functions

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
*/

void(entity at, entity tg) CheckCombatChat;
void() CheckCombatEnemy;

/*
============
CanDamage

Returns true if the inflictor can directly damage the target. Used for
explosions and melee attacks.
============
*/
float() CanDamage =
{
	targ_origin = targ.origin;
	traceline(inflictor_origin, targ_origin, TRUE, inflictor);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor_origin, targ_origin + '15 15 0', TRUE, inflictor);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor_origin, targ_origin + '-15 -15 0', TRUE, inflictor);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor_origin, targ_origin + '-15 15 0', TRUE, inflictor);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor_origin, targ_origin + '15 -15 0', TRUE, inflictor);
	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};

/*
================
TeamArmorDam

Return TRUE if the target's armor can take damage from this attacker.
================
*/

float() TeamArmorDam =
{
	if (armorplay)
	if (attacker.realteam == targ.realteam)
	if ((attacker != targ) || (game_arena))
		return FALSE;	// Armor is protected
	return TRUE;
};

/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void() DamageFlash =
{
	if (firstperson.preferences & PREF_FLASH)
	{
		firstperson.dmg_take = firstperson.dmg_take + take;
		firstperson.dmg_save = firstperson.dmg_save + save;
		firstperson.dmg_inflictor = inflictor;
	}
};

void() T_Damage =
{
	axhitme_ = axhitme;
	axhitme = 0;

// check for quad damage powerup on the attacker
	if (attacker.super_damage_finished > time)
		damage = damage * quad_factor;

	if (pre_game)
	{
		if (attacker != targ)
		{
			if (attacker.client_) attacker.health = rint(damage) + 1000;
			if (targ.client_) targ.currentammo = targ.ammo_nails = targ.ammo_shells = targ.ammo_rockets = targ.ammo_cells = rint(damage) + 1000;
		}
		else
			if (targ.client_) targ.currentammo = targ.ammo_nails = targ.ammo_shells = targ.ammo_rockets = targ.ammo_cells = rint(damage) + 1000;
	}

	if ((attacker != targ) || (game_not_rune_rj))
	{
	// check for double damage for rune of Black Magic powerup
		if (attacker.player_flag & ITEM_RUNE2_FLAG)
			damage = damage * 2;

	// check if target has rune of Earth Magic (half damage)
		else if (targ.player_flag & ITEM_RUNE1_FLAG)
		{
			damage = damage * 0.5;
			// play resistance sound if needed
			if (targ.invincible_sound < time)
			{
				targ.invincible_sound = time + 1;
				msg_entity = targ;
				sound(CHAN_BODY, "items/protect3.wav", 1, ATTN_NORM);
			}
		}
	}

	if (T_Damage2())
		return;

// save damage based on the target's armor level

// team play armor damage avoidance
// TeamArmorDam returns true iff the attacker can damage the target's armor
	if (TeamArmorDam())
	{
		save = ceil(targ.armortype*damage);
		if (save >= targ.armorvalue)
		{
			save = targ.armorvalue;
			targ.armortype = 0;	// lost all armor
			targ.items = targ.items & IT_NOT_ARMOR;
		}
		targ.armorvalue = targ.armorvalue - save;
	}
	else
		save = 0;

	take = ceil(damage-save);

// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?

	if (targ.client_)
	{
		firstperson = targ;
		if (firstperson.player)
			DamageFlash();
		while (firstperson = firstperson.clink)
		{
			if (firstperson.pflags & PF_FIRSTPERSON)
				DamageFlash();
		}

		// figure momentum add
		if (inflictor)
		{
			direction = normalize(targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5) * damage;
			extra_velocity = direction * 8;
			targ.oldvelocity = targ.oldvelocity + extra_velocity;
			targ.velocity = targ.velocity + extra_velocity;
			targ.path_state = targ.path_state | AIR_ACCELERATION;	// for frogbots
		}

		CheckCombatEnemy();

	// check for invincibility
		if (targ.invincible_finished >= time)
		{
			if (targ.invincible_sound < time)
			{
				if (!pre_game)
				{
					msg_entity = targ;
					sound (CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
					targ.invincible_sound = time + 2;
				}
			}
			UpdateTotalDamage(targ);
			return;
		}

	// team play health damage avoidance
		if (teamplay)
		{
			if (attacker.realteam == targ.realteam)
			{
				if (healthplay == TEAM_HEALTH_PROTECT)
				if (targ != attacker)
				{
					UpdateTotalDamage(targ);
					return;
				}

				if (healthplay == TEAM_TOTAL_HEALTH_PROTECT)
				{
					UpdateTotalDamage(targ);
					return;
				}
			}
		}
	}

	killed_self = self;
	self = targ;

// do the damage
	targ.health = targ.health - take;

	if (targ.health <= 0)
	{
		if (targ.health < -99)
			targ.health = -99;		// don't let sbar look bad if a player
		if (!game_disable_botchat)
			CheckCombatChat(attacker, targ);
		self.th_die();
	}
	else
	{
	// react to the damage
		UpdateTotalDamage(self);
		self.th_pain ();
	}

	self = killed_self;

//damage stats
	if (targ.client_ && attacker.client_)
	{
		targ.t_dmg = targ.t_dmg + damage;
		attacker.s_dmg = attacker.s_dmg + damage;
	}
};

/*
============
T_RadiusDamage

============
*/
void() T_RadiusDamage =
{
	attacker_damaged = FALSE;
	inflictor_origin = inflictor.origin;
	damage_radius = t_radius_damage + 40;

	targ = first_takedamage;
	while (targ)
	{
		if (targ.takedamage)
		{
			if (targ != ignore)
			{
				targ_centre = (targ.absmin + targ.absmax) * 0.5;
				inflictor_dist = vlen(inflictor_origin - targ_centre);
				if (inflictor_dist <= damage_radius)
				{
					damage = t_radius_damage - 0.5 * inflictor_dist;
					if (damage > 0)	// only used if t_radius_damage < 40
					{
						if (targ.movetype == MOVETYPE_PUSH)
						{
							traceline(inflictor_origin, targ_centre, TRUE, inflictor);
							if ((trace_fraction == 1) || (trace_ent == targ))
							{
								T_Damage ();
							}
						}
						else
						{
							if (CanDamage())
							{
								if (targ == attacker)
								{
									attacker_damaged = TRUE;
									attacker_damage = damage * 0.5;
								}
								else
									T_Damage ();
							}
						}
					}
				}
			}
		}
		targ = targ.next;
	}
	if (attacker_damaged)
	{
		targ = attacker;
		damage = attacker_damage;
		T_Damage ();
	}
};