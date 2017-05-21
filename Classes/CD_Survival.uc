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

enum CDAuthLevel
{
	CDAUTH_READ,
	CDAUTH_WRITE
};

enum EZTSpawnMode
{
	ZTSM_UNMODDED,
	ZTSM_CLOCKWORK
};


struct StructStagedConfig
{
	var bool     AlbinoAlphas;
	var bool     AlbinoCrawlers;
	var bool     AlbinoGorefasts;
	var string   Boss;
	var int      CohortSize;
	var int      FakePlayers;
	var int      MaxMonsters;
	var float    MinSpawnIntervalFloat;
	var string   SpawnCycle;
	var float    SpawnModFloat;
//	var int      TraderTime;
	var string   WeaponTimeout;
	var float    ZTSpawnSlowdownFloat;
	var string   ZTSpawnMode;
};

struct StructAuthorizedUsers
{
	var string SteamID;
	var string Comment;
};

struct StructChatCommand
{
	var array<string> Names; 
	var array<string> ParamHints; 
	var delegate<ChatCommandNullaryImpl> NullaryImpl;
	var delegate<ChatCommandParamsImpl> ParamsImpl;
	var string Description;
	var CDAuthLevel AuthLevel;
	var bool ModifiesConfig;
};

////////////////////
// Config options //
////////////////////

// increase zed count (but not hp) as though this many additional players were
// present; note that the game normally increases dosh rewards for each zed at
// numplayers >= 3, and faking players this way does the same; you can always
// refrain from buying if you want an extra challenge, but if the mod denied
// you that bonus dosh, it could end up being gamebreaking for some runs
var config int FakePlayers; 

// the trader time, in seconds.  if this is zero or negative, its value is
// totally ignored, and the difficulty's standard trader time is used instead.
var config int TraderTime;

// The timer interval, in seconds, for CD's SpawnManager's update function.
// The update function first checks several state variables to determine
// whether to attempt to spawn more zeds.  If it determines that it should
// spawn zeds, the function then starts placing squads on spawner and/or 
// spawnvolume entities.
// In the unmodded game, this is hardcoded to one second.
var config string MinSpawnInterval;
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
var config int CohortSize;

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

var config string ZTSpawnSlowdown;
var float ZTSpawnSlowdownFloat;

var config string ZTSpawnMode;
var EZTSpawnMode ZTSpawnModeEnum;
var const string ZTSpawnModeHelpString;
var const string ZTSpawnModeDefaultValue;

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

// same value sense as for AlbinoCrawlers, but for double bladed gorefasts
var config bool AlbinoGorefasts;

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
var const string BossOptionHelpString;
var const string BossOptionDefaultValue;

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

// Defines users always allowed to run any chat command
var config array<StructAuthorizedUsers> AuthorizedUsers;

// Defines chat command privileges for users who are not
// defined in AuthorizedUsers (i.e. the general public)
var config CDAuthLevel DefaultAuthLevel;

////////////////////////////////////////////////////////////////
// Internal runtime state (no config options below this line) //
////////////////////////////////////////////////////////////////

// SpawnCycle parsed out of the SpawnCycleDefs strings
var array<CD_AIWaveInfo> IniWaveInfos;

var array<StructChatCommand> ChatCommands;

// Whether SpawnCycleDefs has been parsed into IniWaveInfos
var bool AlreadyLoadedIniWaveInfos;

// Reference to CD_DifficultyInfo
var CD_DifficultyInfo CustomDifficultyInfo;

// Console/log text output facility
var CD_ConsolePrinter GameInfo_CDCP;

// Authoritative list of known SpawnCycle presets
var CD_SpawnCycleCatalog SpawnCycleCatalog;

// Configuration changes latched through chat commands.
// Chat commands always go through StagedConfig, but
// the StagedConfig is only copied to the live config
// if a wave is not currently in progress.  If a wave
// is in progress, the new values sit here in StagedConfig
// until the wave is over, at which time then CD copies
// the staged values to their live counterparts.
var StructStagedConfig StagedConfig;

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

delegate int ClampIntCDOption( const out int raw );
delegate float ClampFloatCDOption( const out float raw );

delegate bool StringReferencePredicate( const out string value );
delegate string ChatCommandNullaryImpl();
delegate string ChatCommandParamsImpl( const out array<string> params );

event InitGame( string Options, out string ErrorMessage )
{
 	Super.InitGame( Options, ErrorMessage );

	SpawnCycleCatalog = new class'CD_SpawnCycleCatalog';
	SpawnCycleCatalog.Initialize( AIClassList, GameInfo_CDCP, bLogControlledDifficulty );

	// Print CD's commit hash (version)
	GameInfo_CDCP.Print( "Version " $ `CD_COMMIT_HASH $ " (" $ `CD_AUTHOR_TIMESTAMP $ ") loaded" );

	ParseCDGameOptions( Options );

	SetupChatCommands();

	SaveConfig();

	InitStructStagedConfig();
}

function bool CheckRelevance(Actor Other)
{
	local KFDroppedPickup Weap;
	local KFAIController KFAIC;
	local bool SuperRelevant;
	local bool CanTeleportCloser; // TODO extract into proper config var
	CanTeleportCloser = false; // TODO same

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
	}

	if ( !CanTeleportCloser )
	{
		KFAIC = KFAIController(Other);
		if ( None != KFAIC )
		{
			KFAIC.bCanTeleportCloser = false;
			`log("Set bCanTeleportCloser=false on "$ KFAIC);
		}
	}

	// Should always be true, due to the early return when false
	return SuperRelevant;
}

private function OverrideWeaponLifespan(KFDroppedPickup Weap)
{
	local int seconds;

	seconds = GetWeaponTimeoutSeconds();

	if ( 0 < seconds )
	{
		Weap.Lifespan = seconds;
	}
	else if ( 0 == seconds )
	{
		Weap.Lifespan = 1;
	}
}

private function int GetWeaponTimeoutSeconds()
{
	if ( "max" == WeaponTimeout )
	{
		return 2147483647;
	}
	else
	{
		return int( WeaponTimeout );
	}
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
		SetSpawnManagerWakeup();
	}
}

function SetSpawnManagerWakeup()
{
	local float ZTTrans;
	local float LocalDilation;

	if ( !IsTimerActive('SpawnManagerWakeup') )
	{
		// Timer does not exist, set it
		`cdlog("Setting independent SpawnManagerWakeup timer (" $ MinSpawnIntervalFloat $")");
		SetTimer(MinSpawnIntervalFloat, true, 'SpawnManagerWakeup');
	}

	// Timer running by the time we reach this line; just modify the time dilation
	if ( ZTSpawnSlowdownFloat > 1.f && ZedTimeRemaining > 0.f && WorldInfo.TimeDilation <= 1.f )
	{
		// In standard KF2, time runs at ZedTimeSlomoScale during ZT
		// At the time this comment was written, ZedTimeSlomoScale=.2,
		// meaning 5 seconds of gametime pass for every 1 second of realtime.
		// If we applied this dilation directly to the spawnmanager, then
		// every kill in zedtime could add up to 4 "free" seconds without
		// spawn activity (circumstances for this to happen are pretty
		// special, but it is possible).
		// (1 - (1/ZTSS)) / stick = istick - istick/ZTSS
		// .8x = .7     x = .7 /.8
		// .4x = .35    x = .35/.4

		// .8x = .5     x = .5/.8
		// .4x = .25    x = .25/.4
		// 1x = 1
		ZTTrans = 1.25f - (1.25f / ZTSpawnSlowdownFloat);  // .8 = 1 - ZedTimeSlomoScale; 1.25 = 1/.8
		LocalDilation = 1.f - ((1.f - WorldInfo.TimeDilation) * ZTTrans);
		LocalDilation = FClamp(LocalDilation, 0.2f, 1.0f);
		`cdlog("SpawnManagerWakeup's scaled timedilation: " $ LocalDilation);
	}
	else
	{
		LocalDilation = 1.f / WorldInfo.TimeDilation;
		`cdlog("SpawnManagerWakeup's clockwork timedilation: " $ LocalDilation);
	}

	ModifyTimerTimeDilation('SpawnManagerWakeup', LocalDilation);
}

/** Default timer, called from native */
event Timer()
{
	super(KFGameInfo).Timer();

	if ( ZTSpawnModeEnum == ZTSM_UNMODDED )
	{
		`cdlog("Invoking MinSpawnIntervalFloat from Timer");
		SpawnManagerWakeup();
	}

	if ( GameConductor != none )
	{
		GameConductor.TimerUpdate();
	}
}

private function SpawnManagerWakeup()
{
	if( SpawnManager != none )
	{
		SpawnManager.Update();
	}
}

private function ParseCDGameOptions( const out string Options )
{

	ParseAndClampFloatOpt( Options, SpawnMod, SpawnModFloat, "SpawnMod", 1.f, ClampSpawnMod );

	if ( HasOption(Options, "MaxMonsters") )
	{
		MaxMonsters = GetIntOption( Options, "MaxMonsters", -1 );
		`cdlog("MaxMonstersFromGameOptions = "$MaxMonsters$" (-1=default)", bLogControlledDifficulty);
	}

	if ( HasOption(Options, "WeaponTimeout") )
	{
		WeaponTimeout = ParseOption(Options, "WeaponTimeout" );
		`cdlog("WeaponTimeoutFromGameOptions = "$WeaponTimeout, bLogControlledDifficulty);
	}

	WeaponTimeout = ClampWeaponTimeout( WeaponTimeout );
	`cdlog("Clamped WeaponTimeout = "$WeaponTimeout, bLogControlledDifficulty);
	GameInfo_CDCP.Print("WeaponTimeout="$ GetWeaponTimeoutString() );

	if ( HasOption(Options, "AlbinoCrawlers") )
	{
		AlbinoCrawlers = GetBoolOption( Options, "AlbinoCrawlers", true );
		`cdlog("AlbinoCrawlersFromGameOptions = "$AlbinoCrawlers$" (true=default)", bLogControlledDifficulty);
	}

	if ( HasOption(Options, "AlbinoAlphas") )
	{
		AlbinoAlphas = GetBoolOption( Options, "AlbinoAlphas", true );
		`cdlog("AlbinoAlphasFromGameOptions = "$AlbinoAlphas$" (true=default)", bLogControlledDifficulty);
	}

	if ( HasOption(Options, "AlbinoGorefasts") )
	{
		AlbinoGorefasts= GetBoolOption( Options, "AlbinoGorefasts", true );
		`cdlog("AlbinoGorefastsFromGameOptions = "$AlbinoGorefasts$" (true=default)", bLogControlledDifficulty);
	}

	if ( HasOption(Options, "SpawnCycle") )
	{
		SpawnCycle= ParseOption(Options, "SpawnCycle" );
		`cdlog("SpawnCycleFromGameOptions = "$SpawnCycle, bLogControlledDifficulty);
	}

	ParseAndClampIntOpt( Options, CohortSize, "CohortSize", 0, ClampCohortSize );

	ParseAndClampIntOpt( Options, FakePlayers, "FakePlayers", -1, ClampFakePlayers );

	ParseAndClampFloatOpt( Options, MinSpawnInterval, MinSpawnIntervalFloat, "MinSpawnInterval", 1.f, ClampMinSpawnInterval );

	ParseAndClampFloatOpt( Options, ZTSpawnSlowdown, ZTSpawnSlowdownFloat, "ZTSpawnSlowdown", 1.f, ClampZTSpawnSlowdown );

	// Process TraderTime command option, if present
	if ( HasOption(Options, "TraderTime") )
	{
		TraderTime= GetIntOption( Options, "TraderTime", -1 );
		`cdlog("TraderTimeFromGameOptions = "$TraderTime$" (-1=missing)", bLogControlledDifficulty);
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

	// Initialize the SpawnCycle option if empty
	if ( "" == SpawnCycle )
	{
		SpawnCycle = "unmodded";
	}

	ParseAndSanitizeStringOpt( Options, Boss, "Boss", BossOptionDefaultValue, BossOptionHelpString, IsValidBossString );

	ParseAndSanitizeStringOpt( Options, ZTSpawnMode, "ZTSpawnMode", ZTSpawnModeDefaultValue, ZTSpawnModeHelpString, IsValidZTSpawnModeString );
	SetZTSpawnModeEnum();
}

private function SetZTSpawnModeEnum()
{
	if ( ZTSpawnMode == "unmodded" )
	{
		ZTSpawnModeEnum = ZTSM_UNMODDED;
	}
	else
	{
		ZTSpawnModeEnum = ZTSM_CLOCKWORK;
	}
}

private function ParseAndSanitizeStringOpt( const out string Options, out string Value, const string OptName,
		const out string DefaultValue, const out string HelpString, const delegate<StringReferencePredicate> Validator )
{
	if ( HasOption(Options, OptName) )
	{
		 Value = ParseOption(Options, OptName );
		`cdlog(OptName $"FromGameOptions = "$ Value, bLogControlledDifficulty);
	}

	// Initialize the option if currently the empty string
	if ( "" == Value )
	{
		Value = DefaultValue;
	}

	if ( !Validator( Value ) )
	{
		// TODO
		GameInfo_CDCP.Print( "WARNING Invalid: "$ OptName $"="$ Value $"; "$ HelpString );
		GameInfo_CDCP.Print( OptName $"=unmodded (forced because \""$ Value $"\" is invalid)");
		Value = DefaultValue;
	}
	else
	{
		GameInfo_CDCP.Print(OptName $"="$ Value);
	}
}

private function ParseAndClampFloatOpt( const out string Options, out string StringHolder, out float FloatValue, const string OptName,
		const float ParseErrorDefaultValue, const delegate<ClampFloatCDOption> Clamper )
{
	local float ValueBeforeClamping;

	if ( StringHolder == "" )
	{
		FloatValue = ParseErrorDefaultValue;
	}
	else
	{
		FloatValue = float( StringHolder );
	}

	if ( HasOption(Options, OptName) )
	{
		FloatValue = GetFloatOption( Options, OptName, ParseErrorDefaultValue );
		`cdlog(OptName $ "FromGameOptions = "$ FloatValue, bLogControlledDifficulty);
	}

	// FClamp the value
	ValueBeforeClamping = FloatValue;
	FloatValue = Clamper( FloatValue );
	`cdlog("Clamped "$ OptName $" = "$ FloatValue, bLogControlledDifficulty);

	if ( FloatValue == ValueBeforeClamping )
	{
		GameInfo_CDCP.Print(OptName $"="$ FloatValue);
	}
	else
	{
		GameInfo_CDCP.Print(OptName $"="$ FloatValue $" (clamped from "$ ValueBeforeClamping $")");
	}

	// Make a string copy (by CD convention, only string copies of config opts are saved, not the float copy)
	StringHolder = string( FloatValue );
}

private function ParseAndClampIntOpt( const out string Options, out int Value, const string OptName,
		const int ParseErrorDefaultValue, const delegate<ClampIntCDOption> Clamper )
{
	local int ValueBeforeClamping, ValueFromGameOptions;

	// Process command-line option, if present
	if ( HasOption( Options, OptName ) )
	{
		ValueFromGameOptions = GetIntOption( Options, OptName, ParseErrorDefaultValue );
		`cdlog(OptName $ "FromGameOptions = "$ValueFromGameOptions, bLogControlledDifficulty);
		Value = ValueFromGameOptions;
	}

	ValueBeforeClamping = Value;
	Value = Clamper( Value ); // TODO delegate
	`cdlog("Clamped "$ OptName $" = "$ Value, bLogControlledDifficulty);

	// Print clamped value to console
	if ( Value != ValueBeforeClamping )
	{
		GameInfo_CDCP.Print(OptName$"="$Value$" (clamped from "$ValueBeforeClamping$")");
	}
	else
	{
		GameInfo_CDCP.Print(OptName$"="$Value);
	}
}

private function InitStructStagedConfig()
{
	StagedConfig.AlbinoAlphas = AlbinoAlphas;
	StagedConfig.AlbinoCrawlers = AlbinoCrawlers;
	StagedConfig.AlbinoGorefasts = AlbinoGorefasts;
	StagedConfig.Boss = Boss;
	StagedConfig.CohortSize = CohortSize;
	StagedConfig.FakePlayers = FakePlayers;
	StagedConfig.MaxMonsters = MaxMonsters;
	StagedConfig.MinSpawnIntervalFloat = MinSpawnIntervalFloat;
	StagedConfig.SpawnCycle = SpawnCycle;
	StagedConfig.SpawnModFloat = SpawnModFloat;
//	StagedConfig.TraderTime = TraderTime;
	StagedConfig.WeaponTimeout = WeaponTimeout;
	StagedConfig.ZTSpawnSlowdownFloat = ZTSpawnSlowdownFloat;
	StagedConfig.ZTSpawnMode = ZTSpawnMode;
}


private function SetupSimpleReadCommand( out StructChatCommand scc, const string CmdName, const string Desc, const delegate<ChatCommandNullaryImpl> Impl )
{
	local array<string> n;
	local array<string> empty;

	empty.length = 0;
	n.Length = 1;
	n[0] = CmdName;

	scc.Names = n;
	scc.ParamHints = empty;
	scc.NullaryImpl = Impl;
	scc.ParamsImpl = None;
	scc.Description = Desc;
	scc.AuthLevel = CDAUTH_READ;
	scc.ModifiesConfig = false;

	ChatCommands.AddItem( scc );
}

private function SetupSimpleWriteCommand( out StructChatCommand scc, const string CmdName, const string Desc, const string Hint, const delegate<ChatCommandParamsImpl> Impl )
{
	local array<string> n;
	local array<string> hints;

	n.Length = 1;
	n[0] = CmdName;

	hints.Length = 1;
	hints[0] = Hint;

	scc.Names = n;
	scc.ParamHints = hints;
	scc.NullaryImpl = None;
	scc.ParamsImpl = Impl;
	scc.Description = Desc;
	scc.AuthLevel = CDAUTH_WRITE;
	scc.ModifiesConfig = true;

	ChatCommands.AddItem( scc );
}

private function SetupChatCommands()
{
	local array<string> n;
	local array<string> h;
	local StructChatCommand scc;

	ChatCommands.Length = 0;

	// Setup pause commands
	n.Length = 2;
	h.Length = 0;
	n[0] = "!cdpausetrader";
	n[1] = "!cdpt";
	scc.Names = n;
	scc.ParamHints = h;
	scc.NullaryImpl = PauseTraderTime;
	scc.ParamsImpl = None;
	scc.Description = "Pause TraderTime countdown";
	scc.AuthLevel = CDAUTH_WRITE;
	scc.ModifiesConfig = false;
	ChatCommands.AddItem( scc );

	n.Length = 2;
	h.Length = 0;
	n[0] = "!cdunpausetrader";
	n[1] = "!cdupt";
	scc.Names = n;
	scc.ParamHints = h;
	scc.NullaryImpl = UnpauseTraderTime;
	scc.ParamsImpl = None;
	scc.Description = "Unpause TraderTime countdown";
	scc.AuthLevel = CDAUTH_WRITE;
	scc.ModifiesConfig = false;
	ChatCommands.AddItem( scc );

	// Setup info commands
	n.Length = 1;
	h.Length = 0;
	n[0] = "!cdinfo";
	scc.Names = n;
	scc.ParamHints = h;
	scc.NullaryImpl = GetCDInfoChatStringDefault;
	scc.ParamsImpl = None;
	scc.Description = "Display CD config summary";
	scc.AuthLevel = CDAUTH_READ;
	scc.ModifiesConfig = false;
	ChatCommands.AddItem( scc );

	n.Length = 1;
	h.Length = 1;
	n[0] = "!cdinfo";
	h[0] = "full|abbrev";
	scc.Names = n;
	scc.ParamHints = h;
	scc.NullaryImpl = None;
	scc.ParamsImpl = GetCDInfoChatStringCommand;
	scc.Description = "Display full CD config";
	scc.AuthLevel = CDAUTH_READ;
	scc.ModifiesConfig = false;
	ChatCommands.AddItem( scc );

	SetupSimpleReadCommand( scc, "!cdalbinoalphas", "Display AlbinoAlphas setting", GetAlbinoAlphasChatString );
	SetupSimpleReadCommand( scc, "!cdalbinocrawlers", "Display AlbinoCrawlers setting", GetAlbinoCrawlersChatString );
	SetupSimpleReadCommand( scc, "!cdalbinogorefasts", "Display AlbinoGorefasts setting", GetAlbinoGorefastsChatString );
	SetupSimpleReadCommand( scc, "!cdboss", "Display Boss override", GetBossChatString );
	SetupSimpleReadCommand( scc, "!cdcohortsize", "Display spawning cohort size in zeds", GetCohortSizeChatString );
	SetupSimpleReadCommand( scc, "!cdhelp", "Information about CD's chat commands", GetCDChatHelpReferralString );
	SetupSimpleReadCommand( scc, "!cdfakeplayers", "Display FakePlayers count", GetFakePlayersChatString );
//	SetupSimpleReadCommand( scc, "!cdinfo", "Display a summary of CD settings", GetCDInfoChatStringDefault );
	SetupSimpleReadCommand( scc, "!cdmaxmonsters", "Display MaxMonsters count", GetMaxMonstersChatString );
	SetupSimpleReadCommand( scc, "!cdminspawninterval", "Display MinSpawnInterval value", GetMinSpawnIntervalChatString );
	SetupSimpleReadCommand( scc, "!cdspawncycle", "Display SpawnCycle name", GetSpawnCycleChatString );
	SetupSimpleReadCommand( scc, "!cdspawnmod", "Display SpawnMod value", GetSpawnModChatString );
	SetupSimpleReadCommand( scc, "!cdtradertime", "Display TraderTime in seconds", GetTraderTimeChatString );
	SetupSimpleReadCommand( scc, "!cdversion", "Display mod version", GetCDVersionChatString );
	SetupSimpleReadCommand( scc, "!cdweapontimeout", "Display WeaponTimeout in seconds", GetWeaponTimeoutChatString );
	SetupSimpleReadCommand( scc, "!cdztspawnslowdown", "Display ZTSpawnSlowdown value", GetZTSpawnSlowdownChatString );
	SetupSimpleReadCommand( scc, "!cdztspawnmode", "Display ZTSpawnMode", GetZTSpawnModeChatString );

	SetupSimpleWriteCommand( scc, "!cdalbinoalphas", "Set AlbinoAlphas", "true|false", SetAlbinoAlphasChatCommand );
	SetupSimpleWriteCommand( scc, "!cdalbinocrawlers", "Set AlbinoCrawlers", "true|false", SetAlbinoCrawlersChatCommand );
	SetupSimpleWriteCommand( scc, "!cdalbinogorefasts", "Set AlbinoGorefasts", "true|false", SetAlbinoGorefastsChatCommand );
	SetupSimpleWriteCommand( scc, "!cdboss", "Choose which boss spawns on the final wave", "volter|patriarch|unmodded", SetBossChatCommand );
	SetupSimpleWriteCommand( scc, "!cdcohortsize", "Set CohortSize", "int", SetCohortSizeChatCommand );
	SetupSimpleWriteCommand( scc, "!cdfakeplayers", "Set FakePlayers", "int", SetFakePlayersChatCommand );
	SetupSimpleWriteCommand( scc, "!cdmaxmonsters", "Set MaxMonsters", "int", SetMaxMonstersChatCommand );
	SetupSimpleWriteCommand( scc, "!cdminspawninterval", "Set MinSpawnInterval", "float", SetMinSpawnIntervalChatCommand );
	SetupSimpleWriteCommand( scc, "!cdspawncycle", "Set SpawnCycle", "name_of_spawncycle|unmodded", SetSpawnCycleChatCommand );
	SetupSimpleWriteCommand( scc, "!cdspawnmod", "Set SpawnMod", "float", SetSpawnModChatCommand );
	SetupSimpleWriteCommand( scc, "!cdweapontimeout", "Set WeaponTimeout", "int|max", SetWeaponTimeoutChatCommand );
	SetupSimpleWriteCommand( scc, "!cdztspawnslowdown", "Set ZTSpawnSlowdown", "float", SetZTSpawnSlowdownChatCommand );
	SetupSimpleWriteCommand( scc, "!cdztspawnmode", "Set ZTSpawnMode", "unmodded|clockwork", SetZTSpawnModeChatCommand );
}

private function string GetCDChatHelpReferralString() {
	return "Type CDChatHelp in console for chat command info";
}

private function string SetAlbinoAlphasChatCommand( const out array<string> params )
{
	StagedConfig.AlbinoAlphas = bool( params[0] );

	if ( AlbinoAlphas != StagedConfig.AlbinoAlphas )
	{
		return "Staged: AlbinoAlphas=" $ StagedConfig.AlbinoAlphas $
			"\nEffective after current wave"; 
	}
	else
	{
		return "AlbinoAlphas is already " $ AlbinoAlphas;
	}
}

private function string SetAlbinoCrawlersChatCommand( const out array<string> params )
{
	StagedConfig.AlbinoCrawlers = bool( params[0] );

	if ( AlbinoCrawlers != StagedConfig.AlbinoCrawlers )
	{
		return "Staged: AlbinoCrawlers=" $ StagedConfig.AlbinoCrawlers $
			"\nEffective after current wave"; 
	}
	else
	{
		return "AlbinoCrawlers is already " $ AlbinoCrawlers;
	}
}

private function string SetAlbinoGorefastsChatCommand( const out array<string> params )
{
	StagedConfig.AlbinoGorefasts = bool( params[0] );

	if ( AlbinoGorefasts != StagedConfig.AlbinoGorefasts )
	{
		return "Staged: AlbinoGorefasts=" $ StagedConfig.AlbinoGorefasts $
			"\nEffective after current wave"; 
	}
	else
	{
		return "AlbinoGorefasts is already " $ AlbinoGorefasts;
	}
}

private function string SetCohortSizeChatCommand( const out array<string> params )
{
	local int TempInt;

	TempInt = int( params[0] );
	TempInt = ClampCohortSize( TempInt );
	StagedConfig.CohortSize = TempInt;
	if ( CohortSize != StagedConfig.CohortSize )
	{
		return "Staged: CohortSize=" $ StagedConfig.CohortSize $
			"\nEffective after current wave"; 
	}
	else
	{
		return "CohortSize is already " $ CohortSize;
	}
}

private function string SetZTSpawnModeChatCommand( const out array<string> params )
{
	local string TempString;

	TempString = Locs( params[0] );

	if ( TempString == ZTSpawnMode )
	{
		return "ZTSpawnMode is already " $ ZTSpawnMode;
	}

	else if ( IsValidZTSpawnModeString( TempString ) )
	{
		StagedConfig.ZTSpawnMode = TempString;
		return "Staged: ZTSpawnMode=" $ StagedConfig.ZTSpawnMode $
			"\nEffective after current wave"; 
	}
	else
	{
		return "Not a valid ZTSpawnMode string\n" $
			"Try unmodded or clockwork"; 
	}
}


private function string SetBossChatCommand( const out array<string> params )
{
	local string TempString;

	TempString = Locs( params[0] );

	if ( TempString == Boss )
	{
		return "Boss is already " $ Boss;
	}
	// I could check for pointless changes here
	// (e.g. "unmodded" -> "random", equivalent but different strings)
	// but it is hard to describe the associated subtlety in a chat response
	else if ( IsValidBossString( TempString ) )
	{
		StagedConfig.Boss = TempString;
		return "Staged: Boss=" $ StagedConfig.Boss $
			"\nEffective after current wave"; 
	}
	else
	{
		return "Not a valid boss string\n" $
			"Try hans, pat, or unmodded"; 
	}
}

private function string SetFakePlayersChatCommand( const out array<string> params )
{
	local int TempInt;

	TempInt = int( params[0] );
	TempInt = ClampFakePlayers( TempInt );
	StagedConfig.FakePlayers = TempInt;
	if ( FakePlayers != StagedConfig.FakePlayers )
	{
		return "Staged: FakePlayers=" $ StagedConfig.FakePlayers $
			"\nEffective after current wave"; 
	}
	else
	{
		return "FakePlayers is already " $ FakePlayers;
	}
}

private function string SetWeaponTimeoutChatCommand( const out array<string> params )
{
	StagedConfig.WeaponTimeout = ClampWeaponTimeout( params[0] );

	if ( WeaponTimeout != StagedConfig.WeaponTimeout )
	{
		return "Staged: WeaponTimeout=" $ GetWeaponTimeoutStringForArg( StagedConfig.WeaponTimeout ) $
			"\nEffective after current wave"; 
	}
	else
	{
		return "WeaponTimeout is already " $ WeaponTimeout;
	}
}

private function string SetMaxMonstersChatCommand( const out array<string> params )
{
	local int TempInt;

	TempInt = int( params[0] );
	if ( TempInt < 0 )
	{
		TempInt = 0;
	} 
	StagedConfig.MaxMonsters = TempInt;

	if ( MaxMonsters != StagedConfig.MaxMonsters )
	{
		return "Staged: MaxMonsters=" $ GetMaxMonstersStringForArg( StagedConfig.MaxMonsters ) $
			"\nEffective after current wave"; 
	}
	else
	{
		return "MaxMonsters is already " $ MaxMonsters;
	}
}

private function string SetMinSpawnIntervalChatCommand( const out array<string> params )
{
	local float TempFloat;

	TempFloat = float( params[0] );
	TempFloat = ClampMinSpawnInterval( TempFloat );
	StagedConfig.MinSpawnIntervalFloat = TempFloat;
	if ( !EpsilonClose( MinSpawnIntervalFloat, StagedConfig.MinSpawnIntervalFloat, MinSpawnIntervalEpsilon ) )
	{
		return "Staged: MinSpawnInterval=" $ StagedConfig.MinSpawnIntervalFloat $
			"\nEffective after current wave"; 
	}
	else
	{
		return "MinSpawnInterval is already " $ MinSpawnInterval;
	}
}


private function string SetSpawnCycleChatCommand( const out array<string> params )
{
	StagedConfig.SpawnCycle = params[0];
	if ( SpawnCycle != StagedConfig.SpawnCycle )
	{
		return "Staged: SpawnCycle=" $ StagedConfig.SpawnCycle $
			"\nEffective after current wave"; 
	}
	else
	{
		return "SpawnCycle is already " $ SpawnCycle;
	}
}

private function string SetSpawnModChatCommand( const out array<string> params )
{
	local float TempFloat;

	TempFloat = float( params[0] );
	TempFloat = ClampSpawnMod( TempFloat );
	StagedConfig.SpawnModFloat = TempFloat;
	if ( !EpsilonClose( SpawnModFloat, StagedConfig.SpawnModFloat, SpawnModEpsilon ) )
	{
		return "Staged: SpawnMod=" $ StagedConfig.SpawnModFloat $
			"\nEffective after current wave"; 
	}
	else
	{
		return "SpawnMod is already " $ SpawnMod;
	}
}

private function string SetZTSpawnSlowdownChatCommand( const out array<string> params )
{
	local float TempFloat;

	TempFloat = float( params[0] );
	TempFloat = ClampZTSpawnSlowdown( TempFloat );
	StagedConfig.ZTSpawnSlowdownFloat = TempFloat;
	if ( !EpsilonClose( ZTSpawnSlowdownFloat, StagedConfig.ZTSpawnSlowdownFloat, ZTSpawnSlowdownEpsilon ) )
	{
		return "Staged: ZTSpawnSlowdown=" $ StagedConfig.ZTSpawnSlowdownFloat $
			"\nEffective after current wave"; 
	}
	else
	{
		return "ZTSpawnSlowdown is already " $ ZTSpawnSlowdown;
	}
}

private function DisplayBriefWaveStatsInChat()
{
	local string s;

	s = CDSpawnManager( SpawnManager ).GetWaveAverageSpawnrate();

	super.Broadcast(None, "[CD] Wave Recap:\n"$ s, 'CDEcho');
}

State TraderOpen
{
	function BeginState( Name PreviousStateName )
	{
		super.BeginState( PreviousStateName );

		SetTimer(1.f, false, 'DisplayBriefWaveStatsInChat');
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

private function bool IsValidZTSpawnModeString( const out string ztsm )
{
	return "unmodded" == ztsm || "clockwork" == ztsm;
}

private function bool IsValidBossString( const out string bs )
{
	return isRandomBossString(bs) || isPatriarchBossString(bs) || isVolterBossString(bs);
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

private function int ClampCohortSize( const out int cs )
{
	return 0 > cs ? 0 : cs;
}

private function int ClampFakePlayers( const out int fp )
{
	return Clamp(fp, 0, 32);
}

private function float ClampSpawnMod( const out float sm )
{
	return FClamp(sm, 0.f, 1.f);
}

private function float ClampMinSpawnInterval( const out float msi )
{
	return FClamp(msi, 0.05 /* 50 ms */, 60.f /* 1 min */);
}

private function float ClampZTSpawnSlowdown( const out float ztss )
{
	return FClamp(ztss, 1.f, 10.f);
}

private function string ClampWeaponTimeout( const out string wt )
{
	local int ParsedSeconds;

	if ( "max" == wt )
	{
		return wt;
	}

	if ( "" != wt )
	{
		ParsedSeconds = int(wt);

		if ( 0 == ParsedSeconds )
		{
			if ( "0" == wt )
			{
				// User specified the exact string "0"; accept it as-is
				return wt;
			}
			else
			{
				// This nonempty string converted to 0 (the default value),
				// but the string itself is not "0".  unrealscript's
				// string-to-int parser never actually fails, it just stops
				// when it finds a character it doesn't understand.  this
				// means the user probably gave us a garbage string.
				// replace it with "-1", which means use TWI's default
				// weapon timeout (a safe default).
				return string(-1);
			}
		}
		else
		{
			return string( ParsedSeconds );
		}
	}

	return string(-1);
}


/*
 * We override this function to apply FakePlayers modifier
 * to dosh rewards for killing zeds.
 */
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

	`cdlog("NumPlayers = "$LocalNumPlayers, bLogControlledDifficulty);
	`cdlog("NumFakes = "$LocalNumFakes, bLogControlledDifficulty);
	`cdlog("DifficultyInfo.GetPlayerNumMaxAIModifier(NumPlayers) = "$LocalMaxAIMod$"; this is fake-count-adjusted", bLogControlledDifficulty);

	DoshMod = (LocalNumPlayers + LocalNumFakes) / LocalMaxAIMod;

	`cdlog("Starting Dosh Bounty: "$ModifiedValue$" DoshMod: "$DoshMod, bLogControlledDifficulty);

	ModifiedValue *= DoshMod;

	`cdlog("Modified Dosh Bounty: "$ModifiedValue, bLogControlledDifficulty);
}

private function string GetMaxMonstersStringForArg( const int mm )
{
	if (0 < mm)
	{
		return string(mm);
	}
	else if ( WorldInfo.NetMode == NM_StandAlone )
	{
		return string(class'CDSpawnManager'.default.MaxMonstersSolo[GameDifficulty]);
	}
	else
	{
		return string(class'CDSpawnManager'.default.MaxMonsters);
	}
}

private function string GetMaxMonstersString()
{
	return GetMaxMonstersStringForArg( MaxMonsters );
}

private function string GetWeaponTimeoutStringForArg( const string wt )
{
	local int seconds;

	if ( "max" == wt )
	{
		return "max";
	}

	seconds = int(wt);

	if ( 0 > seconds )
	{
		return "<unmodded default>";
	}
	else
	{
		return string(seconds);
	}
}

private function string GetWeaponTimeoutString()
{
	return GetWeaponTimeoutStringForArg( WeaponTimeout );
}

/*
 * Configure CD_SpawnManager (particularly MaxMonsters and SpawnCycle)
 */ 
function InitSpawnManager()
{
	local CDSpawnManager cdsm;

	local array<CD_AIWaveInfo> ActiveWaveInfos;

	super.InitSpawnManager();

	if ( SpawnManager.IsA( 'CDSpawnManager' ) )
	{
		`cdlog("Checked that SpawnManager "$SpawnManager$" is an instance of CDSpawnManager (OK)", bLogControlledDifficulty);
		cdsm = CDSpawnManager( SpawnManager );
	}
	else
	{
		GameInfo_CDCP.Print("WARNING: SpawnManager "$SpawnManager$" appears to be misconfigured! CD might not work correctly.");
		return;
	}

	GameInfo_CDCP.Print( "MaxMonsters=" $ GetMaxMonstersString() );

	LoadSpawnCycle( ActiveWaveInfos );

	if ( 0 == ActiveWaveinfos.length && SpawnCycle != "unmodded" )
	{
		GameInfo_CDCP.Print( "SpawnCycle=unmodded (forced because \""$ SpawnCycle $"\" is invalid or does not support this game length)" );
		SpawnCycle = "unmodded";
	}
	else
	{
		cdsm.SetCustomWaves( ActiveWaveInfos );
		GameInfo_CDCP.Print( "SpawnCycle="$ SpawnCycle );
	}

	GameInfo_CDCP.Print( "AlbinoAlphas="$AlbinoAlphas );
	GameInfo_CDCP.Print( "AlbinoCrawlers="$AlbinoCrawlers );
	GameInfo_CDCP.Print( "AlbinoGorefasts="$AlbinoGorefasts );
}

private function LoadSpawnCycle( out array<CD_AIWaveInfo> ActiveWaveInfos )
{
	// Assign a spawn definition array to CycleDefs (unless SpawnCycle=unmodded)
	if ( SpawnCycle == "ini" )
	{
		MaybeLoadIniWaveInfos();

		ActiveWaveInfos = IniWaveInfos;
	}
	else if ( SpawnCycle == "unmodded" )
	{
		`cdlog("Not using a SpawnCycle (value="$SpawnCycle$")", bLogControlledDifficulty);
	}
	else
	{
		if ( !SpawnCycleCatalog.ParseSquadCyclePreset( SpawnCycle, GameLength, ActiveWaveInfos ) )
		{
			ActiveWaveInfos.length = 0;
		}
	}
}

event Broadcast (Actor Sender, coerce string Msg, optional name Type)
{
	super.Broadcast(Sender, Msg, Type);

	if ( Type == 'Say' )
	{
		RunCDChatCommandIfAuthorized( Sender, Msg );
	}
}

private function RunCDChatCommandIfAuthorized( Actor Sender, string CommandString )
{
	local CDAuthLevel AuthLevel;
	local string ResponseMessage;
	local array<string> CommandTokens;
	local name GameStateName;
	local StructChatCommand Cmd;

	local bool SkipStagedConfigApplication;

	local delegate<ChatCommandNullaryImpl> CNDeleg;
	local delegate<ChatCommandParamsImpl> CPDeleg;

	SkipStagedConfigApplication = false;

	// First, see if this chat message looks even remotely like a CD command
	if ( 3 > Len( CommandString ) || !( Left( CommandString, 3 ) ~= "!cd" ) )
	{
		return;
	}

	AuthLevel = GetAuthorizationLevelForUser( Sender );

	// Chat commands are case-insensitive.  Lowercase the command now
	// so that we can do safely do string comparisons with lowercase
	// operands below.
	CommandString = Locs( CommandString );

	// Split the chat command on spaces, dropping empty parts.
	ParseStringIntoArray( CommandString, CommandTokens, " ", true );

	ResponseMessage = "";

	`cdlog("CommandTokens.Length: "$ CommandTokens.Length);

	if ( MatchChatCommand( CommandTokens[0], Cmd, AuthLevel, CommandTokens.Length - 1 ) )
	{
		`cdlog("Invoking chat command via table match");
		CNDeleg = Cmd.NullaryImpl;
		CPDeleg = Cmd.ParamsImpl;
		if ( Cmd.ParamHints.Length == 0 )
		{
			`cdlog("Invoking nullary chat command: "$ CommandString, bLogControlledDifficulty);
			ResponseMessage = CNDeleg();
		}
		else
		{
			`cdlog("Invoking chat command with parameters: "$ CommandString, bLogControlledDifficulty);
			CommandTokens.Remove( 0, 1 );
			ResponseMessage = CPDeleg( CommandTokens );
		}

		if ( Cmd.ModifiesConfig )
		{
			// Check whether we're allowed to modify settings right now.
			// If so, change settings immediately and let ApplyStagedSettings()
			// format an appropriate notification message.
			GameStateName = GetStateName();
			if ( !SkipStagedConfigApplication && ( GameStateName == 'PendingMatch' || GameStateName == 'MatchEnded' || GameStateName == 'TraderOpen' ) )
			{
				ApplyStagedConfig( ResponseMessage, "" );
			}
		}
	}
	else
	{
		`cdlog("Discarding unknown or unauthorized command: "$ CommandString, bLogControlledDifficulty);
	}

	// An authorized command match was found; the command may or may not
	// have succeeded, but something was executed and a chat reply should
	// be sent to all connected clients
	if ( "" != ResponseMessage )
	{
		super.Broadcast(None, ResponseMessage, 'CDEcho');
		return;
	}
}

private function bool MatchChatCommand( const string CmdName, out StructChatCommand Cmd, const CDAuthLevel AuthLevel, const int ParamCount )
{
	local int CCIndex;
	local int NameIndex;

	for ( CCIndex = 0; CCIndex < ChatCommands.length; CCIndex++ )
	{
		if ( AuthLevel < ChatCommands[CCIndex].AuthLevel )
		{
			continue;
		}

		if ( ParamCount != ChatCommands[CCIndex].ParamHints.Length )
		{
			continue;
		}

		for ( NameIndex = 0; NameIndex < ChatCommands[CCIndex].Names.Length; NameIndex++ )
		{
			if ( ChatCommands[CCIndex].Names[NameIndex] == CmdName )
			{
				Cmd = ChatCommands[CCIndex];
				return true;
				`cdlog("MatchChatCommand["$ CCIndex $"]: found Name="$ CmdName $" ParamCount="$ ParamCount $" AuthLevel="$ AuthLevel, bLogControlledDifficulty);
			}
		}
	}

	return false;
}

function WaveEnded( EWaveEndCondition WinCondition )
{
	local string CDSettingChangeMessage;

	super.WaveEnded( WinCondition );

	if ( ApplyStagedConfig( CDSettingChangeMessage, "Staged settings applied:" ) )
	{
		super.Broadcast(None, CDSettingChangeMessage, 'CDEcho');
	}
}


function StartWave()
{
	local string CDSettingChangeMessage;

	if ( ApplyStagedConfig( CDSettingChangeMessage, "Staged settings applied:" ) )
	{
		super.Broadcast(None, CDSettingChangeMessage, 'CDEcho');
	}
	
	super.StartWave();

	// If this is the first wave, print CD's settings
	if ( 1 == WaveNum )
	{
		SetTimer( 2.0f, false, 'DisplayWaveStartMessageInChat' );
	}
}

private function DisplayWaveStartMessageInChat()
{
	super.Broadcast(None, "[Controlled Difficulty Active]\n" $ GetCDInfoChatString( "brief" ), 'CDEcho');
}

private function bool ApplyStagedConfig( out string MessageToClients, const string BannerLine )
{
	local array<string> SettingChangeNotifications;
	local string TempString;
	local array<CD_AIWaveInfo> ActiveWaveInfos;

	if ( StagedConfig.AlbinoAlphas != AlbinoAlphas )
	{
		SettingChangeNotifications.AddItem("AlbinoAlphas="$ StagedConfig.AlbinoAlphas $" (old: "$AlbinoAlphas$")");
		AlbinoAlphas = StagedConfig.AlbinoAlphas;
	}

	if ( StagedConfig.AlbinoCrawlers != AlbinoCrawlers )
	{
		SettingChangeNotifications.AddItem("AlbinoCrawlers="$ StagedConfig.AlbinoCrawlers $" (old: "$AlbinoCrawlers$")");
		AlbinoCrawlers = StagedConfig.AlbinoCrawlers;
	}

	if ( StagedConfig.AlbinoGorefasts != AlbinoGorefasts )
	{
		SettingChangeNotifications.AddItem("AlbinoGorefasts="$ StagedConfig.AlbinoGorefasts $" (old: "$AlbinoGorefasts$")");
		AlbinoGorefasts = StagedConfig.AlbinoGorefasts;
	}

	if ( StagedConfig.Boss != Boss )
	{
		SettingChangeNotifications.AddItem("Boss="$ StagedConfig.Boss $" (old: "$Boss$")");
		Boss = StagedConfig.Boss;
	}

	if ( StagedConfig.CohortSize != CohortSize )
	{
		SettingChangeNotifications.AddItem("CohortSize="$ StagedConfig.CohortSize $" (old: "$CohortSize$")");
		CohortSize = StagedConfig.CohortSize;
	}

	if ( StagedConfig.FakePlayers != FakePlayers )
	{
		SettingChangeNotifications.AddItem("FakePlayers="$ StagedConfig.FakePlayers $" (old: "$FakePlayers$")");
		FakePlayers = StagedConfig.FakePlayers;
	}

	if ( !EpsilonClose( StagedConfig.MinSpawnIntervalFloat, MinSpawnIntervalFloat, MinSpawnIntervalEpsilon ) )
	{
		SettingChangeNotifications.AddItem("MinSpawnInterval="$ StagedConfig.MinSpawnIntervalFloat $" (old: "$MinSpawnIntervalFloat$")");
		MinSpawnIntervalFloat = StagedConfig.MinSpawnIntervalFloat;
		MinSpawnInterval = string(MinSpawnIntervalFloat);
		SetSpawnManagerWakeup();
	}

	if ( StagedConfig.MaxMonsters != MaxMonsters )
	{
		SettingChangeNotifications.AddItem(
			"MaxMonsters="$ GetMaxMonstersStringForArg( StagedConfig.MaxMonsters ) $
			" (old: "$ GetMaxMonstersString() $")");
		MaxMonsters = StagedConfig.MaxMonsters;
	}

	if ( StagedConfig.WeaponTimeout != WeaponTimeout )
	{
		SettingChangeNotifications.AddItem(
			"WeaponTimeout="$ GetWeaponTimeoutStringForArg( StagedConfig.WeaponTimeout ) $
			" (old: "$ GetWeaponTimeoutString() $")");
		WeaponTimeout = StagedConfig.WeaponTimeout;
	}


	if ( StagedConfig.SpawnCycle != SpawnCycle )
	{
		TempString = SpawnCycle;
		SpawnCycle = StagedConfig.SpawnCycle;

		LoadSpawnCycle( ActiveWaveInfos );

		if ( 0 == ActiveWaveinfos.length && SpawnCycle != "unmodded" )
		{
			// The new SpawnCycle was invalid or could not be loaded (gamelength incompatibility?)
			// Revert to the old SC
			SpawnCycle = TempString;
			// Warn the user
			SettingChangeNotifications.AddItem("Setting SpawnCycle=" $ StagedConfig.SpawnCycle $ " failed!");
			SettingChangeNotifications.AddItem("Kept SpawnCycle=" $ SpawnCycle);
			// Overwrite the user's staged SC choice
			StagedConfig.SpawnCycle = SpawnCycle;
			// Reload original SC into ActiveWaveInfos
			LoadSpawnCycle( ActiveWaveInfos );
		}
		else
		{
			// the new SpawnCycle is either "unmodded" or was successfully loaded
			CDSpawnManager( SpawnManager ).SetCustomWaves( ActiveWaveInfos );
			SettingChangeNotifications.AddItem("SpawnCycle="$ StagedConfig.SpawnCycle $" (old: "$TempString$")");
		}
	}

	if ( !EpsilonClose( StagedConfig.SpawnModFloat, SpawnModFloat, SpawnModEpsilon ) )
	{
		SettingChangeNotifications.AddItem("SpawnMod="$ StagedConfig.SpawnModFloat $" (old: "$SpawnModFloat$")");
		SpawnModFloat = StagedConfig.SpawnModFloat;
		SpawnMod = string(SpawnModFloat);
	}

	if ( !EpsilonClose( StagedConfig.ZTSpawnSlowdownFloat, ZTSpawnSlowdownFloat, ZTSpawnSlowdownEpsilon ) )
	{
		SettingChangeNotifications.AddItem("ZTSpawnSlowdown="$ StagedConfig.ZTSpawnSlowdownFloat $" (old: "$ZTSpawnSlowdownFloat$")");
		ZTSpawnSlowdownFloat = StagedConfig.ZTSpawnSlowdownFloat;
		ZTSpawnSlowdown = string(ZTSpawnSlowdownFloat);
	}

	if ( StagedConfig.ZTSpawnMode != ZTSpawnMode )
	{
		SettingChangeNotifications.AddItem("ZTSpawnMode="$ StagedConfig.ZTSpawnMode $" (old: "$ZTSpawnMode$")");
		ZTSpawnMode = StagedConfig.ZTSpawnMode;
		SetZTSpawnModeEnum();
	}

//	if ( StagedConfig.TraderTime != TraderTime )
//	{
//		SettingChangeNotifications.AddItem("TraderTime="$ StagedConfig.TraderTime $" (old: "$TraderTime$")");
//		TraderTime = StagedConfig.TraderTime;
//	}

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

private function bool EpsilonClose( const float a, const float b, const float epsilon )
{
	return a == b || (a < b && b < (a + epsilon)) || (b < a && a < (b + epsilon));
}

private function CDAuthLevel GetAuthorizationLevelForUser( Actor Sender )
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

	HexStringToInt( Right( SteamIdHexString, 8 ), SteamIdAccountNumber );

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

private function int HexStringToInt( string hexstr, out int value )
{
	local int i;
	local int multiplier;

	hexstr = Locs(hexstr);

	multiplier = 1;
	value = 0;

	for ( i = Len(hexstr) - 1 ; 0 <= i ; i-- )
	{
		switch (Mid(hexstr, i, 1))
		{
		case "0": break;
		case "1": value += multiplier; break;
		case "2": value += (multiplier * 2);  break;
		case "3": value += (multiplier * 3);  break;
		case "4": value += (multiplier * 4);  break;
		case "5": value += (multiplier * 5);  break;
		case "6": value += (multiplier * 6);  break;
		case "7": value += (multiplier * 7);  break;
		case "8": value += (multiplier * 8);  break;
		case "9": value += (multiplier * 9);  break;
		case "a": value += (multiplier * 10); break;
		case "b": value += (multiplier * 11); break;
		case "c": value += (multiplier * 12); break;
		case "d": value += (multiplier * 13); break;
		case "e": value += (multiplier * 14); break;
		case "f": value += (multiplier * 15); break;
		default: return -1;
		}

		multiplier *= 16; 
	}

	return value;
}

private function string GetCDInfoChatStringDefault()
{
	return GetCDInfoChatString( "brief" );
}

private function string GetCDInfoChatStringCommand( const out array<string> params)
{
	return GetCDInfoChatString( params[0] );
}

private function string GetCDInfoChatString( const string Verbosity )
{
	if ( Verbosity == "full" )
	{
		return GetAlbinoAlphasChatString() $ "\n" $
		       GetAlbinoCrawlersChatString() $ "\n" $
		       GetAlbinoGorefastsChatString() $ "\n" $
		       GetBossChatString() $ "\n" $
		       GetCohortSizeChatString() $ "\n" $
		       GetFakePlayersChatString() $ "\n" $
		       GetMaxMonstersChatString() $ "\n" $
		       GetMinSpawnIntervalChatString() $ "\n" $
		       GetSpawnCycleChatString() $ "\n" $
		       GetSpawnModChatString() $ "\n" $
		       GetTraderTimeChatString() $ "\n" $
		       GetWeaponTimeoutChatString() $ "\n" $
		       GetZTSpawnSlowdownChatString() $ "\n" $
		       GetZTSpawnModeChatString();
	}
	else
	{
		return GetFakePlayersChatString() $ "\n" $
		       GetMaxMonstersChatString() $ "\n" $
		       GetSpawnModChatString() $ "\n" $
		       GetCohortSizeChatString() $ "\n" $
		       GetSpawnCycleChatString();
	}
}

private function string GetAlbinoAlphasChatString()
{
	local string AlbinoAlphasLatchedString;

	if ( StagedConfig.AlbinoAlphas != AlbinoAlphas )
	{
		AlbinoAlphasLatchedString = " (staged: " $ StagedConfig.AlbinoAlphas $ ")";
	}

	return "AlbinoAlphas=" $ AlbinoAlphas $ AlbinoAlphasLatchedString;
}

private function string GetAlbinoCrawlersChatString()
{
	local string AlbinoCrawlersLatchedString;

	if ( StagedConfig.AlbinoCrawlers != AlbinoCrawlers )
	{
		AlbinoCrawlersLatchedString = " (staged: " $ StagedConfig.AlbinoCrawlers $ ")";
	}

	return "AlbinoCrawlers=" $ AlbinoCrawlers $ AlbinoCrawlersLatchedString;
}

private function string GetAlbinoGorefastsChatString()
{
	local string AlbinoGorefastsLatchedString;

	if ( StagedConfig.AlbinoGorefasts != AlbinoGorefasts )
	{
		AlbinoGorefastsLatchedString = " (staged: " $ StagedConfig.AlbinoGorefasts $ ")";
	}

	return "AlbinoGorefasts=" $ AlbinoGorefasts $ AlbinoGorefastsLatchedString;
}

private function string GetZTSpawnModeChatString()
{
	local string ZTSpawnModeLatchedString;

	if ( StagedConfig.ZTSpawnMode != ZTSpawnMode )
	{
		ZTSpawnModeLatchedString = " (staged: " $ StagedConfig.ZTSpawnMode $ ")";
	}

	return "ZTSpawnMode=" $ ZTSpawnMode $ ZTSpawnModeLatchedString;
}

private function string GetBossChatString()
{
	local string BossLatchedString;

	if ( StagedConfig.Boss != Boss )
	{
		BossLatchedString = " (staged: " $ StagedConfig.Boss $ ")";
	}

	return "Boss=" $ Boss $ BossLatchedString;
}

private function string GetCohortSizeChatString()
{
	local string CohortSizeLatchedString;

	if ( StagedConfig.CohortSize != CohortSize )
	{
		CohortSizeLatchedString = " (staged: " $ StagedConfig.CohortSize $ ")";
	}

	return "CohortSize=" $ CohortSize $ CohortSizeLatchedString;
}

private function string GetFakePlayersChatString()
{
	local string FakePlayersLatchedString;

	if ( StagedConfig.FakePlayers != FakePlayers )
	{
		FakePlayersLatchedString = " (staged: " $ StagedConfig.FakePlayers $ ")";
	}

	return "FakePlayers=" $ FakePlayers $ FakePlayersLatchedString;
}

private function string GetMaxMonstersChatString()
{
	local string MaxMonstersLatchedString;

	if ( StagedConfig.MaxMonsters != MaxMonsters )
	{
		MaxMonstersLatchedString = " (staged: " $ GetMaxMonstersStringForArg(StagedConfig.MaxMonsters) $ ")";
	}

	return "MaxMonsters="$ GetMaxMonstersString() $ MaxMonstersLatchedString;
}

private function string GetMinSpawnIntervalChatString()
{
	local string MinSpawnIntervalLatchedString;

	if ( !EpsilonClose( StagedConfig.MinSpawnIntervalFloat, MinSpawnIntervalFloat, MinSpawnIntervalEpsilon ) )
	{
		MinSpawnIntervalLatchedString = " (staged: " $ StagedConfig.MinSpawnIntervalFloat $ ")";
	}

	return "MinSpawnInterval="$ MinSpawnIntervalFloat $ MinSpawnIntervalLatchedString;
}

private function string GetWeaponTimeoutChatString()
{
	local string WeaponTimeoutLatchedString;

	if ( StagedConfig.WeaponTimeout != WeaponTimeout )
	{
		WeaponTimeoutLatchedString = " (staged: " $ GetWeaponTimeoutStringForArg(StagedConfig.WeaponTimeout) $ ")";
	}

	return "WeaponTimeout="$ GetWeaponTimeoutString() $ WeaponTimeoutLatchedString;
}

private function string GetSpawnCycleChatString()
{
	local string SpawnCycleLatchedString;

	if ( StagedConfig.SpawnCycle != SpawnCycle )
	{
		SpawnCycleLatchedString = " (staged: " $ StagedConfig.SpawnCycle $ ")";
	}

	return "SpawnCycle=" $ SpawnCycle $ SpawnCycleLatchedString;
}

private function string GetSpawnModChatString()
{
	local string SpawnModLatchedString;

	if ( !EpsilonClose( StagedConfig.SpawnModFloat, SpawnModFloat, SpawnModEpsilon ) )
	{
		SpawnModLatchedString = " (staged: " $ StagedConfig.SpawnModFloat $ ")";
	}

	return "SpawnMod="$ SpawnModFloat $ SpawnModLatchedString;
}

private function string GetZTSpawnSlowdownChatString()
{
	local string ZTSpawnSlowdownLatchedString;

	if ( !EpsilonClose( StagedConfig.ZTSpawnSlowdownFloat, ZTSpawnSlowdownFloat, ZTSpawnSlowdownEpsilon ) )
	{
		ZTSpawnSlowdownLatchedString = " (staged: " $ StagedConfig.ZTSpawnSlowdownFloat $ ")";
	}

	return "ZTSpawnSlowdown="$ ZTSpawnSlowdownFloat $ ZTSpawnSlowdownLatchedString;
}


private function string GetTraderTimeChatString()
{
	local string TraderTimeLatchedString;

//	if ( StagedConfig.TraderTime != TraderTime )
//	{
//		TraderTimeLatchedString = " (staged: " $ StagedConfig.TraderTime $ ")";
//	}

	TraderTimeLatchedString = "";

	return "TraderTime=" $ TraderTime $ TraderTimeLatchedString;
}

private function string GetCDVersionChatString()
{
	return "Ver=" $ `CD_COMMIT_HASH $ "\nDate=" $ `CD_AUTHOR_TIMESTAMP;
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
	local string HelpString;
	local int CCIndex, NameIndex, ParamIndex;

	GameInfo_CDCP.Print("Controlled Difficulty Chat Commands", false);
	GameInfo_CDCP.Print("----------------------------------------------------", false);
	GameInfo_CDCP.Print("CD knows the following chat commands.  Type any command in global chat.", false);
	GameInfo_CDCP.Print("Commands typed in team chat are ignored.  Commands marked CDAUTH_READ ", false);
	GameInfo_CDCP.Print("are usable by anyone.  Dedicated server admins may optionally restrict ", false);
	GameInfo_CDCP.Print("access to commands marked CDAUTH_WRITE.", false);

	for ( CCIndex = 0; CCIndex < ChatCommands.Length; CCIndex++ )
	{
		HelpString = "  " $ ChatCommands[CCIndex].Names[0];

		for ( ParamIndex = 0; ParamIndex < ChatCommands[CCIndex].ParamHints.Length; ParamIndex++ )
		{
			HelpString $= " <" $ ChatCommands[CCIndex].ParamHints[ParamIndex] $ ">";
		}

		if ( 1 < ChatCommands[CCIndex].Names.Length )
		{
			HelpString $= " (alternate name(s): ";

			for ( NameIndex = 1; NameIndex < ChatCommands[CCIndex].Names.Length; NameIndex++ )
			{
				if ( 1 < NameIndex )
				{
					HelpString $= ", ";
				}
				HelpString $= ChatCommands[CCIndex].Names[NameIndex];
			}

			HelpString $= ")";
		}

		HelpString $= " [" $ ChatCommands[CCIndex].AuthLevel $ "]";

		GameInfo_CDCP.Print(HelpString, false);
		GameInfo_CDCP.Print("    " $ ChatCommands[CCIndex].Description, false);
	}
}


exec function CDSpawnSummaries( optional string CycleName, optional int AssumedPlayerCount = -255 )
{
	local array<CD_AIWaveInfo> WaveInfosToSummarize;
	local DifficultyWaveInfo DWS;
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

	SpawnModEpsilon=0.0001
	MinSpawnIntervalEpsilon=0.0001
	ZTSpawnSlowdownEpsilon=0.0001

	BossOptionHelpString="Valid alternatives: patriarch, hans, or unmodded"
	BossOptionDefaultValue="unmodded"

	ZTSpawnModeHelpString="Valid alternatives: unmodded or clockwork"
	ZTSpawnModeDefaultValue="unmodded"
}
