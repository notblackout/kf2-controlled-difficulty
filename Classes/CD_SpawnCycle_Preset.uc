//=============================================================================
// CD_SpawnCycle_Preset
//=============================================================================
// The shared interface implemented by all hardcoded CD SpawnCycle values
//=============================================================================

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

/* 
 * Returns the SpawnCycle name.  The user sets SpawnCycle=<this>
 * to activate the preset.
 */
function string GetName();

/*
 * The approximate date that the preset was first added to
 * Controlled Difficulty.  Shown to the user in listings of
 * available presets.
 */
function string GetDate();

/*
 * The name/username/alias of the preset's author(s).
 */
function string GetAuthor();
