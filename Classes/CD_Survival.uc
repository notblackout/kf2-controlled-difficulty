//=============================================================================
// ControlledDifficulty_Survival
//=============================================================================
// Survival with less bullshit
//=============================================================================

class CD_Survival extends KFGameInfo_Survival;

`include(CD_BuildInfo.uci)

// increase zed count (but not hp) as though this many additional players were
// present; note that the game normally increases dosh rewards for each zed at
// numplayers >= 3, and faking players this way does the same; you can always
// refrain from buying if you want an extra challenge, but if the mod denied
// you that bonus dosh, it could end up being gamebreaking for some runs
var config int FakePlayers; 

// the trader time, in seconds.  if this is zero or negative, its value is
// totally ignored, and the difficulty's standard trader time is used instead.
var config int TraderTime;

// the forced spawn modifier, expressed as a float between 0 and 1.
// 1.0 is KFGameConductor's player-friendliest state.
// 0.75 is KFGameConductor's player-hostile state.
// Below 0.75 is spawn intensity unseen in the vanilla game.
// this is a string instead of a float because, if it were a float,
// then the value 0 would be ambiguous.  there's no way to tell whether
// a config float var with value 0 is absent from the file (in which
// case we want to default to value 1.0) or present in the file and
// explicitly set to 0 (in which case we want to use 0).  there's also
// apparently no way to control the default value used when the ini file
// does not have an explicit setting (defaultproperties issues a warning). 
var config string SpawnMod;
var float SpawnModFloat;

// the maximum monsters allowed on the map at one time.  in the vanilla game,
// this is 16 when in NM_StandAlone and GetLivingPlayerCount() == 1; 32 in
// any other case (such as when playing alone on a dedicated server).  if this
// is set to a nonpositive value, then the vanilla behavior prevails.  if this
// is set to a positive value, then it overrides the vanilla behavior.
var config int MaxMonsters;

// true to allow albino crawlers to spawn as they do in the unmodded game.
// false to spawn regular crawlers in place of albino crawlers.
var config bool AlbinoCrawlers;

// same value sense as for AlbinoCrawlers, but for alpha clots
var config bool AlbinoAlphas;

// true to log some internal state specific to this mod
var config bool bLogControlledDifficulty;

// "ini": read info about squads from config and use it to set spawn squads
// "unmodded": unmodded game behavior
// all other values are reserved for potential future preset names
var config string SpawnCycle;
var config array<string> SpawnCycleDefs;

// "hans" or "volter": forces the hans boss wave
// "pat", "patty", "patriarch": forces the patriarch boss wave
// else: choose a random boss wave (unmodded game behavior)
var config string Boss;

var CD_DifficultyInfo CustomDifficultyInfo;

var array<CD_AIWaveInfo> CustomWaveInfos;

var CD_ConsolePrinter GameInfo_CDCP;

var array<CD_SpawnCycle_Preset> SpawnCyclePresetList;

event InitGame( string Options, out string ErrorMessage )
{
	local float SpawnModFromGameOptions;
	local float SpawnModBeforeClamping;
	local int MaxMonstersFromGameOptions;
	local bool AlbinoCrawlersFromGameOptions;
	local bool AlbinoAlphasFromGameOptions;
	local string SpawnCycleFromGameOptions;
	local string BossFromGameOptions;

 	Super.InitGame( Options, ErrorMessage );

	InitSpawnCyclePresetList();

//	AddMutator( "ControlledDifficulty.CD_Mutator", false );

	if (SpawnMod == "")
	{
		SpawnModFloat = 1.f;
	}
	else
	{
		SpawnModFloat = float(SpawnMod);
	}

	if ( HasOption(Options, "SpawnMod") )
	{
		SpawnModFromGameOptions = GetFloatOption( Options, "SpawnMod", 1.f );
		`log("SpawnModFromGameOptions = "$SpawnModFromGameOptions$" (1.0=missing)", bLogControlledDifficulty);
		SpawnModFloat = SpawnModFromGameOptions;
	}

	if ( HasOption(Options, "MaxMonsters") )
	{
		MaxMonstersFromGameOptions = GetIntOption( Options, "MaxMonsters", -1 );
		`log("MaxMonstersFromGameOptions = "$MaxMonstersFromGameOptions$" (-1=default)", bLogControlledDifficulty);
		MaxMonsters = MaxMonstersFromGameOptions;
	}

	if ( HasOption(Options, "AlbinoCrawlers") )
	{
		AlbinoCrawlersFromGameOptions = GetBoolOption( Options, "AlbinoCrawlers", true );
		`log("AlbinoCrawlersFromGameOptions = "$AlbinoCrawlersFromGameOptions$" (true=default)", bLogControlledDifficulty);
		AlbinoCrawlers = AlbinoCrawlersFromGameOptions;
	}

	if ( HasOption(Options, "AlbinoAlphas") )
	{
		AlbinoAlphasFromGameOptions = GetBoolOption( Options, "AlbinoAlphas", true );
		`log("AlbinoAlphasFromGameOptions = "$AlbinoAlphasFromGameOptions$" (true=default)", bLogControlledDifficulty);
		AlbinoAlphas = AlbinoAlphasFromGameOptions;
	}

	if ( HasOption(Options, "SpawnCycle") )
	{
		SpawnCycleFromGameOptions = ParseOption(Options, "SpawnCycle" );
		`log("SpawnCycleFromGameOptions = "$SpawnCycleFromGameOptions, bLogControlledDifficulty);
		SpawnCycle = SpawnCycleFromGameOptions;
	}

	if ( HasOption(Options, "Boss") )
	{
		BossFromGameOptions = ParseOption(Options, "Boss" );
		`log("BossFromGameOptions = "$BossFromGameOptions, bLogControlledDifficulty);
		Boss = BossFromGameOptions;
	}

	// FClamp SpawnModFloat
	SpawnModBeforeClamping = SpawnModFloat;
	SpawnModFloat = FClamp(SpawnModFloat, 0.f, 1.f);
	`log("FClamped SpawnMod = "$SpawnModFloat, bLogControlledDifficulty);

	if ( SpawnModFloat == SpawnModBeforeClamping )
	{
		CDConsolePrint("SpawnMod="$SpawnModFloat);
	}
	else
	{
		CDConsolePrint("SpawnMod="$SpawnModFloat$" (clamped from "$SpawnModBeforeClamping$")");
	}

	// Assign SpawnMod before we save our config (SpawnModFloat is not saved, only its SpawnMod copy)
	SpawnMod = string(SpawnModFloat);

	// Check validity of the Boss option
	if ( Boss == "" )
	{
		Boss = "unmodded";
	}

	if ( !isRandomBossString(Boss) && !isPatriarchBossString(Boss) && !isVolterBossString(Boss) )
	{
		CDConsolePrint("WARNING invalid Boss setting \""$Boss$"\"; Valid alternatives: patriarch, hans, or unmodded");
		CDConsolePrint("Boss=unmodded (forced because \""$ Boss $"\" is invalid)");
		Boss = "unmodded";
	}
	else
	{
		CDConsolePrint("Boss="$ Boss);
	}

	SaveConfig();
}

function InitSpawnCyclePresetList()
{
	if ( 0 == SpawnCyclePresetList.length )
	{
		SpawnCyclePresetList.AddItem(new class'CD_SpawnCycle_Preset_beta_hoe_avg');
	}
}

static function bool isRandomBossString( const out string s )
{
	return s == "" || s ~= "random" || s ~= "unmodded";
}

function bool isRandomBoss()
{
	return isRandomBossString( Boss );
}

static function bool isPatriarchBossString( const out string s )
{
	return s ~= "patriarch" || s~= "patty" || s ~= "pat";
}

function bool isPatriarchBoss()
{
	return isPatriarchBossString( Boss );
}

static function bool isVolterBossString( const out string s )
{
	return s ~= "hans" || s ~= "volter" || s ~= "moregas";
}

function bool isVolterBoss()
{
	return isVolterBossString( Boss );
}

function string getStringForBossSetting()
{
	if ( isPatriarchBoss() )
	{
		return "patriarch";
	}
	else if ( isVolterBoss() )
	{
		return "volter";
	}
	else
	{
		return "random";
	}
}

function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
	local class killerPawnClass;

	if ( (Killer == Other) || (Killer == None) )
	{	//suicide
		BroadcastLocalized(self, class'KFLocalMessage_Game', KMT_Suicide, None, Other.PlayerReplicationInfo);
	}
	else
	{
		if(Killer.IsA('KFAIController'))
		{
			if ( Killer.Pawn != none )
			{
				killerPawnClass = class'CD_ZedNameUtils'.static.CheckClassRemap( Killer.Pawn.Class, "CD_Survival.BroadcastDeathMessage" );
			}
			else
			{
				killerPawnClass = class'KFPawn_Human';
			}
			BroadcastLocalized(self, class'KFLocalMessage_Game', KMT_Killed, none, Other.PlayerReplicationInfo, killerPawnClass );
		}
		else
		{
			BroadcastLocalized(self, class'KFLocalMessage_PlayerKills', KMT_PlayerKillPlayer, Killer.PlayerReplicationInfo, Other.PlayerReplicationInfo);
		}
	}
}

function InitGameConductor()
{
	super.InitGameConductor();

	if ( GameConductor.isA( 'CD_DummyGameConductor' ) )
	{
		`log("Checked that GameConductor "$GameConductor$" is an instance of CD_DummyGameConductor (OK)", bLogControlledDifficulty);
	}
	else
	{
		CDConsolePrint("WARNING: GameConductor "$GameConductor$" appears to be misconfigured! CD might not work correctly.");
	}
}

function CreateDifficultyInfo(string Options)
{
	local int FakePlayersFromGameOptions;
	local int FakePlayersBeforeClamping;
	local int TraderTimeFromGameOptions;

	super.CreateDifficultyInfo(Options);

	// Print CD's commit hash (version)
	CDConsolePrint("Version " $ `CD_COMMIT_HASH $ " (" $ `CD_AUTHOR_TIMESTAMP $ ") loaded");

	// the preceding call should have initialized DifficultyInfo
	CustomDifficultyInfo = CD_DifficultyInfo(DifficultyInfo);

	// Process FakePlayers command option, if present
	if ( HasOption(Options, "FakePlayers") )
	{
		FakePlayersFromGameOptions = GetIntOption( Options, "FakePlayers", -1 );
		`log("FakePlayersFromGameOptions = "$FakePlayersFromGameOptions$" (-1=missing)", bLogControlledDifficulty);
		FakePlayers = FakePlayersFromGameOptions;
	}

	// Force FakePlayers onto the interval [0, 5]
	FakePlayersBeforeClamping = FakePlayers;
	FakePlayers = Clamp(FakePlayers, 0, 5);
	`log("Clamped FakePlayers = "$FakePlayers, bLogControlledDifficulty);

	// Print FakePlayers to console
	if ( FakePlayers != FakePlayersBeforeClamping )
	{
		CDConsolePrint("FakePlayers="$FakePlayers$" (clamped from "$FakePlayersBeforeClamping$")");
	}
	else
	{
		CDConsolePrint("FakePlayers="$FakePlayers);
	}

	// Process TraderTime command option, if present
	if ( HasOption(Options, "TraderTime") )
	{
		TraderTimeFromGameOptions = GetIntOption( Options, "TraderTime", -1 );
		`log("TraderTimeFromGameOptions = "$TraderTimeFromGameOptions$" (-1=missing)", bLogControlledDifficulty);
		TraderTime = TraderTimeFromGameOptions;
	}

	// TraderTime is not clamped

	// Print TraderTime to console
	if ( 0 < TraderTime )
	{
		CDConsolePrint("TraderTime="$TraderTime);
	}
	else
	{
		CDConsolePrint("TraderTime=<unmodded default>");
	}

	// log that we're done with the DI (note that CD_DifficultyInfo logs param values in its setters)
	`log("Finished instantiating and configuring CD_DifficultyInfo", bLogControlledDifficulty);
}

function ModifyAIDoshValueForPlayerCount( out float ModifiedValue )
{
	local float DoshMod;
	local int LocalNumPlayers;
	local int LocalNumFakes;
	local float LocalMaxAIMod;

	LocalNumPlayers = GetNumPlayers();
	LocalNumFakes = CustomDifficultyInfo.GetNumFakePlayers();
	// Only pass actual players to GetPlayerNumMaxAIModifier -- it adds fakes internally
	LocalMaxAIMod = DifficultyInfo.GetPlayerNumMaxAIModifier(LocalNumPlayers);

	`log("NumPlayers = "$LocalNumPlayers, bLogControlledDifficulty);
	`log("NumFakes = "$LocalNumFakes, bLogControlledDifficulty);
	`log("DifficultyInfo.GetPlayerNumMaxAIModifier(NumPlayers) = "$LocalMaxAIMod$"; this is fake-count-adjusted", bLogControlledDifficulty);

	DoshMod = (LocalNumPlayers + LocalNumFakes) / LocalMaxAIMod;

	`log("Starting Dosh Bounty: "$ModifiedValue$" DoshMod: "$DoshMod, bLogControlledDifficulty);

	ModifiedValue *= DoshMod;

	`log("Modified Dosh Bounty: "$ModifiedValue, bLogControlledDifficulty);
}

/** Set up the spawning */
function InitSpawnManager()
{
	local CDSpawnManager cdsm;
	local int ExpectedWaveCount;
	local array<string> CycleDefs;
	local string OriginalSpawnCycle;
	local CD_SpawnCycleParser SCParser;

	super.InitSpawnManager();

	if ( SpawnManager.IsA( 'CDSpawnManager' ) )
	{
		`log("Checked that SpawnManager "$SpawnManager$" is an instance of CDSpawnManager (OK)", bLogControlledDifficulty);
		cdsm = CDSpawnManager( SpawnManager );
	}
	else
	{
		CDConsolePrint("WARNING: SpawnManager "$SpawnManager$" appears to be misconfigured! CD might not work correctly.");
		return;
	}

	if (0 < MaxMonsters)
	{
		CDConsolePrint("MaxMonsters="$MaxMonsters);
	}
	else
	{
		CDConsolePrint("MaxMonsters=<unmodded default>");
	}

	// Back up the current SpawnCycle setting
	OriginalSpawnCycle = SpawnCycle;
	
	// Assign a spawn definition array to CycleDefs (unless SpawnCycle=random)
	if ( SpawnCycle == "ini" )
	{
		// This doesn't seem to work (am I forcing a SaveConfig() beforehand?)
		//`log("Forcing a config reload because SpawnCycle="$SpawnCycle$"...");
		//ConsoleCommand("reloadcfg ControlledDifficulty.CD_Survival", true);
		//ReloadConfig();
		CycleDefs = SpawnCycleDefs;
	}
	else if ( SpawnCycle == "unmodded" )
	{
		`log("Not using a SpawnCycle (value="$SpawnCycle$")");
	}
	else
	{
		if ( !ResolveSpawnCyclePreset( SpawnCycle, CycleDefs ) )
		{
			SpawnCycle = "unmodded";
		}
	}

	// Parse CycleDefs
	if ( SpawnCycle != "unmodded" )
	{
		// Start by assuming this isn't going to work.
		//
		// If the SpawnCycle actually parses correctly, then
		// we'll set SpawnCycle back to OriginalSpawnCycle
		SpawnCycle = "unmodded"; 

		if ( CycleDefs.length > 0 )
		{
			SCParser = new class'CD_SpawnCycleParser';
			SCParser.SetConsolePrinter( GameInfo_CDCP );

			`log("Attempting to parse squad spawn info for SpawnCycle="$ OriginalSpawnCycle $"...");
			CustomWaveInfos = SCParser.ParseFullSpawnCycle( CycleDefs, AIClassList );
	
			// Number of parsed waves must match the current gamelength
			// (Parsed waves only cover non-boss waves)
			switch( GameLength )
			{
				case GL_Short:  ExpectedWaveCount = 4;  break;
				case GL_Normal: ExpectedWaveCount = 7;  break;
				case GL_Long:   ExpectedWaveCount = 10; break;
			};
		
			if ( CustomWaveInfos.length != ExpectedWaveCount )
			{
				CDConsolePrint("WARNING SpawnCycle="$ OriginalSpawnCycle $" defines "$CustomWaveInfos.length$" waves, but there are "$ExpectedWaveCount$" waves in this GameLength");
			}
			else if ( !SCParser.HasParseError() )
			{
				cdsm.SetCustomWaves( CustomWaveInfos );
				SpawnCycle = OriginalSpawnCycle; // success
			}
		}
		else if ( OriginalSpawnCycle == "ini" )
		{
			CDConsolePrint("WARNING No SpawnCycleDefs lines found.  These must be in KFGame.ini under the ControlledDifficulty.CD_Survival section to use SpawnCycle=ini.");
		}
	}

	if ( OriginalSpawnCycle != SpawnCycle )
	{
		CDConsolePrint( "SpawnCycle="$ SpawnCycle $" (forced because \""$ OriginalSpawnCycle $"\" is invalid)" );
	}
	else
	{
		CDConsolePrint( "SpawnCycle="$ SpawnCycle );
	}

	if ( SpawnCycle == "unmodded" )
	{
		CDConsolePrint( "AlbinoCrawlers="$AlbinoCrawlers );
		CDConsolePrint( "AlbinoAlphas="$AlbinoAlphas );
	}
	else
	{
		CDConsolePrint( "AlbinoCrawlers=<ignored because SpawnCycle is not unmodded>" );
		CDConsolePrint( "AlbinoAlphas=<ignored because SpawnCycle is not unmodded>" );
	}
}

function bool ResolveSpawnCyclePreset( const string CycleName, out array<string> CycleDefs )
{
//	local string TmpClassname;
//	local class TmpClass;
//	local object SCPresetBeforeCast;
	local CD_SpawnCycle_Preset SCPreset;
	local int i;

//	// try to map SpawnCycle to a builtin name
//	TmpClassname = "ControlledDifficulty.CD_SpawnCycle_Preset_"$ CycleName;
//	TmpClass = class( DynamicLoadObject(TmpClassname, class'Class', true) );
//
//	if ( TmpClass == None )
//	{
//		CDConsolePrint("WARNING Unable to process SpawnCycle=\""$  CycleName $"\"");
//		return false;
//	}
//
//	`log("Class object loaded for name "$ TmpClassname $": "$ string(TmpClass));
//
//	SCPresetBeforeCast = new TmpClass;
//
//	`log("Instantiated SpawnCycle preset: "$ SCPresetBeforeCast);
//
//	SCPreset = CD_SpawnCycle_Preset(SCPresetBeforeCast);

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
		CDConsolePrint("WARNING Not a recognized SpawnCycle value: "$ CycleName $"\"");
		return false;
	}

	switch( GameLength )
	{
		case GL_Short:  SCPreset.GetShortSpawnCycleDefs( CycleDefs );  break;
		case GL_Normal: SCPreset.GetNormalSpawnCycleDefs( CycleDefs ); break;
		case GL_Long:   SCPreset.GetLongSpawnCycleDefs( CycleDefs );   break;
	};
       	
	if ( 0 == CycleDefs.length )
	{
		CDConsolePrint( "WARNING SpawnCycle="$ CycleName $" exists but is not defined for the current GameLength.\n" $
		                "   The following GameLength(s) are supported by SpawnCycle="$ CycleName $":\n" $
		                "   " $ GetSupportedGameLengthString( SCPreset ) );
		return false;
       	}

	return true;
}

static function string GetSupportedGameLengthString( CD_SpawnCycle_Preset SCPreset )
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

exec function logControlledDifficulty( bool enabled )
{
	bLogControlledDifficulty = enabled;
	`log("Set bLogControlledDifficulty = "$bLogControlledDifficulty);
	SaveConfig();
}

exec function CDSpawnSummaries( optional string CycleName, optional int AssumedPlayerCount = -255 )
{
	if ( CycleName == "" )
	{
		CycleName = SpawnCycle;
	}

	CDConsolePrintScheduleSlug( CycleName );

	if ( SpawnCycle == "unmodded" )
	{
		CDConsolePrint("  Nothing to display because SpawnCycle=unmodded and no parameters were given.", false);
		CDConsolePrint("  This command displays SpawnCycle summaries.  If this command is invoked with", false);
		CDConsolePrint("  a string parameter, then this command interprets the parameter as a SpawnCycle", false);
		CDConsolePrint("  name and attempts to display summaries for that cycle.  If invoked without", false);
		CDConsolePrint("  parameters, this command displays summaries for the current SpawnCycle value.", false);
		return;
	}

	if ( -255 == AssumedPlayerCount )
	{
		if ( WorldInfo.NetMode == NM_StandAlone )
		{
			AssumedPlayerCount = 1 + FakePlayers;
			CDConsolePrint( "Projecting wave summaries for "$AssumedPlayerCount$" players = 1 human + "$FakePlayers$" fake(s)...", false );
		}
		else
		{
			CDConsolePrint( "Unable to guess player count in netmode "$WorldInfo.NetMode, false );
			CDConsolePrint( "Pass a player count as an argument to this console command, e.g.", false );
			CDConsolePrint( "> CDSpawnSummaries 2", false );
			return;
		}
	}
	else if ( 0 < AssumedPlayerCount )
	{
		CDConsolePrint( "Projecting wave summaries for "$AssumedPlayerCount$" players...", false );
	}
	else
	{
		CDConsolePrint( "Player count argument "$AssumedPlayerCount$" must be positive", false );
		return;
	}

	CDConsolePrintSpawnSummaries( CycleName, AssumedPlayerCount, GameInfo_CDCP );
}

exec function CDSpawnDetails( optional string CycleName )
{
	if ( CycleName == "" )
	{
		CycleName = SpawnCycle;
	}

	CDConsolePrintScheduleSlug( CycleName );

	if ( SpawnCycle == "unmodded" )
	{
		CDPrintSpawnDetailsHelp();
		return;
	}

	CDConsolePrint("Printing zed spawn cycles on each wave...", false);
	CDConsolePrintSpawnDetails( CustomWaveInfos /* TODO not this */, "short", GameInfo_CDCP );
}

exec function CDSpawnDetailsVerbose( optional string CycleName )
{
	if ( CycleName == "" )
	{
		CycleName = SpawnCycle;
	}

	CDConsolePrintScheduleSlug( CycleName );

	if ( SpawnCycle == "unmodded" )
	{
		CDPrintSpawnDetailsHelp();
		return;
	}

	CDConsolePrint("Printing zed spawn cycles on each wave...", false);
	CDConsolePrintSpawnDetails( CustomWaveInfos /* TODO not this */, "full", GameInfo_CDCP );
}

function CDPrintSpawnDetailsHelp()
{
	CDConsolePrint( "  This command displays the exact composition and ordering of zed squads that", false );
	CDConsolePrint( "  spawn when the CD option SpawnCycle is not \"unmodded\" (the default).", false );
	CDConsolePrint( "  Either change SpawnCycle to something other than \"unmodded\" or invoke", false );
	CDConsolePrint( "  this command with the name of the SpawnCycle that you want to examine.", false );
}

exec function CDSpawnPresets()
{
	local int i;
	local CD_SpawnCycle_Preset SCPreset;

	CDConsolePrint( "  Total available SpawnCycle presets: "$ SpawnCyclePresetList.length, false );

	if ( 0 < SpawnCyclePresetList.length )
	{
		CDConsolePrint( "  Listing format:", false);
		CDConsolePrint( "    <SpawnCycle name> [SML]", false );
		CDConsolePrint( "  The SML letters denote supported game lengths (Short/Medium/Long)", false);
		CDConsolePrint( "  --------------------------------------------------------------------------", false );
	}

	for ( i = 0; i < SpawnCyclePresetList.length; i++ )
	{
		SCPreset = SpawnCyclePresetList[i];
		CDConsolePrint( "    "$ SCPreset.GetName()$" "$ GetLengthBadgeForPreset( SCPreset ), false );
	}
}

function string GetLengthBadgeForPreset( CD_SpawnCycle_Preset SCPreset )
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

function CDConsolePrintScheduleSlug( string CycleName )
{
	if ( CycleName == "unmodded" )
	{
		CDConsolePrint("  Considering SpawnCycle="$CycleName$" (zeds spawn randomly, as in standard KF2)", false);
	}
	else if ( CycleName == "ini" )
	{
		CDConsolePrint("  Considering SpawnCycle="$CycleName$" (zeds spawn according to the config file)", false);
	}
	else
	{
		CDConsolePrint("  Considering SpawnCycle="$CycleName$" (zeds spawn according to preset "$SpawnCycle$")", false);
	}
}

static function CDConsolePrintSpawnDetails( const out array<CD_AIWaveInfo> WaveInfos, const string Verbosity, const CD_ConsolePrinter CDCP )
{
	local int WaveIndex, SquadIndex, ElemIndex;
	local string s;
	local CD_AIWaveInfo wi;
	local CD_AISpawnSquad ss;
	local array<string> SquadList;
	local array<string> ElemList;
	local string ZedNameTmp;

	for ( WaveIndex = 0; WaveIndex < WaveInfos.length; WaveIndex++ )
	{
		wi = WaveInfos[WaveIndex];
		SquadList.length = 0;

		for ( SquadIndex = 0; SquadIndex < wi.CustomSquads.length; SquadIndex++ )
		{
			ss = wi.CustomSquads[SquadIndex];
			ElemList.length = 0;

			for ( ElemIndex = 0; ElemIndex < ss.CustomMonsterList.length; ElemIndex++ )
			{
				if ( Verbosity == "tiny" )
				{
					class'CD_ZedNameUtils'.static.GetZedTinyName( ss.CustomMonsterList[ElemIndex], ZedNameTmp );
				}
				else if ( Verbosity == "full" )
				{
					class'CD_ZedNameUtils'.static.GetZedFullName( ss.CustomMonsterList[ElemIndex], ZedNameTmp );
				}
				else
				{
					class'CD_ZedNameUtils'.static.GetZedShortName( ss.CustomMonsterList[ElemIndex], ZedNameTmp );
				}

				if ( ZedNameTmp == "" )
				{
					ZedNameTmp = string( ss.CustomMonsterList[ElemIndex].Type );
				}

				ElemList.AddItem(string( ss.CustomMonsterList[ElemIndex].Num ) $ ZedNameTmp);
			}

			JoinArray( ElemList, s, "_" );
			SquadList.AddItem( s );
		}

		JoinArray( SquadList, s, ", " );
		CDCP.Print( "["$GetShortWaveName( WaveIndex )$"] "$s, false );
	}
}

function CDConsolePrintSpawnSummaries( string CycleName, int PlayerCount, CD_ConsolePrinter CDCP )
{
	local int WaveIndex;
	local CD_AIWaveInfo wi;
	local CD_WaveSummary WaveSummary, GameSummary;
	local string WaveSummaryString;

	if ( PlayerCount <= 0 )
	{
		PlayerCount = 1;
	}

	GameSummary = new class'CD_WaveSummary';

	for ( WaveIndex = 0; WaveIndex < CustomWaveInfos.length; WaveIndex++ )
	{
		wi = CustomWaveInfos[WaveIndex];

		WaveSummaryString = "";

		WaveSummary = new class'CD_WaveSummary';

		GetCDWaveSummary( wi, WaveIndex, PlayerCount, WaveSummary );
		GameSummary.AddParamToSelf( WaveSummary );
		WaveSummaryString = WaveSummary.GetString();

		CDCP.Print( "["$GetShortWaveName( WaveIndex )$"] "$WaveSummaryString, false );
	}

	CDCP.Print( " >> Projected Game Totals:", false );
	CDCP.Print( "         "$GameSummary.GetString(), false );
	CDCP.Print( " >> Boss wave not included in preceding tally.", false );
}

function GetCDWaveSummary( CD_AIWaveInfo WaveInfo, int WaveIndex, int PlayerCount, out CD_WaveSummary result )
{
	local int WaveTotalAI;
	local int squadIndex;
	local sDifficultyWaveInfo DWS;
	local class<CDSpawnManager> cdsmClass;
	local CD_AISpawnSquad CDSquad;
	local array<AISquadElement> CustomMonsterList;
	local int elemIndex, remainingBudget, zedsFromElement;

	cdsmClass = class<CDSpawnManager>( SpawnManagerClasses[GameLength] );
	// Don't initialize this one; we just want to ask it about MaxAI
	// SpawnManager.Initialize();
	DWS = cdsmClass.default.DifficultyWaveSettings[ Min(GameDifficulty, cdsmClass.default.DifficultyWaveSettings.Length-1) ];

	WaveTotalAI = DWS.Waves[WaveIndex].MaxAI *
	              CustomDifficultyInfo.GetRawPlayerNumMaxAIModifier( PlayerCount ) *
	              DifficultyInfo.GetDifficultyMaxAIModifier();
	
	result.Clear();

	squadIndex = 0;

	while ( result.GetTotal() < WaveTotalAI )
	{
		CDSquad = WaveInfo.CustomSquads[squadIndex++ % WaveInfo.CustomSquads.length];

		CDSquad.CopyAISquadElements( CustomMonsterList );

		for ( elemIndex = 0; elemIndex < CustomMonsterList.length; elemIndex++ )
		{

			remainingBudget = WaveTotalAI - result.GetTotal();

			if ( remainingBudget <= 0 )
			{
				break;
			}

			zedsFromElement = Min( CustomMonsterList[elemIndex].Num, remainingBudget );

			result.Increment( CustomMonsterList[elemIndex].Type, zedsFromElement );
		}
	}
}

function CDConsolePrintHelpForSpawnDetails()
{
	CDConsolePrint( "This command displays the currently selected CD spawn cycle.", false );
	CDConsolePrint( "Supported verbosity levels:", false );
	CDConsolePrint( "    tiny: abbreviate zed names as much as possible", false );
	CDConsolePrint( "    short: abbreviate zed names down to two letters", false );
	CDConsolePrint( "    full: don't abbreviate zed names", false );
	CDConsolePrint( "For example, to print spawn details with full zed names:", false );
	CDConsolePrint( "    CDSpawnDetails full", false );
	CDConsolePrint( "You can omit the verbosity level argument, in which case", false );
	CDConsolePrint( "this command defaults to \"short\".", false );
}

static function bool GetBoolOption( string Options, string ParseString, bool CurrentValue )
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	if ( InOpt != "" )
	{
		return bool(InOpt);
	}

	return CurrentValue;
}

static function string GetShortWaveName( int WaveIndex )
{
	local string s;

	s = string( WaveIndex + 1 );

	while ( 2 > Len(s) )
	{
		s = "0" $ s;
	}

	s = "W" $ s;

	return s;
}

function CDConsolePrint( string message, optional bool autoPrefix = true )
{
	GameInfo_CDCP.Print( message, autoPrefix );
}

defaultproperties
{
	GameConductorClass=class'ControlledDifficulty.CD_DummyGameConductor'

	DifficultyInfoClass=class'ControlledDifficulty.CD_DifficultyInfo'

	SpawnManagerClasses(0)=class'ControlledDifficulty.CDSpawnManager_Short'
	SpawnManagerClasses(1)=class'ControlledDifficulty.CDSpawnManager_Normal'
	SpawnManagerClasses(2)=class'ControlledDifficulty.CDSpawnManager_Long'

	PlayerControllerClass=class'ControlledDifficulty.CD_PlayerController'

	Begin Object Class=CD_ConsolePrinter Name=Default_CDCP
	End Object

	GameInfo_CDCP=Default_CDCP
}
