/*
	route_calc.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
*/

void() Calc_G_time_path;
void() Calc_G_time_1;
void() Calc_G_time_2;
void() Calc_G_time_3_path;
void() Calc_G_time_4_path;
void() Calc_G_time_5_path;
void() Calc_G_time_6_path;
void() Calc_G_time_7;
void() Calc_G_time_8_path;
void() Calc_G_time_9;
void() Calc_G_time_10_path;
void() Calc_G_time_11;
void() Calc_G_time_12;
void() Calc_G_time_13;
void() Calc_G_time_14;


/*
============
Calc_G_time_path

============
*/
void() Calc_G_time_path =
{
// Note: Max 100000 commands in a function call

	self.nextthink = 0.001;

	count_ = 50;

	while (count_)
	{
		m_P = m.P0;
		if (m_P)
		{
			m_D = m.D0;
			P_time = m.P0_time;
			dropper.use();
		}

		m_P = m.P1;
		if (m_P)
		{
			m_D = m.D1;
			P_time = m.P1_time;
			dropper.use();
		}

		m_P = m.P2;
		if (m_P)
		{
			m_D = m.D2;
			P_time = m.P2_time;
			dropper.use();
		}

		m_P = m.P3;
		if (m_P)
		{
			m_D = m.D3;
			P_time = m.P3_time;
			dropper.use();
		}

		m_P = m.P4;
		if (m_P)
		{
			m_D = m.D4;
			P_time = m.P4_time;
			dropper.use();
		}

		m_P = m.P5;
		if (m_P)
		{
			m_D = m.D5;
			P_time = m.P5_time;
			dropper.use();
		}

		m_P = m.P6;
		if (m_P)
		{
			m_D = m.D6;
			P_time = m.P6_time;
			dropper.use();
		}

		m_P = m.P7;
		if (m_P)
		{
			m_D = m.D7;
			P_time = m.P7_time;
			dropper.use();
		}

		count_ = count_ - 1;

		m = m.marker_link;

		if (!m)
		{
			m = first_marker;

			if (no_change)
			{
				if (dropper.use == Calc_G_time_3_path)
					dropper.use = Calc_G_time_4_path;
				else if (dropper.use == Calc_G_time_4_path)
					dropper.use = Calc_G_time_5_path;
				else if (dropper.use == Calc_G_time_5_path)
					dropper.use = Calc_G_time_6_path;
				else
				{
					if (dropper.use == Calc_G_time_6_path)
						dropper.think = Calc_G_time_7;
					else if (dropper.use == Calc_G_time_8_path)
						dropper.think = Calc_G_time_9;
					else
						dropper.think = Calc_G_time_11;

					set_load();
					return;
				}
			}

			no_change = TRUE;
		}
	}
};

/*
============
Calc_G_time_1

============
*/
void() Calc_G_time_1 =
{
// Note: Max 100000 commands in a function call

	self.nextthink = 0.001;

	count_ = 50;

	self = dropper;

	while (count_)
	{
		m_pos = m.absmin + m.view_ofs;
		m.touch_marker = m;

		content = pointcontents(m_pos + '0 0 4');
		if (content >= CONTENT_LAVA)
		if (content <= CONTENT_WATER)
		{
			CheckWaterColumn();
			if (testplace_z - m_pos_z > 0)
				setsize(m, m.mins, m.maxs + testplace - m_pos);

			count_ = count_ - 1;
		}

		m = m.marker_link;

		if (!m)
		{
			m = dropper;

			dropper.think = Calc_G_time_2;
			set_load();
			return;
		}
	}
};

/*
============
TravelTime

============
*/

void() TravelTime =
{
	if (m_D & ROCKET_JUMP)
	{
		traveltime = 100000;
		return;
	}
	if (m_D & JUMP_LEDGE)
		m_D = m_D | NO_DODGE;

	if (m.classname == "trigger_teleport")
	{
		m_P.near_teleport = m;
		traveltime = 0;	// destination is only path
	}
	else
	{
		m_P_pos = m_P.absmin + m_P.view_ofs;
		if ((m.T & T_WATER) || (m_P.T & T_WATER))
		{
			m_D = m_D | WATER_PATH;
			traveltime = ((vlen(m_P_pos - m_pos) / sv_maxwaterspeed));
		}
		else
			traveltime = ((vlen(m_P_pos - m_pos) / sv_maxspeed));
	}
};

/*
============
Calc_G_time_2

============
*/
void() Calc_G_time_2 =
{
// Note: Max 100000 commands in a function call

	self.nextthink = 0.001;

	count_ = 50;

	while (count_)
	{
		m_pos = m.absmin + m.view_ofs;

		m_P = m.P0;
		if (m_P.fl_marker)
		{
			m_D = m.D0;
			TravelTime();
			m.P0_time = traveltime;
			m.D0 = m_D;
		}
		else
			m.P0 = world;

		m_P = m.P1;
		if (m_P.fl_marker)
		{
			m_D = m.D1;
			TravelTime();
			m.P1_time = traveltime;
			m.D1 = m_D;
		}
		else
			m.P1 = world;

		m_P = m.P2;
		if (m_P.fl_marker)
		{
			m_D = m.D2;
			TravelTime();
			m.P2_time = traveltime;
			m.D2 = m_D;
		}
		else
			m.P2 = world;

		m_P = m.P3;
		if (m_P.fl_marker)
		{
			m_D = m.D3;
			TravelTime();
			m.P3_time = traveltime;
			m.D3 = m_D;
		}
		else
			m.P3 = world;

		m_P = m.P4;
		if (m_P.fl_marker)
		{
			m_D = m.D4;
			TravelTime();
			m.P4_time = traveltime;
			m.D4 = m_D;
		}
		else
			m.P4 = world;

		m_P = m.P5;
		if (m_P.fl_marker)
		{
			m_D = m.D5;
			TravelTime();
			m.P5_time = traveltime;
			m.D5 = m_D;
		}
		else
			m.P5 = world;

		m_P = m.P6;
		if (m_P.fl_marker)
		{
			m_D = m.D6;
			TravelTime();
			m.P6_time = traveltime;
			m.D6 = m_D;
		}
		else
			m.P6 = world;

		m_P = m.P7;
		if (m_P.fl_marker)
		{
			m_D = m.D7;
			TravelTime();
			m.P7_time = traveltime;
			m.D7 = m_D;
		}
		else
			m.P7 = world;

		if (!m.G1_) {m.G1_time = 1000000; m.G1_ = dropper;}
		if (!m.G2_) {m.G2_time = 1000000; m.G2_ = dropper;}
		if (!m.G3_) {m.G3_time = 1000000; m.G3_ = dropper;}
		if (!m.G4_) {m.G4_time = 1000000; m.G4_ = dropper;}
		if (!m.G5_) {m.G5_time = 1000000; m.G5_ = dropper;}
		if (!m.G6_) {m.G6_time = 1000000; m.G6_ = dropper;}
		if (!m.G7_) {m.G7_time = 1000000; m.G7_ = dropper;}
		if (!m.G8_) {m.G8_time = 1000000; m.G8_ = dropper;}
		if (!m.G9_) {m.G9_time = 1000000; m.G9_ = dropper;}
		if (!m.G10_) {m.G10_time = 1000000; m.G10_ = dropper;}
		if (!m.G11_) {m.G11_time = 1000000; m.G11_ = dropper;}
		if (!m.G12_) {m.G12_time = 1000000; m.G12_ = dropper;}
		if (!m.G13_) {m.G13_time = 1000000; m.G13_ = dropper;}
		if (!m.G14_) {m.G14_time = 1000000; m.G14_ = dropper;}
		if (!m.G15_) {m.G15_time = 1000000; m.G15_ = dropper;}
		if (!m.G16_) {m.G16_time = 1000000; m.G16_ = dropper;}
		if (!m.G17_) {m.G17_time = 1000000; m.G17_ = dropper;}
		if (!m.G18_) {m.G18_time = 1000000; m.G18_ = dropper;}
		if (!m.G19_) {m.G19_time = 1000000; m.G19_ = dropper;}
		if (!m.G20_) {m.G20_time = 1000000; m.G20_ = dropper;}
		if (!m.G21_) {m.G21_time = 1000000; m.G21_ = dropper;}
		if (!m.G22_) {m.G22_time = 1000000; m.G22_ = dropper;}
		if (!m.G23_) {m.G23_time = 1000000; m.G23_ = dropper;}
		if (!m.G24_) {m.G24_time = 1000000; m.G24_ = dropper;}

		if (!m.Z1_) {m.Z1_time = m.Z1_time_rev = m.Z1_from_time = 1000000; m.Z1_ = m.Z1_rev = dropper;}
		if (!m.Z2_) {m.Z2_time = m.Z2_time_rev = m.Z2_from_time = 1000000; m.Z2_ = m.Z2_rev = dropper;}
		if (!m.Z3_) {m.Z3_time = m.Z3_time_rev = m.Z3_from_time = 1000000; m.Z3_ = m.Z3_rev = dropper;}
		if (!m.Z4_) {m.Z4_time = m.Z4_time_rev = m.Z4_from_time = 1000000; m.Z4_ = m.Z4_rev = dropper;}
		if (!m.Z5_) {m.Z5_time = m.Z5_time_rev = m.Z5_from_time = 1000000; m.Z5_ = m.Z5_rev = dropper;}
		if (!m.Z6_) {m.Z6_time = m.Z6_time_rev = m.Z6_from_time = 1000000; m.Z6_ = m.Z6_rev = dropper;}
		if (!m.Z7_) {m.Z7_time = m.Z7_time_rev = m.Z7_from_time = 1000000; m.Z7_ = m.Z7_rev = dropper;}
		if (!m.Z8_) {m.Z8_time = m.Z8_time_rev = m.Z8_from_time = 1000000; m.Z8_ = m.Z8_rev = dropper;}
		if (!m.Z9_) {m.Z9_time = m.Z9_time_rev = m.Z9_from_time = 1000000; m.Z9_ = m.Z9_rev = dropper;}
		if (!m.Z10_) {m.Z10_time = m.Z10_time_rev = m.Z10_from_time = 1000000; m.Z10_ = m.Z10_rev = dropper;}
		if (!m.Z11_) {m.Z11_time = m.Z11_time_rev = m.Z11_from_time = 1000000; m.Z11_ = m.Z11_rev = dropper;}
		if (!m.Z12_) {m.Z12_time = m.Z12_time_rev = m.Z12_from_time = 1000000; m.Z12_ = m.Z12_rev = dropper;}
		if (!m.Z13_) {m.Z13_time = m.Z13_time_rev = m.Z13_from_time = 1000000; m.Z13_ = m.Z13_rev = dropper;}
		if (!m.Z14_) {m.Z14_time = m.Z14_time_rev = m.Z14_from_time = 1000000; m.Z14_ = m.Z14_rev = dropper;}
		if (!m.Z15_) {m.Z15_time = m.Z15_time_rev = m.Z15_from_time = 1000000; m.Z15_ = m.Z15_rev = dropper;}
		if (!m.Z16_) {m.Z16_time = m.Z16_time_rev = m.Z16_from_time = 1000000; m.Z16_ = m.Z16_rev = dropper;}
		if (!m.Z17_) {m.Z17_time = m.Z17_time_rev = m.Z17_from_time = 1000000; m.Z17_ = m.Z17_rev = dropper;}
		if (!m.Z18_) {m.Z18_time = m.Z18_time_rev = m.Z18_from_time = 1000000; m.Z18_ = m.Z18_rev = dropper;}
		if (!m.Z19_) {m.Z19_time = m.Z19_time_rev = m.Z19_from_time = 1000000; m.Z19_ = m.Z19_rev = dropper;}
		if (!m.Z20_) {m.Z20_time = m.Z20_time_rev = m.Z20_from_time = 1000000; m.Z20_ = m.Z20_rev = dropper;}
		if (!m.Z21_) {m.Z21_time = m.Z21_time_rev = m.Z21_from_time = 1000000; m.Z21_ = m.Z21_rev = dropper;}
		if (!m.Z22_) {m.Z22_time = m.Z22_time_rev = m.Z22_from_time = 1000000; m.Z22_ = m.Z22_rev = dropper;}
		if (!m.Z23_) {m.Z23_time = m.Z23_time_rev = m.Z23_from_time = 1000000; m.Z23_ = m.Z23_rev = dropper;}
		if (!m.Z24_) {m.Z24_time = m.Z24_time_rev = m.Z24_from_time = 1000000; m.Z24_ = m.Z24_rev = dropper;}

		m.Z1_sight_from_time_ = m.Z2_sight_from_time_ = m.Z3_sight_from_time_ = m.Z4_sight_from_time_ =
		m.Z5_sight_from_time_ = m.Z6_sight_from_time_ = m.Z7_sight_from_time_ = m.Z8_sight_from_time_ =
		m.Z9_sight_from_time_ = m.Z10_sight_from_time_ = m.Z11_sight_from_time_ = m.Z12_sight_from_time_ =
		m.Z13_sight_from_time_ = m.Z14_sight_from_time_ = m.Z15_sight_from_time_ = m.Z16_sight_from_time_ =
		m.Z17_sight_from_time_ = m.Z18_sight_from_time_ = m.Z19_sight_from_time_ = m.Z20_sight_from_time_ =
		m.Z21_sight_from_time_ = m.Z22_sight_from_time_ = m.Z23_sight_from_time_ = m.Z24_sight_from_time_ =
		m.Z1_higher_sight_from_time_ = m.Z2_higher_sight_from_time_ = m.Z3_higher_sight_from_time_ = m.Z4_higher_sight_from_time_ =
		m.Z5_higher_sight_from_time_ = m.Z6_higher_sight_from_time_ = m.Z7_higher_sight_from_time_ = m.Z8_higher_sight_from_time_ =
		m.Z9_higher_sight_from_time_ = m.Z10_higher_sight_from_time_ = m.Z11_higher_sight_from_time_ = m.Z12_higher_sight_from_time_ =
		m.Z13_higher_sight_from_time_ = m.Z14_higher_sight_from_time_ = m.Z15_higher_sight_from_time_ = m.Z16_higher_sight_from_time_ =
		m.Z17_higher_sight_from_time_ = m.Z18_higher_sight_from_time_ = m.Z19_higher_sight_from_time_ = m.Z20_higher_sight_from_time_ =
		m.Z21_higher_sight_from_time_ = m.Z22_higher_sight_from_time_ = m.Z23_higher_sight_from_time_ = m.Z24_higher_sight_from_time_ = 1000000;

		m.Z1_height_equal_time = 1000000;
		m.Z8_height_equal_time = 1000000;

		if (m.S_ != 1) m.S1_time = 1000000;
		if (m.S_ != 2) m.S2_time = 1000000;
		if (m.S_ != 3) m.S3_time = 1000000;
		if (m.S_ != 4) m.S4_time = 1000000;
		if (m.S_ != 5) m.S5_time = 1000000;
		if (m.S_ != 6) m.S6_time = 1000000;
		if (m.S_ != 7) m.S7_time = 1000000;
		if (m.S_ != 8) m.S8_time = 1000000;
		if (m.S_ != 9) m.S9_time = 1000000;
		if (m.S_ != 10) m.S10_time = 1000000;
		if (m.S_ != 11) m.S11_time = 1000000;
		if (m.S_ != 12) m.S12_time = 1000000;
		if (m.S_ != 13) m.S13_time = 1000000;
		if (m.S_ != 14) m.S14_time = 1000000;
		if (m.S_ != 15) m.S15_time = 1000000;
		if (m.S_ != 16) m.S16_time = 1000000;
		if (m.S_ != 17) m.S17_time = 1000000;
		if (m.S_ != 18) m.S18_time = 1000000;
		if (m.S_ != 19) m.S19_time = 1000000;
		if (m.S_ != 20) m.S20_time = 1000000;
		if (m.S_ != 21) m.S21_time = 1000000;
		if (m.S_ != 22) m.S22_time = 1000000;
		if (m.S_ != 23) m.S23_time = 1000000;
		if (m.S_ != 24) m.S24_time = 1000000;
		if (m.S_ != 25) m.S25_time = 1000000;
		if (m.S_ != 26) m.S26_time = 1000000;
		if (m.S_ != 27) m.S27_time = 1000000;
		if (m.S_ != 28) m.S28_time = 1000000;
		if (m.S_ != 29) m.S29_time = 1000000;
		if (m.S_ != 30) m.S30_time = 1000000;
		if (m.S_ != 31) m.S31_time = 1000000;
		if (m.S_ != 32) m.S32_time = 1000000;

		count_ = count_ - 1;

		m = m.marker_link;

		if (!m)
		{
			m = first_marker;

			dropper.use = Calc_G_time_3_path;
			dropper.think = Calc_G_time_path;
			set_load();
			return;
		}
	}
};

/*
============
Calc_G_time_3_path

============
*/
void() Calc_G_time_3_path =
{
	if (m.Z_ == m_P.Z_)
	{
		if (m.S1_time > (P_time + m_P.S1_time)) { no_change = FALSE; m.S1_time = P_time + m_P.S1_time; m.S1_next = m_P; }
		if (m.S2_time > (P_time + m_P.S2_time)) { no_change = FALSE; m.S2_time = P_time + m_P.S2_time; m.S2_next = m_P; }
		if (m.S3_time > (P_time + m_P.S3_time)) { no_change = FALSE; m.S3_time = P_time + m_P.S3_time; m.S3_next = m_P; }
		if (m.S4_time > (P_time + m_P.S4_time)) { no_change = FALSE; m.S4_time = P_time + m_P.S4_time; m.S4_next = m_P; }
		if (m.S5_time > (P_time + m_P.S5_time)) { no_change = FALSE; m.S5_time = P_time + m_P.S5_time; m.S5_next = m_P; }
		if (m.S6_time > (P_time + m_P.S6_time)) { no_change = FALSE; m.S6_time = P_time + m_P.S6_time; m.S6_next = m_P; }
		if (m.S7_time > (P_time + m_P.S7_time)) { no_change = FALSE; m.S7_time = P_time + m_P.S7_time; m.S7_next = m_P; }
		if (m.S8_time > (P_time + m_P.S8_time)) { no_change = FALSE; m.S8_time = P_time + m_P.S8_time; m.S8_next = m_P; }
		if (m.S9_time > (P_time + m_P.S9_time)) { no_change = FALSE; m.S9_time = P_time + m_P.S9_time; m.S9_next = m_P; }
		if (m.S10_time > (P_time + m_P.S10_time)) { no_change = FALSE; m.S10_time = P_time + m_P.S10_time; m.S10_next = m_P; }
		if (m.S11_time > (P_time + m_P.S11_time)) { no_change = FALSE; m.S11_time = P_time + m_P.S11_time; m.S11_next = m_P; }
		if (m.S12_time > (P_time + m_P.S12_time)) { no_change = FALSE; m.S12_time = P_time + m_P.S12_time; m.S12_next = m_P; }
		if (m.S13_time > (P_time + m_P.S13_time)) { no_change = FALSE; m.S13_time = P_time + m_P.S13_time; m.S13_next = m_P; }
		if (m.S14_time > (P_time + m_P.S14_time)) { no_change = FALSE; m.S14_time = P_time + m_P.S14_time; m.S14_next = m_P; }
		if (m.S15_time > (P_time + m_P.S15_time)) { no_change = FALSE; m.S15_time = P_time + m_P.S15_time; m.S15_next = m_P; }
		if (m.S16_time > (P_time + m_P.S16_time)) { no_change = FALSE; m.S16_time = P_time + m_P.S16_time; m.S16_next = m_P; }
		if (m.S17_time > (P_time + m_P.S17_time)) { no_change = FALSE; m.S17_time = P_time + m_P.S17_time; m.S17_next = m_P; }
		if (m.S18_time > (P_time + m_P.S18_time)) { no_change = FALSE; m.S18_time = P_time + m_P.S18_time; m.S18_next = m_P; }
		if (m.S19_time > (P_time + m_P.S19_time)) { no_change = FALSE; m.S19_time = P_time + m_P.S19_time; m.S19_next = m_P; }
		if (m.S20_time > (P_time + m_P.S20_time)) { no_change = FALSE; m.S20_time = P_time + m_P.S20_time; m.S20_next = m_P; }
		if (m.S21_time > (P_time + m_P.S21_time)) { no_change = FALSE; m.S21_time = P_time + m_P.S21_time; m.S21_next = m_P; }
		if (m.S22_time > (P_time + m_P.S22_time)) { no_change = FALSE; m.S22_time = P_time + m_P.S22_time; m.S22_next = m_P; }
		if (m.S23_time > (P_time + m_P.S23_time)) { no_change = FALSE; m.S23_time = P_time + m_P.S23_time; m.S23_next = m_P; }
		if (m.S24_time > (P_time + m_P.S24_time)) { no_change = FALSE; m.S24_time = P_time + m_P.S24_time; m.S24_next = m_P; }
		if (m.S25_time > (P_time + m_P.S25_time)) { no_change = FALSE; m.S25_time = P_time + m_P.S25_time; m.S25_next = m_P; }
		if (m.S26_time > (P_time + m_P.S26_time)) { no_change = FALSE; m.S26_time = P_time + m_P.S26_time; m.S26_next = m_P; }
		if (m.S27_time > (P_time + m_P.S27_time)) { no_change = FALSE; m.S27_time = P_time + m_P.S27_time; m.S27_next = m_P; }
		if (m.S28_time > (P_time + m_P.S28_time)) { no_change = FALSE; m.S28_time = P_time + m_P.S28_time; m.S28_next = m_P; }
		if (m.S29_time > (P_time + m_P.S29_time)) { no_change = FALSE; m.S29_time = P_time + m_P.S29_time; m.S29_next = m_P; }
		if (m.S30_time > (P_time + m_P.S30_time)) { no_change = FALSE; m.S30_time = P_time + m_P.S30_time; m.S30_next = m_P; }
		if (m.S31_time > (P_time + m_P.S31_time)) { no_change = FALSE; m.S31_time = P_time + m_P.S31_time; m.S31_next = m_P; }
		if (m.S32_time > (P_time + m_P.S32_time)) { no_change = FALSE; m.S32_time = P_time + m_P.S32_time; m.S32_next = m_P; }
	}
};

/*
============
Calc_G_time_4_path

============
*/
void() Calc_G_time_4_path =
{
	if (m.G1_time > (P_time + m_P.G1_time)) { no_change = FALSE; m.G1_ = m_P.G1_; m.G1_time = P_time + m_P.G1_time; }
	if (m.G2_time > (P_time + m_P.G2_time)) { no_change = FALSE; m.G2_ = m_P.G2_; m.G2_time = P_time + m_P.G2_time; }
	if (m.G3_time > (P_time + m_P.G3_time)) { no_change = FALSE; m.G3_ = m_P.G3_; m.G3_time = P_time + m_P.G3_time; }
	if (m.G4_time > (P_time + m_P.G4_time)) { no_change = FALSE; m.G4_ = m_P.G4_; m.G4_time = P_time + m_P.G4_time; }
	if (m.G5_time > (P_time + m_P.G5_time)) { no_change = FALSE; m.G5_ = m_P.G5_; m.G5_time = P_time + m_P.G5_time; }
	if (m.G6_time > (P_time + m_P.G6_time)) { no_change = FALSE; m.G6_ = m_P.G6_; m.G6_time = P_time + m_P.G6_time; }
	if (m.G7_time > (P_time + m_P.G7_time)) { no_change = FALSE; m.G7_ = m_P.G7_; m.G7_time = P_time + m_P.G7_time; }
	if (m.G8_time > (P_time + m_P.G8_time)) { no_change = FALSE; m.G8_ = m_P.G8_; m.G8_time = P_time + m_P.G8_time; }
	if (m.G9_time > (P_time + m_P.G9_time)) { no_change = FALSE; m.G9_ = m_P.G9_; m.G9_time = P_time + m_P.G9_time; }
	if (m.G10_time > (P_time + m_P.G10_time)) { no_change = FALSE; m.G10_ = m_P.G10_; m.G10_time = P_time + m_P.G10_time; }
	if (m.G11_time > (P_time + m_P.G11_time)) { no_change = FALSE; m.G11_ = m_P.G11_; m.G11_time = P_time + m_P.G11_time; }
	if (m.G12_time > (P_time + m_P.G12_time)) { no_change = FALSE; m.G12_ = m_P.G12_; m.G12_time = P_time + m_P.G12_time; }
	if (m.G13_time > (P_time + m_P.G13_time)) { no_change = FALSE; m.G13_ = m_P.G13_; m.G13_time = P_time + m_P.G13_time; }
	if (m.G14_time > (P_time + m_P.G14_time)) { no_change = FALSE; m.G14_ = m_P.G14_; m.G14_time = P_time + m_P.G14_time; }
	if (m.G15_time > (P_time + m_P.G15_time)) { no_change = FALSE; m.G15_ = m_P.G15_; m.G15_time = P_time + m_P.G15_time; }
	if (m.G16_time > (P_time + m_P.G16_time)) { no_change = FALSE; m.G16_ = m_P.G16_; m.G16_time = P_time + m_P.G16_time; }
	if (m.G17_time > (P_time + m_P.G17_time)) { no_change = FALSE; m.G17_ = m_P.G17_; m.G17_time = P_time + m_P.G17_time; }
	if (m.G18_time > (P_time + m_P.G18_time)) { no_change = FALSE; m.G18_ = m_P.G18_; m.G18_time = P_time + m_P.G18_time; }
	if (m.G19_time > (P_time + m_P.G19_time)) { no_change = FALSE; m.G19_ = m_P.G19_; m.G19_time = P_time + m_P.G19_time; }
	if (m.G20_time > (P_time + m_P.G20_time)) { no_change = FALSE; m.G20_ = m_P.G20_; m.G20_time = P_time + m_P.G20_time; }
	if (m.G21_time > (P_time + m_P.G21_time)) { no_change = FALSE; m.G21_ = m_P.G21_; m.G21_time = P_time + m_P.G21_time; }
	if (m.G22_time > (P_time + m_P.G22_time)) { no_change = FALSE; m.G22_ = m_P.G22_; m.G22_time = P_time + m_P.G22_time; }
	if (m.G23_time > (P_time + m_P.G23_time)) { no_change = FALSE; m.G23_ = m_P.G23_; m.G23_time = P_time + m_P.G23_time; }
	if (m.G24_time > (P_time + m_P.G24_time)) { no_change = FALSE; m.G24_ = m_P.G24_; m.G24_time = P_time + m_P.G24_time; }
};

/*
============
Calc_G_time_5_path

============
*/
void() Calc_G_time_5_path =
{
	same_zone = (m.Z_ == m_P.Z_);

	if (m.Z1_time > (P_time + m_P.Z1_time)) { no_change = FALSE; m.Z1_ = m_P.Z1_; m.Z1_time = P_time + m_P.Z1_time; m.Z1_next = m_P; { if (same_zone) m.Z1_next_zone = m_P.Z1_next_zone; else m.Z1_next_zone = m_P; } m.Z1_task = m_D | m_P.Z1_task; }
	if (m.Z2_time > (P_time + m_P.Z2_time)) { no_change = FALSE; m.Z2_ = m_P.Z2_; m.Z2_time = P_time + m_P.Z2_time; m.Z2_next = m_P; { if (same_zone) m.Z2_next_zone = m_P.Z2_next_zone; else m.Z2_next_zone = m_P; } }
	if (m.Z3_time > (P_time + m_P.Z3_time)) { no_change = FALSE; m.Z3_ = m_P.Z3_; m.Z3_time = P_time + m_P.Z3_time; m.Z3_next = m_P; { if (same_zone) m.Z3_next_zone = m_P.Z3_next_zone; else m.Z3_next_zone = m_P; } }
	if (m.Z4_time > (P_time + m_P.Z4_time)) { no_change = FALSE; m.Z4_ = m_P.Z4_; m.Z4_time = P_time + m_P.Z4_time; m.Z4_next = m_P; { if (same_zone) m.Z4_next_zone = m_P.Z4_next_zone; else m.Z4_next_zone = m_P; } }
	if (m.Z5_time > (P_time + m_P.Z5_time)) { no_change = FALSE; m.Z5_ = m_P.Z5_; m.Z5_time = P_time + m_P.Z5_time; m.Z5_next = m_P; { if (same_zone) m.Z5_next_zone = m_P.Z5_next_zone; else m.Z5_next_zone = m_P; } }
	if (m.Z6_time > (P_time + m_P.Z6_time)) { no_change = FALSE; m.Z6_ = m_P.Z6_; m.Z6_time = P_time + m_P.Z6_time; m.Z6_next = m_P; { if (same_zone) m.Z6_next_zone = m_P.Z6_next_zone; else m.Z6_next_zone = m_P; } }
	if (m.Z7_time > (P_time + m_P.Z7_time)) { no_change = FALSE; m.Z7_ = m_P.Z7_; m.Z7_time = P_time + m_P.Z7_time; m.Z7_next = m_P; { if (same_zone) m.Z7_next_zone = m_P.Z7_next_zone; else m.Z7_next_zone = m_P; } }
	if (m.Z8_time > (P_time + m_P.Z8_time)) { no_change = FALSE; m.Z8_ = m_P.Z8_; m.Z8_time = P_time + m_P.Z8_time; m.Z8_next = m_P; { if (same_zone) m.Z8_next_zone = m_P.Z8_next_zone; else m.Z8_next_zone = m_P; } }
	if (m.Z9_time > (P_time + m_P.Z9_time)) { no_change = FALSE; m.Z9_ = m_P.Z9_; m.Z9_time = P_time + m_P.Z9_time; m.Z9_next = m_P; { if (same_zone) m.Z9_next_zone = m_P.Z9_next_zone; else m.Z9_next_zone = m_P; } }
	if (m.Z10_time > (P_time + m_P.Z10_time)) { no_change = FALSE; m.Z10_ = m_P.Z10_; m.Z10_time = P_time + m_P.Z10_time; m.Z10_next = m_P; { if (same_zone) m.Z10_next_zone = m_P.Z10_next_zone; else m.Z10_next_zone = m_P; } }
	if (m.Z11_time > (P_time + m_P.Z11_time)) { no_change = FALSE; m.Z11_ = m_P.Z11_; m.Z11_time = P_time + m_P.Z11_time; m.Z11_next = m_P; { if (same_zone) m.Z11_next_zone = m_P.Z11_next_zone; else m.Z11_next_zone = m_P; } }
	if (m.Z12_time > (P_time + m_P.Z12_time)) { no_change = FALSE; m.Z12_ = m_P.Z12_; m.Z12_time = P_time + m_P.Z12_time; m.Z12_next = m_P; { if (same_zone) m.Z12_next_zone = m_P.Z12_next_zone; else m.Z12_next_zone = m_P; } }
	if (m.Z13_time > (P_time + m_P.Z13_time)) { no_change = FALSE; m.Z13_ = m_P.Z13_; m.Z13_time = P_time + m_P.Z13_time; m.Z13_next = m_P; { if (same_zone) m.Z13_next_zone = m_P.Z13_next_zone; else m.Z13_next_zone = m_P; } }
	if (m.Z14_time > (P_time + m_P.Z14_time)) { no_change = FALSE; m.Z14_ = m_P.Z14_; m.Z14_time = P_time + m_P.Z14_time; m.Z14_next = m_P; { if (same_zone) m.Z14_next_zone = m_P.Z14_next_zone; else m.Z14_next_zone = m_P; } }
	if (m.Z15_time > (P_time + m_P.Z15_time)) { no_change = FALSE; m.Z15_ = m_P.Z15_; m.Z15_time = P_time + m_P.Z15_time; m.Z15_next = m_P; { if (same_zone) m.Z15_next_zone = m_P.Z15_next_zone; else m.Z15_next_zone = m_P; } }
	if (m.Z16_time > (P_time + m_P.Z16_time)) { no_change = FALSE; m.Z16_ = m_P.Z16_; m.Z16_time = P_time + m_P.Z16_time; m.Z16_next = m_P; { if (same_zone) m.Z16_next_zone = m_P.Z16_next_zone; else m.Z16_next_zone = m_P; } }
	if (m.Z17_time > (P_time + m_P.Z17_time)) { no_change = FALSE; m.Z17_ = m_P.Z17_; m.Z17_time = P_time + m_P.Z17_time; m.Z17_next = m_P; { if (same_zone) m.Z17_next_zone = m_P.Z17_next_zone; else m.Z17_next_zone = m_P; } }
	if (m.Z18_time > (P_time + m_P.Z18_time)) { no_change = FALSE; m.Z18_ = m_P.Z18_; m.Z18_time = P_time + m_P.Z18_time; m.Z18_next = m_P; { if (same_zone) m.Z18_next_zone = m_P.Z18_next_zone; else m.Z18_next_zone = m_P; } }
	if (m.Z19_time > (P_time + m_P.Z19_time)) { no_change = FALSE; m.Z19_ = m_P.Z19_; m.Z19_time = P_time + m_P.Z19_time; m.Z19_next = m_P; { if (same_zone) m.Z19_next_zone = m_P.Z19_next_zone; else m.Z19_next_zone = m_P; } }
	if (m.Z20_time > (P_time + m_P.Z20_time)) { no_change = FALSE; m.Z20_ = m_P.Z20_; m.Z20_time = P_time + m_P.Z20_time; m.Z20_next = m_P; { if (same_zone) m.Z20_next_zone = m_P.Z20_next_zone; else m.Z20_next_zone = m_P; } }
	if (m.Z21_time > (P_time + m_P.Z21_time)) { no_change = FALSE; m.Z21_ = m_P.Z21_; m.Z21_time = P_time + m_P.Z21_time; m.Z21_next = m_P; { if (same_zone) m.Z21_next_zone = m_P.Z21_next_zone; else m.Z21_next_zone = m_P; } }
	if (m.Z22_time > (P_time + m_P.Z22_time)) { no_change = FALSE; m.Z22_ = m_P.Z22_; m.Z22_time = P_time + m_P.Z22_time; m.Z22_next = m_P; { if (same_zone) m.Z22_next_zone = m_P.Z22_next_zone; else m.Z22_next_zone = m_P; } }
	if (m.Z23_time > (P_time + m_P.Z23_time)) { no_change = FALSE; m.Z23_ = m_P.Z23_; m.Z23_time = P_time + m_P.Z23_time; m.Z23_next = m_P; { if (same_zone) m.Z23_next_zone = m_P.Z23_next_zone; else m.Z23_next_zone = m_P; } }
	if (m.Z24_time > (P_time + m_P.Z24_time)) { no_change = FALSE; m.Z24_ = m_P.Z24_; m.Z24_time = P_time + m_P.Z24_time; m.Z24_next = m_P; { if (same_zone) m.Z24_next_zone = m_P.Z24_next_zone; else m.Z24_next_zone = m_P; } }
};

/*
============
Calc_G_time_6_path

============
*/
void() Calc_G_time_6_path =
{
	if (m_P.Z1_from_time > (m.Z1_from_time + P_time)) { no_change = FALSE; m_P.Z1_from_time = m.Z1_from_time + P_time; }
	if (m_P.Z2_from_time > (m.Z2_from_time + P_time)) { no_change = FALSE; m_P.Z2_from_time = m.Z2_from_time + P_time; }
	if (m_P.Z3_from_time > (m.Z3_from_time + P_time)) { no_change = FALSE; m_P.Z3_from_time = m.Z3_from_time + P_time; }
	if (m_P.Z4_from_time > (m.Z4_from_time + P_time)) { no_change = FALSE; m_P.Z4_from_time = m.Z4_from_time + P_time; }
	if (m_P.Z5_from_time > (m.Z5_from_time + P_time)) { no_change = FALSE; m_P.Z5_from_time = m.Z5_from_time + P_time; }
	if (m_P.Z6_from_time > (m.Z6_from_time + P_time)) { no_change = FALSE; m_P.Z6_from_time = m.Z6_from_time + P_time; }
	if (m_P.Z7_from_time > (m.Z7_from_time + P_time)) { no_change = FALSE; m_P.Z7_from_time = m.Z7_from_time + P_time; }
	if (m_P.Z8_from_time > (m.Z8_from_time + P_time)) { no_change = FALSE; m_P.Z8_from_time = m.Z8_from_time + P_time; }
	if (m_P.Z9_from_time > (m.Z9_from_time + P_time)) { no_change = FALSE; m_P.Z9_from_time = m.Z9_from_time + P_time; }
	if (m_P.Z10_from_time > (m.Z10_from_time + P_time)) { no_change = FALSE; m_P.Z10_from_time = m.Z10_from_time + P_time; }
	if (m_P.Z11_from_time > (m.Z11_from_time + P_time)) { no_change = FALSE; m_P.Z11_from_time = m.Z11_from_time + P_time; }
	if (m_P.Z12_from_time > (m.Z12_from_time + P_time)) { no_change = FALSE; m_P.Z12_from_time = m.Z12_from_time + P_time; }
	if (m_P.Z13_from_time > (m.Z13_from_time + P_time)) { no_change = FALSE; m_P.Z13_from_time = m.Z13_from_time + P_time; }
	if (m_P.Z14_from_time > (m.Z14_from_time + P_time)) { no_change = FALSE; m_P.Z14_from_time = m.Z14_from_time + P_time; }
	if (m_P.Z15_from_time > (m.Z15_from_time + P_time)) { no_change = FALSE; m_P.Z15_from_time = m.Z15_from_time + P_time; }
	if (m_P.Z16_from_time > (m.Z16_from_time + P_time)) { no_change = FALSE; m_P.Z16_from_time = m.Z16_from_time + P_time; }
	if (m_P.Z17_from_time > (m.Z17_from_time + P_time)) { no_change = FALSE; m_P.Z17_from_time = m.Z17_from_time + P_time; }
	if (m_P.Z18_from_time > (m.Z18_from_time + P_time)) { no_change = FALSE; m_P.Z18_from_time = m.Z18_from_time + P_time; }
	if (m_P.Z19_from_time > (m.Z19_from_time + P_time)) { no_change = FALSE; m_P.Z19_from_time = m.Z19_from_time + P_time; }
	if (m_P.Z20_from_time > (m.Z20_from_time + P_time)) { no_change = FALSE; m_P.Z20_from_time = m.Z20_from_time + P_time; }
	if (m_P.Z21_from_time > (m.Z21_from_time + P_time)) { no_change = FALSE; m_P.Z21_from_time = m.Z21_from_time + P_time; }
	if (m_P.Z22_from_time > (m.Z22_from_time + P_time)) { no_change = FALSE; m_P.Z22_from_time = m.Z22_from_time + P_time; }
	if (m_P.Z23_from_time > (m.Z23_from_time + P_time)) { no_change = FALSE; m_P.Z23_from_time = m.Z23_from_time + P_time; }
	if (m_P.Z24_from_time > (m.Z24_from_time + P_time)) { no_change = FALSE; m_P.Z24_from_time = m.Z24_from_time + P_time; }
};

/*
============
CheckReversible

============
*/
void() CheckReversible =
{
	m.next_zone_marker();
	if (next_marker.Z_ == m.Z_)
		m_D = REVERSIBLE;
	else
		m_D = 0;
};

/*
============
Calc_G_time_7

============
*/
void() Calc_G_time_7 =
{
// Note: Max 100000 commands in a function call

	self.nextthink = 0.001;

	count_ = 150;

	while (count_)
	{
		from_marker = m.P0;
		if (from_marker)
		{
			CheckReversible();
			m.D0 = m.D0 | m_D;
		}

		from_marker = m.P1;
		if (from_marker)
		{
			CheckReversible();
			m.D1 = m.D1 | m_D;
		}

		from_marker = m.P2;
		if (from_marker)
		{
			CheckReversible();
			m.D2 = m.D2 | m_D;
		}

		from_marker = m.P3;
		if (from_marker)
		{
			CheckReversible();
			m.D3 = m.D3 | m_D;
		}

		from_marker = m.P4;
		if (from_marker)
		{
			CheckReversible();
			m.D4 = m.D4 | m_D;
		}

		from_marker = m.P5;
		if (from_marker)
		{
			CheckReversible();
			m.D5 = m.D5 | m_D;
		}

		from_marker = m.P6;
		if (from_marker)
		{
			CheckReversible();
			m.D6 = m.D6 | m_D;
		}

		from_marker = m.P7;
		if (from_marker)
		{
			CheckReversible();
			m.D7 = m.D7 | m_D;
		}

		count_ = count_ - 1;

		m = m.marker_link;

		if (!m)
		{
			m = first_marker;

			dropper.use = Calc_G_time_8_path;
			dropper.think = Calc_G_time_path;
			set_load();
			return;
		}
	}
};

/*
============
Calc_G_time_8_path

============
*/
void() Calc_G_time_8_path =
{
	if (m_D & REVERSIBLE)
	{
		if (m.Z1_time_rev > (P_time + m_P.Z1_time_rev)) { no_change = FALSE; m.Z1_rev = m_P.Z1_rev; m.Z1_time_rev = P_time + m_P.Z1_time_rev; m.Z1_next_rev = m_P; }
		if (m.Z2_time_rev > (P_time + m_P.Z2_time_rev)) { no_change = FALSE; m.Z2_rev = m_P.Z2_rev; m.Z2_time_rev = P_time + m_P.Z2_time_rev; m.Z2_next_rev = m_P; }
		if (m.Z3_time_rev > (P_time + m_P.Z3_time_rev)) { no_change = FALSE; m.Z3_rev = m_P.Z3_rev; m.Z3_time_rev = P_time + m_P.Z3_time_rev; m.Z3_next_rev = m_P; }
		if (m.Z4_time_rev > (P_time + m_P.Z4_time_rev)) { no_change = FALSE; m.Z4_rev = m_P.Z4_rev; m.Z4_time_rev = P_time + m_P.Z4_time_rev; m.Z4_next_rev = m_P; }
		if (m.Z5_time_rev > (P_time + m_P.Z5_time_rev)) { no_change = FALSE; m.Z5_rev = m_P.Z5_rev; m.Z5_time_rev = P_time + m_P.Z5_time_rev; m.Z5_next_rev = m_P; }
		if (m.Z6_time_rev > (P_time + m_P.Z6_time_rev)) { no_change = FALSE; m.Z6_rev = m_P.Z6_rev; m.Z6_time_rev = P_time + m_P.Z6_time_rev; m.Z6_next_rev = m_P; }
		if (m.Z7_time_rev > (P_time + m_P.Z7_time_rev)) { no_change = FALSE; m.Z7_rev = m_P.Z7_rev; m.Z7_time_rev = P_time + m_P.Z7_time_rev; m.Z7_next_rev = m_P; }
		if (m.Z8_time_rev > (P_time + m_P.Z8_time_rev)) { no_change = FALSE; m.Z8_rev = m_P.Z8_rev; m.Z8_time_rev = P_time + m_P.Z8_time_rev; m.Z8_next_rev = m_P; }
		if (m.Z9_time_rev > (P_time + m_P.Z9_time_rev)) { no_change = FALSE; m.Z9_rev = m_P.Z9_rev; m.Z9_time_rev = P_time + m_P.Z9_time_rev; m.Z9_next_rev = m_P; }
		if (m.Z10_time_rev > (P_time + m_P.Z10_time_rev)) { no_change = FALSE; m.Z10_rev = m_P.Z10_rev; m.Z10_time_rev = P_time + m_P.Z10_time_rev; m.Z10_next_rev = m_P; }
		if (m.Z11_time_rev > (P_time + m_P.Z11_time_rev)) { no_change = FALSE; m.Z11_rev = m_P.Z11_rev; m.Z11_time_rev = P_time + m_P.Z11_time_rev; m.Z11_next_rev = m_P; }
		if (m.Z12_time_rev > (P_time + m_P.Z12_time_rev)) { no_change = FALSE; m.Z12_rev = m_P.Z12_rev; m.Z12_time_rev = P_time + m_P.Z12_time_rev; m.Z12_next_rev = m_P; }
		if (m.Z13_time_rev > (P_time + m_P.Z13_time_rev)) { no_change = FALSE; m.Z13_rev = m_P.Z13_rev; m.Z13_time_rev = P_time + m_P.Z13_time_rev; m.Z13_next_rev = m_P; }
		if (m.Z14_time_rev > (P_time + m_P.Z14_time_rev)) { no_change = FALSE; m.Z14_rev = m_P.Z14_rev; m.Z14_time_rev = P_time + m_P.Z14_time_rev; m.Z14_next_rev = m_P; }
		if (m.Z15_time_rev > (P_time + m_P.Z15_time_rev)) { no_change = FALSE; m.Z15_rev = m_P.Z15_rev; m.Z15_time_rev = P_time + m_P.Z15_time_rev; m.Z15_next_rev = m_P; }
		if (m.Z16_time_rev > (P_time + m_P.Z16_time_rev)) { no_change = FALSE; m.Z16_rev = m_P.Z16_rev; m.Z16_time_rev = P_time + m_P.Z16_time_rev; m.Z16_next_rev = m_P; }
		if (m.Z17_time_rev > (P_time + m_P.Z17_time_rev)) { no_change = FALSE; m.Z17_rev = m_P.Z17_rev; m.Z17_time_rev = P_time + m_P.Z17_time_rev; m.Z17_next_rev = m_P; }
		if (m.Z18_time_rev > (P_time + m_P.Z18_time_rev)) { no_change = FALSE; m.Z18_rev = m_P.Z18_rev; m.Z18_time_rev = P_time + m_P.Z18_time_rev; m.Z18_next_rev = m_P; }
		if (m.Z19_time_rev > (P_time + m_P.Z19_time_rev)) { no_change = FALSE; m.Z19_rev = m_P.Z19_rev; m.Z19_time_rev = P_time + m_P.Z19_time_rev; m.Z19_next_rev = m_P; }
		if (m.Z20_time_rev > (P_time + m_P.Z20_time_rev)) { no_change = FALSE; m.Z20_rev = m_P.Z20_rev; m.Z20_time_rev = P_time + m_P.Z20_time_rev; m.Z20_next_rev = m_P; }
		if (m.Z21_time_rev > (P_time + m_P.Z21_time_rev)) { no_change = FALSE; m.Z21_rev = m_P.Z21_rev; m.Z21_time_rev = P_time + m_P.Z21_time_rev; m.Z21_next_rev = m_P; }
		if (m.Z22_time_rev > (P_time + m_P.Z22_time_rev)) { no_change = FALSE; m.Z22_rev = m_P.Z22_rev; m.Z22_time_rev = P_time + m_P.Z22_time_rev; m.Z22_next_rev = m_P; }
		if (m.Z23_time_rev > (P_time + m_P.Z23_time_rev)) { no_change = FALSE; m.Z23_rev = m_P.Z23_rev; m.Z23_time_rev = P_time + m_P.Z23_time_rev; m.Z23_next_rev = m_P; }
		if (m.Z24_time_rev > (P_time + m_P.Z24_time_rev)) { no_change = FALSE; m.Z24_rev = m_P.Z24_rev; m.Z24_time_rev = P_time + m_P.Z24_time_rev; m.Z24_next_rev = m_P; }
	}
};

/*
============
Calc_G_time_9_apply

============
*/
void() Calc_G_time_9_apply =
{
	if (m.Z1_sight_from_time_ > m_2.Z1_from_time) { m.Z1_sight_from_time_ = m_2.Z1_from_time; m.Z1_sight_from = m_2; } else if (!m_2.Z1_from_time) m.Z1_sight_from = world;
	if (m.Z2_sight_from_time_ > m_2.Z2_from_time) { m.Z2_sight_from_time_ = m_2.Z2_from_time; m.Z2_sight_from = m_2; } else if (!m_2.Z2_from_time) m.Z2_sight_from = world;
	if (m.Z3_sight_from_time_ > m_2.Z3_from_time) { m.Z3_sight_from_time_ = m_2.Z3_from_time; m.Z3_sight_from = m_2; } else if (!m_2.Z3_from_time) m.Z3_sight_from = world;
	if (m.Z4_sight_from_time_ > m_2.Z4_from_time) { m.Z4_sight_from_time_ = m_2.Z4_from_time; m.Z4_sight_from = m_2; } else if (!m_2.Z4_from_time) m.Z4_sight_from = world;
	if (m.Z5_sight_from_time_ > m_2.Z5_from_time) { m.Z5_sight_from_time_ = m_2.Z5_from_time; m.Z5_sight_from = m_2; } else if (!m_2.Z5_from_time) m.Z5_sight_from = world;
	if (m.Z6_sight_from_time_ > m_2.Z6_from_time) { m.Z6_sight_from_time_ = m_2.Z6_from_time; m.Z6_sight_from = m_2; } else if (!m_2.Z6_from_time) m.Z6_sight_from = world;
	if (m.Z7_sight_from_time_ > m_2.Z7_from_time) { m.Z7_sight_from_time_ = m_2.Z7_from_time; m.Z7_sight_from = m_2; } else if (!m_2.Z7_from_time) m.Z7_sight_from = world;
	if (m.Z8_sight_from_time_ > m_2.Z8_from_time) { m.Z8_sight_from_time_ = m_2.Z8_from_time; m.Z8_sight_from = m_2; } else if (!m_2.Z8_from_time) m.Z8_sight_from = world;
	if (m.Z9_sight_from_time_ > m_2.Z9_from_time) { m.Z9_sight_from_time_ = m_2.Z9_from_time; m.Z9_sight_from = m_2; } else if (!m_2.Z9_from_time) m.Z9_sight_from = world;
	if (m.Z10_sight_from_time_ > m_2.Z10_from_time) { m.Z10_sight_from_time_ = m_2.Z10_from_time; m.Z10_sight_from = m_2; } else if (!m_2.Z10_from_time) m.Z10_sight_from = world;
	if (m.Z11_sight_from_time_ > m_2.Z11_from_time) { m.Z11_sight_from_time_ = m_2.Z11_from_time; m.Z11_sight_from = m_2; } else if (!m_2.Z11_from_time) m.Z11_sight_from = world;
	if (m.Z12_sight_from_time_ > m_2.Z12_from_time) { m.Z12_sight_from_time_ = m_2.Z12_from_time; m.Z12_sight_from = m_2; } else if (!m_2.Z12_from_time) m.Z12_sight_from = world;
	if (m.Z13_sight_from_time_ > m_2.Z13_from_time) { m.Z13_sight_from_time_ = m_2.Z13_from_time; m.Z13_sight_from = m_2; } else if (!m_2.Z13_from_time) m.Z13_sight_from = world;
	if (m.Z14_sight_from_time_ > m_2.Z14_from_time) { m.Z14_sight_from_time_ = m_2.Z14_from_time; m.Z14_sight_from = m_2; } else if (!m_2.Z14_from_time) m.Z14_sight_from = world;
	if (m.Z15_sight_from_time_ > m_2.Z15_from_time) { m.Z15_sight_from_time_ = m_2.Z15_from_time; m.Z15_sight_from = m_2; } else if (!m_2.Z15_from_time) m.Z15_sight_from = world;
	if (m.Z16_sight_from_time_ > m_2.Z16_from_time) { m.Z16_sight_from_time_ = m_2.Z16_from_time; m.Z16_sight_from = m_2; } else if (!m_2.Z16_from_time) m.Z16_sight_from = world;
	if (m.Z17_sight_from_time_ > m_2.Z17_from_time) { m.Z17_sight_from_time_ = m_2.Z17_from_time; m.Z17_sight_from = m_2; } else if (!m_2.Z17_from_time) m.Z17_sight_from = world;
	if (m.Z18_sight_from_time_ > m_2.Z18_from_time) { m.Z18_sight_from_time_ = m_2.Z18_from_time; m.Z18_sight_from = m_2; } else if (!m_2.Z18_from_time) m.Z18_sight_from = world;
	if (m.Z19_sight_from_time_ > m_2.Z19_from_time) { m.Z19_sight_from_time_ = m_2.Z19_from_time; m.Z19_sight_from = m_2; } else if (!m_2.Z19_from_time) m.Z19_sight_from = world;
	if (m.Z20_sight_from_time_ > m_2.Z20_from_time) { m.Z20_sight_from_time_ = m_2.Z20_from_time; m.Z20_sight_from = m_2; } else if (!m_2.Z20_from_time) m.Z20_sight_from = world;
	if (m.Z21_sight_from_time_ > m_2.Z21_from_time) { m.Z21_sight_from_time_ = m_2.Z21_from_time; m.Z21_sight_from = m_2; } else if (!m_2.Z21_from_time) m.Z21_sight_from = world;
	if (m.Z22_sight_from_time_ > m_2.Z22_from_time) { m.Z22_sight_from_time_ = m_2.Z22_from_time; m.Z22_sight_from = m_2; } else if (!m_2.Z22_from_time) m.Z22_sight_from = world;
	if (m.Z23_sight_from_time_ > m_2.Z23_from_time) { m.Z23_sight_from_time_ = m_2.Z23_from_time; m.Z23_sight_from = m_2; } else if (!m_2.Z23_from_time) m.Z23_sight_from = world;
	if (m.Z24_sight_from_time_ > m_2.Z24_from_time) { m.Z24_sight_from_time_ = m_2.Z24_from_time; m.Z24_sight_from = m_2; } else if (!m_2.Z24_from_time) m.Z24_sight_from = world;

	if (m_2_pos_z - m_pos_z >= 40)
	if (vlen(m_2_pos - m_pos) <= 1000)
	{
		if (m.Z1_higher_sight_from_time_ > m_2.Z1_from_time) { m.Z1_higher_sight_from_time_ = m_2.Z1_from_time; m.Z1_higher_sight_from = m_2; } else if (!m_2.Z1_from_time) m.Z1_higher_sight_from = world;
		if (m.Z2_higher_sight_from_time_ > m_2.Z2_from_time) { m.Z2_higher_sight_from_time_ = m_2.Z2_from_time; m.Z2_higher_sight_from = m_2; } else if (!m_2.Z2_from_time) m.Z2_higher_sight_from = world;
		if (m.Z3_higher_sight_from_time_ > m_2.Z3_from_time) { m.Z3_higher_sight_from_time_ = m_2.Z3_from_time; m.Z3_higher_sight_from = m_2; } else if (!m_2.Z3_from_time) m.Z3_higher_sight_from = world;
		if (m.Z4_higher_sight_from_time_ > m_2.Z4_from_time) { m.Z4_higher_sight_from_time_ = m_2.Z4_from_time; m.Z4_higher_sight_from = m_2; } else if (!m_2.Z4_from_time) m.Z4_higher_sight_from = world;
		if (m.Z5_higher_sight_from_time_ > m_2.Z5_from_time) { m.Z5_higher_sight_from_time_ = m_2.Z5_from_time; m.Z5_higher_sight_from = m_2; } else if (!m_2.Z5_from_time) m.Z5_higher_sight_from = world;
		if (m.Z6_higher_sight_from_time_ > m_2.Z6_from_time) { m.Z6_higher_sight_from_time_ = m_2.Z6_from_time; m.Z6_higher_sight_from = m_2; } else if (!m_2.Z6_from_time) m.Z6_higher_sight_from = world;
		if (m.Z7_higher_sight_from_time_ > m_2.Z7_from_time) { m.Z7_higher_sight_from_time_ = m_2.Z7_from_time; m.Z7_higher_sight_from = m_2; } else if (!m_2.Z7_from_time) m.Z7_higher_sight_from = world;
		if (m.Z8_higher_sight_from_time_ > m_2.Z8_from_time) { m.Z8_higher_sight_from_time_ = m_2.Z8_from_time; m.Z8_higher_sight_from = m_2; } else if (!m_2.Z8_from_time) m.Z8_higher_sight_from = world;
		if (m.Z9_higher_sight_from_time_ > m_2.Z9_from_time) { m.Z9_higher_sight_from_time_ = m_2.Z9_from_time; m.Z9_higher_sight_from = m_2; } else if (!m_2.Z9_from_time) m.Z9_higher_sight_from = world;
		if (m.Z10_higher_sight_from_time_ > m_2.Z10_from_time) { m.Z10_higher_sight_from_time_ = m_2.Z10_from_time; m.Z10_higher_sight_from = m_2; } else if (!m_2.Z10_from_time) m.Z10_higher_sight_from = world;
		if (m.Z11_higher_sight_from_time_ > m_2.Z11_from_time) { m.Z11_higher_sight_from_time_ = m_2.Z11_from_time; m.Z11_higher_sight_from = m_2; } else if (!m_2.Z11_from_time) m.Z11_higher_sight_from = world;
		if (m.Z12_higher_sight_from_time_ > m_2.Z12_from_time) { m.Z12_higher_sight_from_time_ = m_2.Z12_from_time; m.Z12_higher_sight_from = m_2; } else if (!m_2.Z12_from_time) m.Z12_higher_sight_from = world;
		if (m.Z13_higher_sight_from_time_ > m_2.Z13_from_time) { m.Z13_higher_sight_from_time_ = m_2.Z13_from_time; m.Z13_higher_sight_from = m_2; } else if (!m_2.Z13_from_time) m.Z13_higher_sight_from = world;
		if (m.Z14_higher_sight_from_time_ > m_2.Z14_from_time) { m.Z14_higher_sight_from_time_ = m_2.Z14_from_time; m.Z14_higher_sight_from = m_2; } else if (!m_2.Z14_from_time) m.Z14_higher_sight_from = world;
		if (m.Z15_higher_sight_from_time_ > m_2.Z15_from_time) { m.Z15_higher_sight_from_time_ = m_2.Z15_from_time; m.Z15_higher_sight_from = m_2; } else if (!m_2.Z15_from_time) m.Z15_higher_sight_from = world;
		if (m.Z16_higher_sight_from_time_ > m_2.Z16_from_time) { m.Z16_higher_sight_from_time_ = m_2.Z16_from_time; m.Z16_higher_sight_from = m_2; } else if (!m_2.Z16_from_time) m.Z16_higher_sight_from = world;
		if (m.Z17_higher_sight_from_time_ > m_2.Z17_from_time) { m.Z17_higher_sight_from_time_ = m_2.Z17_from_time; m.Z17_higher_sight_from = m_2; } else if (!m_2.Z17_from_time) m.Z17_higher_sight_from = world;
		if (m.Z18_higher_sight_from_time_ > m_2.Z18_from_time) { m.Z18_higher_sight_from_time_ = m_2.Z18_from_time; m.Z18_higher_sight_from = m_2; } else if (!m_2.Z18_from_time) m.Z18_higher_sight_from = world;
		if (m.Z19_higher_sight_from_time_ > m_2.Z19_from_time) { m.Z19_higher_sight_from_time_ = m_2.Z19_from_time; m.Z19_higher_sight_from = m_2; } else if (!m_2.Z19_from_time) m.Z19_higher_sight_from = world;
		if (m.Z20_higher_sight_from_time_ > m_2.Z20_from_time) { m.Z20_higher_sight_from_time_ = m_2.Z20_from_time; m.Z20_higher_sight_from = m_2; } else if (!m_2.Z20_from_time) m.Z20_higher_sight_from = world;
		if (m.Z21_higher_sight_from_time_ > m_2.Z21_from_time) { m.Z21_higher_sight_from_time_ = m_2.Z21_from_time; m.Z21_higher_sight_from = m_2; } else if (!m_2.Z21_from_time) m.Z21_higher_sight_from = world;
		if (m.Z22_higher_sight_from_time_ > m_2.Z22_from_time) { m.Z22_higher_sight_from_time_ = m_2.Z22_from_time; m.Z22_higher_sight_from = m_2; } else if (!m_2.Z22_from_time) m.Z22_higher_sight_from = world;
		if (m.Z23_higher_sight_from_time_ > m_2.Z23_from_time) { m.Z23_higher_sight_from_time_ = m_2.Z23_from_time; m.Z23_higher_sight_from = m_2; } else if (!m_2.Z23_from_time) m.Z23_higher_sight_from = world;
		if (m.Z24_higher_sight_from_time_ > m_2.Z24_from_time) { m.Z24_higher_sight_from_time_ = m_2.Z24_from_time; m.Z24_higher_sight_from = m_2; } else if (!m_2.Z24_from_time) m.Z24_higher_sight_from = world;
	}
};

/*
============
Calc_G_time_9

============
*/
void() Calc_G_time_9 =
{
// Note: Max 100000 commands in a function call

	self.nextthink = 0.001;

	count_ = 200;

	while (count_)
	{
		m_pos = m.absmin + m.view_ofs + '0 0 32';
		m_2_pos = m_2.absmin + m_2.view_ofs + '0 0 32';

		traceline(m_pos, m_2_pos, TRUE, world);
		if (trace_fraction == 1)
		if (m_2.classname != "trigger_teleport")
			Calc_G_time_9_apply();


/*
// --------------
		path_normal = FALSE;
		Calc_G_time_9_apply2();
		path_normal = TRUE;
		Calc_G_time_9_apply2();

// -------
*/

		count_ = count_ - 1;

		m_2 = m_2.marker_link;

		if (!m_2)
		{
			m_2 = first_marker;

			m = m.marker_link;

			if (!m)
			{
				m = first_marker;

				dropper.use = Calc_G_time_10_path;
				dropper.think = Calc_G_time_path;
				set_load();
				return;
			}
		}
	}
};

/*
============
Calc_G_time_10_path

============
*/
void() Calc_G_time_10_path =
{
	if (m.Z1_sight_from_time_ < (m_P.Z1_sight_from_time_ - P_time)) { no_change = FALSE; m.Z1_sight_from_time_ = m_P.Z1_sight_from_time_ - P_time; }
	if (m.Z2_sight_from_time_ < (m_P.Z2_sight_from_time_ - P_time)) { no_change = FALSE; m.Z2_sight_from_time_ = m_P.Z2_sight_from_time_ - P_time; }
	if (m.Z3_sight_from_time_ < (m_P.Z3_sight_from_time_ - P_time)) { no_change = FALSE; m.Z3_sight_from_time_ = m_P.Z3_sight_from_time_ - P_time; }
	if (m.Z4_sight_from_time_ < (m_P.Z4_sight_from_time_ - P_time)) { no_change = FALSE; m.Z4_sight_from_time_ = m_P.Z4_sight_from_time_ - P_time; }
	if (m.Z5_sight_from_time_ < (m_P.Z5_sight_from_time_ - P_time)) { no_change = FALSE; m.Z5_sight_from_time_ = m_P.Z5_sight_from_time_ - P_time; }
	if (m.Z6_sight_from_time_ < (m_P.Z6_sight_from_time_ - P_time)) { no_change = FALSE; m.Z6_sight_from_time_ = m_P.Z6_sight_from_time_ - P_time; }
	if (m.Z7_sight_from_time_ < (m_P.Z7_sight_from_time_ - P_time)) { no_change = FALSE; m.Z7_sight_from_time_ = m_P.Z7_sight_from_time_ - P_time; }
	if (m.Z8_sight_from_time_ < (m_P.Z8_sight_from_time_ - P_time)) { no_change = FALSE; m.Z8_sight_from_time_ = m_P.Z8_sight_from_time_ - P_time; }
	if (m.Z9_sight_from_time_ < (m_P.Z9_sight_from_time_ - P_time)) { no_change = FALSE; m.Z9_sight_from_time_ = m_P.Z9_sight_from_time_ - P_time; }
	if (m.Z10_sight_from_time_ < (m_P.Z10_sight_from_time_ - P_time)) { no_change = FALSE; m.Z10_sight_from_time_ = m_P.Z10_sight_from_time_ - P_time; }
	if (m.Z11_sight_from_time_ < (m_P.Z11_sight_from_time_ - P_time)) { no_change = FALSE; m.Z11_sight_from_time_ = m_P.Z11_sight_from_time_ - P_time; }
	if (m.Z12_sight_from_time_ < (m_P.Z12_sight_from_time_ - P_time)) { no_change = FALSE; m.Z12_sight_from_time_ = m_P.Z12_sight_from_time_ - P_time; }
	if (m.Z13_sight_from_time_ < (m_P.Z13_sight_from_time_ - P_time)) { no_change = FALSE; m.Z13_sight_from_time_ = m_P.Z13_sight_from_time_ - P_time; }
	if (m.Z14_sight_from_time_ < (m_P.Z14_sight_from_time_ - P_time)) { no_change = FALSE; m.Z14_sight_from_time_ = m_P.Z14_sight_from_time_ - P_time; }
	if (m.Z15_sight_from_time_ < (m_P.Z15_sight_from_time_ - P_time)) { no_change = FALSE; m.Z15_sight_from_time_ = m_P.Z15_sight_from_time_ - P_time; }
	if (m.Z16_sight_from_time_ < (m_P.Z16_sight_from_time_ - P_time)) { no_change = FALSE; m.Z16_sight_from_time_ = m_P.Z16_sight_from_time_ - P_time; }
	if (m.Z17_sight_from_time_ < (m_P.Z17_sight_from_time_ - P_time)) { no_change = FALSE; m.Z17_sight_from_time_ = m_P.Z17_sight_from_time_ - P_time; }
	if (m.Z18_sight_from_time_ < (m_P.Z18_sight_from_time_ - P_time)) { no_change = FALSE; m.Z18_sight_from_time_ = m_P.Z18_sight_from_time_ - P_time; }
	if (m.Z19_sight_from_time_ < (m_P.Z19_sight_from_time_ - P_time)) { no_change = FALSE; m.Z19_sight_from_time_ = m_P.Z19_sight_from_time_ - P_time; }
	if (m.Z20_sight_from_time_ < (m_P.Z20_sight_from_time_ - P_time)) { no_change = FALSE; m.Z20_sight_from_time_ = m_P.Z20_sight_from_time_ - P_time; }
	if (m.Z21_sight_from_time_ < (m_P.Z21_sight_from_time_ - P_time)) { no_change = FALSE; m.Z21_sight_from_time_ = m_P.Z21_sight_from_time_ - P_time; }
	if (m.Z22_sight_from_time_ < (m_P.Z22_sight_from_time_ - P_time)) { no_change = FALSE; m.Z22_sight_from_time_ = m_P.Z22_sight_from_time_ - P_time; }
	if (m.Z23_sight_from_time_ < (m_P.Z23_sight_from_time_ - P_time)) { no_change = FALSE; m.Z23_sight_from_time_ = m_P.Z23_sight_from_time_ - P_time; }
	if (m.Z24_sight_from_time_ < (m_P.Z24_sight_from_time_ - P_time)) { no_change = FALSE; m.Z24_sight_from_time_ = m_P.Z24_sight_from_time_ - P_time; }
};

/*
============
Calc_G_time_11_apply

============
*/
void() Calc_G_time_11_apply =
{
	min_traveltime = min_traveltime + 1.25;
	runaway_score = runaway_score * 0.125;

	if (m.RA0 == next_marker)
	{
		if (m.RA0_score >= runaway_score)
			return;
		m.RA0_prev = prev_marker;
		m.RA0_score = runaway_score;
		m.RA0_time = runaway_time;
		return;
	}

	if (m.RA1 == next_marker)
	{
		if (m.RA1_score >= runaway_score)
			return;
		m.RA1_prev = prev_marker;
		m.RA1_score = runaway_score;
		m.RA1_time = runaway_time;
	}
	else
	{
		if (m.RA2 == next_marker)
		{
			if (m.RA2_score >= runaway_score)
				return;
			m.RA2_prev = prev_marker;
			m.RA2_score = runaway_score;
			m.RA2_time = runaway_time;
		}
		else
		{
			if (m.RA3 == next_marker)
			{
				if (m.RA3_score >= runaway_score)
					return;
				m.RA3_prev = prev_marker;
				m.RA3_score = runaway_score;
				m.RA3_time = runaway_time;
			}
			else
			{
				if (m.RA4 == next_marker)
				{
					if (m.RA4_score >= runaway_score)
						return;
					m.RA4_prev = prev_marker;
					m.RA4_score = runaway_score;
					m.RA4_time = runaway_time;
				}
				else
				{
					if (m.RA5 == next_marker)
					{
						if (m.RA5_score >= runaway_score)
							return;
						m.RA5_prev = prev_marker;
						m.RA5_score = runaway_score;
						m.RA5_time = runaway_time;
					}
					else
					{
						if (m.RA6 == next_marker)
						{
							if (m.RA6_score >= runaway_score)
								return;
							m.RA6_prev = prev_marker;
							m.RA6_score = runaway_score;
							m.RA6_time = runaway_time;
						}
						else
						{
							if (m.RA7_score < runaway_score)
							{
								m.RA7 = next_marker;
								m.RA7_prev = prev_marker;
								m.RA7_score = runaway_score;
								m.RA7_time = runaway_time;
							}
							else
								return;

							if (m.RA6_score < m.RA7_score)
							{
								runaway_marker_temp = m.RA7;
								runaway_prev_temp = m.RA7_prev;
								runaway_score_temp = m.RA7_score;
								runaway_time_temp = m.RA7_time;

								m.RA7 = m.RA6;
								m.RA7_prev = m.RA6_prev;
								m.RA7_score = m.RA6_score;
								m.RA7_time = m.RA6_time;

								m.RA6 = runaway_marker_temp;
								m.RA6_prev = runaway_prev_temp;
								m.RA6_score = runaway_score_temp;
								m.RA6_time = runaway_time_temp;
							}
						}

						if (m.RA5_score < m.RA6_score)
						{
							runaway_marker_temp = m.RA6;
							runaway_prev_temp = m.RA6_prev;
							runaway_score_temp = m.RA6_score;
							runaway_time_temp = m.RA6_time;

							m.RA6 = m.RA5;
							m.RA6_prev = m.RA5_prev;
							m.RA6_score = m.RA5_score;
							m.RA6_time = m.RA5_time;

							m.RA5 = runaway_marker_temp;
							m.RA5_prev = runaway_prev_temp;
							m.RA5_score = runaway_score_temp;
							m.RA5_time = runaway_time_temp;
						}
					}

					if (m.RA4_score < m.RA5_score)
					{
						runaway_marker_temp = m.RA5;
						runaway_prev_temp = m.RA5_prev;
						runaway_score_temp = m.RA5_score;
						runaway_time_temp = m.RA5_time;

						m.RA5 = m.RA4;
						m.RA5_prev = m.RA4_prev;
						m.RA5_score = m.RA4_score;
						m.RA5_time = m.RA4_time;

						m.RA4 = runaway_marker_temp;
						m.RA4_prev = runaway_prev_temp;
						m.RA4_score = runaway_score_temp;
						m.RA4_time = runaway_time_temp;
					}
				}

				if (m.RA3_score < m.RA4_score)
				{
					runaway_marker_temp = m.RA4;
					runaway_prev_temp = m.RA4_prev;
					runaway_score_temp = m.RA4_score;
					runaway_time_temp = m.RA4_time;

					m.RA4 = m.RA3;
					m.RA4_prev = m.RA3_prev;
					m.RA4_score = m.RA3_score;
					m.RA4_time = m.RA3_time;

					m.RA3 = runaway_marker_temp;
					m.RA3_prev = runaway_prev_temp;
					m.RA3_score = runaway_score_temp;
					m.RA3_time = runaway_time_temp;
				}
			}

			if (m.RA2_score < m.RA3_score)
			{
				runaway_marker_temp = m.RA3;
				runaway_prev_temp = m.RA3_prev;
				runaway_score_temp = m.RA3_score;
				runaway_time_temp = m.RA3_time;

				m.RA3 = m.RA2;
				m.RA3_prev = m.RA2_prev;
				m.RA3_score = m.RA2_score;
				m.RA3_time = m.RA2_time;

				m.RA2 = runaway_marker_temp;
				m.RA2_prev = runaway_prev_temp;
				m.RA2_score = runaway_score_temp;
				m.RA2_time = runaway_time_temp;
			}
		}

		if (m.RA1_score < m.RA2_score)
		{
			runaway_marker_temp = m.RA2;
			runaway_prev_temp = m.RA2_prev;
			runaway_score_temp = m.RA2_score;
			runaway_time_temp = m.RA2_time;

			m.RA2 = m.RA1;
			m.RA2_prev = m.RA1_prev;
			m.RA2_score = m.RA1_score;
			m.RA2_time = m.RA1_time;

			m.RA1 = runaway_marker_temp;
			m.RA1_prev = runaway_prev_temp;
			m.RA1_score = runaway_score_temp;
			m.RA1_time = runaway_time_temp;
		}
	}

	if (m.RA0_score < m.RA1_score)
	{
		runaway_marker_temp = m.RA1;
		runaway_prev_temp = m.RA1_prev;
		runaway_score_temp = m.RA1_score;
		runaway_time_temp = m.RA1_time;

		m.RA1 = m.RA0;
		m.RA1_prev = m.RA0_prev;
		m.RA1_score = m.RA0_score;
		m.RA1_time = m.RA0_time;

		m.RA0 = runaway_marker_temp;
		m.RA0_prev = runaway_prev_temp;
		m.RA0_score = runaway_score_temp;
		m.RA0_time = runaway_time_temp;
	}
};

/*
============
Calc_G_time_11

============
*/
void() Calc_G_time_11 =
{
// Note: Max 100000 commands in a function call

	self.nextthink = 0.001;

	count_ = 2;

	while (count_)
	{
		while (m_zone)
		{
			from_marker = m;
			m_zone.zone_marker();
			if (middle_marker != dropper)
			if (middle_marker != m)
			{
				runaway_dest = middle_marker;

				if (path_normal)
					runaway_time = zone_time;
				else
					runaway_time = zone_time + 5;
				runaway_score = runaway_time;

				next_marker = m;
				min_traveltime = 1.25;

				do
				{
					from_marker = prev_marker = next_marker;
					runaway_dest.path_marker();

					from_marker = m;
					next_marker.zone_marker();
					next_marker.sub_arrival_time();

					if (traveltime >= min_traveltime)
					if (next_marker.classname != "trigger_teleport")
						Calc_G_time_11_apply();
				} while (next_marker != runaway_dest);
			}
			m_zone = m_zone.zone_stack_next;
		}

		m_zone = zone_stack_head;

		count_ = count_ - 1;

		m = m.marker_link;

		if (!m)
		{
			m = first_marker;

			if (path_normal)
				path_normal = FALSE;
			else
			{
				path_normal = TRUE;

				dropper.think = Calc_G_time_12;
				set_load();
				return;
			}
		}
	}
};

/*
============
Calc_G_time_12

============
*/
void() Calc_G_time_12 =
{
// Note: Max 100000 commands in a function call

	self.nextthink = 0.001;

	count_ = 2;

	while (count_)
	{
		middle_marker = m;
		zone_time = 0;
		m_pos = m.absmin + m.view_ofs + '0 0 32';

		runaway_dest = m.Z_head;
		while (runaway_dest)
		{
			if (runaway_dest != m)
			{
				from_marker = m;
				runaway_dest.sub_arrival_time();
				if (traveltime < 1000000)
				{
					runaway_score = runaway_time = traveltime;

					next_marker = m;
					min_traveltime = 1.25;

					do
					{
						from_marker = prev_marker = next_marker;
						runaway_dest.sub_path_marker();

						traceline(m_pos, next_marker.absmin + next_marker.view_ofs + '0 0 32', TRUE, world);
						if (trace_fraction != 1)
						{
							from_marker = m;
							next_marker.sub_arrival_time();

							if (traveltime >= min_traveltime)
							if (next_marker.classname != "trigger_teleport")
								Calc_G_time_11_apply();
						}
					} while (next_marker != runaway_dest);
				}
			}
			runaway_dest = runaway_dest.Z_next;
		}

		count_ = count_ - 1;

		m = m.marker_link;

		if (!m)
		{
			m = first_marker;

			dropper.think = Calc_G_time_13;
			set_load();
			return;
		}
	}
};

/*
============
Check_RA_type2

============
*/
void() Check_RA_type2 =
{
	if (to_marker)
	if (to_marker != next_marker)
	{
		to_marker.zone_marker();
		to_marker.sub_arrival_time();
		traveltime3 = traveltime;

		if (traveltime3 < 5)
		{
			path_normal = FALSE;

			from_marker = next_marker;
			to_marker.zone_marker();
			to_marker.sub_arrival_time();
			traveltime2 = traveltime;

			from_marker = prev_marker;
			to_marker.zone_marker();
			to_marker.sub_arrival_time();

			if (traveltime2 < traveltime)
			{
				from_marker = m;
				next_marker.zone_marker();
				next_marker.sub_arrival_time();
				traveltime2 = traveltime + traveltime2;

				if (traveltime2 < (traveltime3 + 0.5))
					RA_type = THROUGH_NODE;
			}

			path_normal = TRUE;
		}
	}
};

/*
============
Check_RA_type

============
*/
void() Check_RA_type =
{
	RA_type = 0;

	to_marker = m.RA0;
	Check_RA_type2();

	to_marker = m.RA1;
	Check_RA_type2();

	to_marker = m.RA2;
	Check_RA_type2();

	to_marker = m.RA3;
	Check_RA_type2();

	to_marker = m.RA4;
	Check_RA_type2();

	to_marker = m.RA5;
	Check_RA_type2();

	to_marker = m.RA6;
	Check_RA_type2();

	to_marker = m.RA7;
	Check_RA_type2();
};

/*
============
Calc_G_time_13

============
*/
void() Calc_G_time_13 =
{
// Note: Max 100000 commands in a function call

	self.nextthink = 0.001;

	count_ = 25;

	while (count_)
	{
		next_marker = m.RA0;
		if (next_marker)
		{
			prev_marker = m.RA0_prev;
			Check_RA_type();
			m.RA0_type = RA_type;
		}

		next_marker = m.RA1;
		if (next_marker)
		{
			prev_marker = m.RA1_prev;
			Check_RA_type();
			m.RA1_type = RA_type;
		}

		next_marker = m.RA2;
		if (next_marker)
		{
			prev_marker = m.RA2_prev;
			Check_RA_type();
			m.RA2_type = RA_type;
		}

		next_marker = m.RA3;
		if (next_marker)
		{
			prev_marker = m.RA3_prev;
			Check_RA_type();
			m.RA3_type = RA_type;
		}

		next_marker = m.RA4;
		if (next_marker)
		{
			prev_marker = m.RA4_prev;
			Check_RA_type();
			m.RA4_type = RA_type;
		}

		next_marker = m.RA5;
		if (next_marker)
		{
			prev_marker = m.RA5_prev;
			Check_RA_type();
			m.RA5_type = RA_type;
		}

		next_marker = m.RA6;
		if (next_marker)
		{
			prev_marker = m.RA6_prev;
			Check_RA_type();
			m.RA6_type = RA_type;
		}

		next_marker = m.RA7;
		if (next_marker)
		{
			prev_marker = m.RA7_prev;
			Check_RA_type();
			m.RA7_type = RA_type;
		}

		count_ = count_ - 1;

		m = m.marker_link;

		if (!m)
		{
			m = first_marker;

			dropper.think = Calc_G_time_14;
			set_load();
			return;
		}
	}
};

/*
============
Calc_G_time_14

============
*/
void() Calc_G_time_14 =
{
// Note: Max 100000 commands in a function call

	self.nextthink = 0.001;

	count_ = 2;

	while (count_)
	{
		while (m_zone)
		{
			from_marker = m;
			m_zone.zone_marker();
			if (middle_marker != dropper)
			if (traveltime >= 5)
			{
				Z1_path_success = TRUE;
				Z8_path_success = TRUE;

				runaway_dest = middle_marker;

				next_marker = m;
				while (next_marker != runaway_dest)
				{
					from_marker = m;
					next_marker.zone_marker();
					next_marker.sub_arrival_time();

					if (next_marker.Z1_higher_sight_from_time_ <= traveltime) Z1_path_success = FALSE;
					if (next_marker.Z8_higher_sight_from_time_ <= traveltime) Z8_path_success = FALSE;

					from_marker = next_marker;
					runaway_dest.path_marker();
				}

				if (Z1_path_success) m.Z1_height_equal_time = 0;
				if (Z8_path_success) m.Z8_height_equal_time = 0;
			}
			m_zone = m_zone.zone_stack_next;
		}

		m_zone = zone_stack_head;

		count_ = count_ - 1;

		m = m.marker_link;

		if (!m)
		{
			m = first_marker;

			if (path_normal)
				path_normal = FALSE;
			else
			{
				path_normal = TRUE;

				dropper.think = remove_load;
				set_load();
				return;
			}
		}
	}
};