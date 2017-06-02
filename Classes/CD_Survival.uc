//=============================================================================
// ControlledDifficulty_Survival
//=============================================================================
// Survival with less bullshit
//=============================================================================

class CD_Survival extends KFGameInfo_Survival;

`include(CD_BuildInfo.uci)
`include(CD_Log.uci)

enum EWaveInfoStatus
{
	WIS_OK,
	WIS_PARSE_ERROR,
	WIS_SPAWNCYCLE_NOT_MODDED
};

enum EFakePlayersMode
{
	FPM_ADD,
	FPM_REPLACE
};

enum EZTSpawnMode
{
	ZTSM_UNMODDED,
	ZTSM_CLOCKWORK
};

enum EBossChoice
{
	CDBOSS_RANDOM,
	CDBOSS_VOLTER,
	CDBOSS_PATRIARCH
};

enum CDAuthLevel
{
	CDAUTH_READ,
	CDAUTH_WRITE
};

struct StructAuthorizedUsers
{
	var string SteamID;
	var string Comment;
};

////////////////////
// Config options //
////////////////////

// increase zed count (but not hp) as though this many additional players were
// present; note that the game normally increases dosh rewards for each zed at
// numplayers >= 3, and faking players this way does the same; you can always
// refrain from buying if you want an extra challenge, but if the mod denied
// you that bonus dosh, it could end up being gamebreaking for some runs
var config string FakePlayers; 
var config const array<string> FakePlayersDefs; 
var int FakePlayersInt;

// the trader time, in seconds.  if this is zero or negative, its value is
// totally ignored, and the difficulty's standard trader time is used instead.
var config string TraderTime;
var int TraderTimeInt;

// The timer interval, in seconds, for CD's SpawnManager's update function.
// The update function first checks several state variables to determine
// whether to attempt to spawn more zeds.  If it determines that it should
// spawn zeds, the function then starts placing squads on spawner and/or 
// spawnvolume entities.
// In the unmodded game, this is hardcoded to one second.
var config string MinSpawnInterval;
var config const array<string> MinSpawnIntervalDefs; 
var float MinSpawnIntervalFloat;

// The maximum number of zeds that CD's SpawnManager may spawn
// simultaneously (i.e. on one invocation of the SpawnManager's
// update function).
// If this is set to 0, then the cohort spawn logic is
// inactive, and the game instead spawns one squad per invocation
// of the update function.  That behavior (i.e. when set to 0)
// is how unmodded KF2 works: the spawn manager creates one squad
// per attempt, no matter how much headroom might exist under
// the MaxMonsters limit, or how many eligible spawnvolumes
// might be available to accomodate more squads.
var config string CohortSize;
var config const array<string> CohortSizeDefs;
var int CohortSizeInt;

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
var config const array<string> SpawnModDefs;
var float SpawnModFloat;

var config string TrashFP;
var config const array<string> TrashFPDefs;
var int TrashFPInt;

var config string FleshpoundFP;
var config const array<string> FleshpoundFPDefs;
var int FleshpoundFPInt;

var config string ScrakeFP;
var config const array<string> ScrakeFPDefs;
var int ScrakeFPInt;

var config string BossFP;
var config const array<string> BossFPDefs;
var int BossFPInt;

var config string ZTSpawnSlowdown;
var config const array<string> ZTSpawnSlowdownDefs;
var float ZTSpawnSlowdownFloat;

var config string ZTSpawnMode;
var EZTSpawnMode ZTSpawnModeEnum;

var config string AlphaGlitter;
var bool AlphaGlitterBool;

var config string FakePlayersMode;
var EFakePlayersMode FakePlayersModeEnum;

// the maximum monsters allowed on the map at one time.  in the vanilla game,
// this is 16 when in NM_StandAlone and GetLivingPlayerCount() == 1; 32 in
// any other case (such as when playing alone on a dedicated server).  if this
// is set to a nonpositive value, then the vanilla behavior prevails.  if this
// is set to a positive value, then it overrides the vanilla behavior.
var config string MaxMonsters;
var config const array<string> MaxMonstersDefs;
var int MaxMonstersInt;

// true to allow albino crawlers to spawn as they do in the unmodded game.
// false to spawn regular crawlers in place of albino crawlers.
var config string AlbinoCrawlers;
var bool AlbinoCrawlersBool;

// same value sense as for AlbinoCrawlers, but for alpha clots
var config string AlbinoAlphas;
var bool AlbinoAlphasBool;

// same value sense as for AlbinoCrawlers, but for double bladed gorefasts
var config string AlbinoGorefasts;
var bool AlbinoGorefastsBool;

var config string ZedsTeleportCloser;
var bool ZedsTeleportCloserBool;

// true to log some internal state specific to this mod
var config bool bLogControlledDifficulty;

// "ini": read info about squads from config and use it to set spawn squads
// "unmodded": unmodded game behavior
// all other values are reserved for potential future preset names
var config string SpawnCycle;
var config array<string> SpawnCycleDefs;
var array<CD_AIWaveInfo> ActiveWaveInfos;

// "hans" or "volter": forces the hans boss wave
// "pat", "patty", "patriarch": forces the patriarch boss wave
// else: choose a random boss wave (unmodded game behavior)
var config string Boss;
var EBossChoice BossEnum;

// Time, in seconds, that dropped weapons remain on the ground before
// disappearing.  This must be either a valid integer in string form,
// or the string "max".
// If set to a negative value, then the game's builtin
// default value is not modified.  At the time I wrote this comment,
// the game's default was 300 seconds (5 minutes), but that could change;
// setting this to -1 will use whatever TWI chose as the default, even
// if they change the default in future patches.
// If set to a positive value, it overrides the TWI default.  All dropped
// weapons will remain on the ground for as many seconds as this variable's
// value, regardless of whether the weapon was dropped by a dying player
// or a live player who pressed his dropweapon key.
// If set to zero, CD behaves as though it had been set to 1.
// If set to "max", the value 2^31 - 1 is used.
var config string WeaponTimeout;
var int WeaponTimeoutInt;

// Defines users always allowed to run any chat command
var config array<StructAuthorizedUsers> AuthorizedUsers;

// Defines chat command privileges for users who are not
// defined in AuthorizedUsers (i.e. the general public)
var config CDAuthLevel DefaultAuthLevel;

////////////////////////////////////////////////////////////////
// Internal runtime state (no config options below this line) //
////////////////////////////////////////////////////////////////

var CD_ProgrammableSetting BossFPSetting;
var CD_ProgrammableSetting CohortSizeSetting;
var CD_ProgrammableSetting FakePlayersSetting;
var CD_ProgrammableSetting FleshpoundFPSetting;
var CD_ProgrammableSetting MaxMonstersSetting;
var CD_ProgrammableSetting MinSpawnIntervalSetting;
var CD_ProgrammableSetting ScrakeFPSetting;
var CD_ProgrammableSetting SpawnModSetting;
var CD_ProgrammableSetting TrashFPSetting;
var CD_ProgrammableSetting ZTSpawnSlowdownSetting;

var array<CD_ProgrammableSetting> DynamicSettings;


var CD_BasicSetting AlbinoAlphasSetting;
var CD_BasicSetting AlbinoCrawlersSetting;
var CD_BasicSetting AlbinoGorefastsSetting;
var CD_BasicSetting AlphaGlitterSetting;
var CD_BasicSetting BossSetting;
var CD_BasicSetting FakePlayersModeSetting;
var CD_BasicSetting SpawnCycleSetting;
var CD_BasicSetting TraderTimeSetting;
var CD_BasicSetting WeaponTimeoutSetting;
var CD_BasicSetting ZedsTeleportCloserSetting;
var CD_BasicSetting ZTSpawnModeSetting;

var array<CD_BasicSetting> BasicSettings;


var array<CD_Setting> AllSettings;

// SpawnCycle parsed out of the SpawnCycleDefs strings
var array<CD_AIWaveInfo> IniWaveInfos;

// Whether SpawnCycleDefs has been parsed into IniWaveInfos
var bool AlreadyLoadedIniWaveInfos;

// Reference to CD_DifficultyInfo
var CD_DifficultyInfo CustomDifficultyInfo;

// Console/log text output facility
var CD_ConsolePrinter GameInfo_CDCP;

// Authoritative list of known SpawnCycle presets
var CD_SpawnCycleCatalog SpawnCycleCatalog;

// Differences in SpawnMod which are less than this
// value will be considered neglible and ignored, for
// the purpose of display, comparison, and setting mutation
// This is effectively the maximum precision of SpawnMod
var const float SpawnModEpsilon;

var const float MinSpawnIntervalEpsilon;

var const float ZTSpawnSlowdownEpsilon;

// Holds KFGRI state when the countdown to close the
// trader has been temporarily suspended by the user.
var int PausedRemainingTime;
var int PausedRemainingMinute;

var CD_ChatCommander ChatCommander;

var int DebugExtraProgramPlayers;

var string DynamicSettingsBulletin;

delegate int ClampIntCDOption( const out int raw );
delegate float ClampFloatCDOption( const out float raw );

delegate bool StringReferencePredicate( const out string value );

event InitGame( string Options, out string ErrorMessage )
{
 	Super.InitGame( Options, ErrorMessage );

	SpawnCycleCatalog = new class'CD_SpawnCycleCatalog';
	SpawnCycleCatalog.Initialize( AIClassList, GameInfo_CDCP, bLogControlledDifficulty );

	// Print CD's commit hash (version)
	GameInfo_CDCP.Print( "Version " $ `CD_COMMIT_HASH $ " (" $ `CD_AUTHOR_TIMESTAMP $ ") loaded" );

	SetupBasicSettings();
	SetupProgrammableSettings();
	SortAllSettingsByName();

	ParseCDGameOptions( Options );

	ChatCommander = new(self) class'CD_ChatCommander';
	ChatCommander.SetupChatCommands();

	SaveConfig();
}

private function SortAllSettingsByName()
{
	AllSettings.sort(SettingNameComparator);
}

// DO NOT mark the parameters "const out"!  The compiler will accept
// both modifiers without so much as a warning, but the entire engine
// will crash to bugsplat when attempting to call this via a dynamic
// array's sort(<comparator>) function.  Unrealscript should not 
// generally be able to crash the entire engine in the first place,
// so I'm guessing this is an engine, bytecode interpreter, or compiler
// bug (so it's conceivable, though unlikely, that it could get fixed).
private function int SettingNameComparator( CD_Setting a, CD_Setting b )
{
	local string an, bn;

	an = a.GetOptionName();
	bn = b.GetOptionName();

	if ( an < bn )
	{
		return 1;
	}
	else if ( an > bn )
	{
		return -1;
	}
	return 0;
}


private function SetupBasicSettings()
{
	AlbinoAlphasSetting = new(self) class'CD_BasicSetting_AlbinoAlphas';
	RegisterBasicSetting( AlbinoAlphasSetting );

	AlbinoCrawlersSetting = new(self) class'CD_BasicSetting_AlbinoCrawlers';
	RegisterBasicSetting( AlbinoCrawlersSetting );

	AlbinoGorefastsSetting = new(self) class'CD_BasicSetting_AlbinoGorefasts';
	RegisterBasicSetting( AlbinoGorefastsSetting );

	AlphaGlitterSetting = new(self) class'CD_BasicSetting_AlphaGlitter';
	RegisterBasicSetting( AlphaGlitterSetting );

	BossSetting = new(self) class'CD_BasicSetting_Boss';
	RegisterBasicSetting( BossSetting );

	FakePlayersModeSetting = new(self) class'CD_BasicSetting_FakePlayersMode';
	RegisterBasicSetting( FakePlayersModeSetting );

	SpawnCycleSetting = new(self) class'CD_BasicSetting_SpawnCycle';
	RegisterBasicSetting( SpawnCycleSetting );

	TraderTimeSetting = new(self) class'CD_BasicSetting_TraderTime';
	RegisterBasicSetting( TraderTimeSetting );

	WeaponTimeoutSetting = new(self) class'CD_BasicSetting_WeaponTimeout';
	RegisterBasicSetting( WeaponTimeoutSetting );

	ZedsTeleportCloserSetting = new(self) class'CD_BasicSetting_ZedsTeleportCloser';
	RegisterBasicSetting( ZedsTeleportCloserSetting );

	ZTSpawnModeSetting = new(self) class'CD_BasicSetting_ZTSpawnMode';
	RegisterBasicSetting( ZTSpawnModeSetting );
}

private function RegisterBasicSetting( const out CD_BasicSetting BasicSetting )
{
	BasicSettings.AddItem( BasicSetting );
	AllSettings.AddItem( BasicSetting );
}

private function RegisterDynamicSetting( const out CD_ProgrammableSetting DynamicSetting )
{
	DynamicSettings.AddItem( DynamicSetting );
	AllSettings.AddItem( DynamicSetting );
}

private function SetupProgrammableSettings()
{
	BossFPSetting = new(self) class'CD_ProgrammableSetting_BossFP';
	BossFPSetting.IniDefsArray = BossFPDefs;
	RegisterDynamicSetting( BossFPSetting );

	CohortSizeSetting = new(self) class'CD_ProgrammableSetting_CohortSize';
	CohortSizeSetting.IniDefsArray = CohortSizeDefs;
	RegisterDynamicSetting( CohortSizeSetting );

	FakePlayersSetting = new(self) class'CD_ProgrammableSetting_FakePlayers';
	FakePlayersSetting.IniDefsArray = FakePlayersDefs;
	RegisterDynamicSetting( FakePlayersSetting );

	MaxMonstersSetting = new(self) class'CD_ProgrammableSetting_MaxMonsters';
	MaxMonstersSetting.IniDefsArray = MaxMonstersDefs;
	RegisterDynamicSetting( MaxMonstersSetting );

	SpawnModSetting = new(self) class'CD_ProgrammableSetting_SpawnMod';
	SpawnModSetting.IniDefsArray = SpawnModDefs;
	RegisterDynamicSetting( SpawnModSetting );

	MinSpawnIntervalSetting = new(self) class'CD_ProgrammableSetting_MinSpawnInterval';
	MinSpawnIntervalSetting.IniDefsArray = MinSpawnIntervalDefs;
	RegisterDynamicSetting( MinSpawnIntervalSetting );

	ScrakeFPSetting = new(self) class'CD_ProgrammableSetting_ScrakeFP';
	ScrakeFPSetting.IniDefsArray = ScrakeFPDefs;
	RegisterDynamicSetting( ScrakeFPSetting );

	FleshpoundFPSetting = new(self) class'CD_ProgrammableSetting_FleshpoundFP';
	FleshpoundFPSetting.IniDefsArray = FleshpoundFPDefs;
	RegisterDynamicSetting( FleshpoundFPSetting );

	TrashFPSetting = new(self) class'CD_ProgrammableSetting_TrashFP';
	TrashFPSetting.IniDefsArray = TrashFPDefs;
	RegisterDynamicSetting( TrashFPSetting );

	ZTSpawnSlowdownSetting = new(self) class'CD_ProgrammableSetting_ZTSpawnSlowdown';
	ZTSpawnSlowdownSetting.IniDefsArray = ZTSpawnSlowdownDefs;
	RegisterDynamicSetting( ZTSpawnSlowdownSetting );
}

function bool CheckRelevance(Actor Other)
{
	local KFDroppedPickup Weap;
	local KFAIController KFAIC;
	local KFPawn_ZedClot_Alpha Alpha;
	local bool SuperRelevant;

	SuperRelevant = super.CheckRelevance(Other);

	if ( !SuperRelevant )
	{
		// Early return if this is going to be destroyed anyway
		return SuperRelevant;
	}

	Weap = KFDroppedPickup(Other);

	if ( None != Weap )
	{
		OverrideWeaponLifespan(Weap);
		// nothing else to do on weapons, can return early
		return SuperRelevant;
	}

	KFAIC = KFAIController(Other);

	if ( None != KFAIC )
	{
		KFAIC.bCanTeleportCloser = ZedsTeleportCloserBool;
		`cdlog("Set bCanTeleportCloser="$ ZedsTeleportCloserBool $" on "$ KFAIC, bLogControlledDifficulty);
		// might have more checks on zeds, can't return yet
	}

	if ( !AlphaGlitterBool )
	{
		Alpha = KFPawn_ZedClot_Alpha(Other);
		if ( None != Alpha )
		{
			Alpha.SpecialMoveHandler.SpecialMoveClasses[SM_Rally] =
				class'CD_AlphaRally_NoGlitter';
			`cdlog( "Disabled glitter on alpha "$ Alpha, bLogControlledDifficulty );
		}
	}

	// Should always be true, due to the early return when false
	// (We don't actually determine relevance here, it's just the best touch-point
	//  to modify actor properties during creation)
	return SuperRelevant;
}

private function OverrideWeaponLifespan(KFDroppedPickup Weap)
{
	if ( 0 < WeaponTimeoutInt )
	{
		Weap.Lifespan = WeaponTimeoutInt;
	}
	else if ( 0 == WeaponTimeoutInt )
	{
		Weap.Lifespan = 1;
	}

	// If negative, do nothing (TWI's standard lifespan prevails)
}

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
	GameSpeed = FMax(T, 0.00001);
	WorldInfo.TimeDilation = GameSpeed;
	SetTimer(WorldInfo.TimeDilation, true);
	if ( ZTSpawnModeEnum == ZTSM_CLOCKWORK )
	{
		// Tweak the dilation (but do not reset)
		TuneSpawnManagerTimer();
	}
	else
	{
		// Restart the timer (but do not tweak the dilation)
		SetSpawnManagerTimer();
	}
}

function SetSpawnManagerTimer( const optional bool ForceReset = true )
{
	if ( ForceReset || !IsTimerActive('SpawnManagerWakeup') )
	{
		// Timer does not exist, set it
		`cdlog("Setting independent SpawnManagerWakeup timer (" $ MinSpawnIntervalFloat $")");
		SetTimer(MinSpawnIntervalFloat, true, 'SpawnManagerWakeup');
	}
}

function TuneSpawnManagerTimer()
{
	local float LocalDilation;
	local float SlowDivisor;

	LocalDilation = 1.f / WorldInfo.TimeDilation;
	if ( ZedTimeRemaining > 0.f && ZTSpawnSlowdownFloat > 1.f )
	{
		if ( ZedTimeRemaining < ZedTimeBlendOutTime )
		{
			// if zed time is running out, interpolate between [1.0, ZTSS] using the same lerp-alpha-factor that TickZedTime uses
			// When zed time first starts to fade, we will use a divisor slightly less than ZTSS
			// When zed time is on the last tick before it is completly over, we will use slightly more than 1.0
			// See TickZedTime in KFGameInfo for background
			SlowDivisor = Lerp(1.0, ZTSpawnSlowdownFloat, ZedTimeRemaining / ZedTimeBlendOutTime);
		}
		else
		{
			// if zed time is going strong, just use ZTSS
			SlowDivisor = ZTSpawnSlowdownFloat;
		}

		LocalDilation = LocalDilation / SlowDivisor;

		`cdlog("SpawnManagerWakeup's slowed clockwork timedilation: " $ LocalDilation $ " (ZTSS=" $ SlowDivisor $ ")");
	}
	else
	{
		`cdlog("SpawnManagerWakeup's realtime clockwork timedilation: " $ LocalDilation);
	}

	ModifyTimerTimeDilation('SpawnManagerWakeup', LocalDilation);
}

/** Default timer, called from native */
event Timer()
{
	super(KFGameInfo).Timer();

	if ( GameConductor != none )
	{
		GameConductor.TimerUpdate();
	}
}

private function SpawnManagerWakeup()
{
	if ( SpawnManager != none )
	{
		SpawnManager.Update();
	}
}

private function ParseCDGameOptions( const out string Options )
{
	local int i;

	for ( i = 0; i < AllSettings.Length; i++ )
	{
		AllSettings[i].InitFromOptions( Options );
	}
}

protected function SetZTSpawnModeEnum()
{
}

private function DisplayBriefWaveStatsInChat()
{
	local string s;

	s = CD_SpawnManager( SpawnManager ).GetWaveAverageSpawnrate();

	BroadcastCDEcho( "[CD - Wave " $ WaveNum $ " Recap]\n"$ s );
}

State TraderOpen
{
	function BeginState( Name PreviousStateName )
	{
		super.BeginState( PreviousStateName );

		CD_SpawnManager( SpawnManager ).WaveEnded();
		SetTimer(2.f, false, 'DisplayBriefWaveStatsInChat');
	}
}

function EndOfMatch(bool bVictory)
{
	super.EndOfMatch(bVictory);

	if ( !bVictory && WaveNum < WaveMax )
	{
		CD_SpawnManager( SpawnManager ).WaveEnded();
		SetTimer(2.f, false, 'DisplayBriefWaveStatsInChat');
	}
}

private function string PauseTraderTime()
{
	local name GameStateName;

	// Only process these commands in trader time
	GameStateName = GetStateName();
	if ( GameStateName != 'TraderOpen' )
	{
		return "Trader not open";
	}

	if ( MyKFGRI.bStopCountDown )
	{
		return "Trader already paused";
	}

	if ( WorldInfo.NetMode != NM_StandAlone && MyKFGRI.RemainingTime <= 5 )
	{
		return "Pausing requires at least 5 seconds remaining";
	}

	MyKFGRI.bStopCountDown = !MyKFGRI.bStopCountDown;

	PausedRemainingTime = MyKFGRI.RemainingTime;
	PausedRemainingMinute = MyKFGRI.RemainingMinute;
	ClearTimer( 'CloseTraderTimer' );
	`cdlog("Killed CloseTraderTimer", bLogControlledDifficulty);

	`cdlog("MyKFGRI.RemainingTime: "$ MyKFGRI.RemainingTime, bLogControlledDifficulty);
	`cdlog("MyKFGRI.RemainingMinute: "$ MyKFGRI.RemainingMinute, bLogControlledDifficulty);
	`cdlog("MyKFGRI.bStopCountDown: "$ MyKFGRI.bStopCountDown, bLogControlledDifficulty);

	return "Paused Trader";
}

private function string UnpauseTraderTime()
{
	local name GameStateName;

	// Only process these commands in trader time
	GameStateName = GetStateName();
	if ( GameStateName != 'TraderOpen' )
	{
		return "Trader not open";
	}

	if ( !MyKFGRI.bStopCountDown )
	{
		return "Trader not paused";
	}

	MyKFGRI.bStopCountDown = !MyKFGRI.bStopCountDown;

	MyKFGRI.RemainingTime = PausedRemainingTime;
	MyKFGRI.RemainingMinute = PausedRemainingMinute;
	SetTimer( MyKFGRI.RemainingTime, False, 'CloseTraderTimer' );
	`cdlog("Installed CloseTraderTimer at "$ MyKFGRI.RemainingTime $" (non-recurring)", bLogControlledDifficulty);

	`cdlog("MyKFGRI.RemainingTime: "$ MyKFGRI.RemainingTime, bLogControlledDifficulty);
	`cdlog("MyKFGRI.RemainingMinute: "$ MyKFGRI.RemainingMinute, bLogControlledDifficulty);
	`cdlog("MyKFGRI.bStopCountDown: "$ MyKFGRI.bStopCountDown, bLogControlledDifficulty);

	return "Unpaused Trader";
}

/* 
 * We override PreLogin to disable a comically overzealous
 * GameMode integrity check added in v1046 or v1048 (not
 * sure exactly which, but it appeared after v1043 for sure).
 * Basically, TWI added a GameMode whitelist check that executes
 * every time a client quick joins, uses the server browser, or
 * just stays connected to a server through a map change.
 */
event PreLogin(string Options, string Address, const UniqueNetId UniqueId, bool bSupportsAuth, out string ErrorMessage)
{
	local bool bSpectator;
	local bool bPerfTesting;
//	local string DesiredDifficulty, DesiredWaveLength, DesiredGameMode;

	// Check for an arbitrated match in progress and kick if needed
	if (WorldInfo.NetMode != NM_Standalone && bUsingArbitration && bHasArbitratedHandshakeBegun)
	{
		ErrorMessage = PathName(WorldInfo.Game.GameMessageClass) $ ".ArbitrationMessage";
		return;
	}

	// If this player is banned, reject him
	if (AccessControl != none && AccessControl.IsIDBanned(UniqueId))
	{
		`log(Address@"is banned, rejecting...");
		ErrorMessage = "<Strings:KFGame.KFLocalMessage.BannedFromServerString>";
		return;
	}

//	// Check against what is expected from the client in the case of quick join/server browser. The server settings can change from the time the server gets the properties from the backend
//	if( WorldInfo.NetMode == NM_DedicatedServer && !HasOption( Options, "bJoinViaInvite" ) )
//	{
//		DesiredDifficulty = ParseOption( Options, "Difficulty" );
//		if( DesiredDifficulty != "" && int(DesiredDifficulty) != GameDifficulty )
//		{
//			`log("Got bad difficulty"@DesiredDifficulty@"expected"@GameDifficulty);
//			ErrorMessage = "<Strings:KFGame.KFLocalMessage.ServerNoLongerAvailableString>";
//			return;
//		}
//
//		DesiredWaveLength = ParseOption( Options, "GameLength" );
//		if( DesiredWaveLength != "" && int(DesiredWaveLength) != GameLength )
//		{
//			`log("Got bad wave length"@DesiredWaveLength@"expected"@GameLength);
//			ErrorMessage = "<Strings:KFGame.KFLocalMessage.ServerNoLongerAvailableString>";
//			return;
//		}
//
//		DesiredGameMode = ParseOption( Options, "Game" );
//		if( DesiredGameMode != "" && !(DesiredGameMode ~= GetFullGameModePath()) )
//		{
//			`log("Got bad wave length"@DesiredGameMode@"expected"@GetFullGameModePath());
//			ErrorMessage = "<Strings:KFGame.KFLocalMessage.ServerNoLongerAvailableString>";
//			return;
//		}
//	}


	bPerfTesting = ( ParseOption( Options, "AutomatedPerfTesting" ) ~= "1" );
	bSpectator = bPerfTesting || ( ParseOption( Options, "SpectatorOnly" ) ~= "1" ) || ( ParseOption( Options, "CauseEvent" ) ~= "FlyThrough" );

	if (AccessControl != None)
	{
		AccessControl.PreLogin(Options, Address, UniqueId, bSupportsAuth, ErrorMessage, bSpectator);
	}
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
				killerPawnClass = class'CD_ZedNameUtils'.static.CheckClassRemap( Killer.Pawn.Class, "CD_Survival.BroadcastDeathMessage", bLogControlledDifficulty );
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
 * Call super first, then check that the game conductor really
 * is lobotomized.  If the game conductor has not been deactivated,
 * print a scary warning.
 */
function InitGameConductor()
{
	super.InitGameConductor();

	`cdlog("FakePlayers in InitGameConductor(): "$ FakePlayers, bLogControlledDifficulty);

	if ( GameConductor.isA( 'CD_DummyGameConductor' ) )
	{
		`cdlog("Checked that GameConductor "$GameConductor$" is an instance of CD_DummyGameConductor (OK)", bLogControlledDifficulty);
	}
	else
	{
		GameInfo_CDCP.Print("WARNING: GameConductor "$GameConductor$" appears to be misconfigured! CD might not work correctly.");
	}
}

/*
 * Sanity check on DifficultyInfo.
 */
function CreateDifficultyInfo(string Options)
{
	super.CreateDifficultyInfo(Options);

	// the preceding call should have initialized DifficultyInfo
	CustomDifficultyInfo = CD_DifficultyInfo(DifficultyInfo);

	// log that we're done with the DI (note that CD_DifficultyInfo logs param values in its setters)
	`cdlog("CD_DifficultyInfo ready: " $ CustomDifficultyInfo, bLogControlledDifficulty);
}

/*
 * We override this function to apply FakePlayers modifier
 * to dosh rewards for killing zeds.
 */
function ModifyAIDoshValueForPlayerCount( out float ModifiedValue )
{
	local float DoshMod;
	local int LocalNumPlayers;
	local float LocalMaxAIMod;

	LocalNumPlayers = GetNumPlayers();
	// Only pass actual players to GetPlayerNumMaxAIModifier -- it adds fakes internally
	LocalMaxAIMod = DifficultyInfo.GetPlayerNumMaxAIModifier(LocalNumPlayers);

	if ( FakePlayersModeEnum == FPM_ADD )
	{
		DoshMod = (LocalNumPlayers + FakePlayersInt) / LocalMaxAIMod;
	}
	else
	{
		DoshMod = FakePlayersInt / LocalMaxAIMod;
	}

	ModifiedValue *= DoshMod;

	`cdlog("DoshCalc: ModifiedValue="$ ModifiedValue $" FakePlayers="$ FakePlayersInt $
	       " RealPlayers="$ LocalNumPlayers $" computed MaxAIDoshDenominator="$ LocalMaxAIMod, bLogControlledDifficulty);
}

/*
 * Configure CD_SpawnManager (particularly MaxMonsters and SpawnCycle)
 */ 
function InitSpawnManager()
{
	local CD_SpawnManager cdsm;

	super.InitSpawnManager();

	if ( SpawnManager.IsA( 'CD_SpawnManager' ) )
	{
		`cdlog("Checked that SpawnManager "$SpawnManager$" is an instance of CD_SpawnManager (OK)", bLogControlledDifficulty);
		cdsm = CD_SpawnManager( SpawnManager );
	}
	else
	{
		GameInfo_CDCP.Print("WARNING: SpawnManager "$SpawnManager$" appears to be misconfigured! CD might not work correctly.");
		return;
	}

	cdsm.SetCustomWaves( ActiveWaveInfos );
}

protected function LoadSpawnCycle( const out string OverrideSpawnCycle, out array<CD_AIWaveInfo> OutWaveInfos )
{
	// Assign a spawn definition array to CycleDefs (unless SpawnCycle=unmodded)
	if ( OverrideSpawnCycle == "ini" )
	{
		MaybeLoadIniWaveInfos();

		OutWaveInfos = IniWaveInfos;
	}
	else if ( OverrideSpawnCycle == "unmodded" )
	{
		`cdlog("LoadSpawnCycle: found "$OverrideSpawnCycle$", treating as noop", bLogControlledDifficulty);
		OutWaveInfos.Length = 0;
	}
	else
	{
		if ( !SpawnCycleCatalog.ParseSquadCyclePreset( OverrideSpawnCycle, GameLength, OutWaveInfos ) )
		{
			OutWaveInfos.Length = 0;
		}
	}
}

event Broadcast(Actor Sender, coerce string Msg, optional name Type)
{
	super.Broadcast(Sender, Msg, Type);

	if ( Type == 'Say' )
	{
		ChatCommander.RunCDChatCommandIfAuthorized( Sender, Msg );
	}
}

function BroadcastCDEcho( coerce string Msg )
{
        local PlayerController P;

	// Skip the AllowsBroadcast check
        
        foreach WorldInfo.AllControllers(class'PlayerController', P)
        {
                BroadcastHandler.BroadcastText( None, P, Msg, 'CDEcho' );
        }
}

function WaveEnded( EWaveEndCondition WinCondition )
{
	local string CDSettingChangeMessage;

	super.WaveEnded( WinCondition );

	if ( ApplyStagedConfig( CDSettingChangeMessage, "Staged settings applied:" ) )
	{
		BroadcastCDEcho( CDSettingChangeMessage );
	}
}


private function ProgramSettingsForNextWave()
{
	local int i, NWN;
	local string s;
	local bool DynamicSettingsBulletinStarted;

	NWN = WaveNum + 1;
	DynamicSettingsBulletinStarted = false;
	DynamicSettingsBulletin = "";

	for ( i = 0; i < DynamicSettings.Length; i++ )
	{
		s = DynamicSettings[i].RegulateValue( NWN );
		if ( s != "" )
		{
			if ( DynamicSettingsBulletinStarted )
			{
				DynamicSettingsBulletin $= "\n";
			}
			DynamicSettingsBulletin $= s;
			DynamicSettingsBulletinStarted = true;
		}
	}
}

function StartWave()
{
	local string CDSettingChangeMessage;

	if ( ApplyStagedConfig( CDSettingChangeMessage, "Staged settings applied:" ) )
	{
		BroadcastCDEcho( CDSettingChangeMessage );
	}

	ProgramSettingsForNextWave();

	// Restart the SpawnManager's wakeup timer.
	// This synchronizing effect is virtually unnoticeable when MinSpawnInterval is
	// low (say 1s), but very noticable when it is long (say 30s)
	SetSpawnManagerTimer();
	SetGameSpeed( WorldInfo.TimeDilation );
	
	super.StartWave();

	// If this is the first wave, print CD's settings
	if ( 1 == WaveNum )
	{
		SetTimer( 2.0f, false, 'DisplayWaveStartMessageInChat' );
	}
	else // If this is a noninitial wave and there are dynamic settings, then print their values
	{
		//SetTimer( 0.5f, false, 'DisplayDynamicSettingSummaryInChat' );
		DisplayDynamicSettingSummaryInChat();
	}
}

private function DisplayWaveStartMessageInChat()
{
	BroadcastCDEcho( "[Controlled Difficulty Active]\n" $ ChatCommander.GetCDInfoChatString( "brief" ) );
}

private function DisplayDynamicSettingSummaryInChat()
{
	if ( DynamicSettingsBulletin != "" )
	{
		BroadcastCDEcho( "[CD - Dynamic Settings]\n" $ DynamicSettingsBulletin );
	}
}

protected function bool ApplyStagedConfig( out string MessageToClients, const string BannerLine )
{
	local array<string> SettingChangeNotifications;
	local string TempString;
	local int i, PendingWaveNum;

	PendingWaveNum = WaveNum + 1;

	for ( i = 0; i < AllSettings.Length; i++ )
	{
		TempString = AllSettings[i].CommitStagedChanges( PendingWaveNum );

		if ( TempString != "" )
		{
			SettingChangeNotifications.AddItem( TempString );
		}
	}

	if ( 0 < SettingChangeNotifications.Length )
	{
		if ( "" != BannerLine )
		{
			SettingChangeNotifications.InsertItem( 0, BannerLine );
		}

		JoinArray(SettingChangeNotifications, MessageToClients, "\n");

		SaveConfig();

		return true;
	}

	return false;
}

function bool EpsilonClose( const float a, const float b, const float epsilon )
{
	return a == b || (a < b && b < (a + epsilon)) || (b < a && a < (b + epsilon));
}

function CDAuthLevel GetAuthorizationLevelForUser( Actor Sender )
{
	local KFPlayerReplicationInfo KFPRI;
	local KFPlayerController SubjectPC;
	local string SteamIdHexString;
	local int SteamIdAccountNumber;
	local string SteamIdSuffix;
	local int i;
	local int SteamIdSuffixLength;

	// NM_StandAlone bypasses authorization.  Multiuser authorization would not be meaningful in solo.
	if ( WorldInfo.NetMode == NM_StandAlone )
	{
		return CDAUTH_WRITE;
	}

	SubjectPC = KFPlayerController( Sender );

	if ( None == SubjectPC )
	{
		`cdlog("Actor "$ Sender $" does not appear to be a KFPlayerController.", bLogControlledDifficulty);
		return DefaultAuthLevel;
	}

	KFPRI = KFPlayerReplicationInfo( SubjectPC.PlayerReplicationInfo );

	if ( None == KFPRI )
	{
		`cdlog("Subject player controller "$ SubjectPC $" does not have replication info.", bLogControlledDifficulty);
		return DefaultAuthLevel;
	}

	SteamIdHexString = OnlineSub.UniqueNetIdToString(KFPRI.UniqueId); 

	`cdlog("Beginning authorization check for UniqueId=" $ SteamIdHexString $ " (current nickname: "$ KFPRI.PlayerName $")", bLogControlledDifficulty);

	class'CD_StringUtils'.static.HexStringToInt( Right( SteamIdHexString, 8 ), SteamIdAccountNumber );

	if ( -1 == SteamIdAccountNumber )
	{
		`cdlog("Parsing UniqueId=" $ SteamIdHexString $ " as hex failed; not a STEAMID? (current nickname: "$ KFPRI.PlayerName $")", bLogControlledDifficulty);
		return DefaultAuthLevel;
	}

	`cdlog("Unpacked int32 steam account number: " $ SteamIdAccountNumber $ " (current nickname: "$ KFPRI.PlayerName $")", bLogControlledDifficulty); 

	SteamIdSuffix = ":" $ string(SteamIdAccountNumber % 2) $ ":" $ string(SteamIdAccountNumber / 2);
	SteamIdSuffixLength = Len( SteamIdSuffix );

	`cdlog("Formatted account number as STEAMID2-style string: "$ SteamIdSuffix $ " (current nickname: "$ KFPRI.PlayerName $")", bLogControlledDifficulty); 

	for ( i = 0; i < AuthorizedUsers.Length; i++ )
	{
		if ( Len( AuthorizedUsers[i].SteamID ) < SteamIdSuffixLength )
		{
			continue;
		}

		if ( Right( AuthorizedUsers[i].SteamID, SteamIdSuffixLength ) == SteamIdSuffix )
		{
			`cdlog("Found STEAMID2 auth match for " $
			AuthorizedUsers[i].SteamID $ "; granting CDAUTH_WRITE (current nickname: " $ KFPRI.PlayerName $
			", auth comment: " $ AuthorizedUsers[i].Comment $ ")", bLogControlledDifficulty);

			return CDAUTH_WRITE;
		}
	}

	`cdlog("No STEAMID2 auth match found for current user (current nickname: " $ KFPRI.PlayerName $ ")", bLogControlledDifficulty);

	return DefaultAuthLevel;
}

private function MaybeLoadIniWaveInfos()
{
	if ( !AlreadyLoadedIniWaveInfos )
	{
		AlreadyLoadedIniWaveInfos = true;

		// This doesn't seem to work (am I forcing a SaveConfig() beforehand?)
		//`cdlog("Forcing a config reload because SpawnCycle="$SpawnCycle$"...", bLogControlledDifficulty);
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
	if ( SpawnCycleCatalog != None )
	{
		SpawnCycleCatalog.SetLogging( enabled );
	}
	`cdlog("Set bLogControlledDifficulty = "$bLogControlledDifficulty, true);
	SaveConfig();
}

exec function CDChatHelp()
{
	ChatCommander.PrintCDChatHelp();
}

exec function CDSpawnSummaries( optional string CycleName, optional int AssumedPlayerCount = -255 )
{
	local array<CD_AIWaveInfo> WaveInfosToSummarize;
	local DifficultyWaveInfo DWS;
	local class<CD_SpawnManager> cdsmClass;
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
			AssumedPlayerCount = 1 + FakePlayersInt; // TODO is FakePlayersInt still right?
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

	cdsmClass = class<CD_SpawnManager>( SpawnManagerClasses[GameLength] );
	// No need to instantiate; we just want to check its default 
        // values for about Wave MaxAI 
	DWS = cdsmClass.default.DifficultyWaveSettings[ Min(GameDifficulty, cdsmClass.default.DifficultyWaveSettings.Length-1) ];

	class'CD_WaveInfoUtils'.static.PrintSpawnSummaries( WaveInfosToSummarize, AssumedPlayerCount,
		GameInfo_CDCP, GameLength, CustomDifficultyInfo, DWS );

	CDConsolePrintLogfileHint();
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

		CDConsolePrintLogfileHint();
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

		CDConsolePrintLogfileHint();
	}
	else if ( wis == WIS_SPAWNCYCLE_NOT_MODDED )
	{
		CDPrintSpawnDetailsHelp();
	}
}

private function CDConsolePrintLogfileHint()
{
	GameInfo_CDCP.Print(" Need to copy-paste?  CD copies all console output to KF2's logfile, generally:", false);
	GameInfo_CDCP.Print("  <HOME>\\Documents\\My Games\\KillingFloor2\\KFGame\\Logs\\Launch.log", false);
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

	CDConsolePrintLogfileHint();
}

exec function DebugCD_ExtraProgramPlayers( optional int i )
{
	if ( i == -2147483648 )
	{
		GameInfo_CDCP.Print("DebugExtraProgramPlayers="$DebugExtraProgramPlayers);
	}
	else
	{
		DebugExtraProgramPlayers = i;
		SaveConfig();
		GameInfo_CDCP.Print("Set DebugExtraProgramPlayers="$DebugExtraProgramPlayers);
	}
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

defaultproperties
{
	GameConductorClass=class'ControlledDifficulty.CD_DummyGameConductor'

	DifficultyInfoClass=class'ControlledDifficulty.CD_DifficultyInfo'

	SpawnManagerClasses(0)=class'ControlledDifficulty.CD_SpawnManager_Short'
	SpawnManagerClasses(1)=class'ControlledDifficulty.CD_SpawnManager_Normal'
	SpawnManagerClasses(2)=class'ControlledDifficulty.CD_SpawnManager_Long'

	PlayerControllerClass=class'ControlledDifficulty.CD_PlayerController'

	Begin Object Class=CD_ConsolePrinter Name=Default_CDCP
	End Object

	GameInfo_CDCP=Default_CDCP

	SpawnModEpsilon=0.0001
	MinSpawnIntervalEpsilon=0.0001
	ZTSpawnSlowdownEpsilon=0.0001
}
