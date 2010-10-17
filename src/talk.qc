/*
	talk.qc

	Copyright (C) 1999-2000 Numb
	Copyright (C) 2000-2007 ParboiL
*/

void(entity me) say_hello;
void(entity at) say_comeback;
void(entity at) say_insult;
void(entity at) say_insult2;
void() say_hello_;
void() say_comeback_;
void() say_insult_;
void() say_insult2_;
void() say_ouchie_;

/*
============
say

============
*/

void(string s) say =
{
	local entity p;

	p = find(world, classname, "player");
	while(p != world) {
		if (p.netname != "") {
			sprint_fb(p, 3, self.netname);
			sprint_fb(p, 3, ": ");
			sprint_fb(p, 3, s);
			sprint_fb(p, 3, "\n");
		}
		p = find(p, classname, "player");
	}
};

void(entity me, string s) say_team2 = 
{
	local entity p;

	p = find(world, classname, "player");
	while(p != world) {
		if (p.netname != "") {
			if (p.realteam == me.realteam) {
				sprint_fb(p, 3, "¨");
				sprint_fb(p, 3, me.netname);
				sprint_fb(p, 3, "): ");
				sprint_fb(p, 3, s);
				sprint_fb(p, 3, "\n");
			} 
		}
		p = find(p, classname, "player");
	}
}; 

/*
==================
say_hello 
==================
*/

void(entity me) say_hello =
{
	local entity talk;
	local float r;
	r = random();
	if (me.chat_time > time)
		return; 
	me.chat_time = time + 12;
	r = 3 + (r * 3);
	talk = spawn();
	talk.owner = me;
	talk.frogbot_nextthink = time + r;
	talk.nextthink = talk.frogbot_nextthink;
	talk.think = say_hello_;
};

/*
==================
say_comeback 
==================
*/

void(entity at) say_comeback =
{
	local entity talk;
	local float r;
	if (!at.frogbot) 
		return;
	r = random();
	if (at.chat_time > time)
		return; 
	at.chat_time = time + 12;
	r = r * 6;
	talk = spawn();
	talk.owner = at;
	talk.frogbot_nextthink = time + r;
	talk.nextthink = talk.frogbot_nextthink;
	talk.think = say_comeback_;
};

/*
==================
say_insult 
==================
*/

void(entity at) say_insult =
{
	local entity talk;
	local float r;
	if (!at.frogbot) 
		return;
	r = random();
	if (at.chat_time > time)
		return; 
	at.chat_time = time + 12;
	r = r * 6;
	talk = spawn();
	talk.owner = at;
	talk.frogbot_nextthink = time + r;
	talk.nextthink = talk.frogbot_nextthink;
	talk.think = say_insult_;
};

/*
==================
say_insult2
==================
*/

void(entity at) say_insult2 =
{
	local entity talk;
	local float r;
	if (!at.frogbot) 
		return;
	r = random();
	if (at.chat_time > time)
		return; 
	at.chat_time = time + 12;
	r = r * 6;
	talk = spawn();
	talk.owner = at;
	talk.frogbot_nextthink = time + r;
	talk.nextthink = talk.frogbot_nextthink;
	talk.think = say_insult2_;
};

/*
==================
say_ouchie 
==================
*/

void(entity tg) say_ouchie =
{
	local entity talk;
	local float r;
	if (!tg.frogbot) 
		return;
	r = random();
	if (tg.chat_time > time)
		return; 
	tg.chat_time = time + 12;
	talk = spawn();
	talk.owner = tg;
	talk.frogbot_nextthink = time + r;
	talk.nextthink = talk.frogbot_nextthink;
	talk.think = say_ouchie_;
};

/*
==================
say_hello_
==================
*/

void() say_hello_ =
{
	local string txt;
	local entity ent;
	local float r;
	r = random();
	if (r < 0.1) 
		txt = "hi";
	else if (r < 0.3) 
		txt = "lo";
	else if (r < 0.5) 
		txt = ":)";
	else if (r < 0.7) 
		txt = "hiya";
	else if (r < 0.9) 
		txt = "hi :)";
	ent = self;
	self = self.owner;
	if (self.netname != "")
		say(txt);		
	self = ent;
	remove_self();
};


/*
==================
say_insult_
==================
*/

void() say_insult_ =
{
	local string txt;
	local entity ent;
	line_one = line_one + 1;
	if (line_one > 20)
		line_one = 1;
	if (line_one == 1)
		txt = ":)";
	else if (line_one == 2)
		txt = "lol :)";
	else if (line_one == 3)
		txt = ":)";
	else if (line_one == 4)
		txt = "hehe";
	else if (line_one == 5)
		txt = "say hello to satan :)";
	else if (line_one == 6)
		txt = ":)";
	else if (line_one == 7)
		txt = "fetch me some more rockets";
	else if (line_one == 8)
		txt = "tired yet?";
	else if (line_one == 9)
		txt = "sucker :)";
	else if (line_one == 10)
		txt = "try harder!";
	else if (line_one == 11)
		txt = "lol!";
	else if (line_one == 12)
		txt = ":)";
	else if (line_one == 13)
		txt = "you should be taking notes";
	else if (line_one == 14)
		txt = "you're so cute when you're angry!";
	else if (line_one == 15)
		txt = "man, you're breaking my heart :)";
	else if (line_one == 16)
		txt = "say hello to god :)";
	else if (line_one == 17)
		txt = "hehe";
	else if (line_one == 18)
		txt = "nice :)";
	else if (line_one == 19)
		txt = "heh";
	else if (line_one == 20)
		txt = "lam :)";
	ent = self;
	self = self.owner;
	if (self.netname != "")
		say(txt);		
	self = ent;
	remove_self();
};

/*
==================
say_insult2_
==================
*/

void() say_insult2_ =
{
	local string txt;
	local entity ent;
	line_two = line_two + 1;
	if (line_two > 20)
		line_two = 1;
	if (line_two == 1)
		txt = "alright then!";
	else if (line_two == 2)
		txt = "next time... run away";
	else if (line_two == 3)
		txt = "taste the pain!";
	else if (line_two == 4)
		txt = "heh";
	else if (line_two == 5)
		txt = "suck on it!";
	else if (line_two == 6)
		txt = "bwwaahahaha!";
	else if (line_two == 7)
		txt = "spanked you down";
	else if (line_two == 8)
		txt = "hehehe";
	else if (line_two == 9)
		txt = ":)";
	else if (line_two == 10)
		txt = "the agony of defeat...";
	else if (line_two == 11)
		txt = "suck it down!";
	else if (line_two == 12)
		txt = "ahem";
	else if (line_two == 13)
		txt = "single player quake is fun, no?";
	else if (line_two == 14)
		txt = "eat that, bastard!";
	else if (line_two == 15)
		txt = "open up, big boy!";
	else if (line_two == 16)
		txt = "die, weasel!";
	else if (line_two == 17)
		txt = "over here!";
	else if (line_two == 18)
		txt = "buh-bye";
	else if (line_two == 19)
		txt = "smackage";
	else if (line_two == 20)
		txt = "spanking";
	ent = self;
	self = self.owner;
	if (self.netname != "")
		say(txt);		
	self = ent;
	remove_self();
};

/*
==================
say_comeback_
==================
*/

void() say_comeback_ =
{
	local string txt;
	local entity ent;
	line_three = line_three + 1;
	if (line_three > 20)
		line_three = 1;
	if (line_three == 1)
		txt = "Hehehe";
	else if (line_three == 2)
		txt = ":)";
	else if (line_three == 3)
		txt = "lol :)";
	else if (line_three == 4)
		txt = ":)";
	else if (line_three == 5)
		txt = "haw haw :)";
	else if (line_three == 6)
		txt = "can i get you a tissue?";
	else if (line_three == 7)
		txt = "what's up now, foo?!";
	else if (line_three == 8)
		txt = "like i was saying";
	else if (line_three == 9)
		txt = "this could develop into something beautiful";
	else if (line_three == 10)
		txt = "want some more of this?";
	else if (line_three == 11)
		txt = "oooops :)";
	else if (line_three == 12)
		txt = "it's over loser";
	else if (line_three == 13)
		txt = "revenge is sweet";
	else if (line_three == 14)
		txt = "now i'm gonna smoke yer azz";
	else if (line_three == 15)
		txt = "yadda, yadda...";
	else if (line_three == 16)
		txt = "he who laughs last, laughs the loudest";
	else if (line_three == 17)
		txt = "hehe";
	else if (line_three == 18)
		txt = "not so tough now, are ya?";
	else if (line_three == 19)
		txt = "keep yer distance, scruffy";
	else if (line_three == 20)
		txt = "mouse in one hand, cup of tea in the other";
	ent = self;
	self = self.owner;
	if (self.netname != "")
		say(txt);		
	self = ent;
	remove_self();
};

/*
==================
say_ouchie_
==================
*/

void() say_ouchie_ =
{
	local string txt;
	local entity ent;
	line_four = line_four + 1;
	if (line_four > 15)
		line_four = 1;
	if (line_four == 1)
		txt = ":(";
	else if (line_four == 2)
		txt = "):D";
	else if (line_four == 3)
		txt = "hmm";
	else if (line_four == 4)
		txt = "very nice";
	else if (line_four == 5)
		txt = "rofl";
	else if (line_four == 6)
		txt = "doh";
	else if (line_four == 7)
		txt = "lol";
	else if (line_four == 8)
		txt = ":)";
	else if (line_four == 9)
		txt = "ooohh";
	else if (line_four == 10)
		txt = "very good";
	else if (line_four == 11)
		txt = "cool";
	else if (line_four == 12)
		txt = ":((";
	else if (line_four == 13)
		txt = "fucking...";
	else if (line_four == 14)
		txt = "fuck";
	else if (line_four == 15)
		txt = "nice";
	ent = self;
	self = self.owner;
	if (self.netname != "")
		say(txt);		
	self = ent;
	remove_self();
};

/*
==================
CheckCombatChat
==================
*/
void(entity at, entity tg) CheckCombatChat =
{
	if (tg != at)
	if (random() > 0.675) {
		if ((at.frags < (tg.frags - 5)) && (at.frags > 5)) {
			say_comeback(at);
		} else if (fabs(at.frags - tg.frags) < 7) {
			say_insult(at);
		} else if (fabs(at.frags - tg.frags) > 7) {
			say_insult2(at);
		} else { 
			say_ouchie(tg);
		}
	}
};

/*
===============
Bot wish good luck during countdown.
===============
*/
void() bot_say_gl =
{
	local float r;
	self = world;
	while (self = find(self, classname, "frogbot"))
	if (!(self.reporteditems & IT_KEY1)) {
		r = random();
		if (r < 0.3) {
			self.reporteditems = self.reporteditems + IT_KEY1;
			if (self.netname != "" && !match_in_progress) {
				r = random();
				if (r < 0.3) say("gl");
				else if (r < 0.4) say("good luck");
				else if (r < 0.5) say("have fun lads");
				else if (r < 0.6) say("i hope your spawns suck :)");
				else if (r < 0.7) say("gl");
				else if (r < 0.8) say("lets do it :)");
				else if (r < 0.9) say("gl!");
				else say("hf");
				return;
			}
		}
	}
};

/*
===============
Bot say good game during end countdown.
===============
*/
void() bot_say_gg =
{
	local float r;
	self = world;
	while (self = find(self, classname, "frogbot"))
	if (self.frags > 10)
	if (!(self.reporteditems & IT_KEY2)) {
		r = random();
		if (r < 0.3) {
			self.reporteditems = self.reporteditems + IT_KEY2;
			if (self.netname != "") {
				r = random();
				if (r < 0.3) say("gg");
				else if (r < 0.4) say("good game");
				else if (r < 0.5) say("cool :)");
				else if (r < 0.6) say("gg!");
				else if (r < 0.7) say("wooooop!");
				else if (r < 0.8) say("nice game");
				else if (r < 0.9) say("gg");
				else say("gg");
				return;
			}
		} 
	}
};

/*
===============
Team report.
===============
*/
void(entity me) say_report =
{
	local entity p;
	local string at, wt;
	local float f1;

	if(me.items & IT_ARMOR1) at = "ga:";
	if(me.items & IT_ARMOR2) at = "ya:";
	if(me.items & IT_ARMOR3) at = "ra:";
	wt = "axe:";
	f1 = 0;
	if (me.items & IT_SHOTGUN) {
		wt = "sg:";
		f1 = me.ammo_shells;
	}
	if (me.items & IT_NAILGUN) {
		wt = "ng:";
		f1 = me.ammo_nails;
	}
	if (me.items & IT_SUPER_SHOTGUN) {
		wt = "ssg:";
		f1 = me.ammo_shells;
	}
	if (me.items & IT_SUPER_NAILGUN) {
		wt = "sng:";
		f1 = me.ammo_nails;
	}
	if (me.items & IT_GRENADE_LAUNCHER) {
		wt = "gl:";
		f1 = me.ammo_rockets;
	}
	if (me.items & IT_LIGHTNING) {
		wt = "lg:";
		f1 = me.ammo_cells;
	}
	if (me.items & IT_ROCKET_LAUNCHER) {
		wt = "rl:";
		f1 = me.ammo_rockets;
	}
	p = find(world, classname, "player");
	while(p != world) {
		if (p.netname != "") {
			if (p.realteam == me.realteam) {
					sprint_fb(p, 3, "¨");
					sprint_fb(p, 3, me.netname);
					sprint_fb(p, 3, "): ");
				if (me.armorvalue != 0) {
					sprint_fb(p, 3, at);
					sprint_ftos(p, 3, me.armorvalue);
				} else sprint_fb(p, 3, "a:0");
				sprint_fb(p, 3, "  h:");
					sprint_ftos(p, 3, me.health);
					sprint_fb(p, 3, "  ");
					sprint_fb(p, 3, wt);
				sprint_ftos(p, 3, f1);
				if (me.items & IT_INVISIBILITY) sprint_fb(p, 3, "  …εωεσ…‘");
				if (me.items & IT_INVULNERABILITY) sprint_fb(p, 3, "  ……‘");
				if (me.items & IT_QUAD) sprint_fb(p, 3, "  …ρυαδ‘");
				sprint_fb(p, 3, "\n");
			}
		}
		p = find(p, classname, "player");
	}
};

void(entity me) teamreport = 
{
	if (me.health > 0 && teamplay && !game_disable_autoreport)
		say_report(me); 
};

void(entity me, float nt) teamreport2 =
{
	if (teamplay && !game_disable_autoreport)
	if ((me.player && a_rep) || me.frogbot) {
		if (!nt) {
			if (q_gamer != world)
			if (last_say_q != me.realteam)
			if (VisibleEntity(q_gamer)) 
			if (q_gamer.realteam != me.realteam) { 
				say_team2(me, "‡‡ ENEMY QUAD ‡‡");
				last_say_q = me.realteam;
			}
			if (p_gamer != world)
			if (last_say_p != me.realteam)
			if (VisibleEntity(p_gamer)) 
			if (p_gamer.realteam != me.realteam) {
					say_team2(me, "‡‡ ENEMY PENT ‡‡");
					last_say_p = me.realteam;
			}
			if (i_gamer != world)
			if (last_say_i != me.realteam)
			if (VisibleEntity(i_gamer)) 
			if (i_gamer.realteam != me.realteam) {
				say_team2(me, "‡‡ ENEMY INVISIBLE ‡‡");
				last_say_i = me.realteam;
			}
		} else if (nt == 1) {
			say_team2(me, "†† took ga");
		} else if (nt == 2) {
			say_team2(me, "†† took ya");
		} else if (nt == 3) {
			say_team2(me, "†† took ra");
		} else if (nt == 4) {
			say_team2(me, "†† took mega");
		} else if (nt == 5) {
			say_team2(me, "‰‰ took gl");
		} else if (nt == 6) {
			say_team2(me, "‰‰ took rl");
		} else if (nt == 7) {
			say_team2(me, "‰‰ took lg");
		} else if (nt == 8) {
			say_team2(me, "‰‰ took gl pack");
		} else if (nt == 9) {
			say_team2(me, "‰‰ took rl pack");
		} else if (nt == 10) {
			say_team2(me, "‰‰ took lg pack");
		} else if (nt == 11) {
			say_team2(me, "‡‡ TEAM QUAD ‡‡");
			q_gamer = me;
		} else if (nt == 12) {
			say_team2(me, "‡‡ TEAM PENT ‡‡");
			p_gamer = me;
		} else if (nt == 13) {
			say_team2(me, "‡‡ TEAM INVISIBLE ‡‡");
			i_gamer = me;
		} else if (nt == 14) {
			say_team2(me, "‡‡ QUAD in 30 ‡‡");
			last_say_q = 0;
			q_gamer = world; 
		} else if (nt == 15) {
			say_team2(me, "‡‡ PENT EXPIRED ‡‡");
			last_say_p = 0;
			p_gamer = world; 
		} else if (nt == 16) {
			say_team2(me, "‡‡ RING GONE ‡‡");
			last_say_i = 0;
			i_gamer = world;
		} else if (nt == 17) {
			say_team2(me, "‡‡ LOSE QUAD ‡‡");
			last_say_q = 0;
			q_gamer = world; 
		} else if (nt == 18) {
			say_team2(me, "‡‡ LOSE RING ‡‡");
			last_say_i = 0;
			i_gamer = world;
		}
	}
};