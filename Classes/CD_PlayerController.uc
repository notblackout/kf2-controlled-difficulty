class CD_PlayerController extends KFPlayerController;

function AddZedKill( class<KFPawn_Monster> MonsterClass, byte Difficulty, class<DamageType> DT )
{
	if ( MonsterClass == class'CDPawn_ZedCrawler' )
	{
		MonsterClass = class'KFPawn_ZedCrawler';
		`log("Mapped CDPawn_ZedCrawler to KFPawn_ZedCrawler in AddZedKill(...)");
	}

	super.AddZedKill( MonsterClass, Difficulty, DT );
}

defaultproperties
{
	MatchStatsClass=class'ControlledDifficulty.CD_EphemeralMatchStats'
}
