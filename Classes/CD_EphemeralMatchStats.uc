class CD_EphemeralMatchStats extends EphemeralMatchStats;

function RecordZedKill(Class<Pawn> PawnClass, class<DamageType> DT)
{
	PawnClass = class'CD_ZedNameUtils'.static.CheckPawnClassRemap( PawnClass, "CD_EphemeralMatchStats.RecordZedKill" );

	`log("Recording zed kill for PawnClass="$PawnClass );

	super.RecordZedKill( PawnClass, DT );
}
