//=============================================================================
// ControlledDifficulty_Survival
//=============================================================================
// Survival with less bullshit
//=============================================================================

class CD_Survival extends KFGameInfo_Survival;

`include(CD_BuildInfo.uci)

struct StructSquadParserState
{
	// all indexes are zero-based
	var int WaveIndex;
	var int SquadIndex;
	var int ElemIndex;

	var bool ParseError;

	structdefaultproperties
	{
		ParseError=false
	}
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

// true to log some internal state specific to this mod
var config bool bLogControlledDifficulty;

// "ini": read info about squads from config and use it to set spawn squads
// "unmodded": unmodded game behavior
// all other values are reserved for potential future preset names
var config string SquadSchedule;
var config array<string> SquadScheduleDefs;
var StructSquadParserState SquadParserState;

// "hans" or "volter": forces the hans boss wave
// "pat", "patty", "patriarch": forces the patriarch boss wave
// else: choose a random boss wave (unmodded game behavior)
var config string Boss;

var CD_DifficultyInfo CustomDifficultyInfo;

var array<CD_AIWaveInfo> CustomWaveInfos;

event InitGame( string Options, out string ErrorMessage )
{
	local float SpawnModFromGameOptions;
	local float SpawnModBeforeClamping;
	local int MaxMonstersFromGameOptions;
	local bool AlbinoCrawlersFromGameOptions;
	local string SquadScheduleFromGameOptions;
	local string BossFromGameOptions;

 	Super.InitGame( Options, ErrorMessage );

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

	if ( HasOption(Options, "SquadSchedule") )
	{
		SquadScheduleFromGameOptions = ParseOption(Options, "SquadSchedule" );
		`log("SquadScheduleFromGameOptions = "$SquadScheduleFromGameOptions, bLogControlledDifficulty);
		SquadSchedule = SquadScheduleFromGameOptions;
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
		Boss = "random";
	}
	if ( !isRandomBossString(Boss) && !isPatriarchBossString(Boss) && !isVolterBossString(Boss) )
	{
		CDConsolePrint("WARNING invalid Boss setting \""$Boss$"\".  Valid settings for this option: patriarch, hans, random.  Setting Boss = random.");
	}

	SaveConfig();
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

function array<CD_AIWaveInfo> ParseFullSquadSchedule( array<string> fullRawSchedule )
{
	local array<CD_AIWaveInfo> WaveInfosFromConfig;

	for ( SquadParserState.WaveIndex = 0; SquadParserState.WaveIndex < fullRawSchedule.length; SquadParserState.WaveIndex++ )
	{
		`log("Attempting to parse wave "$(SquadParserState.WaveIndex + 1)$"...");
		WaveInfosFromConfig.AddItem( ParseSquadScheduleDef( fullRawSchedule[SquadParserState.WaveIndex] ) );
	}

	return WaveInfosFromConfig;
}

function CD_AIWaveInfo ParseSquadScheduleDef( string rawSchedule )
{
	local array<string> SquadDefs;
	local array<string> ElemDefs;
	local CD_AIWaveInfo CurWaveInfo;
	local CD_AISpawnSquad CurSquad;
	local AISquadElement CurElement;

	CurWaveInfo = new class'ControlledDifficulty.CD_AIWaveInfo';

	// Split on , and drop empty elements
	SquadDefs = SplitString( rawSchedule, ",", true );

	// Iterate through the squads
	for ( SquadParserState.SquadIndex = 0; SquadParserState.SquadIndex < SquadDefs.length; SquadParserState.SquadIndex++ )
	{
		CurSquad = new class'ControlledDifficulty.CD_AISpawnSquad';

		// Squads may in general be heterogeneous, e.g.
		// 2Cyst_3Crawler_2Gorefast_2Siren
		//
		// But specific squads may be homogeneous, e.g. 
		// 6Crawler
		//
		// In the following code, we split on _ and loop through
		// each element, populating a CD_AISpawnSquad as we go.
		ElemDefs = SplitString( SquadDefs[SquadParserState.SquadIndex], "_", true );

		for ( SquadParserState.ElemIndex = 0; SquadParserState.ElemIndex < ElemDefs.length; SquadParserState.ElemIndex++ )
		{
			if ( !ParseSquadElement( ElemDefs[SquadParserState.ElemIndex], CurElement ) )
			{
				continue; // Parse error in that element
			}

			`log("[squad#"$SquadParserState.SquadIndex$"] Parsed squad element: "$CurElement.Num$"x"$CurElement.Type);

			CurSquad.AddSquadElement( CurElement );
		}

		// TODO configure MinVolumeType on this completed squad

		CurWaveInfo.CustomSquads.AddItem(CurSquad);
	}

	return CurWaveInfo;
}

function bool ParseSquadElement( const out String ElemDef, out AISquadElement SquadElement )
{
	local int ElemStrLen, UnicodePoint, ElemCount, i;
	local string ElemType;
	local EAIType ElemEAIType;

	ElemStrLen = Len( ElemDef );

	// Locate the first index into ElemDef where the count
	// of zeds in the element ends and the type of zed should begin
	for ( i = 0; i < ElemStrLen; i++ )
	{
		// Get unicode codepoint (as int) for char at index i
		UnicodePoint = Asc( Mid( ElemDef, i, 1 ) );

		// Check for low ascii numerals [0-9]
		if ( !( 48 <= UnicodePoint && UnicodePoint <= 57 ) )
		{
			break; // not a numeral
		}
	}

	// The index must not be at the very beginning or end of the string.
	// If that's true, then we can assume it was malformed.
	if ( i <= 0 || i >= ElemStrLen )
	{
		// TODO issue warning about this element
		return CDConsolePrintSquadParseError("Spawn element \"$ElemDef$\" could not be parsed.");
	}

	// Cut string in two at index i. Left is the count as a stringified int.
	// Right is supposed to be the type of zed as a string.  We know the left
	// part is a well-formed int-as-string because of the unicode codepoint
	// loop check that we did earlier, and because 0 < i.  We don't know
	// whether the zed name type on the right is valid (must check later).
	ElemCount = int( Mid( ElemDef, 0, i ) );
	ElemType  = Mid( ElemDef, i, ElemStrLen - i );

	// Check value range for ElemCount
	if ( ElemCount <= 0 )
	{
		// TODO issue warning about this element having quantity zero/neg
		return CDConsolePrintSquadParseError("Element count \"$ElemCount$\" is not positive.  Must be between 1 and 6 (inclusive).");
	}
	if ( ElemCount > 6 )
	{
		// TODO issue warning about this element having too many zeds
		return CDConsolePrintSquadParseError("Element count \"$ElemCount$\" is too large.  Must be between 1 and 6 (inclusive).");
	}

	// Convert user-provided zed type name into a zed type enum
	ElemEAIType = GetZedType( ElemType );

	// Was it a valid zed type name?
	if ( 255 == ElemEAIType )
	{
		// TODO issue warning about invalid elem class
		return CDConsolePrintSquadParseError("\""$ElemType$"\" does not appear to be a zed name."$
		              "  Must be a zed name or abbreviation like cyst, fp, etc.");
	}

	SquadElement.Type = ElemEAIType;
	SquadElement.Num = ElemCount;
	SquadElement.CustomClass = none;

	return true;
}

function bool CDConsolePrintSquadParseError( const string message )
{
	SquadParserState.ParseError = true;

	CDConsolePrint("WARNING Parse error in squad definition at location: \n" $
	               "      WaveNumber: " $ string(SquadParserState.WaveIndex + 1) $ " (SquadScheduleDefs, one-based)\n" $
                       "      SquadNumber: " $ string(SquadParserState.SquadIndex + 1) $ " (comma-separated element in the line, one-based)\n" $
                       "      ElementNumber: " $ string(SquadParserState.ElemIndex + 1) $ " (underscore-separated element in the squad, one-based)\n" $
	               "   >> Message: "$ message);
	return false;
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
				killerPawnClass = CheckClassRemap( Killer.Pawn.Class, "CD_Survival.BroadcastDeathMessage" );
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

static function class CheckClassRemap( const class OrigClass, const string InstigatorName )
{
	local class<KFPawn_Monster> MonsterClass;

	if ( ClassIsChildOf( OrigClass, class'KFPawn_Monster' ) )
	{
		MonsterClass = class<KFPawn_Monster>( OrigClass );
		return CheckMonsterClassRemap( MonsterClass, InstigatorName );
	}

	`log("Letting non-monster class "$OrigClass$" stand via "$InstigatorName );
	return OrigClass;
}

static function class<Pawn> CheckPawnClassRemap( const class<Pawn> OrigClass, const string InstigatorName )
{
	local class<KFPawn_Monster> MonsterClass;

	if ( ClassIsChildOf( OrigClass, class'KFPawn_Monster' ) )
	{
		MonsterClass = class<KFPawn_Monster>( OrigClass );
		return CheckMonsterClassRemap( MonsterClass, InstigatorName );
	}

	`log("Letting non-monster class "$OrigClass$" stand via "$InstigatorName );
	return OrigClass;
}

static function class<KFPawn_Monster> CheckMonsterClassRemap( const class<KFPawn_Monster> OrigClass, const string InstigatorName )
{
	local class<KFPawn_Monster> NewClass;

	NewClass = OrigClass;

	// This really should be an associative array, but unrealscript is kind of barbaric
	if ( OrigClass == class'CD_Pawn_ZedCrawler_Special' || 
	     OrigClass == class'CD_Pawn_ZedCrawler_Regular' )
	{
		NewClass = class'KFPawn_ZedCrawler';
	}
	else if ( OrigClass == class'CD_Pawn_ZedClot_Alpha_Special' ||
	          OrigClass == class'CD_Pawn_ZedClot_Alpha_Regular' )
	{
		NewClass = class'KFPawn_ZedClot_Alpha';
	}

	// Log what we just did
	if ( OrigClass != NewClass )
	{
		`log("Masked monster class "$OrigClass$" with substitute class "$NewClass$" via "$InstigatorName );
	}
	else
	{
		`log("Letting monster class "$OrigClass$" stand via "$InstigatorName );
	}

	return NewClass;
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

	CDConsolePrint( "AlbinoCrawlers="$AlbinoCrawlers );

	CDConsolePrint( "Boss="$Boss );

	if ( SquadSchedule == "ini" )
	{
		`log("Forcing a config reload because SquadSchedule="$SquadSchedule$"...");
		//ConsoleCommand("reloadcfg ControlledDifficulty.CD_Survival", true);
		//ReloadConfig();

		`log("Attempting to parse squad information in config...");
		CustomWaveInfos = ParseFullSquadSchedule( SquadScheduleDefs );

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
			CDConsolePrint("WARNING Config defines "$CustomWaveInfos.length$" waves, but there are only "$ExpectedWaveCount$" waves in this GameLength.");
			CDConsolePrint("WARNING Setting SquadSchedule=unmodded for this session because of ini-GameLength wave count mismatch.");
			SquadSchedule = "unmodded";
			SquadParserState.ParseError = true;
		}

		if ( !SquadParserState.ParseError )
		{
			cdsm.SetCustomWaves( CustomWaveInfos );
		}
	}
	else
	{
		`log("Not reading squad information from config (value="$SquadSchedule$")");
	}

	CDConsolePrint( "SquadSchedule="$SquadSchedule );
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

function CDConsolePrintSpawnDetails( string Verbosity )
{
	local int WaveIndex, SquadIndex, ElemIndex;
	local string s;
	local CD_AIWaveInfo wi;
	local CD_AISpawnSquad ss;
	local array<string> SquadList;
	local array<string> ElemList;
	local string ZedNameTmp;

	for ( WaveIndex = 0; WaveIndex < CustomWaveInfos.length; WaveIndex++ )
	{
		wi = CustomWaveInfos[WaveIndex];
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
		CDConsolePrint( "["$GetShortWaveName( WaveIndex )$"] "$s, false );
	}
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

	for ( WaveIndex = 0; WaveIndex < CustomWaveInfos.length; WaveIndex++ )
	{
		wi = CustomWaveInfos[WaveIndex];

		WaveSummaryString = "";

		WaveSummary = new class'CD_WaveSummary';

		GetCDWaveSummary( wi, WaveIndex, PlayerCount, WaveSummary );
		GameSummary.AddParamToSelf( WaveSummary );
		WaveSummaryString = WaveSummary.GetString();

		CDConsolePrint( "["$GetShortWaveName( WaveIndex )$"] "$WaveSummaryString, false );
	}

	CDConsolePrint( " >> Projected Game Totals:", false );
	CDConsolePrint( "         "$GameSummary.GetString(), false );
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

/**
    Get a zed EAIType from the name.

    This is based on the LoadMonsterByName from KFCheatManager, but I have a separate copy here
    for several reasons:
    0. I need EAIType instead of a class, and there does not seem to be an easy way to convert those
    1. To allow for a few more abbreviations than KFCheatManager knows (e.g. for clots: CC, CA, CS)
    2. To accept a slightly smaller universe of legal input strings, so that the effective API
       created by this function is as small as possible.
    3. So that a hypothetical future KF2 update that might change KFCheatManager's zed abbreviations
       will not change the behavior of this method, which is used to parse wave squad schedules and
       generally represents a public API that must not change.
    5. I have no need for the "friendly-to-player" zed AI names here, and I want to accept the absolute
       minimum universe of correct inputs, so that this is easy to maintain.  Same for "TestHusk".
*/

static function EAIType GetZedType( string ZedName )
{
	local int ZedLen;

	ZedName = Caps( ZedName );
	ZedLen = Len( ZedName );
	
	if ( ZedName == "CLOTA" || ZedName == "CA" || (2 <= ZedLen && ZedLen <= 5 && ZedName == Left("ALPHA", ZedLen)) )
	{
		return AT_AlphaClot;
	}
	else if ( ZedName == "CLOTS" || ZedName == "CS" || (2 <= ZedLen && ZedLen <= 7 && ZedName == Left("SLASHER", ZedLen)) )
	{
		return AT_SlasherClot;
	}
	else if ( ZedName == "CLOTC" || ZedName == "CC" || (2 <= ZedLen && ZedLen <= 4 && ZedName == Left("CYST", ZedLen)) )
	{
		return AT_Clot;
	}
	else if ( ZedName == "FP" || (1 <= ZedLen && ZedLen <= 10 && ZedName == Left("FLESHPOUND", ZedLen)) )
	{
		return AT_FleshPound;
	}
	else if ( ZedName == "G" || ZedName == "GF" || (1 <= ZedLen && ZedLen <= 8 && ZedName == Left("GOREFAST", ZedLen)) ) // DG(F) / DoubleGorefast reserved
	{
		return AT_GoreFast;
	}
	else if ( 2 <= ZedLen && ZedLen <= 7 && ZedName == Left("STALKER", ZedLen) )
	{
		return AT_Stalker;
	}
	else if ( 1 <= ZedLen && ZedLen <= 5 && ZedName == Left("BLOAT", ZedLen) )
	{
		return AT_Bloat;
	}
	else if ( 2 <= ZedLen && ZedLen <= 6 && ZedName == Left("SCRAKE", ZedLen) )
	{
		return AT_Scrake;
	}
	else if ( 2 <= ZedLen && ZedLen <= 7 && ZedName == Left("CRAWLER", ZedLen) )
	{
		return AT_Crawler;
	}
	else if ( 1 <= ZedLen && ZedLen <= 4 && ZedName == Left("HUSK", ZedLen) )
	{
		return AT_Husk;
	}
	else if ( 2 <= ZedLen && ZedLen <= 5 && ZedName == Left("SIREN", ZedLen) )
	{
		return AT_Siren;
	}

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

	return "";
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

	return "";
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

	return "";
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
