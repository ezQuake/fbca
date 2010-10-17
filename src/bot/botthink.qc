/*
	bot/botthink.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
*/

/*
============
LookDoor

============
*/
void() LookDoor =
{
	search_item = findradius(self.origin, 300);
	while(search_item) {
		if (search_item.classname == "door") {
			if (search_item.state == STATE_BOTTOM) door_open = 0;
			else door_open = 1;
			return;
		}
		search_item = search_item.chain;
	}
};

/*
============
ThinkTime

============
*/
void() ThinkTime =
{
	self.button2_ = FALSE;

	if (time >= self.frogbot_nextthink)
	{
		//
		// FrogbotThink();
		//

		// think every 0.15 to 0.17 seconds

		self.frogbot_nextthink = self.frogbot_nextthink + 0.15 + (0.015 * random());
		if (self.frogbot_nextthink <= time)
			self.frogbot_nextthink = time + 0.16;

		if (time >= self.weapon_refresh_time)
			UpdateWeapons();

		if (time >= self.touch_marker_time)
		{
			marker_ = LocateMarker(self.origin);
			set_marker(self, marker_);
		}

	//	assertion: self.touch_marker != world

		if (self.touch_marker)
		if (self.state & AWARE_SURROUNDINGS)
		{
			enemy_ = self.enemy;
			look_object_ = self.look_object;
			realteam_ = self.realteam;
			touch_marker_ = self.touch_marker;
			lookahead_time_ = self.lookahead_time;
			linked_marker_ = self.linked_marker;
			origin_ = self.origin;
			goalentity_ = self.goalentity;

			if (self.frogbot)
			{

			//
			// SetEnemy
			//

				if (!(self.state & NOTARGET_ENEMY))
				{
					if (look_object_.client_)
					{
						if (look_object_.movetarget.owner == look_object_)
							dodge_missile = look_object_.movetarget;

						visible_object = look_object_;
						Visible_360();
						if (enemy_visible)
						{
							if (look_object_ == enemy_)
							{
								self.enemy_dist = vlen(look_object_.origin - origin_);
							}
							else
							{
								if (time >= self.enemy_time)
								{
									ClearLookObject(self);
									look_object_ = world;	// stop looking at friend
								}
							}
						}
						else
						{
							ClearLookObject(self);
							look_object_ = world;
						}
					}
					else if (enemy_)
					{
						visible_object = enemy_;
						if (goalentity_ == enemy_)
						{
							Visible_360();
							if (enemy_visible)
								LookEnemy();
							else
							{
								if (time >= self.enemy_time)
								{
									BestEnemy();
									if (enemy_ != goalentity_)
										self.goal_refresh_time = 0;
								}
							}
						}
						else
						{
							Visible_infront();
							if (enemy_visible)
								LookEnemy();
							else
							{
								if (time >= self.enemy_time)
									BestEnemy();
							}
						}
					}
					else
						BestEnemy();
				}

			//
			// SetGoalentity
			//

				if (time >= self.goal_refresh_time)
					UpdateGoal();


			//
			// SetPath
			//

				if (time >= self.linked_marker_time)
					self.old_linked_marker = world;
				
				if (self.old_linked_marker != touch_marker_)
					frogbot_marker_touch();


			//
			// SetArrows
			//

				if (time < self.arrow_time)
				{
					if (time < self.arrow_time2)
					{
						if (random() < 0.5)
						{
							linked_marker_ = self.old_linked_marker = self.linked_marker = touch_marker_;
							self.path_state = 0;
							self.linked_marker_time = time + 0.3;
						}
					}
				}
				else
				{
					dir_move = normalize(linked_marker_.absmin + linked_marker_.view_ofs - origin_);

					if (linked_marker_ == touch_marker_)
					{
						if (goalentity_ == touch_marker_)
						{
							if (touch_marker_.nextthink)
							// item not spawned
								dir_move = '0 0 0';
						}
						else
							dir_move = '0 0 0';
					}

					if (self.flags & FL_ONGROUND)
					if (!(self.path_state & NO_DODGE))
					{
						dodge_factor = 0;

						if (dodge_missile)
						{
							if (dodge_missile.owner.client_)
							{
								rel_pos = origin_ - dodge_missile.origin;
								if ((rel_pos * dodge_missile.v_forward_) > 0.7071067)
									dodge_factor = normalize(rel_pos) * dodge_missile.v_right_;
							}
							else
								dodge_missile = world;
						}

						if (look_object_.client_)
						if (!dodge_factor)
						{
							rel_pos = origin_ - look_object_.origin;
							makevectors(look_object_.v_angle);
							if ((rel_pos * v_forward) > 0)
								dodge_factor = normalize(rel_pos) * v_right;
						}

						if (dodge_factor)
						{
							if (dodge_factor < 0)
								dodge_factor = dodge_factor + 1;
							else
								dodge_factor = dodge_factor - 1;

							makevectors(self.v_angle);
							dir_move = dir_move + (random() * self.dodge_amount * dodge_factor * v_right);
						}
					}

					if (self.waterlevel <= 1)
						dir_move_z = 0;
					BestArrowForDirection();
					self.dir_move_ = dir_move;
					self.arrow = best_arrow;
				}

			//
			// SelectWeapon
			//

				SelectWeapon();
			}
			else
			{
				enemy_ = self.enemy;
				realteam_ = self.realteam;
				touch_marker_ = self.touch_marker;
				lookahead_time_ = self.lookahead_time;
				origin_ = self.origin;
				goalentity_ = self.goalentity;

				if (time >= self.enemy_time)
				{
					BestEnemy();
				}
// FIXME: what happens when map in partial state?
/*
				if (time >= self.goal_refresh_time)
					UpdateGoal();
*/
			}
		}
		else
		{
			self.goal_refresh_time = 0;

			if (self.frogbot)
			{
				self.old_linked_marker = world;
				self.state = self.state | AWARE_SURROUNDINGS;
			}
			else
			{
				if (markers_loaded)
					self.state = self.state | AWARE_SURROUNDINGS;
			}
		}

		CheckCombatJump();
		BotInLava(); // ParboiL

	}
	if (self.frogbot)
	{
		if (!(self.weapon & IT_CONTINUOUS))
		if (!self.rocketjumping)
			self.button0_ = FALSE;

		if (!game_arena)
		if (numberofclients == 2)
			AttackRespawns();

		if (mapname == "povdmm4")
			LookDoor();

		if (time >= self.fire_nextthink)
		{
		// fire think every self.firing_reflex seconds

			self.fire_nextthink = self.fire_nextthink + (self.firing_reflex * (0.95 + (0.1 * random())));
			if (self.fire_nextthink <= time)
				self.fire_nextthink = time + (self.firing_reflex * (0.95 + (0.1 * random())));


			look_object_ = self.look_object;
			enemy_ = self.enemy;
			a_attackfix();

			if (look_object_)
			{

			//
			// SetMouse
			//

				origin_ = self.origin;

				if (look_object_.client_)
				{
					rel_pos = look_object_.origin - origin_;
					rel_dist = vlen(rel_pos);

					if (self.weapon & IT_VELOCITY)
					{
						if (self.weapon & IT_GRENADE_LAUNCHER)
							rel_time = rel_dist / 600;
						else
						{
							rel_time = rel_dist / 1000;
							if (self.player_flag & ITEM_RUNE3_FLAG)
							{
								if (self.weapon & IT_EITHER_NAILGUN)
									rel_time = rel_time * 0.5;
							}
						}

						if (rel_time > 0.5)
							rel_time = 0.5;

						if (enemy_)
						{
						enemy_.oldsolid = enemy_.solid;
						enemy_.solid = SOLID_NOT;

						fallheight = enemy_.origin_z - 56 + enemy_.velocity_z * rel_time;
						testplace = enemy_.origin + '0 0 36' + enemy_.velocity * rel_time;
						PredictSpot();
						if (predict_spot)
						{
							self.predict_origin = dropper.origin;
							self.predict_success = TRUE;
						}
						else
						{
							dir_forward = self.predict_origin - enemy_.origin;
							dir_forward_z = 0;
							if ((vlen(dir_forward) > half_sv_maxspeed) || ((dir_forward * enemy_.velocity) <= 0))
							{
								self.predict_origin = testplace;
								self.predict_success = FALSE;
							}
							else
								self.predict_success = TRUE;
						}

						enemy_.solid = enemy_.oldsolid;

						if (look_object_ == enemy_)
							rel_pos = self.predict_origin - self.origin;
						}
					}
				}
				else
				{
					rel_pos = look_object_.absmin + look_object_.view_ofs - origin_;
					rel_dist = vlen(rel_pos);

					if (self.path_state & DM6_DOOR)
					{
						if (dm6_door.takedamage)
							rel_pos_z = rel_pos_z - 38;
						else
						{
							self.path_state = self.path_state - DM6_DOOR;
							self.state = self.state & NOT_NOTARGET_ENEMY;
						}
					}
					else
					{
						if (rel_dist < 160)
						{
							rel_pos2_x = rel_pos_x;
							rel_pos2_y = rel_pos_y;
							rel_pos2 = 160 * normalize(rel_pos2);
							rel_pos_x = rel_pos2_x;
							rel_pos_y = rel_pos2_y;
							rel_dist = 160;
						}
					}
				}

				if (self.weapon == IT_ROCKET_LAUNCHER)
				{
					if (rel_dist > 96)
					{
						traceline(origin_ + '0 0 16', origin_ + rel_pos - '0 0 22', TRUE, self);
						if (trace_fraction == 1)
							rel_pos_z = rel_pos_z - 38;
					}
				}

				// assertion: rel_dist != 0

				rel_dir = normalize(rel_pos);
				rel_hor_dir = rel_pos;
				rel_hor_dir_z = 0;
				rel_hor_dir = normalize(rel_hor_dir);
				hor_component = rel_dir * rel_hor_dir;
				mouse_vel = 57.29578 / rel_dist;	// 57.29578 = 180/PI

				// rel_hor_dir and '0 0 1' are an orthogonal axis
				// hor_component is the rel_hor_dir (horizontal) component of rel_dir
				// rel_dir_z is the '0 0 1' (vertical) component of rel_dir

				pitch_tangent = rel_dir_z * rel_hor_dir;
				pitch_tangent_z = 0 - hor_component;

				// pitch_tangent is the tangent normal vector to pitch angular velocity

				pitch_tangent = pitch_tangent * mouse_vel;

				// pitch_tangent has been scaled according to view object distance

				yaw_tangent_x = 0 - rel_hor_dir_y;
				yaw_tangent_y = rel_hor_dir_x;
				yaw_tangent_z = 0;

				// yaw_tangent is the tangent normal vector to yaw angular velocity

				yaw_tangent = yaw_tangent * mouse_vel;

				// yaw_tangent has been scaled according to view object distance

				self.track_pitchspeed = (look_object_.velocity - self.velocity) * pitch_tangent;
				self.track_yawspeed = (look_object_.velocity - self.velocity) * yaw_tangent;

				desired_angle = vectoangles(rel_pos);
				if (desired_angle_x > 180)
					desired_angle_x = 360 - desired_angle_x;
				else
					desired_angle_x = 0 - desired_angle_x;


				desired_angle_x = (rint(desired_angle_x / 1.40625));
				desired_angle_y = (rint(desired_angle_y / 1.40625));
				desired_angle = desired_angle * 1.40625;

				if (self.state & HURT_SELF)
					desired_angle_x = 180;

				angle_error = desired_angle - self.v_angle;
				angle_error_x = angle_error_x - (1 - self.fast_aim) * (self.pitchspeed * self.firing_reflex);
				angle_error_y = angle_error_y - (1 - self.fast_aim) * (self.yawspeed * self.firing_reflex);

				if (angle_error_y >= 180)
					angle_error_y = angle_error_y - 360;
				else if (angle_error_y < -180)
					angle_error_y = angle_error_y + 360;

				self.track_pitchspeed = self.track_pitchspeed + self.fast_aim * angle_error_x / self.firing_reflex;
				self.track_yawspeed = self.track_yawspeed + self.fast_aim * angle_error_y / self.firing_reflex;

				self.pitchaccel = (1 - self.fast_aim) * angle_error_x / self.firing_reflex;
				self.yawaccel = (1 - self.fast_aim) * angle_error_y / self.firing_reflex;

				if (self.pitchaccel > 0)
					self.pitchaccel = self.pitchaccel + 5400;
				else if (self.pitchaccel < 0)
					self.pitchaccel = self.pitchaccel - 5400;

				if (self.yawaccel > 0)
					self.yawaccel = self.yawaccel + 5400;
				else if (self.yawaccel < 0)
					self.yawaccel = self.yawaccel - 5400;
				if (!self.rocketjumping)
				SetFireButton();
			}
		}
	}
};