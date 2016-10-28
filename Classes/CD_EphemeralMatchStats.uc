class CD_EphemeralMatchStats extends EphemeralMatchStats;

`include(CD_Log.uci)

function RecordZedKill(Class<Pawn> PawnClass, class<DamageType> DT)
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

	PawnClass = class'CD_ZedNameUtils'.static.CheckPawnClassRemap( PawnClass, "CD_EphemeralMatchStats.RecordZedKill", ShouldLog );

	`cdlog("Recording stat: player killed a zed with PawnClass="$PawnClass, ShouldLog);

	super.RecordZedKill( PawnClass, DT );
}
