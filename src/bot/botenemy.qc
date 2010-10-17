/*
	bot/botenemy.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
*/ 

/* 
============
ClearLookObject

============
*/
void(entity client) ClearLookObject =
{
client.track_pitchspeed = client.track_yawspeed = client.pitchaccel = client.yawaccel = 0;
client.look_object = world;
};

/*
============
LookEnemy

============
*/
void() LookEnemy =
{
look_object_ = self.look_object = enemy_;
self.predict_origin = enemy_.origin;
self.old_linked_marker = world;
};

/*
============
ResetEnemy

============
*/
void() ResetEnemy =
{
	test_enemy = first_client;
	while (test_enemy)
	{
		if (test_enemy.enemy == self)	// test_enemy must be frogbot
		{
			test_enemy.enemy = world;
			if (test_enemy.look_object.client_)	
			{
				ClearLookObject(test_enemy);
				test_enemy.look_object = world;
			}
			if (test_enemy.goalentity == self)
				test_enemy.goal_refresh_time = 0;
		}
		test_enemy = test_enemy.next;
	}

	self.enemy = world;
};

/*
============
CheckCombatEnemy

============
*/
void() CheckCombatEnemy =
{
	if (targ.look_object.firepower < attacker.firepower)
	{	// attacker must be FL_CLIENT
		if (attacker != targ)
		{
			targ.look_object = attacker;
			targ.predict_origin = attacker.origin;

			if (attacker.realteam != targ.realteam)
			{
				if (targ.goalentity == targ.enemy)
					targ.goal_refresh_time = 0;
				targ.enemy_time = time + 1;
				targ.enemy = attacker;
			}
			else
			{
				targ.enemy_time = time + 2.5;
				targ.friend = attacker;	// being shot by this friend
			}
		}
	}
};

/*
============
check_sound

============
*/
void() check_sound =
{
	if (enemy_.client_)
	{
		self_sound = self;
		self = first_client;
		while (self)
		{
			if (!(self.state & NOTARGET_ENEMY))
				if (enemy_ == self.enemy)
					if (enemy_ != self.look_object)
						if (vlen(enemy_.origin - self.origin) < 1000)	// ear shot
						{
							visible_object = enemy_;
							if (Visible_360())
								self.look_object = enemy_;
						}
			self = self.next;
		}
		self = self_sound;
	}
};

/*
============
sound

============
*/
void(float chan, string samp, float vol, float atten) sound =
{
	sound_apply(msg_entity, chan, samp, vol, atten);
	enemy_ = msg_entity;
	check_sound();
};

/*
============
BestEnemy

============
*/
void() BestEnemy_apply =
{
	from_marker.sight_from_marker();

	if (look_marker)
	{
		look_marker.zone_marker();
		look_marker.sub_arrival_time();
		enemy_score = traveltime + random();
	}
	else
	{
		SightMarker();
		enemy_score = look_traveltime + random();
	}

	if (enemy_score < best_score)
	{
		best_score = enemy_score;
		enemy_ = test_enemy;
		predict_dist = vlen(look_marker.absmin + look_marker.view_ofs - (to_marker.absmin + to_marker.view_ofs));
	}
};

void() BestEnemy =
{
// initialise
	best_score = 1000000;
	enemy_ = world;
	predict_dist = 600;

	path_normal = TRUE;	// FIXME: AI set this

	test_enemy = first_client;
	while (test_enemy)
	{
		if (realteam_ != test_enemy.realteam)
		{
			from_marker = test_enemy.touch_marker;
			if (from_marker)
			{
				to_marker = touch_marker_;

				BestEnemy_apply();

				to_marker = from_marker;
				from_marker = touch_marker_;

				BestEnemy_apply();
			}
		}

		test_enemy = test_enemy.next;
	}

	self.enemy_time = time + 1;
	self.enemy = enemy_;
	self.enemy_dist = predict_dist;
};