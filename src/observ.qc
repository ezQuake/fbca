/*
	observ.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
*/

void() ObserverTeleporter =
{
	vec1 = normalize(((test_enemy.absmax + test_enemy.absmin) * 0.5) - self.origin);
	vec2 = normalize(self.velocity);
	if ((vec1 * vec2) <= 0.1)
		return;
	t = find (world, targetname, test_enemy.target);
	makevectors (t.mangle);
	setorigin (self, t.origin + '0 0 22');
	self.angles = t.mangle;
	self.fixangle = TRUE; // turn this way immediately
	self.teleport_time = time + 0.7;
	self.velocity = v_forward * 300;
};

// Spectator functions
// Added Aug11'97 by Zoid <zoid@idsoftware.com>
//
// These functions are called from the server if they exist.
// Note that Spectators only have one think since they movement code doesn't
// track them much. Impulse commands work as usual, but don't call
// the regular ImpulseCommand handler in weapons.qc since Spectators don't
// have any weapons and things can explode.
//
// --- Zoid.

float(float remove_name) RemoveBot;
void() IntermissionThink;
void() ImpulseCommands;
void() LoadPlayer;
void() MakeMOTD;
void() AliasesTime;
void() StuffAliases;

void() join =
{
	stuffcmd_apply(self, "spectator 0; wait\n");
	stuffcmd_apply(self, "reconnect\n");
};

void() observe =
{
	stuffcmd_apply(self, "spectator 1; wait\n");
	stuffcmd_apply(self, "reconnect\n");
};

/*
===========
SpectatorConnect

called when a spectator connects to a server
============
*/
void() SpectatorConnect =
{
	if (scoreboardsize == maxplayers)
		RemoveBot(FALSE);

	self.classname = "spectator";
	self.player = TRUE;

	bprint_fb(1, "Spectator ");
	bprint_fb(1, self.netname);
	bprint_fb(1, " entered the game\n");

	scoreboardsize = scoreboardsize + 1;

	LoadPlayer();

	self.classname = "player";

	SelectSpawnPoint();
	setorigin(self, spawn_pos.origin);
	self.angles = spawn_pos.angles;
	self.fixangle = TRUE;	// turn this way immediately

	self.k_stuff = parm15;

	MakeMOTD();

	if (!self.k_stuff)
		AliasesTime();

	if (intermission_running)
		changelevel (nextmap);
};

/*
===========
SpectatorDisconnect

called when a spectator disconnects from a server
============
*/
void() SpectatorDisconnect =
{
	bprint_fb(1, "Spectator ");
	bprint_fb(1, self.netname);
	bprint_fb(1, " left the game\n");
};

/*
================
SpectatorThink

Called every frame after physics are run
================
*/
void() SpectatorThink =
{
	if (intermission_running)
		IntermissionThink ();

	ImpulseCommands();

	if (!self.k_stuff)
		StuffAliases();

	// look for doors, etc.
	test_enemy = first_teleport;
	while (test_enemy)
	{
		if (vlen(self.origin - (test_enemy.absmin + test_enemy.absmax) * 0.5) <= 75)
		{
			ObserverTeleporter();
			return;
		}
		test_enemy = test_enemy.next;
	}
};