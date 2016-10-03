class CD_EphemeralMatchStats extends EphemeralMatchStats;

function RecordZedKill(Class<Pawn> PawnClass, class<DamageType> DT)
{
	PawnClass = class'ControlledDifficulty.CD_Survival'.static.CheckPawnClassRemap( PawnClass, "CD_EphemeralMatchStats.RecordZedKill" );

	`log("Recording zed kill for PawnClass="$PawnClass );

	super.RecordZedKill( PawnClass, DT );
}
