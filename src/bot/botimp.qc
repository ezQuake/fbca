/*
	bot/botimp.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 1999-2000 Numb
	Copyright (C) 2000-2007 ParboiL
*/

void() GameSettings;
void() LoadTemp1;
void() AddBot;
float() AddRandomBot;
void() AddBotError;
void() AddBots;
void() DoCountDown;
void() PlayerReady;

/*
============
SetAttribs

============
*/
void() SetAttribs =
{
	local float smartness;

	smartness = 10;

	skill_ = self.bot_skill;

	if (game_show_rules)
	{
		bprint_fb(2, "skill ê");
		bprint_g(2, skill_);
		bprint_fb(2, "ë\n");
	}
	if (skill_ > 10)
	{
		self.fast_aim = (skill_ - 10) * 0.1;	// 0.1 to 1
		skill_ = 10;
	}
	else
		self.fast_aim = 0;

	self.firing_reflex = 0.5 - (skill_ * 0.04);	// 0.5 to 0.1
	self.accuracy = 45 - (skill_ * 2.25);	// 45 to 22.5

	self.stop_turn_speed = 135 + (smartness * 40.5);	// 135 to 540
	self.dodge_amount = smartness * 0.1;		// 0 to 1
	self.look_anywhere = smartness * 0.1;	// 0 to 1
	self.lookahead_time = 5 + (smartness * 2.5);		// 5 to 30
	self.prediction_error = 1 - (smartness * 0.1);	// 1 to 0
};

void() SetGame =
{
	game_disable_powerups = (!(gamemode & GAME_ENABLE_POWERUPS));
	game_enable_runes = gamemode & GAME_ENABLE_RUNES;
	game_not_rune_rj = (!(gamemode & GAME_RUNE_RJ));
	game_rl_pref = gamemode & GAME_RL_PREF;
	game_lg_pref = gamemode & GAME_LG_PREF;
	game_not_match = (!(gamemode & GAME_MATCH));
	game_lava_cheat = gamemode & GAME_LAVA_CHEAT;
	game_show_rules = (!(gamemode & GAME_HIDE_RULES));
	game_disable_autoreport = (!(gamemode & GAME_ENABLE_AUTOREPORT));
	game_disable_dropweap = (!(gamemode & GAME_ENABLE_DROPWEAP));
	game_disable_autosteams = (!(gamemode & GAME_ENABLE_AUTOSTEAMS));
	game_disable_botchat = (!(gamemode & GAME_ENABLE_BOTCHAT)); 
	game_qizmo = (stof(infokey(world, "proxy")));
	a_gamemode();
};

/*
============
InitParameters

============
*/
void() InitParameters =
{
	local float ds;

	first_ent = nextent(world);
	test_enemy = first_ent;
	while(test_enemy)
	{
		maxplayers = maxplayers + 1;
		test_enemy = nextent(test_enemy);
	}

	dropper = spawn();	// first entity after clients
	setsize (dropper, VEC_HULL_MIN, VEC_HULL_MAX);

	dropper.desire = goal_NULL;
	dropper.virtual_goal = dropper;

	self = dropper;
	NewItems();

	InitBodyQue ();

	temp1 = stof(infokey(world, "temp1"));
	deathmatch = cvar("deathmatch");

	if (maxplayers > 24)
		maxplayers = 24;

	nextmap = mapname;
	pre_game = TRUE;

	gamemode = cvar("samelevel");

	SetGame();

	teamplay = cvar("teamplay");

	initialize();

	if (teamplay == 1)
		healthplay = TEAM_TOTAL_HEALTH_PROTECT;
	else if (teamplay == 2)
		healthplay = TEAM_FRAG_PENALTY;
	else if (teamplay == 3)
		healthplay = TEAM_HEALTH_PROTECT;
	else if (teamplay == 4)
	{
		healthplay = TEAM_HEALTH_PROTECT;
		armorplay = TRUE;
	}
	else if (teamplay == 5)
	{
		healthplay = TEAM_TOTAL_HEALTH_PROTECT;
		armorplay = TRUE;
	}
	else
	{
		teamplay = 0;
		cvar_set("teamplay", "0");
	}

	next_teamplay = teamplay;

	if (!temp1)
	{
		ds = stof(infokey(world, "d_skill"));
		if (ds) skill = ds;
		else skill = 10;
		localcmd("\n");	// flush buffer (early Quake versions)
		localsave(0, 1, 0);
		localsave(1, 1, 1);
	}
	else
		LoadTemp1();

	SetSkill();

	sv_accelerate = cvar("sv_accelerate");
	sv_friction = cvar("sv_friction");

	numberofbots = -1;

	if ((deathmatch != floor(deathmatch)) || (deathmatch < 1) || (deathmatch > MAX_DEATHMATCH))
	{
		deathmatch = 1;
		cvar_set("deathmatch", "1");
	}

	next_deathmatch = deathmatch;

	if (game_not_match)
	{
		GameSettings();
		max_dead_time = 1000000;
	}
	else
		max_dead_time = 5;

	if (deathmatch <= 3)
		available_weapons = IT_AXE_SHOTGUN;
	else
	{
		if (deathmatch == 4)
			available_weapons = IT_ALL_BUT_GRENADE;
		else
			available_weapons = IT_ALL;
	}

	if (deathmatch != 4)
		quad_factor = 4;
	else
		quad_factor = 8;

	leave = (deathmatch != 1);

	sv_maxspeed = cvar("sv_maxspeed");

	if (sv_maxspeed >= 346.666666)
	{
		if (sv_maxspeed > 400)
		{
			cvar_set("sv_maxspeed", "400");
			sv_maxspeed = 400;
		}
		sv_maxstrafespeed = 346.666666;
	}
	else
	{
		if (sv_maxspeed < 320)
		{
			cvar_set("sv_maxspeed", "320");
			sv_maxspeed = 320;
		}
		sv_maxstrafespeed = sv_maxspeed;
	}

	sv_maxwaterspeed = sv_maxspeed * 0.7;
	half_sv_maxspeed = sv_maxspeed * 0.5;
	inv_sv_maxspeed = 1 / sv_maxspeed;
};

/*
============
SaveTemp1

============
*/
void() SaveTemp1 =
{
	localcmd("localinfo temp1 ");
	localcmd_ftos(skill + 1);
	localcmd("\n");
};

/*
============
SetSkill

============
*/
void() SetSkill =
{
	bprint_fb(2, "\"skill\" changed to \"");
	bprint_ftos(2, skill);
	bprint_fb(2, "\"\n");
	first_ent.bot_skill = skill;
	SaveTemp1();
};

/*
============
LoadTemp1

============
*/
void() LoadTemp1 =
{
	skill = temp1 - 1;
};

/*
============
localsave

============
*/
void(float frogbot_pos, float index_, float value) localsave =
{
	localcmd("localinfo ");
	localcmd_ftos(frogbot_pos * 2 + index_);
	localcmd(" ");
	localcmd_ftos(value);
	localcmd("\n");
};

/*
============
localload

============
*/
void(float frogbot_pos) localload =
{
	str = ftos(frogbot_pos * 2 + frogbot_load_stage);
	registered = stof(infokey(world, str));
};

/*
============
SaveFrogbot

============
*/
void() SaveFrogbot =
{
	localsave(numberofbots, 1, 2 + self.color_+ self.teamcolor * 256 + self.bot_skill * 65536);
	localsave(numberofbots, 2, self.botnumber);
	localsave(numberofbots + 1, 1, 1);
};

/*
============
LoadFrogbot

============
*/
void() LoadFrogbot =
{
	self = postphysics;

	if (frogbot_load_stage)
	{
		if (numberofbots == -1)
		{
			first_ent.admin_code = self.admin_code = registered;
			numberofbots = 0;
			if (invalid_map)
			{
				load_frogbots = FALSE;
				return;
			}
		}
		else
		{
			if (frogbot_load_stage == 1)
			{
				if (registered == 1)
				{
					load_frogbots = FALSE;
					return;
				}
				registered = registered - 2;
				self.color_ = registered & 255;
				self.teamcolor = floor(registered / 256) & 255;
				self.bot_skill = floor(registered / 65536) & 255;
			}
			else if (frogbot_load_stage == 2)
				self.botnumber = registered;
			self.old_bot = TRUE;

			if (frogbot_load_stage <= NUMBER_LOAD_STAGE)
			{
				frogbot_load_stage = frogbot_load_stage + 1;
				localload(numberofbots + 1);
				return;
			}
			AddBot();
		}
	}

	frogbot_load_stage = 1;
	localload(numberofbots + 1);
};

/*
============
CheckParameters

============
*/
void() CheckParameters =
{
	if (!game_not_match || game_arena)
		real_time = check_parm_time - start_time;
	if (!game_not_match)
	if (start_time)
		DoCountDown();

	if (timelimit)
	{
		if (!game_not_match)
		{
			if (!pre_game)
			if (real_time >= timelimit_user * 60)
				NextLevel();
		}
		else
		{
			if (real_time >= timelimit * 60)
				NextLevel();
		}
	}

	check_parm_time = floor(time) + 1;

	if (sv_accelerate != cvar("sv_accelerate"))
	{
		sv_accelerate = cvar("sv_accelerate");

		if (sv_accelerate < 10)
			sv_accelerate = 10;

		cvar_log("sv_accelerate", sv_accelerate);
	}

	if (next_deathmatch != cvar("deathmatch"))
	{
		next_deathmatch = cvar("deathmatch");
		bprint_fb(2, "deathmatch changed to ");
		bprint_ftos(2, next_deathmatch);
		bprint_fb(2, "\n(enabled after restart)\n");
	}

	if (next_teamplay != cvar("teamplay"))
	{
		next_teamplay = cvar("teamplay");
		bprint_fb(2, "teamplay changed to ");
		bprint_ftos(2, next_teamplay);
		bprint_fb(2, "\n(enabled after restart)\n");
	}


	if (sv_accelerate > 10)
		sv_maxfriction = 10;
	else
		sv_maxfriction = sv_accelerate;

	if (sv_friction > sv_maxfriction)
		cvar_set_("sv_friction", sv_maxfriction);

	if (sv_friction != cvar("sv_friction"))
	{
		sv_friction = cvar("sv_friction");
		if (sv_friction < 0)
			sv_friction = 0;
		cvar_log("sv_friction", sv_friction);
	}

	fraglimit = cvar("fraglimit");

	if ((cvar("sv_gravity") != 800) && (mapname != "e1m8"))
		cvar_set("sv_gravity", "800");

	if ((cvar("sv_gravity") != 100) && (mapname == "e1m8"))
		cvar_set("sv_gravity", "100");

	if (cvar("sv_mintic") != 0)
		cvar_set("sv_mintic", "0");

	if (sv_maxspeed != cvar("sv_maxspeed"))
		NextLevel();
};

/*
============
BotExists

============
*/
float() BotExists =
{
	bot = frogbot_spawned;
	while (bot != postphysics)
	{
		if (bot != self)
		{
		if (bot.botnumber == self.botnumber)
				return TRUE;
		}
		bot = nextent(bot);
	}
	return FALSE;
};

/*
============
HCFrogbot

============
*/
void(float color, float numb) HCFrogbot =
{
	self.color_ = color;
	self.botnumber = numb;
};

/*
============
BeenSpawned

============
*/
float(entity client, float value) BeenSpawned =
{
	if (value < 48)
	{
		spawnbit0_ = 1;
		spawnbit1_ = 0;

		while (value > 0)
		{
			spawnbit0_ = spawnbit0_ * 2;
			value = value - 1;
		}

		if (spawnbit0_ >= 16777216)
		{
			spawnbit1_ = spawnbit0_ / 16777216;
			spawnbit0_ = 0;
		}

		if (client.spawnbit0 & spawnbit0_)
			return TRUE;
		if (client.spawnbit1 & spawnbit1_)
			return TRUE;
		client.spawnbit0 = client.spawnbit0 | spawnbit0_;
		client.spawnbit1 = client.spawnbit1 | spawnbit1_;
		client.number_spawnbits = client.number_spawnbits + 1;
	}
	return FALSE;
};

/*
============
SpawnHardBot

============
*/
void() SpawnHardBot =
{
	do
	{
		rnd = random();
		rnd = floor(rnd * NUMBERHARDBOTS);
	} while (BeenSpawned(other, rnd + other.number_bots));

	if (rnd == 0) HCFrogbot(45, 1);
	else if (rnd == 1) HCFrogbot(59, 2);
	else if (rnd == 2) HCFrogbot(19, 3);
	else if (rnd == 3) HCFrogbot(196, 4);
	else if (rnd == 4) HCFrogbot(33, 5);
	else if (rnd == 5) HCFrogbot(203, 6);
	else if (rnd == 6) HCFrogbot(43, 7);
	else if (rnd == 7) HCFrogbot(205, 8);
	else if (rnd == 8) HCFrogbot(60, 9);
	else if (rnd == 9) HCFrogbot(160, 10);
	else if (rnd == 10) HCFrogbot(168, 11);
	else if (rnd == 11) HCFrogbot(212, 12);
	else if (rnd == 12) HCFrogbot(70, 13);
	else if (rnd == 13) HCFrogbot(4, 14);
	else if (rnd == 14) HCFrogbot(75, 15);
	else HCFrogbot(13, 16);
};

string() SetNetName =
{
	if (self.botnumber == 1) return "⁄a–";
	else if (self.botnumber == 2) return "Bro";
	else if (self.botnumber == 3) return "f“A«Ögœd";
	else if (self.botnumber == 4) return "‰Ú·ÁÓ";
	else if (self.botnumber == 5) return "‘hresË";
	else if (self.botnumber == 6) return "ÁÔÏ‰ÂÓboy";
	else if (self.botnumber == 7) return "“Âtile";
	else if (self.botnumber == 8) return "«≈Œ≈“¡ÃÖf¡lU“e";
	else if (self.botnumber == 9) return "˘Ô‰·";
	else if (self.botnumber == 10) return "dude";	
	else if (self.botnumber == 11) return "di⁄⁄y";
	else if (self.botnumber == 12) return "SıÂÚÌ·Ó";
	else if (self.botnumber == 13) return "girlie";
	else if (self.botnumber == 14) return "ÖCÚPÛ≈ÖGÚN‰Ö";	
	else if (self.botnumber == 15) return "À…ÃÃ…Œ«ÖÕ¡√»…Œ≈";
	else return "aƒd…c‘eƒÒı·ÎÂ";
};

/*
============
SpawnBot

============
*/
float() SpawnBot =
{
	do
	{
		if (self.number_spawnbits >= self.number_bots)
			return FALSE;
		rnd = random();
		rnd = floor(rnd * self.number_bots);
	} while (BeenSpawned(self, rnd));

	msg_entity = self;
	stuffcmd("bot");
	stuffcmd_ftos(rnd + 1);
	stuffcmd("\n");

	return TRUE;
};

/*
============
AddRandomBot

============
*/
float() AddRandomBot =
{
	if (self.number_bots < 0)
	{
		if (self.number_bots == -1)
			self.number_bots = 0 - time;
		else if (self.number_bots != (0 - time))
			self.number_bots = 0;
		if (self.number_bots)
		{
			msg_entity = self;
			stuffcmd("wait;addbot\n");
			return TRUE;
		}
	}
	return (SpawnBot());
};

/*
============
AddBot

Note: color = (shirt_color * 16) + pants_color
	team = pants_color + 1
	colors: 0 to 13
============
*/
void() AddBot =
{
	local float t1, t2, color;
	if (self.player)
	{
		if (load_frogbots)
			return;
		if (invalid_map)
		{
			InvalidMap();
			impulse_ = 0;
			return;
		}
	}
	if (markers_loaded)
	{
		if ((numberofclients >= stof(infokey(world, "maxclients"))) || (numberofbots == 16))
		{
			sprint_fb(self, 2, "Server is full.\n");
		}
		else
		{
			if (!self.botnumber)
			{
				if (AddRandomBot())
					return;
			}
			else if (BotExists())
			{
				CopyBot(self, world);	// NULL
				if (AddRandomBot())
					return;
			}
			other = self;
			numberofbots = numberofbots + 1;
			localcmd("localinfo scratch2 ");
			localcmd_ftos(numberofbots);
			localcmd("\n");
			self = frogbot_spawned = EntityAt(first_frogbot, maxplayers - numberofbots);
			self.flags = 0;
			self.frogbot = TRUE;
			self.classname = "frogbot";
			self.stringname = "gamer";
			self.waterlevel = 0;
			self.watertype = 0;
			self.frags = 0;
			self.deadflag = 0;
			self.arrow = 0;
			self.button0_ = 0;
			self.jump_flag = 0;
			self.effects = 0;
			self.color_ = other.color_;
			self.teamcolor = other.teamcolor;
			if (game_arena)
				other.teamcolor = 0;
			self.bot_skill = skill;
			CopyBot(self, other);
			CopyBot(other, world);	// NULL
			scoreboardsize = scoreboardsize + 1;
			if (!self.botnumber)
			{
				do
				{
					SpawnHardBot();
				} while (BotExists());
			}
			if (other.player)
				SaveFrogbot();
			if (teamplay && !game_disable_autosteams)
			{
				t1 = 0;
				t2 = 0;
				search_entity = first_client;
				while(search_entity)
				{
					if (search_entity != self)
					{
						if (search_entity.realteam == TEAM_COLOR1) 
							t1 = t1 + 1;
						else if (search_entity.realteam == TEAM_COLOR2) 
							t2 = t2 + 1;
					}
					search_entity = search_entity.next;
				}
				if ((t1 < t2) || ((t1 == t2) && (random() < 0.5)))
					color = TEAM_COLOR1;
				else
					color = TEAM_COLOR2;
				self.teamcolor = (color - 1) * 17;
				self.color_ = self.teamcolor;
				self.team = color;
			}
			else
			{
				if (teamplay)
					self.color_ = self.teamcolor;
				self.team = (self.color_ & 15) + 1;
			}
			UpdateFrags(self);
			self.netname = SetNetName();
			SetColorName(MSG_ALL, self);
			ClientConnect_apply();
			SetAttribs();
			PutClientInServer();
			self.old_bot = other.old_bot;
			if (!game_disable_botchat && !self.old_bot)
				say_hello(self);
			self.oldorigin = self.origin;
			if (!game_not_match && !game_arena)
			{
				self.ready = 0; 
				PlayerReady();
			}
			self = other;
		}
	}
};

/*
============
AddBots

============
*/
void() AddBots =
{
	min_second = maxplayers - scoreboardsize + 1;
	if (impulse_ > min_second)
		impulse_ = min_second;

	while (impulse_ > 0)
	{
		impulse_ = impulse_ - 1;
		AddBot();
	}
};

/*
============
ClearSpawnBits

============
*/
void() ClearSpawnBits =
{
	test_enemy = find(world, classname, "player");
	while (test_enemy)
	{
		test_enemy.spawnbit0 = test_enemy.spawnbit1 = test_enemy.number_spawnbits = 0;
		test_enemy = find(test_enemy, classname, "player");
	}
};

/*
============
RemoveBot

============
*/
float(float remove_name) RemoveBot =
{
	if (numberofbots)
	{
		if (load_frogbots)
			return 0;
		if (time >= frogbot_removetime)
		{
			frogbot_removetime = time + 0.1;

			ClearSpawnBits();

			removebot_self = self;
			self = frogbot_spawned;

			scoreboardsize = scoreboardsize - 1;

			if (self.client_)
				ClientDisconnect();
			self.nextthink = 0;

			self.netname = ""; 

			if (remove_name)
				ClearName(MSG_ALL, self);

			localsave(numberofbots, 1, 1);
			numberofbots = numberofbots - 1;
			localcmd("localinfo scratch2 ");
			localcmd_ftos(numberofbots);
			localcmd("\n");
			frogbot_spawned = nextent(frogbot_spawned);

			self = removebot_self;
		}
	}
	return numberofbots;
};

void() AutoRemoveBot =
{
	if (RemoveBot(TRUE))
		self.nextthink = time + 0.1;
	else
		remove_self();
};

void() RemoveAllBots =
{
	test_enemy = spawn();
	test_enemy.think = AutoRemoveBot;
	test_enemy.nextthink = 0.001;
};

/*
============
ToggleFlash

============
*/
void() ToggleFlash =
{
	if (self.preferences & PREF_FLASH)
	{
		sprint_fb(self, 2, "flashs off\n");
		self.preferences = self.preferences - PREF_FLASH;
	}
	else
	{
		sprint_fb(self, 2, "flashs on\n");
		self.preferences = self.preferences | PREF_FLASH;
	}
};

/*
============
ToggleFramerate

============
*/
void() ToggleFramerate =
{
	if (self.print_framerate)
		self.print_framerate = FALSE;
	else
		self.print_framerate = TRUE;
};

/*
============
ToggleGameMode

============
*/
void(float value, string s) ToggleGameMode =
{
	new_gamemode = cvar("samelevel");

	if (new_gamemode & value)
	{
		new_gamemode = new_gamemode - value;
		bprint_fb(2, s);
		bprint_fb(2, " disabled after restart\n");
	}
	else
	{
		new_gamemode = new_gamemode | value;
		bprint_fb(2, s);
		bprint_fb(2, " enabled after restart\n");
	}

	cvar_set_("samelevel", new_gamemode);
};

/*
============
ToggleGameModeNow

============
*/
void(float value, string s) ToggleGameModeNow =
{
	new_gamemode = cvar("samelevel");

	if (gamemode & value)
	{
		gamemode = gamemode - value;
		new_gamemode = new_gamemode - (new_gamemode & value);
		bprint_fb(2, s);
		bprint_fb(2, " disabled\n");
	}
	else
	{
		gamemode = gamemode | value;
		new_gamemode = new_gamemode | value;
		bprint_fb(2, s);
		bprint_fb(2, " enabled\n");
	}

	cvar_set_("samelevel", new_gamemode);
	SetGame();
};

/*
============
print_boolean

============
*/
void(float value, string s) print_boolean =
{
	sprint_fb(self, 2, s);
	if (gamemode & value)
		sprint_fb(self, 2, "enabled\n");
	else
		sprint_fb(self, 2, "disabled\n");
};

/*
============
PrintRules

============
*/

void() PrintRules =
{
	sprint_fb(self, 2, "ÛÎÈÏÏ....... ");
	sprint_ftos(self, 2, skill);
	sprint_fb(self, 2, "\n‰Â·ÙËÌ·Ù„Ë.. ");
	sprint_ftos(self, 2, deathmatch);
	sprint_fb(self, 2, "\nÙÂ·ÌÏ·˘.... ");
	sprint_ftos(self, 2, teamplay);
	sprint_fb(self, 2, "\n");
	a_rulesfix();
	print_boolean(GAME_ENABLE_POWERUPS, "Ô˜ÂÚıÛ.... ");
	print_boolean(GAME_ENABLE_RUNES, "ÚıÓÂ........ ");
	print_boolean(GAME_RUNE_RJ, "ÚıÓÂﬂÚÍ..... ");
	print_boolean(GAME_MATCH, "Ì·Ù„Ë....... ");
	print_boolean(GAME_LAVA_CHEAT, "Ï·ˆ·„ËÂ·Ù... ");
	print_boolean(GAME_RL_PREF, "ÚÏﬂÚÂÊ..... ");
	print_boolean(GAME_LG_PREF, "ÏÁﬂÚÂÊ..... ");
	print_boolean(GAME_HIDE_RULES, "ËÈ‰Â........ ");
	print_boolean(GAME_ENABLE_AUTOREPORT, "·ıÙÔÚÂÔÚÙ.. ");
	print_boolean(GAME_ENABLE_DROPWEAP, "‰ÚÔ˜Â·.... ");
	print_boolean(GAME_ENABLE_AUTOSTEAMS, "·ıÙÔÛÙÂ·ÌÛ.. ");
	print_boolean(GAME_ENABLE_BOTCHAT, "‚ÔÙ„Ë·Ù..... ");
	a_boolean();
	sprint_fb(self, 2, "\n");

	if (sv_accelerate != 10)
	{
		sprint_fb(self, 2, "sv_accelerate is ");
		sprint_ftos(self, 2, sv_accelerate);
		sprint_fb(self, 2, "\n");
	}
	if (sv_friction != 4)
	{
		sprint_fb(self, 2, "sv_friction is ");
		sprint_ftos(self, 2, sv_friction);
		sprint_fb(self, 2, "\n");
	}
};

/*
============
PrintFramerate

============
*/
void() PrintFramerate =
{
	sprint_ftos(self, 2, 1/frametime);
	sprint_fb(self, 2, " ");
	sprint_ftos(self, 2, 1/average_frametime);
	sprint_fb(self, 2, " ");
	sprint_ftos(self, 2, (framecount - framecount_start) / (time - time_start));
	sprint_fb(self, 2, "\n");
};

/*
============
PrintTime

============
*/
void() PrintTime =
{
	if (pre_game) return;
	time_to_print = time - start_time;
	sprint_fb(self, 2, "‘ÈÌÂ: ");
	minutes = floor (time_to_print / 60);
	if (minutes < 10)
		sprint_fb(self, 2, " ");	// add extra space in minutes
	sprint_g(self, 2, minutes); // minutes
	sprint_fb(self, 2, "∫");
	seconds = floor (time_to_print - (minutes * 60));
	if (seconds < 10)
		sprint_fb(self, 2, "í");	// add extra 0 in seconds
	sprint_g(self, 2, seconds); // seconds
	sprint_fb(self, 2, "\n");
};

/*
============
AddBotError

============
*/
void() AddBotError =
{
	sprint_fb(self, 2, "There is no support of external bots!\n");
	self.spawnflags = self.impulse = self.lines = 0;
	self.input_time = time + 2;
	self.spawnbit0 = self.spawnbit1 = self.number_spawnbits = 0;
	CopyBot(self, world);	// NULL
};

/*
============
NoAdmin

============
*/
void() NoAdmin =
{
	sprint_fb(self, 2, "You don't have admin privileges\n");
};

/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	if (self.impulse)
	{
		if (intermission_running || k_standby) return;

		if (time >= self.input_time)
		{
			impulse_ = self.impulse;

			if (impulse_ == IMP_JOIN)
				join();
			else if (impulse_ == IMP_OBSERVE)
				observe();

			if (!self.client_ && numberofplayers > 0) return; 

			if (self.lines)
			{
				self.lines = self.lines - 1;
				if (self.lines < 2)
				{
					AddBotError();
					return;
				}
			} 
			else if (impulse_ >= 200 && impulse_ <= 245)
				SelectMap();

			if (impulse_ == 140)
				f_jump();

			if (impulse_ == 141)
				r_jump();

			if (self.spawnflags)
			{
				self.impulse = 0;
				ScratchCommands();
			}
			else if (impulse_ < IMP_START1)
			{
				if (self.lines)
					AddBotError();
			}
			else
			{
				self.impulse = 0;

				if (impulse_ > IMP_END4)
				{
					if (self.lines)
						AddBotError();
				}
				else if (impulse_ <= IMP_END2)
				{
					if (impulse_ <= IMP_END1)
						self.spawnflags = impulse_ - IMP_START1 + START_SKILL;
					else
					{
						if (self.lines)
						{
							if (self.lines != 2)
							{
								AddBotError();
								return;
							}
							self.lines = 0;
						}
						if (impulse_ == IMP_LINES)
							self.spawnflags = START_LINES;
						else if (self.admin_code != dropper.admin_code)
							NoAdmin();
						else if (impulse_ <= IMP_ADD4BOTS)
						{
							impulse_ = impulse_ - IMP_ADDBOT + 1;
							AddBots();
						}
						else
						{
							self.teamcolor = (impulse_ - IMP_ADDBOT0) * 17;
							AddBot();
						}
					}
				}
				else if (self.lines)
					AddBotError();
				else if (impulse_ == IMP_MSG)
					self.spawnflags = START_MSG;
				else if (impulse_ == IMP_BOTS)
					self.spawnflags = START_BOTS;
				else if (impulse_ == IMP_ADMIN)
					self.spawnflags = START_ADMIN1;
				else if (impulse_ == IMP_TIME)
					PrintTime();
				else if (impulse_ == IMP_RULES)
					PrintRules();
				else if (impulse_ == IMP_ABOUT)
					SprintVersion();
				else if (impulse_ == IMP_SCORES)
					PrintScores();
				else if (impulse_ == IMP_FLASH)
					ToggleFlash();
				else if (self.admin_code != dropper.admin_code)
					NoAdmin();
				else if (impulse_ == IMP_HIDE)
					ToggleGameModeNow(GAME_HIDE_RULES, "hide");
				else if (impulse_ == IMP_REMOVEBOT)
					RemoveBot(TRUE);
				else if (impulse_ == IMP_REMOVEALLBOTS)
					RemoveAllBots();
				else if (impulse_ == IMP_LAVACHEAT)
					ToggleGameModeNow(GAME_LAVA_CHEAT, "lavacheat");
				else if (impulse_ == IMP_FRAMERATE)
					ToggleFramerate();
				else if (impulse_ == IMP_POWERUP)
					ToggleGameMode(GAME_ENABLE_POWERUPS, "powerups");
				else if (impulse_ == IMP_AUTOREPORT)
					ToggleGameModeNow(GAME_ENABLE_AUTOREPORT, "autoreport");
				else if (impulse_ == IMP_DROPWEAP)
					ToggleGameModeNow(GAME_ENABLE_DROPWEAP, "dropweap");
				else if (impulse_ == IMP_AUTOSTEAMS)
					ToggleGameModeNow(GAME_ENABLE_AUTOSTEAMS, "autosteams");
				else if (impulse_ == IMP_RUNE)
					ToggleGameMode(GAME_ENABLE_RUNES, "rune");
				else if (impulse_ == IMP_READY)
					PlayerReady();
				else if (impulse_ == IMP_WHO)
					PlayerStatus();
				else if (impulse_ == IMP_BREAK)
					PlayerBreak();
				else if (impulse_ == IMP_TIMEDOWN)
					TimeDown();
				else if (impulse_ == IMP_TIMEUP)
					TimeUp();
				else if (impulse_ == IMP_FRAGSDOWN)
					FragsDown();
				else if (impulse_ == IMP_FRAGSUP)
					FragsUp();
				else if (impulse_ == IMP_SKILLDOWN)
					SkillDown();
				else if (impulse_ == IMP_SKILLUP)
					SkillUp();
				else if (impulse_ == IMP_CHDM)
					ChangeDM();
				else if (impulse_ == IMP_NO_LG)
					ToggleLighting();
				else if (impulse_ == IMP_SH_SPEED)
					toggle_sh_speed();
				else if (impulse_ == IMP_WS_ON)
					start_print_wp_stats();
				else if (impulse_ == IMP_WS_OFF)
					end_print_wp_stats();
				else if (impulse_ == IMP_WS_RES)
					reset_wp_stats();
				else if (impulse_ == IMP_CHTP)
					ChangeTP(); 
				else if (impulse_ == IMP_LOCK)
					ChangeLock();
				else if (impulse_ == IMP_SILENCE)
					ToggleSpecTalk();
				else if (impulse_ == IMP_MATCH)
					ToggleGameMode(GAME_MATCH, "match");
				else if (impulse_ == IMP_OVERTIME)
					ChangeOvertime();
				else if (impulse_ == IMP_BOTCHAT)
					ToggleGameModeNow(GAME_ENABLE_BOTCHAT, "botchat");
				else if (impulse_ == IMP_RL_PREF)
				{
					if (game_lg_pref)
						ToggleGameModeNow(GAME_LG_PREF, "lg_pref"); 
					ToggleGameModeNow(GAME_RL_PREF, "rl_pref");
				}
				else if (impulse_ == IMP_LG_PREF)
				{
					if (game_rl_pref)
						ToggleGameModeNow(GAME_RL_PREF, "rl_pref");
					ToggleGameModeNow(GAME_LG_PREF, "lg_pref");
				} 
				else if (impulse_ == IMP_RUNE_RJ)
					ToggleGameModeNow(GAME_RUNE_RJ, "rune_rj");
				a_impulses();
			}
		}
		else
		{
			self.impulse = 0;
			self.input_time = time + 2;
		}
	}
};