//=============================================================================
// CDSpawnManager
//
// This is the common parent class for CD's various game-length-specific
// SpawnManager subclasses.  Having one subclass per game-length is a
// convention inherited from the base game.
// This lets us override GetMaxMonsters() once for all of the
// game-length-specific subclasses.
//=============================================================================
class CDSpawnManager extends KFAISpawnManager
	within CD_Survival;

var int CustomMaxMonsters;

// Configuration setter
function SetCustomMaxMonsters( int mm )
{
	local KFGameViewportClient GVC;

	CustomMaxMonsters = mm;
	`log("Setting MaxMonsters = "$CustomMaxMonsters$" (nonpositive values mean \"use the unmodded value\")", Outer.bLogControlledDifficulty);

	// print MaxMonsters to the console (most people never see this value in the log)
       	GVC = KFGameViewportClient(class'GameEngine'.static.GetEngine().GameViewport);
	if (0 < CustomMaxMonsters)
	{
		GVC.ViewportConsole.OutputTextLine("[ControlledDifficulty] MaxMonsters="$GetMaxMonsters());
	}
	else
	{
		GVC.ViewportConsole.OutputTextLine("[ControlledDifficulty] MaxMonsters=<unmodded default>");
	}
}

// Configuration getter (the base game never invokes this method; its just for CD)
function int GetCustomMaxMonsters()
{
	return CustomMaxMonsters;
}

// This function is invoked by the spawning system in the base game.
// Its return value is the maximum number of simultaneously live zeds
// allowed on the map at one time.
function int GetMaxMonsters()
{
	local int mm;

	if (0 < CustomMaxMonsters)
	{
		`log("GetMaxMonsters(): Returning "$CustomMaxMonsters, Outer.bLogControlledDifficulty);
		return CustomMaxMonsters;
	}
	else
	{
		mm = super.GetMaxMonsters();
		`log("GetMaxMonsters(): Returning "$mm, Outer.bLogControlledDifficulty);
		return mm;
	}
}
