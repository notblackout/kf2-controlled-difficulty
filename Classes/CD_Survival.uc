//=============================================================================
// ControlledDifficulty_Survival
//=============================================================================
// Survival with less bullshit
//=============================================================================

class CD_Survival extends KFGameInfo_Survival;

`include(CD_BuildInfo.uci)
`include(CD_Log.uci)

enum ECDWaveInfoStatus
{
	WIS_OK,
	WIS_PARSE_ERROR,
	WIS_SPAWNCYCLE_NOT_MODDED
};

enum ECDFakePlayersMode
{
	FPM_ADD,
	FPM_REPLACE
};

enum ECDZTSpawnMode
{
	ZTSM_UNMODDED,
	ZTSM_CLOCKWORK
};

enum ECDBossChoice
{
	CDBOSS_RANDOM,
	CDBOSS_VOLTER,
	CDBOSS_PATRIARCH
};

enum ECDAuthLevel
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


//
// ### Spawn Intensity Settings
//

// #### CohortSize
//
// The maximum number of zeds that CD's SpawnManager may spawn simultaneously
// (i.e. on one invocation of the SpawnManager's update function).
//
// If this is set to 0, then the cohort spawn logic is inactive, and the game
// instead spawns one squad per invocation of the update function.  That
// behavior (i.e.  when set to 0) is how unmodded KF2 works: the spawn manager
// creates one squad per attempt, no matter how much headroom might exist under
// the MaxMonsters limit, or how many eligible spawnvolumes might be available
// to accomodate more squads.
var config string CohortSize;
var config const array<string> CohortSizeDefs;
var int CohortSizeInt;

// #### MaxMonsters
//
// The maximum monsters allowed on the map at one time.  In the vanilla game,
// this is 16 when in NM_StandAlone and GetLivingPlayerCount() == 1.   The
// vanilla game's default is 32 in any other case (such as when playing alone
// on a dedicated server).
//
// If this is set to a nonpositive value, then the vanilla behavior prevails.
//
// If this is set to a positive value, then it is the number of maximum
// monsters allowed on the map at one time.
var config string MaxMonsters;
var config const array<string> MaxMonstersDefs;
var int MaxMonstersInt;

// #### SpawnMod
//
// The forced spawn modifier, expressed as a float between 0 and 1.
// 
// 1.0 is KFGameConductor's player-friendliest state.  0.75 is
// KFGameConductor's player-hostile state.
//
// Below 0.75 is spawn intensity unseen in the vanilla game.
//
// Setting zero means the SpawnManager will try to spawn zeds every single time
// it is awoken (SpawnPoll controls how often it is awoken).  It will
// only fail to spawn zeds if either the MaxMonsters limit is reached, if the
// entire wave's worth of zeds has already spawned, or if the map's spawn
// volumes are so congested that new zeds physically cannot be spawned without
// failing a collision check (zeds inside other zeds).
//
// This does not affect SpawnPoll.  SP controls how often the
// SpawnManager wakes up.  This setting influences whether the SpawnManager
// does or does not attempt to spawn zeds when it wakes up (along with some
// other factors, like early wave modifiers, the presence of a leftover spawn
// squad, the map's baked in spawn interval modifier, and a sinewave mod that
// TWI probably thought would lend some kind of natural "rhythm" to the wave).
// Specifically, this goes into calculation of TimeUntilNextSpawn, which is a
// bit like SpawnManager marking its calendar with the soonest possible next
// spawntime.
var config string SpawnMod;
var config const array<string> SpawnModDefs;
var float SpawnModFloat;

// #### SpawnPoll
//
// The timer interval, in seconds, for CD's SpawnManager's update function.
// The update function first checks several state variables to determine
// whether to attempt to spawn more zeds.  If it determines that it should
// spawn zeds, the function then starts placing squads on spawner and/or
// spawnvolume entities.  In the unmodded game, this is hardcoded to one
// second.
var config string SpawnPoll;
var config const array<string> SpawnPollDefs; 
var float SpawnPollFloat;

// #### ZTSpawnMode
//
// Controls how the spawn manager does (or doesn't) react to zed time.
//
// "unmodded" makes it run as it does in the vanilla game.  This means that the
// spawn manager wakeup timer is destroyed every time zed time starts or is
// extended.  This can result in extremely long spawn lulls after zed time if
// SpawnPoll is long (e.g. 20 seconds).
//
// "clockwork" prevents the spawn manager wakeup timer from being destroyed
// every time zed time starts.  "clockwork" also applies ZTSpawnSlowdown to the
// spawn manager timer's dilation factor.  
var config string ZTSpawnMode;
var ECDZTSpawnMode ZTSpawnModeEnum;

// #### ZTSpawnSlowdown
//
// If ZTSpawnSlowdown is 1.0, then the timer is not dilated, which means that
// the spawn manager continues to wakeup every SpawnPoll (in real
// seconds).  This means zed time does not slow down or speed up spawns in real
// terms at all.
//
// When ZTSpawnSlowdown is greater than 1, the spawn manager wakeup timer is
// dilated to make it run that many times slower.
//
// For example, say ZTSpawnSlowdown is set to 2.0, SpawnPoll is set to
// 5.0, and SpawnMode is set to 0.  The spawn manager wakes up, spawns some
// zeds, and Zed Time starts one millisecond later.  Zed Time lasts 4 seconds.
// The spawn manager's next wakeup will occur about 9 seconds after its last:
// the spawn manager perceived 4 real seconds of zed time as only 2 seconds due
// to ZTSpawnSlowdown, and then 3 more seconds elapsed during normal time, for
// a total of 5 seconds.
var config string ZTSpawnSlowdown;
var config const array<string> ZTSpawnSlowdownDefs;
var float ZTSpawnSlowdownFloat;


//
// ### Zed Type and Spawn-Ordering Control
//

// #### AlbinoCrawlers
//
// Controls whether albino crawlers can spawn.
//
// See AlbinoAlphas for details about exactly how this works.
var config string AlbinoCrawlers;
var bool AlbinoCrawlersBool;

// #### AlbinoAlphas
//
// Controls whether albino alphas can spawn.
//
// true allows albino alphas to spawn normally. The meaning of "normally"
// depends on the SpawnCycle.  If SpawnCycle=unmodded, the albino alphas spawn
// by pure chance, the way TWI does it in vanilla KF2.  If SpawnCycle is not
// unmodded, then albino alphas will spawn according to the SpawnCycle.  If the
// configured SpawnCycle has no albino alphas, then none will spawn even if
// this option is set to true.
//
// false prevents albino alphas from spawning at all.  Even if the SpawnCycle
// mandates albino alphas, they will not spawn when this is false.
var config string AlbinoAlphas;
var bool AlbinoAlphasBool;

// #### AlbinoGorefasts
//
// Controls whether albino gorefasts can spawn.
//
// See AlbinoAlphas for details about exactly how this works.
var config string AlbinoGorefasts;
var bool AlbinoGorefastsBool;

// #### Boss
//
// Optionally controls which boss spawns, if and when the boss wave arrives.
//
// "hans" or "volter": forces the hans boss to spawn if/when the boss wave
// comes
//
// "pat", "patty", "patriarch": forces the patriarch boss to spawn if/when the
// boss wave comes
//
// "random" or "unmodded": choose a random boss when the time comes (unmodded
// game behavior)
var config string Boss;
var ECDBossChoice BossEnum;

// #### SpawnCycle
//
// Says whether to use a SpawnCycle (and if so, which one).
//
// "ini": read info about squads from config and use it to set spawn squads
//
// "unmodded": unmodded game behavior
//
// All other values are reserved for current and future preset names.  Type
// CDSpawnPresets to see available preset names.
var config string SpawnCycle;
var config array<string> SpawnCycleDefs;
var array<CD_AIWaveInfo> SpawnCycleWaveInfos;


//
// ### FakePlayers Settings
//

// #### FakePlayers
//
// Increase zed count (but not hp) as though this many additional players were
// present.  The game normally increases dosh rewards for each zed at
// numplayers >= 3, and faking players this way does the same.  You can always
// refrain from buying if you want an extra challenge, but if the mod denied
// you that bonus dosh, it could end up being gamebreaking for some runs.  In
// short, FakePlayers increases both your budget and the zed count in each
// wave.
//
// The name "FakePlayers" is something of a historical artifact at this point.
// This option might better be called "ExtraWaveSize" where the units are
// phantom players.
var config string FakePlayers; 
var config const array<string> FakePlayersDefs; 
var int FakePlayersInt;

// #### FakePlayersMode
//
// Controls how the values of the FakePlayers, BossFP, FleshpoundFP,
// ScrakeFP, and TrashFP settings interact with the human player count.
//
// If set to "add", then the values of various fake options are added to the
// human player count value.  For example, playing solo with FakePlayers=1,
// each wave will be sized as though two real humans were playing.
//
// If set to "replace", then only the value of a specific fake option is
// considered in its context, and the human player count value is ignored.  For
// example, playing solo with FakePlayers=2, each wave will be sized as though
// two real humans were playing.  If this is set to "replace" and any fake
// option is set to zero, then that option is treated as though it had been set
// to one instead.  
var config string FakePlayersMode;
var ECDFakePlayersMode FakePlayersModeEnum;

// #### BossFP
//
// The FakePlayers modifier applied when scaling boss head and body health.
//
// This is affected by FakePlayersMode.
var config string BossFP;
var config const array<string> BossFPDefs;
var int BossFPInt;

// #### FleshpoundFP
//
// The FakePlayers modifier applied when scaling fleshpound head and body
// health.
//
// This is affected by FakePlayersMode.
var config string FleshpoundFP;
var config const array<string> FleshpoundFPDefs;
var int FleshpoundFPInt;

// #### ScrakeFP
//
// The FakePlayers modifier applied when scaling scrake head and body health.
//
// This is affected by FakePlayersMode.
var config string ScrakeFP;
var config const array<string> ScrakeFPDefs;
var int ScrakeFPInt;

// #### TrashFP
//
// The FakePlayers modifier applied when scaling trash zed head and body
// health.  The trash HP scaling algorithm is a bit screwy compared to the
// other zed HP scaling algorithms, and this parameter only generally matters
// when the net count exceeds 6.
//
// "Trash" in this context means any zed that is not a boss, a scrake, or a
// fleshpound.
//
// This is affected by FakePlayersMode.
var config string TrashFP;
var config const array<string> TrashFPDefs;
var int TrashFPInt;


//
// ### Chat Command Authorization
//

// #### AuthorizedUsers
//
// Defines users always allowed to run any chat command.  This is an array
// option.  It can appear on as many lines as you wish.  This is only consulted
// when the game is running in server mode.  If the game is running in
// standalone mode ("solo"), then the player is always authorized to run any
// command, regardless of AuthorizedUsers.
//
// Each AuthorizedUsers line specifies a steamid (in STEAMID2 format) and a
// comment.  The comment can be whatever you like.  It's there just to make the
// list more manageable.  You might want to put the player's nickname in there
// and the date added, for example, but you can put anything in the comment
// field that you want.  CD does not read the comment.
//
// These two values are organized in a struct with the following form:
//
// ```
//   (SteamID="STEAM_0:0:1234567",Comment="Mr Elusive Jan 31 2017")
// ```
//
// There are many ways to find out a steamid.  Here's one tool that takes the
// name or URL of a steam account, then gives the ID for that account:
//
// ```
//   http://steamidfinder.com (not my website or affiliated with CD)
// ```
//
// On steamidfinder.com, you want to copy the field called "SteamID" into
// AuthorizedUsers.
//
// Here's an example that would authorize CD's author, blackout, and Gabe
// Newell.
//
// ```
//   [ControlledDifficulty.CD_Survival]
//   DefaultAuthLevel=CDAUTH_READ
//   AuthorizedUsers=(SteamID="STEAM_0:0:3691909",Comment="blackout")
//   AuthorizedUsers=(SteamID="STEAM_0:0:11101",Comment="gabe newell")
// ```
var config array<StructAuthorizedUsers> AuthorizedUsers;

// #### DefaultAuthLevel
//
// Controls the chat command authorization given to users who are connected to
// a server and whose SteamID is not in the AuthorizedUsers array.  For the
// rest of this section, we will call these users "anonymous users".
//
// "CDAUTH_READ" means that anonymous users can run any CD chat command that
// does not modify the configuration.  This lets players inspect the current
// configuration but not change it.
//
// "CDAUTH_WRITE" means that anonymous users can run any CD chat command.
// CDAUTH_WRITE effectively makes AuthorizedUsers superfluous, since there is
// no effective difference in chat command authority between AuthorizedUsers
// and anonymous users with CDAUTH_WRITE.
var config ECDAuthLevel DefaultAuthLevel;


//
// ### Miscellaneous Settings
//

// #### AlphaGlitter
//
// Controls the bright red particle effects that appear around zeds when an
// albino alpha clot rallies them (and himself).
//
// true to play the particle effects normally.  This makes alpha rallies look
// the same as in the vanilla game.
//
// false to disable the particle effects.  An albino alpha clot performing a
// rally will still play his little stomp animation, and a small distortion
// bubble will still appear around his body for a fraction of a second, but
// there will be no bright red particles.  This sometimes aids visibility.
//
// This option is strictly cosmetic.  It does not affect any of the behavior
// aspects of rallies (like damage multiplier, cooldown, movespeed multiplier,
// etc.).  So, even when this is set to false, rallies still happen as usual,
// it's just that it's easier to see them.
//
// This might become a client-side option one day if I can figure out how to do
// that nondisruptively.
var config string AlphaGlitter;
var bool AlphaGlitterBool;

// #### TraderTime
//
// The trader time, in seconds.  if this is zero or negative, its value is
// totally ignored, and the difficulty's standard trader time is used instead.
var config string TraderTime;
var int TraderTimeInt;

// #### WeaponTimeout
//
// Time, in seconds, that dropped weapons remain on the ground before
// disappearing.  This must be either a valid integer in string form, or the
// string "max".
//
// If set to a negative value, then the game's builtin default value is not
// modified.  At the time I wrote this comment, the game's default was 300
// seconds (5 minutes), but that could change; setting this to -1 will use
// whatever TWI chose as the default, even if they change the default in future
// patches.  If set to a positive value, it overrides the TWI default.  All
// dropped weapons will remain on the ground for as many seconds as this
// variable's value, regardless of whether the weapon was dropped by a dying
// player or a live player who pressed his dropweapon key.
//
// If set to zero, CD behaves as though it had been set to 1.
//
// If set to "max", the value 2^31 - 1 is used.
var config string WeaponTimeout;
var int WeaponTimeoutInt;

// #### ZedsTeleportCloser
//
// Controls whether zeds are allowed to teleport around the map in an effort to
// move them closer to human players.  This teleporting is unconditionally
// enabled in the vanilla game.
//
// true allows zeds to teleport in exactly the same way they do in the
// vanilla game.
//
// false prevents zeds from teleporting closer to players.  A zed can still
// teleport if it becomes convinced that it is stuck.  Furthermore, this option
// does not affect the way incoming zed squads or cohorts choose spawnpoints,
// which means that brand new zeds can still spawn around corners, surrounding
// doorways, etc as the team kites.  These "in-your-face" spawns can look quite
// a bit like zeds teleporting.  CD has no way to alter that "in-your-face"
// spawn behavior (yet).
var config string ZedsTeleportCloser;
var bool ZedsTeleportCloserBool;

// #### bLogControlledDifficulty
//
// true enables additional CD-specific logging output at runtime.  This option
// is one of the earliest added to CD, before a naming convention was established,
// and its unusual name is retained today for backwards-compatibility.
var config bool bLogControlledDifficulty;


////////////////////////////////////////////////////////////////
// Internal runtime state (no config options below this line) //
////////////////////////////////////////////////////////////////

var CD_DynamicSetting BossFPSetting;
var CD_DynamicSetting CohortSizeSetting;
var CD_DynamicSetting FakePlayersSetting;
var CD_DynamicSetting FleshpoundFPSetting;
var CD_DynamicSetting MaxMonstersSetting;
var CD_DynamicSetting SpawnPollSetting;
var CD_DynamicSetting ScrakeFPSetting;
var CD_DynamicSetting SpawnModSetting;
var CD_DynamicSetting TrashFPSetting;
var CD_DynamicSetting ZTSpawnSlowdownSetting;

var array<CD_DynamicSetting> DynamicSettings;

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

var const float SpawnPollEpsilon;

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
	SetupDynamicSettings();
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

/*
 * Sorts CD_Settings alphabetically by name.
 *
 * DO NOT mark the parameters "const out"!  The compiler will accept both
 * modifiers without so much as a warning, but the entire engine will crash to
 * bugsplat when attempting to call this via a dynamic array's
 * sort(<comparator>) function.  Unrealscript should not generally be able to
 * crash the entire engine in the first place, so I'm guessing this is an
 * engine, bytecode interpreter, or compiler bug (so it's conceivable, though
 * unlikely, that it could get fixed).
 */
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

private function SetupDynamicSettings()
{
	BossFPSetting = new(self) class'CD_DynamicSetting_BossFP';
	BossFPSetting.IniDefsArray = BossFPDefs;
	RegisterDynamicSetting( BossFPSetting );

	CohortSizeSetting = new(self) class'CD_DynamicSetting_CohortSize';
	CohortSizeSetting.IniDefsArray = CohortSizeDefs;
	RegisterDynamicSetting( CohortSizeSetting );

	FakePlayersSetting = new(self) class'CD_DynamicSetting_FakePlayers';
	FakePlayersSetting.IniDefsArray = FakePlayersDefs;
	RegisterDynamicSetting( FakePlayersSetting );

	MaxMonstersSetting = new(self) class'CD_DynamicSetting_MaxMonsters';
	MaxMonstersSetting.IniDefsArray = MaxMonstersDefs;
	RegisterDynamicSetting( MaxMonstersSetting );

	SpawnModSetting = new(self) class'CD_DynamicSetting_SpawnMod';
	SpawnModSetting.IniDefsArray = SpawnModDefs;
	RegisterDynamicSetting( SpawnModSetting );

	SpawnPollSetting = new(self) class'CD_DynamicSetting_SpawnPoll';
	SpawnPollSetting.IniDefsArray = SpawnPollDefs;
	RegisterDynamicSetting( SpawnPollSetting );

	ScrakeFPSetting = new(self) class'CD_DynamicSetting_ScrakeFP';
	ScrakeFPSetting.IniDefsArray = ScrakeFPDefs;
	RegisterDynamicSetting( ScrakeFPSetting );

	FleshpoundFPSetting = new(self) class'CD_DynamicSetting_FleshpoundFP';
	FleshpoundFPSetting.IniDefsArray = FleshpoundFPDefs;
	RegisterDynamicSetting( FleshpoundFPSetting );

	TrashFPSetting = new(self) class'CD_DynamicSetting_TrashFP';
	TrashFPSetting.IniDefsArray = TrashFPDefs;
	RegisterDynamicSetting( TrashFPSetting );

	ZTSpawnSlowdownSetting = new(self) class'CD_DynamicSetting_ZTSpawnSlowdown';
	ZTSpawnSlowdownSetting.IniDefsArray = ZTSpawnSlowdownDefs;
	RegisterDynamicSetting( ZTSpawnSlowdownSetting );
}

private function RegisterBasicSetting( const out CD_BasicSetting BasicSetting )
{
	BasicSettings.AddItem( BasicSetting );
	AllSettings.AddItem( BasicSetting );
}

private function RegisterDynamicSetting( const out CD_DynamicSetting DynamicSetting )
{
	DynamicSettings.AddItem( DynamicSetting );
	AllSettings.AddItem( DynamicSetting );
}

/*
 * We override CheckRelevance to do some mutator-style modifications to actors
 * as they spawn into the game.  This is useful for actors that have important
 * mutable state with defaults that are either immutable or inconvenient to
 * modify.
 */
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

/*
 * Set gameplay speed.  TWI's code calls this to implement zedtime.
 *
 * CD overrides it to apply SpawnPoll and ZTSpawnSlowdown.
 */
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

/*
 * Installs a timer that invokes SpawnManagerWakeup every SpawnPoll
 * seconds.  If the timer already exists and ForceReset is true, it is
 * destroyed and restarted from zero.  If the timer already exists and
 * ForceReset is false, nothing happens.
 */
function SetSpawnManagerTimer( const optional bool ForceReset = true )
{
	if ( ForceReset || !IsTimerActive('SpawnManagerWakeup') )
	{
		// Timer does not exist, set it
		`cdlog("Setting independent SpawnManagerWakeup timer (" $ SpawnPollFloat $")", bLogControlledDifficulty);
		SetTimer(SpawnPollFloat, true, 'SpawnManagerWakeup');
	}
}

/*
 * During zedtime, modify the SpawnManager timer's TimeDilation factor so that
 * it runs ZTSpawnSlowdown times slower than realtime.  At the extreme, when
 * ZTSpawnSlowdown is 1, then this function calculates a TimeDilation factor
 * that cancels out the effect of zed time on the SpawnManager.
 *
 * This is only called when ZTSpawnMode is CLOCKWORK.
 */
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

		`cdlog("SpawnManagerWakeup's slowed clockwork timedilation: " $ LocalDilation $ " (ZTSS=" $ SlowDivisor $ ")", bLogControlledDifficulty);
	}
	else
	{
		`cdlog("SpawnManagerWakeup's realtime clockwork timedilation: " $ LocalDilation, bLogControlledDifficulty);
	}

	ModifyTimerTimeDilation('SpawnManagerWakeup', LocalDilation);
}

/*
 * We override this function to keep it from calling SpawnManager.Update().  CD
 * does that separately through the SpawnManagerWakeup() function.  This
 * separation supports the SpawnPoll setting.
 */
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

/*
 * Extended from TWI.  Called when the entire game ends (wipe or bosskill).
 *
 * CD overrides it to echo the post-wave recap in chat on wipes.
 */
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

	DoshMod = GetEffectivePlayerCount( LocalNumPlayers ) / LocalMaxAIMod;

	ModifiedValue *= DoshMod;

	`cdlog("DoshCalc: ModifiedValue="$ ModifiedValue $" FakePlayers="$ FakePlayersInt $" FakePlayersMode="$ FakePlayersMode $
	       " RealPlayers="$ LocalNumPlayers $" computed MaxAIDoshDenominator="$ LocalMaxAIMod, bLogControlledDifficulty);
}

/*
 * Get param + FakePlayers (not BossFP, FleshpoundFP, or any other *FP value).
 * This automatically accounts for FakePlayersMode.  If FPM_REPLACE is
 * active and FakePlayersInt is 0, then this method returns 1.
 */
final function int GetEffectivePlayerCount( int HumanPlayers )
{
	if ( FakePlayersModeEnum == FPM_ADD )
	{
		return FakePlayersInt + HumanPlayers;
	}
	else
	{
		return 0 < FakePlayersInt ? FakePlayersInt : 1;
	}
}

/*
 * Configure CD_SpawnManager (particularly MaxMonsters and SpawnCycle)
 */ 
function InitSpawnManager()
{
	super.InitSpawnManager();

	if ( SpawnManager.IsA( 'CD_SpawnManager' ) )
	{
		`cdlog("Checked that SpawnManager "$SpawnManager$" is an instance of CD_SpawnManager (OK)", bLogControlledDifficulty);
	}
	else
	{
		GameInfo_CDCP.Print("WARNING: SpawnManager "$SpawnManager$" appears to be misconfigured! CD might not work correctly.");
	}
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

/*
 * Extended from engine/TWI.  CD overrides it to look for chat commands.
 */
event Broadcast(Actor Sender, coerce string Msg, optional name Type)
{
	super.Broadcast(Sender, Msg, Type);

	if ( Type == 'Say' )
	{
		ChatCommander.RunCDChatCommandIfAuthorized( Sender, Msg );
	}
}

/*
 * Send a CDEcho message to all players.  These messages are not
 * length-restricted like ordinary chat messages, but they may be suppressed
 * from the chat window and shown only in the client's console side, depending
 * on that client's configuration.
 */
function BroadcastCDEcho( coerce string Msg )
{
        local PlayerController P;

	// Skip the AllowsBroadcast check
        
        foreach WorldInfo.AllControllers(class'PlayerController', P)
        {
                BroadcastHandler.BroadcastText( None, P, Msg, 'CDEcho' );
        }
}

/*
 * Extended from TWI.  Called on transition from wave to tradertime.
 *
 * CD overrides to apply any setting changes that might have been staged using
 * chat commands during the wave.
 */
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
	// This synchronizing effect is virtually unnoticeable when SpawnPoll is
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
	BroadcastCDEcho( "[Controlled Difficulty - "$ `CD_BUILD_TYPE $" \""$ `CD_COMMIT_HASH $"\"]\n" $ ChatCommander.GetCDInfoChatString( "brief" ) );
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

function ECDAuthLevel GetAuthorizationLevelForUser( Actor Sender )
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
	local ECDWaveInfoStatus wis;

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
			AssumedPlayerCount = GetEffectivePlayerCount( 1 );
			GameInfo_CDCP.Print( "Projecting wave summaries for "$AssumedPlayerCount$" player(s) in current game length...", false );
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
	local ECDWaveInfoStatus wis;

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
	local ECDWaveInfoStatus wis;

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

function ECDWaveInfoStatus GetWaveInfosForConsoleCommand( string CycleName, out array<CD_AIWaveInfo> WaveInfos )
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
	SpawnPollEpsilon=0.0001
	ZTSpawnSlowdownEpsilon=0.0001
}
