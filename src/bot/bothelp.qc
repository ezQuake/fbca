/*
	bot/bothelp.qc

	Copyright (C) 1999-2000 Numb
	Copyright (C) 2000-2007 ParboiL
*/

float(vector vec) EntVisible =
{
	traceline(self.origin, vec, TRUE, self);
	if ((trace_fraction == 1) && !(trace_inopen && trace_inwater)) return TRUE;
	return FALSE;
};

float(entity ent) IsVisible =
{
	local vector vec;

// Three points: origin, bottom and top
	if (EntVisible(ent.origin)) 
		return TRUE;
	vec = ent.origin;
	vec_z = ent.absmin_z;
	if (EntVisible(vec))
		return TRUE;
	vec_z = ent.absmax_z;
	if (EntVisible(vec))
		return TRUE;
	return FALSE;
};

float(entity ent) VisibleEntity =
{
	local vector vec;

// Three points: origin, bottom and top
	if (EntVisible(ent.origin)) 
		return TRUE;
	vec = ent.origin;
	vec_z = ent.absmin_z;
	if (EntVisible(vec))
		return TRUE;
	vec_z = ent.absmax_z;
	return EntVisible(vec);
};

entity(entity me) identify_teammate_ =
{
	local entity p, g;
	local float closeness;
	closeness = -1;
	local vector diff, point;
	local float currclose;
	p = find(world, stringname, "gamer");
	while(p != world) {
		if (me.realteam == p.realteam) {
			diff = p.origin - me.origin;
			diff = normalize(diff);
			point = normalize(me.angles);
			diff = diff - point;
			currclose = vlen(diff);
			traceline(me.origin, p.origin, FALSE, me);
			if (trace_ent == p) {
				if (closeness == -1) {
					closeness = currclose;
					g = p;
				} else if (currclose < closeness) {
					closeness = currclose;
					g = p;
				}
			}
		}
		p = find(p, stringname, "gamer");		
	}
	if (g != world) return g;
	return world;
};

float(float v) anglemod =
{
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};

float(entity me) visible_teammate =
{
	if (!teamplay || (teamplay && (healthplay == TEAM_TOTAL_HEALTH_PROTECT))) return 0;
	local float ang, curang;
	local entity p;
	p = find(world, stringname, "gamer");
	while(p != world) {
		if (p != me) {
			if (me.realteam == p.realteam) {
				if (VisibleEntity(p)) {
					curang = vectoyaw(p.origin - me.origin);
					ang = anglemod(me.angles_y - curang);
					if (ang < 20 || ang > 340) return 1;
				}
			}
		} 
		p = find(p, stringname, "gamer");
	}
	return 0;
};

float(entity me) near_teammate =
{
	if (!teamplay || (teamplay && (healthplay == TEAM_TOTAL_HEALTH_PROTECT))) return 0;
	local entity p;
	p = identify_teammate_(me);
	return ((vlen(p.origin - me.origin)) < 140);
};

entity() HelpTeammate =
{
	if (!teamplay)
		return world;

	if (self.state & WAIT)
		return world;

	if (self.state & RUNAWAY)
		return world;

	if (self.state & NOTARGET_ENEMY) // dm6
		return world;

	if (self.goalentity.goalentity == self)
		return world;

	if ((self.goalentity.client_) && (self.goalentity != self))
	{
		if (self.goalentity.realteam == self.realteam)
		{
			// already helping someone, so just keep helping 
			// that player
			if ((self.goalentity.health < 30) && !(self.goalentity.items & IT_INVULNERABILITY) && (self.goalentity.waterlevel == 0))
			{
				if ((self.items & (IT_ROCKET_LAUNCHER | IT_LIGHTNING)) && (self.health > 65))
				{
					if ((self.ammo_rockets > 2) || (self.ammo_cells > 10))
					{
						if (IsVisible(self.goalentity))
						{
							self.state = self.state | HELP_TEAMMATE;
							return self.goalentity;
						}
					}
				}
			}
		}
	}
	local entity head, selected1, selected2;
	local float d, bdist, best_dist1, best_dist2;
	bdist = 500;

	// if we get here, we are not already helping a player, or being helped
	// so we check for someone else to help... only do this
	// every few seconds, because it is slow
	
	// if already helping player or self, don't check for player
	if (time < self.help_teammate_time)
		return world;

	self.help_teammate_time = time + 20 + 3 * random();
	
	selected1 = world;
	selected2 = world;
	best_dist1 = 99999999;
	best_dist2 = 99999999;

	head = findradius(self.origin, bdist);	
	while(head)
	{
		if (head.client_)
		if (head.realteam == self.realteam)
		if (head != self)
		{
			d = vlen(head.origin - self.origin);
			if (self != head.goalentity)
			{
				if (d < best_dist1)
				if (VisibleEntity(head) && !(head.items & IT_INVULNERABILITY) && (head.health < 40) && (head.armorvalue < 11) && (head.waterlevel == 0)) 
				{
					if (self.items & (IT_ROCKET_LAUNCHER | IT_LIGHTNING))
					{
						if ((self.ammo_cells > 10) || (self.ammo_rockets > 2))
						{
							selected1 = head;
							self.state = self.state | HELP_TEAMMATE;
							best_dist1 = d;
						}
					}
				}
			}
			if (head.realteam == self.realteam)
			if (self != head.goalentity)
			{
				if (d < best_dist2)
				if (VisibleEntity(head) && !(head.items & IT_INVULNERABILITY) && (head.health < 30) && (head.armorvalue < 20) && (head.waterlevel == 0)) 
				{
					if (self.items & (IT_ROCKET_LAUNCHER | IT_LIGHTNING))
					{
						if ((self.ammo_cells > 10) || (self.ammo_rockets > 2))
						{
							selected2 = head;
							self.state = self.state | HELP_TEAMMATE;
							best_dist2 = d;
						}
					}
				}
			}
		}
		head = head.chain;
	}
	if (selected1 != world)
		return selected1;
	else if (selected2 != world)
		return selected2;
	return world;
};