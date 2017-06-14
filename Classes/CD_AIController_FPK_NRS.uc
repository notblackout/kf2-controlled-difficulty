//=============================================================================
// CD_AIController_FPK_NRS
// Sets FleshpoundKing's rage-on-spawn chance to zero
//=============================================================================

class CD_AIController_FPK_NRS extends KFAIController_ZedFleshpoundKing;

`include(CD_Log.uci)

function DoSpawnRageCheck()
{
}

// This is redundant.  SpawnRagedChance is only read in
// DoSpawnRageCheck, and we override it to a noop.
defaultproperties
{
	SpawnRagedChance(`DIFFICULTY_NORMAL)=0.f
	SpawnRagedChance(`DIFFICULTY_HARD)=0.f
	SpawnRagedChance(`DIFFICULTY_SUICIDAL)=0.f
	SpawnRagedChance(`DIFFICULTY_HELLONEARTH)=0.f
}
