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
// "std": unmodded game behavior
// all other values are reserved for potential future preset names
var config string SquadSchedule;
var config array<string> SquadScheduleDefs;

// "hans" or "volter": forces the hans boss wave
// "pat", "patty", "patriarch": forces the patriarch boss wave
// else: choose a random boss wave (unmodded game behavior)
var config string Boss;

var CD_DifficultyInfo CustomDifficultyInfo;

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
	local array<CD_AIWaveInfo> waveInfos;

	for ( i = 0; i < fullRawSchedule.length; i++ )
	{
		`log("Attempting to parse wave "$(i + 1)$"...");
		waveInfos.AddItem( ParseSquadScheduleDef( fullRawSchedule[i] ) );
	}

	return waveInfos;
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

function EAIType GetZedType( string ZedName )
{
	if( Left(ZedName, 5) ~= "ClotA" || Left(ZedName, 2) ~= "CA" )
	{
		return AT_AlphaClot;
	}
	else if( Left(ZedName, 5) ~= "ClotS" || Left(ZedName, 2) ~= "CS" )
	{
		return AT_SlasherClot;
	}
	else if( Left(ZedName, 5) ~= "ClotC" || Left(ZedName, 2) ~= "CC" || ZedName ~= "CLOT" )
	{
		return AT_Clot;
	}
	else if( Left(ZedName, 1) ~= "F" )
	{
		return AT_FleshPound;
	}
	else if( Left(ZedName, 1) ~= "G" )
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
	else if( Left(ZedName, 2) ~= "Hu" ) // could accept "H", but then can't have "H" = Hans
	{
		return AT_Husk;
	}
	else if( Left(ZedName, 2) ~= "Si" )
	{
		return AT_Siren;
	}

	//ClientMessage("Could not spawn ZED ["$ZedName$"]. Please make sure you specified a valid ZED name (ClotA, ClotS, ClotC, etc.) and that the ZED has a valid archetype setup.", CheatType );
	return 255;
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

static function CDConsolePrint( string message )
{
	local KFGameViewportClient GVC;
	GVC = KFGameViewportClient(class'GameEngine'.static.GetEngine().GameViewport);
	GVC.ViewportConsole.OutputTextLine("[ControlledDifficulty] "$message);
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
	local array<CD_AIWaveInfo> WaveInfos;

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
