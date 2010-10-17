/*
	commands.qc

	Copyright (C) 2000-2003 rxr
	Copyright (C) 2000-2007 ParboiL
*/

void() teams_frags_count =
{
	local entity p;
	local string tmp, tmp2;
	k_scores1 = 0;
	k_scores2 = 0;
	p = find(world, stringname, "gamer");
	while(p != world) {
		tmp = infokey(world, "k_team1");
		tmp2 = ClientTeamName(p);
		if (tmp == tmp2) k_scores1 = k_scores1 + p.frags;
		else k_scores2 = k_scores2 + p.frags;
		p = find(p, stringname, "gamer");
	}
};

void() WonTeam =
{
	local string tmp;
	local float f1;
	teams_frags_count();
	if (k_scores1 > k_scores2) {
		f1 = k_scores1 - k_scores2;
		tmp = infokey(world, "k_team1");
		bprint_fb(2, "Τεαν ");
		bprint_fb(2, tmp);
		bprint_fb(2, "‘ leads by ");
		bprint_g(2, f1);
		bprint_fb(2, " frag");
		if (f1 == 1) bprint_fb(2, "\n");
		else bprint_fb(2, "s\n");
	} else if (k_scores1 < k_scores2) {
		f1 = k_scores2 - k_scores1;
		tmp = infokey(world, "k_team2");
		bprint_fb(2, "Τεαν ");
		bprint_fb(2, tmp);
		bprint_fb(2, "‘ leads by ");
		bprint_g(2, f1);
		bprint_fb(2, " frag");
		if (f1 == 1) bprint_fb(2, "\n");
		else bprint_fb(2, "s\n");
	} else bprint_fb(2, "The game is currently a tie\n");
};

void() PrintScores =
{
	local string tmp;
	local float f1;
	if (!game_not_match) {
		if (pre_game) {
			if (!counting_down) sprint_fb(self, 2, "no game - no scores\n");
			else sprint_fb(self, 2, "Countdown\n");
			return;
		}
		if (sudden_death) {
			sprint_fb(self, 2, "Οφεςτινε sudden death ιξ πςοηςεσσ\n");
		} else { 
			if (timelimit) {
				if (minutes_left > 1) {
					sprint_fb(self, 2, "");
					sprint_g(self, 2, minutes_left);
					sprint_fb(self, 2,"‘ full minute");
					if (minutes_left > 2) sprint_fb(self, 2, "s");
				} else {
					sprint_fb(self, 2, "");
					sprint_g(self, 2, time_left);
					sprint_fb(self, 2, "‘ second");
					if (time_left > 1) sprint_fb(self, 2, "s");
				} 
				sprint_fb(self, 2, " left\n");
			}
		}
		if (team_mode) {
			teams_frags_count();
			tmp = infokey(world, "k_team1");
			sprint_fb(self, 2, "Τεαν ");
			sprint_fb(self, 2, tmp);
			sprint_fb(self, 2, "‘ = ");
			sprint_g(self, 2, k_scores1);
			sprint_fb(self, 2, "\n");
			tmp = infokey(world, "k_team2");
			sprint_fb(self, 2, "Τεαν ");
			sprint_fb(self, 2, tmp);
			sprint_fb(self, 2, "‘ = ");
			sprint_g(self, 2, k_scores2);
			sprint_fb(self, 2, "\n");
			if (k_scores1 > k_scores2) {
				f1 = k_scores1 - k_scores2;
				tmp = infokey(world, "k_team1");
				sprint_fb(self, 2, "Τεαν ");
				sprint_fb(self, 2, tmp);
				sprint_fb(self, 2, "‘ leads by ");
				sprint_g(self, 2, f1);
				sprint_fb(self, 2, " frag");
				if (f1 == 1) sprint_fb(self, 2, "\n");
				else sprint_fb(self, 2, "s\n");
			} else if (k_scores1 < k_scores2) {
				f1 = k_scores2 - k_scores1;
				tmp = infokey(world, "k_team2");
				sprint_fb(self, 2, "Τεαν ");
				sprint_fb(self, 2, tmp);
				sprint_fb(self, 2, "‘ leads by ");
				sprint_g(self, 2, f1);
				sprint_fb(self, 2, " frag");
				if (f1 == 1) sprint_fb(self, 2, "\n");
				else sprint_fb(self, 2, "s\n");
			} else sprint_fb(self, 2, "The game is currently a tie\n");
		}
	}
};

void() PlayerStatus =
{
	local entity p;
	local string tmp;
	if (game_not_match) return;
	if (pre_game && !counting_down) {
		sprint_fb(self, 2, "Πμαωεςσ μιστ:\n\n");
		p = find(world, stringname, "gamer");
		while(p != world) {
			if (p.ready) sprint_fb(self, 2, "† ");
			else sprint_fb(self, 2, "‡ ");
			sprint_fb(self, 2, p.netname);
			tmp = ClientTeamName(p);
			if (teamplay && tmp != "") {
				sprint_fb(self, 2, " ");
				sprint_fb(self, 2, tmp);
				sprint_fb(self, 2, "‘\n");
			} else sprint_fb(self, 2, "\n");
			p = find(p, stringname, "gamer");
		} sprint_fb(self, 3, "\n");
	} else sprint_fb(self, 2, "Game in progress\n");
};

void() ChangeOvertime =
{
	local float f1,f2;
	if(match_in_progress) return;
	f1 = stof(infokey(world, "k_overtime"));
	f2 = stof(infokey(world, "k_exttime"));
	if (!f1) {
		if (!f2) {
			localcmd("localinfo k_exttime 1\n");
			f2 = 1;
		}
		bprint_fb(2, "Οφεςτινε: time based\n");
		bprint_fb(2, "Οφεςτινε μεξητθ ισ ");
		bprint_ftos(2, f2);
		bprint_fb(2, " νιξυτε");
		if (f1 == 1) bprint_fb(2, "\n");
		else bprint_fb(2, "σ\n");
		localcmd("localinfo k_overtime 1\n");
	} else if(f1 == 1) {
		bprint_fb(2, "Οφεςτινε: sudden death\n");
		localcmd("localinfo k_overtime 2\n");
	} else if(f1 == 2) {
		bprint_fb(2, "Οφεςτινε: off\n");
		localcmd("localinfo k_overtime 0\n");
	}
};

void() ToggleLighting =
{
	if (match_in_progress || counting_down) return;
	if (!game_not_match) {
		if (deathmatch != 4) {
			sprint_fb(self, 2, "invalid δεατθνατγθ\n");
			return;
		} 
		if (no_lg) no_lg = 0;
		else no_lg = 1;
		if (no_lg) bprint_fb(2, "μιηθτιξη not allowed\n");
		else bprint_fb(2, "μιηθτιξη allowed\n");
	}
};

void() toggle_sh_speed =
{
	if (match_in_progress || counting_down) return;
	if (!game_not_match) {
		if (self.kf_speed) self.kf_speed = 0;
		else self.kf_speed = 1;
		if (self.kf_speed) sprint_fb(self, 2, "σθοχ σπεεδ On\n");
		else sprint_fb(self, 2, "σθοχ σπεεδ Off\n");
	}
};

void() ToggleSpecTalk =
{
	local float tmp;
	if (match_in_progress || counting_down) return;
	if (!game_not_match) {
		tmp = stof(infokey(world, "k_spectalk"));
		bprint_fb(2, "Spectalk ");
		if(tmp != 0) {
			localcmd("localinfo k_spectalk 0\n");
			bprint_fb(2, "off: πμαωεςσ γαξξοτ θεας σπεγτατοςσ δυςιξη ηανε\n");
			return;
		}
		localcmd("localinfo k_spectalk 1\n");
		bprint_fb(2, "on: πμαωεςσ γαξ θεας σπεγτατοςσ δυςιξη ηανε\n");
	}
};

void() ChangeLock =
{
	if (match_in_progress || counting_down) return;
	if (!game_not_match) {
		if(lock) lock = 0;
		else lock = 1;
		if(!lock) bprint_fb(2, "Σεςφες μογλιξη off\n");
		else bprint_fb(2, "Σεςφες μογλεδ - players cannot connect during game\n");
	}
};

void() TimeDown =
{
	local string tmp;
	if (match_in_progress || counting_down) return;
	if (!game_not_match) {
		timelimit = timelimit - 5;
		if (timelimit < 5) timelimit = 5;
		tmp = ftos(timelimit);
		bprint_fb(2, "Νατγθ μεξητθ σετ το ");
		bprint_fb(2, tmp);
		bprint_fb(2, " νιξυτεσ\n");
		cvar_set("timelimit", tmp);
	}
};

void() TimeUp =
{
	local string tmp;
	local float top;
	if (match_in_progress || counting_down) return;
	if (!game_not_match) {
		timelimit = timelimit + 5;
		top = stof(infokey(world, "k_timetop"));
		if (timelimit > top) timelimit = top;
		tmp = ftos(timelimit);
		bprint_fb(2, "Νατγθ μεξητθ σετ το ");
		bprint_fb(2, tmp);
		bprint_fb(2, " νιξυτεσ\n");
		cvar_set("timelimit", tmp);
	}
};

void() FragsDown =
{
	local string tmp;
	if (match_in_progress || counting_down) return;
	if (!game_not_match) {
		fraglimit = fraglimit - 10;
		if (fraglimit < 0) fraglimit = 0;
		tmp = ftos(fraglimit);
		bprint_fb(2, "Ζςαημινιτ σετ το ");
		bprint_fb(2, tmp);
		bprint_fb(2, "\n");
		cvar_set("fraglimit", tmp);
	} 
};

void() FragsUp =
{
	local string tmp;
	if (match_in_progress || counting_down) return;
	if (!game_not_match) {
		fraglimit = fraglimit + 10;
		if (fraglimit > 100) fraglimit = 100;
		tmp = ftos(fraglimit);
		bprint_fb(2, "Ζςαημινιτ σετ το ");
		bprint_fb(2, tmp);
		bprint_fb(2, "\n");
		cvar_set("fraglimit", tmp);
	}
};

void() ChangeDM =
{
	local string tmp;
	if (match_in_progress || counting_down) return;
	if (!game_not_match) {
		deathmatch = deathmatch + 1;
		if (deathmatch > 6) deathmatch = 1;
		tmp = ftos(deathmatch);
		cvar_set("deathmatch", tmp);
	}
};

void() ChangeTP =
{
	local string tmp;
	if (match_in_progress || counting_down) return;
	if (!game_not_match) {
		teamplay = teamplay + 1;
		if (teamplay > 5) teamplay = 0;
		tmp = ftos(teamplay);
		cvar_set("teamplay", tmp);
	}
};

void() SkillUp =
{
	if (match_in_progress || counting_down) return;
	skill = skill + 1;
	if (skill > 20) skill = 20;
	SetSkill();
};

void() SkillDown =
{
	if (match_in_progress || counting_down) return;
	skill = skill - 1;
	if (skill < 0) skill = 0;
	SetSkill();
};

void(float to, float wcount) bcrlf =
{
	local float i;
	i = 1;
	while(i <= wcount) {
		i = i + 1;
		WriteByte(to, 10);
	}
};

void() print_weap_stats =
{
	local float lg;
	local entity ptarg;
	local string srl;
	if (counting_down) return;
	ptarg = self.owner;
	if (ptarg.h_lg) lg = (ptarg.s_lg / ptarg.h_lg) * 100;
	else lg = 0;
	msg_entity = self.owner;				
	WriteByte(MSG_ONE, SVC_CENTERPRINT);
	if (self.style > 0) bcrlf(MSG_ONE, self.style);
	if (!no_lg) {
		WriteByte(MSG_ONE, _l + 128);
		WriteByte(MSG_ONE, _g + 128);
		WriteByte(MSG_ONE, colon);
		cprint_nr(MSG_ONE, lg);
		WriteByte(MSG_ONE, space);
	}
	WriteByte(MSG_ONE, _r + 128);
	WriteByte(MSG_ONE, _l + 128);
	WriteByte(MSG_ONE, colon);
	srl = ftos(ptarg.h_rl);
	WriteString(MSG_ONE, srl);
};

void() wp_stats_think =
{
	if (self.impulse && self.owner.client_) {
		print_weap_stats();
		self.nextthink = time + 0.3;
	} else remove(self);
};

void() start_print_wp_stats =
{
	local entity wp_stats;
	local float x;

	if (!self.client_ || game_not_match) return;

	if (self.cprint & CP_WPSTATS) {
		sprint_fb(self, 2, "Already running ...\n");
		return;
	}
	self.cprint = self.cprint | CP_WPSTATS;
	wp_stats = spawn();
	x = stof(infokey(self, "lw"));
	wp_stats.style = 12 + floor(x);
	wp_stats.impulse = self.client_;
	wp_stats.classname = "wp_stat";
	wp_stats.owner = self;
	wp_stats.think = wp_stats_think;
	wp_stats.nextthink = time;
};

entity(entity pl) check_wp_stats =
{
	local entity pt;
	pt = find(world, classname, "wp_stat");
	while(pt) {
		if (pt.owner == pl) return pt;
		pt = find(pt, classname, "wp_stat");
	}
	return pt;
};

void() end_print_wp_stats =
{
	local entity pt;
	pt = check_wp_stats(self);
	if (pt) {
		self.cprint = self.cprint - (self.cprint & CP_WPSTATS);
		if (!self.cprint && !counting_down) centerprint(self, "");
		remove(pt);
	} 
};

void() reset_wp_stats =
{
	if (match_in_progress) return;
	self.h_rl = 0;
	self.h_lg = 0;
	self.s_lg = 0;
};

void() turn180 =
{
	self.v_angle_y = self.v_angle_y - 180;
	self.angles = self.v_angle;
	self.fixangle = TRUE;
};

void() look_down =
{
	self.v_angle_x = 80;
	self.angles = self.v_angle;
	self.fixangle = TRUE;
};

void() centerview =
{
	self.v_angle_x = 0;
	self.angles = self.v_angle;
	self.fixangle = TRUE;
};

void() f_jump =
{
	if ((time < self.attack_finished) || self.deadflag) return;
	if (counting_down) {
		not_atf(self);
		return;
	}
	turn180();
	impulse_ = 7;
	W_ChangeWeapon();
	W_Attack();
	turn180();
	self.button0 = 0;
	impulse_ = 0;
};

void() r_jump =
{
	if ((time < self.attack_finished) || self.deadflag) return;
	if (counting_down) {
		not_atf(self);
		return;
	}
	look_down();
	impulse_ = 7;
	W_ChangeWeapon();
	W_Attack();
	centerview();
	self.button0 = 0;
	impulse_ = 0;
};