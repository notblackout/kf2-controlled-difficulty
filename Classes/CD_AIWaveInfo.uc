//=============================================================================
// CD_AIWaveInfo
//=============================================================================
// As with CD_AISpawnSquad, this exists to work around constness in TWI's
// KFAIWaveInfo, supporting runtime-modifiable spawn information for
// user-provided SpawnCycles.
//=============================================================================


class CD_AIWaveInfo extends KFAIWaveInfo;

// TWI declared all of these vars const in KFAIWaveInfo,
// which makes this a completely hideous nightmare.
// It's difficult to work around the constness of these
// vars without either preparing a shitload of archetypes
// (for each cfg permutation) or bytecode editing.  There's
// no deep reason it has to be this way; a mere interface
// could have avoided all of this idiocy.

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
