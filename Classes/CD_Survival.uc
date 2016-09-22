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

var CD_DifficultyInfo CustomDifficultyInfo;

event InitGame( string Options, out string ErrorMessage )
{
	local float SpawnModFromGameOptions;
	local float SpawnModBeforeClamping;
	local int MaxMonstersFromGameOptions;
	local bool AlbinoCrawlersFromGameOptions;

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
	super.InitSpawnManager();

	if ( SpawnManager.isA( 'CDSpawnManager' ) )
	{
		`log("Checked that SpawnManager "$SpawnManager$" is an instance of CDSpawnManager (OK)", bLogControlledDifficulty);
	}
	else
	{
		CDConsolePrint("WARNING: SpawnManager "$SpawnManager$" appears to be misconfigured! CD might not work correctly.");
	}

	if (0 < MaxMonsters)
	{
		CDConsolePrint("MaxMonsters="$MaxMonsters);
	}
	else
	{
		CDConsolePrint("MaxMonsters=<unmodded default>");
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
