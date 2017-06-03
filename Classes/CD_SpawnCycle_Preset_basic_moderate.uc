class CD_SpawnCycle_Preset_basic_moderate
	extends CD_SpawnCycle_PresetBase
	implements (CD_SpawnCycle_Preset);

function GetShortSpawnCycleDefs( out array<string> sink )
{
	GetLongSpawnCycleDefs( sink );

	// keep waves 1, 4, 7, 10
	sink.Remove(1, 2);
	sink.Remove(2, 2);
	sink.remove(3, 2);

	sink.Length = 4;
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
	sink[i++] = "3CC_1AL,3CC_1SL_1BL,2CR,2ST,4CC_1BL_2GF,1HU,1SL_2AL_1GF,2AL_2GF,"$
	            "3CC_1AL_1GF,4CC,4CR,3CC_1AL,3CC_1SL_1BL,2CR,2ST,1HU,"$
	            "1SL_2AL_1GF,2AL_2GF,3CC_1AL_1GF,4CC,4CR";

	// Wave 3
	sink[i++] = "4CR,3AL_1BL,2SL_3CR_1GF,8ST,3CC_1GF_1SI,1SL_3GF,1HU,3CC_1AL,"$
	            "2CR,2CR_2GF_2ST_1SI,4ST,4GF_1BL,4CR,4CC_1SI,3AL_2BL,2SL_3CR_1GF,"$
	            "3CC_1GF_1SI,1SL_3GF,1HU,3CC_1AL,2CR,2CR_2GF_2ST_1SI,4ST,4GF";

	// Wave 4
	sink[i++] = "3CC_1AL,3CC_1CR_2ST_1BL_1SI,1HU_4CR,3CC,2AL_2GF,"$
	            "3CC_1GF_1SI,9GF,2ST,1SL_3GF,3CC_2CR_2ST_1SI,6CR,4GF,"$
	            "2CR_2GF_2ST,1BL_4CC_1AL,3CC_1CR_2ST_1BL_1SI,4CR,3CC_2BL,"$
	            "2AL_2GF,1HU,3CC_1GF_1SI,2ST,1SL_3GF,3CC_1CR_2ST_1BL_1SI,6CR,"$
	            "2CC_1CS_1HU,4GF,2CR_2GF_2ST_1SI";

	// Wave 5
	sink[i++] = "2CR,2CR_2GF_2ST_1SI,4CR,3CC_1CR_2ST_1BL_1SI,1SC_6ST,2ST,"$
	            "3CC_1BL,4GF,6CR,4ST,2AL_2GF,2AL_1GF_1HU,1SL_3GF,3CC_1GF_1SI,"$
	            "3AL_1SL,2CR,4ST,2CR_2GF_2ST_1SI,4CR,3CC_1CR_2ST_1BL_1SI,1SC,2ST,"$
	            "3CC_1BL,4GF,2AL_1GF_1HU,6CR,2AL_2GF,1SL_3GF,3CC_1GF_1SI,3AL_1SL";

	// Wave 6
	sink[i++] = "2AL_1GF_1HU,4CR,3AL_1SL,2SL_2CR_2GF_2SI,2AL_1SC,3CC_1SL_1BL,"$
	            "2CR,2ST,1SL_2AL_1GF,4GF,6CR,2CR_2GF_2ST_1SI,1HU,"$
	            "1SL_3GF,2SL_3CR_1GF,3CC_1CR_2ST_1BL_1SI,1SC_4ST,4CC,4ST,3CC_1AL_1GF,"$
	            "2AL_1GF_1HU,4CR,3AL_1SL,2SL_2CR_2GF_2SI,3CC_1SL_1BL,2CR,"$
	            "2AL_1SC,2ST,1SL_2AL_1GF,4GF,6CR,2CR_2GF_2ST_1SI,1SC_3GF,1SL_3GF,"$
	            "2SL_3CR_1GF,1HU,3CC_1CR_2ST_1BL_1SI,4CC,4ST,3CC_1AL_1GF";

	// Wave 7
	sink[i++] = "1SL_2AL_1GF,2AL_2GF,1FP_1SC,2SL_3CR_1GF,3CC_1CR_2ST_1BL,"$
	            "3CC_1AL_1GF,4ST,4GF,1HU,2CR_2ST_1CC_1SI,4CC_1AL,2SL_2CR_2GF_2SI,"$
	            "6CR,2SL_3GF_1SC,1HU_4CR,3CC_1BL,4CC,1HU_1AL_2CS,1SL_2AL_1GF,2AL_2GF,"$
	            "2SL_3CR_1GF,3CC_1CR_2ST_1CC_1SI,"$
	            "2SL_2GF_2SC,3CC_1AL_1GF,4ST,4GF,2CR_2ST_1BL_2SI,3CC_1AL,2SL_2CR_2GF_2SI,6CR,4CR,"$
	            "3CC_1BL,4CC";

	// Wave 8
	sink[i++] = "2SL_3GF_1SC,4CC_1BL,2CR,2AL_1GF_1HU,2ST,1SL_2AL_1GF,"$
	            "2SL_2CR_2GF,2SI,3AL_1SL,4CR,2AL_2GF,1FP_1SC,2SL_3CR_1GF,"$
	            "3CC_1CR_2ST_1BL_1SI,4ST,4CC,4GF,1HU,2CR_2GF_2ST_1SI,2AL_1SC,"$
	            "6CR,4CC_1BL,2CR,2AL_1GF_1HU,2ST,1SL_2AL_1GF,"$
	            "2SL_2CR_2GF,2SI,3AL_1SL,4CR,2AL_2GF,2SL_3CR_1GF,2SL_3GF_1SC,"$
	            "3CC_1CR_2ST_1BL_1SI,2AL_1SC,1BL_4ST,4CC,4GF,2CR_2GF_2ST_1SI,6CR";

	// Wave 9
	sink[i++] = "1HU_4ST,2AL_1SC,4CC_1BL,2CR,3AL_1SL,6CR,2SL_2CR_2GF_2SI,4GF,"$
	            "2FP_1SC,2ST,1SL_2AL_1GF,4CR,2AL_2GF,2SL_3CR_1GF,"$
	            "3CC_1CR_2ST,2BL_1SI,2CR_2GF_2ST_1SI,4CC,2SL_3GF_1SC,4ST,4CC_1BL,2CR,"$
	            "1HU,3CC_2GF,3AL_1SL,6CR,2SL_2CR_2GF_2SI,4GF,2ST,1SL_2AL_1GF,4CR,"$
	            "2SL_3CR_1GF,2AL_2GF,2AL_1SC,3CC_1CR_2ST_1BL_1SI,2SL_3GF_1SC,4CC,"$
	            "2CR_2GF_2ST_1SI,1HU,3CC_1CR_2ST,1BL_1SI,4CC,3GF_1SL";

	// Wave 10
	sink[i++] = "1SL_2AL_1GF,4CR,2FP_2SC,3CC_1CS,2AL_2CC,2AL_2GF,4CC,2SL_3CR_1GF,"$
	            "2SL_2CR_2GF_1SI,3AL_1SL,4ST,"$
	            "2SL_3GF_1SC,6CR,1HU,2CR_2ST,1BL_2SI,3CC_1AL_1GF,3CC_1CR_2ST_1BL_1SI,4GF,"$
	            "1SL_2AL_1GF,4CR,3CC_2BL,2AL_1SC,1HU_3CC,2AL_2GF,2SL_3CR_1GF,"$
	            "2SL_2CR_2GF,2SI,2SL_3GF_1SC,3AL_1SL,4CC_1CA,4ST,"$
	            "1CR_2ST_1BL_1SI,6CR,3CC_1AL_1GF,4CC_1CR_2ST_1BL,4GF";
}

function string GetDate()
{
	return "2016-10-23";
}

function string GetAuthor()
{
	return "blackout + dandyboy + Kore";
}
