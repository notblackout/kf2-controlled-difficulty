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

	`cdlog("MaxAI: Adding FakePlayers = "$fp$" to NumLivingPlayers = "$NumLivingPlayers$" in GetPlayerNumAIMaxModifier", bLogControlledDifficulty);
	`cdlog("Final GetPlayerNumMaxAIModifier = "$sum, bLogControlledDifficulty);
	
	return GetNumPlayersModifier( NumPlayers_WaveSize, sum );
}

/** Scales the health this Zed has by the difficulty level */
// This is invoked by the base game.
function GetAIHealthModifier(KFPawn_Monster P, float ForGameDifficulty, byte NumLivingPlayers, out float HealthMod, out float HeadHealthMod, optional bool bApplyDifficultyScaling=true)
{
	local byte EffectiveNumPlayers;
	local int FPBonus;

	if ( P != none )
	{
		// Global mod * character mod
		if( bApplyDifficultyScaling )
		{
	    	HealthMod = GetGlobalHealthMod() * GetCharHealthModDifficulty(P, ForGameDifficulty);
			HeadHealthMod = GetGlobalHealthMod() * GetCharHeadHealthModDifficulty(P, ForGameDifficulty);
		}

		// invalid scaling?
		if ( HealthMod <= 0 )
		{
			HealthMod = 1.f;
			if( HeadHealthMod <= 0 )
			{
                HeadHealthMod = 1.f;
            }
			return;
		}

		if ( None != KFPawn_MonsterBoss( P ) )
		{
			FPBonus = Outer.BossFPInt;
		}
		else if ( None != KFPawn_ZedFleshpound( P ) )
		{
			FPBonus = Outer.FleshpoundFPInt;
		}
		else if ( None != KFPawn_ZedScrake( P ) )
		{
			FPBonus = Outer.ScrakeFPInt;
		}
		else
		{
			FPBonus = Outer.TrashFPInt;
		}

		EffectiveNumPlayers = NumLivingPlayers + FPBonus;

		HealthMod *= 1.0 + GetNumPlayersHealthMod( EffectiveNumPlayers, P.DifficultySettings.default.NumPlayersScale_BodyHealth );
		HeadHealthMod *= 1.0 + GetNumPlayersHealthMod( EffectiveNumPlayers, P.DifficultySettings.default.NumPlayersScale_HeadHealth );

		`cdlog("HealthMod="$ HealthMod $" for "$ P $" (NumLivingPlayers="$ NumLivingPlayers $" Fake="$ FPBonus $")", bLogControlledDifficulty);
	}
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
