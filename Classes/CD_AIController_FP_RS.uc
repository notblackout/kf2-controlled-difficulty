//=============================================================================
// CD_AIController_FP_RS
// Sets Fleshpound's rage-on-spawn chance to one
//=============================================================================

class CD_AIController_FP_RS extends KFAIController_ZedFleshpound;

`include(CD_Log.uci)

function DoSpawnRageCheck()
{
	local KFGameInfo KFGI;

	KFGI = KFGameInfo( WorldInfo.Game );

	if(KFGI == none)
	{
		return;
	}

	// Initialize LastEnemySightedTime.  As of 1053, neither the standard
	// FP AI controller nor the rage plugin seems to initialize this, even
	// when executing rage-on-spawn.  LastEnemySightedTime defaults to zero.
	// This means FPs that spawn after 30 seconds into the match which rage on
	// spawn will instantly de-rage in the next game tick (less than a second,
	// before their groundpound animation is even done).
	LastEnemySightedTime = WorldInfo.TimeSeconds;
	RagePlugin.DoSpawnRage();
}

// We don't need to set these.  Our DoSpawnRageCheck override ignores them.
// However, we only override DoSpawnRageCheck because of a bug in TWI's
// standard rage-on-spawn mechanic.  If TWI fixes the bug, our override
// could go away, and then we'd rely on these SpawnRageChance values again.
// Leaving them here in case they're needed again.
defaultproperties
{
	SpawnRagedChance(`DIFFICULTY_NORMAL)=1.f
	SpawnRagedChance(`DIFFICULTY_HARD)=1.f
	SpawnRagedChance(`DIFFICULTY_SUICIDAL)=1.f
	SpawnRagedChance(`DIFFICULTY_HELLONEARTH)=1.f
}
