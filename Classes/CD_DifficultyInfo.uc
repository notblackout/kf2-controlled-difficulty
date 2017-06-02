//=============================================================================
// CD_DifficultyInfo
//=============================================================================
// Supports "faked" players that increase zed count and dosh but not 
// zed health or zed head health
//=============================================================================

class CD_DifficultyInfo extends KFGameDifficulty_Survival
	within CD_Survival
	DependsOn( CD_Survival );

`include(CD_Log.uci)

/** Returns adjusted total num AI modifier for this wave's player num */
// This is invoked by the base game.
function float GetPlayerNumMaxAIModifier( byte NumLivingPlayers )
{
	local int Result;

	if ( FakePlayersModeEnum == FPM_ADD )
	{
		Result = NumLivingPlayers + Outer.FakePlayersInt;
		`cdlog("GetPlayerNumAIMaxModifier: using count "$ Result $": added FakePlayers="$ Outer.FakePlayersInt $" to NumLivingPlayers="$ NumLivingPlayers, bLogControlledDifficulty);
	}
	else
	{
		Result = Outer.FakePlayersInt;
		if ( 0 >= Result )
		{
			`cdlog("FakePlayers="$ Result $" is invalid in FakePlayersMode="$ FakePlayersMode $"; using 1", bLogControlledDifficulty);
			Result = 1;
		}
		`cdlog("GetPlayerNumAIMaxModifier: using count "$ Result $": replaced NumLivingPlayers="$ NumLivingPlayers $" with FakePlayers="$ Outer.FakePlayersInt, bLogControlledDifficulty);
	}

	return GetNumPlayersModifier( NumPlayers_WaveSize, Result );
}

/** Scales the health this Zed has by the difficulty level */
// This is invoked by the base game.
function GetAIHealthModifier(KFPawn_Monster P, float ForGameDifficulty, byte NumLivingPlayers, out float HealthMod, out float HeadHealthMod, optional bool bApplyDifficultyScaling=true)
{
	local byte EffectiveNumPlayers;
	local int FakeValue;

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
			FakeValue = Outer.BossFPInt;
		}
		else if ( None != KFPawn_ZedFleshpound( P ) )
		{
			FakeValue = Outer.FleshpoundFPInt;
		}
		else if ( None != KFPawn_ZedScrake( P ) )
		{
			FakeValue = Outer.ScrakeFPInt;
		}
		else
		{
			FakeValue = Outer.TrashFPInt;
		}

		if ( FakePlayersModeEnum == FPM_ADD )
		{
			EffectiveNumPlayers = NumLivingPlayers + FakeValue;
		}
		else
		{
			EffectiveNumPlayers = FakeValue;
			if ( 0 >= EffectiveNumPlayers )
			{
				`cdlog("HealthFP="$ FakeValue $" is invalid in FakePlayersMode="$ FakePlayersMode $"; using 1", bLogControlledDifficulty);
				EffectiveNumPlayers = 1;
			}
		}

		HealthMod *= 1.0 + GetNumPlayersHealthMod( EffectiveNumPlayers, P.DifficultySettings.default.NumPlayersScale_BodyHealth );
		HeadHealthMod *= 1.0 + GetNumPlayersHealthMod( EffectiveNumPlayers, P.DifficultySettings.default.NumPlayersScale_HeadHealth );

		`cdlog("GetAIHealthModifier: Monster="$ P $": HealthMod="$ HealthMod $" EffNumPlayers="$ EffectiveNumPlayers $
		       " NumLivingPlayers="$ NumLivingPlayers $" FPMode="$ FakePlayersMode $" FakeValue="$ FakeValue $")", bLogControlledDifficulty);
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
	if ( 0 < Outer.TraderTimeInt )
	{
		return Outer.TraderTimeInt;
	}

	return super.GetTraderTimeByDifficulty();
}
