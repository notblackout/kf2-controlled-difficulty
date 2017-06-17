//=============================================================================
// CD_AIWaveInfo
//=============================================================================
// As with CD_AISpawnSquad, this exists to work around constness in TWI's
// KFAIWaveInfo, supporting runtime-modifiable spawn information for
// user-provided SpawnCycles.
//=============================================================================

class CD_AIWaveInfo extends Object;

// TWI declared KFAIWaveInfo's state const, which makes it a pain in the ass to
// use with SpawnCycles, since SpawnCycles involve parsing and setting up wave
// info dynamically at runtime in response to user input that is not known at
// compile time.

/** List of available squads to spawn for each wave */
var array<CD_AISpawnSquad> CustomSquads;

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
