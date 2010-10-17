/*
	match.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
*/

void() TimerThink =
{
	if (game_not_match) {
		real_time = real_time + 1;
		time_left = timelimit * 60 - real_time;
	} else {
		time_left = timelimit_user * 60 - real_time;
		if (sudden_death) return;
	}
	if (time_left <= 0) return;
	// s: minutes
	minutes_left = time_left / 60;
	if(floor(minutes_left) == minutes_left) {
		if (!game_not_match) {
			localcmd("serverinfo status \"");
			localcmd_ftos(minutes_left);
			localcmd(" min left\"\n");
		}
		bprint_fb(2, "ê");
		bprint_g(2, minutes_left);
		if (minutes_left == 1)
			bprint_fb(2, "ë minute remaining\n");
		else
			bprint_fb(2, "ë minutes remaining\n");
		if (!game_not_match && team_mode)
			WonTeam();
	}
	// s: seconds
	if (time_left == 30 || time_left == 15 || time_left <= 10) {
		bprint_fb(2, "ê");
		bprint_g(2, time_left);
		if (time_left == 1)
			bprint_fb(2, "ë second\n");
		else
			bprint_fb(2, "ë seconds\n");
		if (time_left <= 10 && !game_not_match && !game_disable_botchat)
		if (random() < 0.35 && numberofclients > 1)
			bot_say_gg();
		if (time_left < 6)
			AllPlaySnd("buttons/switch04.wav");
	}
	if (game_not_match)
		self.nextthink = time + 1;
};

/*
============
DoCountDown

============
*/
void() DoCountDown =
{
	local float f1, n1, c1, s1;
	local string tmp;
	local entity old;
	c1 = 0 - real_time;
	if (c1 < 0)
	{
		k_standby = 0;
		TimerThink();
		return;
	}
	if (c1 > 0) 
	{
		if (c1 == 1)
		{
			k_standby = 1;
			self = first_client;
			while(self)
			{
				self.takedamage = 0;
				self.solid = 0;
				self.movetype = 0;
				self.modelindex = 0;
				self.model = string_null;
				self = self.next;
			}
		}
		if (!game_disable_botchat && numberofclients > 1)
			bot_say_gl();
		if (c1 < 6)
			AllPlaySnd("buttons/switch04.wav");
		if (c1 <= 99) // count down from 99
		{
			n1 = floor(c1 / 10);
			WriteByte(2, 26);
			WriteShort(2, 49930);	// \nC
			WriteShort(2, 62959);	// ou
			WriteShort(2, 62702);	// nt
			WriteShort(2, 61412);	// do
			WriteShort(2, 61175);	// wn
			WriteShort(2, 8250);	// :
			if(c1 < 10)
				WriteByte(2, 32);
			if(n1) WriteByte(2, n1 + 146);
			n1 = c1 - n1 * 10;
			WriteByte(2, n1 + 146);
			WriteShort(2, 2570); // 0x0A0A = \n\n
			WriteByte(2, 10);
			//deathmatch x
			WriteShort(2, 25924);
			WriteShort(2, 29793);
			WriteShort(2, 28008);
			WriteShort(2, 29793);
			WriteShort(2, 26723);
			WriteShort(2, 8224);
			WriteByte(2, deathmatch + 146);
			//modes
			WriteShort(2, 19722);
			WriteShort(2, 25711);
			WriteShort(2, 8293);
			WriteByte(2, 32);
			if (duel_mode) // Duel
			{
				WriteShort(2, 41156);
				WriteShort(2, 41205);
				WriteShort(2, 41189);
				WriteByte(2, 236);
			}
			else if (team_mode) // Team
			{
				WriteShort(2, 41172);
				WriteShort(2, 41189);
				WriteShort(2, 41185);
				WriteByte(2, 237);
			}
			else // Ffa
			{
				WriteShort(2, 41120);
				WriteShort(2, 41158);
				WriteShort(2, 41190);
				WriteByte(2, 225);
			}
			//(teamplay x)
			if(teamplay)
			{
				WriteByte(2, 10);
				WriteShort(2, 25940);
				WriteShort(2, 28001);
				WriteShort(2, 27760);
				WriteShort(2, 31073);
				WriteShort(2, 8224);
				WriteShort(2, 8224);
				WriteByte(2, teamplay + 146);
			}
			//(timelimit xx)
			if(timelimit)
			{
				WriteShort(2, 21514);
				WriteShort(2, 28009);
				WriteShort(2, 27749);
				WriteShort(2, 28009);
				WriteShort(2, 29801);
				WriteShort(2, 8224);
				f1 = timelimit;
				n1 = floor(f1 / 10);
				f1 = f1 - (n1 * 10);
				if(n1) WriteByte(2, n1 + 146);
				else WriteByte(2, 32);
				WriteByte(2, f1 + 146);
			}
			//(fraglimit xxx)
			if(fraglimit)
			{
				WriteShort(2, 17930);
				WriteShort(2, 24946);
				WriteShort(2, 27751);
				WriteShort(2, 28009);
				WriteShort(2, 29801);
				WriteByte(2, 32);
				f1 = fraglimit;
				n1 = floor(f1 / 100);
				f1 = f1 - (n1 * 100);
				if(n1) WriteByte(2, n1 + 146);
				else WriteByte(2, 32);
				n1 = floor(f1 / 10);
				f1 = f1 - (n1 * 10);
				WriteByte(2, n1 + 146);
				WriteByte(2, f1 + 146);
			}
			// overtime printout, supports sudden death display
			// overtime xx
			f1 = stof(infokey(world, "k_overtime"));
			if(f1)
			{
				WriteShort(2, 20234);
				WriteShort(2, 25974);
				WriteShort(2, 29810);
				WriteShort(2, 28009);
				WriteShort(2, 8293);
				WriteShort(2, 8224);
				if(f1 == 1)
				{
					f1 = stof(infokey(world, "k_exttime"));
					n1 = floor(f1 / 10);
					f1 = f1 - (n1 * 10);
					if(n1) WriteByte(2, n1 + 146);
					else WriteByte(2, 32);
					WriteByte(2, f1 + 146);
				}
				else
					WriteShort(2, 58611);
			}
			// powerups
			WriteByte(2, 10);
			WriteShort(2, 28496);
			WriteShort(2, 25975);
			WriteShort(2, 30066);
			WriteShort(2, 29552);
			WriteShort(2, 8224);
			if (game_disable_powerups)
			{
				WriteShort(2, 59087);
				WriteByte(2, 230);
			}
			else if (!game_disable_powerups)
			{
				WriteShort(2, 53152);
				WriteByte(2, 238);
			} 
			WriteString(2, "");
		}
		return;
	}
	self = find(world, classname, "missile");
	while (self)
	{
		remove_self();
		self = find(self, classname, "missile");
	}
	self = first_item;
	while (self)
	{
		if (self.think == SUB_regen)
			self.nextthink = 0;
		self = self.next;
	}
	self = first_item;
	while (self)
	{
		AssignVirtualGoal();
		self = self.next;
	}
	GameSettings();
	SpawnRunes();
	counting_down = 0;
	self = first_client;
	while (self)
	{
		ResetItems();
		self.frags = 0;
		self.friendly = 0;
		self.deaths = 0;
		self.efficiency = 0;
		self.h_rl = 0;
		self.h_lg = 0;
		self.s_lg = 0;
		old = self;
		PutClientInServer();
		self = old;
		self = self.next; 
	}
	centerprint_all("");
	bprint_fb(2, "‘ËÂ Ì·Ù„Ë Ë·Û ‚ÂÁıÓ°\n");
	s1 = stof(infokey(world, "allow_startsound"));
	if (s1) sound_apply(world, CHAN_AUTO, "boss2/pop2.wav", 0.13, ATTN_NONE);
	match_in_progress = 1;
	timelimit_user = timelimit;
	tmp = infokey(world, "k_spectalk");
	localcmd("sv_spectalk ");
	localcmd(tmp);
	localcmd("\n");
	localcmd("\nserverinfo status \"");
	localcmd_ftos(timelimit);
	localcmd(" min left\"\n");
	if (team_mode)
	TestTeamName();
};

void() PlayerBreak =
{
	local float f1;
	break_match = 0;
	if (!self.ready) return;
	if (pre_game && !counting_down) {
		self.ready = 0;
		bprint_fb(2, self.netname);
		bprint_fb(2, " ÈÛ ÓÔÙ ÚÂ·‰˘\n");
		if (teamplay) self.effects = self.effects | EF_BLUE;
		return;
	}
	if (pre_game && counting_down) {
		counting_down = 0;
		start_time = 0;
		self.ready = 0;
		lightstyle(0, "m");
		localcmd("serverinfo status Standby\n");
		bprint_fb(2, self.netname);
		bprint_fb(2, " ÛÙÔÛ ÙËÂ „ÔıÓÙ‰Ô˜Ó\n");
		if (teamplay) self.effects = self.effects | EF_BLUE;
		return;
	}
	if (self.p_break) {
		bprint_fb(2, self.netname);
		bprint_fb(2, " ˜ÈÙË‰Ú·˜Û ËÈÛ ˆÔÙÂ\n");
		self.p_break = 0;
		e_break = e_break - 1;
		return;
	}
	bprint_fb(2, self.netname);
	bprint_fb(2, " ˆÔÙÂÛ ÊÔÚ ÛÙÔÈÓÁ ÙËÂ Ì·Ù„Ë\n");
	self.p_break = 1;
	e_break = e_break + 1;
	f1 = (floor(numberofplayers / 2)) + 1;
	if (e_break >= f1) {
		bprint_fb(2, "Match stopped by majority vote\n");
		break_match = 1;
		start_time = 0;
		self.ready = 0;
		NextLevel();
		return;
	}
};

/*
============
PlayerReady

============
*/
void() PlayerReady =
{
	local float f1, f2, c1;
	local string tmp;
	if (pre_game) {
		if (self.ready) { 
			sprint_fb(self, 2, "Type break to unready yourself\n");
			return;
		}
		if (!counting_down) {
			self.ready = 1;
			bprint_fb(2, self.netname);
			bprint_fb(2, " is ready"); 
			if (teamplay) {
				if (self.player) self.effects = self.effects - (self.effects & EF_BLUE); 
				tmp = ClientTeamName(self);
				bprint_fb(2, " ê");
				bprint_fb(2, tmp);
				bprint_fb(2, "ë");
			}
			bprint_fb(2, "\n");
			if (self.player) {
				if (team_mode) {
					f1 = CountTeams();
					if (f1 < 2) {
						bprint_ftos(2, 2 - f1);
						bprint_fb(2, " ÌÔÚÂ ÙÂ·Ì");
						if ((2 - f1) != 1) bprint_fb(2, "Û");
						bprint_fb(2, " ÚÂÒıÈÚÂ‰\n");
						return;
					}
					if (f1 > 2) {
						bprint_fb(2, "«ÂÙ ÚÈ‰ ÔÊ ");
						bprint_ftos(2, f1 - 2);
						bprint_fb(2, " ÙÂ·Ì");
						if ((f1 - 2) != 1) bprint_fb(2, "Û");
						bprint(2, "!\n");
						return;
					}
				}
				f2 = ControlRPlayers();
				if (f2 == numberofplayers) {
					c1 = stof(infokey(world, "k_count"));
					start_time = check_parm_time + c1;
					counting_down = 1;
					k_shutdown = 1;
					stuffcmd_apply(self, "-attack\n");
					localcmd("serverinfo status Countdown\n");
					bprint_fb(2, "All players ready ê");
					bprint_ftos(2, numberofclients);
					bprint_fb(2, "ë\nSpawnmodel: ŒÔÚÌ·Ï —◊ ÚÂÛ·˜ÓÛ\n");
					AllPlaySnd("items/protect2.wav");
					lightstyle(0, "g");
				} else return;
			}
		}
	}
};

void () TopScorers =
{
	local entity p;
	local float max, maxfrags, maxdeaths, maxfriend, maxeffi;
	maxfrags = -99999;
	maxdeaths = 0;
	maxfriend = 0;
	maxeffi = 0;
	p = find(world, stringname, "gamer");
	while(p != world) {
		if (maxfrags < p.frags) maxfrags = p.frags;
		if (maxdeaths < p.deaths) maxdeaths = p.deaths;
		if (maxfriend < p.friendly) maxfriend = p.friendly;
		if (maxeffi < p.efficiency) maxeffi = p.efficiency;
		p = find(p, stringname, "gamer");
	}
	if (maxfrags || maxdeaths || maxfriend || maxeffi) {
		bprint_fb(2, "\nê");
		bprint_fb(2, mapname);
		bprint_fb(2, "ë ÙÔ Û„ÔÚÂÛ:\nùûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûü\n");
		if (maxfrags) {
			bprint_fb(2, "      ∆Ú·ÁÛ: ");
			max = 0;
			p = find(world, stringname, "gamer");
			while(p != world) { 
				if (p.frags == maxfrags) {
					if (max) bprint_fb(2, "             ");
					max = 1;
					bprint_fb(2, p.netname);
					bprint_fb(2, " ê");
					bprint_ftos(2, maxfrags);
					bprint_fb(2, "ë\n");
				}
				p = find(p, stringname, "gamer");
			} 
		}
		if (maxdeaths) { 
			bprint_fb(2, "     ƒÂ·ÙËÛ: ");
			max = 0; 
			p = find(world, stringname, "gamer");
			while(p != world) {
				if (p.deaths == maxdeaths) {
					if (max) bprint_fb(2, "             ");
					max = 1;
					bprint_fb(2, p.netname);
					bprint_fb(2, " ê");
					bprint_ftos(2, maxdeaths);
					bprint_fb(2, "ë\n");
				}
				p = find(p, stringname, "gamer");
			}
		} 
		if (team_mode && maxfriend) {
			bprint_fb(2, "∆ÚÈÂÓ‰ÎÈÏÏÛ: ");
			max = 0;
			p = find(world, stringname, "gamer");
			while(p != world) {
				if (p.friendly == maxfriend) {
					if (max) bprint_fb(2, "             ");
					max = 1;
					bprint_fb(2, p.netname);
					bprint_fb(2, " ê");
					bprint_ftos(2, maxfriend);
					bprint_fb(2, "ë\n");
				}
				p = find(p, stringname, "gamer");
			}
		}
		if (maxeffi) {
			bprint_fb(2, " ≈ÊÊÈ„ÈÂÓ„˘: ");
			max = 0;
			p = find(world, stringname, "gamer");
			while(p != world) {
				if (p.efficiency == maxeffi) {
					if (max) bprint_fb(2, "             ");
					max = 1;
					bprint_fb(2, p.netname);
					bprint_fb(2, " ê");
					bprint_nr(2, maxeffi);
					bprint_fb(2, "%ë\n");
				}
				p = find(p, stringname, "gamer");
			}
		}
	} 
};

void(entity ent) PrintFullStats =
{
	bprint_fb(2, "◊: ");
	if (ent.h_lg) {
		bprint_fb(2, "ÏÁ:");
		bprint_nr(2, (ent.s_lg / ent.h_lg) * 100);
		bprint_fb(2, "% ");
	}
	if (ent.h_rl) {
		bprint_fb(2, "ÚÏ:");
		bprint_ftos(2, ent.h_rl);
		bprint_fb(2, " ");
	}
	if (ent.h_sg) {
		bprint_fb(2, "ÛÁ:");
		bprint_nr(2, (ent.s_sg / ent.h_sg) * 100);
		bprint_fb(2, "% ");
	}
	if (ent.h_ssg) {
		bprint_fb(2, "ÛÛÁ:");
		bprint_nr(2, (ent.s_ssg / ent.h_ssg) * 100);
		bprint_fb(2, "% ");
	}
	bprint_fb(2, "\n");
	// Powerups
	if (!game_disable_powerups) {
		bprint_fb(2, "–Ô˜ÂÚıÛ: —:");
		bprint_ftos(2, ent.s_QUAD);
		bprint_fb(2, " –:");
		bprint_ftos(2, ent.s_PENT);
		bprint_fb(2, " “:");
		bprint_ftos(2, ent.s_RING);
		bprint_fb(2, "\n");
	}
	// Armors
	bprint_fb(2, "  ¡ÚÌÔÚÛ: Á·:");
	bprint_ftos(2, ent.s_GA);
	bprint_fb(2, " ˘·:");
	bprint_ftos(2, ent.s_YA);
	bprint_fb(2, " Ú·:");
	bprint_ftos(2, ent.s_RA);
	bprint_fb(2, "\n");
	// Damages
	bprint_fb(2, "  ƒ·Ì·ÁÂ: ‘·ÎÂÓ:");
	bprint_nr(2, ent.t_dmg);
	bprint_fb(2, " «ÈˆÂÓ:");
	bprint_nr(2, ent.s_dmg);
	bprint_fb(2, "\n");
};

void (entity p) PlayerScores =
{
	local string tmp, tmp2;
	bprint_fb(2, "á ");
	bprint_fb(2, p.netname);
	bprint_fb(2, ":\n  ");
	bprint_ftos(2, p.frags);
	bprint_fb(2, " (");
	bprint_ftos(2, p.frags - p.deaths);
	bprint_fb(2, ")");
	if (team_mode) {
		bprint_fb(2, " ");
		bprint_ftos(2, p.friendly);
	}
	if (p.frags < 1) p.efficiency = 0;
	else p.efficiency = p.frags / (p.frags + p.deaths) * 100;
	bprint_fb(2, " è ");
	bprint_nr(2, p.efficiency);
	bprint_fb(2, "%\n");
	if (duel_mode) {
		PrintFullStats(p);
		// EndGame
		bprint_fb(2, "  ≈Ó‰«·ÌÂ: »: ê");
		bprint_ftos(2, p.health);
		bprint_fb(2, "ë ¡: ê");
		if (p.armortype == 0.3) bprint_fb(2, "ga:");
		else if (p.armortype == 0.6) bprint_fb(2, "ya:");
		else if (p.armortype == 0.8) bprint_fb(2, "ra:");
		bprint_ftos(2, p.armorvalue);
		bprint_fb(2, "ë\n");
		// OverTime
		if (overtime_stats) {
			bprint_fb(2, "  œˆÂÚ‘ÈÌÂ: »: ê");
			bprint_ftos(2, p.t_health);
			bprint_fb(2, "ë ¡: ê");
			if (p.t_armortype == 0.3) bprint_fb(2, "ga:");
			else if (p.t_armortype == 0.6) bprint_fb(2, "ya:");
			else if (p.t_armortype == 0.8) bprint_fb(2, "ra:");
			bprint_ftos(2, p.t_armorvalue);
			bprint_fb(2, "ë\n");
		}
		// SpawnFrags
		bprint_fb(2, "  ”·˜Ó∆Ú·ÁÛ: ê");
		bprint_ftos(2, p.s_frags);
		bprint_fb(2, "ë\n");
	}
	if (team_mode) {
		tmp = infokey(world, "k_team1");
		tmp2 = ClientTeamName(p);
		if (tmp == tmp2) {
			if (t1_pline) {
				bprint_fb(2, "ùûûûûûûûûü\n");
				t1_pline = t1_pline - 1;
			}
		} else {
			if (t2_pline) {
				bprint_fb(2, "ùûûûûûûûûü\n");
				t2_pline = t2_pline - 1;
			}
		}
	} else {
		if (dm_pline) {
			bprint_fb(2, "ùûûûûûûûûü\n");
			dm_pline = dm_pline - 1;
		}
	}
};

void () PlayerStats =
{
	local entity p, p2;
	local float x1, x2;
	local string s1, s2, tmp;
	bprint_fb(2, "\n–Ï·˘ÂÚ ÛÙ·ÙÈÛÙÈ„Û:\n∆Ú·ÁÛ (Ú·ÓÎ)");
	if (team_mode) bprint_fb(2, " ÊÚÈÂÓ‰ÎÈÏÏÛ");
	bprint_fb(2, " è ÂÊÊÈ„ÈÂÓ„˘\nùûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûü\n");
	p = find(world, stringname, "gamer");
	while(p) {
		if (!p.k_accepted) {
			p2 = p;
			while(p2) {
				s1 = ClientTeamName(p);
				s2 = ClientTeamName(p2);
				if (s1 == s2) {
					if (team_mode) {
						if (s2 == infokey(world, "k_team1")) {
							if (!x1) {
								x1 = 1;
								bprint_fb(2, "Team ê");
								tmp = infokey(world, "k_team1");
								bprint_fb(2, tmp);
								bprint_fb(2, "ë:\n");
							}
						} else {
							if (!x2) {
								x2 = 1;
								bprint_fb(2, "\nTeam ê");
								tmp = infokey(world, "k_team2");
								bprint_fb(2, tmp);
								bprint_fb(2, "ë:\n");
							}
						}
					}
					PlayerScores(p2);
					p2.k_accepted = 1;
				}
				p2 = find(p2, stringname, "gamer");
			}
		}
		p = find(p, stringname, "gamer");
	}
};

void(entity ent, entity p) CalcTeamStats =
{
	ent.s_lg = ent.s_lg + p.s_lg; 
	ent.h_lg = ent.h_lg + p.h_lg;
	ent.h_rl = ent.h_rl + p.h_rl;
	ent.s_sg = ent.s_sg + p.s_sg;
	ent.h_sg = ent.h_sg + p.h_sg;
	ent.s_ssg = ent.s_ssg + p.s_ssg;
	ent.h_ssg = ent.h_ssg + p.h_ssg;
	ent.s_QUAD = ent.s_QUAD + p.s_QUAD;
	ent.s_PENT = ent.s_PENT + p.s_PENT;
	ent.s_RING = ent.s_RING + p.s_RING;
	ent.s_GA = ent.s_GA + p.s_GA;
	ent.s_YA = ent.s_YA + p.s_YA;
	ent.s_RA = ent.s_RA + p.s_RA;
	ent.t_dmg = ent.t_dmg + p.t_dmg;
	ent.s_dmg = ent.s_dmg + p.s_dmg;
};

void () TeamScorers =
{
	local entity p;
	local string tmp, tmp2;
	t1_pline = -1;
	t2_pline = -1;
	bprint_fb(2, "\n‘Â·Ì ÛÙ·ÙÈÛÙÈ„Û:\n◊Â·ÔÓÛ¨ Ô˜ÂÚıÛ¨ ·ÚÌÔÚÛ¨ ‰·Ì·ÁÂ\nùûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûü\n");
	p = find(world, stringname, "gamer");
	while(p != world) {
		tmp = infokey(world, "k_team1");
		tmp2 = ClientTeamName(p);
		if (tmp == tmp2) {
			t1_pline = t1_pline + 1;
			CalcTeamStats(team1, p);
		} else {
			t2_pline = t2_pline + 1;
			CalcTeamStats(team2, p);
		}
		p = find(p, stringname, "gamer");
	}
	tmp = infokey(world, "k_team1");
	bprint_fb(2, "ê");
	bprint_fb(2, tmp);
	bprint_fb(2, "ë: ");
	PrintFullStats(team1);
	bprint_fb(2, "\n");
	tmp = infokey(world, "k_team2");
	bprint_fb(2, "ê");
	bprint_fb(2, tmp);
	bprint_fb(2, "ë: ");
	PrintFullStats(team2);
};

void() FinalTeamStats =
{
	local string tmp;
	local float sumfrags;
	bprint_fb(2, "\n‘Â·Ì Û„ÔÚÂÛ: ÊÚ·ÁÛ è ÂÚ„ÂÓÙ·ÁÂ\nùûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûûü\n");
	teams_frags_count();
	sumfrags = k_scores1 + k_scores2;
	bprint_fb(2, "ê");
	tmp = infokey(world, "k_team1");
	bprint_fb(2, tmp);
	bprint_fb(2, "ë: ");
	bprint_ftos(2, k_scores1);
	bprint_fb(2, " è ");
	if (sumfrags > 0) bprint_nr(2, (k_scores1 / sumfrags) * 100);
	else bprint_nr(2, 0);
	bprint_fb(2, "%\n");
	bprint_fb(2, "ê");
	tmp = infokey(world, "k_team2");
	bprint_fb(2, tmp);
	bprint_fb(2, "ë: ");
	bprint_ftos(2, k_scores2);
	bprint_fb(2, " è ");
	if (sumfrags > 0) bprint_nr(2, (k_scores2 / sumfrags) * 100);
	else bprint_nr(2, 0);
	bprint_fb(2, "%\n");
};

void() FinalStats =
{
	if (team_mode) TeamScorers();
	else dm_pline = numberofclients - 1;
	PlayerStats();
	TopScorers();
	if (team_mode) FinalTeamStats();
	bprint_fb(2, "\n");
};

/*
============
GameSettings

============
*/
void() GameSettings =
{
	pre_game = FALSE;
	if (deathmatch != 4)
		use_ammo = TRUE;
};