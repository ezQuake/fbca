/*
	maps.qc

	Copyright (C) 2000-2003 rxr
	Copyright (C) 2000-2007 ParboiL
*/

string(float f2) GetMapName =
{
	local float f1;
	local string s1, s2;

	if (f2 == 200) return "ztndm3";
	else if (f2 == 201) return "aerowalk";
	else if (f2 == 202) return "spinev2";
	else if (f2 == 203) return "pkeg1";
	else if (f2 == 204) return "ultrav";
	else if (f2 == 205) return "frobodm2";
	else if (f2 == 206) return "amphi2";
	else if (f2 == 207) return "povdmm4";
	else if (f2 == 208) return "e1m1";
	else if (f2 == 209) return "e1m2";
	else if (f2 == 210) return "e1m3";
	else if (f2 == 211) return "e1m4";
	else if (f2 == 212) return "e1m5";
	else if (f2 == 213) return "e1m6";
	else if (f2 == 214) return "e1m7";
	else if (f2 == 215) return "e1m8";
	else if (f2 == 216) return "e2m1";
	else if (f2 == 217) return "e2m2";
	else if (f2 == 218) return "e2m3";
	else if (f2 == 219) return "e2m4";
	else if (f2 == 220) return "e2m5";
	else if (f2 == 221) return "e2m6";
	else if (f2 == 222) return "e2m7";
	else if (f2 == 223) return "e3m1";
	else if (f2 == 224) return "e3m2";
	else if (f2 == 225) return "e3m3";
	else if (f2 == 226) return "e3m4";
	else if (f2 == 227) return "e3m5";
	else if (f2 == 228) return "e3m6";
	else if (f2 == 229) return "e3m7";
	else if (f2 == 230) return "e4m1";
	else if (f2 == 231) return "e4m2";
	else if (f2 == 232) return "e4m3";
	else if (f2 == 233) return "e4m4";
	else if (f2 == 234) return "e4m5";
	else if (f2 == 235) return "e4m6";
	else if (f2 == 236) return "e4m7";
	else if (f2 == 237) return "e4m8";
	else if (f2 == 238) return "dm1";
	else if (f2 == 239) return "dm2";
	else if (f2 == 240) return "dm3";
	else if (f2 == 241) return "dm4";
	else if (f2 == 242) return "dm5";
	else if (f2 == 243) return "dm6";
	else if (f2 == 244) return "start";
	else if (f2 == 245) return "end";
	else {
		f1 = f2 + 999 - 137;
		s1 = ftos(f1);
		s2 = infokey(world, s1);
		return s2;
	}
};

float(float val) map_was_voted =
{
	local entity p;
	local float l;
	p = find(world, classname, "player");
	while(p) {
		if (p != self) {
			if (p.k_vote == val) {
				l = TRUE;
				break;
			}
		}
		p = find(p, classname, "player");
	}
	return l;
};

float(float val) count_map_votes =
{
	local entity p;
	local float l;
	p = find(world, classname, "player");
	while(p) {
		if (p.k_vote == val) l = l + 1;
		p = find(p, classname, "player");
	}
	return l;
};

void() SelectMap =
{
	local float f1, f2, f3;
	local string s1;
	if (match_in_progress || counting_down || intermission_running) return;
	s1 = GetMapName(self.impulse);
	if (k_vbreak || (numberofplayers < 2)) {
		if ((self.k_vote == self.impulse) && numberofplayers > 1) {
			sprint_fb(self, 2, "ùûûûûü your vote is still good ùûûûûü\n");
		} else {
			self.k_vote = self.impulse;
			f1 = map_was_voted(self.impulse);
			f2 = count_map_votes(self.impulse);
			f3 = (floor(numberofplayers / 2)) + 1;
			if (f1) {
				if (numberofplayers < 3) {
					bprint_fb(3, self.netname);
					bprint_fb(3, " agrees to map ");
				} else {
					bprint_fb(3, self.netname);
					bprint_fb(3, " agrees on map ");
				}
			} else {
				bprint_fb(3, self.netname);
				bprint_fb(3, " would rather play on ");
			}
			bprint_fb(2, s1);
			bprint_fb(2, "\n");
			if (f2 >= f3) {
				if (numberofplayers > 1) {
					bprint(2, "Majority votes for mapchange\n");
				} 
				s1 = GetMapName(self.impulse);
				localcmd("map ");
				localcmd(s1);
				localcmd("\n");
				return;
			} 
		}
	} else {
		s1 = GetMapName(self.impulse);
		bprint_fb(3, self.netname);
		bprint_fb(3, " suggests map ");
		bprint_fb(2, s1);
		bprint_fb(2, "\n");
		self.k_vote = self.impulse;
	}
	k_vbreak = self.impulse;
};

// random map que for ffa;
string() rndffamap =
{
	local float x, y, closed;
	local string cmap, pmap;
	cmap = infokey(world, mapname);
	pmap = cmap;
	while ((cmap != "") && (cmap != mapname)) {
		cmap = infokey(world, cmap);
		if (cmap == mapname) closed = TRUE;
		else pmap = cmap;
		x = x + 1;
	}
	if (!x || !closed) return mapname;
	else if (x == 1) return pmap;
	else {
		x = rndm(1, x);
		cmap = mapname;
		while (y < x) {
			cmap = infokey(world, cmap);
			y = y + 1;
		}
		return cmap;
	}
};