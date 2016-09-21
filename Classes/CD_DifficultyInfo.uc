//=============================================================================
// CD_DifficultyInfo
//=============================================================================
// Supports "faked" players that increase zed count and dosh but not 
// zed health or zed head health
//=============================================================================

class CD_DifficultyInfo extends KFGameDifficulty_Survival
	within CD_Survival;

/** Returns adjusted total num AI modifier for this wave's player num */
// This is invoked by the base game.
function float GetPlayerNumMaxAIModifier( byte NumLivingPlayers )
{
	local int sum;
	local int fp;

	fp = GetNumFakePlayers();

	sum = NumLivingPlayers + fp;

	`log("Adding ControlledDifficulty FakePlayers = "$fp$" to NumLivingPlayers = "$NumLivingPlayers$" in GetPlayerNumAIMaxModifier", bLogControlledDifficulty);
	`log("Final GetPlayerNumMaxAIModifier = "$sum, bLogControlledDifficulty);
	
	if ( 6 < sum )
	{
		// FakePlayers is clamped onto [0,5] in CD_Survival, so it this condition should be
		// impossible in solo play, but put a log message in anyway, in case someone tries to
		// run this on a multiplayer server.
		// This (intentionally) does not respect bLogControlledDifficulty.
		`log("WARNING: FakePlayers ("$fp$") + NumLivingPlayers ("$NumLivingPlayers$") is greater than 6! This is more players than KF2 normally supports. Keeping this sum at or below 6 is recommended.");
	}

	return GetNumPlayersModifier( NumPlayers_WaveSize, sum );
}

/** Get the custom trader time, or the difficulty's default TT if no custom TT is set */
// This is invoked by the base game.
function float GetTraderTimeByDifficulty()
{
	local int tt;

	tt = GetTraderTime();

	if ( 0 < tt )
	{
		return tt;
	}

	return super.GetTraderTimeByDifficulty();
}

// configuration getter
function int GetNumFakePlayers()
{
	return Outer.FakePlayers;
}

// configuration getter
function float GetTraderTime()
{
	return Outer.TraderTime;
}
