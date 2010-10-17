/*
	bot/botstat.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
*/

/*
============
UpdateTotalDamage

============
*/
void(entity client) UpdateTotalDamage =
{
	client.total_armor = client.armortype * client.armorvalue;
	min_first = client.health / (1 - client.armortype);
	min_second = client.health + client.armorvalue;
	if (min_first <= min_second)
		client.total_damage = min_first;
	else
		client.total_damage = min_second;

	if (client.total_armor == 160)
	{
		client.desire_armor1 = client.desire_armor2 = client.desire_armorInv = 0;
	}
	else
	{
		min_first = client.health / 0.2 ;
		min_second = client.health + 200;
		if (min_first <= min_second)
			client.desire_armorInv = min_first - client.total_damage;
		else
			client.desire_armorInv = min_second - client.total_damage;

		if (client.total_armor >= 90)
		{
			client.desire_armor1 = client.desire_armor2 = 0;
		}
		else
		{
			min_first = client.health / 0.4;
			min_second = client.health + 150;
			if (min_first <= min_second)
				client.desire_armor2 = min_first - client.total_damage;
			else
				client.desire_armor2 = min_second - client.total_damage;

			if (client.desire_armor2 < 0)
				client.desire_armor2 = 0;

			if (client.total_armor >= 30)
				client.desire_armor1 = 0;
			else
			{
				min_first = client.health / 0.7;
				min_second = client.health + 100;
				if (min_first <= min_second)
					client.desire_armor1 = 2 * (min_first - client.total_damage);
				else
					client.desire_armor1 = 2 * (min_second - client.total_damage);

				if (client.desire_armor1 < 0)
					client.desire_armor1 = 0;
			}
		}
	}

	if (client.health < 250)
	{
		if (client.health < 150)
			new_health = client.health + 100;
		else
			new_health = 250;

		min_first = new_health / (1 - client.armortype);
		min_second = new_health + client.armorvalue;
		if (min_first <= min_second)
			client.desire_health2 = min_first - client.total_damage;
		else
			client.desire_health2 = min_second - client.total_damage;

		if (client.health < 100)
		{
			if (client.health < 75)
				new_health = client.health + 25;
			else
				new_health = 100;

			min_first = new_health / (1 - client.armortype);
			min_second = new_health + client.armorvalue;
			if (min_first <= min_second)
				client.desire_health0 = 2 * (min_first - client.total_damage);
			else
				client.desire_health0 = 2 * (min_second - client.total_damage);
		}
		else
			client.desire_health0 = 0;
	}
	else
		client.desire_health0 = client.desire_health2 = 0;

	if (client.player_flag & ITEM_RUNE1_FLAG)
		client.total_damage = client.total_damage * 2;
};
