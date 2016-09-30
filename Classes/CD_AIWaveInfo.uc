class CD_AIWaveInfo extends KFAIWaveInfo;

// TWI declared all of these vars const in KFAIWaveInfo,
// which makes this a completely hideous nightmare.
// It's difficult to work around the constness of these
// vars without either preparing a shitload of archetypes
// (for each cfg permutation) or bytecode editing.  There's
// no deep reason it has to be this way; a mere interface
// could have avoided all of this idiocy.

/** Once a squad is dead, do not reuse them */
var bool	CustombRecycleWave;

/** List of available squads to spawn for each wave */
var array<KFAISpawnSquad>		CustomSquads;

/** Copy the list of squads for this wave type */
function CopySquads(out array<KFAISpawnSquad> out_SquadList)
{
	local int i;

    // Clear our AvailableSquadList and repopulate it
	out_SquadList.Length = 0;

	for ( i = 0; i < CustomSquads.Length; i++ )
	{
		if ( CustomSquads[i] != none )
		{
			out_SquadList.AddItem(CustomSquads[i]);
		}
	}
}

//interface CD_AIWaveInfo;
//
///** Once a squad is dead, do not reuse them
//    In practice, isRecycleWave = !isNotBossWave */
//function bool CanRecycleWave();
//
///** List of available squads to spawn for each wave */
//function array<CD_AISpawnSquad> GetRegularSquads();
//
///** The special squads - spawned once per wave */
//function array<CD_AISpawnSquad> GetSpecialSquads();
//
///** Total number of AI that spawn for 1 player on Normal */
//function int GetMaxAI();
////var	int	MaxAI<ClampMin=1|ClampMax=200|DisplayName=TotalAIBase>;	// make this max=42 for release
//
///** Squads that can be triggered to spawn */
//function array<CD_AISpawnSquad> GetEventSquads();
