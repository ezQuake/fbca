/*
	bot/botwater.qc

	Copyright (C) 1999-2000 Numb
*/

float() WaterCombat =
{
	if (self.waterlevel < 2)
		return TRUE;
	return ((pointcontents(enemy_.origin) == CONTENT_WATER) && (enemy_.origin_z < origin__z - 32));
};

float() JumpInWater =
{
	return (pointcontents(self.origin + '0 0 -64') == CONTENT_WATER);
};

void() BotWaterJumpFix = 
{
	if (self.frogbot)
	{
		self.tread_water_count = self.tread_water_count + 1;
		if (self.tread_water_count > 60)
		{
			self.tread_water_count = 0;
			self.old_linked_marker = world;
			self.linked_marker = LocateMarker(self.origin);
			self.path_state = 0;
			self.linked_marker_time = time + 5;
		}
	}
};

float() BotCanReachMarker = 
{
	local vector spot1, spot2;

	spot2 = self.linked_marker.origin;
	spot1 = self.origin + self.view_ofs;

	traceline (spot1,spot2,TRUE,self);
	return (trace_fraction == 1); 

};

float() BotSwimDown =
{
	return (self.linked_marker.origin_z < self.origin_z);
};

float() BotSwimUp =
{
	return (self.linked_marker.origin_z >= self.origin_z);
};

float() BotGoUpForAir =
{
	if (time > (self.air_finished - 2))
	{
		traceline (self.origin, self.origin + '0 0 64', TRUE, self);
		if (trace_fraction == 1) //
			return (self.swim_arrow = UP);	
		else
		{
			new_velocity 	= self.velocity;
			dir_move 	= normalize(dir_move);
			dir_move 	= dir_move + normalize(new_velocity);
			dir_move_z 	= 0;
			NewVelocityForArrow();
		}	
	
		if (time > self.air_finished)
		{	
			// time's up!
			traceline (self.origin, self.origin + '0 0 32', TRUE, self);
			if (trace_fraction != 1)
				return (self.swim_arrow = UP);
		}
	}
	return FALSE;	
};

void() FrogTreadWater =
{
	if (self.frogbot)
	{	
		self.tread_water_count = self.tread_water_count + 1;

		// treading water too long
		if (self.tread_water_count > 75)
		{
			self.old_linked_marker = world;
			self.linked_marker = LocateMarker(self.origin);
			self.path_state = 0;
			self.linked_marker_time = time + 5;	
		}
	}
};

void() SwimAwayFromWall =
{
	if ((self.obstruction_normal * rel_pos) > 0.5)
	{
		dir_move = (-1) * dir_move;	
	}

	traceline (self.origin, self.origin + v_right * 20, TRUE, self);
	if (trace_fraction != 1)
	{
		dir_move = normalize(dir_move);
		dir_move = normalize(dir_move + ((-32) * v_right * random()));
	}

	traceline (self.origin, self.origin + v_right * (-20), TRUE, self);
	if (trace_fraction != 1)
	{
		dir_move = normalize(dir_move);
		dir_move = normalize(dir_move + (32 * v_right * random()));
	}

	NewVelocityForArrow();
	
};
	
void() FrogWaterMove = 
{
	if (self.frogbot)
	if (self.waterlevel > 2)
	{
		if (time < self.frogwatermove_time)
			return;
		self.frogwatermove_time = self.frogbot_nextthink + 0.1;
		
		if (self.obstruction_normal != '0 0 0')
			SwimAwayFromWall();

		if (BotGoUpForAir())
		{
			VelocityForArrow();
			return;
		}

		if (BotCanReachMarker())
		{
			if (BotSwimDown()) 
			{
				self.swim_arrow = DOWN;
			}
			else if (BotSwimUp()) 
			{
				self.swim_arrow = UP;
			}
		}
		else
		{
			traceline (self.origin,self.origin + '0 0 32', TRUE, self); 
			if (trace_fraction == 1) 
			{
				self.swim_arrow = UP;
			}
			else 
			{
				traceline (self.origin,self.origin + '0 0 -32', TRUE, self); 
				if (trace_fraction == 1) 
				{
					self.swim_arrow = DOWN;
				}
				else
				{
					self.swim_arrow = UP;
				}
			}
		}
		VelocityForArrow();
	}
};

float () BotShouldDischarge =
{
	local float n;
	local entity p;

	if (self.waterlevel != 3)
		return FALSE;

	if (!(self.items & IT_LIGHTNING))
		return FALSE;

	if (self.ammo_cells < 25)
		return FALSE;

	if (self.enemy_dist > 600)
		return FALSE;

	if (look_object_ != enemy_)
		return FALSE;

	// discharge!
	if (self.invincible_time > time)
	if (pointcontents(enemy_.origin) == CONTENT_WATER)
		return TRUE;

	// don't discharge...
	if ((self.items & IT_ROCKET_LIGHTNING) && (self.ammo_rockets > 25) && (self.ammo_cells > 25))
		return FALSE;

	if ((self.items & IT_NAILGUN_ROCKET) && (self.ammo_rockets > 25) && (self.ammo_nails > 25))
		return FALSE;

	n = 0;
	p = findradius(self.origin, 1000);
	while (p != world)
	{
		if (pointcontents(p.origin) == CONTENT_WATER)
		{
			if (p.client_)
			{
				if (p.takedamage)
				{
					if (IsVisible(p))
					{
						if (p.realteam != self.realteam)
						{
							n = n + 1;
						}
						else
						{
							n = n - 1;
						}
					}
				}
			}
		}
		p = p.chain;
	}
	
	if (n >= 2)
	{
		// discharge! we'll kill 2 or more 
		if (random() < 0.003)
		{	
			return TRUE;
		}
	}

	return FALSE;
};