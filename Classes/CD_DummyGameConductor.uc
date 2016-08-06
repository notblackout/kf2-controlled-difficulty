//=============================================================================
// CD_DummyGameConductor
//=============================================================================
// Lobotomized game conductor
//=============================================================================

class CD_DummyGameConductor extends KFGameConductor within KFGameInfo;

var float SpawnMod;

/** Conductor's periodic "think" method **/
function TimerUpdate()
{
	CurrentSpawnRateModification = SpawnMod;
	CurrentAIMovementSpeedMod = DifficultyInfo.GetAIGroundSpeedMod();
	`log("Dummy SpawnMod = "$CurrentSpawnRateModification$" AIMoveSpeedMod = "$CurrentAIMovementSpeedMod, bLogGameConductor);
}

/**
 * At the time I wrote this file, the only entry point for
 * the Evaluate***() family of methods was TimerUpdate().
 * So, making TimerUpdate() do nothing should turn the
 * Evaluate***() methods into dead code.  However, I'm
 * overriding them anyway in case I missed a call site,
 * or in case a future patch introduces a new call site.
 */

function EvaluateSpawnRateModification()
{
	// do nothing
}

function EvaluateAIMovementSpeedModification()
{
	// do nothing
}

function SetSpawnMod( float csp )
{
	SpawnMod = csp;
	`log("Set Dummy SpawnMod = "$SpawnMod);
}

defaultproperties
{
	//bLogGameConductor=true
}
