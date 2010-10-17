/*
	bot/botphys.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
*/

/*
============
obstruction

Sets self.obstruction_normal to be horizontal normal direction into wall obstruction encountered
during quake physics (ie. between PlayerPreThink and PlayerPostThink)
============
*/
void() obstruction =
{
	delta_velocity = self.oldvelocity - self.velocity;
	if (delta_velocity_x < 0.1)
	if (delta_velocity_x > -0.1)
	if (delta_velocity_y < 0.1)
	if (delta_velocity_y > -0.1)
	{
		self.obstruction_normal = '0 0 0';
		return;
	}

	if (!(self.flags & FL_ONGROUND))
	if ((!self.waterlevel) || (self.flags & FL_WATERJUMP))
	{
		self.obstruction_normal = '0 0 0';
		return;
	}

	if (delta_velocity_z < 0.1)
	if (delta_velocity_z > -0.1)
	{
		hor_velocity = self.velocity;
		hor_velocity_z = 0;

		if (hor_velocity != '0 0 0')
		{
			if (self.player)
			{
				hor_direction = normalize(hor_velocity);
				hor_velocity = hor_direction * (hor_direction * self.oldvelocity);
				self.velocity_x = hor_velocity_x;
				self.velocity_y = hor_velocity_y;
			}

			self.velocity_normal = self.oldvelocity - hor_velocity;
			self.velocity_normal_z = 0;
			self.obstruction_normal = normalize(self.velocity_normal);
			return;
		}

		hor_velocity = self.oldvelocity;
		hor_velocity_z = 0;
		if (hor_velocity != '0 0 0')
		{
			self.velocity_normal = self.oldvelocity - (self.obstruction_normal * (self.obstruction_normal * self.oldvelocity));
			self.velocity_normal_z = 0;
			self.obstruction_normal = normalize(self.velocity_normal);
			return;
		}
	}
	self.obstruction_normal = '0 0 0';
};

/*
============
VelocityForArrow

self is a Frogbot.
Sets self.velocity according to current state and the value of self.arrow.
============
*/
void() VelocityForArrow =
{
	turning_speed = 0;

		// first check air circle turning
		if (!self.waterlevel)
		{
			if (time > self.arrow_time2)
			{
				hor_velocity = self.velocity;
				hor_velocity_z = 0;
				hor_speed = vlen(hor_velocity);

				if ((hor_speed > 100) || (self.path_state & AIR_ACCELERATION))
				{
					hor_normal_vec_x = 0 - self.velocity_y;
					hor_normal_vec_y = self.velocity_x;
					// (hor_normal_vec_z = 0;)
					hor_normal_vec = normalize(hor_normal_vec);

					rel_pos = (self.linked_marker.absmin + self.linked_marker.view_ofs) - self.origin;
					rel_pos_z = 0;
					if (rel_pos * rel_pos != 0)
					turning_speed = 114.59156 * hor_speed * (rel_pos * hor_normal_vec) / (rel_pos * rel_pos);	// 114.59156 = 360 / PI

					if (fabs(turning_speed) > 270)
					{
						if (self.path_state & AIR_ACCELERATION)
						{
							if (turning_speed > 0)
								turning_speed = 270;
							else
								turning_speed = -270;
						}
						else
							turning_speed = 0;
					}

					if (!(self.flags & FL_ONGROUND))
					{
						velocity_hor_angle_y = vectoyaw(hor_velocity) + (turning_speed * frametime);
						makevectors(velocity_hor_angle);

						desired_accel = (v_forward * hor_speed) - hor_velocity;

						dir_forward = normalize(desired_accel);
						accel_forward = vlen(desired_accel);

						if (accel_forward > max_accel_forward)
							accel_forward = max_accel_forward;

						velocity_forward = self.velocity * dir_forward;

						if ((velocity_forward + accel_forward) > 30)
						{
							accel_forward = 30 - velocity_forward;
							if (accel_forward < 0)
								accel_forward = 0;
						}

						self.velocity = self.velocity + (accel_forward * dir_forward);
						return;
					}
				}
			}
		}

		arrow_ = self.arrow;

	if (!arrow_)
	{
		if (self.waterlevel <= 1)
		{
			return;
		}
		else
		{
			if (self.swim_arrow)
			{
				if (self.swim_arrow == UP)
					dir_forward = '0 0 1';
				else
					dir_forward = '0 0 -1';

				current_maxspeed = 200;
			}
			else
			{
				dir_forward = '0 0 -1';
				current_maxspeed = 42;
			}
		}
	}
	else
	{
		makevectors(self.v_angle);

		if (arrow_ & FORWARD)
		{
			if (arrow_ == FORWARD)
				dir_forward = v_forward;
			else if (arrow_ == FORWARD_LEFT)
				dir_forward = (v_forward * 0.7525767) - (v_right * 0.6585046);
			else	// (arrow_ == FORWARD_RIGHT)
				dir_forward = (v_forward * 0.7525767) + (v_right * 0.6585046);

			current_maxspeed = sv_maxspeed;
		}
		else if (arrow_ & BACK)
		{
			if (arrow_ == BACK)
				dir_forward = '0 0 0' - v_forward;
			else if (arrow_ == BACK_LEFT)
				dir_forward = '0 0 0' - (v_forward * 0.7525767) - (v_right * 0.6585046);
			else	// (arrow_ == BACK_RIGHT)
				dir_forward = (v_right * 0.6585046) - (v_forward * 0.7525767);

			current_maxspeed = sv_maxspeed;
		}
		else
		{
			if (arrow_ == LEFT)
				dir_forward = '0 0 0' - v_right;
			else	// (arrow_ == RIGHT)
				dir_forward = v_right;

			current_maxspeed = sv_maxstrafespeed;
		}

		if (self.waterlevel <= 1)
		{
			dir_forward_z = 0;
			dir_forward = normalize(dir_forward);
		}
		else
		{
			if (self.swim_arrow)
			{
				if (self.swim_arrow == UP)
					dir_forward = normalize(dir_forward + '0 0 0.5');
				else
					dir_forward = normalize(dir_forward + '0 0 -0.5');
			}

			current_maxspeed = 0.7 * current_maxspeed;
		}
	}

	accel_forward = sv_accelerate_frametime * current_maxspeed;

	velocity_forward = self.velocity * dir_forward;

	if (!(self.flags & FL_ONGROUND))
		if (self.waterlevel <= 1)
			if (current_maxspeed > 30)
				current_maxspeed = 30;

	if ((velocity_forward + accel_forward) > (current_maxspeed))
	{
		accel_forward = current_maxspeed - velocity_forward;
		if (accel_forward < 0)
			accel_forward = 0;
	}

	self.velocity = self.velocity + (accel_forward * dir_forward);
};

/*
============
DoFriction

============
*/
void() DoFriction =
{
	if (self.flags & FL_ONGROUND)
	{
		hor_velocity = self.velocity;
		hor_velocity_z = 0;
		hor_speed = vlen(hor_velocity);

		// sv_stopspeed = 100

		if (hor_speed > 100)
		{
			self.velocity_x = self.velocity_x * inv_sv_friction_frametime;
			self.velocity_y = self.velocity_y * inv_sv_friction_frametime;
			return;
		}
		else
		{
			friction_factor = (1 - (sv_friction_frametime_100 / hor_speed));
			if (friction_factor < 0)
				friction_factor = 0;

			self.velocity_x = self.velocity_x * friction_factor;
			self.velocity_y = self.velocity_y * friction_factor;
			return;
		}
	}
};

/*
============
ApplyFriction

============
*/
void() ApplyFriction =
{
	if (self.flags & FL_WATERJUMP)
	{
		self.velocity_x = self.movedir_x;
		self.velocity_y = self.movedir_y;

		if ((!self.waterlevel) || (time >= self.teleport_time))
		{
			self.flags = self.flags - FL_WATERJUMP;
			self.teleport_time = 0;
		}
	}
	else
	{
		if (self.waterlevel <= 1)
			DoFriction();
		else	// do water friction
			self.velocity = self.velocity * inv_sv_friction_frametime;
	}
};

/*
============
FrogbotPrePhysics1

============
*/
void() FrogbotPrePhysics1 =
{
	frametime = real_frametime;

	// Remove_Obstacles for AvoidHazards
	if (hazard_time)
	{
		self = first_client;
		while (self)
		{
			self.oldsolid = self.solid;
			self.solid = SOLID_NOT;
			self = self.next;
		}
	}

	self = first_client;
	while (self)
	{
		if (self.frogbot)
		{
			if (self.movetype == MOVETYPE_STEP)
				ApplyFriction();

			if (self.takedamage)
			{
				oldvelocity_ = self.velocity;
				VelocityForArrow();
				if (hazard_time)
					AvoidHazards();
			}
		}

		self = self.next;
	}

	if (hazard_time)
	{
		// Restore_Obstacles for AvoidHazards
		self = first_client;
		while (self)
		{
			self.solid = self.oldsolid;
			self = self.next;
		}
	}
};

/*
============
FrogbotPrePhysics2

============
*/
void() FrogbotPrePhysics2 =
{
	frametime = real_frametime;
	no_bots_stuck = TRUE;

	self = first_client;
	while (self)
	{
		if (!self.player)
		{
			content1 = pointcontents(self.origin + '0 0 -24');
			if (content1 == CONTENT_EMPTY)
			{
				self.oldwaterlevel = 0;
				self.oldwatertype = CONTENT_EMPTY;
			}
			else if (content1 == CONTENT_SOLID)
			{
				unstick_time = unstick_time + frametime;
				if (unstick_time <= numberofclients)
				{
					no_bots_stuck = FALSE;
					self.velocity_z = JUMPSPEED;
				}
				else
				{
					self.botchose = 1;
					self.impulse = CLIENTKILL;
				}
			}
			else
			{
				content2 = pointcontents(self.origin + '0 0 4');
				if (content2 == CONTENT_EMPTY)
				{
					self.oldwaterlevel = 1;
					self.oldwatertype = content1;
				}
				else
				{
					content3 = pointcontents(self.origin + '0 0 22');
					if (content3 == CONTENT_EMPTY)
					{
						self.oldwaterlevel = 2;
						self.oldwatertype = content2;
					}
					else
					{
						self.oldwaterlevel = 3;
						self.oldwatertype = content3;
					}
				}
			}

			if (self.takedamage)
			{
				PlayerPreThink_apply();

				if (self.flags & FL_ONGROUND)
				{
					if (self.velocity_z < 0)
						self.oldvelocity_z = self.velocity_z = 0;

					if (self.fl_ontrain)
						self.fl_ontrain = FALSE;
					else
						self.flags = self.flags - FL_ONGROUND;
				}
				else
				{
					self.jump_flag = self.velocity_z;
					self.fl_ontrain = FALSE;
				}

				if ((self.oldwaterlevel >= 2) || (self.flags & FL_WATERJUMP))
					self.velocity_z = self.velocity_z + (800 * frametime);	// 800 = sv_gravity

				self.oldorigin = self.origin;
				self.waterlevel = self.watertype = 0;
			}
			else
			{
				if (!intermission_running)
				if (self.deadflag >= DEAD_DEAD)
					PlayerDeathThink ();
			}
		}

		self = self.next;
	}

	if (no_bots_stuck)
		unstick_time = 0;

};

/*
============
thud_touch

Stops thud landing sound
============
*/
void() thud_touch =
{
	if (self.flags & FL_ONGROUND)
	{
		self.flags = self.flags - FL_ONGROUND;
		self.fl_thud = TRUE;
	}
};

/*
============
FrogbotPostPhysics

============
*/
void() FrogbotPostPhysics1 =
{
	frametime = real_frametime;

	self = first_client;
	while (self)
	{
		if (self.movetype == MOVETYPE_STEP)
		{
			if (self.fl_thud)
			{
				self.flags = self.flags | FL_ONGROUND;
				self.fl_thud = FALSE;
			}

			self.waterlevel = self.oldwaterlevel;
			self.watertype = self.oldwatertype;
			obstruction();

			//
			// CheckStep
			//

			if (self.obstruction_normal != '0 0 0')
			{
				new_velocity = self.velocity + self.velocity_normal;
				yaw = vectoyaw(self.obstruction_normal);
				dist = ((new_velocity * frametime) - (self.origin - self.oldorigin)) * self.obstruction_normal;
				oldflags = self.flags;
				self.flags = self.flags | FL_ONGROUND_PARTIALGROUND;
				if (walkmove(yaw, dist))
				{
					self.velocity = new_velocity;
					self.velocity_z = 0;
					self.obstruction_normal = '0 0 0';
				}
				else
					self.flags = oldflags;
			}

		// check to see if player landed and play landing sound
			if (self.jump_flag)
			if (self.flags & FL_ONGROUND)
				CheckLand();
		}
		self = self.next;
	}
};

/*
============
FrogbotPostPhysics2

============
*/
void() FrogbotPostPhysics2 =
{
	frametime = real_frametime;
	self = first_client;
	while (self)
	{
		if (self.movetype == MOVETYPE_STEP)
			PlayerPostThink_apply();

		if (game_qizmo)
		{
			if (!self.player)
				SetPlayerInfo();
		}
		self = self.next;
	}
};

/*
============
FrogbotPostPhysics

============
*/
void() FrogbotPostPhysics =
{
	FrogbotPostPhysics1();
	FrogbotPostPhysics2();
};