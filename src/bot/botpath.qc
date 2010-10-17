/*
	bot/botpath.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2001 DMSouL
	Copyright (C) 2000-2007 ParboiL
*/

/*
============
EvalPath

============
*/
void() EvalPath =
{
	if (test_marker.classname == "door")
	if (test_marker.state != STATE_BOTTOM)
		return;
	if (a_evalpath())
		return;
	if (!path_normal)
	{
		if (!(description & REVERSIBLE))
			return;
	}
 	if (test_marker == dm6_door)
	{
		if (!dm6_door.takedamage)
			return;	// door open
	}
	marker_pos = test_marker.absmin + test_marker.view_ofs;

	if (description & DM6_DOOR)
	{
		if (dm6_door.origin_x > -64)
			return;	// door not open enough
	}
	if (description & ROCKET_JUMP)
	if (!able_rj())
		return; // SOUL

	same_dir = self_dir * normalize(marker_pos - origin_);
	path_score = same_dir + random();

	if (time < test_marker.arrow_time)
	{
		avoid = TRUE;
	}
	else
	{
		avoid = FALSE;
		if (rocket_alert)
		{
			if (vlen(marker_pos - rocket_endpos) < 200)
			{
				traceline(rocket_endpos, marker_pos, TRUE, self);
				if (trace_fraction == 1)
					avoid = TRUE;
			}
		}
	}

	if (beQuiet)
	{
	// try not to make noise.
	// items and respawn/teleport destinations
		if (test_marker.pickup)
		if (!test_marker.nextthink)	// item sitting there
		if (test_marker != goalentity_marker)
		if (test_marker.pickup())
			path_score = path_score - 2.5;
	}

	if (avoid)
	{
		path_score = path_score - 2.5;
	}
	else
	{
		if (goalentity_marker)
		{
			from_marker = test_marker;
				path_normal = self.path_normal_;
			goalentity_marker.zone_marker();
			goalentity_marker.sub_arrival_time();
			total_goal_time = path_time + traveltime;
			if (total_goal_time > goal_late_time)
			{
				if (traveltime < current_goal_time)	// improve position
					path_score = path_score + lookahead_time_ - total_goal_time;
				else if (total_goal_time > current_goal_time_125) // don't go way off track
					path_score = path_score - total_goal_time;
			}
		}
	}

	if (path_score > best_score)
	{
		best_score = path_score;
		linked_marker_ = test_marker;
		new_path_state = description;
	}
};

/*
============
EvalLook

============
*/
void() EvalLook =
{
	look_score = (dir_look * normalize((from_marker.absmin + from_marker.view_ofs) - linked_marker_origin));
	look_score = look_score + random();

	if (look_score > best_score)
	{
		best_score = look_score;
		look_object_ = from_marker;
	}
};

/*
============
EvalCloseRunAway

============
*/
void() EvalCloseRunAway =
{
	from_marker = enemy_touch_marker;
	to_marker.zone_marker();
	to_marker.sub_arrival_time();
	traveltime2 = traveltime;

	from_marker = touch_marker_;
	to_marker.zone_marker();
	to_marker.sub_arrival_time();

	if (look_traveltime)
		test_away_score = random() * RA_time * ((traveltime2 * traveltime2) - (look_traveltime_squared + (traveltime * traveltime))) / (look_traveltime * traveltime);
	else
		test_away_score = random() * RA_time * (traveltime2 - traveltime);

	if (test_away_score > best_away_score)
	{
		best_away_marker = to_marker;
		best_away_score = test_away_score;
	}
};

/*
============
frogbot_marker_touch

============
*/

void() frogbot_marker_touch =
{
	if (self.path_state & WAIT_GROUND)
	if (!(self.flags & FL_ONGROUND))
		return;

	goalentity_marker = goalentity_.touch_marker;

	if (self.state & RUNAWAY)	// FIXME: consider goals
		goalentity_marker = world;

	if (linked_marker_ == touch_marker_)
	{
		if (goalentity_ == touch_marker_)
		{
			if (!touch_marker_.nextthink)
			// item hasn't been touched yet
				return;
		}
		else if (goalentity_marker == touch_marker_)
		{
			if (goalentity_.classname == "dynamic_item")
			{
				if (IsVisible(goalentity_))
				{ 
					linked_marker_ = self.linked_marker = goalentity_;
					self.linked_marker_time = time + 5;
					self.old_linked_marker = touch_marker_;
					return;
				}
			}
		}
	}
	else
	{
		from_marker = self.old_linked_marker;
		to_marker = touch_marker_;
		if (ExistsPath())
		{
			from_marker = touch_marker_;
			to_marker = linked_marker_;
			if (ExistsPath())
			{
				self.path_state = new_path_state;
				return;	// intermediate marker
			}
		}

		self.state = self.state & NOT_HURT_SELF;
	}

//
// best path
//

	self.path_normal_ = TRUE;	// FIXME: AI set this

	if (self.state & RUNAWAY)
	{
		enemy_touch_marker = enemy_.touch_marker;

		if (enemy_touch_marker)
		{
			best_away_marker = world;
			best_away_score = 0;

			to_marker = touch_marker_;
			enemy_touch_marker.sight_from_time();
			look_traveltime_squared = look_traveltime * look_traveltime;

			path_normal = TRUE;

			to_marker = touch_marker_.RA0;
			if (to_marker)
			{
				RA_time = touch_marker_.RA0_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA1;
			if (to_marker)
			{
				RA_time = touch_marker_.RA1_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA2;
			if (to_marker)
			{
				RA_time = touch_marker_.RA2_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA3;
			if (to_marker)
			{
				RA_time = touch_marker_.RA3_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA4;
			if (to_marker)
			{
				RA_time = touch_marker_.RA4_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA5;
			if (to_marker)
			{
				RA_time = touch_marker_.RA5_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA6;
			if (to_marker)
			{
				RA_time = touch_marker_.RA6_time;
				EvalCloseRunAway();
			}

			to_marker = touch_marker_.RA7;
			if (to_marker)
			{
				RA_time = touch_marker_.RA7_time;
				EvalCloseRunAway();
			}

			if (!best_away_marker)
				best_away_marker = touch_marker_;

			self.goal_respawn_time = 0;
			goalentity_marker = best_away_marker;

			self.path_normal_ = TRUE;
		}
	}

	if (random () < 0.5)
	if (self.items & IT_ROCKET_LAUNCHER)
	if (self.ammo_rockets)
	if ((self.firepower < enemy_.firepower) && (self.armorvalue < enemy_.armorvalue))
	if (!avoid)
	{
		to_marker = enemy_.touch_marker;
		if (to_marker)
		{
			from_marker = touch_marker_;
			from_marker.higher_sight_from_marker();
			if (!look_marker)
			{
				self._highermarker = 0;
				HigherSightMarker();
			}
			if (look_marker)
			{
				goalentity_marker = look_marker;
				self._highermarker = 1;
			}
		}
	}

	if (duel_mode)
	if (enemy_.weapon == IT_GRENADE_LAUNCHER)
	if (enemy_.ammo_rockets > 6)
	if ((self.origin_z + 18) < (enemy_.absmin_z + enemy_.view_ofs_z))
	if (vlen(self.origin - enemy_.origin) < 200)
	if (enemy_.button0)
	{
		to_marker = enemy_.touch_marker;
		if (to_marker)
		{
			from_marker = touch_marker_;
			from_marker.higher_sight_from_marker();
			if (!look_marker)
			{
				self._highermarker = 0;
				HigherSightMarker();
			}
			if (look_marker)
			{
				goalentity_marker = look_marker;
				self._highermarker = 1;
			}
		}
	}

	best_score = -1000000;
	self_dir = normalize(self.velocity);

	rocket_alert = FALSE;

	if (enemy_.items & IT_ROCKET_LAUNCHER && !(self.items & IT_INVULNERABILITY))
	{
		if (enemy_.attack_finished <= time + 0.2)
		{
			if (enemy_.ammo_rockets)
			{
				if (random() < 0.5)
				{
					src = enemy_.origin + '0 0 16';
					traceline(src, origin_, TRUE, self);
					if (trace_fraction != 1)
					{
						rocket_alert = TRUE;
						makevectors(enemy_.v_angle);
						traceline(src, src + (v_forward * 500), TRUE, self);
						rocket_endpos = trace_endpos;
					}
				}
			}
		}
	}

	if (look_object_ == enemy_)
		beQuiet = FALSE;

	else
	{
		if (enemy_)
			beQuiet = !self.allowedMakeNoise;
		else
			beQuiet = FALSE;
	}

	if (goalentity_marker)
	{
		from_marker = touch_marker_;

		path_normal = self.path_normal_;
		goalentity_marker.zone_marker();
		goalentity_marker.sub_arrival_time();
		current_goal_time = traveltime;
		current_goal_time_125 = current_goal_time + 1.25;
		if (current_goal_time < 2.5)
			goal_late_time = (self.goal_respawn_time - (random() * 5)) - time;
		else
			goal_late_time = (self.goal_respawn_time - (random() * 10))- time;

		test_marker = touch_marker_;
		if (test_marker)
		{
			description = 0;
			path_time = 0;
			EvalPath();
		}
	}

	test_marker = touch_marker_.P0;
	if (test_marker)
	{
		description = touch_marker_.D0;
		path_time = touch_marker_.P0_time;
		EvalPath();
	}

	test_marker = touch_marker_.P1;
	if (test_marker)
	{
		description = touch_marker_.D1;
		path_time = touch_marker_.P1_time;
		EvalPath();
	}

	test_marker = touch_marker_.P2;
	if (test_marker)
	{
		description = touch_marker_.D2;
		path_time = touch_marker_.P2_time;
		EvalPath();
	}

	test_marker = touch_marker_.P3;
	if (test_marker)
	{
		description = touch_marker_.D3;
		path_time = touch_marker_.P3_time;
		EvalPath();
	}

	test_marker = touch_marker_.P4;
	if (test_marker)
	{
		description = touch_marker_.D4;
		path_time = touch_marker_.P4_time;
		EvalPath();
	}

	test_marker = touch_marker_.P5;
	if (test_marker)
	{
		description = touch_marker_.D5;
		path_time = touch_marker_.P5_time;
		EvalPath();
	}

	test_marker = touch_marker_.P6;
	if (test_marker)
	{
		description = touch_marker_.D6;
		path_time = touch_marker_.P6_time;
		EvalPath();
	}

	test_marker = touch_marker_.P7;
	if (test_marker)
	{
		description = touch_marker_.D7;
		path_time = touch_marker_.P7_time;
		EvalPath();
	}

	if (touch_marker_.classname == "door")	// FIXME: should this include doors?
	{
		if (deathtype != "squish")
		if (linked_marker_.absmin_z + linked_marker_.view_ofs_z > self.origin_z + 18)
		{
			// check if fully on lift - if not then continue moving to linked_marker_
			if (teamplay)
			{
				if (self.state & HELP_TEAMMATE)
					self.state = self.state - HELP_TEAMMATE;
			}
			if (self.absmin_x >= touch_marker_.absmin_x)
			if (self.absmax_x <= touch_marker_.absmax_x)
			if (self.absmin_y >= touch_marker_.absmin_y)
			if (self.absmax_y <= touch_marker_.absmax_y)
			{
				linked_marker_ = self.linked_marker = touch_marker_;
				self.path_state = 0;
				self.linked_marker_time = time + 5;
				self.old_linked_marker = world;
			}
			return;
		}
	}

	if (self.state & WAIT)
	{
		if (!look_object_.client_)
		{
			traceline(linked_marker_.absmin + linked_marker_.view_ofs + '0 0 32', look_object_.absmin + look_object_.view_ofs + '0 0 32', TRUE, self);
			if (trace_fraction != 1)
			{	
				linked_marker_ = touch_marker_;
				new_path_state = 0;
			}
		}
		else
			self.state = self.state - (self.state & WAIT); 
	}

	if (mapname == "dm3")
	{
		if (numberofclients > 1)
		if (teamplay && deathmatch <= 3)
		if (self.items & (IT_ROCKET_LAUNCHER | IT_LIGHTNING) && !self.bot_evade)
		if ((self.health > 60) && (self.armorvalue > 80))
		if ((self.ammo_cells > 15) || (self.ammo_rockets > 3))
		{
			search_entity = find(world, classname, "item_artifact_super_damage");
			if (search_entity != world)
			if (random() < 0.5)
			{
				if (search_entity.origin_z <= self.origin_z + 18)
				if (vlen(search_entity.origin - self.origin) < 200)
				{
					if (random() < 0.9)
					{
						self.camp_state = self.camp_state | CAMPBOT;
						linked_marker_ = touch_marker_;
					}
				}
				else 
					self.camp_state = self.camp_state - (self.camp_state & CAMPBOT);
			}
		}
	}
	else if (mapname == "dm4")
	{
		if (duel_mode)
		if (self.items & (IT_ROCKET_LAUNCHER | IT_LIGHTNING) && !self.bot_evade)
		if ((self.health > 50) && (self.armorvalue > 30))
		if ((self.ammo_cells > 15) || (self.ammo_rockets > 3))
		{
			if (random() < 0.985) 
			{
				if ((enemy_.origin_x < 700) && (vlen('448 -176 60' - self.origin) < 200))
				{
					self.camp_state = self.camp_state | CAMPBOT;
					linked_marker_ = touch_marker_;
				}
				else if ((enemy_.origin_x >= 700) && (vlen('280 -330 60' - self.origin) < 200))
				{
					self.camp_state = self.camp_state | CAMPBOT;
					linked_marker_ = touch_marker_;
				}
				else
					self.camp_state = self.camp_state - (self.camp_state & CAMPBOT);
			}
		}
	}
	else if (mapname == "dm6")
	{
		if (numberofclients > 1)
		if (self.items & (IT_ROCKET_LAUNCHER | IT_LIGHTNING) && !self.bot_evade)
		if ((self.health > 80) && (self.armorvalue > 100))
		if ((self.ammo_cells > 15) || (self.ammo_rockets > 3))
		{
			search_entity = find(world, classname, "item_armorInv");
			if (search_entity != world)
			{
				if (search_entity.origin_z <= self.origin_z + 18)
				if (vlen(search_entity.origin - self.origin) < 200)
				{
					if (random() < 0.9)
					{
						self.camp_state = self.camp_state | CAMPBOT;
						linked_marker_ = touch_marker_;
					}
				}
				else
					self.camp_state = self.camp_state - (self.camp_state & CAMPBOT);
			}
		}
	}

	self.linked_marker = linked_marker_;
	self.path_state = new_path_state;

	if (touch_marker_ == linked_marker_)
		self.linked_marker_time = time + 0.3;
	else
		self.linked_marker_time = time + 5;

	self.old_linked_marker = touch_marker_;

//
// CheckTasks
//

	if (goalentity_marker.Z_ == 1)	// task zone
	{
		if (touch_marker_.Z1_task & DM6_DOOR)
		{
			if (dm6_door.takedamage)
			{
				direction = normalize(dm6_door.absmin + dm6_door.view_ofs - origin_ - '0 0 40');
				src = origin_ + '0 0 16';

				traceline (src, src + direction*2048, FALSE, self);
				if (trace_ent == dm6_door)
					self.path_state = self.path_state | DM6_DOOR;
			}
			else
				self.path_state = self.path_state - (self.path_state & DM6_DOOR);
		}
	}

	self.state = self.state & NOT_NOTARGET_ENEMY;
	if (self.flags & FL_ONGROUND && self.wasinwater)
	{
		self.wasinwater = FALSE;
		self.path_state = self.path_state - (self.path_state & WATERJUMP_);
		self.state = self.state & NOT_NOTARGET_ENEMY;	
	}
	if (self.path_state & WATERJUMP_)
	{
		self.wasinwater = TRUE;
		self.state = self.state | NOTARGET_ENEMY;
		look_object_ = self.linked_marker;
		self.look_object = look_object_;
		if (random() < 0.003)
			self.button2_ = TRUE;
		return;
	}
	if (self.path_state & DM6_DOOR)
	{
		self.state = self.state | NOTARGET_ENEMY;
		look_object_ = dm6_door;
		self.look_object = look_object_;
		return;
	}
	if (look_object_.client_)
		return;

//
//	BestLook
//

	if ((self.waterlevel == 2) || (self.waterlevel == 1)) // SOUL
	{
		self.look_object = self.linked_marker;
		return;
	}
	if (random() < self.look_anywhere)
	{
		// FIXME: if no enemy then replace with goalentity

		from_marker = enemy_.touch_marker;
		if (!from_marker)
			from_marker = goalentity_marker;

		if (from_marker)
		{
			to_marker = linked_marker_;
			from_marker.sight_from_marker();

			if (look_marker)
			{
				path_normal = TRUE;
				look_marker.zone_marker();
				look_marker.sub_arrival_time();
				look_traveltime = traveltime;
			}
			else
				SightMarker();

			if (look_marker)
			{
				to_marker = from_marker;
				from_marker = linked_marker_;

				path_normal = TRUE;
				to_marker.zone_marker();
				to_marker.sub_arrival_time();

				if (look_traveltime < traveltime)
				{
					self.look_object = look_object_ = look_marker;
					self.predict_shoot = TRUE;
					return;
				}
			}
		}
	}

	if (touch_marker_ == linked_marker_)
		dir_look = '0 0 0';
	else
	{
		linked_marker_origin = linked_marker_.absmin + linked_marker_.view_ofs;
		dir_look = normalize(linked_marker_origin - origin_);
	}
	makevectors(self.v_angle);
	dir_look = normalize((self.velocity * inv_sv_maxspeed) + v_forward + dir_look);
	linked_marker_origin = linked_marker_.absmin + linked_marker_.view_ofs;

	best_score = -1000000;

	from_marker = linked_marker_.P0;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P1;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P2;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P3;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P4;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P5;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P6;
	if (from_marker)
		EvalLook();

	from_marker = linked_marker_.P7;
	if (from_marker)
		EvalLook();

	self.look_object = look_object_;
	self.predict_shoot = FALSE;
};