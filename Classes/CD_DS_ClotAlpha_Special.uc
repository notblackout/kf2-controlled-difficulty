//=============================================================================
// CD_DS_ClotAlpha_Special
// Sets the special spawnchance to one on all difficulties
//=============================================================================
class CD_DS_ClotAlpha_Special extends KFDifficulty_ClotAlpha
	abstract;

defaultproperties
{
	// Settings for triggering a rally
	RallyTriggerSettings(`DIFFICULTY_Normal)={(SpawnChance=1.0)}
	RallyTriggerSettings(`DIFFICULTY_Hard)={(SpawnChance=1.0, RallyChance=0.00)}
	RallyTriggerSettings(`DIFFICULTY_Suicidal)={(SpawnChance=1.0, RallyChance=0.70, Cooldown=15.0, SelfTakenDamageModifier=0.1, SelfDealtDamageModifier=2.50)}
	RallyTriggerSettings(`DIFFICULTY_HellOnEarth)={(SpawnChance=1.0, RallyChance=0.80, Cooldown=15.0, SelfTakenDamageModifier=0.1, SelfDealtDamageModifier=2.50)}
}
