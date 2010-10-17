/*
	route_lookup.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
*/

//
// Sub-zone lookup
//

void() S_time_error = { traveltime = 1000000; };
void() S1_time_ = { traveltime = zone_time + middle_marker.S1_time; };
void() S2_time_ = { traveltime = zone_time + middle_marker.S2_time; };
void() S3_time_ = { traveltime = zone_time + middle_marker.S3_time; };
void() S4_time_ = { traveltime = zone_time + middle_marker.S4_time; };
void() S5_time_ = { traveltime = zone_time + middle_marker.S5_time; };
void() S6_time_ = { traveltime = zone_time + middle_marker.S6_time; };
void() S7_time_ = { traveltime = zone_time + middle_marker.S7_time; };
void() S8_time_ = { traveltime = zone_time + middle_marker.S8_time; };
void() S9_time_ = { traveltime = zone_time + middle_marker.S9_time; };
void() S10_time_ = { traveltime = zone_time + middle_marker.S10_time; };
void() S11_time_ = { traveltime = zone_time + middle_marker.S11_time; };
void() S12_time_ = { traveltime = zone_time + middle_marker.S12_time; };
void() S13_time_ = { traveltime = zone_time + middle_marker.S13_time; };
void() S14_time_ = { traveltime = zone_time + middle_marker.S14_time; };
void() S15_time_ = { traveltime = zone_time + middle_marker.S15_time; };
void() S16_time_ = { traveltime = zone_time + middle_marker.S16_time; };
void() S17_time_ = { traveltime = zone_time + middle_marker.S17_time; };
void() S18_time_ = { traveltime = zone_time + middle_marker.S18_time; };
void() S19_time_ = { traveltime = zone_time + middle_marker.S19_time; };
void() S20_time_ = { traveltime = zone_time + middle_marker.S20_time; };
void() S21_time_ = { traveltime = zone_time + middle_marker.S21_time; };
void() S22_time_ = { traveltime = zone_time + middle_marker.S22_time; };
void() S23_time_ = { traveltime = zone_time + middle_marker.S23_time; };
void() S24_time_ = { traveltime = zone_time + middle_marker.S24_time; };
void() S25_time_ = { traveltime = zone_time + middle_marker.S25_time; };
void() S26_time_ = { traveltime = zone_time + middle_marker.S26_time; };
void() S27_time_ = { traveltime = zone_time + middle_marker.S27_time; };
void() S28_time_ = { traveltime = zone_time + middle_marker.S28_time; };
void() S29_time_ = { traveltime = zone_time + middle_marker.S29_time; };
void() S30_time_ = { traveltime = zone_time + middle_marker.S30_time; };
void() S31_time_ = { traveltime = zone_time + middle_marker.S31_time; };
void() S32_time_ = { traveltime = zone_time + middle_marker.S32_time; };

void() S_path_marker_error = { next_marker = world; };
void() S1_path_marker = { next_marker = from_marker.S1_next; };
void() S2_path_marker = { next_marker = from_marker.S2_next; };
void() S3_path_marker = { next_marker = from_marker.S3_next; };
void() S4_path_marker = { next_marker = from_marker.S4_next; };
void() S5_path_marker = { next_marker = from_marker.S5_next; };
void() S6_path_marker = { next_marker = from_marker.S6_next; };
void() S7_path_marker = { next_marker = from_marker.S7_next; };
void() S8_path_marker = { next_marker = from_marker.S8_next; };
void() S9_path_marker = { next_marker = from_marker.S9_next; };
void() S10_path_marker = { next_marker = from_marker.S10_next; };
void() S11_path_marker = { next_marker = from_marker.S11_next; };
void() S12_path_marker = { next_marker = from_marker.S12_next; };
void() S13_path_marker = { next_marker = from_marker.S13_next; };
void() S14_path_marker = { next_marker = from_marker.S14_next; };
void() S15_path_marker = { next_marker = from_marker.S15_next; };
void() S16_path_marker = { next_marker = from_marker.S16_next; };
void() S17_path_marker = { next_marker = from_marker.S17_next; };
void() S18_path_marker = { next_marker = from_marker.S18_next; };
void() S19_path_marker = { next_marker = from_marker.S19_next; };
void() S20_path_marker = { next_marker = from_marker.S20_next; };
void() S21_path_marker = { next_marker = from_marker.S21_next; };
void() S22_path_marker = { next_marker = from_marker.S22_next; };
void() S23_path_marker = { next_marker = from_marker.S23_next; };
void() S24_path_marker = { next_marker = from_marker.S24_next; };
void() S25_path_marker = { next_marker = from_marker.S25_next; };
void() S26_path_marker = { next_marker = from_marker.S26_next; };
void() S27_path_marker = { next_marker = from_marker.S27_next; };
void() S28_path_marker = { next_marker = from_marker.S28_next; };
void() S29_path_marker = { next_marker = from_marker.S29_next; };
void() S30_path_marker = { next_marker = from_marker.S30_next; };
void() S31_path_marker = { next_marker = from_marker.S31_next; };
void() S32_path_marker = { next_marker = from_marker.S32_next; };


//
// Zone lookup
//

void() Z_next_zone_marker_error = { next_marker = world; };
void() Z1_next_zone_marker = { next_marker = from_marker.Z1_next_zone; };
void() Z2_next_zone_marker = { next_marker = from_marker.Z2_next_zone; };
void() Z3_next_zone_marker = { next_marker = from_marker.Z3_next_zone; };
void() Z4_next_zone_marker = { next_marker = from_marker.Z4_next_zone; };
void() Z5_next_zone_marker = { next_marker = from_marker.Z5_next_zone; };
void() Z6_next_zone_marker = { next_marker = from_marker.Z6_next_zone; };
void() Z7_next_zone_marker = { next_marker = from_marker.Z7_next_zone; };
void() Z8_next_zone_marker = { next_marker = from_marker.Z8_next_zone; };
void() Z9_next_zone_marker = { next_marker = from_marker.Z9_next_zone; };
void() Z10_next_zone_marker = { next_marker = from_marker.Z10_next_zone; };
void() Z11_next_zone_marker = { next_marker = from_marker.Z11_next_zone; };
void() Z12_next_zone_marker = { next_marker = from_marker.Z12_next_zone; };
void() Z13_next_zone_marker = { next_marker = from_marker.Z13_next_zone; };
void() Z14_next_zone_marker = { next_marker = from_marker.Z14_next_zone; };
void() Z15_next_zone_marker = { next_marker = from_marker.Z15_next_zone; };
void() Z16_next_zone_marker = { next_marker = from_marker.Z16_next_zone; };
void() Z17_next_zone_marker = { next_marker = from_marker.Z17_next_zone; };
void() Z18_next_zone_marker = { next_marker = from_marker.Z18_next_zone; };
void() Z19_next_zone_marker = { next_marker = from_marker.Z19_next_zone; };
void() Z20_next_zone_marker = { next_marker = from_marker.Z20_next_zone; };
void() Z21_next_zone_marker = { next_marker = from_marker.Z21_next_zone; };
void() Z22_next_zone_marker = { next_marker = from_marker.Z22_next_zone; };
void() Z23_next_zone_marker = { next_marker = from_marker.Z23_next_zone; };
void() Z24_next_zone_marker = { next_marker = from_marker.Z24_next_zone; };

void() Z_sight_from_marker_error = { look_marker = world; };
void() Z1_sight_from_marker = { look_marker = to_marker.Z1_sight_from; };
void() Z2_sight_from_marker = { look_marker = to_marker.Z2_sight_from; };
void() Z3_sight_from_marker = { look_marker = to_marker.Z3_sight_from; };
void() Z4_sight_from_marker = { look_marker = to_marker.Z4_sight_from; };
void() Z5_sight_from_marker = { look_marker = to_marker.Z5_sight_from; };
void() Z6_sight_from_marker = { look_marker = to_marker.Z6_sight_from; };
void() Z7_sight_from_marker = { look_marker = to_marker.Z7_sight_from; };
void() Z8_sight_from_marker = { look_marker = to_marker.Z8_sight_from; };
void() Z9_sight_from_marker = { look_marker = to_marker.Z9_sight_from; };
void() Z10_sight_from_marker = { look_marker = to_marker.Z10_sight_from; };
void() Z11_sight_from_marker = { look_marker = to_marker.Z11_sight_from; };
void() Z12_sight_from_marker = { look_marker = to_marker.Z12_sight_from; };
void() Z13_sight_from_marker = { look_marker = to_marker.Z13_sight_from; };
void() Z14_sight_from_marker = { look_marker = to_marker.Z14_sight_from; };
void() Z15_sight_from_marker = { look_marker = to_marker.Z15_sight_from; };
void() Z16_sight_from_marker = { look_marker = to_marker.Z16_sight_from; };
void() Z17_sight_from_marker = { look_marker = to_marker.Z17_sight_from; };
void() Z18_sight_from_marker = { look_marker = to_marker.Z18_sight_from; };
void() Z19_sight_from_marker = { look_marker = to_marker.Z19_sight_from; };
void() Z20_sight_from_marker = { look_marker = to_marker.Z20_sight_from; };
void() Z21_sight_from_marker = { look_marker = to_marker.Z21_sight_from; };
void() Z22_sight_from_marker = { look_marker = to_marker.Z22_sight_from; };
void() Z23_sight_from_marker = { look_marker = to_marker.Z23_sight_from; };
void() Z24_sight_from_marker = { look_marker = to_marker.Z24_sight_from; };

void() Z_higher_sight_from_marker_error = { look_marker = world; };
void() Z1_higher_sight_from_marker = { look_marker = to_marker.Z1_higher_sight_from; };
void() Z2_higher_sight_from_marker = { look_marker = to_marker.Z2_higher_sight_from; };
void() Z3_higher_sight_from_marker = { look_marker = to_marker.Z3_higher_sight_from; };
void() Z4_higher_sight_from_marker = { look_marker = to_marker.Z4_higher_sight_from; };
void() Z5_higher_sight_from_marker = { look_marker = to_marker.Z5_higher_sight_from; };
void() Z6_higher_sight_from_marker = { look_marker = to_marker.Z6_higher_sight_from; };
void() Z7_higher_sight_from_marker = { look_marker = to_marker.Z7_higher_sight_from; };
void() Z8_higher_sight_from_marker = { look_marker = to_marker.Z8_higher_sight_from; };
void() Z9_higher_sight_from_marker = { look_marker = to_marker.Z9_higher_sight_from; };
void() Z10_higher_sight_from_marker = { look_marker = to_marker.Z10_higher_sight_from; };
void() Z11_higher_sight_from_marker = { look_marker = to_marker.Z11_higher_sight_from; };
void() Z12_higher_sight_from_marker = { look_marker = to_marker.Z12_higher_sight_from; };
void() Z13_higher_sight_from_marker = { look_marker = to_marker.Z13_higher_sight_from; };
void() Z14_higher_sight_from_marker = { look_marker = to_marker.Z14_higher_sight_from; };
void() Z15_higher_sight_from_marker = { look_marker = to_marker.Z15_higher_sight_from; };
void() Z16_higher_sight_from_marker = { look_marker = to_marker.Z16_higher_sight_from; };
void() Z17_higher_sight_from_marker = { look_marker = to_marker.Z17_higher_sight_from; };
void() Z18_higher_sight_from_marker = { look_marker = to_marker.Z18_higher_sight_from; };
void() Z19_higher_sight_from_marker = { look_marker = to_marker.Z19_higher_sight_from; };
void() Z20_higher_sight_from_marker = { look_marker = to_marker.Z20_higher_sight_from; };
void() Z21_higher_sight_from_marker = { look_marker = to_marker.Z21_higher_sight_from; };
void() Z22_higher_sight_from_marker = { look_marker = to_marker.Z22_higher_sight_from; };
void() Z23_higher_sight_from_marker = { look_marker = to_marker.Z23_higher_sight_from; };
void() Z24_higher_sight_from_marker = { look_marker = to_marker.Z24_higher_sight_from; };

void() Z_sight_from_time_error = { look_traveltime = 1000000; };
void() Z1_sight_from_time = { look_traveltime = to_marker.Z1_sight_from_time_; };
void() Z2_sight_from_time = { look_traveltime = to_marker.Z2_sight_from_time_; };
void() Z3_sight_from_time = { look_traveltime = to_marker.Z3_sight_from_time_; };
void() Z4_sight_from_time = { look_traveltime = to_marker.Z4_sight_from_time_; };
void() Z5_sight_from_time = { look_traveltime = to_marker.Z5_sight_from_time_; };
void() Z6_sight_from_time = { look_traveltime = to_marker.Z6_sight_from_time_; };
void() Z7_sight_from_time = { look_traveltime = to_marker.Z7_sight_from_time_; };
void() Z8_sight_from_time = { look_traveltime = to_marker.Z8_sight_from_time_; };
void() Z9_sight_from_time = { look_traveltime = to_marker.Z9_sight_from_time_; };
void() Z10_sight_from_time = { look_traveltime = to_marker.Z10_sight_from_time_; };
void() Z11_sight_from_time = { look_traveltime = to_marker.Z11_sight_from_time_; };
void() Z12_sight_from_time = { look_traveltime = to_marker.Z12_sight_from_time_; };
void() Z13_sight_from_time = { look_traveltime = to_marker.Z13_sight_from_time_; };
void() Z14_sight_from_time = { look_traveltime = to_marker.Z14_sight_from_time_; };
void() Z15_sight_from_time = { look_traveltime = to_marker.Z15_sight_from_time_; };
void() Z16_sight_from_time = { look_traveltime = to_marker.Z16_sight_from_time_; };
void() Z17_sight_from_time = { look_traveltime = to_marker.Z17_sight_from_time_; };
void() Z18_sight_from_time = { look_traveltime = to_marker.Z18_sight_from_time_; };
void() Z19_sight_from_time = { look_traveltime = to_marker.Z19_sight_from_time_; };
void() Z20_sight_from_time = { look_traveltime = to_marker.Z20_sight_from_time_; };
void() Z21_sight_from_time = { look_traveltime = to_marker.Z21_sight_from_time_; };
void() Z22_sight_from_time = { look_traveltime = to_marker.Z22_sight_from_time_; };
void() Z23_sight_from_time = { look_traveltime = to_marker.Z23_sight_from_time_; };
void() Z24_sight_from_time = { look_traveltime = to_marker.Z24_sight_from_time_; };

void() Z_marker_error = { middle_marker = dropper; zone_time = 1000000; };
void() Z1_marker = 
{ 
if (path_normal) 
	{
	 middle_marker = from_marker.Z1_; 
	zone_time = from_marker.Z1_time; 
 return; 
	} 
 else 
	{
	 middle_marker = from_marker.Z1_rev; 
	 zone_time = from_marker.Z1_time_rev; 
	 } 
 };


void() Z2_marker = { if (path_normal) { middle_marker = from_marker.Z2_; zone_time = from_marker.Z2_time; return; } else { middle_marker = from_marker.Z2_rev; zone_time = from_marker.Z2_time_rev; } };
void() Z3_marker = { if (path_normal) { middle_marker = from_marker.Z3_; zone_time = from_marker.Z3_time; return; } else { middle_marker = from_marker.Z3_rev; zone_time = from_marker.Z3_time_rev; } };
void() Z4_marker = { if (path_normal) { middle_marker = from_marker.Z4_; zone_time = from_marker.Z4_time; return; } else { middle_marker = from_marker.Z4_rev; zone_time = from_marker.Z4_time_rev; } };
void() Z5_marker = { if (path_normal) { middle_marker = from_marker.Z5_; zone_time = from_marker.Z5_time; return; } else { middle_marker = from_marker.Z5_rev; zone_time = from_marker.Z5_time_rev; } };
void() Z6_marker = { if (path_normal) { middle_marker = from_marker.Z6_; zone_time = from_marker.Z6_time; return; } else { middle_marker = from_marker.Z6_rev; zone_time = from_marker.Z6_time_rev; } };
void() Z7_marker = { if (path_normal) { middle_marker = from_marker.Z7_; zone_time = from_marker.Z7_time; return; } else { middle_marker = from_marker.Z7_rev; zone_time = from_marker.Z7_time_rev; } };
void() Z8_marker = { if (path_normal) { middle_marker = from_marker.Z8_; zone_time = from_marker.Z8_time; return; } else { middle_marker = from_marker.Z8_rev; zone_time = from_marker.Z8_time_rev; } };
void() Z9_marker = { if (path_normal) { middle_marker = from_marker.Z9_; zone_time = from_marker.Z9_time; return; } else { middle_marker = from_marker.Z9_rev; zone_time = from_marker.Z9_time_rev; } };
void() Z10_marker = { if (path_normal) { middle_marker = from_marker.Z10_; zone_time = from_marker.Z10_time; return; } else { middle_marker = from_marker.Z10_rev; zone_time = from_marker.Z10_time_rev; } };
void() Z11_marker = { if (path_normal) { middle_marker = from_marker.Z11_; zone_time = from_marker.Z11_time; return; } else { middle_marker = from_marker.Z11_rev; zone_time = from_marker.Z11_time_rev; } };
void() Z12_marker = { if (path_normal) { middle_marker = from_marker.Z12_; zone_time = from_marker.Z12_time; return; } else { middle_marker = from_marker.Z12_rev; zone_time = from_marker.Z12_time_rev; } };
void() Z13_marker = { if (path_normal) { middle_marker = from_marker.Z13_; zone_time = from_marker.Z13_time; return; } else { middle_marker = from_marker.Z13_rev; zone_time = from_marker.Z13_time_rev; } };
void() Z14_marker = 
{
 if (path_normal)
 {
 middle_marker = from_marker.Z14_; 
zone_time = from_marker.Z14_time;
 return; 
} 
else
 {
 middle_marker = from_marker.Z14_rev; 
zone_time = from_marker.Z14_time_rev; }
 };


void() Z15_marker = { if (path_normal) { middle_marker = from_marker.Z15_; zone_time = from_marker.Z15_time; return; } else { middle_marker = from_marker.Z15_rev; zone_time = from_marker.Z15_time_rev; } };
void() Z16_marker = { if (path_normal) { middle_marker = from_marker.Z16_; zone_time = from_marker.Z16_time; return; } else { middle_marker = from_marker.Z16_rev; zone_time = from_marker.Z16_time_rev; } };
void() Z17_marker = { if (path_normal) { middle_marker = from_marker.Z17_; zone_time = from_marker.Z17_time; return; } else { middle_marker = from_marker.Z17_rev; zone_time = from_marker.Z17_time_rev; } };
void() Z18_marker = { if (path_normal) { middle_marker = from_marker.Z18_; zone_time = from_marker.Z18_time; return; } else { middle_marker = from_marker.Z18_rev; zone_time = from_marker.Z18_time_rev; } };
void() Z19_marker = { if (path_normal) { middle_marker = from_marker.Z19_; zone_time = from_marker.Z19_time; return; } else { middle_marker = from_marker.Z19_rev; zone_time = from_marker.Z19_time_rev; } };
void() Z20_marker = { if (path_normal) { middle_marker = from_marker.Z20_; zone_time = from_marker.Z20_time; return; } else { middle_marker = from_marker.Z20_rev; zone_time = from_marker.Z20_time_rev; } };
void() Z21_marker = { if (path_normal) { middle_marker = from_marker.Z21_; zone_time = from_marker.Z21_time; return; } else { middle_marker = from_marker.Z21_rev; zone_time = from_marker.Z21_time_rev; } };
void() Z22_marker = { if (path_normal) { middle_marker = from_marker.Z22_; zone_time = from_marker.Z22_time; return; } else { middle_marker = from_marker.Z22_rev; zone_time = from_marker.Z22_time_rev; } };
void() Z23_marker = { if (path_normal) { middle_marker = from_marker.Z23_; zone_time = from_marker.Z23_time; return; } else { middle_marker = from_marker.Z23_rev; zone_time = from_marker.Z23_time_rev; } };
void() Z24_marker = { if (path_normal) { middle_marker = from_marker.Z24_; zone_time = from_marker.Z24_time; return; } else { middle_marker = from_marker.Z24_rev; zone_time = from_marker.Z24_time_rev; } };

void() Z_path_marker_error = { next_marker = world; };
void() Z1_path_marker = { if (path_normal) { next_marker = from_marker.Z1_next; } else { next_marker = from_marker.Z1_next_rev; } };
void() Z2_path_marker = { if (path_normal) { next_marker = from_marker.Z2_next; } else { next_marker = from_marker.Z2_next_rev; } };
void() Z3_path_marker = { if (path_normal) { next_marker = from_marker.Z3_next; } else { next_marker = from_marker.Z3_next_rev; } };
void() Z4_path_marker = { if (path_normal) { next_marker = from_marker.Z4_next; } else { next_marker = from_marker.Z4_next_rev; } };
void() Z5_path_marker = { if (path_normal) { next_marker = from_marker.Z5_next; } else { next_marker = from_marker.Z5_next_rev; } };
void() Z6_path_marker = { if (path_normal) { next_marker = from_marker.Z6_next; } else { next_marker = from_marker.Z6_next_rev; } };
void() Z7_path_marker = { if (path_normal) { next_marker = from_marker.Z7_next; } else { next_marker = from_marker.Z7_next_rev; } };
void() Z8_path_marker = { if (path_normal) { next_marker = from_marker.Z8_next; } else { next_marker = from_marker.Z8_next_rev; } };
void() Z9_path_marker = { if (path_normal) { next_marker = from_marker.Z9_next; } else { next_marker = from_marker.Z9_next_rev; } };
void() Z10_path_marker = { if (path_normal) { next_marker = from_marker.Z10_next; } else { next_marker = from_marker.Z10_next_rev; } };
void() Z11_path_marker = { if (path_normal) { next_marker = from_marker.Z11_next; } else { next_marker = from_marker.Z11_next_rev; } };
void() Z12_path_marker = { if (path_normal) { next_marker = from_marker.Z12_next; } else { next_marker = from_marker.Z12_next_rev; } };
void() Z13_path_marker = { if (path_normal) { next_marker = from_marker.Z13_next; } else { next_marker = from_marker.Z13_next_rev; } };
void() Z14_path_marker = { if (path_normal) { next_marker = from_marker.Z14_next; } else { next_marker = from_marker.Z14_next_rev; } };
void() Z15_path_marker = { if (path_normal) { next_marker = from_marker.Z15_next; } else { next_marker = from_marker.Z15_next_rev; } };
void() Z16_path_marker = { if (path_normal) { next_marker = from_marker.Z16_next; } else { next_marker = from_marker.Z16_next_rev; } };
void() Z17_path_marker = { if (path_normal) { next_marker = from_marker.Z17_next; } else { next_marker = from_marker.Z17_next_rev; } };
void() Z18_path_marker = { if (path_normal) { next_marker = from_marker.Z18_next; } else { next_marker = from_marker.Z18_next_rev; } };
void() Z19_path_marker = { if (path_normal) { next_marker = from_marker.Z19_next; } else { next_marker = from_marker.Z19_next_rev; } };
void() Z20_path_marker = { if (path_normal) { next_marker = from_marker.Z20_next; } else { next_marker = from_marker.Z20_next_rev; } };
void() Z21_path_marker = { if (path_normal) { next_marker = from_marker.Z21_next; } else { next_marker = from_marker.Z21_next_rev; } };
void() Z22_path_marker = { if (path_normal) { next_marker = from_marker.Z22_next; } else { next_marker = from_marker.Z22_next_rev; } };
void() Z23_path_marker = { if (path_normal) { next_marker = from_marker.Z23_next; } else { next_marker = from_marker.Z23_next_rev; } };
void() Z24_path_marker = { if (path_normal) { next_marker = from_marker.Z24_next; } else { next_marker = from_marker.Z24_next_rev; } };


/*
============
SightMarker

============
*/
void() SightMarker =
{
	look_traveltime = 1000000;

	middle_marker = from_marker;
	zone_time = 0;
	to_marker_pos = to_marker.absmin + to_marker.view_ofs + '0 0 32';

	marker_ = from_marker.Z_head;
	while (marker_)
	{
		traceline(to_marker_pos, marker_.absmin + marker_.view_ofs + '0 0 32', TRUE, world);
		if (trace_fraction == 1)
		{
			marker_.sub_arrival_time();
			if (look_traveltime > traveltime)
			{
				if (marker_.classname != "trigger_teleport")
				{
					look_traveltime = traveltime;
					look_marker = marker_;
					marker_.near_teleport = world;	
				}
				else if (marker_.classname == "trigger_teleport")
				marker_.near_teleport = marker_;	
			}
		}
		marker_ = marker_.Z_next;
	}
};

/*
============
HigherSightMarker

============
*/
void() HigherSightMarker =
{
	look_traveltime = 1000000;

	middle_marker = from_marker;
	zone_time = 0;
	to_marker_pos = to_marker.absmin + to_marker.view_ofs + '0 0 32';

	marker_ = from_marker.Z_head;
	while (marker_)
	{
		marker_pos = marker_.absmin + marker_.view_ofs + '0 0 32';
		if (marker_pos_z - to_marker_pos_z >= 40)
		if (vlen(marker_pos - to_marker_pos) <= 1000)
		{
			traceline(to_marker_pos, marker_pos, TRUE, world);
			if (trace_fraction == 1)
			{
				marker_.sub_arrival_time();
				if (look_traveltime > traveltime)
				{
					if (marker_.classname != "trigger_teleport")
					{
						look_traveltime = traveltime;
						look_marker = marker_;
						marker_.near_teleport = world;
							
					}
					else if (marker_.classname == "trigger_teleport")
						marker_.near_teleport = marker_;
				}
			}
		}
		marker_ = marker_.Z_next;
	}
};
