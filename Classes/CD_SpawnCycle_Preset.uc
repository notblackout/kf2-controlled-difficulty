interface CD_SpawnCycle_Preset;

/*
 * If this preset is defined for the short GameLength, then
 * clear sink and fill it with SpawnCycleDefs strings specifying
 * this preset's SpawnCycle.  sink will be returned with four
 * elements corresponding to waves 1 through 4 (in ascending
 * index order).
 *
 * If this preset is not defined for the short GameLength,
 * then sink's length will be set to zero.
 */
function GetShortSpawnCycleDefs( out array<string> sink );

/* As above, but for normal GameLength.
 */
function GetNormalSpawnCycleDefs( out array<string> sink );

/* As above, but for long GameLength.
 */
function GetLongSpawnCycleDefs( out array<string> sink );

function string GetName();
