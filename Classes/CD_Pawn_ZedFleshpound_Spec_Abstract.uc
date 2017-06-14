//=============================================================================
// CD_Pawn_ZedFleshpound_Spec_Abstract
// Albino fleshpound with his extra "boss minion" spawning disabled
//=============================================================================
class CD_Pawn_ZedFleshpound_Spec_Abstract extends KFPawn_ZedFleshpoundKing
	Abstract;

`include(CD_Log.uci)

static event class<KFPawn_Monster> GetAIPawnClassToSpawn()
{
	`cdlog("CD_Pawn_ZedFleshpound_Spec_Abstract: default.class="$ default.class);
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
	DifficultySettings=class'CD_DS_Fleshpound_Special'
}
