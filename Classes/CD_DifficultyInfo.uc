//=============================================================================
// CD_DifficultyInfo
//=============================================================================
// Supports "faked" players that increase zed count and dosh but not 
// zed health or zed head health
//=============================================================================

class CD_DifficultyInfo extends KFGameDifficulty_Survival
	within CD_Survival;

`include(CD_Log.uci)

/** Returns adjusted total num AI modifier for this wave's player num */
// This is invoked by the base game.
function float GetPlayerNumMaxAIModifier( byte NumLivingPlayers )
{
	local int sum;
	local int fp;

	fp = GetNumFakePlayers();

	sum = NumLivingPlayers + fp;

	`cdlog("Adding ControlledDifficulty FakePlayers = "$fp$" to NumLivingPlayers = "$NumLivingPlayers$" in GetPlayerNumAIMaxModifier", bLogControlledDifficulty);
	`cdlog("Final GetPlayerNumMaxAIModifier = "$sum, bLogControlledDifficulty);
	
	return GetNumPlayersModifier( NumPlayers_WaveSize, sum );
}

function float GetRawPlayerNumMaxAIModifier( byte TotalPlayers )
{
	return GetNumPlayersModifier( NumPlayers_WaveSize, TotalPlayers );
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
	return Outer.FakePlayersInt;
}

// configuration getter
function float GetTraderTime()
{
	return Outer.TraderTime;
}
