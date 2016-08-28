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

var CD_DifficultyInfo CustomDifficultyInfo;

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

function InitGameConductor()
{
	local CD_DummyGameConductor customConductor;
	super.InitGameConductor();
	// the preceding call should have initialized GameConductor
	customConductor = CD_DummyGameConductor(GameConductor);
	customConductor.SetSpawnMod( SpawnMod );
	GameConductor = customConductor;
	`log("Finished instantiating and configuring CD_DummyGameConductor", bLogControlledDifficulty);
}

function CreateDifficultyInfo(string Options)
{
	super.CreateDifficultyInfo(Options);
	// the preceding call should have initialized DifficultyInfo
	CustomDifficultyInfo = CD_DifficultyInfo(DifficultyInfo);
	CustomDifficultyInfo.SetFakePlayers( FakePlayers );
	CustomDifficultyInfo.SetTraderTime( TraderTime );
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

exec function logControlledDifficulty( bool enabled )
{
	bLogControlledDifficulty = enabled;
	`log("Set bLogControlledDifficulty = "$bLogControlledDifficulty);
	SaveConfig();
}

defaultproperties
{
	GameConductorClass=class'ControlledDifficulty.CD_DummyGameConductor'
	DifficultyInfoClass=class'ControlledDifficulty.CD_DifficultyInfo'
}
