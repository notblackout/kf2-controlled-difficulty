//=============================================================================
// CD_Pawn_ZedFleshpoundKing_NoMinions
// Albino fleshpound with his extra "boss minion" spawning disabled
//=============================================================================
class CD_Pawn_ZedFleshpoundKing_NoMinions extends KFPawn_ZedFleshpoundKing;

`include(CD_Log.uci)

static event class<KFPawn_Monster> GetAIPawnClassToSpawn()
{
	`cdlog("CD_Pawn_ZedFleshpoundKing_NoMinions: default.class="$ default.class);
	return default.class;
}

function SpawnSubWave()
{
	// Do nothing
}

function PauseBossWave()
{
	// Do nothing
}

defaultproperties
{
	ControllerClass=class'CD_AIController_FPK_NRS'
	DifficultySettings=class'CD_DS_Fleshpound_Special'
}
