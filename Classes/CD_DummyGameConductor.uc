//=============================================================================
// CD_DummyGameConductor
//=============================================================================
// Lobotomized game conductor
//=============================================================================

class CD_DummyGameConductor extends KFGameConductor within CD_Survival;

var float SpawnMod;

/** Conductor's periodic "think" method **/
function TimerUpdate()
{
	CurrentSpawnRateModification = SpawnMod;
	CurrentAIMovementSpeedMod = DifficultyInfo.GetAIGroundSpeedMod();
	`log("(GameConductor woken up) ControlledDifficulty forcing SpawnMod = "$CurrentSpawnRateModification$" AIMoveSpeedMod = "$CurrentAIMovementSpeedMod, Outer.bLogControlledDifficulty);
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

function SetSpawnMod( float csm )
{
	local KFGameViewportClient GVC;

	SpawnMod = csm;
	`log("Set Dummy SpawnMod = "$SpawnMod, Outer.bLogControlledDifficulty);

	// print SpawnMod to the console (most people never see the log)
	GVC = KFGameViewportClient(class'GameEngine'.static.GetEngine().GameViewport);
	GVC.ViewportConsole.OutputText("[ControlledDifficulty] SpawnMod="$SpawnMod);
}

function float GetSpawnMod()
{
	return SpawnMod;
}
