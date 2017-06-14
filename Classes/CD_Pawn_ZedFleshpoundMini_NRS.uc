//=============================================================================
// CD_Pawn_ZedFleshpoundMini_NRS
// Mini fleshpound ("Quarter Pound") with rage-on-spawn disabled
//=============================================================================
class CD_Pawn_ZedFleshpoundMini_NRS extends KFPawn_ZedFleshpoundMini;

static event class<KFPawn_Monster> GetAIPawnClassToSpawn()
{
	return default.class;
}

defaultproperties
{
	ControllerClass=class'CD_AIController_FP_NRS'
	DifficultySettings=class'KFDifficulty_FleshpoundMini'
}
