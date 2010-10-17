/*
	defs.qc

	global definitions

	Copyright (C) 1996-1997 Id Software, Inc.
	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
*/

/*
==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================
*/

//
// system globals
//
entity		self;
entity		other;
entity		world;
float			time;
float			frametime;

entity		newmis;	// if this is set, the entity that just
								// run created a new missile that should
								// be simulated immediately


float		force_retouch;	// force all entities to touch triggers
								// next frame. this is needed because
								// non-moving things don't normally scan
								// for triggers, and when a trigger is
								// created (like a teleport trigger), it
								// needs to catch everything.
								// decremented each frame, so set to 2
								// to guarantee everything is touched
string		mapname;

float			serverflags;	// propagated from level to level, used to
								// keep track of completed episodes
float			total_secrets;
float			total_monsters;

float			found_secrets;	// number of secrets found
float			killed_monsters;	// number of monsters killed


// spawnparms are used to encode information about clients across server
// level changes
float parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;

//
// global variables set by built in functions
//
vector v_forward, v_up, v_right;	// set by makevectors()
	
// set by traceline / tracebox
float	trace_allsolid;
float	trace_startsolid;
float	trace_fraction;
vector	trace_endpos;
vector	trace_plane_normal;
float	trace_plane_dist;
entity	trace_ent;
float	trace_inopen;
float	trace_inwater;

entity	msg_entity;	// destination of single entity writes

//
// required prog functions
//
void() main;	// only for testing

void() StartFrame;

void() PlayerPreThink;
void() PlayerPostThink;

void() ClientKill;
void() ClientConnect;
void() PutClientInServer;	// call after setting the parm1... parms
void() ClientDisconnect;

void() SetNewParms;	// called when a client first connects to
									// a server. sets parms so they can be
									// saved off for restarts

void() SetChangeParms;	// call to set parms for self so they can
									// be saved for a level transition


//================================================
void	end_sys_globals;	// flag for structure dumping
//================================================

/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float modelindex;	// *** model index in the precached list
.vector absmin, absmax; // *** origin + mins / maxs

.float ltime;	// local time for entity
.float lastruntime;	// *** to allow entities to run out of sequence

.float movetype;
.float solid;

.vector origin;	// ***
.vector oldorigin;	// ***
.vector velocity;
.vector angles;
.vector avelocity;

.string classname;	// spawn function
.string model;
.float frame;
.float skin;
.float effects;

.vector mins, maxs;	// bounding box extents reletive to origin
.vector size;	// maxs - mins

.void() touch;
.void() use;
.void() think;
.void() blocked;	// for doors or plats, called when can't push other


.float nextthink;
.entity groundentity;



// stats
.float health;
.float frags;
.float weapon;	// one of the IT_SHOTGUN, etc flags
.string weaponmodel;
.float weaponframe;
.float currentammo;
.float ammo_shells, ammo_nails, ammo_rockets, ammo_cells;

.float items;	// bit flags

.float takedamage;
.entity chain;
.float deadflag;

.vector view_ofs;	// add to origin to get eye point


.float button0;	// fire
.float button1;	// use
.float button2;	// jump

.float impulse;	// weapon changes

.float fixangle;
.vector v_angle;	// view / targeting angle for players, range -180 to 180

.string netname;

.entity enemy;

.float flags;

.float colormap;
.float team;

.float max_health;	// players maximum health is stored here

.float teleport_time;	// don't back up

.float armortype;	// save this fraction of incoming damage
.float armorvalue;

.float waterlevel;	// 0 = not in, 1 = feet, 2 = wast, 3 = eyes
.float watertype;	// a contents value

.float ideal_yaw;
.float yaw_speed;

.entity aiment;

.entity goalentity;	// a movetarget or an enemy

.float spawnflags;

.string target;
.string targetname;

// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float dmg_take;
.float dmg_save;
.entity dmg_inflictor;

.entity owner;	// who launched a missile
.vector movedir;	// mostly for doors, but also used for waterjump

.string message;	// trigger messages

.float sounds;	// either a cd track number or sound number

.string noise, noise1, noise2, noise3;	// contains names of wavs to play

//================================================
void end_sys_fields;	// flag for structure dumping
//================================================


/*
==============================================================================

				VARS NOT REFERENCED BY C CODE

==============================================================================
*/


//================================================

//
// quakeed fields
//
.string		wad;
.string 		map;
.float		worldtype;	// 0=medieval 1=metal 2=base

.string		killtarget;
.float		light_lev;		// not used by game, but parsed by light util
.float		style;
.float		count;			// for counting triggers

.vector		mangle;			// angle at start
.float		speed;
.float		wait;
.float		delay;
.float		dmg;			// damage done by door when hit
.float		lip;
.float		height;

.string		mdl;


.void start_remove_fieldnames_;

//
// constants
//

float FALSE					= 0;
float TRUE					= 1;

// edict.flags
float	FL_FLY				= 1;
float	FL_SWIM				= 2;
float	FL_INWATER				= 16;		// for enter / leave water splash
//float	FL_GODMODE			= 64;		// player cheat
//float	FL_NOTARGET			= 128;	// player cheat
float	FL_ITEM				= 256;	// extra wide size for bonus items
float	FL_ONGROUND				= 512;	// standing on something
float	FL_PARTIALGROUND			= 1024;	// not all corners are valid
float	FL_WATERJUMP			= 2048;	// player jumping out of water
float	FL_JUMPRELEASED			= 4096;	// for jump debouncing
float FL_BODYQUE				= 262144;


// 4194304;
// 12582911;
// 8388608;
// 8388607;

float FL_ONGROUND_PARTIALGROUND	= 1536;
float FL_NOT_JUMPRELEASED		= 16773119;
float FL_NOT_ONGROUND			= 16776703;

.float client_;
.float player;
.float frogbot;
.float fl_thud;	// for thud removal
.float fl_ontrain;	// for Frogbot train movement
.float ready;
.float p_break;
float time1;
float e_break;
float counting_down;
float match_in_progress;
float marker_time;
float next_marker_time;
float hazard_time;
float next_hazard_time;

// spawnflags values for players
float START_SKILL			= 1;
float START_SKIN			= 2;
float START_SHIRT			= 3;
float START_PANTS			= 4;
float START_TEAMSHIRT		= 5;
float START_TEAMPANTS		= 6;
float START_TEAMPLAY		= 7;
float START_DEATHMATCH		= 8;
float START_TIMELIMIT		= 9;
float START_FRAGLIMIT		= 10;
float START_LINES			= 11;
float START_MSG			= 18;
float START_BOTS			= 12;
float START_ADMIN1		= 15;
float START_ADMIN2		= 16;
float START_ADMIN3		= 17;




//---------------------------
float IMP_START1		= 14;			// command value, during loading
float IMP_SKILL		= 14;
float IMP_SKIN		= 15;
float IMP_SHIRT		= 16;
float IMP_PANTS		= 17;
float IMP_TEAMSHIRT	= 18;
float IMP_TEAMPANTS	= 19;
float IMP_END1		= 20;
//---------------------------
float IMP_LINES		= 24;
//---------------------------
float IMP_ADDBOT		= 25;			// requires admin, end of loading
float IMP_ADD2BOTS	= 26;
float IMP_ADD3BOTS	= 27;
float IMP_ADD4BOTS	= 28;
float IMP_ADDBOT0		= 29;
float IMP_ADDBOT1		= 30;
float IMP_ADDBOT2		= 31;
float IMP_ADDBOT3		= 32;
float IMP_ADDBOT4		= 33;
float IMP_ADDBOT5		= 34;
float IMP_ADDBOT6		= 35;
float IMP_ADDBOT7		= 36;
float IMP_ADDBOT8		= 37;
float IMP_ADDBOT9		= 38;
float IMP_ADDBOT10	= 39;
float IMP_ADDBOT11	= 40;
float IMP_ADDBOT12	= 41;
float IMP_ADDBOT13	= 42;
float IMP_END2		= 43;
//---------------------------
float IMP_MSG		= 44;			// command value, not in loading
float IMP_BOTS		= 45;
//---------------------------
float IMP_ADMIN		= 46;
//---------------------------
float IMP_TIME		= 47;
float IMP_RULES		= 48;
float IMP_SETSKIN		= 49;
float IMP_FLASH		= 50;
//---------------------------
float IMP_HIDE		= 51;			// requires admin, not in loading
float IMP_REMOVEBOT	= 52;
float IMP_REMOVEALLBOTS	= 53;
float IMP_LAVACHEAT	= 54;
float IMP_FRAMERATE	= 55;
float IMP_POWERUP		= 56;
float IMP_RUNE		= 57;
float IMP_READY		= 58;
float IMP_MATCH		= 59;
float IMP_OVERTIME	= 60;
float IMP_REPORT		= 61;
float IMP_AUTOREPORT	= 62;
float IMP_DROPWEAP	= 63;
float IMP_AUTOSTEAMS	= 64;
float IMP_BOTCHAT		= 65;
float IMP_WHO		= 66;
float IMP_RL_PREF		= 67;
float IMP_LG_PREF		= 68;
float IMP_RUNE_RJ		= 69;
float IMP_NOSKINS		= 70;
//---------------------------
float IMP_RANDOM		= 250;
float IMP_IMPULSE_0	= 255;
//---------------------------


// edict.movetype values
float	MOVETYPE_NONE			= 0;	// never moves
float	MOVETYPE_WALK			= 3;	// players only
float	MOVETYPE_STEP			= 4;	// discrete, not real time unless fall
float	MOVETYPE_FLY			= 5;
float	MOVETYPE_TOSS			= 6;	// gravity
float	MOVETYPE_PUSH			= 7;	// no clip to world, push and crush
float	MOVETYPE_NOCLIP			= 8;
float	MOVETYPE_FLYMISSILE		= 9;	// fly with extra size against monsters
float	MOVETYPE_BOUNCE			= 10;
float	MOVETYPE_BOUNCEMISSILE		= 11;	// bounce with extra size

// edict.solid values
float	SOLID_NOT				= 0;	// no interaction with other objects
float	SOLID_TRIGGER			= 1;	// touch on edge, but not blocking
float	SOLID_BBOX				= 2;	// touch on edge, block
float	SOLID_SLIDEBOX			= 3;	// touch on edge, but not an onground
float	SOLID_BSP				= 4;	// bsp clip, touch on edge, block

// deadflag values

float	DEAD_NO				= 0;
float	DEAD_DYING				= 1;
float	DEAD_DEAD				= 2;
float	DEAD_RESPAWNABLE			= 3;

// takedamage values

float	DAMAGE_NO				= 0;
float	DAMAGE_YES				= 1;
float	DAMAGE_AIM				= 2;

// items
float	IT_AXE				= 4096;
float	IT_SHOTGUN				= 1;
float	IT_SUPER_SHOTGUN			= 2;
float	IT_NAILGUN				= 4;
float	IT_SUPER_NAILGUN			= 8;
float	IT_GRENADE_LAUNCHER		= 16;
float	IT_ROCKET_LAUNCHER		= 32;
float	IT_LIGHTNING			= 64;
float IT_EITHER_NAILGUN			= 12;
float IT_NAILGUN_ROCKET			= 44;
float IT_VELOCITY				= 60;
float IT_CONTINUOUS			= 76;
float IT_AXE_SHOTGUN			= 4097;
float IT_ALL_BUT_GRENADE		= 4207;
float IT_ALL				= 4223;

float	IT_SHELLS				= 256;
float	IT_NAILS				= 512;
float	IT_ROCKETS				= 1024;
float	IT_CELLS				= 2048;
float IT_NOT_AMMO				= 16773375;

float	IT_ARMOR1				= 8192;
float	IT_ARMOR2				= 16384;
float	IT_ARMOR3				= 32768;
float IT_ARMOR				= 57344;
float IT_SUPERHEALTH= 65536;
float IT_NOT_ARMOR			= 16719871;

float	IT_KEY1				= 131072;
float	IT_KEY2				= 262144;

float	IT_INVISIBILITY			= 524288;
float	IT_INVULNERABILITY		= 1048576;
float	IT_SUIT				= 2097152;
float	IT_QUAD				= 4194304;

float	IT_INVULNERABILITY_QUAD		= 5242880;
float IT_POWERUP				= 7864320;
float IT_ARMOR3_INVULNERABILITY	= 1081344;

float	IT_NOT_INVISIBILITY		= 16252927;
float IT_NOT_INVULNERABILITY		= 15728639;
float IT_NOT_SUIT				= 14680063;
float	IT_NOT_QUAD				= 12582911;

float	IT_SIGIL1				= 268435456;
float	IT_SIGIL2				= 536870912;
float	IT_SIGIL3				= 1073741824;
float	IT_SIGIL4				= 2147483648;

float ITEM_RUNE1_FLAG		= 1;
float ITEM_RUNE2_FLAG		= 2;
float ITEM_RUNE3_FLAG		= 4;
float ITEM_RUNE4_FLAG		= 8;
float ITEM_RUNE_MASK		= 15;

// point content values

float	CONTENT_EMPTY			= -1;
float	CONTENT_SOLID			= -2;
float	CONTENT_WATER			= -3;
float	CONTENT_SLIME			= -4;
float	CONTENT_LAVA			= -5;
float	CONTENT_SKY				= -6;

float	STATE_TOP		= 0;
float	STATE_BOTTOM	= 1;
float	STATE_UP		= 2;
float	STATE_DOWN		= 3;

float TE_BLOOD		= 12;
float TE_LIGHTNINGBLOOD = 13;

vector	VEC_ORIGIN = '0 0 0';
vector	VEC_HULL_MIN = '-16 -16 -24';
vector	VEC_HULL_MAX = '16 16 32';

vector	VEC_HULL2_MIN = '-32 -32 -24';
vector	VEC_HULL2_MAX = '32 32 64';

// protocol bytes
float SVC_SETVIEWPORT		= 5;
float MSG_PRINT			= 8;
float MSG_STUFFCMD		= 9;
float MSG_UPDATENAME		= 13;
float MSG_UPDATEFRAGS		= 14;
float MSG_UPDATECOLORS		= 17;
float	SVC_TEMPENTITY		= 23;
float SVC_CENTERPRINT		= 26;
float	SVC_KILLEDMONSTER		= 27;
float	SVC_FOUNDSECRET		= 28;
float	SVC_INTERMISSION		= 30;
float	SVC_CDTRACK			= 32;
float SVC_SMALLKICK		= 34;
float SVC_BIGKICK			= 35;
float SVC_UPDATEPING		= 36;
float SVC_UPDATETIME		= 37;
float SVC_MUZZLEFLASH		= 39;
float SVC_UPDATEUSERINFO	= 40;
float SVC_PLAYERINFO		= 42;
float SVC_SETINFO			= 51;
float	TE_SPIKE		= 0;
float	TE_SUPERSPIKE	= 1;
float	TE_GUNSHOT		= 2;
float	TE_EXPLOSION	= 3;
float	TE_LIGHTNING2	= 6;
float	TE_LAVASPLASH	= 10;
float	TE_TELEPORT		= 11;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
float	CHAN_AUTO		= 0;
float	CHAN_WEAPON		= 1;
float	CHAN_VOICE		= 2;
float	CHAN_ITEM		= 3;
float	CHAN_BODY		= 4;
float	CHAN_NO_PHS_ADD = 8;	// ie: CHAN_BODY+CHAN_NO_PHS_ADD
float	ATTN_NONE		= 0;
float	ATTN_NORM		= 1;
float	ATTN_IDLE		= 2;
float	ATTN_STATIC		= 3;

// entity effects

float	EF_MUZZLEFLASH 	= 2;
float	EF_DIMLIGHT 	= 8;

float NOT_EF_DIMLIGHT	= 16777207;

// GLQuakeWorld Stuff
float EF_BLUE		= 64;	// Blue Globe effect for Quad
float	EF_RED		= 128;	// Red Globe effect for Pentagram
float EF_DIMLIGHT_BLUE	= 72;
float EF_DIMLIGHT_RED	= 136;
float NOT_EF_BLUE		= 16777151;
float NOT_EF_RED		= 16777087;

// messages
float	MSG_BROADCAST		= 0;		// unreliable to all
float	MSG_ONE			= 1;		// reliable to one (msg_entity)
float	MSG_ALL			= 2;		// reliable to all

// message levels
float PRINT_LOW		= 0;	// pickup messages
float PRINT_MEDIUM	= 1;	// death messages
float PRINT_HIGH	= 2;	// critical messages
float MSG_MULTICAST = 4;	// for multicast() call

// multicast sets
float MULTICAST_PHS = 1;	// within hearing
float MULTICAST_PVS = 2;	// within sight
float MAX_SKILL = 20;
float MAX_TEAMPLAY = 5;
float MAX_DEATHMATCH = 6;

float enter = 10;
float space = 32;
float quote = 34;
float minus = 45;
float _0 = 48;
float _1 = 49;
float _2 = 50;
float _3 = 51;
float _4 = 52;
float _5 = 53;
float _6 = 54;
float _7 = 55;
float _8 = 56;
float _9 = 57;
float colon = 58;
float _A = 65;
float _B = 66;
float _C = 67;
float _D = 68;
float _E = 69;
float _F = 70;
float _G = 71;
float _H = 72;
float _I = 73;
float _J = 74;
float _K = 75;
float _L = 76;
float _M = 77;
float _N = 78;
float _O = 79;
float _P = 80;
float _Q = 81;
float _R = 82;
float _S = 83;
float _T = 84;
float _U = 85;
float _V = 86;
float _W = 87;
float _X = 88;
float _Y = 89;
float _Z = 90;
float _a = 97;
float _b = 98;
float _c = 99;
float _d = 100;
float _e = 101;
float _f = 102;
float _g = 103;
float _h = 104;
float _i = 105;
float _j = 106;
float _k = 107;
float _l = 108;
float _m = 109;
float _n = 110;
float _o = 111;
float _p = 112;
float _q = 113;
float _r = 114;
float _s = 115;
float _t = 116;
float _u = 117;
float _v = 118;
float _w = 119;
float _x = 120;
float _y = 121;
float _z = 122;
float tilde = 126;
float backspace = 127;

float CLIENTKILL = 11;


//================================================

//
// globals
//
float	gameover;		// set when a rule exits

entity	newmis;			// launch_spike sets this after spawning it

entity	activator;		// the entity that activated a trigger or brush

entity attacker;
float	framecount;

float skill;
float old_skill;
float skill_;

float temp1;

string str;

float teamplay;
float deathmatch;
float next_teamplay;
float next_deathmatch;

.float teamflag;
float team_index;

float TEAM_TOTAL_HEALTH_PROTECT =	1;	// No health damage from friendly fire (including self)
float TEAM_FRAG_PENALTY =		2;	// One frag penalty for killing teammate
float TEAM_HEALTH_PROTECT =		3;	// No health damage from friendly fire (excluding self)
float TEAM_HEALTH_MASK = 		3;
float TEAM_ARMOR_PROTECT =		4;	// No armor or health damage from friendly fire

float modelindex_player;
float	modelindex_eyes;
float modelindex_head;

entity runespawn;

//
// player only fields
//

.float oldwaterlevel;
.float oldwatertype;
.float realteam;
.float score_pos;

.float deaths;
.float efficiency;


float realteam_;

.float healamount, healtype;
.float ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
.float total_armor;

float current_team;
float current_frogbot;

.void() th_pain;
.void() th_die;

.float walkframe;

.float 		attack_finished;
.float		pain_finished;

.float		invincible_finished;
.float		invisible_finished;
.float		super_damage_finished;
.float		radsuit_finished;

.float		invincible_time, invincible_sound;
.float		invisible_time, invisible_sound;
.float		super_time, super_sound;
.float		regeneration_sound;//RUNE: Elder Magic
.float		haste_sound;//RUNE: Hell Magic
.float		rad_time;
.float		fly_sound;

float			axhitme;
float			axhitme_;

.float		jump_flag;		// player jump flag
.float		swim_flag;		// player swimming sound flag
.float		air_finished;	// when time > air_finished, start drowning
.float		bubble_count;	// keeps track of the number of bubbles
string		deathtype;		// keeps track of how the player died

.float 		player_flag;	// misc flags (skins, etc.)
.float		regen_time;		// time to next regen

float healthplay;
float armorplay;

float gamemode;
float new_gamemode;
float game_disable_powerups;
float game_enable_runes;
float game_not_rune_rj;
float game_rl_pref;
float game_lg_pref;
float game_not_match;
float game_disable_autoreport;
float game_disable_dropweap;
float game_disable_autosteams;
float game_disable_botchat;
float game_lava_cheat;
float game_show_rules;

// miscellaneous features
float game_fastnail = 0; // 0 or 1
float game_qizmo;

// gamemode values
float GAME_ENABLE_POWERUPS		= 1;
float GAME_ENABLE_RUNES			= 2;
float GAME_RUNE_RJ			= 4;
float GAME_MATCH				= 64;
float GAME_RL_PREF			= 128;
float GAME_LAVA_CHEAT			= 256;
float GAME_ENABLE_DROPWEAP		= 512;
float GAME_ENABLE_AUTOREPORT		= 1024;
float GAME_ENABLE_AUTOSTEAMS		= 2048;
float GAME_ENABLE_BOTCHAT		= 4096;
float GAME_HIDE_RULES			= 8192;

// 131072;
// 262144;
float GAME_LG_PREF			= 524288;


//
// object stuff
//
.float		t_length, t_width;

//
// doors, etc
//
.vector		dest;
.string		noise4;


.float		aflag;
	
	
//
// subs
//
.void()		think1;
.vector		finaldest, finalangle;

//
// plats / doors / buttons
//
.float		state;
.float		camp_state;
.vector		pos1, pos2;		// top and bottom positions


//===========================================================================


//
// builtin functions
//

void(vector ang)	makevectors		= #1;		// sets v_forward, etc globals
void(entity e, vector o) setorigin	= #2;
void(entity e, string m) setmodel_apply	= #3;		// set movetype and solid first
void(entity e, string m) setmodel =
{
	setmodel_apply(e, m);
};
void(entity e, vector min, vector max) setsize = #4;
// #5 was removed
float() random						= #7;		// returns 0 - 1
void(entity e, float chan, string samp, float vol, float atten) sound_apply = #8;
void(float chan, string samp, float vol, float atten) sound;
vector(vector v) normalize			= #9;
void(string e) error				= #10;
float(vector v) vlen				= #12;
float(vector v) vectoyaw			= #13;	// returns 0 to 360

entity() spawn;
void(entity e) remove;
void() remove_self;

// sets trace_* globals
// nomonsters can be:
// An entity will also be ignored for testing if forent == test,
// forent->owner == test, or test->owner == forent
// a forent of world is ignored
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;	

entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound		= #19;
string(string s) precache_model		= #20;

void(entity client, string s) stuffcmd_apply = #21;
void(string s) stuffcmd =
{
	if (msg_entity.player)
		stuffcmd_apply (msg_entity, s);
};
entity(vector org, float rad) findradius = #22;
void(float level, string s) bprint = #23;
//void(string s) dprint				= #25;
string(float f) ftos				= #26;
float(float yaw, float dist) walkmove	= #32;	// returns TRUE or FALSE
// #33 was removed
float() droptofloor = #34;	// TRUE if landed on floor
void(float style, string value) lightstyle = #35;
float(float v) rint					= #36;		// round to nearest int
float(float v) oldfloor				= #37;	// largest integer <= v
float(float a) floor =
{
	local float b;
	b = oldfloor(a);
	if ((a - b) >= 0.9999) b = b + 1;
	return b;
};
float(float v) ceil					= #38;		// smallest integer >= v
// #39 was removed
float(vector v) pointcontents		= #41;		// returns a CONTENT_*
// #42 was removed
float(float f) fabs = #43;
float(string s) cvar = #45;						// return cvar.value
void(string s) localcmd = #46;					// put string into local que
entity(entity e) nextent = #47;					// for looping through all ents
// #50 was removed
vector(vector v) vectoangles			= #51;	// returns 0 to 360

//
// direct client message generation
//
void(float to, float f) WriteByte		= #52;
//void(float to, float f) WriteChar		= #53;
void(float to, float f) WriteShort		= #54;
void(float to, float f) WriteCoord		= #56;
void(float to, float f) WriteLong		= #55;
void(float to, float f) WriteAngle		= #57;
void(float to, string s) WriteString	= #58;
void(float to, entity e) WriteEntity	= #59;

//
// broadcast client message generation
//

//string(string s) precache_file	= #68;	// no effect except for -copy
void(entity e) makestatic		= #69;
void(string s) changelevel = #70;

//#71 was removed

void(string var, string val) cvar_set = #72;	// sets cvar.value
void(entity client, string s) centerprint = #73;	// sprint, but in middle
void(entity client, string s, string s2, string s3, string s4, string s5) centerprint5 = #73;
void(vector pos, string samp, float vol, float atten) ambientsound_apply = #74;
void(vector pos, string samp, float vol, float atten) ambientsound =
{
	ambientsound_apply(pos, samp, vol, atten);
};
string(string s) precache_model2	= #75;		// registered version only
string(string s) precache_sound2	= #76;		// registered version only
//string(string s) precache_file2	= #77;		// registered version only

//void(entity e) setspawnparms		= #78;		// set parm1... to the
												// values at level start
												// for coop respawn

string(entity e, string key) infokey = #80;	// get a key value (world = serverinfo)
float(string s) stof = #81;	// convert string to float
void(vector where, float set) multicast = #82;	// sends the temp message to a set
								// of clients, possibly in 
void(entity client, float level, string s) sprint = #24;

float msg_level;

// view through someones eyes
entity firstperson;
.entity clink;
.float pflags;
float PF_FIRSTPERSON = 1; //view through players eyes
float scoreboardsize;

void(float level, string s) bprint_fb =
{
	if (scoreboardsize)
	bprint(level, s);
};

void(entity client, float level, string s) sprint_fb =
{
	if (!client.player) return;
	sprint(client, level, s);
};

void(float level, float f) bprint_ftos =
{
	str = ftos(f);
	bprint_fb(level, str);
};

void(entity client, float level, float f) sprint_ftos =
{
	str = ftos(f);
	sprint_fb(client, level, str);
};

void(string s) bprint_ =
{
	WriteByte(MSG_ALL, MSG_PRINT);
	WriteString(MSG_ALL, s);
};

void(float f) localcmd_ftos =
{
	str = ftos(f);
	localcmd(str);
};

void(float f) stuffcmd_ftos =
{
	str = ftos(f);
	stuffcmd(str);
};


//===========================================================================

//
// subs.qc
//
void(vector tdest, float tspeed) SUB_CalcMove;
void() SUB_CalcMoveDone;
void() SUB_UseTargets;
void() SUB_Remove;

//
//	combat.qc
//
void() T_Damage;
float() CanDamage;

entity targ;
vector extra_velocity;
float damage;
float t_radius_damage;
entity ignore;

void() check_sound;
void(entity client) UpdateTotalDamage;

entity(entity first_in_list) AddToList;

void(string pvar, float value) cvar_set_ =
{
	str = ftos(value);
	cvar_set(pvar, str);
};

void(string pvar, float value) cvar_log =
{
	cvar_set_(pvar, value);
	bprint_fb(2, "\"");
	bprint_fb(2, pvar);
	bprint_fb(2, "\" changed to \"");
	bprint_ftos(2, value);
	bprint_fb(2, "\"\n");
};

void(vector org, entity e) spawn_tfog;
void() bf;

//
// botphys.qc
//
//============================================================================

//
// frogbot variables
//

.float arrow;
.float wasinwater;
.float swim_arrow;
.float button0_;
.float button2_;
.float arrow_time;
.float arrow_time2;
.float enemy_time;
float enemy_visible;
.float linked_marker_time;
.float touch_marker_time;
.float enemy_dist;

float predict_dist;

entity previous_spot;

entity enemy_;
entity virtual_enemy;
entity look_object_;
entity visible_object;
entity goalentity_;

entity test_enemy;
entity viewport;
entity non_viewport;
entity self_aiment;
vector targ_origin;
vector targ_centre;
vector inflictor_origin;
entity inflictor;
float damage_radius;
float inflictor_dist;
entity self_sound;

float FORWARD		= 1;
float BACK			= 2;
float LEFT			= 4;
float RIGHT			= 8;
float FORWARD_LEFT	= 5;
float FORWARD_RIGHT	= 9;
float BACK_LEFT		= 6;
float BACK_RIGHT		= 10;
float UP			= 16;
float DOWN			= 32;

float JUMPSPEED = 270;

float numberofbots;
float numberofplayers;
float numberofclients;

.float index;

.float print_framerate;

.vector oldvelocity;
vector oldvelocity_;

vector delta_velocity;

float new_pitch;

.vector obstruction_normal;
.vector velocity_normal;

float average_frametime;
float time_12;

entity current_waiting_bot;
entity first_client;
entity first_item;
entity first_ent;
entity first_teleport;
entity first_takedamage;

entity first_marker;
.entity marker_link;
.float fl_marker;

float takedamage_exists;

.entity previous;
.entity next;

.entity next_load;

.float oldsolid;

//float DROP_SUCCESS			= -2;
//float DROP_FAILED			= -1;
float FALL_FALSE				= 0;
float FALL_BLOCKED			= 1;
float FALL_LAND				= 2;
float FALL_DEATH				= 3;

entity dropper;
float fallheight;

.float real_pitch;
.float real_yaw;
.float pitchspeed;
.float yawspeed;
.float pitchaccel;
.float yawaccel;
.float track_pitchspeed;
.float track_yawspeed;
.float _highermarker;
float mouse_friction;

vector pitch_tangent;
vector yaw_tangent;
float mouse_vel;
float pitchspeed_;
float yawspeed_;
float total_pitchspeed;
float total_yawspeed;
float real_pitch_;

//
// Paths
//

.entity P0, P1, P2, P3, P4, P5, P6, P7;

entity m_P;
entity m_zone;

// Path times
.float P0_time, P1_time, P2_time, P3_time, P4_time, P5_time, P6_time, P7_time;

float P_time;

// description of path
.float D0, D1, D2, D3, D4, D5, D6, D7;

float m_D;


.float path_state;
float new_path_state;
float old_path_state;

//
// path_state/path_mode values for paths
//

// map set values
// map set values
float WATERJUMP_			= 2;
float DM6_DOOR			= 256;
float JUMP_LEDGE			= 1024;
float ROCKET_JUMP		= 512;
float SAVED_DESCRIPTION	= 1792;

// auto set values
float REVERSIBLE			= 16384;
float WATER_PATH			= 32768;
//float THROUGH_PATH		= 65536;

// dynamic values
float DELIBERATE_AIR		= 131072;
float WAIT_GROUND			= 262144;
float STUCK_PATH			= 524288;
float AIR_ACCELERATION		= 1048576;
float NO_DODGE			= 2097152;


float DISCONNECT_MARKERS	= 1048576;	// a path_mode not a path_state

float NOT_JUMP_LEDGE			= 16776191;
float DELIBERATE_AIR_WAIT_GROUND	= 393216;


// runaway markers
.entity RA0, RA1, RA2, RA3, RA4, RA5, RA6, RA7;
.entity RA0_prev, RA1_prev, RA2_prev, RA3_prev, RA4_prev, RA5_prev, RA6_prev, RA7_prev;

.float RA0_type, RA1_type, RA2_type, RA3_type, RA4_type, RA5_type, RA6_type, RA7_type;

float RA_type;

float THROUGH_NODE	= 1;

.float RA0_time, RA1_time, RA2_time, RA3_time, RA4_time, RA5_time, RA6_time, RA7_time;

.float RA0_score, RA1_score, RA2_score, RA3_score, RA4_score, RA5_score, RA6_score, RA7_score;

// through path times
//.float TP0_time, TP1_time, TP2_time, TP3_time, TP4_time, TP5_time, TP6_time, TP7_time;

//float through_path_time;


.float T;	// marker type

// T values for markers/type_mode
float UNREACHABLE				= 1;

float T_WATER				= 2;
float T_NO_AIR				= 4;

float SAVED_T				= 1;


.entity near_teleport;

entity dm6_door;

// state values for clients
float NOTARGET_ENEMY			= 32;
float AWARE_SURROUNDINGS		= 128;
float HURT_SELF				= 1024;
float CHASE_ENEMY				= 2048;
float RUNAWAY				= 4096;
float WAIT					= 8192;

float NOT_HURT_SELF			= 16776191;
float NOT_NOTARGET_ENEMY		= 16777183;
float NOT_AWARE_SURROUNDINGS		= 16777087;

// camp values for clients
float CAMPBOT				= 1;
float SHOT_FOR_LUCK			= 2;


.entity linked_marker;
.entity old_linked_marker;
.entity look_object;
.entity friend;

.float frogbot_nextthink;
.float fire_nextthink;

float nextthink_;

float try_shoot;

//
// SaveMarker variables
//

float marker_index;
float item_marker_index;
float que_size;
float markers_loaded;
float no_change;
//entity new_m_G;	// new marker Goal
float goal_index;
entity m, m_2;
vector m_pos, m_2_pos;
vector m_P_pos;

entity current_load_position;
entity load_position;


entity m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17,m18,m19,m20;
entity m21,m22,m23,m24,m25,m26,m27,m28,m29,m30,m31,m32,m33,m34,m35,m36,m37,m38,m39,m40;
entity m41,m42,m43,m44,m45,m46,m47,m48,m49,m50,m51,m52,m53,m54,m55,m56,m57,m58,m59,m60;
entity m61,m62,m63,m64,m65,m66,m67,m68,m69,m70,m71,m72,m73,m74,m75,m76,m77,m78,m79,m80;
entity m81,m82,m83,m84,m85,m86,m87,m88,m89,m90,m91,m92,m93,m94,m95,m96,m97,m98,m99,m100;
entity m101,m102,m103,m104,m105,m106,m107,m108,m109,m110,m111,m112,m113,m114,m115,m116,m117,m118,m119,m120;
entity m121,m122,m123,m124,m125,m126,m127,m128,m129,m130,m131,m132,m133,m134,m135,m136,m137,m138,m139,m140;
entity m141,m142,m143,m144,m145,m146,m147,m148,m149,m150,m151,m152,m153,m154,m155,m156,m157,m158,m159,m160;
entity m161,m162,m163,m164,m165,m166,m167,m168,m169,m170,m171,m172,m173,m174,m175,m176,m177,m178,m179,m180;
entity m181,m182,m183,m184,m185,m186,m187,m188,m189,m190,m191,m192,m193,m194,m195,m196,m197,m198,m199,m200;
entity m201,m202,m203,m204,m205,m206,m207,m208,m209,m210,m211,m212,m213,m214,m215,m216,m217,m218,m219,m220;
entity m221,m222,m223,m224,m225,m226,m227,m228,m229,m230,m231,m232,m233,m234,m235,m236,m237,m238,m239,m240;
entity m241,m242,m243,m244,m245,m246,m247,m248,m249,m250,m251,m252,m253,m254,m255,m256,m257,m258,m259,m260;
entity m261,m262,m263,m264,m265,m266,m267,m268,m269,m270,m271,m272,m273,m274,m275,m276,m277,m278,m279,m280;
entity m281,m282,m283,m284,m285,m286,m287,m288,m289,m290,m291,m292,m293,m294,m295,m296,m297,m298,m299,m300;


//
// goals
//
float NUMBER_GOALS = 24;

.entity G1_, G2_, G3_, G4_, G5_, G6_, G7_, G8_, G9_, G10_, G11_, G12_, G13_, G14_, G15_, G16_;
.entity G17_, G18_, G19_, G20_, G21_, G22_, G23_, G24_;

// time to goals
.float G1_time, G2_time, G3_time, G4_time, G5_time, G6_time, G7_time, G8_time;
.float G9_time, G10_time, G11_time, G12_time, G13_time, G14_time, G15_time, G16_time;
.float G17_time, G18_time, G19_time, G20_time, G21_time, G22_time, G23_time, G24_time;


void(entity marker) G1;
void(entity marker) G2;
void(entity marker) G3;
void(entity marker) G4;
void(entity marker) G5;
void(entity marker) G6;
void(entity marker) G7;
void(entity marker) G8;
void(entity marker) G9;
void(entity marker) G10;
void(entity marker) G11;
void(entity marker) G12;
void(entity marker) G13;
void(entity marker) G14;
void(entity marker) G15;
void(entity marker) G16;
void(entity marker) G17;
void(entity marker) G18;
void(entity marker) G19;
void(entity marker) G20;
void(entity marker) G21;
void(entity marker) G22;
void(entity marker) G23;
void(entity marker) G24;

// goal number
.float G_;
float goal_number;
entity test_goal;

.entity virtual_goal;

//
// zones
//
float NUMBER_ZONES = 24;

.entity Z1_, Z2_, Z3_, Z4_, Z5_, Z6_, Z7_, Z8_;
.entity Z9_, Z10_, Z11_, Z12_, Z13_, Z14_, Z15_, Z16_;
.entity Z17_, Z18_, Z19_, Z20_, Z21_, Z22_, Z23_, Z24_;

.entity Z1_rev, Z2_rev, Z3_rev, Z4_rev, Z5_rev, Z6_rev, Z7_rev, Z8_rev;
.entity Z9_rev, Z10_rev, Z11_rev, Z12_rev, Z13_rev, Z14_rev, Z15_rev, Z16_rev;
.entity Z17_rev, Z18_rev, Z19_rev, Z20_rev, Z21_rev, Z22_rev, Z23_rev, Z24_rev;

// time to zones
.float Z1_time, Z2_time, Z3_time, Z4_time, Z5_time, Z6_time, Z7_time, Z8_time;
.float Z9_time, Z10_time, Z11_time, Z12_time, Z13_time, Z14_time, Z15_time, Z16_time;
.float Z17_time, Z18_time, Z19_time, Z20_time, Z21_time, Z22_time, Z23_time, Z24_time;

.float Z1_time_rev, Z2_time_rev, Z3_time_rev, Z4_time_rev, Z5_time_rev, Z6_time_rev, Z7_time_rev, Z8_time_rev;
.float Z9_time_rev, Z10_time_rev, Z11_time_rev, Z12_time_rev, Z13_time_rev, Z14_time_rev, Z15_time_rev, Z16_time_rev;
.float Z17_time_rev, Z18_time_rev, Z19_time_rev, Z20_time_rev, Z21_time_rev, Z22_time_rev, Z23_time_rev, Z24_time_rev;

// next zone to zone
.entity Z1_next_zone, Z2_next_zone, Z3_next_zone, Z4_next_zone, Z5_next_zone, Z6_next_zone, Z7_next_zone, Z8_next_zone;
.entity Z9_next_zone, Z10_next_zone, Z11_next_zone, Z12_next_zone, Z13_next_zone, Z14_next_zone, Z15_next_zone, Z16_next_zone;
.entity Z17_next_zone, Z18_next_zone, Z19_next_zone, Z20_next_zone, Z21_next_zone, Z22_next_zone, Z23_next_zone, Z24_next_zone;
float same_zone;

// next marker to zone
.entity Z1_next, Z2_next, Z3_next, Z4_next, Z5_next, Z6_next, Z7_next, Z8_next;
.entity Z9_next, Z10_next, Z11_next, Z12_next, Z13_next, Z14_next, Z15_next, Z16_next;
.entity Z17_next, Z18_next, Z19_next, Z20_next, Z21_next, Z22_next, Z23_next, Z24_next;

.entity Z1_next_rev, Z2_next_rev, Z3_next_rev, Z4_next_rev, Z5_next_rev, Z6_next_rev, Z7_next_rev, Z8_next_rev;
.entity Z9_next_rev, Z10_next_rev, Z11_next_rev, Z12_next_rev, Z13_next_rev, Z14_next_rev, Z15_next_rev, Z16_next_rev;
.entity Z17_next_rev, Z18_next_rev, Z19_next_rev, Z20_next_rev, Z21_next_rev, Z22_next_rev, Z23_next_rev, Z24_next_rev;

// time from zones
.float Z1_from_time, Z2_from_time, Z3_from_time, Z4_from_time, Z5_from_time, Z6_from_time, Z7_from_time, Z8_from_time;
.float Z9_from_time, Z10_from_time, Z11_from_time, Z12_from_time, Z13_from_time, Z14_from_time, Z15_from_time, Z16_from_time;
.float Z17_from_time, Z18_from_time, Z19_from_time, Z20_from_time, Z21_from_time, Z22_from_time, Z23_from_time, Z24_from_time;

// first visible marker of entity coming from zone
.entity Z1_sight_from, Z2_sight_from, Z3_sight_from, Z4_sight_from, Z5_sight_from, Z6_sight_from, Z7_sight_from, Z8_sight_from;
.entity Z9_sight_from, Z10_sight_from, Z11_sight_from, Z12_sight_from, Z13_sight_from, Z14_sight_from, Z15_sight_from, Z16_sight_from;
.entity Z17_sight_from, Z18_sight_from, Z19_sight_from, Z20_sight_from, Z21_sight_from, Z22_sight_from, Z23_sight_from, Z24_sight_from;

// time enemy in zone has to reach direct line of sight to marker (with some averaging out)
.float Z1_sight_from_time_, Z2_sight_from_time_, Z3_sight_from_time_, Z4_sight_from_time_, Z5_sight_from_time_, Z6_sight_from_time_, Z7_sight_from_time_, Z8_sight_from_time_;
.float Z9_sight_from_time_, Z10_sight_from_time_, Z11_sight_from_time_, Z12_sight_from_time_, Z13_sight_from_time_, Z14_sight_from_time_, Z15_sight_from_time_, Z16_sight_from_time_;
.float Z17_sight_from_time_, Z18_sight_from_time_, Z19_sight_from_time_, Z20_sight_from_time_, Z21_sight_from_time_, Z22_sight_from_time_, Z23_sight_from_time_, Z24_sight_from_time_;

// first visible marker of entity coming from zone, with height advantage
.entity Z1_higher_sight_from, Z2_higher_sight_from, Z3_higher_sight_from, Z4_higher_sight_from, Z5_higher_sight_from, Z6_higher_sight_from, Z7_higher_sight_from, Z8_higher_sight_from;
.entity Z9_higher_sight_from, Z10_higher_sight_from, Z11_higher_sight_from, Z12_higher_sight_from, Z13_higher_sight_from, Z14_higher_sight_from, Z15_higher_sight_from, Z16_higher_sight_from;
.entity Z17_higher_sight_from, Z18_higher_sight_from, Z19_higher_sight_from, Z20_higher_sight_from, Z21_higher_sight_from, Z22_higher_sight_from, Z23_higher_sight_from, Z24_higher_sight_from;

// time enemy in zone has to reach direct line of sight to marker, with height advantage
.float Z1_higher_sight_from_time_, Z2_higher_sight_from_time_, Z3_higher_sight_from_time_, Z4_higher_sight_from_time_, Z5_higher_sight_from_time_, Z6_higher_sight_from_time_, Z7_higher_sight_from_time_, Z8_higher_sight_from_time_;
.float Z9_higher_sight_from_time_, Z10_higher_sight_from_time_, Z11_higher_sight_from_time_, Z12_higher_sight_from_time_, Z13_higher_sight_from_time_, Z14_higher_sight_from_time_, Z15_higher_sight_from_time_, Z16_higher_sight_from_time_;
.float Z17_higher_sight_from_time_, Z18_higher_sight_from_time_, Z19_higher_sight_from_time_, Z20_higher_sight_from_time_, Z21_higher_sight_from_time_, Z22_higher_sight_from_time_, Z23_higher_sight_from_time_, Z24_higher_sight_from_time_;

// time to get to at least equal virtual height to enemy in zone
.float Z1_height_equal_time;
.float Z8_height_equal_time;

float Z1_path_success;
float Z8_path_success;


// zone number
.float Z_;

entity zone_stack_head;
.entity zone_stack_next;

.entity Z_head;
.entity Z_next;

entity Z1_head, Z2_head, Z3_head, Z4_head, Z5_head, Z6_head, Z7_head, Z8_head;
entity Z9_head, Z10_head, Z11_head, Z12_head, Z13_head, Z14_head, Z15_head, Z16_head;
entity Z17_head, Z18_head, Z19_head, Z20_head, Z21_head, Z22_head, Z23_head, Z24_head;

entity Z1_tail, Z2_tail, Z3_tail, Z4_tail, Z5_tail, Z6_tail, Z7_tail, Z8_tail;
entity Z9_tail, Z10_tail, Z11_tail, Z12_tail, Z13_tail, Z14_tail, Z15_tail, Z16_tail;
entity Z17_tail, Z18_tail, Z19_tail, Z20_tail, Z21_tail, Z22_tail, Z23_tail, Z24_tail;

float Z1_S_index, Z2_S_index, Z3_S_index, Z4_S_index, Z5_S_index, Z6_S_index, Z7_S_index, Z8_S_index;
float Z9_S_index, Z10_S_index, Z11_S_index, Z12_S_index, Z13_S_index, Z14_S_index, Z15_S_index, Z16_S_index;
float Z17_S_index, Z18_S_index, Z19_S_index, Z20_S_index, Z21_S_index, Z22_S_index, Z23_S_index, Z24_S_index;


//
// sub-zones
//
float NUMBER_SUBZONES = 32;

.float S1_time, S2_time, S3_time, S4_time, S5_time, S6_time, S7_time, S8_time;
.float S9_time, S10_time, S11_time, S12_time, S13_time, S14_time, S15_time, S16_time;
.float S17_time, S18_time, S19_time, S20_time, S21_time, S22_time, S23_time, S24_time;
.float S25_time, S26_time, S27_time, S28_time, S29_time, S30_time, S31_time, S32_time;

.entity S1_next, S2_next, S3_next, S4_next, S5_next, S6_next, S7_next, S8_next;
.entity S9_next, S10_next, S11_next, S12_next, S13_next, S14_next, S15_next, S16_next;
.entity S17_next, S18_next, S19_next, S20_next, S21_next, S22_next, S23_next, S24_next;
.entity S25_next, S26_next, S27_next, S28_next, S29_next, S30_next, S31_next, S32_next;

float S_index;

// sub-zone number
.float S_;

//
// tasks
//
.float Z1_task;


float path_normal;
.float path_normal_;

// impossible paths have >= 1000000 travel time
.void() zone_marker;		// if no zone found then middle_marker = dropper
					// must set path_normal variable
.void() sub_arrival_time;
.void() sub_path_marker;	// if no path found then next_marker = world (same marker not allowed)
.void() path_marker;		// if no path found then next_marker = world (same marker allowed)
.void() next_zone_marker;	// if no path found then next_marker = world (same zone allowed)
.void() sight_from_marker;	// if no marker found or ambiguous then look_marker = world
.void() higher_sight_from_marker;	// if no marker found or ambiguous then look_marker = world
.void() sight_from_time;


.void() desire;
.float() pickup;
.float saved_goal_desire;
.float saved_respawn_time;
.float saved_goal_time;
.float saved_enemy_time_squared;
.float goal_respawn_time;

float leave;

entity from_marker;
entity middle_marker;
entity next_marker;
entity to_marker;
entity look_marker;

entity test_marker;
entity prev_marker;

float two_teams;
float first_team;
float second_team;
float new_team;

vector to_marker_pos;

entity goal_entity;

.float goal_refresh_time;		// when must recheck goals
.float weapon_refresh_time;		// when must recheck weapons

float goal_refresh_time_;
float weapon_refresh_time_;

.float total_damage;
.float firepower;
//.float toughness;

float toughness_;

float items_;
float weapon_;
float	am;
float attackbonus;
float firepower_;

float	save;
float	take;

.float desire_armor1;
.float desire_armor2;
.float desire_armorInv;
.float desire_health0;
.float desire_health2;
.float desire_supershotgun;
.float desire_nailgun;
.float desire_supernailgun;
.float desire_grenadelauncher;
.float desire_rocketlauncher;
.float desire_lightning;
.float desire_rockets;
.float desire_cells;
.float desire_nails;
.float desire_shells;

float maxplayers;

.entity touch_marker;
.float touch_distance;

entity touch_marker_;

.float color_;
.float teamcolor;
.float bot_skill;
.float admin_code;
.float lines;
.float input_time;

.float fast_aim;
.float dodge_amount;
.float lookahead_time;
.float prediction_error;
.float look_anywhere;
.float stop_turn_speed;
.float accuracy;
.float firing_reflex;

float lookahead_time_;
float prediction_error_;
vector origin_;

float impulse_;

float time_start;
float framecount_start;
float real_frametime;
float sv_accelerate;
float sv_maxfriction;
float sv_accelerate_frametime;
float timelimit;
float fraglimit;
float sv_maxspeed;
float sv_maxwaterspeed;
float half_sv_maxspeed;
float inv_sv_maxspeed;
float sv_maxstrafespeed;
float quad_factor;

float sv_friction;
float sv_friction_frametime;
float inv_sv_friction_frametime;
float sv_friction_frametime_100;
float friction_factor;
float old_time;
float distance;
vector hor_direction;
vector dir_forward;
float current_maxspeed;
float velocity_forward;
float accel_forward;
float max_accel_forward;
vector desired_accel;
float arrow_;
float yaw;
float dist;
vector hor_velocity;
float hor_speed;
vector new_velocity;
vector new_origin;
vector last_clear_hor_velocity;
float last_clear_hor_speed;
vector jump_velocity;
vector jump_origin;
float oldflags;
float current_arrow;
float content;
float content1;
float content2;
float content3;
float fall;
float new_fall;
float current_fallspot;
vector edge_normal;
float normal_comp;
float best_dotproduct;
float best_arrow;
float test_forward;
float test_forward_left;
float test_forward_right;
float test_right;
float test_left;
float test_back;
float test_back_left;
float test_back_right;
vector self_view;
vector testplace;
vector testplace_mins;
vector testplace_maxs;
vector test_enemy_mins;
vector test_enemy_maxs;
.vector virtual_mins;
.vector virtual_maxs;
vector hor_velocity;
float tries;
vector last_clear_point;
vector last_clear_velocity;
float jumpspeed;
vector dir_move;
.vector dir_move_;
float path_score;
float total_goal_time;
entity goal_marker2;
vector self_dir;
float best_score;
float look_score;
vector dir_look;
entity best_goal;
entity best_goal_marker;
float best_goal_desire;
float best_goal_time;
float best_score2;
entity best_goal2;
float goal_desire;
float enemy_desire;
float enemy_repel;
float best_goal_score;
float current_goal_time;
float current_goal_time_125;
float best_respawn_time;
entity goalentity_marker;	// closest marker to self.goalentity (dynamically changes)
float goal_late_time;
entity linked_marker_;
vector linked_marker_origin;
float goal_score;
float goal_score2;
float goal_time2;
float same_dir;
float avoid;
float enemy_score;
vector rel_pos;
vector rel_pos2;
vector rel_dir;
float rel_dist;
float rel_time;
vector rel_hor_dir;
vector desired_angle;
float hor_component;
vector angle_error;
float min_angle_error;
entity enemy_touch_marker;
entity touch_marker_;
float new_health;
vector src;
vector direction;
vector desired_angle;
vector angle_error;
vector rel_pos;
float rel_dist;
float risk;
float hit_radius;
float risk_factor;
float risk_strength;
vector rocket_origin;
float splash_damage;
float shaft_available;
vector rel_pos;
vector enemy_angles;
float avoid_rockets;
entity grenade_marker;
float desired_weapon;
entity bot;
float rnd;
float minutes;
float seconds;
float time_to_print;
entity spawn_pos;
float attacker_damaged;
float attacker_damage;
entity spots;
float pcount;
entity thing;
float numspots;
float totalspots;
entity t;
vector vec1;
vector vec2;
vector vec_;
entity think_ent;
entity trigger;
vector cmins;
vector cmaxs;
entity trigger;
entity item;
vector tmin;
vector tmax;
float or;
float nr;
float best_weapon;
float score_count;
vector item_pos;
entity closest_marker;
float shortest_distance;
vector marker_pos;
entity marker_;
entity marker2;
float zone_time;
float real_yaw_;
entity fireball;
entity bubble;
entity bubble_spawner;
vector org_;
float rnd1;
float rnd2;
float rnd3;
float character;
float block_;
float char_count;
float word_count;
float spawnflags_;
float digit;
float exponent;
float previous_exponent;
entity target_;
float traveltime;
float traveltime2;
float traveltime3;
float look_traveltime;
float look_traveltime_squared;
entity flag_self;
float flag_pos;
entity flag1;
entity flag2;
entity tfog;
vector weapons_vel;
entity death;
entity trace_ent1;
entity trace_ent2;
entity old_self;
entity old_other;
float ledge_backup;
.float ledge_backup_time;
float try_jump_ledge;
float being_blocked;

float forward;
string deathstring;
string deathstring2;
entity removebot_self;
float min_first;
float min_second;
vector start;
vector end;
float description;
float goal_time;
float path_time;
float component_speed;
float do_jump;
entity viewport;
float dm;
float count_;
entity array_sub_object_;
float bind_char;
float dodge_factor;
entity dodge_missile;

entity killed_self;
entity rune_self;
entity fallspot_self;
entity door_enemy;

entity multi_ent;
float	multi_damage;

vector blood_org;

float blood_count;
vector puff_org;
float puff_count;

float clientpants;
float clientshirt;
.float hit_z;

float load_frogbots;
float frogbot_removetime;

.float number_bots;

float invalid_map;
float frogbot_load_stage;

float NUMBER_LOAD_STAGE = 9;
float NUMBERHARDBOTS = 16;

float	intermission_running;
float	intermission_exittime;

entity bodyque_head;

.float dmgtime;
.float k_msgcount;

float rocket_alert;
vector rocket_endpos;

string nextmap;

float frogbot_number;
entity new_bot;
entity prephysics;
entity postphysics;
entity first_frogbot;
entity frogbot_spawned;

// match variables
float use_ammo;
float available_weapons;
float pre_game;
float start_time;
float real_time;
float time_left;
float minutes_left;
.float skin0;
.float skin1;
.float skin2;
.float spawnbit0;
.float spawnbit1;
.float number_spawnbits;

float spawnbit0_;
float spawnbit1_;
float registered;
float check_parm_time;

.entity movetarget;
.vector v_forward_;
.vector v_right_;
float SPAWN_SIZE = 1;


// sharing AI
.entity touchPlayer;
.float touchPlayerTime;

// unstick AI
float unstick_time;
float no_bots_stuck;
.float tread_water_count;

// hit wall in flight prediction AI
float first_trace_fraction;
vector first_trace_plane_normal;

// air turning prediction AI
float turning_speed;
vector hor_normal_vec;
vector last_clear_angle;
vector velocity_hor_angle;

// enemy prediction AI
.vector predict_origin;
.float predict_success;
float predict_spot;
.float predict_shoot;

.float allowedMakeNoise;
float beQuiet;

// preferences
.float preferences;

float PREF_FLASH		= 1;

// weapon switching
float w_switch;
float b_switch;
.float dead_time;
float max_dead_time;
.float desire_backpack;
float runaway_time;
float runaway_time_temp;
float runaway_score;
float runaway_score_temp;
entity runaway_dest;
float runaway_fail;
entity runaway_marker_temp;
entity runaway_prev_temp;
float min_traveltime;
entity to_zone;
float test_away_score;
float best_away_score;
entity best_away_marker;
entity search_entity;
float RA_time;
float enemy_time_squared;
.void end_remove_fieldnames_;
