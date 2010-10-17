/*
	bot/bothazd.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2003 3d[Power]
	Copyright (C) 2000-2007 ParboiL
*/

/*
============
HazardTeleport

============
*/
void() HazardTeleport =
{
	if (self.arrow_time < time + 0.5)
		self.arrow_time = time + 0.5;	// avoid telefrag

	test_enemy = first_client;
	while (test_enemy)
	{
		if (test_enemy != other)
		{
			if (test_enemy.linked_marker == self)
			{
				test_enemy.old_linked_marker = world;
				test_enemy.linked_marker = LocateMarker(test_enemy.origin);
				test_enemy.path_state = 0;
				test_enemy.linked_marker_time = time + 5;
			}
		}
		test_enemy = test_enemy.next;
	}
};

/*
============
ExplodeAlert

============
*/
void(vector org) ExplodeAlert =
{
	grenade_marker = findradius(org, 256);

	while (grenade_marker)
	{
		if (grenade_marker.fl_marker)
		{
			traceline(org, grenade_marker.absmin + grenade_marker.view_ofs, TRUE, grenade_marker);
			if (trace_fraction == 1)
			{
				grenade_marker.arrow_time = nextthink_;
				test_enemy = first_teleport;
				while (test_enemy)
				{
					if (test_enemy.enemy == grenade_marker)
					{
						if (test_enemy.arrow_time < nextthink_)
							test_enemy.arrow_time = nextthink_;
					}
					test_enemy = test_enemy.next;
				}
			}
		}
		grenade_marker = grenade_marker.chain;
	}
};

/*
============
GrenadeAlert

============
*/
void() GrenadeAlert =
{
	nextthink_ = self.nextthink = time + 0.05;
	self.think = GrenadeAlert;
	if (self.frogbot_nextthink <= time)
	{
		self.think = GrenadeExplode;
		self.nextthink = time;
	} 
	ExplodeAlert(self.origin);
};

/*
============
RocketAlert

============
*/
void() RocketAlert =
{
	nextthink_ = self.nextthink = time + 0.5;
	if (nextthink_ >= self.frogbot_nextthink)
		self.think = Missile_Remove;

	src = self.origin;
	traceline(src, src + (self.velocity * 600), TRUE, self.owner);
	ExplodeAlert(trace_endpos);
};


/*
============
NewVelocityForArrow

============
*/
void() NewVelocityForArrow =
{
	BestArrowForDirection();

	if (self.arrow != best_arrow)
	{
		self.dir_move_ = dir_move;
		self.arrow = best_arrow;
		self.arrow_time = time + 0.15;
		self.velocity = oldvelocity_;
		VelocityForArrow();
	}
};

/*
============
AvoidHazards

============
*/
void() AvoidHazards =
{
	new_velocity = self.velocity;
	linked_marker_ = self.linked_marker;

	if (self.path_state & JUMP_LEDGE)
	{
		if (time > self.arrow_time2)
		{
			rel_pos = (linked_marker_.absmin + linked_marker_.view_ofs) - self.origin;
			if (self.flags & FL_ONGROUND)
			{
				try_jump_ledge = TRUE;
				being_blocked = FALSE;
				if (vlen(oldvelocity_) <= 100)
				{
					rel_hor_dir = rel_pos;
					rel_hor_dir_z = 0;

					try_jump_ledge = (vlen(rel_hor_dir) <= 80);

					rel_hor_dir = normalize(rel_hor_dir);
					being_blocked = ((self.obstruction_normal * rel_hor_dir) > 0.5);
				}

				if (try_jump_ledge)
				if (rel_pos_z > 18)
				{
					hor_normal_vec_x = 0 - rel_pos_y;
					hor_normal_vec_y = rel_pos_x;
					hor_normal_vec = normalize(hor_normal_vec);

					jumpspeed = new_velocity_z + JUMPSPEED;

					if ((jumpspeed * jumpspeed * 0.000625) >= rel_pos_z)	// 0.000625 = 0.5 / sv_gravity
					{
						self.button2_ = TRUE;
						self.path_state = self.path_state | WAIT_GROUND;
						self.ledge_backup_time = 0;
						return;
					}
				}

				if (being_blocked)
				if (time > self.arrow_time)
				{
					if (self.ledge_backup_time)
					{
						if (time >= self.ledge_backup_time)
						{
							dir_move = rel_hor_dir - (self.obstruction_normal * (self.obstruction_normal * rel_hor_dir));
							if (dir_move == '0 0 0')
								dir_move = (-1) * self.obstruction_normal;
							else if (random() < 0.5)
								dir_move = (-1) * dir_move;
							NewVelocityForArrow();
							self.ledge_backup_time = 0;
						}
					}
					else
						self.ledge_backup_time = time + 0.15;
				}
			}
			else if (time > self.arrow_time)
			{
				if (new_velocity_z >= 0)
					ledge_backup = ((new_velocity_z * new_velocity_z * 0.000625) < rel_pos_z);	// 0.000625 = 0.5 / sv_gravity
				else
					ledge_backup = (rel_pos_z > 0);
				if (ledge_backup)
				{
					if (self.ledge_backup_time)
					{
						if (time >= self.ledge_backup_time)
						{
							dir_move = (-1) * rel_pos;
							dir_move_z = 0;
							NewVelocityForArrow();
							self.ledge_backup_time = 0;
						}
					}
					else
						self.ledge_backup_time = time + 0.15;
				}
			}
		}

		if (time >= (self.ledge_backup_time + 0.15))
			self.ledge_backup_time = 0;
	}
	else if (self.obstruction_normal != '0 0 0')
	{
		if (time > self.arrow_time)
		{
			if (self.flags & FL_WATERJUMP)
				return;

			if (linked_marker_ != self.touch_marker)	// not being stationary
			if (vlen(oldvelocity_) <= 32)
			{
				dir_move = new_velocity - (self.obstruction_normal * (self.obstruction_normal * new_velocity));

				if ((dir_move_x == 0) && (dir_move_y == 0))
				{
					dir_move = (-1) * self.obstruction_normal;
					self.path_state = self.path_state | STUCK_PATH;
				}
				else if ((oldvelocity__x == 0) && (oldvelocity__y == 0))
				{
					// maybe stuck in a corner
					if (random() < 0.5)
						dir_move = (-1) * dir_move;
					self.path_state = self.path_state | STUCK_PATH;
				}
				else
				{
					if (self.path_state & STUCK_PATH)
					{
						dir_move = normalize(dir_move);
						dir_move = dir_move + normalize(new_velocity);
					}
					else
						dir_move = self.dir_move_ - 0.5 * (self.obstruction_normal * (self.obstruction_normal * self.dir_move_));
				}

				dir_move_z = 0;
				NewVelocityForArrow();
			}
		}

		new_velocity = new_velocity - (self.obstruction_normal * (self.obstruction_normal * new_velocity));
	}

	hor_velocity = new_velocity;
	hor_velocity_z = 0;
	hor_speed = vlen(hor_velocity);
	if (!hor_speed)
		return;

	new_origin = self.origin;
	testplace = new_origin + new_velocity * (32 / hor_speed);
/*
	if (self.near_teleport)
	{
	// check avoid teleport
		test_enemy = self.near_teleport;
		self.near_teleport = world;
		if (test_enemy != self.linked_zone_marker)
		{
			test_enemy_maxs = test_enemy.virtual_maxs;
			if (testplace_x <= test_enemy_maxs_x)
			if (testplace_y <= test_enemy_maxs_y)
			if (testplace_z <= test_enemy_maxs_z)
			{
				test_enemy_mins = test_enemy.virtual_mins;
				if (testplace_x >= test_enemy_mins_x)
				if (testplace_y >= test_enemy_mins_y)
				if (testplace_z >= test_enemy_mins_z)
				{
					AvoidEdge();
					return;
				}
			}
		}
	}
*/

	if (self.waterlevel)
		return;

	dir_forward = normalize(hor_velocity);

	fallheight = self.origin_z - 38;

	if (linked_marker_)
	{
		min_second = linked_marker_.absmin_z + linked_marker_.view_ofs_z - 36;
		if (fallheight > min_second)
			fallheight = min_second;
	}

	if (self.flags & FL_ONGROUND)
	{
		if (new_velocity_z < 0)
			new_velocity_z = 0;

		last_clear_point = self.origin;
		testplace = last_clear_point + new_velocity * (16 / hor_speed);

		FallSpotGround();

		if (fall == FALL_BLOCKED)
		{
			first_trace_fraction = 1;
			TestTopBlock();

			if (first_trace_fraction != 1)
			{
				testplace = last_clear_point + new_velocity * (16 / hor_speed) * first_trace_fraction;
				new_velocity = new_velocity - (first_trace_plane_normal * (first_trace_plane_normal * new_velocity));
				hor_velocity = new_velocity;
				hor_velocity_z = 0;
				hor_speed = vlen(hor_velocity);
				testplace = testplace + (new_velocity * (16 / hor_speed) * (1 - first_trace_fraction));
			}

			FallSpotGround();
		}

		if (fall >= FALL_LAND)
		{
			jump_origin = testplace;

			new_fall = fall;
			testplace = new_origin;
			FallSpotGround();
			if (self.path_state & DELIBERATE_AIR)
			{
				if (fall < FALL_LAND)
					return;
				self.path_state = self.path_state - DELIBERATE_AIR;
			}
			if (new_fall > fall)
			{
				if (time > self.arrow_time2)
				{
					current_fallspot = fall;
					jump_velocity = new_velocity;
					jump_velocity_z = jump_velocity_z - (6400 / hor_speed);	// 6400 = sv_gravity * 8
					jump_origin_z = jump_origin_z + (jump_velocity_z * (16 / hor_speed));
					jump_velocity_z = jump_velocity_z - (6400 / hor_speed);	// 6400 = sv_gravity * 8
					CanJumpOver();
					if (do_jump)
					{
						self.path_state = self.path_state | DELIBERATE_AIR_WAIT_GROUND;
						if (turning_speed)
							self.path_state = self.path_state | AIR_ACCELERATION;
						return;
					}
					jump_origin = new_origin;
					jump_velocity = new_velocity;
					jump_velocity_z = jump_velocity_z + JUMPSPEED;
					CanJumpOver();
					if (do_jump)
					{
						self.button2_ = TRUE;
						self.path_state = self.path_state | DELIBERATE_AIR_WAIT_GROUND;
						if (turning_speed)
							self.path_state = self.path_state | AIR_ACCELERATION;
						return;
					}
				}

				AvoidEdge();
			}
			return;
		}

		new_origin = testplace + new_velocity * (8 / hor_speed);
		testplace = testplace + new_velocity * (16 / hor_speed);

		FallSpotGround();

		if (fall >= FALL_LAND)
		{
			jump_origin = testplace;

			new_fall = fall;
			testplace = self.origin;
			FallSpotGround();
			if (self.path_state & DELIBERATE_AIR)
			{
				if (fall < FALL_LAND)
					return;
				self.path_state = self.path_state - DELIBERATE_AIR;
			}
			if (new_fall > fall)
			{
			//	RunAlongEdge

				if (time > self.arrow_time2)
				{
					current_fallspot = fall;
					jump_velocity = new_velocity;
					jump_velocity_z = jump_velocity_z - (6400 / hor_speed);	// 6400 = sv_gravity * 8
					jump_origin_z = jump_origin_z + (jump_velocity_z * (16 / hor_speed));
					jump_velocity_z = jump_velocity_z - (6400 / hor_speed);	// 6400 = sv_gravity * 8
					CanJumpOver();
					if (do_jump)
					{
						self.path_state = self.path_state | NO_DODGE;
						return;
					}
					jump_origin = new_origin;
					jump_velocity = new_velocity;
					jump_velocity_z = jump_velocity_z + JUMPSPEED;
					CanJumpOver();
					if (do_jump)
					{
						self.path_state = self.path_state | NO_DODGE;
						return;
					}
				}

				traceline(self.origin + (dir_forward * 32) + '0 0 -24.1', self.origin - (dir_forward * 16) + '0 0 -24.1', TRUE, world);
				trace_plane_normal_z = 0;

				if (trace_plane_normal == '0 0 0')
				{
					AvoidEdge();
					return;
				}
				else
					edge_normal = normalize(trace_plane_normal);

				normal_comp = edge_normal * dir_forward;

				if (normal_comp <= 0)
				{
					AvoidEdge();
					return;
				}

				dir_move = dir_forward - (2 * edge_normal * normal_comp);
				dir_move_z = 0;
				NewVelocityForArrow();
				if (normal_comp > 0.5)
					self.arrow_time2 = self.arrow_time;
			}
		}
	}
	else
	{
//		testplace = new_origin + new_velocity * (32 / hor_speed);

		FallSpotAir();

		if (fall >= FALL_LAND)
		{
			new_fall = fall;
			testplace = new_origin;
			FallSpotAir();
			if (self.path_state & DELIBERATE_AIR)
			{
				if (fall < FALL_LAND)
					return;
				self.path_state = self.path_state - DELIBERATE_AIR;
			}

			if (new_fall > fall)
			{
				testplace = new_origin + new_velocity * (16 / hor_speed);
				FallSpotAir();
				if (new_fall > fall)
				{
					current_fallspot = fall;
					jump_origin = new_origin;
					jump_velocity = new_velocity;
					CanJumpOver();
					if (do_jump)
						return;

					AvoidEdge();
				}
			}
		}
	}
};

/*
============
AvoidEdge

============
*/
void() AvoidEdge =
{
	dir_forward = oldvelocity_;
	dir_forward_z = 0;

	if (dir_forward != '0 0 0')
	{
		if (game_lava_cheat)
		oldvelocity__x = oldvelocity__y = 0;
		dir_move = (-1) * dir_forward;
		NewVelocityForArrow();
		self.arrow_time2 = self.arrow_time;
	}
};