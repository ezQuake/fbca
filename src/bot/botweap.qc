/*
	bot/botweap.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2001 DMSouL
	Copyright (C) 2003 3d[Power]
	Copyright (C) 2000-2007 ParboiL
*/

float() rndval = 
{
	if (pre_game || arenastate != A_PLAYING) return 0.3;
	else return 1;
};

/*
============
AttackRespawns
Original idea by 3d[Power]
============
*/
void() AttackRespawns = 
{	
	if (enemy_.health < 1)
	if (ar_time > time)
	if (self.bot_skill >= 15) 
	if (self.items & IT_ROCKET_LAUNCHER)
	if (self.ammo_rockets > 3)
	if (!self.rocketjumping)
	if (random() > 0.15)
	{
		local entity resp;
		resp = findradius(self.origin, 1000);
		while(resp != world)
		{	
			if (resp.classname == "info_player_deathmatch")
			if (vlen(resp.origin - self.origin + '0 0 16') > 160)
			if (VisibleEntity(resp))
			{
				self.botchose = 1;
				self.impulse = 7;
				self.look_object = look_object_ = resp;
				self.predict_origin = resp.origin + '0 0 16';
				self.old_linked_marker = world;
				local	float	ang1, ang2;
				ang2 = vectoyaw(resp.origin - self.origin);
				ang1 = anglemod(self.angles_y - ang2);
				if (ang1 < 20 || ang1 > 340)
					self.button0_ = TRUE;
				return;				
			}
			resp = resp.chain;
		}
	}
};

/*
============
CheckNewWeapon

============
*/
void() CheckNewWeapon =
{
	if (self.weapon != desired_weapon)
	{
		if (self.lines)
			return;	// loading bots
		self.botchose = 1;
		if (desired_weapon == IT_LIGHTNING)
			self.impulse = 8;
		else if (desired_weapon == IT_ROCKET_LAUNCHER)
			self.impulse = 7;
		else if (desired_weapon == IT_GRENADE_LAUNCHER)
			self.impulse = 6;
		else if (desired_weapon == IT_SUPER_NAILGUN)
			self.impulse = 5;
		else if (desired_weapon == IT_NAILGUN)
			self.impulse = 4;
		else if (desired_weapon == IT_SUPER_SHOTGUN)
			self.impulse = 3;
		else if (desired_weapon == IT_SHOTGUN)
			self.impulse = 2;
		else if (desired_weapon == IT_AXE)
			self.impulse = 1;
	}
};

float(vector object) ShotForLuck =
{
	makevectors(self.v_angle);
	traceline(self.origin, object, TRUE, self);
	return (trace_fraction == 1);
};

/*
============
SetFireButton

============
*/
void() SetFireButton =
{
	if (pre_game) 
	{
		if (!counting_down)
		{
			if ((enemy_ != attacker) || ((time + random()) < enemy_.attack_finished))
			{
				self.button0_ = FALSE;
				return;
			}
		}
		else
		{
			self.button0_ = FALSE;
			return;
		}
	}

	if (self.button0_)
	{
		if (look_object_ == enemy_)
		if (random() < 0.666667)
		if (!self.impulse)
			return;
		if (!self.rocketjumping)
		self.button0_ = FALSE;
	}
	else
	{
		if (time < self.attack_finished)
			return;
	}

	if (self.impulse)
		return;

	if (look_object_.realteam != self.realteam)
	{
		if (self.path_state & DM6_DOOR)
		{
			items_ = self.items;
			if (self.ammo_shells)
				desired_weapon = IT_SHOTGUN;
			else if ((items_ & IT_NAILGUN) && (self.ammo_nails))
				desired_weapon = IT_NAILGUN;
			else if ((items_ & IT_SUPER_NAILGUN) && (self.ammo_nails))
				desired_weapon = IT_SUPER_NAILGUN;
			else if ((items_ & IT_LIGHTNING) && (self.ammo_cells))
				desired_weapon = IT_LIGHTNING;
			CheckNewWeapon();
			if (self.weapon == desired_weapon)
				self.button0_ = TRUE;
		}
		if (self.state & HURT_SELF)
		{
			if (self.weapon == IT_ROCKET_LAUNCHER)
			if (self.real_pitch == 78.75)
			{
				self.button0_ = TRUE;
				self.state = self.state & NOT_HURT_SELF;
			}
			return;
		}
		
		if (enemy_)
		if (enemy_.touch_marker)
		{
			traceline(origin_ + '0 0 16', origin_ + '0 0 16' + rel_pos, FALSE, self);
			if (trace_fraction == 1)
			{
				if (self.weapon != IT_ROCKET_LAUNCHER)
				if (look_object_ != enemy_)
					return;
			}
			else
			{
				if (trace_ent != look_object_)
				{
					if (trace_ent.client_)
					{
						if (self.realteam != trace_ent.realteam)
						{
							if (!(self.flags & FL_WATERJUMP)) // SOUL
							{
								self.enemy = enemy_ = trace_ent;
								LookEnemy();
							}
						}
						return;
					}
					else
					{
						if (look_object_ == enemy_)
						{
							if (!self.waterlevel)
							if (self.allowedMakeNoise)
							if (self.flags & FL_ONGROUND) 						
							{
								traceline(origin_ + '0 0 32', origin_ + '0 0 32' + rel_pos, FALSE, self);
								if (trace_fraction == 1)
									self.button2_ = TRUE;
							}
						}
						return;
					}
				}
			}

			if (self.weapon == IT_LIGHTNING)
			if (self.waterlevel > 1)
				return; // NUMB

			risk_factor = 0.5;
			risk = random();
			risk = risk * risk;

			if (self.items & IT_QUAD)
			if (healthplay != TEAM_TOTAL_HEALTH_PROTECT)
			if (!(self.items & IT_INVULNERABILITY))
			if ((self.weapon == IT_ROCKET_LAUNCHER) || (self.weapon == IT_GRENADE_LAUNCHER))
			if (self.look_object == enemy_)
			{
				if (self.enemy_dist <= 250)
				{
					items_ = self.items;
					if ((items_ & IT_LIGHTNING) && (self.ammo_cells))
						desired_weapon = IT_LIGHTNING;
					else if ((items_ & IT_SUPER_NAILGUN) && (self.ammo_nails))
						desired_weapon = IT_SUPER_NAILGUN;
					else if ((items_ & IT_NAILGUN) && (self.ammo_nails))
						desired_weapon = IT_NAILGUN;
					else if ((items_ & IT_SUPER_SHOTGUN) && (self.ammo_shells))
						desired_weapon = IT_SUPER_SHOTGUN; 
					else if (self.ammo_shells)
						desired_weapon = IT_SHOTGUN;
					CheckNewWeapon();
					if (self.weapon == desired_weapon)
						self.button0_ = TRUE;
				}
			}

			if (self.weapon == IT_ROCKET_LAUNCHER)
			{
				hit_radius = 160;
				rocket_origin = origin_ + '0 0 16';
				makevectors(self.v_angle);
				traceline(rocket_origin, rocket_origin + (v_forward * 600), FALSE, self);
				rocket_endpos = trace_endpos;
				risk_strength = trace_fraction;
				realteam_ = self.realteam;
				test_enemy = first_client;
				while (test_enemy)
				{
					if (test_enemy.takedamage)
					{
						if (test_enemy == enemy_)
						{
							predict_dist = 1000000;
							if (look_object_.client_)
							{
								if (look_object_ == enemy_)
								{
									testplace = self.predict_origin;
									predict_dist = vlen(testplace - rocket_endpos);
								}
							}
							else if (look_object_)
							{
								if (self.allowedMakeNoise)
								if (self.predict_shoot)
								{
									testplace = look_object_.absmin + look_object_.view_ofs;
									from_marker = enemy_.touch_marker;
									path_normal = TRUE;	// FIXME: AI set this
									look_object_.zone_marker();
									look_object_.sub_arrival_time();
									predict_dist = (traveltime * sv_maxspeed) + vlen(testplace - rocket_endpos);
								}
							}
						}
						else
						{
							testplace = test_enemy.origin;
							predict_dist = vlen(testplace - rocket_endpos);
						}
						if (predict_dist <= (hit_radius / (1 - risk)))
						{
							traceline(rocket_endpos, testplace, TRUE, self);
							if (trace_fraction == 1)
							{
								if (test_enemy.realteam != realteam_)
								{
									risk_factor = risk_factor / risk_strength;
									if (look_object_ == enemy_)
										self.button0_ = TRUE; 
									else if (predict_dist <= (80 / (1.2 - risk)))
										self.button0_ = TRUE;
									else
									{
										if (self.items & IT_ROCKET_LAUNCHER)
										{
											if (!self.lines)
											if (look_object_)
											{
												testplace = self.look_object.absmin + self.look_object.view_ofs;
												rel_pos = testplace - self.origin;
												rel_dist = vlen(rel_pos);

												if (self.items & IT_QUAD) dist_sfl = 300;
												else dist_sfl = 250;
			
												if (self.ammo_rockets > 3)
												if (!visible_teammate(self))
												if (!self.rocketjumping)
												if (self.allowedMakeNoise)
												{
													if (rel_dist > dist_sfl)
													if (ShotForLuck(testplace))
													if (RocketSafe())
													{
														traceline(origin_ + '0 0 16', self.origin + rel_pos - '0 0 22', TRUE, self);
														if (trace_fraction == 1)
															rel_pos_z = rel_pos_z - 38;
														self.state = self.state | SHOT_FOR_LUCK;
														self.botchose = 1;
														self.impulse = 7;
														self.button0_ = TRUE;
													}
													else self.state = self.state - (self.state & SHOT_FOR_LUCK);
												}
											}
										}
										if (self.items & IT_GRENADE_LAUNCHER)
										if (!self.lines)
										if (enemy_)
										if (!self.rocketjumping)
										if (self.allowedMakeNoise)
										{
											if (self.ammo_rockets > 3)
											if (!visible_teammate(self))
											if (self.arrow == BACK)
											{
												self.botchose = 1;
												self.impulse = 6;
												self.button0_ = TRUE;
											}
										}
									}
								}
								else
								{
									if (test_enemy != self)
										return;
									else
										risk_factor = risk_factor * risk_strength;
								}
							}
						}
					}
					test_enemy = test_enemy.next;
				}
				return;
			}
			angle_error = desired_angle - self.v_angle;
			if (angle_error_y >= 180)
				angle_error_y = angle_error_y - 360;
			else if (angle_error_y < -180)
				angle_error_y = angle_error_y + 360;
			if (angle_error_x < 0)
				angle_error_x = 0 - angle_error_x;
			if (angle_error_y < 0)
				angle_error_y = 0 - angle_error_y;
			min_angle_error = (1 + risk) * risk_factor * (self.accuracy + (1440 / rel_dist));	// 1440 = 90 * 16
			if (angle_error_x > min_angle_error)
				return;
			if (angle_error_y > min_angle_error)
				return;
			self.button0_ = TRUE;
		}
	}
};

/*
============
RocketSafe

============
*/
float() RocketSafe =
{
	splash_damage = 80 - (0.25 * self.enemy_dist);

	if (splash_damage <= 0)
		return TRUE;

	if (healthplay == TEAM_TOTAL_HEALTH_PROTECT)
		return TRUE;

	if (self.super_damage_finished > time)
	{
		splash_damage = splash_damage * quad_factor;

		if (self.player_flag & ITEM_RUNE_MASK)
		{
			if (self.player_flag & ITEM_RUNE2_FLAG)
				splash_damage = splash_damage * 2;
			else if (self.player_flag & ITEM_RUNE1_FLAG)
				splash_damage = splash_damage * 0.5;
		}
	}

	if (self.total_damage > splash_damage)
		return TRUE;
	return FALSE;
};

/*
============
DesiredWeapon

============
*/
void() DesiredWeapon =
{
	avoid_rockets = FALSE;
	items_ = self.items;

	if (self.items & IT_QUAD)
	if (teamplay && (healthplay != TEAM_TOTAL_HEALTH_PROTECT))
	{
		search_entity = identify_teammate_(self);
		if (!search_entity.invincible_time)
		if (VisibleEntity(search_entity))
		if (enemy_visible)
		if (vlen(search_entity.origin - enemy_.origin) < 150)
		if (self.ammo_shells)
		{
			desired_weapon = IT_SHOTGUN;
			return;
		}
	}

	if (game_rl_pref || no_lg)
	{
		if (items_ & IT_ROCKET_LAUNCHER)
		{
			if (self.ammo_rockets)
			{
				if (RocketSafe())
				{
					desired_weapon = IT_ROCKET_LAUNCHER;
					return;
				}
				avoid_rockets = TRUE;
			}
		}
	}

	shaft_available = FALSE;

	if (game_lg_pref && !no_lg)
	{
		if ((self.waterlevel <= 1) || (self.items & IT_INVULNERABILITY)) 
		{
			if (items_ & IT_LIGHTNING)
			{
				if (self.ammo_cells)
				{
					if (self.enemy_dist <= 600)
					{ 
						desired_weapon = IT_LIGHTNING;
						return;
					}
					shaft_available = TRUE;
				}
			}
		}
	}

	if (BotShouldDischarge())
	{
		desired_weapon = IT_LIGHTNING;
		return;
	}

	if (!no_lg)
	{
		if ((self.waterlevel <= 1) || (self.items & IT_INVULNERABILITY))
		{
			if (items_ & IT_LIGHTNING)
			{ 
				if (self.ammo_cells)
				{
					if (self.enemy_dist <= 600)
					{
						if (look_object_ == enemy_)
						{
							enemy_angles = vectoangles(look_object_.origin - origin_);
							if (enemy_angles_x < 15)
							if (enemy_angles_x > -15)
							{
								desired_weapon = IT_LIGHTNING;
								return;
							}
						}
						else
						{
							desired_weapon = IT_LIGHTNING;
							return;
						}
						shaft_available = TRUE;
					}
				}
			}
		}
	}

	if (!avoid_rockets)
	{
		if (items_ & IT_ROCKET_LAUNCHER)
		{
			if (self.ammo_rockets)
			{
				if (RocketSafe())
				{
					desired_weapon = IT_ROCKET_LAUNCHER;
					return;
				}
				if (!(self.items & IT_INVULNERABILITY))
					avoid_rockets = TRUE;
			}	
		}
	}

	if (self.state & WAIT)
	{
		if (items_ & IT_ROCKET_LAUNCHER)
		{
			if (self.ammo_rockets)
			{
				if (RocketSafe())
				{
					desired_weapon = IT_ROCKET_LAUNCHER;
					return;
				}
			}
		}
		else if (items_ & IT_LIGHTNING)
		{
			if (self.ammo_cells)
			{
				if (shaft_available)
				{
					desired_weapon = IT_LIGHTNING;
					return;
				}
			}
		}
	}

	if (shaft_available)
	{
		desired_weapon = IT_LIGHTNING;
		return;
	}

	if (self.enemy_dist <= 320)
	{
		if (!avoid_rockets)
		if (items_ & IT_GRENADE_LAUNCHER)
		if (self.ammo_rockets)
		if (RocketSafe())
		if (WaterCombat())
		{
			desired_weapon = IT_GRENADE_LAUNCHER;
			return;
		}
	}

	if (self.enemy_dist <= 600)
	{
		if (items_ & IT_SUPER_NAILGUN)
		if (self.ammo_nails)
		{
			desired_weapon = IT_SUPER_NAILGUN;
			return;
		}
		if (items_ & IT_SUPER_SHOTGUN)
		if (self.ammo_shells)
		{
			desired_weapon = IT_SUPER_SHOTGUN;
			return;
		}
		if (items_ & IT_NAILGUN)
		if (self.ammo_nails)
		{
			desired_weapon = IT_NAILGUN;
			return;
		}
	}

	if (self.ammo_shells)
	{	
		desired_weapon = IT_SHOTGUN;
		return;
	}
};

/*
============
SelectWeapon

============
*/
void() SelectWeapon =
{
	if (self.path_state & DM6_DOOR)
		return;
		
	if (self.state & HURT_SELF)
	{
		if (self.items & IT_ROCKET_LAUNCHER)
		if (self.ammo_rockets)
		if (self.health >= 50)
		if (self.super_damage_finished <= time)
		{
			if (self.weapon != IT_ROCKET_LAUNCHER)
			{
				self.botchose = 1;
				self.impulse = 7;
			}
			return;
		}
		self.state = self.state & NOT_HURT_SELF;
	}

	DesiredWeapon();
	CheckNewWeapon();
 };

/*
============
DelayUpdateWeapons

============
*/
void() DelayUpdateWeapons =
{
	weapon_refresh_time_ = time + 1;
	if (self.weapon_refresh_time > weapon_refresh_time_)
		self.weapon_refresh_time = weapon_refresh_time_;
};

/*
============
UpdateWeapons

============
*/
void() UpdateWeapons =
{
	self.weapon_refresh_time = 1000000;

	if (deathmatch != 4)
	{
		attackbonus = 0;
		items_ = self.items;
		if (items_ & IT_ROCKET_LAUNCHER)
		{
			firepower_ = self.ammo_rockets * 8;
			if (self.ammo_rockets)
				attackbonus = 50;
		}
		else if (items_ & IT_GRENADE_LAUNCHER)
		{
			firepower_ = self.ammo_rockets * 6;
			if (firepower_ > 50)
				firepower_ = 50;
		}
		else
			firepower_ = 0;

		if (items_ & IT_LIGHTNING)
		{
			firepower_ = firepower_ + self.ammo_cells;
			if (self.ammo_cells >= 10)
				attackbonus = attackbonus + 50;
		}

		if (items_ & IT_EITHER_NAILGUN)
			firepower_ = firepower_ + (self.ammo_nails * 0.1);

		if (items_ & IT_SUPER_SHOTGUN)
		{
			if (self.ammo_shells >= 50)
				firepower_ = firepower_ + 20;
			else
				firepower_ = firepower_ + self.ammo_shells * 0.4;
		}
		else
		{
			if (self.ammo_shells >= 25)
				firepower_ = firepower_ + 10;
			else
				firepower_ = firepower_ + self.ammo_shells * 0.4;
		}

		if (firepower_ > 100)
			firepower_ = 100;

		if (self.ammo_rockets >= 15)
			self.desire_rockets = 5;
		else
			self.desire_rockets = 20 - self.ammo_rockets;

		if (self.ammo_cells >= 37.5)
			self.desire_cells = 2.5;
		else
			self.desire_cells = (50 - self.ammo_cells) * 0.2;

		self.desire_rocketlauncher = 100 - firepower_;

		if (self.desire_rocketlauncher < self.desire_rockets)
			self.desire_rocketlauncher = self.desire_rockets;

		if (self.desire_rocketlauncher >= self.desire_cells)
			self.desire_lightning = self.desire_rocketlauncher;
		else
			self.desire_lightning = self.desire_cells;
		
		if (items_ & IT_ROCKET_LAUNCHER)
			self.desire_rockets = self.desire_grenadelauncher = self.desire_rocketlauncher;
		else
		{
			if (firepower_ >= 50)
				self.desire_grenadelauncher = 0;
			else
				self.desire_grenadelauncher = 50 - firepower_;

			if (self.desire_grenadelauncher < self.desire_rockets)
				self.desire_grenadelauncher = self.desire_rockets;

			if (items_ & IT_GRENADE_LAUNCHER)
				self.desire_rockets = self.desire_grenadelauncher;
		}

		if (items_ & IT_LIGHTNING)
			self.desire_cells = self.desire_lightning;

		if (firepower_ < 20)
		{
			self.desire_nails = 2.5 - (self.ammo_nails * 0.0125);
			if (self.ammo_shells >= 50)
				self.desire_shells = 0;
			else
				self.desire_shells = 2.5 - (self.ammo_shells * 0.05);
		}
		else
			self.desire_nails = self.desire_shells = 0;

		if (firepower_ >= 20)
			self.desire_supershotgun = 0;
		else
			self.desire_supershotgun = 20 - firepower_;

		if (self.desire_supershotgun >= self.desire_nails)
			self.desire_nailgun = self.desire_supernailgun = self.desire_supershotgun;
		else
			self.desire_nailgun = self.desire_supernailgun = self.desire_nails;

		if (self.desire_supershotgun < self.desire_shells)
			self.desire_supershotgun = self.desire_shells;

		if (items_ & IT_EITHER_NAILGUN)
			self.desire_nails = self.desire_supernailgun;

		if (items_ & IT_SUPER_SHOTGUN)
			self.desire_shells = self.desire_supershotgun;

		firepower_ = firepower_ + attackbonus;

		if (firepower_ > 100)
			firepower_ = 100;

		if (boomstick_only())
			self.desire_backpack = self.desire_supershotgun;

		if (self.super_damage_finished > time)
			firepower_ = firepower_ * 4;

		if (self.player_flag & ITEM_RUNE2_FLAG)
			firepower_ = firepower_ * 2;

		self.firepower = firepower_;
	}
	else
	{
		if (self.super_damage_finished > time)
			self.firepower = 800;
		else
			self.firepower = 100;

		if (self.player_flag & ITEM_RUNE2_FLAG)
			self.firepower = self.firepower * 2;
	}
};