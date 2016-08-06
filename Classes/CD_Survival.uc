//=============================================================================
// ControlledDifficulty_Survival
//=============================================================================
// Survival with less bullshit
//=============================================================================

class CD_Survival extends KFGameInfo_Survival;

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
// 1.0 is KFGameConductor's "at rest" or player-friendliest state.
// 0.75 is KFGameConductor's "raged" or player-hostile state.
// Below 0.75 is spawn intensity unseen in the vanilla game.
var config float SpawnMod;

// true to log some internal state specific to this mod
var config bool bLogControlledDifficulty;

event InitGame( string Options, out string ErrorMessage )
{
	local int FakePlayersFromGameOptions;
	local int TraderTimeFromGameOptions;
	local float SpawnModFromGameOptions;

 	Super.InitGame( Options, ErrorMessage );

	FakePlayersFromGameOptions = GetIntOption( Options, "FakePlayers", -1 );
	TraderTimeFromGameOptions = GetIntOption( Options, "TraderTime", -1 );
	SpawnModFromGameOptions = GetFloatOption( Options, "SpawnMod", 1.f );
	`log("FakePlayersFromGameOptions = "$FakePlayersFromGameOptions$" (-1=missing)", bLogControlledDifficulty);
	`log("TraderTimeFromGameOptions = "$TraderTimeFromGameOptions$" (-1=missing)", bLogControlledDifficulty);
	`log("SpawnModFromGameOptions = "$SpawnModFromGameOptions$" (1.0=default)", bLogControlledDifficulty);

	if (0 <= FakePlayersFromGameOptions)
	{
		FakePlayers = FakePlayersFromGameOptions;
	}

	if (0 < TraderTimeFromGameOptions)
	{
		TraderTime = TraderTimeFromGameOptions;
	}

	if (0.f < SpawnModFromGameOptions)
	{
		SpawnMod = SpawnModFromGameOptions;
	}

	FakePlayers = Clamp(FakePlayers, 0, 5);
	// TT is not clamped
	SpawnMod = FClamp(SpawnMod, 0.f, 1.f);
	`log("FClamped SpawnMod = "$SpawnMod, bLogControlledDifficulty);

	SaveConfig();
}

event PreBeginPlay()
{
	local CD_DifficultyInfo customDifficulty;
	local CD_DummyGameConductor customConductor;

	WorldInfo.TWApplyTweaks();

	super.PreBeginPlay();

	customDifficulty = new(self) class'CD_DifficultyInfo'(DifficultyTemplate);
	customDifficulty.SetFakePlayers( FakePlayers );
	customDifficulty.SetTraderTime( TraderTime );
        DifficultyInfo = customDifficulty;
	DifficultyInfo.SetDifficultySettings( GameDifficulty );
	`log("Instantiated and configured CD_DifficultyInfo = "$customDifficulty, bLogControlledDifficulty);

	MyKFGRI = KFGameReplicationInfo(GameReplicationInfo);
	InitGRIVariables();

	CreateTeam(0);
	InitGameConductor();

	customConductor = CD_DummyGameConductor(GameConductor);
	customConductor.SetSpawnMod( SpawnMod );

	InitAIDirector();
	InitTraderList();
	ReplicateWelcomeScreen();

	WorldInfo.TWLogsInit();

	InitSpawnManager();
	UpdateGameSettings();
}

exec function logControlledDifficulty( bool enabled )
{
	bLogControlledDifficulty = enabled;
	`log("Set bLogControlledDifficulty = "$bLogControlledDifficulty);
	SaveConfig();
}

defaultproperties
{
	GameConductorClass=class'ControlledDifficulty.CD_DummyGameConductor'
}
