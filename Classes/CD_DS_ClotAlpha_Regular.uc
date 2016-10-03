//=============================================================================
// CD_DS_ClotAlpha_Regular
// Sets the special spawnchance to zero on all difficulties
//=============================================================================
class CD_DS_ClotAlpha_Regular extends KFDifficulty_ClotAlpha
	abstract;

// The Alpha AI controller's InitRallySettings() ultimately decides
// whether a newly-spawned alpha becomes special or not.  It does
// this by comparing fRand() against SpawnChance.  

defaultproperties
{
	RallyTriggerSettings(`DIFFICULTY_Normal)	={(SpawnChance=0.0, RallyChance=0.0)}
	RallyTriggerSettings(`DIFFICULTY_Hard)		={(SpawnChance=0.0, RallyChance=0.0)}
	RallyTriggerSettings(`DIFFICULTY_Suicidal)	={(SpawnChance=0.0, RallyChance=0.0)}
	RallyTriggerSettings(`DIFFICULTY_HellOnEarth)	={(SpawnChance=0.0, RallyChance=0.0)}
}
