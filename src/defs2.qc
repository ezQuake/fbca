/*
	defs2.qc

	global definitions

	Copyright (C) 2000-2003 rxr
	Copyright (C) 2000-2001 DMSouL
	Copyright (C) 2000-2007 ParboiL
*/

void() SightMarker;
void() AvoidEdge;
void() PlayerBreak;
void() SetSkill;
void() frogbot_marker_touch;
void() SightMarker;
void() HigherSightMarker;
void() AvoidHazards;
void(entity me) teamreport;
void(entity me, float nt) teamreport2;
void() teams_frags_count;
void(entity e) remove_apply = #15;
float(entity ent) IsVisible;
entity() spawn_apply = #14;
entity search_item;
entity q_gamer;
entity p_gamer;
entity i_gamer;
float IT_ROCKET_LIGHTNING = 96;
float HELP_TEAMMATE = 128;
float CP_WPSTATS = 1;
float intermission_getting_closer;
float total_entity_count;
float() ExistsPath;
float() RocketSafe;
float() BotShouldDischarge;
float() WaterCombat;
float() boomstick_only;
float TEAM_COLOR1 = 5;
float TEAM_COLOR2 = 14;
float TEAM_COLOR3 = 1;
float TEAM_COLOR4 = 2;
float TEAM_COLOR5 = 3;
float TEAM_COLOR6 = 4;
float TEAM_COLOR7 = 6;
float TEAM_COLOR8 = 7;
float TEAM_COLOR9 = 8;
float TEAM_COLOR10 = 9;
float TEAM_COLOR11 = 10;
float TEAM_COLOR12 = 11;
float TEAM_COLOR13 = 12;
float TEAM_COLOR14 = 13;
float last_say_q;
float last_say_p;
float last_say_i;
float game_arena;
float k_scores1;
float k_scores2;
float k_standby;
float load_delay_time;
float ar_time;
float sudden_death;
float break_match;
float timelimit_user;
float line_one;
float line_two;
float line_three;
float line_four;
float open_bracket = 40;
float close_bracket = 41;
float MSG_HIGH = 3;
float overtime_begun;
float overtime_stats;
float k_vbreak;
float dist_sfl;
float lock;
float duel_mode;
float team_mode;
float no_lg;
float k_shutdown;
float a_rep;
float dm_pline;
float t1_pline;
float t2_pline;
float door_open;
.float kf_speed;
.float s_sg;
.float s_ssg;
.float s_lg;
.float h_sg;
.float h_ssg;
.float h_rl;
.float h_lg;
.float s_RA;
.float s_YA;
.float s_GA;
.float s_QUAD;
.float s_PENT;
.float s_RING;
.float s_dmg;
.float t_dmg;
.float k_vote;
.float k_flag;
.float t_health;
.float t_armortype;
.float t_armorvalue;
.float chat_time;
.float reporteditems;
.float friendly;
.float bot_evade;
.float help_teammate_time;
.float frogwatermove_time;
.float kick;
.float k_stuff;
.float k_accepted;
.float suicide_time;
.float spawn_frag_time;
.float s_frags;
.float cprint;
.float up_finished;
.float botnumber;
.float old_bot; 
.string stringname;
string string_null;

void() SprintVersion =
{
	sprint_fb(self, 2, "\nÆâãá öåòóéïî: 1.01kt final\n");
	sprint_fb(self, 2, "Äáôå ïæ òåìåáóå: Mar 08 2007\n");
	sprint_fb(self, 2, "Áõôèïò ïæ íïä: ParboiL\n");
	sprint_fb(self, 2, "Íïòå éîæï: www.parboil.quakeworld.ru\n\n");
	sprint_fb(self, 2, "Type \"ãïííáîäó\" for help\n");
};

void() VersionInfo =
{
	localcmd("serverinfo mod_version 1.01kt\n");
};

string (float g) GetTeamName =
{
	if (g == TEAM_COLOR1) return infokey(world, "team4");
	else if (g == TEAM_COLOR2) return infokey(world, "team13");
	else if (g == TEAM_COLOR3) return infokey(world, "team0");
	else if (g == TEAM_COLOR4) return infokey(world, "team1");
	else if (g == TEAM_COLOR5) return infokey(world, "team2");
	else if (g == TEAM_COLOR6) return infokey(world, "team3");
	else if (g == TEAM_COLOR7) return infokey(world, "team5");
	else if (g == TEAM_COLOR8) return infokey(world, "team6");
	else if (g == TEAM_COLOR9) return infokey(world, "team7");
	else if (g == TEAM_COLOR10) return infokey(world, "team8");
	else if (g == TEAM_COLOR11) return infokey(world, "team9");
	else if (g == TEAM_COLOR12) return infokey(world, "team10");
	else if (g == TEAM_COLOR13) return infokey(world, "team11");
	else return infokey(world, "team12");
};

string (entity p) ClientTeamName =
{
	if (p.player) return infokey(p, "team");
	else return GetTeamName(p.realteam);
};

void() TestTeamName = 
{
	local float t1;
	local string tmp, s1;
	local entity p, old;
	t1 = 0;
	old = world;
	p = find(world, stringname, "gamer");
	while(p != world && !t1) {
		tmp = ClientTeamName(p);
		localcmd("localinfo k_team1 \"");
		localcmd(tmp);
		localcmd("\"\n");
		t1 = 1;
		old = p;
		p = find(p, stringname, "gamer");
	}
	while(p != world && t1) {
		tmp = ClientTeamName(p);
		s1 = ClientTeamName(old);
		if (tmp != s1) {
			localcmd("localinfo k_team2 \"");
			localcmd(tmp);
			localcmd("\"\n");
			t1 = 0;
		}
		p = find(p, stringname, "gamer");
	}
};

float() ControlRPlayers =
{
	local entity p;
	local float num;
	num = 0;
	p = find(world, classname, "player");
	while(p != world)	{
		if (p.client_ && p.ready) num = num + 1;
		p = find(p, classname, "player");
	}
	return num;
};

float() CountTeams =
{
	local entity p, p2;
	local float num;
	local string s1, s2;
	num = 0;
	p = find(world, stringname, "gamer");
	while(p != world) {
		p.k_flag = 0;
		p = find(p, stringname, "gamer");
	}
	p = find(world, stringname, "gamer");
	while(p != world) {
		if(!p.k_flag) {
			p.k_flag = 1;
			s1 = ClientTeamName(p);
			if(s1 != "") {
				num = num + 1;
				p2 = find(p, stringname, "gamer");
				while(p2 != world) {
					s1 = ClientTeamName(p);
					s2 = ClientTeamName(p2);
					if(s1 == s2) p2.k_flag = 1;
					p2 = find(p2, stringname, "gamer");
				}
			}
		}
		p = find(p, stringname, "gamer");
	}
	return num;
};

float(float fw, float fh) rndm =
{
	local float x;
	x = rint(fw + random() * (fh - fw));
	return x;
};

string(float n) gNum =
{
	if (n == 0) return "’";
	else if (n == 1) return "“";
	else if (n == 2) return "”";
	else if (n == 3) return "•";
	else if (n == 4) return "–";
	else if (n == 5) return "—";
	else if (n == 6) return "˜";
	else if (n == 7) return "™";
	else if (n == 8) return "š";
	else return "›";
};

void (float lev, float f) bprint_g = 
{
	local float n, d, g;
	local string s;
	if (f > 999 || f < -999) {
		bprint_ftos(lev, f);
		return;
	}
	f = floor(f);
	if (f < 0) {
		f = f * -1;
		bprint_fb(lev, "­");
	}
	n = rint(f);
	d = floor(n / 100);
	if (d) {
		s = gNum(d);
		bprint_fb(lev, s);
	}
	n = n - d * 100;
	g = floor(n / 10);
	if (g || d) {
		s = gNum(g);
		bprint_fb(lev, s);
	}
	n = n - g * 10;
	s = gNum(n);
	bprint_fb(lev, s);
};

void (entity who, float lev, float f) sprint_g = 
{
	local float n, d, g;
	local string s;
	if (f > 999 || f < -999) {
		sprint_ftos(who, lev, f);
		return;
	}
	f = floor(f);
	if (f < 0) {
		f = f * -1;
		sprint_fb(who, lev, "­");
	}
	n = rint(f);
	d = floor(n / 100);
	if (d) {
		s = gNum(d);
		sprint_fb(who, lev, s);
	}
	n = n - d * 100;
	g = floor(n / 10);
	if (g || d) {
		s = gNum(g);
		sprint_fb(who, lev, s);
	}
	n = n - g * 10;
	s = gNum(n);
	sprint_fb(who, lev, s);
};

void (float to, float val) bprint_nr =
{
	local float x, y;
	x = floor(val);
	y = rint((val - x) * 10);
	if (y == 10) {
		y = 0;
		x = x + 1; 
	}
	bprint_ftos(to, x);
	bprint_fb(to, ".");
	bprint_ftos(to, y);
};

void(float to, float val) cprint_nr =
{
	local float x, y, n, d, g;
	x = floor(val);
	y = rint((val - x) * 10);
	if (y == 10) {
		y = 0;
		x = x + 1; 
	}
	n = rint(x);
	d = floor(n / 100);
	if (d) WriteByte(to, d + 48);
	n = n - d * 100;
	g = floor(n / 10);
	if (d || g) WriteByte(to, g + 48);
	n = n - g * 10;
	WriteByte(to, n + 48);
	WriteByte(to, 46);	
	WriteByte(to, y + 48);
};

void() MatchMode =
{
	duel_mode = 0;
	team_mode = 0;
	if (numberofclients == 2) duel_mode = 1;
	else if (teamplay && numberofclients > 2) team_mode = 1;
};

float(entity p) ent_fspeed =
{
	local vector vel;
	local float spd;
	vel = p.velocity;
	vel_z = 0;	
	spd = vlen(vel);
	spd = rint(spd);
	return spd;
};

void(entity pl) show_speed =
{
	local float sp, x, sign;
	sp = ent_fspeed(pl);
	x = floor(sp / 1000);
	sign = 1;
	if (sp > 999) sign = -1; 
	sp = sp - x * 1000;
	pl.armorvalue = sp * sign + 1000 * sign;
};

void() explode =
{
	WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte(MSG_MULTICAST, TE_LAVASPLASH);
	WriteCoord(MSG_MULTICAST, self.origin_x);
	WriteCoord(MSG_MULTICAST, self.origin_y);
	WriteCoord(MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);
	remove(self);
};

void() explode_all =
{
	local entity e;
	local float x;
	e = nextent(world);
	while(e) {
		x = 0;
		if (e.classname == "missile") x = 1;
		if (x) {
			e.think = explode;
			e.nextthink = time + 0.01;
		}
		e = nextent(e);
	}
};

entity() spawn =
{
	if (total_entity_count == 600)
		return world;
	total_entity_count = total_entity_count + 1;
	return spawn_apply();
};

void(entity e) remove =
{
	total_entity_count = total_entity_count - 1;
	remove_apply(e);
};

void() remove_self =
{
	remove(self);
};

void(string s) AllPlaySnd =
{
	local entity p;
	p = find(world, classname, "player");
	while(p) {
		stuffcmd_apply(p, "play ");
		stuffcmd_apply(p, s);
		stuffcmd_apply(p, "\n");
		p = find(p, classname, "player");
	}
};

void(entity p) not_atf =
{
	stuffcmd_apply(p, "bf\n");
	if (time > (p.k_msgcount + 2)) {
		sprint_fb(p, 3, "console: you are not allowed to fire\n");
		p.k_msgcount = time;
	}
};

float() IsDanger =
{
	if ((self.health < enemy_.health) && (self.armorvalue < enemy_.armorvalue) && (self.armortype < enemy_.armortype) && (self.firepower < enemy_.firepower))
		return TRUE;
	if ((enemy_.items & (IT_INVULNERABILITY | IT_QUAD | IT_INVISIBILITY)) && (!(self.items & (IT_INVULNERABILITY | IT_INVISIBILITY))))
		return TRUE;
	return FALSE;
};

float() self_have_rl_or_lg =
{
	return (((self.items & IT_ROCKET_LAUNCHER) && (self.ammo_rockets > 1)) || ((self.items & IT_LIGHTNING) && (self.ammo_cells > 5)));
};

float() enemy_have_rl_or_lg =
{
	return (((enemy_.items & IT_ROCKET_LAUNCHER) && (enemy_.ammo_rockets > 1)) || ((enemy_.items & IT_LIGHTNING) && (enemy_.ammo_cells > 5)));
};

float() boomstick_only =
{
	return ((self.items & IT_SHOTGUN) && !(self.items & (IT_NAILGUN | IT_SUPER_NAILGUN | IT_SUPER_SHOTGUN | IT_ROCKET_LAUNCHER | IT_GRENADE_LAUNCHER | IT_LIGHTNING)));
};

float() enemy_defenceless =
{
	if (!enemy_have_rl_or_lg() && self_have_rl_or_lg())
	if (!IsDanger() && (self.health > 50) && (self.armorvalue >= 50))
		return TRUE;
	return FALSE; 
};

float() enemy_shaft_attack =
{
	return ((enemy_.weapon == IT_LIGHTNING) && (self.enemy_dist < 630) && (time < enemy_.attack_finished));
};