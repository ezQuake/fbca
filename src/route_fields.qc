/*
	route_fields.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
*/

//
// Goals
//

void(entity marker) G1 = { marker.G1_ = marker; marker.G_ = 1; };
void(entity marker) G2 = { marker.G2_ = marker; marker.G_ = 2; };
void(entity marker) G3 = { marker.G3_ = marker; marker.G_ = 3; };
void(entity marker) G4 = { marker.G4_ = marker; marker.G_ = 4; };
void(entity marker) G5 = { marker.G5_ = marker; marker.G_ = 5; };
void(entity marker) G6 = { marker.G6_ = marker; marker.G_ = 6; };
void(entity marker) G7 = { marker.G7_ = marker; marker.G_ = 7; };
void(entity marker) G8 = { marker.G8_ = marker; marker.G_ = 8; };
void(entity marker) G9 = { marker.G9_ = marker; marker.G_ = 9; };
void(entity marker) G10 = { marker.G10_ = marker; marker.G_ = 10; };
void(entity marker) G11 = { marker.G11_ = marker; marker.G_ = 11; };
void(entity marker) G12 = { marker.G12_ = marker; marker.G_ = 12; };
void(entity marker) G13 = { marker.G13_ = marker; marker.G_ = 13; };
void(entity marker) G14 = { marker.G14_ = marker; marker.G_ = 14; };
void(entity marker) G15 = { marker.G15_ = marker; marker.G_ = 15; };
void(entity marker) G16 = { marker.G16_ = marker; marker.G_ = 16; };
void(entity marker) G17 = { marker.G17_ = marker; marker.G_ = 17; };
void(entity marker) G18 = { marker.G18_ = marker; marker.G_ = 18; };
void(entity marker) G19 = { marker.G19_ = marker; marker.G_ = 19; };
void(entity marker) G20 = { marker.G20_ = marker; marker.G_ = 20; };
void(entity marker) G21 = { marker.G21_ = marker; marker.G_ = 21; };
void(entity marker) G22 = { marker.G22_ = marker; marker.G_ = 22; };
void(entity marker) G23 = { marker.G23_ = marker; marker.G_ = 23; };
void(entity marker) G24 = { marker.G24_ = marker; marker.G_ = 24; };


//
// Sub-zones
//

void(entity marker) Set_sub_arrival_time =
{
	marker.S_ = S_index;
	if (S_index <= 16)
	{
		if (S_index <= 8)
		{
			if (S_index <= 4)
			{
				if (S_index <= 2)
				{
					if (S_index == 1)
					{
						marker.sub_arrival_time = S1_time_;
						marker.sub_path_marker = S1_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S2_time_;
						marker.sub_path_marker = S2_path_marker;
					}
				}
				else
				{
					if (S_index == 3)
					{
						marker.sub_arrival_time = S3_time_;
						marker.sub_path_marker = S3_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S4_time_;
						marker.sub_path_marker = S4_path_marker;
					}
				}
			}
			else
			{
				if (S_index <= 6)
				{
					if (S_index == 5)
					{
						marker.sub_arrival_time = S5_time_;
						marker.sub_path_marker = S5_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S6_time_;
						marker.sub_path_marker = S6_path_marker;
					}
				}
				else
				{
					if (S_index == 7)
					{
						marker.sub_arrival_time = S7_time_;
						marker.sub_path_marker = S7_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S8_time_;
						marker.sub_path_marker = S8_path_marker;
					}
				}
			}
		}
		else
		{
			if (S_index <= 12)
			{
				if (S_index <= 10)
				{
					if (S_index == 9)
					{
						marker.sub_arrival_time = S9_time_;
						marker.sub_path_marker = S9_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S10_time_;
						marker.sub_path_marker = S10_path_marker;
					}
				}
				else
				{
					if (S_index == 11)
					{
						marker.sub_arrival_time = S11_time_;
						marker.sub_path_marker = S11_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S12_time_;
						marker.sub_path_marker = S12_path_marker;
					}
				}
			}
			else
			{
				if (S_index <= 14)
				{
					if (S_index == 13)
					{
						marker.sub_arrival_time = S13_time_;
						marker.sub_path_marker = S13_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S14_time_;
						marker.sub_path_marker = S14_path_marker;
					}
				}
				else
				{
					if (S_index == 15)
					{
						marker.sub_arrival_time = S15_time_;
						marker.sub_path_marker = S15_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S16_time_;
						marker.sub_path_marker = S16_path_marker;
					}
				}
			}
		}
	}
	else if (S_index <= 32)
	{
		if (S_index <= 24)
		{
			if (S_index <= 20)
			{
				if (S_index <= 18)
				{
					if (S_index == 17)
					{
						marker.sub_arrival_time = S17_time_;
						marker.sub_path_marker = S17_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S18_time_;
						marker.sub_path_marker = S18_path_marker;
					}
				}
				else
				{
					if (S_index == 19)
					{
						marker.sub_arrival_time = S19_time_;
						marker.sub_path_marker = S19_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S20_time_;
						marker.sub_path_marker = S20_path_marker;
					}
				}
			}
			else
			{
				if (S_index <= 22)
				{
					if (S_index == 21)
					{
						marker.sub_arrival_time = S21_time_;
						marker.sub_path_marker = S21_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S22_time_;
						marker.sub_path_marker = S22_path_marker;
					}
				}
				else
				{
					if (S_index == 23)
					{
						marker.sub_arrival_time = S23_time_;
						marker.sub_path_marker = S23_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S24_time_;
						marker.sub_path_marker = S24_path_marker;
					}
				}
			}
		}
		else
		{
			if (S_index <= 28)
			{
				if (S_index <= 26)
				{
					if (S_index == 25)
					{
						marker.sub_arrival_time = S25_time_;
						marker.sub_path_marker = S25_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S26_time_;
						marker.sub_path_marker = S26_path_marker;
					}
				}
				else
				{
					if (S_index == 27)
					{
						marker.sub_arrival_time = S27_time_;
						marker.sub_path_marker = S27_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S28_time_;
						marker.sub_path_marker = S28_path_marker;
					}
				}
			}
			else
			{
				if (S_index <= 30)
				{
					if (S_index == 29)
					{
						marker.sub_arrival_time = S29_time_;
						marker.sub_path_marker = S29_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S30_time_;
						marker.sub_path_marker = S30_path_marker;
					}
				}
				else
				{
					if (S_index == 31)
					{
						marker.sub_arrival_time = S31_time_;
						marker.sub_path_marker = S31_path_marker;
					}
					else
					{
						marker.sub_arrival_time = S32_time_;
						marker.sub_path_marker = S32_path_marker;
					}
				}
			}
		}
	}
};


//
// Zones
//

void(entity marker) Z1 =
{
	Z1_S_index = Z1_S_index + 1;
	S_index = Z1_S_index;
	Set_sub_arrival_time(marker);
	marker.Z1_ = marker.Z1_rev = marker.Z1_next_zone = marker.Z1_next = marker;
	marker.Z_ = 1;
	marker.zone_marker = Z1_marker;
	marker.next_zone_marker = Z1_next_zone_marker;
	marker.path_marker = Z1_path_marker;
	marker.sight_from_marker = Z1_sight_from_marker;
	marker.higher_sight_from_marker = Z1_higher_sight_from_marker;
	marker.sight_from_time = Z1_sight_from_time;

	if (Z1_tail)
	{
		Z1_tail.Z_next = marker;
		Z1_tail = marker;
	}
	else
	{
		Z1_head = Z1_tail = marker;
		Z1_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z1_head;
	}

	marker.Z_head = Z1_head;
};

void(entity marker) Z2 =
{
	Z2_S_index = Z2_S_index + 1;
	S_index = Z2_S_index;
	Set_sub_arrival_time(marker);
	marker.Z2_ = marker.Z2_rev = marker.Z2_next_zone = marker.Z2_next = marker;
	marker.Z_ = 2;
	marker.zone_marker = Z2_marker;
	marker.next_zone_marker = Z2_next_zone_marker;
	marker.path_marker = Z2_path_marker;
	marker.sight_from_marker = Z2_sight_from_marker;
	marker.higher_sight_from_marker = Z2_higher_sight_from_marker;
	marker.sight_from_time = Z2_sight_from_time;

	if (Z2_tail)
	{
		Z2_tail.Z_next = marker;
		Z2_tail = marker;
	}
	else
	{
		Z2_head = Z2_tail = marker;
		Z2_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z2_head;
	}

	marker.Z_head = Z2_head;
};

void(entity marker) Z3 =
{
	Z3_S_index = Z3_S_index + 1;
	S_index = Z3_S_index;
	Set_sub_arrival_time(marker);
	marker.Z3_ = marker.Z3_rev = marker.Z3_next_zone = marker.Z3_next = marker;
	marker.Z_ = 3;
	marker.zone_marker = Z3_marker;
	marker.next_zone_marker = Z3_next_zone_marker;
	marker.path_marker = Z3_path_marker;
	marker.sight_from_marker = Z3_sight_from_marker;
	marker.higher_sight_from_marker = Z3_higher_sight_from_marker;
	marker.sight_from_time = Z3_sight_from_time;

	if (Z3_tail)
	{
		Z3_tail.Z_next = marker;
		Z3_tail = marker;
	}
	else
	{
		Z3_head = Z3_tail = marker;
		Z3_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z3_head;
	}

	marker.Z_head = Z3_head;
};

void(entity marker) Z4 =
{
	Z4_S_index = Z4_S_index + 1;
	S_index = Z4_S_index;
	Set_sub_arrival_time(marker);
	marker.Z4_ = marker.Z4_rev = marker.Z4_next_zone = marker.Z4_next = marker;
	marker.Z_ = 4;
	marker.zone_marker = Z4_marker;
	marker.next_zone_marker = Z4_next_zone_marker;
	marker.path_marker = Z4_path_marker;
	marker.sight_from_marker = Z4_sight_from_marker;
	marker.higher_sight_from_marker = Z4_higher_sight_from_marker;
	marker.sight_from_time = Z4_sight_from_time;

	if (Z4_tail)
	{
		Z4_tail.Z_next = marker;
		Z4_tail = marker;
	}
	else
	{
		Z4_head = Z4_tail = marker;
		Z4_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z4_head;
	}

	marker.Z_head = Z4_head;
};

void(entity marker) Z5 =
{
	Z5_S_index = Z5_S_index + 1;
	S_index = Z5_S_index;
	Set_sub_arrival_time(marker);
	marker.Z5_ = marker.Z5_rev = marker.Z5_next_zone = marker.Z5_next = marker;
	marker.Z_ = 5;
	marker.zone_marker = Z5_marker;
	marker.next_zone_marker = Z5_next_zone_marker;
	marker.path_marker = Z5_path_marker;
	marker.sight_from_marker = Z5_sight_from_marker;
	marker.higher_sight_from_marker = Z5_higher_sight_from_marker;
	marker.sight_from_time = Z5_sight_from_time;

	if (Z5_tail)
	{
		Z5_tail.Z_next = marker;
		Z5_tail = marker;
	}
	else
	{
		Z5_head = Z5_tail = marker;
		Z5_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z5_head;
	}

	marker.Z_head = Z5_head;
};

void(entity marker) Z6 =
{
	Z6_S_index = Z6_S_index + 1;
	S_index = Z6_S_index;
	Set_sub_arrival_time(marker);
	marker.Z6_ = marker.Z6_rev = marker.Z6_next_zone = marker.Z6_next = marker;
	marker.Z_ = 6;
	marker.zone_marker = Z6_marker;
	marker.next_zone_marker = Z6_next_zone_marker;
	marker.path_marker = Z6_path_marker;
	marker.sight_from_marker = Z6_sight_from_marker;
	marker.higher_sight_from_marker = Z6_higher_sight_from_marker;
	marker.sight_from_time = Z6_sight_from_time;

	if (Z6_tail)
	{
		Z6_tail.Z_next = marker;
		Z6_tail = marker;
	}
	else
	{
		Z6_head = Z6_tail = marker;
		Z6_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z6_head;
	}

	marker.Z_head = Z6_head;
};

void(entity marker) Z7 =
{
	Z7_S_index = Z7_S_index + 1;
	S_index = Z7_S_index;
	Set_sub_arrival_time(marker);
	marker.Z7_ = marker.Z7_rev = marker.Z7_next_zone = marker.Z7_next = marker;
	marker.Z_ = 7;
	marker.zone_marker = Z7_marker;
	marker.next_zone_marker = Z7_next_zone_marker;
	marker.path_marker = Z7_path_marker;
	marker.sight_from_marker = Z7_sight_from_marker;
	marker.higher_sight_from_marker = Z7_higher_sight_from_marker;
	marker.sight_from_time = Z7_sight_from_time;

	if (Z7_tail)
	{
		Z7_tail.Z_next = marker;
		Z7_tail = marker;
	}
	else
	{
		Z7_head = Z7_tail = marker;
		Z7_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z7_head;
	}

	marker.Z_head = Z7_head;
};

void(entity marker) Z8 =
{
	Z8_S_index = Z8_S_index + 1;
	S_index = Z8_S_index;
	Set_sub_arrival_time(marker);
	marker.Z8_ = marker.Z8_rev = marker.Z8_next_zone = marker.Z8_next = marker;
	marker.Z_ = 8;
	marker.zone_marker = Z8_marker;
	marker.next_zone_marker = Z8_next_zone_marker;
	marker.path_marker = Z8_path_marker;
	marker.sight_from_marker = Z8_sight_from_marker;
	marker.higher_sight_from_marker = Z8_higher_sight_from_marker;
	marker.sight_from_time = Z8_sight_from_time;

	if (Z8_tail)
	{
		Z8_tail.Z_next = marker;
		Z8_tail = marker;
	}
	else
	{
		Z8_head = Z8_tail = marker;
		Z8_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z8_head;
	}

	marker.Z_head = Z8_head;
};

void(entity marker) Z9 =
{
	Z9_S_index = Z9_S_index + 1;
	S_index = Z9_S_index;
	Set_sub_arrival_time(marker);
	marker.Z9_ = marker.Z9_rev = marker.Z9_next_zone = marker.Z9_next = marker;
	marker.Z_ = 9;
	marker.zone_marker = Z9_marker;
	marker.next_zone_marker = Z9_next_zone_marker;
	marker.path_marker = Z9_path_marker;
	marker.sight_from_marker = Z9_sight_from_marker;
	marker.higher_sight_from_marker = Z9_higher_sight_from_marker;
	marker.sight_from_time = Z9_sight_from_time;

	if (Z9_tail)
	{
		Z9_tail.Z_next = marker;
		Z9_tail = marker;
	}
	else
	{
		Z9_head = Z9_tail = marker;
		Z9_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z9_head;
	}

	marker.Z_head = Z9_head;
};

void(entity marker) Z10 =
{
	Z10_S_index = Z10_S_index + 1;
	S_index = Z10_S_index;
	Set_sub_arrival_time(marker);
	marker.Z10_ = marker.Z10_rev = marker.Z10_next_zone = marker.Z10_next = marker;
	marker.Z_ = 10;
	marker.zone_marker = Z10_marker;
	marker.next_zone_marker = Z10_next_zone_marker;
	marker.path_marker = Z10_path_marker;
	marker.sight_from_marker = Z10_sight_from_marker;
	marker.higher_sight_from_marker = Z10_higher_sight_from_marker;
	marker.sight_from_time = Z10_sight_from_time;

	if (Z10_tail)
	{
		Z10_tail.Z_next = marker;
		Z10_tail = marker;
	}
	else
	{
		Z10_head = Z10_tail = marker;
		Z10_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z10_head;
	}

	marker.Z_head = Z10_head;
};

void(entity marker) Z11 =
{
	Z11_S_index = Z11_S_index + 1;
	S_index = Z11_S_index;
	Set_sub_arrival_time(marker);
	marker.Z11_ = marker.Z11_rev = marker.Z11_next_zone = marker.Z11_next = marker;
	marker.Z_ = 11;
	marker.zone_marker = Z11_marker;
	marker.next_zone_marker = Z11_next_zone_marker;
	marker.path_marker = Z11_path_marker;
	marker.sight_from_marker = Z11_sight_from_marker;
	marker.higher_sight_from_marker = Z11_higher_sight_from_marker;
	marker.sight_from_time = Z11_sight_from_time;

	if (Z11_tail)
	{
		Z11_tail.Z_next = marker;
		Z11_tail = marker;
	}
	else
	{
		Z11_head = Z11_tail = marker;
		Z11_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z11_head;
	}

	marker.Z_head = Z11_head;
};

void(entity marker) Z12 =
{
	Z12_S_index = Z12_S_index + 1;
	S_index = Z12_S_index;
	Set_sub_arrival_time(marker);
	marker.Z12_ = marker.Z12_rev = marker.Z12_next_zone = marker.Z12_next = marker;
	marker.Z_ = 12;
	marker.zone_marker = Z12_marker;
	marker.next_zone_marker = Z12_next_zone_marker;
	marker.path_marker = Z12_path_marker;
	marker.sight_from_marker = Z12_sight_from_marker;
	marker.higher_sight_from_marker = Z12_higher_sight_from_marker;
	marker.sight_from_time = Z12_sight_from_time;

	if (Z12_tail)
	{
		Z12_tail.Z_next = marker;
		Z12_tail = marker;
	}
	else
	{
		Z12_head = Z12_tail = marker;
		Z12_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z12_head;
	}

	marker.Z_head = Z12_head;
};

void(entity marker) Z13 =
{
	Z13_S_index = Z13_S_index + 1;
	S_index = Z13_S_index;
	Set_sub_arrival_time(marker);
	marker.Z13_ = marker.Z13_rev = marker.Z13_next_zone = marker.Z13_next = marker;
	marker.Z_ = 13;
	marker.zone_marker = Z13_marker;
	marker.next_zone_marker = Z13_next_zone_marker;
	marker.path_marker = Z13_path_marker;
	marker.sight_from_marker = Z13_sight_from_marker;
	marker.higher_sight_from_marker = Z13_higher_sight_from_marker;
	marker.sight_from_time = Z13_sight_from_time;

	if (Z13_tail)
	{
		Z13_tail.Z_next = marker;
		Z13_tail = marker;
	}
	else
	{
		Z13_head = Z13_tail = marker;
		Z13_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z13_head;
	}

	marker.Z_head = Z13_head;
};

void(entity marker) Z14 =
{
	Z14_S_index = Z14_S_index + 1;
	S_index = Z14_S_index;
	Set_sub_arrival_time(marker);
	marker.Z14_ = marker.Z14_rev = marker.Z14_next_zone = marker.Z14_next = marker;
	marker.Z_ = 14;
	marker.zone_marker = Z14_marker;
	marker.next_zone_marker = Z14_next_zone_marker;
	marker.path_marker = Z14_path_marker;
	marker.sight_from_marker = Z14_sight_from_marker;
	marker.higher_sight_from_marker = Z14_higher_sight_from_marker;
	marker.sight_from_time = Z14_sight_from_time;

	if (Z14_tail)
	{
		Z14_tail.Z_next = marker;
		Z14_tail = marker;
	}
	else
	{
		Z14_head = Z14_tail = marker;
		Z14_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z14_head;
	}

	marker.Z_head = Z14_head;
};

void(entity marker) Z15 =
{
	Z15_S_index = Z15_S_index + 1;
	S_index = Z15_S_index;
	Set_sub_arrival_time(marker);
	marker.Z15_ = marker.Z15_rev = marker.Z15_next_zone = marker.Z15_next = marker;
	marker.Z_ = 15;
	marker.zone_marker = Z15_marker;
	marker.next_zone_marker = Z15_next_zone_marker;
	marker.path_marker = Z15_path_marker;
	marker.sight_from_marker = Z15_sight_from_marker;
	marker.higher_sight_from_marker = Z15_higher_sight_from_marker;
	marker.sight_from_time = Z15_sight_from_time;

	if (Z15_tail)
	{
		Z15_tail.Z_next = marker;
		Z15_tail = marker;
	}
	else
	{
		Z15_head = Z15_tail = marker;
		Z15_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z15_head;
	}

	marker.Z_head = Z15_head;
};

void(entity marker) Z16 =
{
	Z16_S_index = Z16_S_index + 1;
	S_index = Z16_S_index;
	Set_sub_arrival_time(marker);
	marker.Z16_ = marker.Z16_rev = marker.Z16_next_zone = marker.Z16_next = marker;
	marker.Z_ = 16;
	marker.zone_marker = Z16_marker;
	marker.next_zone_marker = Z16_next_zone_marker;
	marker.path_marker = Z16_path_marker;
	marker.sight_from_marker = Z16_sight_from_marker;
	marker.higher_sight_from_marker = Z16_higher_sight_from_marker;
	marker.sight_from_time = Z16_sight_from_time;

	if (Z16_tail)
	{
		Z16_tail.Z_next = marker;
		Z16_tail = marker;
	}
	else
	{
		Z16_head = Z16_tail = marker;
		Z16_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z16_head;
	}

	marker.Z_head = Z16_head;
};

void(entity marker) Z17 =
{
	Z17_S_index = Z17_S_index + 1;
	S_index = Z17_S_index;
	Set_sub_arrival_time(marker);
	marker.Z17_ = marker.Z17_rev = marker.Z17_next_zone = marker.Z17_next = marker;
	marker.Z_ = 17;
	marker.zone_marker = Z17_marker;
	marker.next_zone_marker = Z17_next_zone_marker;
	marker.path_marker = Z17_path_marker;
	marker.sight_from_marker = Z17_sight_from_marker;
	marker.higher_sight_from_marker = Z17_higher_sight_from_marker;
	marker.sight_from_time = Z17_sight_from_time;

	if (Z17_tail)
	{
		Z17_tail.Z_next = marker;
		Z17_tail = marker;
	}
	else
	{
		Z17_head = Z17_tail = marker;
		Z17_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z17_head;
	}

	marker.Z_head = Z17_head;
};

void(entity marker) Z18 =
{
	Z18_S_index = Z18_S_index + 1;
	S_index = Z18_S_index;
	Set_sub_arrival_time(marker);
	marker.Z18_ = marker.Z18_rev = marker.Z18_next_zone = marker.Z18_next = marker;
	marker.Z_ = 18;
	marker.zone_marker = Z18_marker;
	marker.next_zone_marker = Z18_next_zone_marker;
	marker.path_marker = Z18_path_marker;
	marker.sight_from_marker = Z18_sight_from_marker;
	marker.higher_sight_from_marker = Z18_higher_sight_from_marker;
	marker.sight_from_time = Z18_sight_from_time;

	if (Z18_tail)
	{
		Z18_tail.Z_next = marker;
		Z18_tail = marker;
	}
	else
	{
		Z18_head = Z18_tail = marker;
		Z18_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z18_head;
	}

	marker.Z_head = Z18_head;
};

void(entity marker) Z19 =
{
	Z19_S_index = Z19_S_index + 1;
	S_index = Z19_S_index;
	Set_sub_arrival_time(marker);
	marker.Z19_ = marker.Z19_rev = marker.Z19_next_zone = marker.Z19_next = marker;
	marker.Z_ = 19;
	marker.zone_marker = Z19_marker;
	marker.next_zone_marker = Z19_next_zone_marker;
	marker.path_marker = Z19_path_marker;
	marker.sight_from_marker = Z19_sight_from_marker;
	marker.higher_sight_from_marker = Z19_higher_sight_from_marker;
	marker.sight_from_time = Z19_sight_from_time;

	if (Z19_tail)
	{
		Z19_tail.Z_next = marker;
		Z19_tail = marker;
	}
	else
	{
		Z19_head = Z19_tail = marker;
		Z19_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z19_head;
	}

	marker.Z_head = Z19_head;
};

void(entity marker) Z20 =
{
	Z20_S_index = Z20_S_index + 1;
	S_index = Z20_S_index;
	Set_sub_arrival_time(marker);
	marker.Z20_ = marker.Z20_rev = marker.Z20_next_zone = marker.Z20_next = marker;
	marker.Z_ = 20;
	marker.zone_marker = Z20_marker;
	marker.next_zone_marker = Z20_next_zone_marker;
	marker.path_marker = Z20_path_marker;
	marker.sight_from_marker = Z20_sight_from_marker;
	marker.higher_sight_from_marker = Z20_higher_sight_from_marker;
	marker.sight_from_time = Z20_sight_from_time;

	if (Z20_tail)
	{
		Z20_tail.Z_next = marker;
		Z20_tail = marker;
	}
	else
	{
		Z20_head = Z20_tail = marker;
		Z20_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z20_head;
	}

	marker.Z_head = Z20_head;
};

void(entity marker) Z21 =
{
	Z21_S_index = Z21_S_index + 1;
	S_index = Z21_S_index;
	Set_sub_arrival_time(marker);
	marker.Z21_ = marker.Z21_rev = marker.Z21_next_zone = marker.Z21_next = marker;
	marker.Z_ = 21;
	marker.zone_marker = Z21_marker;
	marker.next_zone_marker = Z21_next_zone_marker;
	marker.path_marker = Z21_path_marker;
	marker.sight_from_marker = Z21_sight_from_marker;
	marker.higher_sight_from_marker = Z21_higher_sight_from_marker;
	marker.sight_from_time = Z21_sight_from_time;

	if (Z21_tail)
	{
		Z21_tail.Z_next = marker;
		Z21_tail = marker;
	}
	else
	{
		Z21_head = Z21_tail = marker;
		Z21_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z21_head;
	}

	marker.Z_head = Z21_head;
};

void(entity marker) Z22 =
{
	Z22_S_index = Z22_S_index + 1;
	S_index = Z22_S_index;
	Set_sub_arrival_time(marker);
	marker.Z22_ = marker.Z22_rev = marker.Z22_next_zone = marker.Z22_next = marker;
	marker.Z_ = 22;
	marker.zone_marker = Z22_marker;
	marker.next_zone_marker = Z22_next_zone_marker;
	marker.path_marker = Z22_path_marker;
	marker.sight_from_marker = Z22_sight_from_marker;
	marker.higher_sight_from_marker = Z22_higher_sight_from_marker;
	marker.sight_from_time = Z22_sight_from_time;

	if (Z22_tail)
	{
		Z22_tail.Z_next = marker;
		Z22_tail = marker;
	}
	else
	{
		Z22_head = Z22_tail = marker;
		Z22_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z22_head;
	}

	marker.Z_head = Z22_head;
};

void(entity marker) Z23 =
{
	Z23_S_index = Z23_S_index + 1;
	S_index = Z23_S_index;
	Set_sub_arrival_time(marker);
	marker.Z23_ = marker.Z23_rev = marker.Z23_next_zone = marker.Z23_next = marker;
	marker.Z_ = 23;
	marker.zone_marker = Z23_marker;
	marker.next_zone_marker = Z23_next_zone_marker;
	marker.path_marker = Z23_path_marker;
	marker.sight_from_marker = Z23_sight_from_marker;
	marker.higher_sight_from_marker = Z23_higher_sight_from_marker;
	marker.sight_from_time = Z23_sight_from_time;

	if (Z23_tail)
	{
		Z23_tail.Z_next = marker;
		Z23_tail = marker;
	}
	else
	{
		Z23_head = Z23_tail = marker;
		Z23_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z23_head;
	}

	marker.Z_head = Z23_head;
};

void(entity marker) Z24 =
{
	Z24_S_index = Z24_S_index + 1;
	S_index = Z24_S_index;
	Set_sub_arrival_time(marker);
	marker.Z24_ = marker.Z24_rev = marker.Z24_next_zone = marker.Z24_next = marker;
	marker.Z_ = 24;
	marker.zone_marker = Z24_marker;
	marker.next_zone_marker = Z24_next_zone_marker;
	marker.path_marker = Z24_path_marker;
	marker.sight_from_marker = Z24_sight_from_marker;
	marker.higher_sight_from_marker = Z24_higher_sight_from_marker;
	marker.sight_from_time = Z24_sight_from_time;

	if (Z24_tail)
	{
		Z24_tail.Z_next = marker;
		Z24_tail = marker;
	}
	else
	{
		Z24_head = Z24_tail = marker;
		Z24_head.zone_stack_next = zone_stack_head;
		zone_stack_head = Z24_head;
	}

	marker.Z_head = Z24_head;
};
