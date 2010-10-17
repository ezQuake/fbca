/*
	loadmap.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
	Copyright (C) 2000-2007 ParboiL
*/

/*
============
InvalidMap

============
*/
void() InvalidMap =
{
	sprint_fb(self, 2, mapname);
	sprint_fb(self, 2, " ισ ξοτ α συπποςτεδ ναπ®\n");
	sprint_fb(self, 2, "Τθε μιστ οζ συπποςτεδ ναπσ ισ:\n");
	sprint_fb(self, 2, "dm3, dm4, dm6, e1m2, frobodm2, aerowalk, spinev2, pkeg1, ultrav, ztndm3, amphi2, povdmm4\n");
};

/*
============
LoadMap

Make sure InvalidMap is updated!!!
============
*/
void() LoadMap =
{
	load_frogbots = invalid_map = TRUE;
	item_marker_index = marker_index;

	if (mapname == "dm6")
	{
		map_dm6();
		return;
	}
	if (mapname == "dm4")
	{
		map_dm4();
		return;
	}
	if (mapname == "e1m2")
	{
		map_e1m2();
		return;
	}
	if (mapname == "aerowalk")
	{
		map_aerowalk();
		return;
	}
	if (mapname == "ztndm3")
	{
		map_ztndm3();
		return;
	}
	if (mapname == "dm3")
	{
		map_dm3();
		return;
	}
	if (mapname == "spinev2")
	{
		map_spinev2();
		return;
	}
	if (mapname == "pkeg1")
	{
		map_pkeg1();
		return;
	}
	if (mapname == "ultrav")
	{
		map_ultrav();
		return;
	}
	if (mapname == "frobodm2")
	{
		map_frobodm2();
		return;
	}
	if (mapname == "amphi2")
	{
		map_amphi2();
		return;
	}
	if (mapname == "povdmm4")
	{
		map_povdmm4();
		return;
	}
	// assertion: map is invalid
	StartItems();
};