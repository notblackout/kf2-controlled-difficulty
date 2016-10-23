class CD_SpawnCycle_Preset_basic_light
	extends CD_SpawnCycle_PresetBase
	implements (CD_SpawnCycle_Preset);

function GetShortSpawnCycleDefs( out array<string> sink )
{
	sink.length = 0;
}

function GetNormalSpawnCycleDefs( out array<string> sink )
{
	sink.length = 0;
}

function GetLongSpawnCycleDefs( out array<string> sink )
{
	local int i;

	i = 0;

	sink.length = 0;
	sink.length = 10;

	// Wave 1
	sink[i++] = "4CC,3CC_1AL_1GF,6SL,4CC_1BL,3AL_1SL,4CC,3CC_1AL_1GF,4CC_1BL,3AL_1SL";

	// Wave 2
	sink[i++] = "3CC_1AL,3CC_1SL_1BL,2CR,2ST,8ST,1HU,1SL_2AL_1GF,2AL_2GF,"$
	            "3CC_1AL_1GF,4CC,4CR,3CC_1AL,3CC_1SL_1BL,2CR,2ST,1HU,"$
	            "1SL_2AL_1GF,2AL_2GF,3CC_1AL_1GF,4CC,4CR";

	// Wave 3
	sink[i++] = "4CR,3AL_1BL,2SL_3CR_1GF,3BL,3CC_1GF_1SI,1SL_3GF,1HU,3CC_1AL,"$
	            "2CR,2CR_2GF_2ST_1SI,4ST,4GF,4CR,3AL_1BL,2SL_3CR_1GF,"$
	            "3CC_1GF_1SI,1SL_3GF,1HU,3CC_1AL,2CR,2CR_2GF_2ST_1SI,4ST,4GF";

	// Wave 4
	sink[i++] = "3CC_1AL,3CC_1CR_2ST_1BL_1SI,1HU,4CR,3CC_1BL,2AL_2GF,"$
	            "3CC_1GF_1SI,3HU,2ST,1SL_3GF,3CC_1CR_2ST_1BL_1SI,6CR,4GF,"$
	            "2CR_2GF_2ST_1SI,3CC_1AL,3CC_1CR_2ST_1BL_1SI,1HU,4CR,3CC_1BL,"$
	            "2AL_2GF,3CC_1GF_1SI,2ST,1SL_3GF,3CC_1CR_2ST_1BL_1SI,6CR,4GF,"$
	            "2CR_2GF_2ST_1SI";

	// Wave 5
	sink[i++] = "2CR,4ST,2CR_2GF_2ST_1SI,4CR,3CC_1CR_2ST_1BL_1SI,2ST,3BL_3HU,"$
	            "3CC_1BL,2AL_1GF_1HU,4GF,6CR,2AL_2GF,1SL_3GF,3CC_1GF_1SI,"$
	            "3AL_1SL,2CR,4ST,2CR_2GF_2ST_1SI,4CR,3CC_1CR_2ST_1BL_1SI,2ST,"$
	            "3CC_1BL,2AL_1GF_1HU,4GF,6CR,2AL_2GF,1SL_3GF,3CC_1GF_1SI,3AL_1SL";

	// Wave 6
	sink[i++] = "2AL_1GF_1HU,4CR,3AL_1SL,2SL_2CR_2GF_2SI,1SC_4ST,3CC_1SL_1BL,"$
	            "2CR,2AL_1SC,2ST,1SL_2AL_1GF,4GF,6CR,2CR_2GF_2ST_1SI,1HU,"$
	            "1SL_3GF,2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,4CC,4ST,3CC_1AL_1GF,"$
	            "2AL_1GF_1HU,4CR,3AL_1SL,2SL_2CR_2GF_2SI,3CC_1SL_1BL,2CR,"$
	            "2AL_1SC,2ST,1SL_2AL_1GF,4GF,6CR,2CR_2GF_2ST_1SI,1HU,1SL_3GF,"$
	            "2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,4CC,4ST,3CC_1AL_1GF";

	// Wave 7
	sink[i++] = "1SL_2AL_1GF,2AL_2GF,2SL_3CR_1GF,2SC_4ST,3CC_1CR_2ST_1BL_1SI,"$
	            "3CC_1AL_1GF,4ST,4GF,2CR_2ST_1BL_2SI,3CC_1AL,2SL_2CR_2GF_2SI,"$
	            "6CR,2SL_3GF_1SC,4CR,3CC_1BL,2HU,4CC,1SL_2AL_1GF,2AL_2GF,"$
	            "2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,3CC_1AL_1GF,4ST,4GF,"$
	            "2CR_2ST_1BL_2SI,3CC_1AL,2SL_2CR_2GF_2SI,6CR,2SL_3GF_1SC,4CR,"$
	            "3CC_1BL,2HU,4CC";

	// Wave 8
	sink[i++] = "4CC_1BL,2SL_3GF_1SC,2CR,2AL_1GF_1HU,2ST,1SL_2AL_1GF,"$
	            "2SL_2CR_2GF_2SI,3AL_1SL,4CR,2AL_2GF,2SC_4ST,2SL_3CR_1GF,"$
	            "3CC_1CR_2ST_1BL_1SI,1HU,4ST,2AL_1SC,4CC,4GF,2CR_2GF_2ST_1SI,"$
	            "6CR,4CC_1BL,2SL_3GF_1SC,2CR,2AL_1GF_1HU,2ST,1SL_2AL_1GF,"$
	            "2SL_2CR_2GF_2SI,3AL_1SL,4CR,2AL_2GF,2SL_3CR_1GF,"$
	            "3CC_1CR_2ST_1BL_1SI,1HU,4ST,2AL_1SC,4CC,4GF,2CR_2GF_2ST_1SI,6CR";

	// Wave 9
	sink[i++] = "4ST,2HU,4CC_1BL,2CR,3AL_1SL,2AL_1SC,6CR,2SL_2CR_2GF_2SI,4GF,"$
	            "2ST,1SL_2AL_1GF,2SC_4ST,4CR,2AL_2GF,2SL_3GF_1SC,2SL_3CR_1GF,"$
	            "3CC_1CR_2ST_1BL_1SI,4CC,2CR_2GF_2ST_1SI,4ST,2HU,4CC_1BL,2CR,"$
	            "3AL_1SL,2AL_1SC,6CR,2SL_2CR_2GF_2SI,4GF,2ST,1SL_2AL_1GF,4CR,"$
	            "2AL_2GF,2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,2SL_3GF_1SC,4CC,"$
	            "2CR_2GF_2ST_1SI";

	// Wave 10
	sink[i++] = "1SL_2AL_1GF,4CR,2HU,3CC_1BL,2AL_1SC,2AL_2GF,2SL_3CR_1GF,"$
	            "2SL_2CR_2GF_2SI,3AL_1SL,2FP_1SC,1HU,4ST,4CC,2CR_2ST_1BL_2SI,"$
	            "2SL_3GF_1SC,6CR,3CC_1AL_1GF,3CC_1CR_2ST_1BL_1SI,4GF,"$
	            "1SL_2AL_1GF,4CR,2HU,3CC_1BL,2AL_1SC,2AL_2GF,2SL_3CR_1GF,"$
	            "2SL_2CR_2GF_2SI,3AL_1SL,1HU,4ST,2SL_3GF_1SC,4CC,"$
	            "2CR_2ST_1BL_2SI,6CR,3CC_1AL_1GF,3CC_1CR_2ST_1BL_1SI,4GF";
}

function string GetDate()
{
	return "2016-10-23";
}

function string GetAuthor()
{
	return "blackout";
}
