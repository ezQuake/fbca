/*
	bot/botjump.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2001 Justice
	Copyright (C) 2000-2007 ParboiL
*/

float(entity me) near_teammate;

// moving in right direction to rocket-jump
float() right_direction =
{
	local vector test_dir;
	local float current_dir, wish_dir, right_dir;
	local float min_one, min_two;

	test_dir = normalize(self.oldvelocity); // before physics
	current_dir = vectoyaw(test_dir);
	test_dir = normalize(self.linked_marker.origin - self.origin);
	wish_dir = vectoyaw(test_dir);
	min_one = fabs(wish_dir - current_dir);
	if (wish_dir >= 180)
		wish_dir = wish_dir - 360;
	if (current_dir >= 180)
		current_dir = current_dir - 360;
	min_two = fabs(wish_dir - current_dir);
	right_dir = min_one;
	if (min_two < right_dir)
		right_dir = min_two;
	return (right_dir <= 90);
};

// enough health & items to rocket-jump
float() able_rj =
{
	local float health_after;
	if (self.items & (IT_INVULNERABILITY_QUAD | IT_INVULNERABILITY))
		return 1;
	health_after = ceil(self.armortype * 50);
	if (health_after > self.armorvalue)
		health_after = self.armorvalue;
	health_after = self.health - ceil(50 - health_after);
	if (((health_after > 50)
	|| (teamplay == 1) || (teamplay == 5))
	&& (self.items & IT_ROCKET_LAUNCHER)
	&& (self.ammo_rockets > 2)
	&& ((!game_arena) || (arenastate == A_PLAYING))
	&& (!beQuiet)
	&& (random() > 0.5))
		return 1;
	return 0;
};

// called in EvalPath
float() a_evalpath =
{
	if (test_marker.classname == "door")
	if (test_marker.state != STATE_BOTTOM)
		return 1;
	
	if (description & ROCKET_JUMP)
	if (able_rj())
	{
		m_pos = touch_marker_.absmin + touch_marker_.view_ofs;
		m_P_pos = test_marker.absmin + test_marker.view_ofs;
		path_time = ((vlen(m_P_pos - m_pos) / sv_maxspeed));
	}
	return 0;
};

float() checkboven =
{
	traceline(self.origin, self.origin + '0 0 140', TRUE, self);
	return (trace_fraction == 1);
};

float() checkground = 
{
	makevectors(self.v_angle);
	v_forward_z = 0;
	v_forward = normalize(v_forward) * 10;
	traceline (self.origin, (self.origin + v_forward) + '0 0 -40', TRUE, self);
	return (trace_fraction != 1);
};

// called every frame
void() lava_jump = 
{
	local entity e, pt;
	local float bdist, byaw;

	bdist = 1001;
	pt = self;
	e = self;
	e = findradius(e.origin,1000);
	while(e) {
		if (e.classname == "marker") {
			if (vlen(t.origin - e.origin) < bdist) {
				bdist = vlen(t.origin - e.origin);
				pt = e;
			}
		}
		e = e.chain;
	}
	byaw = vectoyaw(t.origin);
	self.real_yaw = (360 - byaw);
	self.yawaccel = 0;
	self.yawspeed = 0;

	if (self.waterlevel == 3) {
		self.real_pitch = 78.75;
		new_pitch = 78.75;
		self.pitchaccel = 0;
		self.pitchspeed = 0;
		self.arrow = BACK;
		VelocityForArrow();
	}

	if (self.waterlevel == 2) {
		if (self.arrow == BACK) {
			self.real_pitch = 78.75;
			new_pitch = 78.75;
			self.pitchaccel = 0;
			self.pitchspeed = 0;
			self.arrow = BACK;
			VelocityForArrow();
			self.rocketjumping = 1;
			self.botchose = 1;
			self.impulse = 7;
			self.button0_ = 1;
			self.up_finished = time + 0.1;
		} else {
			if (time > self.up_finished) {
				self.swim_arrow = DOWN;
				VelocityForArrow();
			}
		} 
	}
};

void() a_rocketjump =
{
	self.rocketjumping = 0;

	if (pre_game && counting_down)
		return;
	if (!self.ammo_rockets)
		return;
	if (!(self.items & IT_ROCKET_LAUNCHER))
		return;
	if (self.waterlevel > 1)
	if (pointcontents(self.origin + '0 0 -24') == CONTENT_LAVA)
	if (checkboven()) 
	{
		lava_jump(); 
		return;
	}
	if (!able_rj())
		return;
	if (self.items & IT_QUAD)
	if (!(self.items & IT_INVULNERABILITY))
		return;
	if (!(self.path_state & ROCKET_JUMP))
		return;
	if (self.button0_)
		return;
	if (self.button2_)
		return;
	if (near_teammate(self))
		return;
	if (self.attack_finished > time)
		return;
	if (!(self.flags & FL_ONGROUND))
		return;
	if (vlen(self.origin - self.touch_marker.origin) > 100)
		return;
	if (!checkboven()) 
		return;
	if (!checkground())
		return;
	if (!right_direction())
		return;
	BestArrowForDirection();
	VelocityForArrow();
	new_pitch = 78.75;
	self.real_pitch = 78.75;
	self.pitchspeed = 0;
	self.pitchaccel = 0;
	self.rocketjumping = 1;
	self.botchose = 1;
	self.impulse = 7;
	self.button0_ = 1;
	self.button2_ = 1;
};

void() CheckCombatJump =
{
	if (game_botjump) 
	if (self.frogbot)
	{ 
		if (!self.waterlevel)
		if (self.allowedMakeNoise)
		if (self.flags & FL_ONGROUND)
		if (self.weapon != IT_LIGHTNING)
		if (look_object_ == enemy_)
		if (random() < 0.2)
		if (!self.rocketjumping)
		{
			self.button2_ = 1;
		}
	} 
};

void() BotInLava =
{
	if (mapname == "amphi2")
	if (self.frogbot)
	{
		if (time > self.arrow_time)
		if (self.waterlevel == 1)
		if (pointcontents(self.origin + '0 0 -24') == CONTENT_LAVA)
		if (self.flags & FL_ONGROUND)
		if (!enemy_shaft_attack())
		if (!self.rocketjumping)
		{
			BestArrowForDirection();
			VelocityForArrow();
			self.button2_ = 1;
		}
	}
};