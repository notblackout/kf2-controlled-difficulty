//=============================================================================
// ControlledDifficulty_Survival
//=============================================================================
// Survival with less bullshit
//=============================================================================

class CD_Survival extends KFGameInfo_Survival;

`include(CD_BuildInfo.uci)

enum EWaveInfoStatus
{
	WIS_OK,
	WIS_PARSE_ERROR,
	WIS_SPAWNCYCLE_NOT_MODDED
};

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

var array<CD_AIWaveInfo> IniWaveInfos;
var bool AlreadyLoadedIniWaveInfos;

var CD_DifficultyInfo CustomDifficultyInfo;

var CD_ConsolePrinter GameInfo_CDCP;

var CD_SpawnCycleCatalog SpawnCycleCatalog;

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

	SpawnCycleCatalog = new class'CD_SpawnCycleCatalog';
	SpawnCycleCatalog.Initialize( AIClassList, GameInfo_CDCP );

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
		GameInfo_CDCP.Print("SpawnMod="$SpawnModFloat);
	}
	else
	{
		GameInfo_CDCP.Print("SpawnMod="$SpawnModFloat$" (clamped from "$SpawnModBeforeClamping$")");
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
		GameInfo_CDCP.Print("WARNING invalid Boss setting \""$Boss$"\"; Valid alternatives: patriarch, hans, or unmodded");
		GameInfo_CDCP.Print("Boss=unmodded (forced because \""$ Boss $"\" is invalid)");
		Boss = "unmodded";
	}
	else
	{
		GameInfo_CDCP.Print("Boss="$ Boss);
	}

	SaveConfig();
}

/* 
 * We override this function for the sole purpose of hiding
 * our custom CD_ZedPawn classnames from the kill ticker.
 * classname literals are embedded in the internationalization
 * assets, so it's impossible to display custom zed class names
 * properly on the client's zed kill ticker without a
 * specifically client-side mod, which I don't want to do.
 *
 * This class intercepts outgoing kill ticker messages mentioning
 * a CD_ZedPawn class and replaces that class with its standard
 * KF_ZedPawn equivalent.
 *
 * This prevents the client from falling back on its ugly
 * "I don't know how to internationalize this string" behavior,
 * which is something like "?<Package.Classname>?".
 */
function BroadcastDeathMessage(Controller Killer, Controller Other, class<DamageType> damageType)
{
	local class killerPawnClass;

	if ( (Killer == Other) || (Killer == None) )
	{
		// suicide
		BroadcastLocalized(self, class'KFLocalMessage_Game', KMT_Suicide, None, Other.PlayerReplicationInfo);
	}
	else
	{
		if ( Killer.IsA('KFAIController') )
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

/*
 * Check that the game conductor is lobotomized (or print a warning if not)
 */
function InitGameConductor()
{
	super.InitGameConductor();

	if ( GameConductor.isA( 'CD_DummyGameConductor' ) )
	{
		`log("Checked that GameConductor "$GameConductor$" is an instance of CD_DummyGameConductor (OK)", bLogControlledDifficulty);
	}
	else
	{
		GameInfo_CDCP.Print("WARNING: GameConductor "$GameConductor$" appears to be misconfigured! CD might not work correctly.");
	}
}

/*
 * Setup CD_DifficultyInfo, FakePlayers, and TraderTime.
 */
function CreateDifficultyInfo(string Options)
{
	local int FakePlayersFromGameOptions;
	local int FakePlayersBeforeClamping;
	local int TraderTimeFromGameOptions;

	super.CreateDifficultyInfo(Options);

	// Print CD's commit hash (version)
	GameInfo_CDCP.Print("Version " $ `CD_COMMIT_HASH $ " (" $ `CD_AUTHOR_TIMESTAMP $ ") loaded");

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
		GameInfo_CDCP.Print("FakePlayers="$FakePlayers$" (clamped from "$FakePlayersBeforeClamping$")");
	}
	else
	{
		GameInfo_CDCP.Print("FakePlayers="$FakePlayers);
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
		GameInfo_CDCP.Print("TraderTime="$TraderTime);
	}
	else
	{
		GameInfo_CDCP.Print("TraderTime=<unmodded default>");
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

/*
 * Configure CD_SpawnManager according to user-specified options, including:
 *
 *  - SpawnCycle
 *  - Boss
 *  - AlbinoAlphas
 *  - AlbinoCrawlers
 */ 
function InitSpawnManager()
{
	local CDSpawnManager cdsm;

	local array<CD_AIWaveInfo> ActiveWaveInfos;

	super.InitSpawnManager();

	if ( SpawnManager.IsA( 'CDSpawnManager' ) )
	{
		`log("Checked that SpawnManager "$SpawnManager$" is an instance of CDSpawnManager (OK)", bLogControlledDifficulty);
		cdsm = CDSpawnManager( SpawnManager );
	}
	else
	{
		GameInfo_CDCP.Print("WARNING: SpawnManager "$SpawnManager$" appears to be misconfigured! CD might not work correctly.");
		return;
	}

	if (0 < MaxMonsters)
	{
		GameInfo_CDCP.Print("MaxMonsters="$MaxMonsters);
	}
	else
	{
		GameInfo_CDCP.Print("MaxMonsters=<unmodded default>");
	}

	// Assign a spawn definition array to CycleDefs (unless SpawnCycle=random)
	if ( SpawnCycle == "ini" )
	{
		MaybeLoadIniWaveInfos();

		ActiveWaveInfos = IniWaveInfos;
	}
	else if ( SpawnCycle == "unmodded" )
	{
		`log("Not using a SpawnCycle (value="$SpawnCycle$")");
	}
	else
	{
		if ( !SpawnCycleCatalog.ParseSquadCyclePreset( SpawnCycle, GameLength, ActiveWaveInfos ) )
		{
			ActiveWaveInfos.length = 0;
		}
	}

	if ( 0 == ActiveWaveinfos.length )
	{
		GameInfo_CDCP.Print( "SpawnCycle=unmodded (forced because \""$ SpawnCycle $"\" is invalid or does not support this game length)" );
		SpawnCycle = "unmodded";
	}
	else
	{
		cdsm.SetCustomWaves( ActiveWaveInfos );
		GameInfo_CDCP.Print( "SpawnCycle="$ SpawnCycle );
	}

	if ( SpawnCycle == "unmodded" )
	{
		GameInfo_CDCP.Print( "AlbinoCrawlers="$AlbinoCrawlers );
		GameInfo_CDCP.Print( "AlbinoAlphas="$AlbinoAlphas );
	}
	else
	{
		GameInfo_CDCP.Print( "AlbinoCrawlers=<ignored because SpawnCycle is not unmodded>" );
		GameInfo_CDCP.Print( "AlbinoAlphas=<ignored because SpawnCycle is not unmodded>" );
	}
}

private function MaybeLoadIniWaveInfos()
{
	if ( !AlreadyLoadedIniWaveInfos )
	{
		AlreadyLoadedIniWaveInfos = true;

		// This doesn't seem to work (am I forcing a SaveConfig() beforehand?)
		//`log("Forcing a config reload because SpawnCycle="$SpawnCycle$"...");
		//ConsoleCommand("reloadcfg ControlledDifficulty.CD_Survival", true);
		//ConsoleCommand("reloadcfg 'ControlledDifficulty.CD_Survival'", true);
		//ConsoleCommand("reloadcfg \"ControlledDifficulty.CD_Survival\"", true);

		if ( !SpawnCycleCatalog.ParseIniSquadCycle( SpawnCycleDefs, GameLength, IniWaveInfos ) )
		{
			IniWaveInfos.length = 0;
		}
	}
}

exec function logControlledDifficulty( bool enabled )
{
	bLogControlledDifficulty = enabled;
	`log("Set bLogControlledDifficulty = "$bLogControlledDifficulty);
	SaveConfig();
}

exec function CDSpawnSummaries( optional string CycleName, optional int AssumedPlayerCount = -255 )
{
	local array<CD_AIWaveInfo> WaveInfosToSummarize;
	local sDifficultyWaveInfo DWS;
	local class<CDSpawnManager> cdsmClass;
	local EWaveInfoStatus wis;

	wis = GetWaveInfosForConsoleCommand( CycleName, WaveInfosToSummarize );

	if ( wis == WIS_SPAWNCYCLE_NOT_MODDED )
	{
		GameInfo_CDCP.Print("", false);
		GameInfo_CDCP.Print("Usage: CDSpawnSummaries <optional SpawnCycle name> <optional player count>", false);
		GameInfo_CDCP.Print("", false);
		GameInfo_CDCP.Print("This command displays summary zed counts for a SpawnCycle.", false);
		GameInfo_CDCP.Print("It uses the optional SpawnCycle name param when provided, but otherwise", false);
		GameInfo_CDCP.Print("defaults to whatever SpawnCycle was used to open CD.", false);
		GameInfo_CDCP.Print("", false);
		GameInfo_CDCP.Print("Because the current effective SpawnCycle setting is \"unmodded\",", false);
		GameInfo_CDCP.Print("this command has no effect.  Either open CD with a different SpawnCycle", false);
		GameInfo_CDCP.Print("or invoke this command with the name of a SpawnCycle.", false);
		GameInfo_CDCP.Print("", false);
		GameInfo_CDCP.Print("To see a list of available SpawnCycles, invoke CDSpawnPresets.", false);
		return;
	}
	else if ( wis == WIS_PARSE_ERROR )
	{
		return;
	}

	if ( -255 == AssumedPlayerCount )
	{
		if ( WorldInfo.NetMode == NM_StandAlone )
		{
			AssumedPlayerCount = 1 + FakePlayers;
			GameInfo_CDCP.Print( "Projecting wave summaries for "$AssumedPlayerCount$" players = 1 human + "$FakePlayers$" fake(s) in current game length...", false );
		}
		else
		{
			GameInfo_CDCP.Print( "Unable to guess player count in netmode "$WorldInfo.NetMode, false );
			GameInfo_CDCP.Print( "Pass a player count as an argument to this console command, e.g.", false );
			GameInfo_CDCP.Print( "> CDSpawnSummaries 2", false );
			return;
		}
	}
	else if ( 0 < AssumedPlayerCount )
	{
		GameInfo_CDCP.Print( "Projecting wave summaries for "$AssumedPlayerCount$" players in current game length...", false );
	}
	else
	{
		GameInfo_CDCP.Print( "Player count argument "$AssumedPlayerCount$" must be positive", false );
		return;
	}

	cdsmClass = class<CDSpawnManager>( SpawnManagerClasses[GameLength] );
	// No need to instantiate; we just want to check its default 
        // values for about Wave MaxAI 
	DWS = cdsmClass.default.DifficultyWaveSettings[ Min(GameDifficulty, cdsmClass.default.DifficultyWaveSettings.Length-1) ];

	class'CD_WaveInfoUtils'.static.PrintSpawnSummaries( WaveInfosToSummarize, AssumedPlayerCount,
		GameInfo_CDCP, GameLength, CustomDifficultyInfo, DWS );
}

exec function CDSpawnDetails( optional string CycleName )
{
	local array<CD_AIWaveInfo> WaveInfosToSummarize;
	local EWaveInfoStatus wis;

	wis = GetWaveInfosForConsoleCommand( CycleName, WaveInfosToSummarize );

	if ( wis == WIS_OK )
	{
		GameInfo_CDCP.Print("Printing abbreviated zed spawn cycles for each wave...", false);

		class'CD_WaveInfoUtils'.static.PrintSpawnDetails( WaveInfosToSummarize, "short", GameInfo_CDCP );
	}
	else if ( wis == WIS_SPAWNCYCLE_NOT_MODDED )
	{
		CDPrintSpawnDetailsHelp();
	}
}

exec function CDSpawnDetailsVerbose( optional string CycleName )
{
	local array<CD_AIWaveInfo> WaveInfosToSummarize;
	local EWaveInfoStatus wis;

	wis = GetWaveInfosForConsoleCommand( CycleName, WaveInfosToSummarize );

	if ( wis == WIS_OK )
	{
		GameInfo_CDCP.Print("Printing verbose zed spawn cycles for each wave...", false);

		class'CD_WaveInfoUtils'.static.PrintSpawnDetails( WaveInfosToSummarize, "full", GameInfo_CDCP );
	}
	else if ( wis == WIS_SPAWNCYCLE_NOT_MODDED )
	{
		CDPrintSpawnDetailsHelp();
	}
}

function EWaveInfoStatus GetWaveInfosForConsoleCommand( string CycleName, out array<CD_AIWaveInfo> WaveInfos )
{
	WaveInfos.length = 0;

	if ( CycleName == "" )
	{
		CycleName = SpawnCycle;
	}

	PrintScheduleSlug( CycleName );

	if ( CycleName == "unmodded" )
	{
		return WIS_SPAWNCYCLE_NOT_MODDED;
	}

	if ( CycleName == "ini" )
	{
		MaybeLoadIniWaveInfos();

		WaveInfos = IniWaveInfos;
	}
	else if ( !SpawnCycleCatalog.ParseSquadCyclePreset( CycleName, GameLength, WaveInfos ) )
	{
		WaveInfos.length = 0;
	}

	return WaveInfos.length == 0 ? WIS_PARSE_ERROR : WIS_OK;
}

function CDPrintSpawnDetailsHelp()
{
	GameInfo_CDCP.Print("", false);
	GameInfo_CDCP.Print("Usage: CDSpawnDetails(Verbose) <optional SpawnCycle name>", false);
	GameInfo_CDCP.Print("", false);
	GameInfo_CDCP.Print("This command displays precise zed squad composition for a SpawnCycle.", false);
	GameInfo_CDCP.Print("It uses the optional SpawnCycle name param when provided, but otherwise", false);
	GameInfo_CDCP.Print("defaults to whatever SpawnCycle was used to open CD.", false);
	GameInfo_CDCP.Print("", false);
	GameInfo_CDCP.Print("Because the current effective SpawnCycle setting is \"unmodded\",", false);
	GameInfo_CDCP.Print("this command has no effect.  Either open CD with a different SpawnCycle", false);
	GameInfo_CDCP.Print("or invoke this command with the name of a SpawnCycle.", false);
	GameInfo_CDCP.Print("", false);
	GameInfo_CDCP.Print("To see a list of available SpawnCycles, invoke CDSpawnPresets.", false);
}

exec function CDSpawnPresets()
{
	SpawnCycleCatalog.PrintPresets();
}

private function PrintScheduleSlug( string CycleName )
{
	if ( CycleName == "ini" )
	{
		GameInfo_CDCP.Print("Considering SpawnCycle="$CycleName$" (zeds spawn according to the config file)", false);
	}
	else if ( CycleName != "unmodded" )
	{
		GameInfo_CDCP.Print("Considering SpawnCycle="$CycleName$" (if a preset with that name exists)", false);
	}
}

private static function bool GetBoolOption( string Options, string ParseString, bool CurrentValue )
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	if ( InOpt != "" )
	{
		return bool(InOpt);
	}

	return CurrentValue;
}

function bool isRandomBoss()
{
	return isRandomBossString( Boss );
}

function bool isPatriarchBoss()
{
	return isPatriarchBossString( Boss );
}

function bool isVolterBoss()
{
	return isVolterBossString( Boss );
}

static function bool isRandomBossString( const out string s )
{
	return s == "" || s ~= "random" || s ~= "unmodded";
}

static function bool isPatriarchBossString( const out string s )
{
	return s ~= "patriarch" || s~= "patty" || s ~= "pat";
}

static function bool isVolterBossString( const out string s )
{
	return s ~= "hans" || s ~= "volter" || s ~= "moregas";
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
