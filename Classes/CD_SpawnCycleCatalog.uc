class CD_SpawnCycleCatalog extends Object;

var private array< class< KFPawn_Monster > > AIClassList;

var private array<CD_SpawnCycle_Preset> SpawnCyclePresetList;

var private CD_ConsolePrinter CDCP;

function Initialize( const out array< class< KFPawn_Monster > > NewAIClassList, CD_ConsolePrinter NewCDCP )
{
	AIClassList = NewAIClassList;
	CDCP = NewCDCP;
	InitSpawnCyclePresetList();
}

function bool ParseSquadCyclePreset( const string CycleName, const int GameLength, out array<CD_AIWaveInfo> WaveInfos )
{
	local array<string> CycleDefs;
	local CD_SpawnCycleParser SCParser;
	
	if ( None == ResolvePreset( CycleName, GameLength, CycleDefs ) )
	{
		`log("Unable to map SpawnCycle="$ CycleName $" to a preset");
		return false;
	}

	SCParser = new class'CD_SpawnCycleParser';
	SCParser.SetConsolePrinter( CDCP );
	
	if ( !SCParser.ParseFullSpawnCycle( CycleDefs, AIClassList, WaveInfos ) )
	{
		`log("Found a preset corresponding to SpawnCycle="$ CycleName $", but failed to parse it");
		return false;
	}
	
	`log("Located and parsed preset corresponding to SpawnCycle="$ CycleName);
	return true;
}

function bool ParseIniSquadCycle( const array<string> CycleDefs, const int GameLength, out array<CD_AIWaveInfo> WaveInfos )
{
	local int ExpectedWaveCount;
	local CD_SpawnCycleParser SCParser;

	if ( CycleDefs.length == 0 )
	{
		CDCP.Print("WARNING SpawnCycle=ini appears to define no waves"$
		               " (are there any SpawnCycleDefs lines in KFGame.ini?)");
		return false;
	}

	SCParser = new class'CD_SpawnCycleParser';
	SCParser.SetConsolePrinter( CDCP );
	
	if ( !SCParser.ParseFullSpawnCycle( CycleDefs, AIClassList, WaveInfos ) )
	{
		return false;
	}
	
	// Number of parsed waves must match the current gamelength
	// (Parsed waves only cover non-boss waves)
	switch( GameLength )
	{
		case GL_Short:  ExpectedWaveCount = 4;  break;
		case GL_Normal: ExpectedWaveCount = 7;  break;
		case GL_Long:   ExpectedWaveCount = 10; break;
	};
	
	if ( WaveInfos.length != ExpectedWaveCount )
	{
		CDCP.Print("WARNING SpawnCycle=ini defines "$ WaveInfos.length $
		               " waves, but there are "$ ExpectedWaveCount $" waves in this GameLength");
		return false;
	}
	
	return true;
}

function PrintPresets()
{
	local int i;
	local CD_SpawnCycle_Preset SCPreset;

	CDCP.Print( "  Total available SpawnCycle presets: "$ SpawnCyclePresetList.length, false );

	if ( 0 < SpawnCyclePresetList.length )
	{
		CDCP.Print( "  Listing format:", false);
		CDCP.Print( "    <SpawnCycle name> [SML]", false );
		CDCP.Print( "  The SML letters denote supported game lengths (Short/Medium/Long)", false);
		CDCP.Print( "  --------------------------------------------------------------------------", false );
	}

	for ( i = 0; i < SpawnCyclePresetList.length; i++ )
	{
		SCPreset = SpawnCyclePresetList[i];
		CDCP.Print( "    "$ SCPreset.GetName()$" "$ GetLengthBadgeForPreset( SCPreset ), false );
	}
}

private function CD_SpawnCycle_Preset ResolvePreset( const string CycleName, const int GameLength, out array<string> CycleDefs )
{
	local CD_SpawnCycle_Preset SCPreset;
	local int i;

	// Avoidable linear search; this is another case where I wish unrealscript
	// had an associative array/hashtable
	for ( i = 0; i < SpawnCyclePresetList.length; i++ )
	{
		if ( CycleName == SpawnCyclePresetList[i].GetName() )
		{
			SCPreset = SpawnCyclePresetList[i];
			break;
		}
	}

	`log("SCPreset: "$ SCPreset);

	if ( SCPreset == None )
	{
		CDCP.Print("WARNING Not a recognized SpawnCycle value: \""$ CycleName $"\"");
		return None;
	}

	switch( GameLength )
	{
		case GL_Short:  SCPreset.GetShortSpawnCycleDefs( CycleDefs );  break;
		case GL_Normal: SCPreset.GetNormalSpawnCycleDefs( CycleDefs ); break;
		case GL_Long:   SCPreset.GetLongSpawnCycleDefs( CycleDefs );   break;
	};
       	
	if ( 0 == CycleDefs.length )
	{
		CDCP.Print( "WARNING SpawnCycle="$ CycleName $" exists but is not defined for the current GameLength.\n" $
		                "   The following GameLength(s) are supported by SpawnCycle="$ CycleName $":\n" $
		                "   " $ GetSupportedGameLengthString( SCPreset ) );
		return None;
       	}

	return SCPreset;
}

private function InitSpawnCyclePresetList()
{
	if ( 0 == SpawnCyclePresetList.length )
	{
		SpawnCyclePresetList.AddItem(new class'CD_SpawnCycle_Preset_beta_hoe_avg');
	}
}

private static function string GetSupportedGameLengthString( CD_SpawnCycle_Preset SCPreset )
{
	local array<string> defs;
	local string result;

	result = "";

	SCPreset.GetShortSpawnCycleDefs( defs );
	if ( 0 < defs.length )
	{
		result $= "Short (GameLength=0), ";
	}

	SCPreset.GetNormalSpawnCycleDefs( defs );
	if ( 0 < defs.length )
	{
		result $= "Medium (GameLength=1), ";
	}

	SCPreset.GetLongSpawnCycleDefs( defs );
	if ( 0 < defs.length )
	{
		result $= "Long (GameLength=2), ";
	}

	return Left( result, Len( result ) - 2 );
}

private static function string GetLengthBadgeForPreset( CD_SpawnCycle_Preset SCPreset )
{
	local string result;
	local array<string> defs;

	result = "[";

	SCPreset.GetShortSpawnCycleDefs( defs );
	result $= ( 0 < defs.length ? "S" : "_" );

	SCPreset.GetNormalSpawnCycleDefs( defs );
	result $= ( 0 < defs.length ? "M" : "_" );

	SCPreset.GetLongSpawnCycleDefs( defs );
	result $= ( 0 < defs.length ? "L" : "_" );

	result $= "]";

	return result;
}
