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

function float GetPlayerNumMaxAIModifier( byte NumLivingPlayers )
{
	local int EffectivePlayerCount;

	EffectivePlayerCount = GetEffectivePlayerCount( NumLivingPlayers );

	return GetNumPlayersModifier( NumPlayers_WaveSize, EffectivePlayerCount );
}

/*
 * Extended from TWI.  The only callsite for this is in KFGameInfo.SetMonsterDefaults,
 * and CD_Survival replaces that call with an equivalent one to
 * GetDamageResistanceModifierForZedType (a CD-specific extension).
 *
 * Nothing should ever call this function.  It's intrinsically unsafe because it
 * can't tell which of Boss/Fleshpound/Scrake/TrashHPFakes to apply to its
 * return value.
 */
function float GetDamageResistanceModifier( byte NumLivingPlayers )
{
	`cdlog("ERROR: GetDamageResistanceModifier should never be called.  Zed HP scaling may be broken!");

	return super.GetDamageResistanceModifier( NumLivingPlayers );
}

function float GetDamageResistanceModifierForZedType( KFPawn_Monster P, byte NumLivingPlayers )
{
	local int EffectiveNumPlayers;

	EffectiveNumPlayers = GetEffectivePlayerCountForZedType( P, NumLivingPlayers );

	return GetNumPlayersModifier( NumPlayers_ZedDamageResistance, EffectiveNumPlayers );
}

function GetVersusHealthModifier(KFPawn_Monster P, byte NumLivingPlayers, out float HealthMod, out float HeadHealthMod)
{
	local byte EffectiveNumPlayers;

	if ( P != none )
	{
		HealthMod = GetGlobalHealthMod();
		HeadHealthMod = GetGlobalHealthMod();

		EffectiveNumPlayers = GetEffectivePlayerCountForZedType( P, NumLivingPlayers );

		// Add another multiplier based on the number of players and the zeds character info scalers
		HealthMod *= 1.0 + (GetNumPlayersHealthMod( EffectiveNumPlayers, P.DifficultySettings.default.NumPlayersScale_BodyHealth_Versus ));
		HeadHealthMod *= 1.0 + (GetNumPlayersHealthMod( EffectiveNumPlayers, P.DifficultySettings.default.NumPlayersScale_HeadHealth_Versus ));
	}
}

function GetAIHealthModifier(KFPawn_Monster P, float ForGameDifficulty, byte NumLivingPlayers, out float HealthMod, out float HeadHealthMod, optional bool bApplyDifficultyScaling=true)
{
	local byte EffectiveNumPlayers;

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

		EffectiveNumPlayers = GetEffectivePlayerCountForZedType( P, NumLivingPlayers );

		HealthMod *= 1.0 + GetNumPlayersHealthMod( EffectiveNumPlayers, P.DifficultySettings.default.NumPlayersScale_BodyHealth );
		HeadHealthMod *= 1.0 + GetNumPlayersHealthMod( EffectiveNumPlayers, P.DifficultySettings.default.NumPlayersScale_HeadHealth );

		`cdlog("GetAIHealthModifier: Monster="$ P $": HealthMod="$ HealthMod $" EffectiveNumPlayers="$ EffectiveNumPlayers $
		       " NumLivingPlayers="$ NumLivingPlayers, bLogControlledDifficulty);
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
