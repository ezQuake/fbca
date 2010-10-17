/*
	motd.qc

	Copyright (C) 2000-2007 ParboiL
*/

void() PrintMOTD =
{
	local string s1, s2;
	s1 = infokey(world, "k_motd1");
	s2 = infokey(world, "k_motd2");
	if (s1 == "") s1 = string_null;
	if (s2 == "") s2 = string_null;
	if (self.attack_finished < time || k_shutdown) {
		remove(self);
		k_shutdown = 0;
		return;
	}
	if (self.attack_finished > time + 6) centerprint5(self.owner, "Welcome to\n\n", s1, "\n", s2, "\n\n€‚\n");
	else centerprint5(self.owner, "Welcome to\n\n", s1, "\n", s2, "\n\n€‚\n\nRunning Æâãá “®’“ëô final by ÐáòboiL\n\nbased on Ëïíâáô Ôåáíó ”®”“\n");
	self.nextthink = time + 0.7;
};

void() MakeMOTD =
{
	local entity motd;
	motd = spawn();
	motd.classname = "motd";
	motd.owner = self;
	motd.think = PrintMOTD;
	motd.nextthink = time + 0.5;
	motd.attack_finished = time + 7;
};

void() AliasesTime =
{
	self.alias1time = time + 1;
	self.alias2time = time + 2;
	self.alias3time = time + 3;
	self.alias4time = time + 4;
};

void() StuffAliases =
{
	if (self.alias1time)
	if (time >= self.alias1time)
	{
		self.alias1time = 0;
		aliases1();
		sprint_fb(self, 2, "Maps downloaded\n");
	}
	if (self.alias2time)
	if (time >= self.alias2time)
	{
		self.alias2time = 0;
		aliases2();
	}
	if (self.alias3time)
	if (time >= self.alias3time)
	{
		self.alias3time = 0;
		aliases3();
	}
	if (self.alias4time)
	if (time >= self.alias4time)
	{
		self.alias4time = 0;
		self.k_stuff = 1;
		aliases4();
		sprint_fb(self, 2, "Commands downloaded\n");
	}
};