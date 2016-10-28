class CD_PlayerController extends KFPlayerController;

function AddZedKill( class<KFPawn_Monster> MonsterClass, byte Difficulty, class<DamageType> DT )
{
	local CD_Survival CDGameInfo;
	local bool ShouldLog;

	ShouldLog = true;

	// Try to read CD_Survival.bLogControlledDifficulty
	if ( WorldInfo != None )
	{
		CDGameInfo = CD_Survival( WorldInfo.Game );

		if ( CDGameInfo != None )
		{
			ShouldLog = CDGameInfo.bLogControlledDifficulty;
		}
	}

	MonsterClass = class'CD_ZedNameUtils'.static.CheckMonsterClassRemap( MonsterClass, "CD_PlayerController.AddZedKill", ShouldLog );

	super.AddZedKill( MonsterClass, Difficulty, DT );
}

defaultproperties
{
	MatchStatsClass=class'ControlledDifficulty.CD_EphemeralMatchStats'
}
