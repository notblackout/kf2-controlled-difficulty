//=============================================================================
// CD_Pawn_ZedFleshpoundMini_RS
// Mini fleshpound ("Quarter Pound") with guaranteed rage-on-spawn
//=============================================================================
class CD_Pawn_ZedFleshpoundMini_RS extends KFPawn_ZedFleshpoundMini;

static event class<KFPawn_Monster> GetAIPawnClassToSpawn()
{
	return default.class;
}

defaultproperties
{
	ControllerClass=class'CD_AIController_FP_RS'
	DifficultySettings=class'KFDifficulty_FleshpoundMini'
}
