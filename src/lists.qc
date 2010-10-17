/*
	lists.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
*/

void() thud_touch;
void() FrogbotPrePhysics2;
void() FrogbotPostPhysics;
void() LoadMap;

entity(entity first_in_list) AddToList =
{
	self.next = first_in_list;
	self.previous = first_in_list.previous;
	if (first_in_list)
	{
		if (first_in_list.previous)
			first_in_list.previous.next = self;
		first_in_list.previous = self;
	}
	return self;
};

entity(entity first_in_list) RemoveFromList =
{
	if (first_in_list == self)
		first_in_list = first_in_list.next;
	if (self.previous)
		self.previous.next = self.next;
	if (self.next)
		self.next.previous = self.previous;
	return first_in_list;
};

void() Add_takedamage =
{
	self.takedamage = DAMAGE_YES;
	first_takedamage = AddToList(first_takedamage);
	takedamage_exists = TRUE;
};

void() UpdateRadiusDamage =
{
	if (takedamage_exists)
	{
		if (numberofclients)
			return;
		test_enemy = first_takedamage;
		while (test_enemy.next)
			test_enemy = test_enemy.next;
		test_enemy.next = first_client;
		first_client.previous = test_enemy;
	}
	else
	{
		first_takedamage = first_client;
	}
};

void() CheckTwoTeams =
{
	local entity client;

	first_team = second_team = 0;

	client = first_client;
	first_team = first_client.realteam;
	while (client)
	{
		new_team = client.realteam;
		if (new_team != first_team)
		{
			if (second_team)
			{
				if (new_team != second_team)
				{
					two_teams = FALSE;
					return;
				}
			}
			else
				second_team = new_team;
		}
		client = client.next;
	}

	if (second_team)
		two_teams = TRUE;
	else
		two_teams = FALSE;
};

void() Add_client =
{
	if (self.client_)
		return;

	self.client_ = TRUE;

	first_client = AddToList(first_client);
	UpdateRadiusDamage();
	numberofclients = numberofclients + 1;

	if (teamplay)
	{
		self.realteam = self.team;
		team_index = self.team - 1;
		self.teamflag = 1;
		while (team_index)
		{
			team_index = team_index - 1;
			self.teamflag = self.teamflag * 2;
		}
	}
	else
	{
		current_team = current_team + 1;
		self.realteam = current_team;
	}

	CheckTwoTeams();

	self.movetarget = world;	// clear shot rocket
	self.goalentity = self.enemy = world;
};

void() RemoveFromAllLists =
{
	if (self.client_)
	{
		self.client_ = FALSE;
		self.frogbot = FALSE;
		first_client = RemoveFromList(first_client);
		UpdateRadiusDamage();
		numberofclients = numberofclients - 1;
		CheckTwoTeams();
	}
};

/*
============
EntityAt

============
*/
entity(entity start_entity, float index_) EntityAt =
{
	while (index_ > 0)
	{
		start_entity = nextent(start_entity);
		index_ = index_ - 1;
	}
	return start_entity;
};

/*
============
InitFrogbots1

============
*/
void() InitFrogbots1 =
{
	prephysics = spawn();
	prephysics.think = FrogbotPrePhysics2;

	while (frogbot_number < maxplayers)
	{
		new_bot = spawn();
		new_bot.touch = thud_touch;

		if (!first_frogbot)
			first_frogbot = new_bot;
		new_bot.score_pos = frogbot_number;
		frogbot_number = frogbot_number + 1;
		new_bot.colormap = frogbot_number;
	}

	postphysics = frogbot_spawned = spawn();
	postphysics.think = FrogbotPostPhysics;
};

void() InitFrogbots2 =
{
	test_enemy = find(world, classname, "path_corner");
	while (test_enemy)
	{
		if (!test_enemy.admin_code)
			remove(test_enemy);
		test_enemy = find(test_enemy, classname, "path_corner");
	}

	total_entity_count = 1;
	self = world;
	while (self = nextent(self))
		total_entity_count = total_entity_count + 1;

	self = first_item;
	while (self)
	{
		self.movetype = MOVETYPE_NONE;
		self.origin_z = self.origin_z + 6;
		droptofloor();
		setsize(self, self.mins + '-49 -49 0', self.maxs + '49 49 0');
		adjust_view_ofs_z();
		self.virtual_mins = self.absmin + '32 32 -33';
		self.virtual_maxs = self.virtual_mins + '96 96 114';
		self = self.next;
	}

	SpawnRunes();

	LoadMap();	// dropper.think changed, no reference to absmin/view_ofs
};

/*
============
UpdateFrags

============
*/
void(entity e) UpdateFrags =
{
	if (fraglimit)
		if (e.frags >= fraglimit)
			NextLevel ();

	if (e.player)
		return;

	WriteByte(MSG_ALL, MSG_UPDATEFRAGS);
	WriteByte(MSG_ALL, e.score_pos);
	WriteShort(MSG_ALL, e.frags);
};

/*
============
ClearName

============
*/
void(float to, entity client) ClearName =
{
	WriteByte(to, SVC_UPDATEUSERINFO);		// update userinfo
	WriteByte(to, client.score_pos);		// client number
	WriteLong(to, 0);					// client userid
	WriteByte(to, 92); // \
	WriteByte(to, _n);
	WriteByte(to, _a);
	WriteByte(to, _m);
	WriteByte(to, _e);
	WriteByte(to, 92); // \
	WriteByte(to, 0);
};

/*
============
SetColorName QW // ParboiL

============
*/
void(float to, entity client) SetColorName =
{
	local string s1;

	WriteByte(to, SVC_UPDATEPING);		// update ping
	WriteByte(to, client.score_pos);		// client number
	WriteShort(to, 999);				// client ping

	WriteByte(to, SVC_UPDATEPACKETLOSS);	// update pl
	WriteByte(to, client.score_pos);		// client number
	WriteByte(to, (30 + (random() * 20)));	// client pl

	WriteByte(to, SVC_UPDATETIME);		// update time
	WriteByte(to, client.score_pos);		// client number
	WriteLong(to, time);				// client enter time

	clientshirt = floor(client.color_ / 16);
	clientpants = client.color_ - (clientshirt * 16);
	WriteByte(to, SVC_UPDATEUSERINFO);		// update userinfo
	WriteByte(to, client.score_pos);		// client number
	WriteLong(to, 0);					// client userid

	WriteByte(to, 92); // \
	WriteByte(to, _b);
	WriteByte(to, _o);
	WriteByte(to, _t);
	WriteByte(to, _t);
	WriteByte(to, _o);
	WriteByte(to, _m);
	WriteByte(to, _c);
	WriteByte(to, _o);
	WriteByte(to, _l);
	WriteByte(to, _o);
	WriteByte(to, _r);
	WriteByte(to, 92); // \

	if (clientpants > 9)
	{
		WriteByte(to, 49);
		WriteByte(to, 38 + clientpants);
	}
	else
		WriteByte(to, 48 + clientpants);

	WriteByte(to, 92); // \
	WriteByte(to, _t);
	WriteByte(to, _o);
	WriteByte(to, _p);
	WriteByte(to, _c);
	WriteByte(to, _o);
	WriteByte(to, _l);
	WriteByte(to, _o);
	WriteByte(to, _r);
	WriteByte(to, 92); // \

	if (clientshirt > 9)
	{
		WriteByte(to, 49);
		WriteByte(to, 38 + clientshirt);
	}
	else
		WriteByte(to, 48 + clientshirt);

	WriteByte(to, 92); // \
	WriteByte(to, _n);
	WriteByte(to, _a);
	WriteByte(to, _m);
	WriteByte(to, _e);
	WriteByte(to, 92); // \
	WriteString(to, client.netname);

	if (teamplay)
	{
		WriteByte(to, SVC_SETINFO);
		WriteByte(to, client.score_pos);
		WriteString(to, "team");
		s1 = GetTeamName(client.team);
		WriteString(to, s1); 
	}
};

/*
============
SetScoreboard

============
*/
void() SetScoreboard =
{
	msg_entity = self;
	msg_level = PRINT_HIGH;
	score_count = 0;
	
	test_enemy = other.enemy;
	while (score_count < SPAWN_SIZE)
	{
		if (test_enemy.frogbot)
		{
			WriteByte(MSG_ONE, SVC_UPDATEPING);			// update ping
			WriteByte(MSG_ONE, test_enemy.score_pos);		// client number
			WriteShort(MSG_ONE, (300 + (random() * 40)));	// client ping
			WriteByte(MSG_ONE, SVC_UPDATEPACKETLOSS);		// update pl
			WriteByte(MSG_ONE, test_enemy.score_pos);		// client number
			WriteByte(MSG_ONE, (30 + (random() * 20)));	// client pl
			WriteByte(MSG_ONE, SVC_UPDATETIME);			// update time
			WriteByte(MSG_ONE, test_enemy.score_pos);		// client number
			WriteLong(MSG_ONE, time);				// client enter time
			WriteByte(MSG_ONE, MSG_UPDATEFRAGS);
			WriteByte(MSG_ONE, test_enemy.score_pos);
			WriteShort(MSG_ONE, test_enemy.frags);
			SetColorName(MSG_ONE, test_enemy);
		}
		test_enemy = nextent(test_enemy);
		score_count = score_count + 1;
	}
	other.enemy = test_enemy;
};

void() SetPlayerInfo =
{
	WriteByte(MSG_BROADCAST, SVC_PLAYERINFO);
	WriteByte(MSG_BROADCAST, self.score_pos);
	if (self.modelindex == modelindex_player)
	{
		if (self.effects)
			WriteShort(MSG_BROADCAST, 4254);		// mask = 4254 = 158 + 4096
		else
			WriteShort(MSG_BROADCAST, 4126);		// mask = 4126 = 30 + 4096
	}
	else
	{
		if (self.effects)
			WriteShort(MSG_BROADCAST, 4286);		// mask = 4286 = 190 + 4096
		else
			WriteShort(MSG_BROADCAST, 4158);		// mask = 4158 = 62 + 4096
	}
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	WriteByte(MSG_BROADCAST, self.frame);

	WriteByte(MSG_BROADCAST, 129);		// mask2 = 129
	WriteShort(MSG_BROADCAST, self.v_angle_x * 182.0444444);	// 182.0444444 = 65536 / 360
	WriteShort(MSG_BROADCAST, self.v_angle_y * 182.0444444);	// 182.0444444 = 65536 / 360

	WriteByte(MSG_BROADCAST, real_frametime);

	WriteShort(MSG_BROADCAST, self.velocity_x);
	WriteShort(MSG_BROADCAST, self.velocity_y);
	WriteShort(MSG_BROADCAST, self.velocity_z);

	if (self.modelindex != modelindex_player)
		WriteByte(MSG_BROADCAST, self.modelindex);

	if (self.effects)
		WriteByte(MSG_BROADCAST, self.effects);
};
