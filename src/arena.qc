/*
	arena.qc

	arena game mode

	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
*/

// definitions

.float entertime;
.float ping;
.float ping_;
.float packetloss;
.float packetloss_;
float pingupdate;
float SVC_UPDATEPACKETLOSS = 53;
float SVC_SETANGLE = 10;
.float itemstarted;
.float botchose;
.float aggressive;
.float invisible;
.float trackprint_time;
.float tracking;
.float printmotd;
.float connected;
.float scoreboard;
.float rocketjumping;
.float userid;
.float alias1time;
.float alias2time;
.float alias3time;
.float alias4time;
.float damfrags;
.float players;
.float wins;
.float teamnumber;
.float shirt1;
.float shirt2;
.float shirt3;
.float shirtcolor;
.float shirtcolor_;
.float pantscolor;
.float pantscolor_;
.float botpantscolor;
.float nextthink2;
.float gravity;
.float a_button0;
.float a_button2;
.vector oldangles;
.entity chasing;
.void() think2;
entity team0;
entity team1;
entity team2;
entity team3;
entity team4;
entity updatebot;
float cvar_;
float print_;
float reset_;
string varg;
float var_;
float min_;
float max_;
float idleprint_time;
float last_action_time;
float force_time;
float users;
float inter_print;
float loadbot_time;
float loadingbots;
float check_loadingbots;
float game_drop;
float game_botjump;
float game_damage;
float game_raspawn;
float GAME_DROP		= 524288;
float GAME_ARENA		= 1048576;
float GAME_DAMAGE		= 2097152;
float GAME_RASPAWN	= 4194304;
float GAME_BOTJUMP	= 8388608;
float teams;
float round;
float rounds;
float a_health;
float a_armorvalue;
float a_armortype;
float a_ammo_shells;
float a_ammo_nails;
float a_ammo_rockets;
float a_ammo_cells;
float a_items;
float arenastate;
float A_IDLE 		= 0;
float A_STARTING 		= 1;
float A_PREROUND		= 2;
float A_PLAYING 		= 3;
float A_POSTROUND		= 4;
float a_nextthink;
float friction_factor;
float initialized;
float updatestuff;
float exclamation = 33;
float period 	= 46;
float a_sounds;
string a_spawn;
float BIT_30 = 1073741824;
float BIT_29 = 536870912;
float BIT_28 = 268435456;
float BIT_27 = 134217728;
float BIT_26 = 67108864;
float BIT_25 = 33554432;
float BIT_24 = 16777216;
float BIT_23 = 8388608;
float BIT_22 = 4194304;
float BIT_21 = 2097152;
float BIT_20 = 1048576;
float BIT_19 = 524288;
float BIT_18 = 262144;
float BIT_17 = 131072;
float BIT_16 = 65536;
float BIT_15 = 32768;
float BIT_14 = 16384;
float BIT_13 = 8192;
float BIT_12 = 4096;
float BIT_11 = 2048;
float BIT_10 = 1024;
float BIT_09 = 512;
float BIT_08 = 256;
float BIT_07 = 128;
float BIT_06 = 64;
float BIT_05 = 32;
float BIT_04 = 16;
float BIT_03 = 8;
float BIT_02 = 4;
float BIT_01 = 2;
float BIT_00 = 1;

// functions
void(float to, entity e) updatetime;
void(float to, entity e) updateping;
void(float to, entity e) updatepacketloss;
void(float to, entity e) updateuserinfo;
void(string s) dprint = #25;
// void() bot_netname;
// void() dprint_obituary;
void() updatebotpings;
void() print_limit;
void() FinalStats;
void() SetScoreboard2;
void() a_rocketjump;
void(float to, entity e) UpdateFrags2;
void() commands;
void() framethink;
void() checkifstart;
void() changecolor;
void() setinvisitems;
void() updateteams;
void() initialize;
void() selfconnect;
void() selfdisconnect;
void() selfdie;
void() choose_team;
void() choose_shirt;
void(float seconds_) timesound;
void() a_precache;
void() a_gamemode;
void() a_boolean;
void() a_impulses;
void() set_a_spawn;
float() players_;
float() putselfinserver;
float() best_rl;
float() best_gl;
float() a_prethink;
float() a_postthink;
float() a_newitems;
float() toss_player;
void() a_rulesfix;
void() a_skillfix;
void() a_attackfix;
float() scratch1;
void(entity newteam) addtoteam;
void() notready;
void() settings;
void() defaults;
void() forcestart;
void() changesounds;
void(float which, string wname) toggleweapon;
void() changearmortype;
void() togglenoclip;
void() fight;
void() print1;
void() print2;
void() print3;
void() print4;
void() print5;
void() fiveseconds;
void() roundsound;
void() nextround;
void() bluevsred;
void() startseries;
void() allinvisible;
void() ateamwon;
void() checkifteamwon;
void() idleprint;
void() becomeinvisible;
void() check_bot_choose_team;
void() solid_player;
void() track_off;
void() track_next;
void() track_toggle;
void() track;
void() a_think;
void() null = {};
void() aliases1;
void() aliases2;
void() aliases3;
void() aliases4;
void(string s, float value) alias;

// other functions used
void() obstruction;
void() VelocityForArrow;
void() BestArrowForDirection;
void() PrintRules;
void() GameSettings;
void() SetGame;
void() SpawnRunes;
void() fd_secret_use;
void() train_next;
void() CheckNewWeapon;
void() PrintRules;
void() GotoNextMap;
void(string s) centerprint_all;
void(entity e) UpdateFrags;
void() SelectSpawnPoint;
void(vector org, entity death_owner) spawn_tdeath;
float() W_BestWeapon;
void() NextLevel;
void(float value, string s) ToggleGameMode;
void(float value, string s) ToggleGameModeNow;
void(float value, string s) print_boolean;
void() goal_NULL;
void() health_touch;
void() armor_touch;
void() weapon_touch;
void() ammo_touch;
void() powerup_touch;
void() item_health;
void() item_armor1;
void() item_armor2;
void() item_armorInv;
void() weapon_supershotgun;
void() weapon_nailgun;
void() weapon_supernailgun;
void() weapon_grenadelauncher;
void() weapon_rocketlauncher;
void() weapon_lightning;
void() item_shells;
void() item_spikes;
void() item_rockets;
void() item_cells;
void() item_weapon;
void() item_artifact_invulnerability;
void() item_artifact_envirosuit;
void() item_artifact_invisibility;
void() item_artifact_super_damage;
void() SUB_regen;
void() BotWaterJumpFix;
void(float to, entity client) SetColorName;

// impulses
float IMP_DROP		= 71;
float IMP_ARENA		= 72;
float IMP_DAMAGE 		= 73;
float IMP_SETTINGS	= 74;
float IMP_DEFAULTS	= 75;
float IMP_RESTART		= 76;
float IMP_FORCE		= 77;
float IMP_SOUNDS		= 78;
float IMP_ARMORTYPE	= 79;
float IMP_SET_DEATHMATCH = 80;
float IMP_SET_TEAMPLAY	= 81;
float IMP_SET_TIMELIMIT = 82;
float IMP_SET_FRAGLIMIT = 83;
float IMP_SET_SKILL	= 84;
float IMP_SET_TEAMS	= 85;
float IMP_SET_ROUNDS	= 86;
float IMP_SET_HEALTH	= 87;
float IMP_SET_ARMOR	= 88;
float IMP_SET_SHELLS	= 89;
float IMP_SET_NAILS	= 90;
float IMP_SET_ROCKETS	= 91;
float IMP_SET_CELLS	= 92;
float IMP_SG		= 93;
float IMP_SSG		= 94;
float IMP_NG		= 95;
float IMP_SNG		= 96;
float IMP_GL		= 97;
float IMP_RL		= 98;
float IMP_LG		= 99;
float IMP_NOTREADY	= 100;
float IMP_OLDTEAM_BLUE 	= 101;
float IMP_OLDTEAM_RED 	= 102;
float IMP_OLDTEAM_YELLOW = 103;
float IMP_OLDTEAM_GREEN = 104;
float IMP_RA		= 105;
float IMP_BOTJUMP		= 106;
float IMP_ALIASES		= 107;
float IMP_COMMANDS	= 108;
float IMP_BREAK		= 109;
float IMP_TIMEDOWN	= 110;
float IMP_TIMEUP		= 111;
float IMP_FRAGSDOWN	= 112;
float IMP_FRAGSUP		= 113;
float IMP_SKILLDOWN	= 114;
float IMP_SKILLUP		= 115;
float IMP_JOIN		= 116;
float IMP_OBSERVE		= 117;
float IMP_LOCK		= 118;
float IMP_ABOUT		= 119;
float IMP_SCORES		= 120;
float IMP_CHDM		= 121;
float IMP_CHTP		= 122;
float IMP_SILENCE		= 124;
float IMP_NO_LG		= 125;
float IMP_WS_ON		= 126;
float IMP_WS_OFF		= 127;
float IMP_WS_RES		= 128;
float IMP_SH_SPEED	= 129;
float IMP_END4		= 130;
float IMP_NOCLIP		= 131;
// 140 kf_jump
// 141 kr_jump

// centerprint to all humans
void(string s) centerprint_all =
{
	msg_entity = find(world, classname, "player");
	while (msg_entity)
	{
		centerprint(msg_entity, s);
		msg_entity = find(msg_entity, classname, "player");
	}
};

// centerprint for countdown
void(string s) centerprint_players =
{
	msg_entity = find(world, classname, "player");
	while (msg_entity)
	{
		if (!msg_entity.invisible)
			centerprint(msg_entity, s);
		msg_entity = find(msg_entity, classname, "player");
	}
};

// check if n is an integer
float(float a) int =
{
	if (a == rint(a))
		return 1;
	return 0;
};

// check if n is an odd integer
float(float a) oint =
{
	if (int(a))
	if (!int(a / 2))
		return 1;
	return 0;
};

// check if a^b is an imaginary number
float(float a, float b) imaginary =
{
	if (a < 0)
	if (!int(b))
	if (!oint(1 / b))
		return 1;
	return 0;
};

// return digit in b place of number a (b = power of 10)
float(float a, float b) dig =
{
	local float c, d, e;
	a = fabs(a);
	c = floor(a / b);
	d = floor(c / 10) * 10;
	e = c - d;
	return e;
};

// returns a^b (w00t!)
float(float a, float b) pow =
{
	local float c, d, e, f, g, h, i, j, k;

	if (!a)
		return 0;
	if (!b)
		return 1;
	if (imaginary(a, b))
		return 0;
	if (b > 14000)
		return 0;
	b = rint(b * 100) / 100;
	c = fabs(b);
	c = floor(c);
	d = 1;
	while (c > 0)
	{
		c = c - 1;
		d = d * a;
	}
	if (!int(b))
	{
		e = 0.1;
		while (e >= 0.01)
		{
			f = dig(b, e);
			f = pow(a, f);
			if (f)
			{
				g = 50;
				if (a > 1)
					h = a;
				else
					h = 1;
				i = 0;
				while (g > 0)
				{
					g = g - 1;
					j = (h + i) / 2;

				k = pow(j, 1 / e);
					if (k == f)
						g = 0;
					else
					if (k > f)
						h = j;
					else
					if (k < f)
						i = j;
				}
				d = d * j;
			}
			e = e / 10;
		}
		if (a < 0)
			d = -1 * d;
	}
	if (b < 0)
		d = 1 / d;
	return d;
};

// used for testing (a^b)
void() power_ =
{
	local float a, b, c;
	a = stof(infokey(self, "saved1"));
	b = stof(infokey(self, "saved2"));
	b = rint(b * 100) / 100;
	c = pow(a, b);
	sprint_ftos(self, 2, a);
	sprint_fb(self, 2, "^");
	sprint_ftos(self, 2, b);
	sprint_fb(self, 2, " = ");
	sprint_ftos(self, 2, c);
	sprint_fb(self, 2, "\n");
};

// for player v_angle and angles
float(float a) anglemod2 =
{
	while (a >= 180)
		a = a - 360; // a < 180
	while (a < -180)
		a = a + 360; // a >= -180
	a = rint(a / 1.40625) * 1.40625; // 256 yaws, not 360
	return a;
};

// use instead of fixangle
void(entity client, vector v_ang) SetViewAngle =
{
	v_ang_x = anglemod2(v_ang_x);
	v_ang_y = anglemod2(v_ang_y);

	if (v_ang_x > 68.90625)
		v_ang_x = 68.90625; // max pitch
	if (v_ang_x < -78.75)
		v_ang_x = -78.75; // min pitch

	client.v_angle_x = v_ang_x * -1;
	client.v_angle_y = v_ang_y;

	client.angles_x = v_ang_x / 3;
	client.angles_y = v_ang_y;

	if (client.player)
	{
		msg_entity = client;
		WriteByte(MSG_ONE, SVC_SETANGLE);
		WriteAngle(MSG_ONE, client.v_angle_x);
		WriteAngle(MSG_ONE, client.v_angle_y);
		WriteAngle(MSG_ONE, client.v_angle_z);
	}
};

// what does this do?
float() check_cvar =
{
	local float asdf;
	if (cvar_)
		asdf = cvar(varg);
	else
		asdf = scratch1();
	if (asdf == var_)
		return var_;
	if (!int(asdf))
	{
		if (cvar_)
			cvar_set_(varg, var_);
		return var_;
	}
	if ((asdf < min_) || (asdf > max_))
	{
		if (asdf < min_)
			asdf = min_;
		else if (asdf > max_)
			asdf = max_;
		if (cvar_)
			cvar_set_(varg, asdf);
		if (var_ == asdf)
			return var_;
	}
	if (cvar_)
		cvar_set_(varg, asdf);
	if ((print_) || (!cvar_))
	{
		bprint_fb(2, "\"");
		bprint_fb(2, varg);
		bprint_fb(2, "\" changed to \"");
		bprint_ftos(2, asdf);
		bprint_fb(2, "\"\n");
	}
	if ((reset_) && (cvar_))
		bprint_fb(2, "(enabled after restart)\n");
	return asdf;
};

// man, i should have made comments when i wrote these functions
void() check_cvars =
{
	cvar_ =
	reset_ =
	print_ = 1;

	varg = "deathmatch";
	var_ = next_deathmatch;
	min_ = 1;
	max_ = MAX_DEATHMATCH;
	next_deathmatch = check_cvar();
	varg = "teamplay";
	var_ = next_teamplay;
	min_ = 0;
	max_ = MAX_TEAMPLAY;
	next_teamplay = check_cvar();

	reset_ = 0;

	varg = "timelimit";
	var_ = timelimit;
	min_ = 0;
	max_ = 9999;
	timelimit = check_cvar();

	varg = "fraglimit";
	var_ = fraglimit;
	min_ = 0;
	max_ = 9999;
	fraglimit = check_cvar();
};

// set skill, i guess
void() set_skill =
{
	reset_ = 0;
	print_ = 1;
	cvar_ = 0;
	varg = "skill";
	var_ = skill;
	min_ = 0;
	max_ = 20;
	skill = check_cvar();
};

// set teams to scratch1
void() set_teams =
{
	reset_ = 0;
	print_ = 1;
	cvar_ = 0;
	varg = "teams";
	var_ = teams;
	min_ = 2;
	max_ = 4;
	teams = check_cvar();
};

// set rounds
void() set_rounds =
{
	reset_ = 0;
	print_ = 1;
	cvar_ = 0;
	varg = "rounds";
	var_ = rounds;
	min_ = 1;
	max_ = 9999;
	rounds = check_cvar();
};

// set health
void() set_health =
{
	reset_ = 0;
	print_ = 1;
	cvar_ = 0;
	varg = "health";
	var_ = a_health;
	min_ = 1;
	max_ = 9999;
	a_health = check_cvar();
};

// set armor
void() set_armorvalue =
{
	reset_ = 0;
	print_ = 1;
	cvar_ = 0;
	varg = "armor";
	var_ = a_armorvalue;
	min_ = 0;
	max_ = 9999;
	a_armorvalue = check_cvar();
};

// set shells
void() set_shells =
{
	reset_ = 0;
	print_ = 1;
	cvar_ = 0;
	varg = "shells";
	var_ = a_ammo_shells;
	min_ = 0;
	max_ = 9999;
	a_ammo_shells = check_cvar();
};

// set nails
void() set_nails =
{
	reset_ = 0;
	print_ = 1;
	cvar_ = 0;
	varg = "nails";
	var_ = a_ammo_nails;
	min_ = 0;
	max_ = 9999;
	a_ammo_nails = check_cvar();
};

// set rockets
void() set_rockets =
{
	reset_ = 0;
	print_ = 1;
	cvar_ = 0;
	varg = "rockets";
	var_ = a_ammo_rockets;
	min_ = 0;
	max_ = 9999;
	a_ammo_rockets = check_cvar();
};

// set cells
void() set_cells =
{
	reset_ = 0;
	print_ = 1;
	cvar_ = 0;
	varg = "cells";
	var_ = a_ammo_cells;
	min_ = 0;
	max_ = 9999;
	a_ammo_cells = check_cvar();
};

// fix bunny-hopping
void() a_jumpfix =
{
	if (self.velocity_z < 0)
		self.velocity_z = 0;
};

// list commands
void() commands =
{
	if (self.k_stuff)
	{
		sprint_fb(self, 2, "Ô˜ÂÚıÛ.... quad, òòò, ring & suit\n");
		sprint_fb(self, 2, "‰ÚÔ........ drop quad/ring\n");
		sprint_fb(self, 2, "·ÚÂÓ·....... clan arena\n");
		sprint_fb(self, 2, "‚ÔÙÍıÌ..... bot jumping\n");
		sprint_fb(self, 2, "·‰‰‚ÔÙ...... add bot\n");
		sprint_fb(self, 2, "ÚÂÌÔˆÂ‚ÔÙ... remove bot\n");
		sprint_fb(self, 2, "ÚÂÛÙ·ÚÙ..... restart map\n");
		sprint_fb(self, 2, "„ÔÌÌ·Ó‰Û.... print commands\n");
		sprint_fb(self, 2, "ÚıÏÂÛ....... print rules\n");
		sprint_fb(self, 2, "ÍÔÈÓ........ joins game\n");
		sprint_fb(self, 2, "Ô‚ÛÂÚˆÂ..... reconnect as spectator\n");
		sprint_fb(self, 2, "ÏÔ„Î........ change locking mode\n");
		if (!game_not_match)
		{
			sprint_fb(self, 2, "ÚÂ·‰˘....... when you feel ready\n");
			sprint_fb(self, 2, "‚ÚÂ·Î....... unready\n");
			if (teamplay)
			{
				sprint_fb(self, 2, "·ıÙÔÚÂÔÚÙ.. auto team report\n");
				sprint_fb(self, 2, "·ıÙÔÛÙÂ·ÌÛ.. bot auto select team\n");
				sprint_fb(self, 2, "Û„ÔÚÂÛ...... match time and score\n");
			}
			sprint_fb(self, 2, "ÔˆÂÚÙÈÌÂ.... toggle overtime mode\n");
			sprint_fb(self, 2, "˜ËÔ......... players list\n");
			sprint_fb(self, 2, "ÙÈÌÂ‰Ô˜Ó.... -5 mins match time\n");
			sprint_fb(self, 2, "ÙÈÌÂı...... +5 mins match time\n");
			sprint_fb(self, 2, "ÊÚ·ÁÛ‰Ô˜Ó... -10 fraglimit\n");
			sprint_fb(self, 2, "ÊÚ·ÁÛı..... +10 fraglimit\n");
			sprint_fb(self, 2, "ÛÎÈÏÏ‰Ô˜Ó... -1 skill\n");
			sprint_fb(self, 2, "ÛÎÈÏÏı..... +1 skill\n");
			sprint_fb(self, 2, "‰Ì.......... change deathmatch mode\n");
			sprint_fb(self, 2, "Ù.......... change teamplay mode\n");
			sprint_fb(self, 2, "ÛÈÏÂÓ„Â..... toggle spectator talk\n");
			sprint_fb(self, 2, "ÓÔﬂÏÁ....... toggle shaft\n");
			sprint_fb(self, 2, "ÛËﬂÛÂÂ‰.... toggle use show speed\n");
			sprint_fb(self, 2, "´˜ﬂÛÙ·ÙÛ... start print weapon stats\n");
			sprint_fb(self, 2, "˜ﬂÚÂÛÂÙ.... clear weapon stats\n");
		}
		sprint_fb(self, 2, "‰ÚÔ˜Â·.... dropbackpack/weapon\n");
		sprint_fb(self, 2, "‚ÔÙ„Ë·Ù..... bot talk mode\n");
		sprint_fb(self, 2, "ÎÊÍıÌ...... just forward jump\n");
		sprint_fb(self, 2, "ÎÚÍıÌ...... just rocket jump\n");
		sprint_fb(self, 2, "·‚ÔıÙ....... fbca info\n");
	}
	else
	{
		sprint_fb(self, 2, "aliases (impulse ");
		sprint_ftos(self, 2, IMP_ALIASES);
		sprint_fb(self, 2, ")\n");
	}
};

// delay loading bots when changing map
float() loadbot_time_ =
{
	if (!loadingbots)
		return 1;
	if (!loadbot_time)
		loadbot_time = time + 3 + random() * 3;
	if (time >= loadbot_time)
	{
		local float asdf;
		rnd = random();
		if (rnd < 0.5)
			asdf = 0.01;
		else
		if (rnd < 0.75)
			asdf = 0.1;
		else
			asdf = 0.5;
		loadbot_time = loadbot_time + random() * asdf;
		return 1;
	}
	return 0;
};

void(string s, float val) alias =
{
	stuffcmd("alias ");
	stuffcmd(s);
	stuffcmd(" impulse ");
	stuffcmd_ftos(val);
	stuffcmd("\n");
};

// stuff 1st quarter of aliases
void() aliases1 =
{
	msg_entity = self;
	stuffcmd("alias ztndm3 impulse 200\n");
	stuffcmd("alias aerowalk impulse 201\n");
	stuffcmd("alias spinev2 impulse 202\n");
	stuffcmd("alias pkeg1 impulse 203\n");
	stuffcmd("alias ultrav impulse 204\n");
	stuffcmd("alias frobodm2 impulse 205\n");
	stuffcmd("alias amphi2 impulse 206\n");
	stuffcmd("alias povdmm4 impulse 207\n");
	stuffcmd("alias e1m1 impulse 208\n");
	stuffcmd("alias e1m2 impulse 209\n");
	stuffcmd("alias e1m3 impulse 210\n");
	stuffcmd("alias e1m4 impulse 211\n");
	stuffcmd("alias e1m5 impulse 212\n");
	stuffcmd("alias e1m6 impulse 213\n");
	stuffcmd("alias e1m7 impulse 214\n");
	stuffcmd("alias e1m8 impulse 215\n");
	stuffcmd("alias e2m1 impulse 216\n");
	stuffcmd("alias e2m2 impulse 217\n");
	stuffcmd("alias e2m3 impulse 218\n");
	stuffcmd("alias e2m4 impulse 219\n");
	stuffcmd("alias e2m5 impulse 220\n");
	stuffcmd("alias e2m6 impulse 221\n");
	stuffcmd("alias e2m7 impulse 222\n");
	stuffcmd("alias e3m1 impulse 223\n");
	stuffcmd("alias e3m2 impulse 224\n");
	stuffcmd("alias e3m3 impulse 225\n");
	stuffcmd("alias e3m4 impulse 226\n");
	stuffcmd("alias e3m5 impulse 227\n");
	stuffcmd("alias e3m6 impulse 228\n");
	stuffcmd("alias e3m7 impulse 229\n");
	stuffcmd("alias e4m1 impulse 230\n");
	stuffcmd("alias e4m2 impulse 231\n");
	stuffcmd("alias e4m3 impulse 232\n");
	stuffcmd("alias e4m4 impulse 233\n");
	stuffcmd("alias e4m5 impulse 234\n");
	stuffcmd("alias e4m6 impulse 235\n");
	stuffcmd("alias e4m7 impulse 236\n");
	stuffcmd("alias e4m8 impulse 237\n");
	stuffcmd("alias dm1 impulse 238\n");
	stuffcmd("alias dm2 impulse 239\n");
	stuffcmd("alias dm3 impulse 240\n");
	stuffcmd("alias dm4 impulse 241\n");
	stuffcmd("alias dm5 impulse 242\n");
	stuffcmd("alias dm6 impulse 243\n");
	stuffcmd("alias start impulse 244\n");
	stuffcmd("alias end impulse 245\n");
};

// stuff more aliases
void() aliases2 =
{
	msg_entity = self;
	alias("random", IMP_RANDOM);
	alias("msg=", IMP_MSG);
	alias("bots=", IMP_BOTS);
	alias("admin=", IMP_ADMIN);
	alias("skill=", IMP_SKILL);
	alias("skin=", IMP_SKIN);
	alias("shirt=", IMP_SHIRT);
	alias("pants=", IMP_PANTS);
	alias("teamshirt=", IMP_TEAMSHIRT);
	alias("teampants=", IMP_TEAMPANTS);
	alias("name=", 0);
	alias("qwskin=", 0);
	alias("lines=", IMP_LINES);
	alias("addbot", IMP_ADDBOT);
	alias("add2bots", IMP_ADD2BOTS);
	alias("add3bots", IMP_ADD3BOTS);
	alias("add4bots", IMP_ADD4BOTS);
	alias("addbot0", IMP_ADDBOT0);
	alias("addbot1", IMP_ADDBOT1);
	alias("addbot2", IMP_ADDBOT2);
	alias("addbot3", IMP_ADDBOT3);
	alias("addbot4", IMP_ADDBOT4);
	alias("addbot5", IMP_ADDBOT5);
	alias("addbot6", IMP_ADDBOT6);
	alias("addbot7", IMP_ADDBOT7);
	alias("addbot8", IMP_ADDBOT8);
	alias("addbot9", IMP_ADDBOT9);
	alias("addbot10", IMP_ADDBOT10);
	alias("addbot11", IMP_ADDBOT11);
	alias("addbot12", IMP_ADDBOT12);
	alias("addbot13", IMP_ADDBOT13);
	alias("time", IMP_TIME);
	alias("rules", IMP_RULES);
	alias("setskin", IMP_SETSKIN);
	alias("noflash", IMP_FLASH);
};

// 1 second delay between these stuffings
void() aliases3 =
{
	msg_entity = self;
	alias("hide", IMP_HIDE);
	alias("removebot", IMP_REMOVEBOT);
	alias("removeallbots", IMP_REMOVEALLBOTS);
	alias("framerate", IMP_FRAMERATE);
	alias("powerups", IMP_POWERUP);
	alias("rune", IMP_RUNE);
	alias("ready", IMP_READY);
	alias("break", IMP_BREAK);
	alias("overtime", IMP_OVERTIME);
	alias("report", IMP_REPORT);
	alias("autoreport", IMP_AUTOREPORT);
	alias("dropweap", IMP_DROPWEAP);
	alias("autosteams", IMP_AUTOSTEAMS);
	alias("botchat", IMP_BOTCHAT);
	alias("who", IMP_WHO);
	alias("about", IMP_ABOUT);
	alias("scores", IMP_SCORES); 
	alias("match", IMP_MATCH);
	alias("rl_pref", IMP_RL_PREF);
	alias("lg_pref", IMP_LG_PREF);
	alias("rune_rj", IMP_RUNE_RJ);
	alias("lavacheat", IMP_LAVACHEAT);
	alias("noskins_", IMP_NOSKINS);
	alias("drop", IMP_DROP);
	alias("arena", IMP_ARENA);
	alias("damage", IMP_DAMAGE);
	alias("settings", IMP_SETTINGS);
	alias("defaults", IMP_DEFAULTS);
	alias("restart", IMP_RESTART);
	alias("force", IMP_FORCE);
	alias("sounds", IMP_SOUNDS);
	alias("sg", IMP_SG);
	alias("ssg", IMP_SSG);
	alias("ng", IMP_NG);
	alias("sng", IMP_SNG);
	alias("gl", IMP_GL);
	alias("rl", IMP_RL);
	alias("lg", IMP_LG);
};

// last one
void() aliases4 =
{
	msg_entity = self;
	alias("armortype", IMP_ARMORTYPE);
	alias("setdeathmatch", IMP_SET_DEATHMATCH);
	alias("setteamplay", IMP_SET_TEAMPLAY);
	alias("settimelimit", IMP_SET_TIMELIMIT);
	alias("setfraglimit", IMP_SET_FRAGLIMIT);
	alias("setskill", IMP_SET_SKILL);
	alias("setteams", IMP_SET_TEAMS);
	alias("setrounds", IMP_SET_ROUNDS);
	alias("sethealth", IMP_SET_HEALTH);
	alias("setarmor", IMP_SET_ARMOR);
	alias("setshells", IMP_SET_SHELLS);
	alias("setnails", IMP_SET_NAILS);
	alias("setrockets", IMP_SET_ROCKETS);
	alias("setcells", IMP_SET_CELLS);
	alias("notready", IMP_NOTREADY);
	alias("oldteam_blue", IMP_OLDTEAM_BLUE);
	alias("oldteam_red", IMP_OLDTEAM_RED);
	alias("oldteam_yellow", IMP_OLDTEAM_YELLOW);
	alias("oldteam_green", IMP_OLDTEAM_GREEN);
	alias("raspawn", IMP_RA);
	alias("botjump", IMP_BOTJUMP);
	alias("timedown", IMP_TIMEDOWN);
	alias("timeup", IMP_TIMEUP);
	alias("fragsdown", IMP_FRAGSDOWN);
	alias("fragsup", IMP_FRAGSUP);
	alias("skilldown", IMP_SKILLDOWN);
	alias("skillup", IMP_SKILLUP);
	alias("dm", IMP_CHDM);
	alias("tp", IMP_CHTP);
	alias("no_lg", IMP_NO_LG);
	alias("+wp_stats", IMP_WS_ON);
	alias("-wp_stats", IMP_WS_OFF);
	alias("wp_reset", IMP_WS_RES);
	alias("sh_speed", IMP_SH_SPEED);
	alias("join", IMP_JOIN);
	alias("observe", IMP_OBSERVE);
	alias("lock", IMP_LOCK);
	alias("silence", IMP_SILENCE); 
	alias("noclip_", IMP_NOCLIP);
	alias("impulse_0", IMP_IMPULSE_0);
	stuffcmd("alias kfjump \"impulse 140;+jump;wait;-jump\"\n");
	stuffcmd("alias krjump \"impulse 141;+jump;wait;-jump\"\n");
};

// convert float to long
float(float n) utilFloatToLong =
{
	local float pexponent, bitposition, bitnumber, topnumber, result;

	n = fabs(n);

	if(n == 0)
		// 0F == 0L so no need to calculate.
		return 0;

	// work out the pexponent.

	bitposition = 1;
	bitnumber = 1;
	topnumber = 1;

	while(bitposition <= 24)
	{
		if(n & bitnumber)
		{
			pexponent = bitposition;
			topnumber = bitnumber;
		}
		bitposition = bitposition + 1;
		bitnumber = bitnumber * 2;
	}
	// add the bias (127) and drop the topmost bit (subtract 1).
	pexponent = pexponent + 126;
	// convert the float to long

	result = 0;

	// pexponent.
	if(pexponent & BIT_07)
		result = result | BIT_30;
	if(pexponent & BIT_06)
		result = result | BIT_29;
	if(pexponent & BIT_05)
		result = result | BIT_28;
	if(pexponent & BIT_04)
		result = result | BIT_27;
	if(pexponent & BIT_03)
		result = result | BIT_26;
	if(pexponent & BIT_02)
		result = result | BIT_25;
	if(pexponent & BIT_01)
		result = result | BIT_24;
	if(pexponent & BIT_00)
		result = result | BIT_23;
	// mantissa.
	bitnumber = topnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_22;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_21;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_20;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_19;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_18;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_17;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_16;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_15;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_14;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_13;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_12;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_11;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_10;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_09;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_08;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_07;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_06;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_05;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_04;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_03;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_02;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_01;
	bitnumber = bitnumber * 0.5;
	if(n & bitnumber)
		result = result | BIT_00;
	return result;
};

// update frags
void(float to, entity e) UpdateFrags2 =
{
	WriteByte(to, MSG_UPDATEFRAGS);
	WriteByte(to, e.score_pos);
	WriteShort(to, e.frags);
};

// update ping
void(float to, entity e) updateping =
{
	WriteByte(to, SVC_UPDATEPING);
	WriteByte(to, e.score_pos);
	WriteShort(to, e.ping);
};

// update pl
void(float to, entity e) updatepacketloss =
{
	WriteByte(to, SVC_UPDATEPACKETLOSS);
	WriteByte(to, e.score_pos);
	WriteByte(to, e.packetloss);
};

// update entertime
void(float to, entity e) updatetime =
{
	local float entertime_;

	if (e.player)
		return;

	entertime_ = utilFloatToLong(time - e.entertime);

	WriteByte(to, SVC_UPDATETIME);
	WriteByte(to, e.score_pos);
	WriteLong(to, entertime_);
};

// update user info
void(float to, entity e) updateuserinfo =
{
	local float eshirt, epants;
	eshirt = floor(e.color_ / 16);
	epants = e.color_ - (eshirt * 16);
	WriteByte(to, SVC_UPDATEUSERINFO);
	WriteByte(to, e.score_pos);
	WriteLong(to, e.userid);
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
	if (eshirt > 9)
	{
		WriteByte(to, _1);
		WriteByte(to, 38 + eshirt);
	}
	else
		WriteByte(to, _0 + eshirt);
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
	if (epants > 9)
	{
		WriteByte(to, _1);
		WriteByte(to, 38 + epants);
	}
	else
		WriteByte(to, _0 + epants);
	WriteByte(to, 92); // \
	WriteByte(to, _s);
	WriteByte(to, _k);
	WriteByte(to, _i);
	WriteByte(to, _l);
	WriteByte(to, _l);
	WriteByte(to, 92); // \
	if (e.bot_skill == 20)
	{
		WriteByte(to, _2);
		WriteByte(to, _0);
	}
	else
	if (e.bot_skill > 9)
	{
		WriteByte(to, _1);
		WriteByte(to, 38 + e.bot_skill);
	}
	else
		WriteByte(to, _0 + e.bot_skill);
	WriteByte(to, 92); // \
	WriteByte(to, _n);
	WriteByte(to, _a);
	WriteByte(to, _m);
	WriteByte(to, _e);
	WriteByte(to, 92); // \
	WriteString(to, e.netname);
};

// random bot pings & packetloss: every 2 seconds
void() updatebotpings =
{
	if (time < pingupdate) return;
	pingupdate = time + 2;
	self = first_client;
	while(self) {
		if (!self.player) {
			if (!self.ping_) {
				self.ping_ = 113 - (self.bot_skill * 5);
				if (self.ping_ < 50) self.packetloss_ = 0;
				else self.packetloss_ = random() * 6;
			}
			self.ping = floor(self.ping_ + random() * 2);
			self.packetloss = floor(self.packetloss_ * random());
			updateping(MSG_ALL, self);
			updatepacketloss(MSG_ALL, self);
		}
		self = self.next;
	}
};

// add timelimit & fraglimit to PrintRules()
void() a_rulesfix =
{
	sprint_fb(self, 2, "ÙÈÌÂÏÈÌÈÙ... ");
	sprint_ftos(self, 2, timelimit);
	sprint_fb(self, 2, "\nÊÚ·ÁÏÈÌÈÙ... ");
	sprint_ftos(self, 2, fraglimit);
	sprint_fb(self, 2, "\n");
};

// make .bot files with old skill settings still work
void() a_skillfix =
{
	if (impulse_ > MAX_SKILL)
		impulse_ = rint(impulse_ / 10);

};

// make bot stop shooting when no enemy
void() a_attackfix =
{
	if (!self.rocketjumping)
	if (!enemy_)
	if (!(self.state & SHOT_FOR_LUCK))
		self.button0_ = 0; 
};

// timelimit or fraglimit reached, print to qw console
void() print_limit =
{
	local string asdf3;

	if (inter_print)
		return;

	inter_print = 1;

	if (game_arena)
	{
		if (timelimit)
		if (real_time >= timelimit * 60)
		{
			asdf3 = "The match is over\n";
			bprint_fb(2, asdf3);
		}
		if (fraglimit)
		{
			local entity asdf, asdf2;
			asdf = first_client;
			while (asdf)
			{
				if (asdf.frags >= fraglimit)
					asdf2 = asdf;
				asdf = asdf.next;
			}
			if (asdf2)
			{
				asdf3 = " hit the fraglimit\n"; 
				bprint_fb(2, asdf2.netname);
				bprint_fb(2, asdf3);
			}
		}
	}
	else
	{
		if (!game_not_match)
		{ 
			bprint_fb(2, "The match is over\n");
			localcmd("\nsv_spectalk 1\n");
		}
		else
			bprint_fb(2, "The round is over\n");
		if (!break_match)
			FinalStats();
	}
};

// set aliases, update pings, respawn hack, & other stuff 
void() framethink =
{
	check_cvars();

	if (game_arena)
	{
		if (!check_loadingbots)
		{
			check_loadingbots = 1;
			loadingbots = stof(infokey(world, "scratch2"));
		}

		if (arenastate > A_STARTING)
			idleprint_time = 0;

		if (idleprint_time)
		if (time >= idleprint_time)
		{
			idleprint_time = time + 1;
			self = first_client;
			while (self)
			{
				idleprint();
				check_bot_choose_team();
				self = self.next;
			}
		}
	}
	self = first_client;
	while (self)
	{
		if (self.player)
		{
			if (self.printmotd)
			if (time >= self.printmotd)
			{
				self.printmotd = 0;
				selfconnect();
			}
			if (game_arena)
			if (self.scoreboard) 
			if (time >= self.scoreboard)
			{
				self.scoreboard = time + 0.1;
				SetScoreboard2();
			}
		}
		self = self.next;
	}
	updatebotpings();
	if (game_arena)
	if (a_nextthink)
	if (time >= a_nextthink)
	{
		a_nextthink = 0;
		a_think();
	}
	self = first_client;
	while (self)
	{
		track();
		if (self.nextthink2)
		if (time >= self.nextthink2)
		{
			self.nextthink2 = 0;
			self.think2();
		}
		self = self.next;
	}
	if (time < updatestuff)
		return;
	updatestuff = time + 1;
	if (intermission_running)
	{
		print_limit();
		if (!numberofplayers)
		if (time >= intermission_exittime + 5 + random() * 5)
		{
			GotoNextMap();
			return;
		}
	}
	if (!game_arena)
		return;
	if (numberofclients <= 2)
		force_time = 0;
	else if (!arenastate)
	{
		updateteams();
		if (team0.players != 1)
			force_time = 0;
		else
		if (!force_time)
		{
			force_time = time + 20;
			local entity asdf, asdf2;
			asdf = first_client;
			while (asdf)
			{
				if (!asdf.pantscolor)
					asdf2 = asdf;
				asdf = asdf.next;
			}
			asdf = first_client;
			while (asdf)
			{
				if (asdf != asdf2)
				{
					msg_entity = asdf;
					sprint_fb(asdf, 2, asdf2.netname);
					sprint_fb(asdf, 2, " has 20 seconds ready up...\n");
				}
				asdf = asdf.next;
			}
			msg_entity = asdf2;
			sprint_fb(asdf2, 2, "You have 20 seconds to ready up...\n");
		}
		else
		if (force_time < 0)
			force_time = force_time + 1;
	}
	if (arenastate)
		force_time = 0;
	if (force_time > 0)
	if (time >= force_time)
	{
		force_time = 0;
		forcestart();
	}
	self = first_client;
	while (self)
	{
		if (self.player)
		{
			local float topcolor, bottomcolor;
			topcolor = stof(infokey(self, "topcolor"));
			bottomcolor = stof(infokey(self, "bottomcolor"));
			if ((topcolor != self.shirtcolor) || (bottomcolor != self.pantscolor))
			changecolor();
		}
		if (!self.invisible) // hack: if spawned outside map, respawn
		{
			content1 = pointcontents(self.origin);
			if (content1 == CONTENT_SOLID)
				PutClientInServer();
		}
		self = self.next;
	}
};

// everyone has readied up
void() checkifstart =
{
	if (!game_arena)
		return;
	if (arenastate != A_IDLE)
		return;
	updateteams();
	local float teams_;
	local entity asdf;
	asdf = team1;
	while (asdf.teamnumber <= teams)
	{
		if (asdf.players)
			teams_ = teams_ + 1;
		asdf = asdf.next;
	}
	if (!team0.players)
	if (teams_ >= 2)
		startseries();
};

// change color
void() changecolor =
{
	msg_entity = self;
	if (self.player)
	{
		stuffcmd("color ");
		stuffcmd_ftos(self.shirtcolor);
		stuffcmd(" ");
		stuffcmd_ftos(self.pantscolor);
		stuffcmd("\n");
	}
	else
	if (self.frogbot)
	{
		self.color_ = self.shirtcolor * 16 + (self.color_ & 15);
		self.color_ = (self.color_ & 240) + self.pantscolor;
		updateuserinfo(MSG_ALL, self);
	}
	self.realteam = self.pantscolor + 1;
};

// when invisible
void() setinvisitems =
{
	self.items = 
	self.weapon = IT_AXE;
	self.armorvalue = 
	self.ammo_nails = 
	self.ammo_rockets = 
	self.ammo_cells = 
	self.armortype =
	self.ammo_shells =
	self.currentammo = 0;
	self.health = 100;
	self.weaponmodel = "";
};

// if return TRUE, skip T_Damage
float() T_Damage2 =
{
	if (game_arena)
	if (arenastate != A_PLAYING)
		return 1;
	if (game_damage)
	{
		if (deathtype == "falling")
			damage = 0;
		if (!deathtype)
		if (self.watertype == -3)
			damage = 0;
	}
	if (damage)
		last_action_time = time;
	if (!game_damage)
		return 0;
	if (pre_game)
	if (!game_arena)
		return 0;
	if (attacker == targ)
		return 0;
	if (!attacker.client_)
		return 0;
	if (!targ.client_)
		return 0;
	if (attacker.realteam == targ.realteam)
		return 0;
	local float asdf, asdf2;
	asdf = targ.health + targ.armorvalue;
	asdf2 = targ.health / (1 - targ.armortype);
	if (asdf2 < asdf)
		asdf = asdf2;
	if (damage < asdf)
		asdf = damage;
	asdf = ceil(asdf);
	attacker.damfrags = attacker.damfrags + asdf;
	asdf2 = 0;
	while (attacker.damfrags >= 100)
	{
		asdf2 = 1;
		attacker.damfrags = attacker.damfrags - 100;
		attacker.frags = attacker.frags + 1;
	}
	if (asdf2)
		UpdateFrags(attacker);
	return 0;
};

// update # of players on each team
void() updateteams =
{
	local entity asdf, asdf2;
	team0.players = 0;
	asdf = team1;
	while (asdf.teamnumber <= teams)
	{
		asdf.players = 0;
		asdf = asdf.next;
	}
	asdf2 = first_client;
	while (asdf2)
	{
		if (asdf2.pantscolor == 0)
			team0.players = team0.players + 1;
		asdf = team1;
		while (asdf.teamnumber <= teams)
		{
			if (asdf2.pantscolor == asdf.pantscolor)
				asdf.players = asdf.players + 1;
			asdf = asdf.next;
		}
		asdf2 = asdf2.next;
	}
};

// set deathmatch and teamplay
void() setdmtp =
{
	if (game_arena)
	{
		deathmatch = 6;
		teamplay = 5;
		return;
	}
	deathmatch = cvar("deathmatch");
	teamplay = cvar("teamplay");


};

// print setting?
void(string a, float b) print_setting =
{
	sprint_fb(self, 2, a);
	sprint_ftos(self, 2, b);
	sprint_fb(self, 2, "\n");
};

// boolean setting
void(string a, float b) print_setting_b =
{
	sprint_fb(self, 2, a);
	if (b)
		sprint_fb(self, 2, "enabled\n");
	else
		sprint_fb(self, 2, "disabled\n");
};

// print current arena settings
void() settings =
{
	sprint_fb(self, 2, "\nCurrent settings:\n");
	print_setting("teams       ", teams);
	print_setting("rounds      ", rounds);
	print_setting("health      ", a_health);
	print_setting("armor       ", a_armorvalue);
	print_setting("shells      ", a_ammo_shells);
	print_setting("nails       ", a_ammo_nails);
	print_setting("rockets     ", a_ammo_rockets);
	print_setting("cells       ", a_ammo_cells);
	print_setting_b("sg          ", a_items & IT_SHOTGUN);
	print_setting_b("ssg         ", a_items & IT_SUPER_SHOTGUN);
	print_setting_b("ng          ", a_items & IT_NAILGUN);
	print_setting_b("sng         ", a_items & IT_SUPER_NAILGUN);
	print_setting_b("gl          ", a_items & IT_GRENADE_LAUNCHER);
	print_setting_b("rl          ", a_items & IT_ROCKET_LAUNCHER);
	print_setting_b("lg          ", a_items & IT_LIGHTNING);
	local string armortype_;
	if (a_armortype == 0.3)
		armortype_ = "green";
	else
	if (a_armortype == 0.6)
		armortype_ = "yellow";
	else
	if (a_armortype == 0.8)
		armortype_ = "red";
	sprint_fb(self, 2, "armortype   ");
	sprint_fb(self, 2, armortype_);
	sprint_fb(self, 2, "\n");
};

// set defaults
void() defaults =
{
	a_health = 100;
	a_armortype = 0.8;
	a_armorvalue = 200;
	a_ammo_shells =
	a_ammo_nails = 250;
	a_ammo_rockets = 200;
	a_ammo_cells = 200;
	a_items =
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_LIGHTNING |
		IT_ARMOR3;
};

// when first load map
void() initialize =
{
	setdmtp();
	if (initialized)
		return;
	initialized = 1;
	rounds = 5;
	teams = 2;
	team0 = spawn();
	team1 = spawn();
	team2 = spawn();
	team3 = spawn();
	team4 = spawn();
	team0.next = team1;
	team0.classname = "êÓÔÓÂë"; // none
	team0.pantscolor = 0;
	team0.teamnumber = 5;
	team0.shirt1 =
	team0.shirt2 =
	team0.shirt3 = 0;
	team1.next = team2;
	team1.classname = "ê‚ÏıÂë"; // blue
	team1.pantscolor = 13;
	team1.teamnumber = 1;
	team1.shirt1 = 13;
	team1.shirt2 = 2;
	team1.shirt3 = 11;
	team2.next = team3;
	team2.classname = "êÚÂ‰ë"; // red
	team2.pantscolor = 4;
	team2.teamnumber = 2;
	team2.shirt1 = 4;
	team2.shirt2 = 6;
	team2.shirt3 = 7;
	team3.next = team4;
	team3.classname = "ê˘ÂÏÏÔ˜ë"; // yellow
	team3.pantscolor = 12;
	team3.teamnumber = 3;
	team3.shirt1 = 12;
	team3.shirt2 = 5;
	team3.shirt3 = 10;
	team4.next = team0;
	team4.classname = "êÁÚÂÂÓë"; // green
	team4.pantscolor = 3;
	team4.teamnumber = 4;
	team4.shirt1 = 3;
	team4.shirt2 = 8;
	team4.shirt3 = 9;
	updateteams();
	a_sounds = 2;
	arenastate = 0;
	idleprint_time = 1;
	defaults();
};

// find lowest available userid
float() lowest_userid =
{
	local float checknext, lowest;
	local entity asdf;
	do
	{
		lowest = lowest + 1;
		checknext = 0;
		asdf = first_client;
		while (asdf)
		{
			if (asdf.userid == lowest)
				checknext = 1;
			asdf = asdf.next;
		}
	} while (checknext);
	return lowest;
};

// change any bot's userid conflicting with self
void() bumpfrogbot =
{
	users = stof(infokey(world, "users"));
	self.userid = stof(infokey(world, self.netname));
	if (!self.userid)
	{
		users = users + 1;
		localcmd("localinfo users ");
		localcmd_ftos(users);
		localcmd("\n");
		self.userid = users;
		localcmd("localinfo ");
		localcmd(self.netname);
		localcmd(" ");
		localcmd_ftos(self.userid);
		localcmd("\n");
	}
	local entity asdf;
	asdf = first_client;
	while (asdf)
	{
		if (!asdf.player)
		if (asdf.userid == self.userid)
		{
			asdf.userid = lowest_userid();
			updateuserinfo(MSG_ALL, asdf);
		}
		asdf = asdf.next;
	}
};

// load scoreboard 1 bot at a time
void() SetScoreboard2 =
{
	if (!updatebot)
		updatebot = first_client;
	local float asdf;
	while (asdf < 2)
	{
		asdf = asdf + 1;
		if (updatebot.frogbot)
		{
			msg_entity = self;
			UpdateFrags2(MSG_ONE, updatebot);
			updatetime(MSG_ONE, updatebot);
			updateuserinfo(MSG_ONE, updatebot);
		}
		if (updatebot)
			updatebot = updatebot.next;
		else
		{
			self.scoreboard = 0;
			return;
		}
	}
};

// called in ClientConnect or something
void() selfconnect =
{
	if (!self.player)
	return;
	bumpfrogbot();
	stuffcmd("alias aliases impulse ");
	stuffcmd_ftos(IMP_ALIASES);
	stuffcmd("\nalias commands impulse ");
	stuffcmd_ftos(IMP_COMMANDS);
	stuffcmd("\n");
};

// self just disconnected
void() selfdisconnect =
{
	self.connected =
	self.shirtcolor = 
	self.pantscolor = 
	self.shirtcolor_ = 
	self.pantscolor_ = 
	self.nextthink2 =
	self.botpantscolor = 0;
	checkifstart();
	if (!self.player)
	{
			self.ping =
			self.ping_ = 0;
			dprint(self.netname);
			dprint(" removed\n");
	}
	else
	{
			localcmd("localinfo ");
			localcmd(self.netname);
			localcmd(" 0\n");
	}
};

// called in PlayerDie, print attacker's stats
void() selfdie =
{
/*
	dprint_obituary();
*/
	if (!game_arena)
		return;
	self.shirtcolor = self.pantscolor = 0;
	changecolor();
	local entity asdf;
	checkifteamwon();
	if (attacker.client_)
		asdf = attacker;
	else
	if (attacker.owner.client_)
		asdf = attacker.owner;
	else
		asdf = world;
	if (!asdf.client_)
		return;
	sprint_fb(self, 2, asdf.netname);
	sprint_fb(self, 2, " had Armor: ");
	sprint_g(self, 2, asdf.armorvalue);
	sprint_fb(self, 2, " Health: ");
	sprint_g(self, 2, asdf.health);
	sprint_fb(self, 2, "\n");
};

// change player shirt color according to impulse
void() choose_shirt =
{
	if (!game_arena)
		return;
	if (arenastate > A_STARTING)
		return;
	if (self.player)
	if (self.frogbot)
	if (!self.botchose)
		return;
	if (impulse_ == 5)
		notready();
	if (impulse_ > 3)
		return;
	local entity asdf;
	local float asdf2;
	asdf = team1;
	while (asdf.teamnumber <= teams)
	{
		if (self.pantscolor == asdf.pantscolor)
		{
			if (impulse_ == 1)
				asdf2 = asdf.shirt1;
			else
			if (impulse_ == 2)
				asdf2 = asdf.shirt2;
			else
			if (impulse_ == 3)
				asdf2 = asdf.shirt3;
			self.shirtcolor = self.shirtcolor_ = asdf2;
		}

	asdf = asdf.next;
	}
	changecolor();
};

// add player to corrosponding team
void() choose_team =
{
	if (!game_arena)
		return;
	if (arenastate > A_STARTING)
		return;
	if (self.player)
	if (self.frogbot)
	if (!self.botchose)
		return;
	if (self.pantscolor_)
		return;
	if (impulse_ > teams)
		return;
	local entity asdf, asdf2;
	asdf = team1;
	while (asdf.teamnumber <= teams)
	{
		if (impulse_ == asdf.teamnumber)
			asdf2 = asdf;
		asdf = asdf.next;
	}
	if (!asdf2)
		return;
	self.shirtcolor =
	self.pantscolor = asdf2.pantscolor;
	changecolor();
	addtoteam(asdf2);
};

// seconds before match begins
void(float seconds_) timesound =
{
	if (!a_sounds)
		return;
	local string timesound_;
	local float channel;
	channel = CHAN_AUTO + CHAN_NO_PHS_ADD;
	if (a_sounds == 2)
	{
		if (seconds_== 0) timesound_ = "sffight.wav";
		else if (seconds_ == 1) timesound_ = "sf1.wav";
		else if (seconds_ == 2) timesound_ = "sf2.wav";
		else if (seconds_ == 3) timesound_ = "sf3.wav";
		else if (seconds_ == 4) timesound_ = "sf4.wav";
		else if (seconds_ == 5) timesound_ = "sf5.wav";
		sound(channel, timesound_, 1, ATTN_NONE);
	}
	else
	if (a_sounds == 1)
	if (seconds_ <= 3)
	{
		if (seconds_== 0) timesound_ = "ra/fight.wav";
		else if (seconds_ == 1) timesound_ = "ra/1.wav";
		else if (seconds_ == 2) timesound_ = "ra/2.wav";
		else if (seconds_ == 3) timesound_ = "ra/3.wav";
		sound(channel, timesound_, 1, ATTN_NONE);
	}
};

// precaches
void() a_precache =
{
	precache_model ("progs/quaddama.mdl");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");
	precache_model("maps/b_bh100.bsp");
	precache_sound("items/r_item2.wav");
	precache_model("maps/b_bh10.bsp");
	precache_sound("items/r_item1.wav");

	precache_model("maps/b_bh25.bsp");
	precache_sound("items/health1.wav");
	precache_model ("progs/armor.mdl");
	precache_model ("progs/g_shot.mdl");
	precache_model ("progs/g_nail.mdl");
	precache_model ("progs/g_nail2.mdl");
	precache_model ("progs/g_rock.mdl");
	precache_model ("progs/g_rock2.mdl");
	precache_model ("progs/g_light.mdl");
	precache_model ("maps/b_shell1.bsp");
	precache_model ("maps/b_shell0.bsp");
	precache_model ("maps/b_nail1.bsp");
	precache_model ("maps/b_nail0.bsp");
	precache_model ("maps/b_rock1.bsp");
	precache_model ("maps/b_rock0.bsp");
	precache_model ("maps/b_batt1.bsp");
	precache_model ("maps/b_batt0.bsp");
	precache_model ("progs/invulner.mdl");
	precache_model ("progs/suit.mdl");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	precache_model ("progs/invisibl.mdl");
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");

	precache_model ("progs/end1.mdl");
	precache_model ("progs/end2.mdl");
	precache_model ("progs/end3.mdl");
	precache_model ("progs/end4.mdl");

	precache_sound ("ra/3.wav");
	precache_sound ("ra/2.wav");
	precache_sound ("ra/1.wav");
	precache_sound ("ra/fight.wav");
	precache_sound ("sf1.wav");
	precache_sound ("sf2.wav");
	precache_sound ("sf3.wav");
	precache_sound ("sf4.wav");
	precache_sound ("sf5.wav");
	precache_sound ("sf6.wav");
	precache_sound ("sf7.wav");
	precache_sound ("sf8.wav");
	precache_sound ("sf9.wav");
	precache_sound ("sffight.wav");
	precache_sound ("sfround.wav");
};

// called in SetGame()
void() a_gamemode =
{
	game_arena = gamemode & GAME_ARENA;
	game_damage = gamemode & GAME_DAMAGE;
	game_raspawn = gamemode & GAME_RASPAWN;
	game_botjump = gamemode & GAME_BOTJUMP;
	game_drop = gamemode & GAME_DROP;
};

// called in PrintRules()
void() a_boolean =
{
	print_boolean(GAME_ARENA, "·ÚÂÓ·....... ");
	print_boolean(GAME_DAMAGE, "‰·Ì·ÁÂ...... ");
	print_boolean(GAME_RASPAWN, "Ú·Û·˜Ó..... ");
	print_boolean(GAME_BOTJUMP, "‚ÔÙÍıÌ..... ");
	print_boolean(GAME_DROP, "‰ÚÔ........ ");
};

// more ImpulseCommands, woo!
void() a_impulses =
{
	if (impulse_ == IMP_ARENA)
		ToggleGameMode(GAME_ARENA, "arena");
	else if (impulse_ == IMP_DAMAGE)
		ToggleGameMode(GAME_DAMAGE, "damage frags");
	else if (impulse_ == IMP_RA)
		ToggleGameMode(GAME_RASPAWN, "ra spawning");
	else if (impulse_ == IMP_BOTJUMP)
		ToggleGameModeNow(GAME_BOTJUMP, "botjump");
	else if (impulse_ == IMP_DROP)
		ToggleGameMode(GAME_DROP, "drop powerups");
	else if (impulse_ == IMP_NOCLIP)
		togglenoclip();
	else if (impulse_ == IMP_COMMANDS)
		commands();
	else if (impulse_ == IMP_RESTART)
		changelevel(nextmap);
	else if (impulse_ == IMP_REPORT)
		teamreport(self);
	else if (impulse_ == IMP_ALIASES)
	{
			sprint_fb(self, 2, "Stuffing aliases, please wait 4 seconds.\n");
			self.alias1time = time + 1;
			self.alias2time = time + 2;
			self.alias3time = time + 3;
			self.alias4time = time + 4;
	}
	local float asdf;
	asdf = scratch1();
	if (impulse_ == IMP_SET_DEATHMATCH)
		cvar_set_("deathmatch", asdf);
	else if (impulse_ == IMP_SET_TEAMPLAY)
		cvar_set_("teamplay", asdf);
	else if (impulse_ == IMP_SET_TIMELIMIT)
		cvar_set_("timelimit", asdf);
	else if (impulse_ == IMP_SET_FRAGLIMIT)
		cvar_set_("fraglimit", asdf);
	else if (impulse_ == IMP_SET_SKILL)
		set_skill();
	else if (impulse_ == 150)
		power_();
	if (!game_arena)
		return;
	else if (impulse_ == IMP_SET_TEAMS)
		set_teams();
	else if (impulse_ == IMP_SET_ROUNDS)
		set_rounds();
	else if (impulse_ == IMP_SET_ARMOR)
		set_armorvalue();
	else if (impulse_ == IMP_SET_HEALTH)
		set_health();
	else if (impulse_ == IMP_SET_SHELLS)
		set_shells();
	else if (impulse_ == IMP_SET_NAILS)

		set_nails();
	else if (impulse_ == IMP_SET_ROCKETS)
		set_rockets();
	else if (impulse_ == IMP_SET_CELLS)
		set_cells();
	if (impulse_ == IMP_NOTREADY)
		notready();
	else if (impulse_ == IMP_FORCE)
		forcestart();
	else if (impulse_ == IMP_SOUNDS)
		changesounds();
	else if (impulse_ == IMP_ARMORTYPE)
		changearmortype();
	else if (impulse_ == IMP_SG)
		toggleweapon(IT_SHOTGUN, "shotgun");
	else if (impulse_ == IMP_SSG)
		toggleweapon(IT_SUPER_SHOTGUN, "super shotgun");
	else if (impulse_ == IMP_NG)
		toggleweapon(IT_NAILGUN, "nailgun");
	else if (impulse_ == IMP_SNG)
		toggleweapon(IT_SUPER_NAILGUN, "super nailgun");
	else if (impulse_ == IMP_GL)
		toggleweapon(IT_GRENADE_LAUNCHER, "grenade launcher");
	else if (impulse_ == IMP_RL)
		toggleweapon(IT_ROCKET_LAUNCHER, "rocket launcher");
	else if (impulse_ == IMP_LG)
		toggleweapon(IT_LIGHTNING, "lightning gun");
	else if (impulse_ == IMP_OLDTEAM_BLUE)
		addtoteam(team1);
	else if (impulse_ == IMP_OLDTEAM_RED)
		addtoteam(team2);
	else if (impulse_ == IMP_OLDTEAM_YELLOW)
		addtoteam(team3);
	else if (impulse_ == IMP_OLDTEAM_GREEN)
		addtoteam(team4);
	else if (impulse_ == IMP_SETTINGS)
		settings();
	else if (impulse_ == IMP_DEFAULTS)
	{
		bprint_fb(2, "Defaults set\n");
		defaults();
	}
};

// deathmatch or rocket arena spawns
void() set_a_spawn =
{
	a_spawn = "info_player_deathmatch";
	if (!game_raspawn)
		return;
	if (game_arena)
	if (self.invisible)
		return;
	a_spawn = "info_teleport_destination";
};

// PutClientInServer(), check if should becomeinvisible
float() putselfinserver =
{
	if (!self.connected)
	{
		self.connected = 1;
		if (!self.player)
		{
			self.aggressive = rint(random());
			UpdateFrags2(MSG_ALL, self);
/*
				self.entertime = time;
				updatetime(MSG_ALL, self);
				self.userid = lowest_userid();
				updateuserinfo(MSG_ALL, self);
				bot_netname();
				dprint(self.netname);
				dprint(" added\n");
*/
			if (game_arena)
				self.botpantscolor = self.team - 1;
		}
		else
		{
			self.printmotd = time + 0.1;
			self.scoreboard = time + 1.5;
		}
	}
	if (!game_arena)
		return 0;
	self.invisible = 0;
	if (self.pantscolor)
		return 0;
	if (!self.pantscolor_)
	{
		self.shirtcolor_ = 
		self.shirtcolor = 
		self.pantscolor = 0;
		changecolor();
	}
	becomeinvisible();
	return 1;
};

// W_BestWeapon() for arena
float() best_rl =
{
	if (game_arena)
	if (items_ & IT_ROCKET_LAUNCHER)
	if (self.ammo_rockets >= 1)
		return 1;
	return 0;
};

// same as above
float() best_gl =
{
	if (game_arena)
	if (items_ & IT_GRENADE_LAUNCHER)
	if (self.ammo_rockets >= 1)
		return 1;
	return 0;
};

// check if should do invisible prethink
float() a_prethink =
{
	if (!game_arena)
		return 0;
	if (intermission_running)
		return 0;
	if (!self.invisible)
		return 0;
	if (self.health <= 0)
		return 0;
	if (self.frogbot)
	{
		self.angles = self.oldangles;
		self.oldvelocity =
		self.velocity = '0 0 0';
		self.fixangle = TRUE;
		return 1;
	}
	if (self.waterlevel)
	{
		if (!(self.player))
		if (self.waterlevel == 2)

	{
			BotWaterJumpFix();
			makevectors (self.v_angle);
			start = self.origin;
			start_z = start_z + 8; 
			v_forward_z = 0;
			v_forward = normalize(v_forward) * 24;
			end = start + v_forward;
			traceline (start, end, TRUE, self);
			if (trace_fraction < 1)
			{
				start_z = self.origin_z + self.maxs_z;
				end = start + v_forward;
				self.movedir = trace_plane_normal * -50;
				traceline (start, end, TRUE, self);
				if (trace_fraction == 1)
				{
					self.flags = (self.flags | FL_WATERJUMP) & FL_NOT_JUMPRELEASED;
					self.velocity_z = 225;
					self.teleport_time = time + 2;
				}
			}
		}
		if (!(self.player))
		if (!(self.flags & FL_WATERJUMP))
			self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
	}
	if (self.button2)
	{
		if (!(self.flags & FL_WATERJUMP))
		{
			if (self.waterlevel >= 2)
			{
				if (!(self.player))
				{
				if (self.watertype == CONTENT_WATER)
					self.velocity_z = 100;
				else if (self.watertype == CONTENT_SLIME)
					self.velocity_z = 80;
				else
					self.velocity_z = 50;
				}
			}
			else
			{
				if (self.flags & FL_ONGROUND)
				{
					if (self.flags & FL_JUMPRELEASED)
					{
						a_jumpfix();
						self.flags = self.flags - FL_JUMPRELEASED;
						if (!(self.player))
						self.flags = self.flags - FL_ONGROUND;
						self.button2 = 0;
						if (!(self.player))
						self.velocity_z = self.velocity_z + JUMPSPEED;
					}
				}
			}
		}
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;
	self.oldvelocity = self.velocity;
	self.touch_distance = 1000000;
	return 1;
};

// check if should do invisible postthink
float() a_postthink =
{
	if (!game_arena)
		return 0;
	if (intermission_running)
		return 0;
	if (!self.invisible)
		return 0;
	if (self.health <= 0)
		return 0;
	if (arenastate <= A_STARTING)
	if (self.impulse)
	if (!self.spawnflags)

	{
		impulse_ = self.impulse;
		self.impulse = 0;
		if (!self.pantscolor_)
			choose_team();
		else
			choose_shirt();
		self.botchose = 0;
	}
	if (!self.player)
		return 1;
	if (!self.button0_)
		self.a_button0 = 1;
	if (!self.button2_)
		self.a_button2 = 1;
	if (self.button0_)
	if (self.a_button0)
	{
		self.a_button0 = 0;
		track_toggle();
	}
	if (self.button2_)
	if (self.a_button2)
	{
		self.a_button2 = 0;
		track_next();
	}
	return 1;
};

// make bots either aggressive or defensive
void() a_goal_client6 =
{
	updateteams();
	local entity asdf;
	local float asdf2;
	if (time > last_action_time + 10)
	{
		asdf = first_client;
		while (asdf)
		{
			if (!asdf.player)
			if (!asdf.invisible)
			if (!asdf.deadflag)
			if (asdf.aggressive)
				asdf2 = 1;
			asdf = asdf.next;
		}
		if (!asdf2) // nobody aggressive, make a random one so
		{
			local float asdf3, asdf4;
			asdf3 = floor(random() * players_());
			asdf = first_client;
			while (asdf)
			{
				if (!asdf.player)
				if (!asdf.invisible)
				if (!asdf.deadflag)
				{
					if (asdf4 == asdf3)
						asdf.aggressive = 1;
					asdf4 = asdf4 + 1;
				}
				asdf = asdf.next;
			}
		}
	}
	asdf2 = 0;
	asdf = team1;
	while (asdf.teamnumber <= teams)
	{
		if (asdf.players == 1)
			asdf2 = 1;
		asdf = asdf.next;
	}
	if (arenastate != A_PLAYING)
		enemy_desire = 0;
	else
	if (asdf2)
		enemy_desire = 200;
	else
	if (self.aggressive)
		enemy_desire = 100;
	else
		enemy_desire = 0;
};

// check if should set arena or deathmatch items
float() a_newitems =
{
	if (game_arena)
	{
		self.health = a_health;
		self.armorvalue = a_armorvalue;
		self.armortype = a_armortype;
		self.ammo_shells = a_ammo_shells;
		self.ammo_nails = a_ammo_nails;
		self.ammo_rockets = a_ammo_rockets;
		self.ammo_cells = a_ammo_cells;
		self.items = a_items;
		self.weapon = W_BestWeapon();
		return 1;
	}
	return 0;
};

// enable track mode
void() track_on =
{
	self.tracking = 1;
	self.gravity = 0;
	track_next();
	sprint_fb(self, 2, "Entering track mode...\n");
	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;		
};

// disable track mode
void() track_off =
{
	self.tracking = 0;
	self.gravity = 1;
	self.chasing = world;
	sprint_fb(self, 2, "Leaving track mode...\n");
	centerprint(self, "\n");
	becomeinvisible();
};

void() track_print =
{
	if (self.chasing.client_)
	{
		local string s1, s2, s3, s4, s5;
		s1 = "\n\n\n\n\n\n\n\n\n\n\n";
		s2 = "Tracking: ";
		s3 = self.chasing.netname;
		s4 = "\n";
		s5 = "Press jump for next";
		centerprint5(self, s1, s2, s3, s4, s5);
	}
};

// track next player
void() track_next = 
{
	if (!self.tracking)
		return;
	if (!self.chasing)
		self.chasing = first_client;
	else
		self.chasing = self.chasing.next;
	if (self.chasing.invisible)
		track_next();
	else
	if (self.chasing.health <= 0)
		track_next();
	else
		track_print();
};

// number of players still active
float() players_ =
{
	local entity asdf;
	local float asdf2;
	asdf = first_client;
	while (asdf)
	{
		if (!asdf.invisible)
		if (asdf.health > 0)
			asdf2 = asdf2 + 1;
		asdf = asdf.next;
	}
	return asdf2;
};

// toggle trackcam
void() track_toggle =
{
	if (arenastate == A_POSTROUND)
		return;
	if (!self.invisible)
		return;
	if (self.health <= 0)
		return;
	if (!players_())
		return;
	if (self.tracking)
		track_off();
	else
		track_on();
};

// track think function
void() track =
{
	if (!self.tracking)
		return;
	if (arenastate == A_POSTROUND)
	{
		track_off();
		return;
	}
	if ((self.chasing.invisible)
	|| (self.chasing.health <= 0)
	|| (!self.chasing.client_))
	{
		if (players_())
			track_next();
		else
			track_off();
		return;
	}
	local vector org, dir;
	local float pdistance;
	org = self.chasing.origin;
	makevectors(self.chasing.v_angle);
	traceline(org, org - v_forward * 140, FALSE, self.chasing);
	org = trace_endpos + v_forward * 40;
	pdistance = vlen(org - self.origin);
	dir = normalize(org - self.origin);
	self.velocity = dir * distance * 4;
	self.origin = org;
	self.weaponmodel = "";
	self.view_ofs_z = 0;
	setorigin(self, self.origin);
	self.oldorigin = self.origin;
/*
	self.chasing.v_angle = self.v_angle;
	self.chasing.real_pitch = self.angles_x;
	self.chasing.real_yaw = self.angles_y;
	self.chasing.angles = self.angles;
	self.chasing.fixangle = TRUE;
*/
	self.angles = self.chasing.angles;
	self.angles_z = 0;
	self.angles_x = self.angles_x * -3;
	self.mangle = '0 0 0';
	self.fixangle = TRUE;


	self.health = self.chasing.health;
	self.armortype = self.chasing.armortype;
	self.armorvalue = self.chasing.armorvalue;
	self.items = self.chasing.items;
	self.weapon = self.chasing.weapon;
	self.currentammo = self.chasing.currentammo;
	self.ammo_shells = self.chasing.ammo_shells;
	self.ammo_nails = self.chasing.ammo_nails;
	self.ammo_rockets = self.chasing.ammo_rockets;
	self.ammo_cells = self.chasing.ammo_cells;
	self.frame = 0;
	if (time < self.trackprint_time)
		return;
	self.trackprint_time = time + 1;
	track_print();
};

// returns scratch1 cvar/setinfo settings
float() scratch1 =
{
	local float amount;
	amount = stof(infokey(self, "scratch1"));
	return amount;
};

// add bot to team
void(entity newteam) addtoteam =
{
	if (!game_arena)
		return;
	if (self.pantscolor_)
		return;
	if (newteam == team3)
	if (teams < 3)
		return;
	if (newteam == team4)
	if (teams < 4)
		return;
	self.pantscolor_ = 
	self.shirtcolor_ = newteam.pantscolor;
	bprint_fb(2, self.netname);
	bprint_fb(2, " has been added to team ");
	bprint_fb(2, newteam.classname);
	bprint_fb(2, "\n");
	checkifstart();
};

// remove self from team
void() notready =
{
	if (!game_arena)
		return;
	if (!self.pantscolor_)
		return;
	local entity asdf, asdf2;
	asdf = team1;
	while (asdf.teamnumber <= teams)
	{
		if (self.pantscolor_ == asdf.pantscolor)
			asdf2 = asdf;
		asdf = asdf.next;
	}
	bprint_fb(2, self.netname);
	bprint_fb(2, " has been removed from team ");
	bprint_fb(2, asdf2.classname);
	bprint_fb(2, "\n");
	self.pantscolor = 
	self.shirtcolor = 
	self.shirtcolor_ =
	self.pantscolor_ = 0;
	if (self.frags)
	{
		self.frags = 0;
		UpdateFrags(self);
	}
	changecolor();
	becomeinvisible();
	checkifteamwon();
};

float() a_item =
{
	if ((((deathmatch == 6) 
	|| (deathmatch == 2)) 
	&& ((self.touch == health_touch) 
	|| (self.touch == armor_touch)))
	|| ((deathmatch > 3) 
	&& (self.touch == weapon_touch))
	|| (((deathmatch == 2) 
	|| (deathmatch == 4) 
	|| (deathmatch == 6))
	&& (self.touch == ammo_touch))
	|| ((game_disable_powerups) 
	&& (self.touch == powerup_touch)))
	{
		self.model = "";
		self.think =

	self.touch = null;
		self.desire = goal_NULL;
	}
	else
		self.think = SUB_regen;
	if (pre_game)
		self.nextthink = -1;
	else
		self.nextthink = 0;
	if (!self.desire)
		self.desire = goal_NULL; // safety
	if (self.itemstarted)
		return 1;
	self.itemstarted = 1;
	return 0;
};

// force series to begin
void() forcestart =
{
	if (!game_arena)
		return;
	if (arenastate > A_STARTING)
		return;
	bprint_fb(2, "Forcing series to start...\n");
	arenastate = A_STARTING;
	round = 0;
	a_think = bluevsred;
	a_nextthink = time + 1;
};

// mortal kombat, street fighter, or no sounds
void() changesounds =
{
	if (!game_arena)
		return;
	a_sounds = a_sounds + 1;
	if (a_sounds > 2)
		a_sounds = 0;
	if (!a_sounds)
		bprint_fb(2, "No sound\n");
	else
	if (a_sounds == 1)
		bprint_fb(2, "Mortal Kombat sounds\n");
	else
	if (a_sounds == 2)
		bprint_fb(2, "Street Fighter sounds\n");
};

// enable/disable weapon
void(float which, string wname) toggleweapon =
{
	if (!game_arena)
		return;
	bprint_fb(2, self.netname);
	bprint_fb(2, " has ");
	if (a_items & which)
	{
		bprint_fb(2, "‰ÈÛ·‚ÏÂ‰");
		a_items = a_items - which;
	}
	else
	{
		bprint_fb(2, "ÂÓ·‚ÏÂ‰");
		a_items = a_items | which;
	}
	bprint_fb(2, " the ");
	bprint_fb(2, wname);
	bprint_fb(2, "\n");
};

// green, yellow, or red armor
void() changearmortype =
{
	if (!game_arena)
		return;
	local string armortype_;
	if (a_armortype == 0.3)
	{
		armortype_ = "yellow";
		a_armortype = 0.6;

		a_items = (a_items | IT_ARMOR2) - IT_ARMOR1;
	}
	else
	if (a_armortype == 0.6)
	{
		armortype_ = "red";
		a_armortype = 0.8;
		a_items = (a_items | IT_ARMOR3) - IT_ARMOR2;
	}
	else
	if (a_armortype == 0.8)
	{
		armortype_ = "green";
		a_armortype = 0.3;
		a_items = (a_items | IT_ARMOR1) - IT_ARMOR3;
	}
	bprint_fb(2, "\"armortype\" changed to \"");
	bprint_fb(2, armortype_);
	bprint_fb(2, "\"\n");
};

// toggle noclip mode for editing; remove later!
void() togglenoclip =
{
	msg_entity = self;
	if (self.movetype == MOVETYPE_NOCLIP)
	{
		self.movetype = MOVETYPE_WALK;
		sprint_fb(self, 2, "Noclip OFF\n");
	}
	else
	{
		self.movetype = MOVETYPE_NOCLIP;
		sprint_fb(self, 2, "Noclip ON\n");
	}
};

// match begins
void() fight = 
{
	a_think = null;
	a_nextthink = 0;
	if (arenastate != A_PREROUND)
		return;
	arenastate = A_PLAYING;
	timesound(0);
	bprint_fb(2, "‘ËÂ Ì·Ù„Ë Ë·Û ‚ÂÁıÓ°\n");
	centerprint_players("∆…«»‘°\n");
};
	
// 1 second to start
void() print1 =
{
	if (arenastate != A_PREROUND)
		return;
	msg_level = PRINT_HIGH;
	timesound(1);
	centerprint_players("\n");
	a_think = fight;
	a_nextthink = time + 1;
};

// 2 seconds...
void() print2 =
{
	if (arenastate != A_PREROUND)
		return;
	msg_level = PRINT_HIGH;
	timesound(2);
	centerprint_players("\n");
	a_think = print1;
	a_nextthink = time + 1;
};

// 3...
void() print3 =
{
	if (arenastate != A_PREROUND)
		return;
	msg_level = PRINT_HIGH;
	timesound(3);
	centerprint_players("\n");
	a_think = print2;
	a_nextthink = time + 1;
};

// 4...
void() print4 =
{
	if (arenastate != A_PREROUND)
		return;
	msg_level = PRINT_HIGH;
	timesound(4);
	centerprint_players("\n");
	a_think = print3;
	a_nextthink = time + 1;
};

// 5...
void() print5 =
{
	if (arenastate != A_PREROUND)
		return;
	msg_level = PRINT_HIGH;
	timesound(5);
	centerprint_players("\n");
	a_think = print4;
	a_nextthink = time + 1;
};

// who vs. who, match starts in 5 seconds
void() fiveseconds =
{
	if (arenastate != A_PREROUND)
		return;
	sound(CHAN_NO_PHS_ADD, "misc/talk.wav", 1, ATTN_NONE);
	updateteams();
	local entity asdf, asdf2;
	local float number, number_;
	asdf2 = team1;
	while (asdf2.teamnumber <= teams)
	{
		if (teams >= asdf2.teamnumber)
		if (asdf2.players)
		{
			if (number_)
			bprint_fb(2, " vs. ");
			number_ = 1;
			number = 0;
			asdf = first_client;
			while (asdf)
			{
				if (asdf.pantscolor == asdf2.pantscolor)
				{
					if (number)
						bprint_fb(2, ", ");
					number = 1;
					bprint_fb(2, asdf.netname);
				}
				asdf = asdf.next;
			}
		}
		asdf2 = asdf2.next;
	}
	if (number)
		bprint_fb(2, "\n");
	bprint_fb(2, "Match begins in  seconds\n");
	a_think = print5;
	a_nextthink = time + 1;
};	

// street fighter sounds only
void() roundsound =
{
	if (arenastate != A_PREROUND)
		return;
	if (a_sounds != 2)
		return;
	a_think = fiveseconds;
	a_nextthink = time + 0.25;
	local string round_;
	if (round == 1) round_ = "sf1.wav";
	else if (round == 2) round_ = "sf2.wav";
	else if (round == 3) round_ = "sf3.wav";
	else if (round == 4) round_ = "sf4.wav";
	else if (round == 5) round_ = "sf5.wav";
	else if (round == 6) round_ = "sf6.wav";
	else if (round == 7) round_ = "sf7.wav";
	else if (round == 8) round_ = "sf8.wav";
	else if (round == 9) round_ = "sf9.wav";
	local float channel;
	channel = CHAN_AUTO + CHAN_NO_PHS_ADD;
	sound(channel, round_, 1, ATTN_NONE);
};

// start next round
void() nextround =
{
	if (arenastate != A_STARTING)
	if (arenastate != A_POSTROUND)
		return;
	arenastate = A_PREROUND;
	centerprint_all("\n");
	self = first_client;
	while (self)
	{
		if (self.tracking)
			track_off();
		if (self.pantscolor_)
		{
			PutClientInServer();
			self.team = (self.color_ & 15) + 1;
			SetColorName(MSG_ALL, self);
		}
		self = self.next;
	}
	round = round + 1;
	if ((a_sounds == 2) && (round < 10))
	{
		sound(CHAN_NO_PHS_ADD, "sfround.wav", 1, ATTN_NONE);
		a_think = roundsound;
		a_nextthink = time + 0.75;
	}
	else
	{
		a_think = fiveseconds;
		a_nextthink = time + 1;
	}
	bprint_fb(2, "Round ");
	bprint_g(2, round);
	bprint_fb(2, "\n");
};

// print which teams playing
void() bluevsred =
{
	if (arenastate != A_STARTING)
		return;
	sound(CHAN_NO_PHS_ADD, "misc/talk.wav", 1, ATTN_NONE);
	local entity asdf;
	asdf = first_client;
	while (asdf)
	{
		asdf.frags = 0;
		UpdateFrags(asdf);
		asdf = asdf.next;
	}
	updateteams();
	local float notfirst;
	asdf = team1;
	while (asdf.teamnumber <= teams)
	{
		if (asdf.players)
		{
			if (notfirst)
				bprint_fb(2, " vs. ");
			bprint_fb(2, asdf.classname);
			notfirst = 1;
		}
		asdf = asdf.next;
	}
	if (notfirst)
		bprint_fb(2, "\n");
	a_think = nextround;
	a_nextthink = time + 1;

};

// everyone ready or forced start
void() startseries =
{
	if (arenastate != A_IDLE)
		return;
	arenastate = A_STARTING;
	round = 0;
	bprint_fb(2, "Series begins in  seconds...\n");
	a_think = bluevsred;
	a_nextthink = time + 10;
};

// everyone becomeinvisible
void() allinvisible =
{
	self = first_client;
	local float asdf;
	while (self)
	{
		if (self.tracking)
			track_off();
		asdf = asdf + 0.1;
		if (arenastate == A_IDLE)
		{
			self.shirtcolor_ = 
			self.pantscolor_ = 0;
		}
		self.shirtcolor = self.shirtcolor_;
		self.pantscolor = self.pantscolor_;
		becomeinvisible();
		self.think2 = changecolor;
		self.nextthink2 = time + asdf;
		self = self.next;
	}
	if (arenastate == A_POSTROUND)
	{
		a_think = nextround;
		a_nextthink = time + 5;
	}
	else
	if (arenastate == A_IDLE)
	{
		idleprint_time = 1;
		team1.wins = team2.wins = team3.wins = team4.wins = 0;
	}
};

// only 1 team left alive
void() ateamwon =
{
	sound(CHAN_NO_PHS_ADD, "misc/talk.wav", 1, ATTN_NONE);
	local entity asdf;
	asdf = first_client;
	while (asdf)
	{
		if (!asdf.invisible)
		if (asdf.health > 0)
		{
			bprint_fb(2, asdf.netname);
			bprint_fb(2, " had ");
			bprint_g(2, asdf.armorvalue);
			bprint_fb(2, " armor and ");
			bprint_g(2, asdf.health);
			bprint_fb(2, " health\n");
		}
		asdf = asdf.next;
	}
	updateteams();
	local entity winner;
	asdf = team1;
	while (asdf.teamnumber <= teams)
	{
		if (asdf.players > 0)
			winner = asdf;
		asdf = asdf.next;
	}
	if (winner)
	{
		local float wonseries;
		winner.wins = winner.wins + 1;
		if (winner.wins >= rounds)
			wonseries = 1;
	}
	if (!wonseries)
	{
		if (winner)
		{
			bprint_fb(2, "Team ");
			bprint_fb(2, winner.classname);
			bprint_fb(2, " has won the round\n");
		}
		else
			bprint_fb(2, "“ÔıÓ‰ ÈÛ · ‰Ú·˜°\n");
		local entity first;
		asdf = first = team1;
		while (asdf.teamnumber <= teams)
		{
			if (asdf.wins > first.wins)
				first = asdf;
			asdf = asdf.next;
		}
		local float winners;

		asdf = team1;
		while (asdf.teamnumber <= teams)
		{

		if (asdf.wins == first.wins)
				winners = winners + 1;
			asdf = asdf.next;
		}
		if (winners == 1)
		{
			local entity second;
			second = asdf = team1;
			if (first == second)
				second = second.next;
			while (asdf.teamnumber <= teams)
			{
				if (asdf != first)
				if (asdf.wins > second.wins)
					second = asdf;
				asdf = asdf.next;
			}
			bprint_fb(2, "Team ");
			bprint_fb(2, first.classname);
			bprint_fb(2, " leads the series by ");
			bprint_g(2, first.wins - second.wins);
			bprint_fb(2, " wins and needs ");
			bprint_g(2, rounds - first.wins);
			bprint_fb(2, " more\n");
		}
		else
		{
			bprint_fb(2, "‘ËÂ ÛÂÚÈÂÛ ÈÛ ÙÈÂ‰ ‚ÂÙ˜ÂÂÓ ÙÂ·ÌÛ ");
			local float notfirst;
			asdf = team1;
			while (asdf.teamnumber <= teams)
			{
				if (asdf.wins == first.wins)
				{
					if (notfirst)
						bprint_fb(2, " and ");
					bprint_fb(2, asdf.classname);
					notfirst = 1;
				}
				asdf = asdf.next;
			}
			bprint_fb(2, "\n");
		}
	}
	else
	{
		arenastate = A_IDLE;
		bprint_fb(2, "Team ");
		bprint_fb(2, winner.classname);
		bprint_fb(2, " has won the series!\n");
	}
	a_think = allinvisible;
	a_nextthink = time + 1;
};

// check # of teams left alive
void() checkifteamwon =
{

	if (!game_arena)
		return;
	if (arenastate != A_PLAYING)
		return;
	updateteams();
	local float teams_;
	local entity asdf;
	asdf = team1;
	while (asdf.teamnumber <= teams)
	{
		if (asdf.players)
			teams_ = teams_ + 1;
		asdf = asdf.next;
	}
	if (teams_ <= 1)
	{
		arenastate = A_POSTROUND;
		a_think = ateamwon;
		a_nextthink = time + 3;
	}
};

// change bot shirt color after add to team
void() bot_choose_shirt =
{
	if (!self.frogbot)
		return;
	self.think2 = null;
	self.nextthink2 = 0;
	if (arenastate > A_STARTING)
		return;
	local float asdf;
	asdf = random() * 2;
	asdf = floor(asdf) + 2;
	self.botchose = 1;
	self.impulse = asdf;
};

// add bot to team
void() bot_choose_team =
{
	if (arenastate > A_STARTING)
		return;
	if (self.pantscolor_)
		return;
	if (!self.frogbot)
		return;
	updateteams();
	local entity asdf, asdf2;
	asdf = team1;
	while (asdf.teamnumber <= teams)
	{
		if (self.botpantscolor == asdf.pantscolor)
			asdf2 = asdf;
		asdf = asdf.next;
	}
	if (!asdf2)
	{
		local entity lowest;
		local float lowest_;
		asdf = lowest = team1;
		while (asdf.teamnumber <= teams)
		{
			if (asdf.players < lowest.players)
				lowest = asdf;
			asdf = asdf.next;
		}
//		asdf2 = lowest;
		asdf = team1;
		while (asdf.teamnumber <= teams)
		{
			if (asdf.players == lowest.players)
				lowest_ = lowest_ + 1;
			asdf = asdf.next;
		}
		if (lowest_ == 1)
			asdf2 = lowest;
		else
		{
			rnd = random() * lowest_;
			rnd = ceil(rnd);
			lowest_ = 0;
			asdf = team1;
			while (asdf.teamnumber <= teams)
			{
				if (asdf.players == lowest.players)
				{
					lowest_ = lowest_ + 1;
					if (lowest_ == rnd)
						asdf2 = asdf;
				}
				asdf = asdf.next;
			}
		}
	}
	self.botchose = 1;
	self.impulse = asdf2.teamnumber;
	if (random() < 0.4)
	{
		self.think2 = bot_choose_shirt;
		self.nextthink2 = time + random() * 3;
	}
};

// centerprint "choose team" or "choose shirt color"
void() idleprint =
{
	if (!self.player)
		return;
	local string s, s1, s2, s3, s4;
	local entity asdf, asdf2, lowest;
	local float lowest_;
	updateteams();
	if (!self.pantscolor_)
	{
		s = "Please choose a team:\n\nêë Blue\nêë Red\n";
		if (teams == 4)
			s1 = "êë Yellow\nêë Green\n";
		else
		if (teams == 3)
			s1 = "êë Yellow\n";
		else
			s1 = "";
		s2 = "\n\nTeam ";
		s4 = " needs more people\n";
		msg_level = PRINT_HIGH;
		asdf = lowest = team1;
		while (asdf.teamnumber <= teams)
		{
			if (asdf.players < lowest.players)
				lowest = asdf;
			asdf = asdf.next;
		}
		asdf = team1;
		while (asdf.teamnumber <= teams)
		{
			if (asdf.players == lowest.players)
				lowest_ = lowest_ + 1;
			asdf = asdf.next;
		}
		if (lowest_ == 1)
			s3 = lowest.classname;
		else
			s2 = s3 = s4 = "";
		centerprint5(self, s, s1, s2, s3, s4);
	}
	else
	{

	s = "Choose your shirt color:\n\n";
		if (self.pantscolor == 13)
			s1 = "êë Blue\nêë Light Blue\nêë Green Blue\n";
		else 
		if (self.pantscolor == 4)
			s1 = "êë Red\nêë Peach\nêë Tan\n";
		else
		if (self.pantscolor == 12)
			s1 = "êë Yellow\nêë Dark Yellow\nêë Tan\n";
		else
		if (self.pantscolor == 3)
			s1 = "êë Green\nêë Purple\nêë Magenta\n";
		s2 = "\nPress êë to uncommit\n\n";
		if (team0.players != 1)
		{
			s3 = s4 = "";
			centerprint5(self, s, s1, s2, s3, s4);
		}
		else
		{
			asdf = first_client;
			while (asdf)
			{
				if (!asdf.pantscolor)
					asdf2 = asdf;
				asdf = asdf.next;
			}
			if (asdf2.client_)
			{
				s3 = asdf2.netname;
				s4 = " is holding things up!\n";
				centerprint5(self, s, s1, s2, s3, s4);
			}
		}
	}
};

// become invisible
void() becomeinvisible =
{
	SelectSpawnPoint();
	previous_spot = spawn_pos;
	self.origin = spawn_pos.origin + '0 0 1';
	self.angles = spawn_pos.angles;
	self.oldangles = self.angles;
	setorigin(self, self.origin);
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.oldorigin = self.origin;
	self.modelindex = 0;
	self.weaponmodel = self.model = "";
	if (self.aiment)
		self.aiment.modelindex = 0;
	self.invisible = 1;
	self.takedamage = 
	self.deadflag = 
	self.solid = 
	self.frame =
	self.effects = 
	self.state =
	self.jump_flag =
	self.nextthink = 0;
	self.view_ofs_z = 22;
	self.air_finished = 9999999;
	self.gravity = 1;
	self.oldvelocity = self.velocity = '0 0 0';
	setinvisitems();
	if (self.player)
	{
		self.movetype = MOVETYPE_WALK;
		self.fixangle = TRUE;
	}
	else
	{
		self.movetype = MOVETYPE_STEP;

	self.oldwaterlevel = self.oldwatertype = 0;
	}
};

// check if ok to choose team
void() check_bot_choose_team =
{
	if (arenastate > A_STARTING)
	{
		self.think2 = null;
		self.nextthink2 = 0;
		return;
	}
	if (self.frogbot)
	if (!self.pantscolor_)
	if (!self.nextthink2)
	{
		self.think2 = bot_choose_team;
		self.nextthink2 = time + 2 + random() * 10;
	}
};

// become solid after getting tossed to avoid telefrag
void() solid_player =
{
	self.solid = SOLID_SLIDEBOX;
	spawn_tdeath(self.origin, self);
	self.think2 = null;
	self.nextthink2 = 0;
};

// toss player to avoid telefrag
float() toss_player =
{
	if (!game_arena)
	if (!pre_game)
		return 0;
	if (arenastate == A_PLAYING)
		return 0;
	local vector toss;
	other.solid = SOLID_NOT;
	toss = '0 0 0';
	toss_y = random() * 360;
	makevectors(toss);
	other.velocity = v_forward * 1000;
	other.velocity_z = 200;
	other.think2 = solid_player;
	other.nextthink2 = time + 1;
	return 1;
};
