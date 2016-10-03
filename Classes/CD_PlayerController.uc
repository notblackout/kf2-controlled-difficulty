class CD_PlayerController extends KFPlayerController;

function AddZedKill( class<KFPawn_Monster> MonsterClass, byte Difficulty, class<DamageType> DT )
{
	MonsterClass = class'CD_Survival'.static.CheckMonsterClassRemap( MonsterClass, "CD_PlayerController.AddZedKill" );

	super.AddZedKill( MonsterClass, Difficulty, DT );
}

defaultproperties
{
	MatchStatsClass=class'ControlledDifficulty.CD_EphemeralMatchStats'
}
