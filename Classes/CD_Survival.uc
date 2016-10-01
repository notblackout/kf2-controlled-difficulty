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

// true to log some internal state specific to this mod
var config bool bLogControlledDifficulty;

// "ini": read info about squads from config and use it to set spawn squads
// "unmodded": unmodded game behavior
// all other values are reserved for potential future preset names
var config string SquadSchedule;
var config array<string> SquadScheduleDefs;

// "hans" or "volter": forces the hans boss wave
// "pat", "patty", "patriarch": forces the patriarch boss wave
// else: choose a random boss wave (unmodded game behavior)
var config string Boss;

var CD_DifficultyInfo CustomDifficultyInfo;

var array<CD_AIWaveInfo> WaveInfos;

event InitGame( string Options, out string ErrorMessage )
{
	local float SpawnModFromGameOptions;
	local float SpawnModBeforeClamping;
	local int MaxMonstersFromGameOptions;
	local bool AlbinoCrawlersFromGameOptions;
	local string SquadScheduleFromGameOptions;

 	Super.InitGame( Options, ErrorMessage );

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

	if ( HasOption(Options, "SquadSchedule") )
	{
		SquadScheduleFromGameOptions = ParseOption(Options, "SquadSchedule" );
		`log("SquadScheduleFromGameOptions = "$SquadScheduleFromGameOptions, bLogControlledDifficulty);
		SquadSchedule = SquadScheduleFromGameOptions;
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

	SaveConfig();
}

function array<CD_AIWaveInfo> ParseFullSquadSchedule( array<string> fullRawSchedule )
{
	local int i;
	local array<CD_AIWaveInfo> wis;

	for ( i = 0; i < fullRawSchedule.length; i++ )
	{
		`log("Attempting to parse wave "$(i + 1)$"...");
		wis.AddItem( ParseSquadScheduleDef( fullRawSchedule[i] ) );
	}

	return wis;
}

function CD_AIWaveInfo ParseSquadScheduleDef( string rawSchedule )
{
	local array<string> squadDefs;
	local array<string> elemDefs;
	local int squadIdx;
	local int elemIdx;
	local CD_AIWaveInfo waveInfo;
	local CD_AISpawnSquad curSquad;
	local AISquadElement curElement;
	local int elemStrLen;
	local int elemStrIdx;
	local int unicodeVal;

	local string elemCount;
	local string elemType;

	local int elemCountInt;

	local EAIType elemEAIType;

	waveInfo = new class'ControlledDifficulty.CD_AIWaveInfo';

	// Split on , and drop empty elements
	squadDefs = SplitString( rawSchedule, ",", true );

	// Iterate through the squads
	for ( squadIdx = 0; squadIdx < squadDefs.length; squadIdx++ )
	{
		curSquad = new class'ControlledDifficulty.CD_AISpawnSquad';

		// Squads may in general be heterogeneous, e.g.
		// 2SClot_3Ccrawler_2Gorefast_2Siren
		//
		// This general model also allows squads that are homogeneous, e.g. 
		// 6Crawler
		//
		// In the following code, we split on _ and loop through
		// each element, populating a CD_AISpawnSquad as we go.
		elemDefs = SplitString( squadDefs[squadIdx], "_", true );

		for ( elemIdx = 0; elemIdx < elemDefs.length; elemIdx++ )
		{
			elemStrLen = Len( elemDefs[elemIdx] );

			for ( elemStrIdx = 0; elemStrIdx < elemStrLen; elemStrIdx++ )
			{
				unicodeVal = Asc( Mid( elemDefs[elemIdx], elemStrIdx, 1 ) );
				if ( !( 48 <= unicodeVal && unicodeVal <= 57 ) )
				{
					break;
				}
			}

			if ( elemStrIdx < elemStrLen )
			{
				elemCount = Mid( elemDefs[elemIdx], 0, elemStrIdx );
				elemType  = Mid( elemDefs[elemIdx], elemStrIdx, elemStrLen - elemStrIdx );
			}

			if ( elemCount == "" )
			{
				elemCount = "1";
			}

			elemEAIType = GetZedType( elemType );

			elemCountInt = int(elemCount);

			if ( "" == elemCount || elemCountInt < 1 || elemCountInt > 6 )
			{
				// TODO invalid elem count
				`log("Invalid elemCount "$elemCount);
				continue;
			}

			if ( 255 == elemEAIType )
			{
				// TODO invalid elem class
				`log("Invalid elemType "$elemType);
				continue;
			}

			curElement.Type = elemEAIType;
			curElement.Num = elemCountInt;
			curElement.CustomClass = none;

			`log("[squad#"$squadIdx$"] Parsed squad element: "$curElement.Num$"x"$curElement.Type);

			curSquad.AddSquadElement(curElement);
		}

		// todo check whether special or not, add to appropriate dynarray
		waveInfo.CustomSquads.AddItem(curSquad);
	}

	return waveInfo;
}

/**
    Get a zed EAIType from the name.

    This is based on the LoadMonsterByName from KFCheatManager, but I have a separate copy here
    for four reasons:
    0. I need EAIType instead of a class, and there does not seem to be an easy way to convert those
    1. To allow for a few more abbreviations than KFCheatManager knows (e.g. for clots: CC, CA, CS)
    2. So that a hypothetical future KF2 update that might change KFCheatManager's zed abbreviations
       will not change the behavior of this method, which is used to parse wave squad schedules and
       generally represents a public API that must not change.
    4. I have no need for the "friendly" zed shorthand names here, and I want to accept the absolute
       minimum universe of correct inputs, so that this is easy to maintain.  Same for "TestHusk".
*/

static function EAIType GetZedType( string ZedName )
{
	if( Left(ZedName, 5) ~= "ClotA" || Left(ZedName, 2) ~= "Al" || ZedName ~= "CA" )
	{
		return AT_AlphaClot;
	}
	else if( Left(ZedName, 5) ~= "ClotS" || Left(ZedName, 2) ~= "Sl" || ZedName ~= "CS" )
	{
		return AT_SlasherClot;
	}
	else if( Left(ZedName, 5) ~= "ClotC" || ZedName ~= "CC" || Left(ZedName, 2) ~= "cy" || ZedName ~= "clot" )
	{
		return AT_Clot;
	}
	else if( Left(ZedName, 1) ~= "F" )
	{
		return AT_FleshPound;
	}
	else if( Left(ZedName, 1) ~= "G" ) // DG(F) / DoubleGorefast reserved
	{
		return AT_GoreFast;
	}
	else if( Left(ZedName, 2) ~= "St" )
	{
		return AT_Stalker;
	}
	else if( Left(ZedName, 1) ~= "B" )
	{
		return AT_Bloat;
	}
	else if( Left(ZedName, 2) ~= "Sc" )
	{
		return AT_Scrake;
	}
	else if( Left(ZedName, 2) ~= "Cr" )
	{
		return AT_Crawler;
	}
	else if( Left(ZedName, 2) ~= "H" ) // this is ambiguous if we ever decide to accept Hans
	{
		return AT_Husk;
	}
	else if( Left(ZedName, 2) ~= "Si" )
	{
		return AT_Siren;
	}
	else
	{
		// TODO error handling
	}

	//ClientMessage("Could not spawn ZED ["$ZedName$"]. Please make sure you specified a valid ZED name (ClotA, ClotS, ClotC, etc.) and that the ZED has a valid archetype setup.", CheatType );
	return 255;
}

static function String GetZedFullName( EAIType ZedType )
{
	if ( ZedType == AT_AlphaClot )
	{
		return "Alpha";
	}
	else if ( ZedType == AT_SlasherClot )
	{
		return "Slasher";
	}
	else if ( ZedType == AT_Clot ) 
	{
		return "Cyst";
	}
	else if ( ZedType == AT_FleshPound )
	{
		return "Fleshpound";
	}
	else if ( ZedType == AT_Gorefast )
	{
		return "Gorefast";
	}
	else if ( ZedType == AT_Stalker )
	{
		return "Stalker";
	}
	else if ( ZedType == AT_Bloat )
	{
		return "Bloat";
	}
	else if ( ZedType == AT_Scrake )
	{
		return "Scrake";
	}
	else if ( ZedType == AT_Crawler )
	{
		return "Crawler";
	}
	else if ( ZedType == AT_Husk )
	{
		return "Husk";
	}
	else if ( ZedType == AT_Siren )
	{
		return "Siren";
	}
	else
	{
		// TODO error handling
	}

	//ClientMessage("Could not spawn ZED ["$ZedName$"]. Please make sure you specified a valid ZED name (ClotA, ClotS, ClotC, etc.) and that the ZED has a valid archetype setup.", CheatType );
	return "?";
}

static function String GetZedTinyName( EAIType ZedType )
{
	if ( ZedType == AT_AlphaClot )
	{
		return "AL";
	}
	else if ( ZedType == AT_SlasherClot )
	{
		return "SL";
	}
	else if ( ZedType == AT_Clot ) 
	{
		return "CY";
	}
	else if ( ZedType == AT_FleshPound )
	{
		return "F";
	}
	else if ( ZedType == AT_Gorefast )
	{
		return "G";
	}
	else if ( ZedType == AT_Stalker )
	{
		return "ST";
	}
	else if ( ZedType == AT_Bloat )
	{
		return "B";
	}
	else if ( ZedType == AT_Scrake )
	{
		return "SC";
	}
	else if ( ZedType == AT_Crawler )
	{
		return "CR";
	}
	else if ( ZedType == AT_Husk )
	{
		return "H";
	}
	else if ( ZedType == AT_Siren )
	{
		return "SI";
	}
	else
	{
		// TODO error handling
	}

	//ClientMessage("Could not spawn ZED ["$ZedName$"]. Please make sure you specified a valid ZED name (ClotA, ClotS, ClotC, etc.) and that the ZED has a valid archetype setup.", CheatType );
	return "?";
}

static function String GetZedShortName( EAIType ZedType )
{
	if ( ZedType == AT_AlphaClot )
	{
		return "AL";
	}
	else if ( ZedType == AT_SlasherClot )
	{
		return "SL";
	}
	else if ( ZedType == AT_Clot ) 
	{
		return "CY";
	}
	else if ( ZedType == AT_FleshPound )
	{
		return "FP";
	}
	else if ( ZedType == AT_Gorefast )
	{
		return "GF";
	}
	else if ( ZedType == AT_Stalker )
	{
		return "ST";
	}
	else if ( ZedType == AT_Bloat )
	{
		return "BL";
	}
	else if ( ZedType == AT_Scrake )
	{
		return "SC";
	}
	else if ( ZedType == AT_Crawler )
	{
		return "CR";
	}
	else if ( ZedType == AT_Husk )
	{
		return "HU";
	}
	else if ( ZedType == AT_Siren )
	{
		return "SI";
	}
	else
	{
		// TODO error handling
	}

	//ClientMessage("Could not spawn ZED ["$ZedName$"]. Please make sure you specified a valid ZED name (ClotA, ClotS, ClotC, etc.) and that the ZED has a valid archetype setup.", CheatType );
	return "?";
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
				killerPawnClass = Killer.Pawn.Class;
				if ( killerPawnClass == class'CDPawn_ZedCrawler' )
				{
					killerPawnClass = class'KFPawn_ZedCrawler';
					`log("Mapped CDPawn_ZedCrawler to KFPawn_ZedCrawler in BroadcastDeathMessage(...)");
				}
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

static function CDConsolePrint( string message, optional bool autoPrefix = true )
{
	local KFGameViewportClient GVC;
	GVC = KFGameViewportClient(class'GameEngine'.static.GetEngine().GameViewport);

	if ( autoPrefix )
	{
		GVC.ViewportConsole.OutputTextLine("[ControlledDifficulty] "$message);
	}
	else
	{
		GVC.ViewportConsole.OutputTextLine(message);
	}
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

	super.InitSpawnManager();

	if ( SpawnManager.isA( 'CDSpawnManager' ) )
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

	if ( SquadSchedule == "ini" )
	{
		`log("Attempting to parse squad information in config...");
		WaveInfos = ParseFullSquadSchedule( SquadScheduleDefs );
		// TODO WaveInfo validation
		cdsm.SetCustomWaves( WaveInfos );
	}
	else
	{
		`log("Not reading squad information from config (value="$SquadSchedule$")");
	}

	CDConsolePrint( "AlbinoCrawlers="$AlbinoCrawlers );
}

exec function logControlledDifficulty( bool enabled )
{
	bLogControlledDifficulty = enabled;
	`log("Set bLogControlledDifficulty = "$bLogControlledDifficulty);
	SaveConfig();
}

exec function CDSpawnSummaries( optional int AssumedPlayerCount = -255 )
{
	CDConsolePrintScheduleSlug();

	if ( SquadSchedule == "unmodded" )
	{
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
			CDConsolePrint( "> cdSpawnSummaries 2", false );
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

	CDConsolePrintSpawnSummaries( AssumedPlayerCount );
}

exec function CDSpawnDetails( optional string Verbosity = "" )
{
	CDConsolePrintScheduleSlug();

	if ( SquadSchedule == "unmodded" )
	{
		return;
	}

	Verbosity = Locs( Verbosity );

	if ( Verbosity == "" )
	{
		Verbosity = "short";
		CDConsolePrint( "Verbosity level: \""$Verbosity$"\" (run \"CDSpawnDetails help\" for more choices)", false );
	}
	else if ( Verbosity == "tiny" || Verbosity == "short" || Verbosity == "long" )
	{
		// do nothing
	}
	else if ( Verbosity == "help" )
	{
		CDConsolePrintHelpForSpawnDetails();
		return;
	}
	else
	{
		CDConsolePrint( "Parameter \""$Verbosity$"\" is not valid.", false );
		CDConsolePrintHelpForSpawnDetails();
		return;
	}

	CDConsolePrint("Printing zed spawn cycles on each wave...", false);
	CDConsolePrintSpawnDetails( Verbosity );
}

static function CDConsolePrintHelpForSpawnDetails()
{
	CDConsolePrint( "This command displays the currently selected CD spawn cycle.", false );
	CDConsolePrint( "Supported verbosity levels:", false );
	CDConsolePrint( "    tiny: abbreviate zed names as much as possible", false );
	CDConsolePrint( "    short: abbreviate zed names down to two letters", false );
	CDConsolePrint( "    long: don't abbreviate zed names", false );
	CDConsolePrint( "For example, to print spawn details with full zed names:", false );
	CDConsolePrint( "    CDSpawnDetails long", false );
	CDConsolePrint( "You can omit the verbosity level argument, in which case", false );
	CDConsolePrint( "this command defaults to \"short\".", false );
}

function CDConsolePrintScheduleSlug()
{
	if ( SquadSchedule == "unmodded" )
	{
		CDConsolePrint("SquadSchedule="$SquadSchedule$" (zeds spawn randomly, as in standard KF2)", false);
	}
	else if ( SquadSchedule == "ini" )
	{
		CDConsolePrint("SquadSchedule="$SquadSchedule$" (zeds spawn according to the config file)", false);
	}
	else
	{
		CDConsolePrint("SquadSchedule="$SquadSchedule$" (zeds spawn according to preset "$SquadSchedule$")", false);
	}
}

static function string ZeroPadIntString( int numberToFormat, int totalWidth )
{
	local string numberAsString;

	numberAsString = string( numberToFormat );

	while ( Len(numberAsString) < totalWidth )
	{
		numberAsString = "0" $ numberAsString;
	}
	
	return numberAsString;
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

function CDConsolePrintSpawnDetails( string Verbosity )
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
					ZedNameTmp = GetZedTinyName( ss.CustomMonsterList[ElemIndex].Type );
				}
				else if ( Verbosity == "long" )
				{
					ZedNameTmp = GetZedFullName( ss.CustomMonsterList[ElemIndex].Type );
				}
				else
				{
					ZedNameTmp = GetZedShortName( ss.CustomMonsterList[ElemIndex].Type );
				}

				ElemList.AddItem(string( ss.CustomMonsterList[ElemIndex].Num ) $ ZedNameTmp);
			}

			JoinArray( ElemList, s, "_" );
			SquadList.AddItem( s );
		}

		JoinArray( SquadList, s, ", " );
		CDConsolePrint( "["$GetShortWaveName( WaveIndex )$"] "$s, false );
	}

	// TODO log boss override (if any)
}

function CDConsolePrintSpawnSummaries( int PlayerCount )
{
	local int WaveIndex;
	local CD_AIWaveInfo wi;
	local CD_WaveSummary WaveSummary, GameSummary;
	local string WaveSummaryString;

	if ( PlayerCount <= 0 )
	{
		// TODO complain about being handed nonpositive players
		PlayerCount = 1;
	}

	GameSummary = new class'CD_WaveSummary';

	for ( WaveIndex = 0; WaveIndex < WaveInfos.length; WaveIndex++ )
	{
		wi = WaveInfos[WaveIndex];

		WaveSummaryString = "";

		WaveSummary = new class'CD_WaveSummary';

		GetCDWaveSummary( wi, WaveIndex, PlayerCount, WaveSummary );
		GameSummary.AddParamToSelf( WaveSummary );
		WaveSummaryString = WaveSummary.GetString();

		CDConsolePrint( "["$GetShortWaveName( WaveIndex )$"] "$WaveSummaryString, false );
	}

	CDConsolePrint( " >> Projected Game Totals:", false );
	CDConsolePrint( "[TOT] "$GameSummary.GetString(), false );
	CDConsolePrint( " >> Boss wave not included in preceding tally.", false );
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
	              PlayerCount *
	              DifficultyInfo.GetDifficultyMaxAIModifier();
	
	result.Clear();

	squadIndex = -1;

	while ( result.Total < WaveTotalAI )
	{
		CDSquad = WaveInfo.CustomSquads[squadIndex++ % WaveInfo.CustomSquads.length];

		CDSquad.CopyAISquadElements( CustomMonsterList );

		for ( elemIndex = 0; elemIndex < CustomMonsterList.length; elemIndex++ )
		{

			remainingBudget = WaveTotalAI - result.total;

			if ( remainingBudget <= 0 )
			{
				break;
			}

			zedsFromElement = Min( CustomMonsterList[elemIndex].Num, remainingBudget );

			result.Increment( CustomMonsterList[elemIndex].Type, zedsFromElement );
		}
	}
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

defaultproperties
{
	GameConductorClass=class'ControlledDifficulty.CD_DummyGameConductor'

	DifficultyInfoClass=class'ControlledDifficulty.CD_DifficultyInfo'

	SpawnManagerClasses(0)=class'ControlledDifficulty.CDSpawnManager_Short'
	SpawnManagerClasses(1)=class'ControlledDifficulty.CDSpawnManager_Normal'
	SpawnManagerClasses(2)=class'ControlledDifficulty.CDSpawnManager_Long'

	PlayerControllerClass=class'ControlledDifficulty.CD_PlayerController'
}
