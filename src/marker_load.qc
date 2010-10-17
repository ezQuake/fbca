/*
	marker_load.qc

	Copyright (C) 1997-1999 Robert 'Frog' Field
*/

/*
============
AddToQue

============
*/
void() AddToQue_apply =
{
// Note: Max 100000 commands in a function call

	if (que_size < 50)
	{
		m1=m2;m2=m3;m3=m4;m4=m5;m5=m6;m6=m7;m7=m8;m8=m9;m9=m10;m10=m11;
		m11=m12;m12=m13;m13=m14;m14=m15;m15=m16;m16=m17;m17=m18;m18=m19;m19=m20;m20=m21;
		m21=m22;m22=m23;m23=m24;m24=m25;m25=m26;m26=m27;m27=m28;m28=m29;m29=m30;m30=m31;
		m31=m32;m32=m33;m33=m34;m34=m35;m35=m36;m36=m37;m37=m38;m38=m39;m39=m40;m40=m41;
		m41=m42;m42=m43;m43=m44;m44=m45;m45=m46;m46=m47;m47=m48;m48=m49;m49=m50;m50=self;
	}
	else if (que_size < 100)
	{
		m51=m52;m52=m53;m53=m54;m54=m55;m55=m56;m56=m57;m57=m58;m58=m59;m59=m60;m60=m61;
		m61=m62;m62=m63;m63=m64;m64=m65;m65=m66;m66=m67;m67=m68;m68=m69;m69=m70;m70=m71;
		m71=m72;m72=m73;m73=m74;m74=m75;m75=m76;m76=m77;m77=m78;m78=m79;m79=m80;m80=m81;
		m81=m82;m82=m83;m83=m84;m84=m85;m85=m86;m86=m87;m87=m88;m88=m89;m89=m90;m90=m91;
		m91=m92;m92=m93;m93=m94;m94=m95;m95=m96;m96=m97;m97=m98;m98=m99;m99=m100;m100=self;
	}
	else if (que_size < 150)
	{
		m101=m102;m102=m103;m103=m104;m104=m105;m105=m106;m106=m107;m107=m108;m108=m109;m109=m110;m110=m111;
		m111=m112;m112=m113;m113=m114;m114=m115;m115=m116;m116=m117;m117=m118;m118=m119;m119=m120;m120=m121;
		m121=m122;m122=m123;m123=m124;m124=m125;m125=m126;m126=m127;m127=m128;m128=m129;m129=m130;m130=m131;
		m131=m132;m132=m133;m133=m134;m134=m135;m135=m136;m136=m137;m137=m138;m138=m139;m139=m140;m140=m141;
		m141=m142;m142=m143;m143=m144;m144=m145;m145=m146;m146=m147;m147=m148;m148=m149;m149=m150;m150=self;
	}
	else if (que_size < 200)
	{
		m151=m152;m152=m153;m153=m154;m154=m155;m155=m156;m156=m157;m157=m158;m158=m159;m159=m160;m160=m161;
		m161=m162;m162=m163;m163=m164;m164=m165;m165=m166;m166=m167;m167=m168;m168=m169;m169=m170;m170=m171;
		m171=m172;m172=m173;m173=m174;m174=m175;m175=m176;m176=m177;m177=m178;m178=m179;m179=m180;m180=m181;
		m181=m182;m182=m183;m183=m184;m184=m185;m185=m186;m186=m187;m187=m188;m188=m189;m189=m190;m190=m191;
		m191=m192;m192=m193;m193=m194;m194=m195;m195=m196;m196=m197;m197=m198;m198=m199;m199=m200;m200=self;
	}
	else if (que_size < 250)
	{
		m201=m202;m202=m203;m203=m204;m204=m205;m205=m206;m206=m207;m207=m208;m208=m209;m209=m210;m210=m211;
		m211=m212;m212=m213;m213=m214;m214=m215;m215=m216;m216=m217;m217=m218;m218=m219;m219=m220;m220=m221;
		m221=m222;m222=m223;m223=m224;m224=m225;m225=m226;m226=m227;m227=m228;m228=m229;m229=m230;m230=m231;
		m231=m232;m232=m233;m233=m234;m234=m235;m235=m236;m236=m237;m237=m238;m238=m239;m239=m240;m240=m241;
		m241=m242;m242=m243;m243=m244;m244=m245;m245=m246;m246=m247;m247=m248;m248=m249;m249=m250;m250=self;
	}
	else if (que_size < 300) // "300"
	{
		m251=m252;m252=m253;m253=m254;m254=m255;m255=m256;m256=m257;m257=m258;m258=m259;m259=m260;m260=m261;
		m261=m262;m262=m263;m263=m264;m264=m265;m265=m266;m266=m267;m267=m268;m268=m269;m269=m270;m270=m271;
		m271=m272;m272=m273;m273=m274;m274=m275;m275=m276;m276=m277;m277=m278;m278=m279;m279=m280;m280=m281;
		m281=m282;m282=m283;m283=m284;m284=m285;m285=m286;m286=m287;m287=m288;m288=m289;m289=m290;m290=m291;
		m291=m292;m292=m293;m293=m294;m294=m295;m295=m296;m296=m297;m297=m298;m298=m299;m299=m300;m300=self;
	}
	que_size = que_size + 1;
};

void() AddToQue =
{
	marker_index = marker_index + 1;
	self.index = marker_index;
	AddToQue_apply();

	self.zone_marker = Z_marker_error;
	self.sub_arrival_time = S_time_error;
	self.sub_path_marker = S_path_marker_error;
	self.path_marker = Z_path_marker_error;
	self.next_zone_marker = Z_next_zone_marker_error;
	self.sight_from_marker = Z_sight_from_marker_error;
	self.higher_sight_from_marker = Z_higher_sight_from_marker_error;
	self.sight_from_time = Z_sight_from_time_error;
};

/*
============
N (New marker)

Load a marker
============
*/
void(vector org) N =
{
// put on save que
	spawn_marker(org);
	self = marker_;
	AddToQue();
};

/*
============
LSQ (Left Shift Que)

============
*/
void() LSQ =
{
	self = world;
	while ((floor(que_size * 0.02) * 50) != que_size)
		AddToQue_apply();

// set map loading info
	load_frogbots = invalid_map = FALSE;
	no_change = TRUE;
	m = m_2 = first_marker;
	m_zone = zone_stack_head;
	path_normal = TRUE;

	spawn_load();
	dropper.think = Calc_G_time_1;
	set_load();
};
