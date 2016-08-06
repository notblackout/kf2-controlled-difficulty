//=============================================================================
// CD_DifficultyInfo
//=============================================================================
// Supports "faked" players that increase zed count and dosh but not 
// zed health or zed head health
//=============================================================================

class CD_DifficultyInfo extends KFDifficultyInfo within CD_Survival;

// increase zed count (but not hp) as though this many additional players were
// present; note that the game normally increases dosh rewards for each zed at
// numplayers >= 3, and faking players this way does the same; you can always
// refrain from buying if you want an extra challenge, but if the mod denied
// you that bonus dosh, it could end up being gamebreaking for some runs
var int FakePlayers; 

// I initially made FakePlayers a config variable and annotated this class with
// the "config(Game)" modifier, but for reasons I never figured out, this
// variable was neither read from nor saved to KFGame.ini, whereas CD_Survival
// inherits similar annotations and works perfectly with KFGame.ini.  I never
// got to the bottom of that problem.  I just moved this config option into
// CD_Survival as a workaround.  Similar story for the other config options
// that follow FakePlayers -- they might logically belong here, but I resorted
// to putting them in CD_Survival because I couldn't get config file save/load
// to work otherwise.

// if this is positive, then it overrides the normal trader time for the
// configured difficulty.  if nonpositive, it is totally ignored, and the
// difficulty's standard trader time is used instead.
var int TraderTime;

/** Returns adjusted total num AI modifier for this wave's player num */
function float GetPlayerNumMaxAIModifier( byte NumLivingPlayers )
{
	local int sum;

	sum = NumLivingPlayers + FakePlayers;

	`log("Adding ControlledDifficulty FakePlayers = "$FakePlayers$" to NumLivingPlayers = "$NumLivingPlayers$" in GetPlayerNumAIMaxModifier", Outer.bLogControlledDifficulty);
	`log("Final GetPlayerNumMaxAIModifier = "$sum, Outer.bLogControlledDifficulty);
	
	if ( 6 < sum )
	{
		// This does not respect Outer.bLogControlledDifficulty (intentionally)
		`log("WARNING: FakePlayers ("$FakePlayers$") + NumLivingPlayers ("$NumLivingPlayers$") is greater than 6! This is more players than the vanilla game supports. Keeping this sum at or below 6 is recommended.");
	}

	return GetNumPlayersModifier( NumPlayers_WaveSize, sum );
}

/** Get the custom trader time, or the difficulty's default TT if no custom TT is set */
function float GetTraderTimeByDifficulty()
{
	if ( 0 < TraderTime )
	{
		return TraderTime;
	}

	return super.GetTraderTimeByDifficulty();
}

function SetFakePlayers( int fpc )
{
	FakePlayers = fpc;
	`log("Set FakePlayers = "$FakePlayers, Outer.bLogControlledDifficulty);
}

function SetTraderTime( int tt )
{
	TraderTime = tt;
	`log("Set TraderTime = "$TraderTime, Outer.bLogControlledDifficulty);
}
