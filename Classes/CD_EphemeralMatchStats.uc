//=============================================================================
// CD_EphemeralMatchStats
//=============================================================================
// TWI's stat tracking (supporting the after-action report and some steamworks
// stats) depends on the classes of zeds killed.  CD uses custom zed subclasses
// for some behavioral controls (like specifying albinos or non-albinos in
// SpawnCycles).  This class substitutes CD's custom zed subclasses with
// ordinary TWI classes just before TWI's stat code tries to count them.
//=============================================================================


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
